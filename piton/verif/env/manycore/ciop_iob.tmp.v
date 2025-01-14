// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: ciop_iob.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
//
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
//
// The above named program is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
//
// ========== Copyright Header End ============================================
`timescale 1ps/1ps
`include "define.vh"
`include "cross_module.tmp.h"

`define NUM_TILES 1
`define X_TILES 1
`define Y_TILES 1


module ciop_fake_iob(
    input clk,
    input rst_n,

    input noc_in_val,
    output reg noc_in_rdy,
    input [`NOC_DATA_WIDTH-1:0] noc_in_data,

    output reg noc_out_val,
    input noc_out_rdy,
    output reg [`NOC_DATA_WIDTH-1:0] noc_out_data,
   input                spc0_inst_done,
   input [48:0]         pc_w0



);
`ifndef __ICARUS__
//temp. memory.
reg [`IOB_CPU_WIDTH-1:0] 	    fake_iob_out_req;
reg [`CPX_WIDTH-1:0] 	    fake_iob_out_data;

wire [`CPX_WIDTH-1:0]       cpx_data = fake_iob_out_data;

//Input buffer
reg [`NOC_DATA_WIDTH-1:0] in_buffer [1:0];
reg [`NOC_DATA_WIDTH-1:0] noc_buffer_write_packet;
reg [3:0] in_buffer_counter;
reg [3:0] in_buffer_counter_next;

// buffer to iob interface
reg buffer_iob_val;
reg buffer_iob_rdy = 1'b1; // iob always accept packets
reg [2*`NOC_DATA_WIDTH-1:0] buffer_iob_data; // TODO: error?

// this block determines the next index for writing
always @ (posedge clk)
begin
    if (noc_in_val && noc_in_rdy)
    begin
        in_buffer_counter_next = in_buffer_counter + 1;
    end
    else if (buffer_iob_val && buffer_iob_rdy)
    begin
        in_buffer_counter_next = 0;
    end
    else
    begin
        in_buffer_counter_next = in_buffer_counter;
    end

    if (in_buffer_counter > 2)
    begin
        $display("%d : Simulation -> FAIL(%0s)", $time, "ciop_iob.v: IOB in buffer overflowed");
        repeat(5)@(posedge clk);
        `MONITOR_PATH.fail("ciop_iob.v: IOB in buffer overflowed");
    end
end

always @ (posedge clk)
begin
    if (!rst_n)
    begin
        in_buffer[0] <= 0;
        in_buffer[1] <= 0;
    end
    else
    begin
        if (noc_in_val && noc_in_rdy)
            in_buffer[in_buffer_counter] <= noc_in_data;
    end
end

always @ (posedge clk)
begin
    if (!rst_n)
    begin
        in_buffer_counter <= 0;
    end
    else
    begin
        in_buffer_counter <= in_buffer_counter_next;
    end
end

reg noc_in_buf_full;
always @ *
begin
    noc_in_buf_full = (in_buffer_counter ==  2);
    noc_in_rdy = !noc_in_buf_full;
    buffer_iob_val = noc_in_buf_full;
    buffer_iob_data = {in_buffer[0], in_buffer[1]};
end


// Output buffer
// The output buffer need to be asynchronous and cannot ever be overflowed.
// We will ensure this by having a lot of entries
localparam NUM_ASYNC_ENTRIES = 256;

reg [`NOC_DATA_WIDTH-1:0] out_buffer [NUM_ASYNC_ENTRIES-1:0];
reg [NUM_ASYNC_ENTRIES-1:0] out_buffer_val;

reg iob_buffer_val;
reg [2*`NOC_DATA_WIDTH-1:0] iob_buffer_data;

///////////////////////////////////////////////////////////
// write port of the async fifo; runs at chip frequency
///////////////////////////////////////////////////////////
reg [7:0] out_write_index;
reg [7:0] out_write_index_next;

integer i;

always @ (posedge `CHIP.clk_muxed)
begin
    if (!rst_n)
        out_write_index <= 0;
    else
    begin
        out_write_index <= out_write_index_next;
    end

    // write port
    if (!rst_n)
        for (i = 0; i < NUM_ASYNC_ENTRIES; i = i + 1)
        begin
            out_buffer[i] = 0;
            out_buffer_val[i] = 1'b0;
        end
    else
    begin
        if (iob_buffer_val)
        begin
            // no ready; always accepting packet
            out_buffer[out_write_index + 1] = iob_buffer_data[63:0];
            out_buffer[out_write_index] = iob_buffer_data[127:64];
            out_buffer_val[out_write_index] = 1'b1;
            out_buffer_val[out_write_index + 1] = 1'b1;
        end
    end

end

always @ *
begin
    out_write_index_next = iob_buffer_val ? out_write_index + 2 : out_write_index;
end


///////////////////////////////////////////////////////////
// read port of the async fifo; runs at off-chip frequency
///////////////////////////////////////////////////////////
reg [7:0] out_read_index;
reg [7:0] out_read_index_next;

always @ (posedge clk)
begin
    if (!rst_n)
        out_read_index <= 0;
    else
    begin
        out_read_index <= out_read_index_next;
    end

    if (noc_out_rdy && noc_out_val)
    begin
        out_buffer_val[out_read_index] = 1'b0;
    end
end

always @ *
begin
    noc_out_val = out_buffer_val[out_read_index];
    noc_out_data = 0; // Tri: fixes x when out_buffer_counter == 0
    noc_out_data = out_buffer[out_read_index];

    out_read_index_next = (noc_out_rdy && noc_out_val) ? out_read_index + 1 : out_read_index;
end

///////////////////////////////////////////////////////////
// Make out going packets from IOB out data
///////////////////////////////////////////////////////////
reg [63:0] iob_buffer_flit1;
reg [63:0] iob_buffer_flit2;
reg  [5:0] dest_x;
reg  [5:0] dest_y;
always @ *
begin
   iob_buffer_val = fake_iob_out_data[144];
   iob_buffer_flit1 = {14'b0,5'b0, 3'b0, 8'b0,`NOC_FBITS_L1,8'd1, `MSG_TYPE_INTERRUPT,14'b0};
   iob_buffer_flit2 = {fake_iob_out_data[63:16],7'b0,fake_iob_out_data[8:0]};

   // assuming a 8x8 topo
   iob_buffer_flit1[`MSG_DST_X] = dest_x;
   iob_buffer_flit1[`MSG_DST_Y] = dest_y;

   if (iob_buffer_val)
   begin
      $display("IOB sending to tile X:%d Y:%d", iob_buffer_flit1[`MSG_DST_X], iob_buffer_flit1[`MSG_DST_Y]);
      $display("   raw tileid %x", fake_iob_out_data[49:18]);
    end

   iob_buffer_data = {iob_buffer_flit1, iob_buffer_flit2};
end

always @*
begin
    case (fake_iob_out_data[49:18])
    
32'd0: 
begin
    dest_x = `NOC_X_WIDTH'd0;
    dest_y = `NOC_Y_WIDTH'd0;
end

    default:
    begin
        dest_x = `NOC_X_WIDTH'dX;
        dest_y = `NOC_Y_WIDTH'dX;
    end
    endcase
end


// input signals
wire  [`PCX_WIDTH-1:0]           pcx_iob_data        = {buffer_iob_val,5'b01001,1'b0,3'b0,2'b0,48'b0,buffer_iob_data[63:0]};
wire  [`IOB_CPU_WIDTH-1:0]       cpx_iob_grant       = fake_iob_out_req; // basically always ready

wire                             spc0_inst_done_buf  = spc0_inst_done;
wire [48:0]                      pc_w0_buf           = pc_w0;




reg 	 ok_iob;
initial
begin
    ok_iob    = 0;
    fake_iob_out_req   = 0;
    fake_iob_out_data  = 0;

	$init_iob_model();
end

// cmp clock domain
// trin bug #65: use reference clock from the chip b/c the fake iob
// needs to monitor the core PC
always @(negedge `CHIP.clk_muxed)
begin
    if(ok_iob)
    begin
        $iob_cdriver(//input to pli
            //pcx packet from core
            pcx_iob_data,
            //cpx request from iob
            fake_iob_out_req,
            fake_iob_out_data,
            //grand and request
            cpx_iob_grant,
            //pc event
            spc0_inst_done_buf,
            pc_w0_buf


        );

        // a little error check
        if (iob_buffer_val && (out_buffer_val[out_write_index] | out_buffer_val[out_write_index + 1] == 1'b1))
        begin
            $display("%d : Simulation -> FAIL(%0s)", $time, "ciop_iob.v: IOB out buffer overflowed");
            repeat(5)@(posedge clk);
            `MONITOR_PATH.fail("ciop_iob.v: IOB out buffer overflowed");
        end
    end // if (ok_iob)
end // always @ (posedge cmp_gclk)

`else
// Code from ciop_iob for FPGA
reg                     ok_iob;

initial
begin
    ok_iob    = 0;
end

// making wake up packet
parameter FLIT_TO_SEND = 2;

wire [63:0]         iob_buffer_flit1;
wire [63:0]         iob_buffer_flit2;
reg                 iob_buffer_val;
reg  [1:0]          flit_cnt;

assign iob_buffer_flit1     = 64'h0000_0000_0048_4000;
assign iob_buffer_flit2     = 64'h0000_0000_0001_0001;

reg                 ok_iob_sent;

always @(posedge clk) begin
    if (~rst_n) begin
        flit_cnt <= 2'b0;
    end
    else if (~ok_iob_sent) begin
        flit_cnt <= noc_out_val & noc_out_rdy ? flit_cnt + 1 : flit_cnt;
    end 
    else begin
        flit_cnt <= flit_cnt;
    end
end

always @(posedge clk)
    iob_buffer_val <= ok_iob;

always @* begin
    noc_out_val = iob_buffer_val & (((flit_cnt < FLIT_TO_SEND) && !ok_iob_sent));
end

always @(*) begin
    if (!ok_iob_sent) begin
        if(flit_cnt == 2'b0) begin
            noc_out_data = iob_buffer_flit1;
        end else if (flit_cnt == 2'b1) begin
            noc_out_data = iob_buffer_flit2;
        end 
        else begin
            noc_out_data =  {`NOC_DATA_WIDTH{1'b0}};
        end
    end 
    else begin
        noc_out_data =  {`NOC_DATA_WIDTH{1'b0}};
    end
end

// Note when ok_iob finishes sending both packets
// ok_iob_sent could technically be a wire fed by flit_cnt?
always @(posedge clk) begin
    if (~rst_n) begin
        ok_iob_sent <= 1'b0;
    end
    else if (flit_cnt == FLIT_TO_SEND) begin
       ok_iob_sent <= 1'b1;
    end
end

`endif

endmodule

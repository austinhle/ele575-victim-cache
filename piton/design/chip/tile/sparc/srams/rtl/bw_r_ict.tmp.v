// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: bw_r_ict.v
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
////////////////////////////////////////////////////////////////////////
/*
 //  Module Name:  bw_r_ict.v
 //  Description:
 //    Contains the RTL for the icache and dcache tag blocks.
 //    This is a 1RW 512 entry X 33b macro, with 132b rd and 132b wr,
 //    broken into 4 33b segments with its own write enable.
 //    Address and Control inputs are available the stage before
 //    array access, which is referred to as "_x".  Write data is
 //    available in the same stage as the write to the ram, referred
 //    to as "_y".  Read data is also read out and available in "_y".
 //
 //            X       |      Y
 //     index          |  ram access
 //     index sel      |  write_tag
 //     rd/wr req      |     -> read_tag
 //     way enable     |
 */


////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////





`ifdef SIM_FPGA_SYN_SRAM_ICACHE_TAG // simulation flag
`define PITON_PROTO
`endif

`ifdef FPGA_FORCE_SRAM_ICACHE_TAG
`undef PITON_PROTO
`endif


//PITON_PROTO enables all FPGA related modifications
`ifdef PITON_PROTO
`define FPGA_SYN_ICT
`else
`define SRAM_ICACHE_TAG
`endif

`ifdef FPGA_SYN_ICT

module bw_r_ict(rdtag_y, so, rclk, se,
//`else
//module bw_r_ict_orig(rdtag_y, so, rclk, se,
//`endif
	si, reset_l, sehold, rst_tri_en, index0_x, index1_x, index_sel_x,
	dec_wrway_x, rdreq_x, wrreq_x, wrtag_y,
	wrtag_x,
  adj,

  // sram wrapper interface
  sramid,
  srams_rtap_data,
  rtap_srams_bist_command,
  rtap_srams_bist_data
  );

	input			rclk;
	input			se;
	input			si;
	input			reset_l;
	input			sehold;
	input			rst_tri_en;
  input [`IC_SET_IDX_HI:0]   index0_x;
  input [`IC_SET_IDX_HI:0]   index1_x;
	input			index_sel_x;
	input	[`IC_WAY_ARRAY_MASK]		dec_wrway_x;
	input			rdreq_x;
	input			wrreq_x;
  input [`IC_TLB_TAG_MASK] wrtag_x;
  input [`IC_TLB_TAG_MASK] wrtag_y;
	input	[`IC_WAY_ARRAY_MASK]		adj;

  // sram wrapper interface
  output [`SRAM_WRAPPER_BUS_WIDTH-1:0] srams_rtap_data;
  // dummy output for the reference model
  assign srams_rtap_data = 4'b0;
  input  [`BIST_OP_WIDTH-1:0] rtap_srams_bist_command;
  input  [`SRAM_WRAPPER_BUS_WIDTH-1:0] rtap_srams_bist_data;
  input  [`BIST_ID_WIDTH-1:0] sramid;
  wire unused = rtap_srams_bist_command
                | rtap_srams_bist_data
                | sramid;

  output  [`IC_TLB_TAG_MASK_ALL] rdtag_y;
	output			so;

  wire _unused_sink = |wrtag_x; // wrtag_x is unused in this implementation

	wire			clk;
	reg	[`IC_SET_IDX_HI:0]		index_y;
	reg			rdreq_y;
	reg			wrreq_y;
	reg	[`IC_WAY_ARRAY_MASK]		dec_wrway_y;
	wire	[`IC_SET_IDX_HI:0]		index_x;
	wire	[`IC_WAY_ARRAY_MASK]		we;

   	reg [`IC_TLB_TAG_MASK_ALL]  rdtag_sa_y; //for error_inject XMR

	assign clk = rclk;
	assign index_x = (index_sel_x ? index1_x : index0_x);
    assign we = ({`IC_NUM_WAY {((wrreq_y & reset_l) & (~rst_tri_en))}} & dec_wrway_y);

	always @(posedge clk) begin
	  if (~sehold) begin
	    rdreq_y <= rdreq_x;
	    wrreq_y <= wrreq_x;
	    index_y <= index_x;
	    dec_wrway_y <= dec_wrway_x;
	  end
	end

  
  bw_r_ict_array ictag_ary_0(
    .we (we[0]),
    .clk  (clk),
        .way (`IC_WAY_IDX_WIDTH'd0),
    .rd_data(rdtag_y[`IC_TLB_TAG_WAY0_MASK]),
    .wr_data(wrtag_y),
    .addr (index_y),
    .dec_wrway_y (dec_wrway_y));


  bw_r_ict_array ictag_ary_1(
    .we (we[1]),
    .clk  (clk),
        .way (`IC_WAY_IDX_WIDTH'd1),
    .rd_data(rdtag_y[`IC_TLB_TAG_WAY1_MASK]),
    .wr_data(wrtag_y),
    .addr (index_y),
    .dec_wrway_y (dec_wrway_y));


  bw_r_ict_array ictag_ary_2(
    .we (we[2]),
    .clk  (clk),
        .way (`IC_WAY_IDX_WIDTH'd2),
    .rd_data(rdtag_y[`IC_TLB_TAG_WAY2_MASK]),
    .wr_data(wrtag_y),
    .addr (index_y),
    .dec_wrway_y (dec_wrway_y));


  bw_r_ict_array ictag_ary_3(
    .we (we[3]),
    .clk  (clk),
        .way (`IC_WAY_IDX_WIDTH'd3),
    .rd_data(rdtag_y[`IC_TLB_TAG_WAY3_MASK]),
    .wr_data(wrtag_y),
    .addr (index_y),
    .dec_wrway_y (dec_wrway_y));



endmodule

module bw_r_ict_array(we, clk, rd_data, wr_data, addr,dec_wrway_y,way);

input we;
input clk;
input [`IC_TLB_TAG_MASK] wr_data;
input [`IC_SET_IDX_HI:0] addr;
input [`IC_WAY_ARRAY_MASK] dec_wrway_y;
input [`IC_WAY_MASK] way;
output [`IC_TLB_TAG_MASK] rd_data;
reg [`IC_TLB_TAG_MASK] rd_data;

reg	[`IC_TLB_TAG_MASK]		array[`IC_ENTRY_HI:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
integer i;

initial begin
// `ifdef DO_MEM_INIT
//     // Add the memory init file in the database
//     $readmemb("/import/dtg-data11/sandeep/niagara/design/sys/iop/srams/rtl/mem_init_ict.txt",array);
// `endif
  // Tri: nonsynthesizable
  for (i = 0; i <= `IC_ENTRY_HI; i = i + 1)
  begin
    array[i] = {`IC_TAG_SZ{1'b0}};
  end
end

	always @(negedge clk) begin
	  if (we)
          begin
              array[addr] <= wr_data;
          end
	  else
          rd_data <= array[addr];
	end
endmodule

`endif

`ifdef SRAM_ICACHE_TAG
module bw_r_ict(rdtag_y, so, rclk, se,
  si, reset_l, sehold, rst_tri_en, index0_x, index1_x, index_sel_x,
  dec_wrway_x, rdreq_x, wrreq_x, wrtag_y,
  wrtag_x, adj,

  // sram wrapper interface
  sramid,
  srams_rtap_data,
  rtap_srams_bist_command,
  rtap_srams_bist_data
  );

  input     rclk;
  input     se;
  input     si;
  input     reset_l;
  input     sehold;
  input     rst_tri_en;
  input [`IC_SET_IDX_HI:0]   index0_x;
  input [`IC_SET_IDX_HI:0]   index1_x;
  input     index_sel_x;
  input [`IC_WAY_ARRAY_MASK]   dec_wrway_x;
  input     rdreq_x;
  input     wrreq_x;
  input [`IC_TLB_TAG_MASK] wrtag_x;
  input [`IC_TLB_TAG_MASK] wrtag_y;
  input [`IC_WAY_ARRAY_MASK]   adj;


  // sram wrapper interface
  output [`SRAM_WRAPPER_BUS_WIDTH-1:0] srams_rtap_data;
  input  [`BIST_OP_WIDTH-1:0] rtap_srams_bist_command;
  input  [`SRAM_WRAPPER_BUS_WIDTH-1:0] rtap_srams_bist_data;
  input  [`BIST_ID_WIDTH-1:0] sramid;

  output  [`IC_TLB_TAG_MASK_ALL] rdtag_y;
  output      so;

  wire      clk;
  wire  [`IC_SET_IDX_HI:0]   index_x;
  reg   [`IC_SET_IDX_HI:0]   index_y;
  wire  [`IC_WAY_ARRAY_MASK]   we;
  reg           wrreq_y;
  reg           rdreq_y;

  reg [`IC_TLB_TAG_MASK_ALL]  rdtag_sa_y; //for error_inject XMR

  assign clk = rclk;
  assign index_x = (index_sel_x ? index1_x : index0_x);
  assign we = ({`IC_NUM_WAY {((wrreq_x & reset_l) & (~rst_tri_en))}} & dec_wrway_x);

  // assign write_bus_x[`IC_PHYS_TAG_WAY0_MASK] = wrtag_x;
  // assign write_bus_x[`IC_PHYS_TAG_WAY1_MASK] = wrtag_x;
  // assign write_bus_x[`IC_PHYS_TAG_WAY2_MASK] = wrtag_x;
  // assign write_bus_x[`IC_PHYS_TAG_WAY3_MASK] = wrtag_x;

  always @ (posedge rclk)
  begin
    index_y <= index_x;
    wrreq_y <= wrreq_x;
    rdreq_y <= rdreq_x;
  end

// real SRAM instance
wire [`IC_PHYS_TAG_MASK_ALL] write_bus_mask_x = {
{`IC_PHYS_TAG_SZ{we[3]}},
{`IC_PHYS_TAG_SZ{we[2]}},
{`IC_PHYS_TAG_SZ{we[1]}},
{`IC_PHYS_TAG_SZ{we[0]}}

};

  wire [`IC_PHYS_TAG_HI:0] wrtag_x_phys = wrtag_x;
  wire [`IC_PHYS_TAG_MASK_ALL] write_bus_x_phys = {`IC_NUM_WAY{wrtag_x_phys}};
  // wire [`IC_PHYS_TAG_MASK_ALL] write_bus_x_phys = {wrtag_x_phys, wrtag_x_phys, wrtag_x_phys, wrtag_x_phys};
  wire [`IC_PHYS_TAG_MASK_ALL] rdtag_y_phys;

  // assign rdtag_y[`IC_TLB_TAG_WAY0_MASK] = rdtag_y_phys[`IC_PHYS_TAG_WAY0_MASK];
  // assign rdtag_y[`IC_TLB_TAG_WAY1_MASK] = rdtag_y_phys[`IC_PHYS_TAG_WAY1_MASK];
  // assign rdtag_y[`IC_TLB_TAG_WAY2_MASK] = rdtag_y_phys[`IC_PHYS_TAG_WAY2_MASK];
  // assign rdtag_y[`IC_TLB_TAG_WAY3_MASK] = rdtag_y_phys[`IC_PHYS_TAG_WAY3_MASK];

  // truncate tags from 33 bits to appropriate size
  
  wire [`IC_PHYS_TAG_HI:0] rdtag_y_phys_WAY0 = rdtag_y_phys[`IC_PHYS_TAG_WAY0_MASK];
  assign rdtag_y[`IC_TLB_TAG_WAY0_MASK] = rdtag_y_phys_WAY0[`IC_TLB_TAG_HI:0];
  

  wire [`IC_PHYS_TAG_HI:0] rdtag_y_phys_WAY1 = rdtag_y_phys[`IC_PHYS_TAG_WAY1_MASK];
  assign rdtag_y[`IC_TLB_TAG_WAY1_MASK] = rdtag_y_phys_WAY1[`IC_TLB_TAG_HI:0];
  

  wire [`IC_PHYS_TAG_HI:0] rdtag_y_phys_WAY2 = rdtag_y_phys[`IC_PHYS_TAG_WAY2_MASK];
  assign rdtag_y[`IC_TLB_TAG_WAY2_MASK] = rdtag_y_phys_WAY2[`IC_TLB_TAG_HI:0];
  

  wire [`IC_PHYS_TAG_HI:0] rdtag_y_phys_WAY3 = rdtag_y_phys[`IC_PHYS_TAG_WAY3_MASK];
  assign rdtag_y[`IC_TLB_TAG_WAY3_MASK] = rdtag_y_phys_WAY3[`IC_TLB_TAG_HI:0];
  


  sram_l1i_tag cache
  (
    .MEMCLK(rclk),
      .RESET_N(reset_l),
    .CE(wrreq_x | rdreq_x),
    .A(index_x),
    .DIN(write_bus_x_phys),
    .BW(write_bus_mask_x),
    .RDWEN(~wrreq_x),
    .DOUT(rdtag_y_phys),

    .BIST_COMMAND(rtap_srams_bist_command),
    .BIST_DIN(rtap_srams_bist_data),
    .BIST_DOUT(srams_rtap_data),
    .SRAMID(sramid)
  );

endmodule

`endif // IBM TAG


`ifdef SIM_FPGA_SYN_SRAM_ICACHE_TAG // simulation flag
`undef PITON_PROTO
`endif

`ifdef FPGA_FORCE_SRAM_ICACHE_TAG
`define PITON_PROTO
`endif

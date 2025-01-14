/*
Copyright (c) 2015 Princeton University
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Princeton University nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY PRINCETON UNIVERSITY "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL PRINCETON UNIVERSITY BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

//==================================================================================================
//  Filename      : l2_pipe2_buf_in.v
//  Created On    : 2014-04-06
//  Revision      :
//  Author        : Yaosheng Fu
//  Company       : Princeton University
//  Email         : yfu@princeton.edu
//
//  Description   : Input buffer for pipeline2
//
//
//==================================================================================================

`include "l2.tmp.h"
`include "define.vh"

module l2_pipe2_buf_in(

    input wire clk,
    input wire rst_n,

    input wire valid_in,
    input wire [`NOC_DATA_WIDTH-1:0] data_in,
    output reg ready_in,

    output reg msg_header_valid_out,
    output reg [`L2_P2_HEADER_BUF_IN_WIDTH-1:0] msg_header_out,
    input wire msg_header_ready_out,

    output reg msg_data_valid_out,
    output reg [`L2_P2_DATA_BUF_IN_WIDTH-1:0] msg_data_out,
    input wire msg_data_ready_out
);




localparam msg_data_state_0F = 2'd0;
localparam msg_data_state_2F = 2'd1;
localparam msg_data_state_8F = 2'd2;

localparam msg_state_header0 = 4'd0;
localparam msg_state_header1 = 4'd1;
localparam msg_state_header2 = 4'd2;
localparam msg_state_data0 = 4'd3;
localparam msg_state_data1 = 4'd4;
localparam msg_state_data2 = 4'd5;
localparam msg_state_data3 = 4'd6;
localparam msg_state_data4 = 4'd7;
localparam msg_state_data5 = 4'd8;
localparam msg_state_data6 = 4'd9;
localparam msg_state_data7 = 4'd10;

reg [3:0] msg_state_f;
reg [3:0] msg_state_next;

reg [1:0] msg_data_state_f;
reg [1:0] msg_data_state_next;

always @ *
begin
    if (!rst_n)
    begin
        msg_data_state_next = msg_data_state_0F;
    end
    else if((msg_state_f == msg_state_header0) && valid_in)
    begin
        if (data_in[`MSG_LENGTH] == 8)
        begin
            msg_data_state_next = msg_data_state_8F;
        end
        else if (data_in[`MSG_LENGTH] == 0)
        begin
            msg_data_state_next = msg_data_state_0F;
        end
        else    
        begin
            msg_data_state_next = msg_data_state_2F;
        end
    end
    else
    begin
        msg_data_state_next = msg_data_state_f;
    end
end

always @ (posedge clk)
begin
    msg_data_state_f <= msg_data_state_next;
end

always @ *
begin
    if (!rst_n)
    begin
        msg_state_next = msg_state_header0;
    end
    else if (valid_in && ready_in)
    begin
        if ((msg_state_f == msg_state_header0) && (data_in[`MSG_TYPE] != `MSG_TYPE_WB_REQ))
        begin
            if (data_in[`MSG_LENGTH] == 0)
            begin
                msg_state_next = msg_state_header0;
            end
            else
            begin
                msg_state_next = msg_state_data0;
            end
        end
        else if ((msg_state_f == msg_state_data1) && (msg_data_state_f == msg_data_state_2F))
        begin
            msg_state_next = msg_state_header0;
        end
        else
        begin
            if (msg_state_f == msg_state_data7)
            begin
                msg_state_next = msg_state_header0;
            end
            else
            begin
                msg_state_next = msg_state_f + 3'd1;
            end
        end
    end
    else
    begin
        msg_state_next = msg_state_f;
    end 
end


always @ (posedge clk)
begin
    msg_state_f <= msg_state_next;
end

localparam msg_mux_header = 1'b0;
localparam msg_mux_data = 1'b1;

reg msg_mux_sel;

always @ *
begin
    if ((msg_state_f == msg_state_header0)
    ||  (msg_state_f == msg_state_header1)
    ||  (msg_state_f == msg_state_header2))
    begin
        msg_mux_sel = msg_mux_header;
    end
    else
        msg_mux_sel = msg_mux_data;
end


reg msg_header_valid_in;
reg [`NOC_DATA_WIDTH-1:0] msg_header_in;
reg msg_header_ready_in;


reg msg_data_valid_in;
reg [`NOC_DATA_WIDTH-1:0] msg_data_in;
reg msg_data_ready_in;


always @ *
begin
    if (msg_mux_sel == msg_mux_header)
    begin
        msg_header_valid_in = valid_in;
        msg_header_in = data_in;
    end
    else
    begin
        msg_header_valid_in = 0;
        msg_header_in = 0;
    end
end

always @ *
begin
    if (msg_mux_sel == msg_mux_data)
    begin
        msg_data_valid_in = valid_in;
        msg_data_in = data_in;
    end
    else
    begin
        msg_data_valid_in = 0;
        msg_data_in = 0;
    end
end

always @ *
begin
    if (msg_mux_sel == msg_mux_data)
    begin
        ready_in = msg_data_ready_in; 
    end
    else
    begin
        ready_in = msg_header_ready_in;
    end
end



reg [`NOC_DATA_WIDTH-1:0] header_buf_mem_f [`L2_P2_HEADER_BUF_IN_SIZE-1:0];
reg header_buf_empty;
reg header_buf_full;
reg [`L2_P2_HEADER_BUF_IN_LOG_SIZE:0] header_buf_counter_f;
reg [`L2_P2_HEADER_BUF_IN_LOG_SIZE:0] header_buf_counter_next;
reg [`L2_P2_HEADER_BUF_IN_LOG_SIZE-1:0] header_rd_ptr_f;
reg [`L2_P2_HEADER_BUF_IN_LOG_SIZE-1:0] header_rd_ptr_next;
reg [`L2_P2_HEADER_BUF_IN_LOG_SIZE-1:0] header_rd_ptr_plus1;
reg [`L2_P2_HEADER_BUF_IN_LOG_SIZE-1:0] header_rd_ptr_plus2;
reg [`L2_P2_HEADER_BUF_IN_LOG_SIZE-1:0] header_wr_ptr_f;
reg [`L2_P2_HEADER_BUF_IN_LOG_SIZE-1:0] header_wr_ptr_next;


always @ *
begin
    header_buf_empty = (header_buf_counter_f == 0);
    header_buf_full = (header_buf_counter_f ==  `L2_P2_HEADER_BUF_IN_SIZE);
end

reg [1:0] msg_header_flits;

always @ *
begin
    msg_header_flits = 1;
    if (header_buf_mem_f[header_rd_ptr_f][`MSG_TYPE] == `MSG_TYPE_WB_REQ)
    begin
        msg_header_flits = 3;
    end
    else
    begin
        msg_header_flits = 1;
    end
end

always @ *
begin
   if (!rst_n)
    begin
        header_buf_counter_next = 0;
    end
    else if ((msg_header_valid_in && msg_header_ready_in) && (msg_header_valid_out && msg_header_ready_out))
    begin
        header_buf_counter_next = header_buf_counter_f + 1 - msg_header_flits;
    end
    else if (msg_header_valid_in && msg_header_ready_in)
    begin 
        header_buf_counter_next = header_buf_counter_f + 1;
    end
    else if (msg_header_valid_out && msg_header_ready_out)
    begin 
        header_buf_counter_next = header_buf_counter_f - msg_header_flits;
    end
    else
    begin
        header_buf_counter_next = header_buf_counter_f;
    end
end



always @ (posedge clk)
begin
    header_buf_counter_f <= header_buf_counter_next;
end

always @ *
begin
    if (!rst_n)
    begin   
        header_rd_ptr_next = 0;
    end
    else if (msg_header_valid_out && msg_header_ready_out)
    begin
        header_rd_ptr_next = header_rd_ptr_f + msg_header_flits;
    end
    else
    begin
        header_rd_ptr_next = header_rd_ptr_f;
    end
end


always @ (posedge clk)
begin
    header_rd_ptr_f <= header_rd_ptr_next;
end

always @ *
begin
    if (!rst_n)
    begin   
        header_wr_ptr_next = 0;
    end
    else if (msg_header_valid_in && msg_header_ready_in)
    begin
        header_wr_ptr_next = header_wr_ptr_f + 1;
    end
    else
    begin
        header_wr_ptr_next = header_wr_ptr_f;
    end
end

always @ (posedge clk)
begin
    header_wr_ptr_f <= header_wr_ptr_next;
end


always @ *
begin
    header_rd_ptr_plus1 = header_rd_ptr_f + 1;
    header_rd_ptr_plus2 = header_rd_ptr_f + 2;
end


always @ *
begin
   msg_header_ready_in = !header_buf_full;
end


always @ *
begin
    msg_header_valid_out = (!header_buf_empty) && (header_buf_counter_f >= msg_header_flits);
end

always @ *
begin
    if (msg_header_flits == 3)
    begin
        msg_header_out = {header_buf_mem_f[header_rd_ptr_plus2], 
                          header_buf_mem_f[header_rd_ptr_plus1], 
                          header_buf_mem_f[header_rd_ptr_f]};
    end
    else
    begin
        msg_header_out = {{(2*`NOC_DATA_WIDTH){1'b0}},header_buf_mem_f[header_rd_ptr_f]}; 
    end
end


always @ (posedge clk)
begin
    if (!rst_n)
    begin   
        header_buf_mem_f[0] <= 0;
        header_buf_mem_f[1] <= 0;
        header_buf_mem_f[2] <= 0;
        header_buf_mem_f[3] <= 0;

    end
    else if (msg_header_valid_in && msg_header_ready_in)
    begin
        header_buf_mem_f[header_wr_ptr_f] <= msg_header_in;
    end
    else
    begin 
        header_buf_mem_f[header_wr_ptr_f] <= header_buf_mem_f[header_wr_ptr_f];
    end
end



reg [`NOC_DATA_WIDTH-1:0] data_buf_mem_f [`L2_P2_DATA_BUF_IN_SIZE-1:0];
reg data_buf_empty;
reg data_buf_full;
reg [`L2_P2_DATA_BUF_IN_LOG_SIZE:0] data_buf_counter_f;
reg [`L2_P2_DATA_BUF_IN_LOG_SIZE:0] data_buf_counter_next;
reg [`L2_P2_DATA_BUF_IN_LOG_SIZE-1:0] data_rd_ptr_f;
reg [`L2_P2_DATA_BUF_IN_LOG_SIZE-1:0] data_rd_ptr_next;
reg [`L2_P2_DATA_BUF_IN_LOG_SIZE-1:0] data_rd_ptr_plus1;
reg [`L2_P2_DATA_BUF_IN_LOG_SIZE-1:0] data_wr_ptr_f;
reg [`L2_P2_DATA_BUF_IN_LOG_SIZE-1:0] data_wr_ptr_next;

always @ *
begin
    data_buf_empty = (data_buf_counter_f == 0);
    data_buf_full = (data_buf_counter_f ==  `L2_P2_DATA_BUF_IN_SIZE);
end

always @ *
begin
    if ((msg_data_valid_in && msg_data_ready_in) && (msg_data_valid_out && msg_data_ready_out))
    begin
        data_buf_counter_next = data_buf_counter_f + 1 - `L2_P2_DATA_BUF_IN_FLITS;
    end
    else if (msg_data_valid_in && msg_data_ready_in)
    begin 
        data_buf_counter_next = data_buf_counter_f + 1;
    end
    else if (msg_data_valid_out && msg_data_ready_out)
    begin 
        data_buf_counter_next = data_buf_counter_f - `L2_P2_DATA_BUF_IN_FLITS;
    end
    else
    begin
        data_buf_counter_next = data_buf_counter_f;
    end
end


always @ (posedge clk)
begin
    if (!rst_n)
        data_buf_counter_f <= 0;
    else
        data_buf_counter_f <= data_buf_counter_next;
end

always @ *
begin
    if (!rst_n)
    begin   
        data_rd_ptr_next = 0;
    end
    else if (msg_data_valid_out && msg_data_ready_out)
    begin
        data_rd_ptr_next = data_rd_ptr_f + `L2_P2_DATA_BUF_IN_FLITS;
    end
    else
    begin
        data_rd_ptr_next = data_rd_ptr_f;
    end
end


always @ (posedge clk)
begin
    data_rd_ptr_f <= data_rd_ptr_next;
end

always @ *
begin
    if (!rst_n)
    begin   
        data_wr_ptr_next = 0;
    end
    else if (msg_data_valid_in && msg_data_ready_in)
    begin
        data_wr_ptr_next = data_wr_ptr_f + 1;
    end
    else
    begin
        data_wr_ptr_next = data_wr_ptr_f;
    end
end

always @ (posedge clk)
begin
    data_wr_ptr_f <= data_wr_ptr_next;
end


always @ *
begin
    data_rd_ptr_plus1 = data_rd_ptr_f + 1;
end

always @ *
begin
   msg_data_ready_in = !data_buf_full;
end


always @ *
begin
    msg_data_valid_out = (data_buf_counter_f >= `L2_P2_DATA_BUF_IN_FLITS);
    msg_data_out = {data_buf_mem_f[data_rd_ptr_plus1], data_buf_mem_f[data_rd_ptr_f]}; 
end


always @ (posedge clk)
begin
    if (!rst_n)
    begin   
        data_buf_mem_f[0] <= 0;
        data_buf_mem_f[1] <= 0;
        data_buf_mem_f[2] <= 0;
        data_buf_mem_f[3] <= 0;
        data_buf_mem_f[4] <= 0;
        data_buf_mem_f[5] <= 0;
        data_buf_mem_f[6] <= 0;
        data_buf_mem_f[7] <= 0;
        data_buf_mem_f[8] <= 0;
        data_buf_mem_f[9] <= 0;
        data_buf_mem_f[10] <= 0;
        data_buf_mem_f[11] <= 0;
        data_buf_mem_f[12] <= 0;
        data_buf_mem_f[13] <= 0;
        data_buf_mem_f[14] <= 0;
        data_buf_mem_f[15] <= 0;

    end
    else if (msg_data_valid_in && msg_data_ready_in)
    begin
        data_buf_mem_f[data_wr_ptr_f] <= msg_data_in;
    end
    else
    begin 
        data_buf_mem_f[data_wr_ptr_f] <=  data_buf_mem_f[data_wr_ptr_f];
    end
end



endmodule


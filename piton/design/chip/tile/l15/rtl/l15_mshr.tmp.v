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
//  Filename      : l15_mshr.v
//  Created On    : 2014-02-06 02:44:17
//  Last Modified : 2015-01-22 17:33:10
//  Revision      :
//  Author        : Tri Nguyen
//  Company       : Princeton University
//  Email         : trin@princeton.edu
//
//  Description   : asynchronous read, synchronous write on posedge
//
//
//==================================================================================================

//`timescale 1 ns / 10 ps
`include "l15.tmp.h"

`ifdef DEFAULT_NETTYPE_NONE
`default_nettype none
`endif
module l15_mshr(
    input wire clk,
    input wire rst_n,

    //s1
    input wire pipe_mshr_writereq_val_s1,
    input wire [`L15_MSHR_WRITE_TYPE_WIDTH-1:0] pipe_mshr_writereq_op_s1,
    input wire [`L15_PADDR_HI:0] pipe_mshr_writereq_address_s1,
    input wire [127:0] pipe_mshr_writereq_write_buffer_data_s1,
    input wire [15:0] pipe_mshr_writereq_write_buffer_byte_mask_s1,
    input wire [`L15_CONTROL_WIDTH-1:0] pipe_mshr_writereq_control_s1,
    input wire [`L15_MSHR_ID_WIDTH-1:0] pipe_mshr_writereq_mshrid_s1,
    input wire [`L15_THREADID_MASK] pipe_mshr_writereq_threadid_s1,

    input wire [`L15_THREADID_MASK] pipe_mshr_readreq_threadid_s1,
    input wire [`L15_MSHR_ID_WIDTH-1:0] pipe_mshr_readreq_mshrid_s1,
    output reg [`L15_CONTROL_WIDTH-1:0]mshr_pipe_readres_control_s1,
    output reg [`PACKET_HOME_ID_WIDTH-1:0] mshr_pipe_readres_homeid_s1,

    // s1/2/3 (address conflict checking)
    output reg [(`L15_NUM_MSHRID_PER_THREAD*`L15_NUM_THREADS)-1:0] mshr_pipe_vals_s1,
    output reg [(40*`L15_NUM_THREADS)-1:0] mshr_pipe_ld_address,
    output reg [(40*`L15_NUM_THREADS)-1:0] mshr_pipe_st_address,
    output reg [(2*`L15_NUM_THREADS)-1:0] mshr_pipe_st_way_s1,
    output reg [(`L15_MESI_TRANS_STATE_WIDTH*`L15_NUM_THREADS)-1:0] mshr_pipe_st_state_s1,

    //s2
    input wire pipe_mshr_write_buffer_rd_en_s2,
    input wire [`L15_THREADID_MASK] pipe_mshr_threadid_s2,
    output reg [127:0]mshr_pipe_write_buffer_s2,
    output reg [15:0] mshr_pipe_write_buffer_byte_mask_s2,

    //s3
    input wire pipe_mshr_val_s3,
    input wire [`L15_MSHR_WRITE_TYPE_WIDTH-1:0] pipe_mshr_op_s3,
    input wire [`L15_MSHR_ID_WIDTH-1:0] pipe_mshr_mshrid_s3,
    input wire [`L15_THREADID_MASK] pipe_mshr_threadid_s3,
    input wire [`L15_MESI_TRANS_STATE_WIDTH-1:0] pipe_mshr_write_update_state_s3,
    input wire [1:0] pipe_mshr_write_update_way_s3,

    // output reg mshr_pipe_t0_ld_address_val,
    // output reg mshr_pipe_t0_st_address_val,
    // output reg mshr_pipe_t1_ld_address_val,
    // output reg mshr_pipe_t1_st_address_val,



    // homeid related signals
    input wire noc1buffer_mshr_homeid_write_val_s4,
    input wire [`L15_MSHR_ID_WIDTH-1:0] noc1buffer_mshr_homeid_write_mshrid_s4,
    input wire [`L15_THREADID_MASK] noc1buffer_mshr_homeid_write_threadid_s4,
    input wire [`PACKET_HOME_ID_WIDTH-1:0] noc1buffer_mshr_homeid_write_data_s4
    );

// reg [`L15_PADDR_HI:0]                    address_array [0:9];
// reg [`L15_CONTROL_WIDTH-1:0]   control_array [0:9];
// reg [9:0] val_array;

// reg [127:0] st8_data;
// reg [127:0] st9_data;
// reg [15:0] st8_data_byte_mask;
// reg [15:0] st9_data_byte_mask;
// reg [1:0] st8_way;
// reg [1:0] st9_way;
// reg [`L15_MESI_TRANS_STATE_WIDTH-1:0] st8_state;
// reg [`L15_MESI_TRANS_STATE_WIDTH-1:0] st9_state;
// reg [`PACKET_HOME_ID_WIDTH-1:0] st_fill_homeid[0:1];

reg [`L15_PADDR_HI:0] ld_address [0:`L15_NUM_THREADS-1];
reg [`L15_CONTROL_WIDTH-1:0] ld_control [0:`L15_NUM_THREADS-1];
reg [`L15_NUM_THREADS-1:0] ld_val;
reg [`PACKET_HOME_ID_WIDTH-1:0] ld_homeid [0:`L15_NUM_THREADS-1];

// reg [`L15_PADDR_HI:0] ifill_address [0:`L15_NUM_THREADS-1];
reg [`L15_CONTROL_WIDTH-1:0] ifill_control [0:`L15_NUM_THREADS-1];
reg [`L15_NUM_THREADS-1:0] ifill_val;
// reg [`PACKET_HOME_ID_WIDTH-1:0] ifill_homeid [0:`L15_NUM_THREADS-1];

reg [`L15_PADDR_HI:0] st_address [0:`L15_NUM_THREADS-1];
reg [`L15_CONTROL_WIDTH-1:0] st_control [0:`L15_NUM_THREADS-1];
reg [`L15_NUM_THREADS-1:0] st_val;
reg [`PACKET_HOME_ID_WIDTH-1:0] st_homeid [0:`L15_NUM_THREADS-1];
reg [`L15_MESI_TRANS_STATE_WIDTH-1:0] st_state [0:`L15_NUM_THREADS-1];
reg [1:0] st_way [0:`L15_NUM_THREADS-1];
reg [127:0] st_write_buffer [0:`L15_NUM_THREADS-1];
reg [15:0] st_write_buffer_byte_mask [0:`L15_NUM_THREADS-1];

/////////////////
// renaming
/////////////////
reg [`L15_MSHR_WRITE_TYPE_WIDTH-1:0] op_s1;
reg [`L15_MSHR_WRITE_TYPE_WIDTH-1:0] op_s3;
reg [`L15_THREADID_MASK] threadid_s1;
reg [`L15_THREADID_MASK] threadid_s3;
reg [`L15_MSHR_ID_WIDTH-1:0] mshrid_s1;
reg [`L15_MSHR_ID_WIDTH-1:0] mshrid_s3;
always @ *
begin
    op_s1 = pipe_mshr_writereq_op_s1;
    threadid_s1 = pipe_mshr_writereq_threadid_s1;
    mshrid_s1 = pipe_mshr_writereq_mshrid_s1;

    threadid_s3 = pipe_mshr_threadid_s3;
    op_s3 = pipe_mshr_op_s3;
    mshrid_s3 = pipe_mshr_mshrid_s3;
end

// Read operation/outputs
reg [`L15_NUM_MSHRID_PER_THREAD-1:0] tmp_vals [`L15_NUM_THREADS-1:0];
reg [`L15_PADDR_HI:0] tmp_st_address [`L15_NUM_THREADS-1:0];
reg [`L15_PADDR_HI:0] tmp_ld_address [`L15_NUM_THREADS-1:0];
reg [2-1:0] tmp_st_way [`L15_NUM_THREADS-1:0];
reg [`L15_MESI_TRANS_STATE_WIDTH-1:0] tmp_st_state [`L15_NUM_THREADS-1:0];
always @ *
begin

tmp_vals[0] = 0;
tmp_vals[0][`L15_MSHR_ID_IFILL] = ifill_val[0];
tmp_vals[0][`L15_MSHR_ID_LD] = ld_val[0];
tmp_vals[0][`L15_MSHR_ID_ST] = st_val[0];

tmp_st_address[0] = st_address[0];
tmp_ld_address[0] = ld_address[0];
tmp_st_way[0] = st_way[0];
tmp_st_state[0] =st_state[0];


tmp_vals[1] = 0;
tmp_vals[1][`L15_MSHR_ID_IFILL] = ifill_val[1];
tmp_vals[1][`L15_MSHR_ID_LD] = ld_val[1];
tmp_vals[1][`L15_MSHR_ID_ST] = st_val[1];

tmp_st_address[1] = st_address[1];
tmp_ld_address[1] = ld_address[1];
tmp_st_way[1] = st_way[1];
tmp_st_state[1] =st_state[1];


    mshr_pipe_vals_s1 = {tmp_vals[1], tmp_vals[0]};
    mshr_pipe_ld_address = {tmp_ld_address[1], tmp_ld_address[0]};
    mshr_pipe_st_address = {tmp_st_address[1], tmp_st_address[0]};
    mshr_pipe_st_way_s1 = {tmp_st_way[1], tmp_st_way[0]};
    mshr_pipe_st_state_s1 = {tmp_st_state[1], tmp_st_state[0]};

    // S1 read
    mshr_pipe_readres_homeid_s1[`PACKET_HOME_ID_WIDTH-1:0] = 0;
    mshr_pipe_readres_control_s1[`L15_CONTROL_WIDTH-1:0] = 0;

    case (pipe_mshr_readreq_mshrid_s1)
        `L15_MSHR_ID_IFILL:
        begin
            mshr_pipe_readres_control_s1 = ifill_control[pipe_mshr_readreq_threadid_s1];
        end
        `L15_MSHR_ID_LD:
        begin
            mshr_pipe_readres_control_s1 = ld_control[pipe_mshr_readreq_threadid_s1];
            mshr_pipe_readres_homeid_s1 = ld_homeid[pipe_mshr_readreq_threadid_s1];
        end
        `L15_MSHR_ID_ST:
        begin
            mshr_pipe_readres_control_s1 = st_control[pipe_mshr_readreq_threadid_s1];
            mshr_pipe_readres_homeid_s1 = st_homeid[pipe_mshr_readreq_threadid_s1];
        end
    endcase

    // write-buffer reading in S2
    mshr_pipe_write_buffer_s2[127:0] = 128'b0;
    mshr_pipe_write_buffer_byte_mask_s2 = 16'b0;
    if (pipe_mshr_write_buffer_rd_en_s2)
    begin
        mshr_pipe_write_buffer_s2 = st_write_buffer[pipe_mshr_threadid_s2];
        mshr_pipe_write_buffer_byte_mask_s2 = st_write_buffer_byte_mask[pipe_mshr_threadid_s2];
    end
end

// Write operation
// generating mask for write
reg [127:0] bit_write_mask_s1;
always @ *
begin
    bit_write_mask_s1[0] = pipe_mshr_writereq_write_buffer_byte_mask_s1[0];
bit_write_mask_s1[1] = pipe_mshr_writereq_write_buffer_byte_mask_s1[0];
bit_write_mask_s1[2] = pipe_mshr_writereq_write_buffer_byte_mask_s1[0];
bit_write_mask_s1[3] = pipe_mshr_writereq_write_buffer_byte_mask_s1[0];
bit_write_mask_s1[4] = pipe_mshr_writereq_write_buffer_byte_mask_s1[0];
bit_write_mask_s1[5] = pipe_mshr_writereq_write_buffer_byte_mask_s1[0];
bit_write_mask_s1[6] = pipe_mshr_writereq_write_buffer_byte_mask_s1[0];
bit_write_mask_s1[7] = pipe_mshr_writereq_write_buffer_byte_mask_s1[0];
bit_write_mask_s1[8] = pipe_mshr_writereq_write_buffer_byte_mask_s1[1];
bit_write_mask_s1[9] = pipe_mshr_writereq_write_buffer_byte_mask_s1[1];
bit_write_mask_s1[10] = pipe_mshr_writereq_write_buffer_byte_mask_s1[1];
bit_write_mask_s1[11] = pipe_mshr_writereq_write_buffer_byte_mask_s1[1];
bit_write_mask_s1[12] = pipe_mshr_writereq_write_buffer_byte_mask_s1[1];
bit_write_mask_s1[13] = pipe_mshr_writereq_write_buffer_byte_mask_s1[1];
bit_write_mask_s1[14] = pipe_mshr_writereq_write_buffer_byte_mask_s1[1];
bit_write_mask_s1[15] = pipe_mshr_writereq_write_buffer_byte_mask_s1[1];
bit_write_mask_s1[16] = pipe_mshr_writereq_write_buffer_byte_mask_s1[2];
bit_write_mask_s1[17] = pipe_mshr_writereq_write_buffer_byte_mask_s1[2];
bit_write_mask_s1[18] = pipe_mshr_writereq_write_buffer_byte_mask_s1[2];
bit_write_mask_s1[19] = pipe_mshr_writereq_write_buffer_byte_mask_s1[2];
bit_write_mask_s1[20] = pipe_mshr_writereq_write_buffer_byte_mask_s1[2];
bit_write_mask_s1[21] = pipe_mshr_writereq_write_buffer_byte_mask_s1[2];
bit_write_mask_s1[22] = pipe_mshr_writereq_write_buffer_byte_mask_s1[2];
bit_write_mask_s1[23] = pipe_mshr_writereq_write_buffer_byte_mask_s1[2];
bit_write_mask_s1[24] = pipe_mshr_writereq_write_buffer_byte_mask_s1[3];
bit_write_mask_s1[25] = pipe_mshr_writereq_write_buffer_byte_mask_s1[3];
bit_write_mask_s1[26] = pipe_mshr_writereq_write_buffer_byte_mask_s1[3];
bit_write_mask_s1[27] = pipe_mshr_writereq_write_buffer_byte_mask_s1[3];
bit_write_mask_s1[28] = pipe_mshr_writereq_write_buffer_byte_mask_s1[3];
bit_write_mask_s1[29] = pipe_mshr_writereq_write_buffer_byte_mask_s1[3];
bit_write_mask_s1[30] = pipe_mshr_writereq_write_buffer_byte_mask_s1[3];
bit_write_mask_s1[31] = pipe_mshr_writereq_write_buffer_byte_mask_s1[3];
bit_write_mask_s1[32] = pipe_mshr_writereq_write_buffer_byte_mask_s1[4];
bit_write_mask_s1[33] = pipe_mshr_writereq_write_buffer_byte_mask_s1[4];
bit_write_mask_s1[34] = pipe_mshr_writereq_write_buffer_byte_mask_s1[4];
bit_write_mask_s1[35] = pipe_mshr_writereq_write_buffer_byte_mask_s1[4];
bit_write_mask_s1[36] = pipe_mshr_writereq_write_buffer_byte_mask_s1[4];
bit_write_mask_s1[37] = pipe_mshr_writereq_write_buffer_byte_mask_s1[4];
bit_write_mask_s1[38] = pipe_mshr_writereq_write_buffer_byte_mask_s1[4];
bit_write_mask_s1[39] = pipe_mshr_writereq_write_buffer_byte_mask_s1[4];
bit_write_mask_s1[40] = pipe_mshr_writereq_write_buffer_byte_mask_s1[5];
bit_write_mask_s1[41] = pipe_mshr_writereq_write_buffer_byte_mask_s1[5];
bit_write_mask_s1[42] = pipe_mshr_writereq_write_buffer_byte_mask_s1[5];
bit_write_mask_s1[43] = pipe_mshr_writereq_write_buffer_byte_mask_s1[5];
bit_write_mask_s1[44] = pipe_mshr_writereq_write_buffer_byte_mask_s1[5];
bit_write_mask_s1[45] = pipe_mshr_writereq_write_buffer_byte_mask_s1[5];
bit_write_mask_s1[46] = pipe_mshr_writereq_write_buffer_byte_mask_s1[5];
bit_write_mask_s1[47] = pipe_mshr_writereq_write_buffer_byte_mask_s1[5];
bit_write_mask_s1[48] = pipe_mshr_writereq_write_buffer_byte_mask_s1[6];
bit_write_mask_s1[49] = pipe_mshr_writereq_write_buffer_byte_mask_s1[6];
bit_write_mask_s1[50] = pipe_mshr_writereq_write_buffer_byte_mask_s1[6];
bit_write_mask_s1[51] = pipe_mshr_writereq_write_buffer_byte_mask_s1[6];
bit_write_mask_s1[52] = pipe_mshr_writereq_write_buffer_byte_mask_s1[6];
bit_write_mask_s1[53] = pipe_mshr_writereq_write_buffer_byte_mask_s1[6];
bit_write_mask_s1[54] = pipe_mshr_writereq_write_buffer_byte_mask_s1[6];
bit_write_mask_s1[55] = pipe_mshr_writereq_write_buffer_byte_mask_s1[6];
bit_write_mask_s1[56] = pipe_mshr_writereq_write_buffer_byte_mask_s1[7];
bit_write_mask_s1[57] = pipe_mshr_writereq_write_buffer_byte_mask_s1[7];
bit_write_mask_s1[58] = pipe_mshr_writereq_write_buffer_byte_mask_s1[7];
bit_write_mask_s1[59] = pipe_mshr_writereq_write_buffer_byte_mask_s1[7];
bit_write_mask_s1[60] = pipe_mshr_writereq_write_buffer_byte_mask_s1[7];
bit_write_mask_s1[61] = pipe_mshr_writereq_write_buffer_byte_mask_s1[7];
bit_write_mask_s1[62] = pipe_mshr_writereq_write_buffer_byte_mask_s1[7];
bit_write_mask_s1[63] = pipe_mshr_writereq_write_buffer_byte_mask_s1[7];
bit_write_mask_s1[64] = pipe_mshr_writereq_write_buffer_byte_mask_s1[8];
bit_write_mask_s1[65] = pipe_mshr_writereq_write_buffer_byte_mask_s1[8];
bit_write_mask_s1[66] = pipe_mshr_writereq_write_buffer_byte_mask_s1[8];
bit_write_mask_s1[67] = pipe_mshr_writereq_write_buffer_byte_mask_s1[8];
bit_write_mask_s1[68] = pipe_mshr_writereq_write_buffer_byte_mask_s1[8];
bit_write_mask_s1[69] = pipe_mshr_writereq_write_buffer_byte_mask_s1[8];
bit_write_mask_s1[70] = pipe_mshr_writereq_write_buffer_byte_mask_s1[8];
bit_write_mask_s1[71] = pipe_mshr_writereq_write_buffer_byte_mask_s1[8];
bit_write_mask_s1[72] = pipe_mshr_writereq_write_buffer_byte_mask_s1[9];
bit_write_mask_s1[73] = pipe_mshr_writereq_write_buffer_byte_mask_s1[9];
bit_write_mask_s1[74] = pipe_mshr_writereq_write_buffer_byte_mask_s1[9];
bit_write_mask_s1[75] = pipe_mshr_writereq_write_buffer_byte_mask_s1[9];
bit_write_mask_s1[76] = pipe_mshr_writereq_write_buffer_byte_mask_s1[9];
bit_write_mask_s1[77] = pipe_mshr_writereq_write_buffer_byte_mask_s1[9];
bit_write_mask_s1[78] = pipe_mshr_writereq_write_buffer_byte_mask_s1[9];
bit_write_mask_s1[79] = pipe_mshr_writereq_write_buffer_byte_mask_s1[9];
bit_write_mask_s1[80] = pipe_mshr_writereq_write_buffer_byte_mask_s1[10];
bit_write_mask_s1[81] = pipe_mshr_writereq_write_buffer_byte_mask_s1[10];
bit_write_mask_s1[82] = pipe_mshr_writereq_write_buffer_byte_mask_s1[10];
bit_write_mask_s1[83] = pipe_mshr_writereq_write_buffer_byte_mask_s1[10];
bit_write_mask_s1[84] = pipe_mshr_writereq_write_buffer_byte_mask_s1[10];
bit_write_mask_s1[85] = pipe_mshr_writereq_write_buffer_byte_mask_s1[10];
bit_write_mask_s1[86] = pipe_mshr_writereq_write_buffer_byte_mask_s1[10];
bit_write_mask_s1[87] = pipe_mshr_writereq_write_buffer_byte_mask_s1[10];
bit_write_mask_s1[88] = pipe_mshr_writereq_write_buffer_byte_mask_s1[11];
bit_write_mask_s1[89] = pipe_mshr_writereq_write_buffer_byte_mask_s1[11];
bit_write_mask_s1[90] = pipe_mshr_writereq_write_buffer_byte_mask_s1[11];
bit_write_mask_s1[91] = pipe_mshr_writereq_write_buffer_byte_mask_s1[11];
bit_write_mask_s1[92] = pipe_mshr_writereq_write_buffer_byte_mask_s1[11];
bit_write_mask_s1[93] = pipe_mshr_writereq_write_buffer_byte_mask_s1[11];
bit_write_mask_s1[94] = pipe_mshr_writereq_write_buffer_byte_mask_s1[11];
bit_write_mask_s1[95] = pipe_mshr_writereq_write_buffer_byte_mask_s1[11];
bit_write_mask_s1[96] = pipe_mshr_writereq_write_buffer_byte_mask_s1[12];
bit_write_mask_s1[97] = pipe_mshr_writereq_write_buffer_byte_mask_s1[12];
bit_write_mask_s1[98] = pipe_mshr_writereq_write_buffer_byte_mask_s1[12];
bit_write_mask_s1[99] = pipe_mshr_writereq_write_buffer_byte_mask_s1[12];
bit_write_mask_s1[100] = pipe_mshr_writereq_write_buffer_byte_mask_s1[12];
bit_write_mask_s1[101] = pipe_mshr_writereq_write_buffer_byte_mask_s1[12];
bit_write_mask_s1[102] = pipe_mshr_writereq_write_buffer_byte_mask_s1[12];
bit_write_mask_s1[103] = pipe_mshr_writereq_write_buffer_byte_mask_s1[12];
bit_write_mask_s1[104] = pipe_mshr_writereq_write_buffer_byte_mask_s1[13];
bit_write_mask_s1[105] = pipe_mshr_writereq_write_buffer_byte_mask_s1[13];
bit_write_mask_s1[106] = pipe_mshr_writereq_write_buffer_byte_mask_s1[13];
bit_write_mask_s1[107] = pipe_mshr_writereq_write_buffer_byte_mask_s1[13];
bit_write_mask_s1[108] = pipe_mshr_writereq_write_buffer_byte_mask_s1[13];
bit_write_mask_s1[109] = pipe_mshr_writereq_write_buffer_byte_mask_s1[13];
bit_write_mask_s1[110] = pipe_mshr_writereq_write_buffer_byte_mask_s1[13];
bit_write_mask_s1[111] = pipe_mshr_writereq_write_buffer_byte_mask_s1[13];
bit_write_mask_s1[112] = pipe_mshr_writereq_write_buffer_byte_mask_s1[14];
bit_write_mask_s1[113] = pipe_mshr_writereq_write_buffer_byte_mask_s1[14];
bit_write_mask_s1[114] = pipe_mshr_writereq_write_buffer_byte_mask_s1[14];
bit_write_mask_s1[115] = pipe_mshr_writereq_write_buffer_byte_mask_s1[14];
bit_write_mask_s1[116] = pipe_mshr_writereq_write_buffer_byte_mask_s1[14];
bit_write_mask_s1[117] = pipe_mshr_writereq_write_buffer_byte_mask_s1[14];
bit_write_mask_s1[118] = pipe_mshr_writereq_write_buffer_byte_mask_s1[14];
bit_write_mask_s1[119] = pipe_mshr_writereq_write_buffer_byte_mask_s1[14];
bit_write_mask_s1[120] = pipe_mshr_writereq_write_buffer_byte_mask_s1[15];
bit_write_mask_s1[121] = pipe_mshr_writereq_write_buffer_byte_mask_s1[15];
bit_write_mask_s1[122] = pipe_mshr_writereq_write_buffer_byte_mask_s1[15];
bit_write_mask_s1[123] = pipe_mshr_writereq_write_buffer_byte_mask_s1[15];
bit_write_mask_s1[124] = pipe_mshr_writereq_write_buffer_byte_mask_s1[15];
bit_write_mask_s1[125] = pipe_mshr_writereq_write_buffer_byte_mask_s1[15];
bit_write_mask_s1[126] = pipe_mshr_writereq_write_buffer_byte_mask_s1[15];
bit_write_mask_s1[127] = pipe_mshr_writereq_write_buffer_byte_mask_s1[15];

end



////////////////////////
// s1 stage writes
////////////////////////
// do write, either allocating a new mshr or updating write-buffer or deallocating an mshr
always @ (posedge clk)
begin
    if (pipe_mshr_writereq_val_s1 && (op_s1 == `L15_MSHR_WRITE_TYPE_ALLOCATION))
    begin
        case (mshrid_s1)
            `L15_MSHR_ID_IFILL:
            begin
                // ifill_address[threadid_s1] <= pipe_mshr_writereq_address_s1;
                ifill_control[threadid_s1] <= pipe_mshr_writereq_control_s1;
            end
            `L15_MSHR_ID_LD:
            begin
                ld_address[threadid_s1] <= pipe_mshr_writereq_address_s1;
                ld_control[threadid_s1] <= pipe_mshr_writereq_control_s1;
            end
            `L15_MSHR_ID_ST:
            begin
                st_address[threadid_s1] <= pipe_mshr_writereq_address_s1;
                st_control[threadid_s1] <= pipe_mshr_writereq_control_s1;
                st_write_buffer[threadid_s1] <= (pipe_mshr_writereq_write_buffer_data_s1 & bit_write_mask_s1);
                st_write_buffer_byte_mask[threadid_s1] <= pipe_mshr_writereq_write_buffer_byte_mask_s1;
            end
        endcase
    end // address and control allocation

    else if (pipe_mshr_writereq_val_s1 && op_s1 == `L15_MSHR_WRITE_TYPE_UPDATE_WRITE_CACHE)
    begin
        st_write_buffer[threadid_s1] <= ((st_write_buffer[threadid_s1] & ~bit_write_mask_s1) | (pipe_mshr_writereq_write_buffer_data_s1 & bit_write_mask_s1));
        st_write_buffer_byte_mask[threadid_s1] <= (st_write_buffer_byte_mask[threadid_s1] | pipe_mshr_writereq_write_buffer_byte_mask_s1);
    end // update write-buffer
end

////////////////////////
// s3 state writes
////////////////////////
always @ (posedge clk)
begin
    if (pipe_mshr_val_s3 && op_s3 == `L15_MSHR_WRITE_TYPE_UPDATE_ST_STATE)
    begin
        st_state[threadid_s3] <= pipe_mshr_write_update_state_s3;
        st_way[threadid_s3] <= pipe_mshr_write_update_way_s3;
    end // update store mshr state
end // mshr write

// special write logic for valid because of potential allocation/deallocation conflicts
// it's impossible because the L1.5 won't allocate until the valid bit is unset
//  but if there's a conflict, allocation wins
reg [`L15_NUM_THREADS-1:0] ld_val_next;
reg [`L15_NUM_THREADS-1:0] st_val_next;
reg [`L15_NUM_THREADS-1:0] ifill_val_next;
always @ (posedge clk)
begin
    if (!rst_n)
    begin
        ld_val <= 0;
        st_val <= 0;
        ifill_val <= 0;
    end
    else
    begin
        ld_val <= ld_val_next;
        st_val <= st_val_next;
        ifill_val <= ifill_val_next;
    end
end

reg [`L15_NUM_THREADS-1:0] ld_alloc_mask;
reg [`L15_NUM_THREADS-1:0] st_alloc_mask;
reg [`L15_NUM_THREADS-1:0] ifill_alloc_mask;
reg [`L15_NUM_THREADS-1:0] ld_dealloc_mask;
reg [`L15_NUM_THREADS-1:0] st_dealloc_mask;
reg [`L15_NUM_THREADS-1:0] ifill_dealloc_mask;
always @ *
begin
    // deallocate_mask_inv[9:0] = 0;
    // if (mshr_write_val_s3 && mshr_write_type_s3 == `L15_MSHR_WRITE_TYPE_DEALLOCATION)
    //     deallocate_mask_inv[9:0] = 10'b0000000001 << mshr_write_mshrid_s3;
    // deallocate_mask[9:0] = ~deallocate_mask_inv[9:0];

    // allocate_mask[9:0] = 0;
    // if (mshr_val_s1 && op_s1 == `L15_MSHR_WRITE_TYPE_ALLOCATION)
    //     allocate_mask[9:0] = 10'b0000000001 << mshrid_s1;

    // val_array_next[9:0] = (val_array[9:0] & deallocate_mask[9:0]) | allocate_mask[9:0];


    // if (mshr_val_s1 && (op_s1 == `L15_MSHR_WRITE_TYPE_ALLOCATION)
    //     && mshr_write_val_s3 && (mshr_write_type_s3 == `L15_MSHR_WRITE_TYPE_DEALLOCATION)
    //     && (mshrid_s1 == mshr_write_mshrid_s3)
    //     && (threadid_s1 == mshr_write_threadid_s3))
    ld_alloc_mask = 0;
    st_alloc_mask = 0;
    ifill_alloc_mask = 0;
    if (pipe_mshr_writereq_val_s1 && (op_s1 == `L15_MSHR_WRITE_TYPE_ALLOCATION))
    begin
        if (mshrid_s1 == `L15_MSHR_ID_LD)
            ld_alloc_mask[threadid_s1] = 1'b1;
        else if (mshrid_s1 == `L15_MSHR_ID_ST)
            st_alloc_mask[threadid_s1] = 1'b1;
        else if (mshrid_s1 == `L15_MSHR_ID_IFILL)
            ifill_alloc_mask[threadid_s1] = 1'b1;
    end

    ld_dealloc_mask = 0;
    st_dealloc_mask = 0;
    ifill_dealloc_mask = 0;
    if (pipe_mshr_val_s3 && (op_s3 == `L15_MSHR_WRITE_TYPE_DEALLOCATION))
    begin
        if (mshrid_s3 == `L15_MSHR_ID_LD)
            ld_dealloc_mask[threadid_s3] = 1'b1;
        else if (mshrid_s3 == `L15_MSHR_ID_ST)
            st_dealloc_mask[threadid_s3] = 1'b1;
        else if (mshrid_s3 == `L15_MSHR_ID_IFILL)
            ifill_dealloc_mask[threadid_s3] = 1'b1;
    end

    ld_val_next = ld_val;
    st_val_next = st_val;
    ifill_val_next = ifill_val;

    ld_val_next = (ld_val & ~ld_dealloc_mask) | ld_alloc_mask;
    st_val_next = (st_val & ~st_dealloc_mask) | st_alloc_mask;
    ifill_val_next = (ifill_val & ~ifill_dealloc_mask) | ifill_alloc_mask;
end

// write logic for homeid fills
always @ (posedge clk)
begin
    if (!rst_n)
    begin
        st_homeid[0] <= 0;
        st_homeid[1] <= 0;
        ld_homeid[0] <= 0;
        ld_homeid[1] <= 0;
    end
    else
    begin
        if (noc1buffer_mshr_homeid_write_val_s4)
        begin
            if (noc1buffer_mshr_homeid_write_mshrid_s4 == `L15_MSHR_ID_LD)
                ld_homeid[noc1buffer_mshr_homeid_write_threadid_s4] <= noc1buffer_mshr_homeid_write_data_s4;
            else if (noc1buffer_mshr_homeid_write_mshrid_s4 == `L15_MSHR_ID_ST)
                st_homeid[noc1buffer_mshr_homeid_write_threadid_s4] <= noc1buffer_mshr_homeid_write_data_s4;
        end
    end
end
endmodule

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
//  Filename      : l15_hmc.v
//  Created On    : 2014-06-07
//  Last Modified : 2014-06-07
//  Revision      :
//  Author        : Yaosheng Fu
//  Company       : Princeton University
//  Email         : yfu@princeton.edu
//
//  Description   : The HMC in the L15 cache
//
//
//==================================================================================================

`include "l15.tmp.h"
`include "define.vh"

module l15_hmc(

    input wire clk,
    input wire rst_n,

    //Read enable
    input wire rd_en,

    //Write enable
    input wire wr_en,

    //Diagnostic read enable
    input wire rd_diag_en,

    //Diagnostic write enable
    input wire wr_diag_en,

    //Flush enable
    input wire flush_en,

    input wire [`L15_HMC_ADDR_OP_WIDTH-1:0] addr_op,

    //address
    input wire [`L15_HMC_ADDR_WIDTH-1:0] rd_addr_in,
    input wire [`L15_HMC_ADDR_WIDTH-1:0] wr_addr_in,

    //Write data
    input wire [`L15_HMC_DATA_IN_WIDTH-1:0] data_in,

    output reg hit,

    //Read output
    output reg [`L15_HMC_DATA_OUT_WIDTH-1:0] data_out,
    output reg [`L15_HMC_VALID_WIDTH-1:0] valid_out,
    output reg [`L15_HMC_TAG_WIDTH-1:0] tag_out
);



reg [`L15_HMC_ENTRIES-1:0] entry_used_f;
reg [`L15_HMC_ENTRIES-1:0] entry_used_next;
reg [`L15_HMC_ENTRIES-1:0] entry_used_and_mask;
reg [`L15_HMC_ENTRIES-1:0] entry_used_or_mask;
reg [`L15_HMC_ENTRIES-1:0] entry_locked_f;
reg [`L15_HMC_ENTRIES-1:0] entry_locked_next;
reg [`L15_HMC_ENTRIES-1:0] entry_locked_and_mask;
reg [`L15_HMC_ENTRIES-1:0] entry_locked_or_mask;
reg [`L15_HMC_ARRAY_WIDTH-1:0] data_mem_f [`L15_HMC_ENTRIES-1:0];

reg [`L15_HMC_TAG_WIDTH-1:0] smc_tag [`L15_HMC_ENTRIES-1:0];
reg [`L15_HMC_VALID_WIDTH-1:0] smc_valid [`L15_HMC_ENTRIES-1:0];
reg [`L15_HMC_DATA_WIDTH-1:0] smc_data [`L15_HMC_ENTRIES-1:0];
reg [`MSG_SDID_WIDTH-1:0] smc_sdid [`L15_HMC_ENTRIES-1:0];
reg [`L15_HMC_TAG_WIDTH-1:0] rd_tag_in;
reg [`L15_HMC_TAG_WIDTH-1:0] wr_tag_in;
reg [`L15_HMC_INDEX_WIDTH-1:0] rd_index_in;
reg [`L15_HMC_INDEX_WIDTH-1:0] wr_index_in;
reg [`L15_HMC_OFFSET_WIDTH-1:0] rd_offset_in;
reg [`L15_HMC_OFFSET_WIDTH-1:0] wr_offset_in;
reg [`MSG_SDID_WIDTH-1:0] wr_sdid_in;
reg [`L15_HMC_VALID_WIDTH-1:0] smc_valid_in;
reg [`L15_HMC_DATA_WIDTH-1:0] smc_data_in;
reg [`L15_HMC_INDEX_WIDTH-1:0] hit_index;
reg [`L15_HMC_INDEX_WIDTH-1:0] replace_index;
reg wr_hit;
reg [`L15_HMC_INDEX_WIDTH-1:0] wr_hit_index;
reg [`L15_HMC_INDEX_WIDTH-1:0] wr_index;


always @ *
begin
    smc_tag[0] = data_mem_f[0][`L15_HMC_TAG];
    smc_tag[1] = data_mem_f[1][`L15_HMC_TAG];
    smc_tag[2] = data_mem_f[2][`L15_HMC_TAG];
    smc_tag[3] = data_mem_f[3][`L15_HMC_TAG];
    smc_tag[4] = data_mem_f[4][`L15_HMC_TAG];
    smc_tag[5] = data_mem_f[5][`L15_HMC_TAG];
    smc_tag[6] = data_mem_f[6][`L15_HMC_TAG];
    smc_tag[7] = data_mem_f[7][`L15_HMC_TAG];
    smc_tag[8] = data_mem_f[8][`L15_HMC_TAG];
    smc_tag[9] = data_mem_f[9][`L15_HMC_TAG];
    smc_tag[10] = data_mem_f[10][`L15_HMC_TAG];
    smc_tag[11] = data_mem_f[11][`L15_HMC_TAG];
    smc_tag[12] = data_mem_f[12][`L15_HMC_TAG];
    smc_tag[13] = data_mem_f[13][`L15_HMC_TAG];
    smc_tag[14] = data_mem_f[14][`L15_HMC_TAG];
    smc_tag[15] = data_mem_f[15][`L15_HMC_TAG];

end

always @ *
begin
    smc_valid[0] = data_mem_f[0][`L15_HMC_VALID];
    smc_valid[1] = data_mem_f[1][`L15_HMC_VALID];
    smc_valid[2] = data_mem_f[2][`L15_HMC_VALID];
    smc_valid[3] = data_mem_f[3][`L15_HMC_VALID];
    smc_valid[4] = data_mem_f[4][`L15_HMC_VALID];
    smc_valid[5] = data_mem_f[5][`L15_HMC_VALID];
    smc_valid[6] = data_mem_f[6][`L15_HMC_VALID];
    smc_valid[7] = data_mem_f[7][`L15_HMC_VALID];
    smc_valid[8] = data_mem_f[8][`L15_HMC_VALID];
    smc_valid[9] = data_mem_f[9][`L15_HMC_VALID];
    smc_valid[10] = data_mem_f[10][`L15_HMC_VALID];
    smc_valid[11] = data_mem_f[11][`L15_HMC_VALID];
    smc_valid[12] = data_mem_f[12][`L15_HMC_VALID];
    smc_valid[13] = data_mem_f[13][`L15_HMC_VALID];
    smc_valid[14] = data_mem_f[14][`L15_HMC_VALID];
    smc_valid[15] = data_mem_f[15][`L15_HMC_VALID];

end

always @ *
begin
    smc_data[0] = data_mem_f[0][`L15_HMC_DATA];
    smc_data[1] = data_mem_f[1][`L15_HMC_DATA];
    smc_data[2] = data_mem_f[2][`L15_HMC_DATA];
    smc_data[3] = data_mem_f[3][`L15_HMC_DATA];
    smc_data[4] = data_mem_f[4][`L15_HMC_DATA];
    smc_data[5] = data_mem_f[5][`L15_HMC_DATA];
    smc_data[6] = data_mem_f[6][`L15_HMC_DATA];
    smc_data[7] = data_mem_f[7][`L15_HMC_DATA];
    smc_data[8] = data_mem_f[8][`L15_HMC_DATA];
    smc_data[9] = data_mem_f[9][`L15_HMC_DATA];
    smc_data[10] = data_mem_f[10][`L15_HMC_DATA];
    smc_data[11] = data_mem_f[11][`L15_HMC_DATA];
    smc_data[12] = data_mem_f[12][`L15_HMC_DATA];
    smc_data[13] = data_mem_f[13][`L15_HMC_DATA];
    smc_data[14] = data_mem_f[14][`L15_HMC_DATA];
    smc_data[15] = data_mem_f[15][`L15_HMC_DATA];

end

always @ *
begin
    smc_sdid[0] = data_mem_f[0][`L15_HMC_SDID];
    smc_sdid[1] = data_mem_f[1][`L15_HMC_SDID];
    smc_sdid[2] = data_mem_f[2][`L15_HMC_SDID];
    smc_sdid[3] = data_mem_f[3][`L15_HMC_SDID];
    smc_sdid[4] = data_mem_f[4][`L15_HMC_SDID];
    smc_sdid[5] = data_mem_f[5][`L15_HMC_SDID];
    smc_sdid[6] = data_mem_f[6][`L15_HMC_SDID];
    smc_sdid[7] = data_mem_f[7][`L15_HMC_SDID];
    smc_sdid[8] = data_mem_f[8][`L15_HMC_SDID];
    smc_sdid[9] = data_mem_f[9][`L15_HMC_SDID];
    smc_sdid[10] = data_mem_f[10][`L15_HMC_SDID];
    smc_sdid[11] = data_mem_f[11][`L15_HMC_SDID];
    smc_sdid[12] = data_mem_f[12][`L15_HMC_SDID];
    smc_sdid[13] = data_mem_f[13][`L15_HMC_SDID];
    smc_sdid[14] = data_mem_f[14][`L15_HMC_SDID];
    smc_sdid[15] = data_mem_f[15][`L15_HMC_SDID];

end


always @ *
begin
    rd_tag_in = rd_addr_in[`L15_HMC_ADDR_TAG];
    rd_offset_in = rd_addr_in[`L15_HMC_ADDR_OFFSET];
    rd_index_in = rd_addr_in[`L15_HMC_ADDR_INDEX];
end

always @ *
begin
    wr_tag_in = wr_addr_in[`L15_HMC_ADDR_TAG];
    wr_offset_in = wr_addr_in[`L15_HMC_ADDR_OFFSET];
    wr_index_in = wr_addr_in[`L15_HMC_ADDR_INDEX];
    wr_sdid_in = wr_addr_in[`L15_HMC_ADDR_SDID];
end


always @ *
begin
    smc_valid_in = { data_in[127], data_in[95], data_in[63], data_in[31] };
    smc_data_in = { data_in[125:96], data_in[93:64], data_in[61:32], data_in[29:0] };

end


wire [`L15_HMC_INDEX_WIDTH-1:0] tag_hit_index;
wire tag_hit;


reg [15:0] smc_tag_cmp;

always @ *
begin

    smc_tag_cmp[0] = (smc_tag[0] == rd_tag_in) && smc_valid[0][rd_offset_in];

    smc_tag_cmp[1] = (smc_tag[1] == rd_tag_in) && smc_valid[1][rd_offset_in];

    smc_tag_cmp[2] = (smc_tag[2] == rd_tag_in) && smc_valid[2][rd_offset_in];

    smc_tag_cmp[3] = (smc_tag[3] == rd_tag_in) && smc_valid[3][rd_offset_in];

    smc_tag_cmp[4] = (smc_tag[4] == rd_tag_in) && smc_valid[4][rd_offset_in];

    smc_tag_cmp[5] = (smc_tag[5] == rd_tag_in) && smc_valid[5][rd_offset_in];

    smc_tag_cmp[6] = (smc_tag[6] == rd_tag_in) && smc_valid[6][rd_offset_in];

    smc_tag_cmp[7] = (smc_tag[7] == rd_tag_in) && smc_valid[7][rd_offset_in];

    smc_tag_cmp[8] = (smc_tag[8] == rd_tag_in) && smc_valid[8][rd_offset_in];

    smc_tag_cmp[9] = (smc_tag[9] == rd_tag_in) && smc_valid[9][rd_offset_in];

    smc_tag_cmp[10] = (smc_tag[10] == rd_tag_in) && smc_valid[10][rd_offset_in];

    smc_tag_cmp[11] = (smc_tag[11] == rd_tag_in) && smc_valid[11][rd_offset_in];

    smc_tag_cmp[12] = (smc_tag[12] == rd_tag_in) && smc_valid[12][rd_offset_in];

    smc_tag_cmp[13] = (smc_tag[13] == rd_tag_in) && smc_valid[13][rd_offset_in];

    smc_tag_cmp[14] = (smc_tag[14] == rd_tag_in) && smc_valid[14][rd_offset_in];

    smc_tag_cmp[15] = (smc_tag[15] == rd_tag_in) && smc_valid[15][rd_offset_in];

end


l15_priority_encoder_4 priority_encoder_cmp_4bits( 

    .data_in        (smc_tag_cmp),
    .data_out       (tag_hit_index),
    .data_out_mask  (),
    .nonzero_out    (tag_hit)
);



always @ *
begin
    if (rd_en && rd_diag_en)
    begin
        hit = 1'b0;
        hit_index = rd_index_in;
    end
    else
    begin
        if(rd_en)
        begin
            hit = tag_hit;
            hit_index = tag_hit_index;
        end
        else
        begin
            hit = 1'b0;
            hit_index = 0;
        end
    end
end
/*
        if(rd_en)
    begin
        if ((smc_tag[0] == rd_tag_in) && smc_valid[0][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd0;
        end
        else if ((smc_tag[1] == rd_tag_in) && smc_valid[1][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd1;
        end
        else if ((smc_tag[2] == rd_tag_in) && smc_valid[2][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd2;
        end
        else if ((smc_tag[3] == rd_tag_in) && smc_valid[3][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd3;
        end
        else if ((smc_tag[4] == rd_tag_in) && smc_valid[4][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd4;
        end
        else if ((smc_tag[5] == rd_tag_in) && smc_valid[5][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd5;
        end
        else if ((smc_tag[6] == rd_tag_in) && smc_valid[6][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd6;
        end
        else if ((smc_tag[7] == rd_tag_in) && smc_valid[7][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd7;
        end
        else if ((smc_tag[8] == rd_tag_in) && smc_valid[8][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd8;
        end
        else if ((smc_tag[9] == rd_tag_in) && smc_valid[9][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd9;
        end
        else if ((smc_tag[10] == rd_tag_in) && smc_valid[10][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd10;
        end
        else if ((smc_tag[11] == rd_tag_in) && smc_valid[11][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd11;
        end
        else if ((smc_tag[12] == rd_tag_in) && smc_valid[12][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd12;
        end
        else if ((smc_tag[13] == rd_tag_in) && smc_valid[13][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd13;
        end
        else if ((smc_tag[14] == rd_tag_in) && smc_valid[14][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd14;
        end
        else if ((smc_tag[15] == rd_tag_in) && smc_valid[15][rd_offset_in])
        begin
            hit = 1'b1;
            hit_index = 4'd15;
        end
        else
        begin
            hit = 1'b0;
            hit_index = 4'd0;
        end
    end
    else
    begin
        hit = 1'b0;
        hit_index = 4'd0;
    end

    end
end
*/


wire [`L15_HMC_INDEX_WIDTH-1:0] tag_wr_hit_index;
wire tag_wr_hit;


reg [15:0] smc_tag_wr_cmp;

always @ *
begin

    smc_tag_wr_cmp[0] = (smc_tag[0] == wr_tag_in) && (smc_valid[0] != 0);

    smc_tag_wr_cmp[1] = (smc_tag[1] == wr_tag_in) && (smc_valid[1] != 0);

    smc_tag_wr_cmp[2] = (smc_tag[2] == wr_tag_in) && (smc_valid[2] != 0);

    smc_tag_wr_cmp[3] = (smc_tag[3] == wr_tag_in) && (smc_valid[3] != 0);

    smc_tag_wr_cmp[4] = (smc_tag[4] == wr_tag_in) && (smc_valid[4] != 0);

    smc_tag_wr_cmp[5] = (smc_tag[5] == wr_tag_in) && (smc_valid[5] != 0);

    smc_tag_wr_cmp[6] = (smc_tag[6] == wr_tag_in) && (smc_valid[6] != 0);

    smc_tag_wr_cmp[7] = (smc_tag[7] == wr_tag_in) && (smc_valid[7] != 0);

    smc_tag_wr_cmp[8] = (smc_tag[8] == wr_tag_in) && (smc_valid[8] != 0);

    smc_tag_wr_cmp[9] = (smc_tag[9] == wr_tag_in) && (smc_valid[9] != 0);

    smc_tag_wr_cmp[10] = (smc_tag[10] == wr_tag_in) && (smc_valid[10] != 0);

    smc_tag_wr_cmp[11] = (smc_tag[11] == wr_tag_in) && (smc_valid[11] != 0);

    smc_tag_wr_cmp[12] = (smc_tag[12] == wr_tag_in) && (smc_valid[12] != 0);

    smc_tag_wr_cmp[13] = (smc_tag[13] == wr_tag_in) && (smc_valid[13] != 0);

    smc_tag_wr_cmp[14] = (smc_tag[14] == wr_tag_in) && (smc_valid[14] != 0);

    smc_tag_wr_cmp[15] = (smc_tag[15] == wr_tag_in) && (smc_valid[15] != 0);

end



l15_priority_encoder_4 priority_encoder_wr_cmp_4bits( 

    .data_in        (smc_tag_wr_cmp),
    .data_out       (tag_wr_hit_index),
    .data_out_mask  (),
    .nonzero_out    (tag_wr_hit)
);





//avoid redundant entries
always @ *
begin
    if(wr_en || (flush_en && (addr_op == 2'd1)))
    begin
        wr_hit = tag_wr_hit;
        wr_hit_index = tag_wr_hit_index;
    end
    else
    begin
        wr_hit = 1'b0;
        wr_hit_index = 0;
    end
end


/*
always @ *
begin
    if(wr_en || (flush_en && (addr_op == 2'd1)))
    begin
        if ((smc_tag[0] == wr_tag_in) && (smc_valid[0] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd0;
        end
        else if ((smc_tag[1] == wr_tag_in) && (smc_valid[1] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd1;
        end
        else if ((smc_tag[2] == wr_tag_in) && (smc_valid[2] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd2;
        end
        else if ((smc_tag[3] == wr_tag_in) && (smc_valid[3] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd3;
        end
        else if ((smc_tag[4] == wr_tag_in) && (smc_valid[4] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd4;
        end
        else if ((smc_tag[5] == wr_tag_in) && (smc_valid[5] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd5;
        end
        else if ((smc_tag[6] == wr_tag_in) && (smc_valid[6] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd6;
        end
        else if ((smc_tag[7] == wr_tag_in) && (smc_valid[7] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd7;
        end
        else if ((smc_tag[8] == wr_tag_in) && (smc_valid[8] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd8;
        end
        else if ((smc_tag[9] == wr_tag_in) && (smc_valid[9] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd9;
        end
        else if ((smc_tag[10] == wr_tag_in) && (smc_valid[10] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd10;
        end
        else if ((smc_tag[11] == wr_tag_in) && (smc_valid[11] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd11;
        end
        else if ((smc_tag[12] == wr_tag_in) && (smc_valid[12] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd12;
        end
        else if ((smc_tag[13] == wr_tag_in) && (smc_valid[13] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd13;
        end
        else if ((smc_tag[14] == wr_tag_in) && (smc_valid[14] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd14;
        end
        else if ((smc_tag[15] == wr_tag_in) && (smc_valid[15] != 0))
        begin
            wr_hit = 1'b1;
            wr_hit_index = 4'd15;
        end
        else
        begin
            wr_hit = 1'b0;
            wr_hit_index = 4'd0;
        end
    end
    else
    begin
        wr_hit = 1'b0;
        wr_hit_index = 4'd0;
    end

end
*/

always @ *
begin
    data_out = smc_data[hit_index]>>(rd_offset_in * `L15_HMC_DATA_OUT_WIDTH);
    valid_out = smc_valid[hit_index];
    tag_out = smc_tag[hit_index];
end


always @ *
begin
    entry_locked_and_mask = {`L15_HMC_ENTRIES{1'b1}};
    entry_locked_or_mask = {`L15_HMC_ENTRIES{1'b0}};
    if (!rst_n)
    begin
        entry_locked_and_mask = {`L15_HMC_ENTRIES{1'b0}};
    end
    else if (wr_en && ~wr_diag_en)
    begin
        if(smc_valid_in)
        begin
            entry_locked_or_mask[wr_index] = 1'b1;
        end
        else
        begin
            entry_locked_and_mask[wr_index] = 1'b0;
        end
        if (rd_en && ~rd_diag_en && hit && (wr_index != hit_index) && entry_locked_f[hit_index])
        begin
            entry_locked_and_mask[hit_index] = 1'b0;
        end
    end
    else if (rd_en && ~rd_diag_en && hit && entry_locked_f[hit_index])
    begin
        entry_locked_and_mask[hit_index] = 1'b0;
    end
end

always @ *
begin
    entry_locked_next = (entry_locked_f & entry_locked_and_mask) | entry_locked_or_mask;
end


always @ (posedge clk)
begin
    entry_locked_f <= entry_locked_next;
end


always @ *
begin
    entry_used_and_mask = {`L15_HMC_ENTRIES{1'b1}};
    entry_used_or_mask = {`L15_HMC_ENTRIES{1'b0}};
    if (!rst_n)
    begin
        entry_used_and_mask = {`L15_HMC_ENTRIES{1'b0}};
    end
    else if (wr_en && ~wr_diag_en)
    begin
        if(smc_valid_in)
        begin
            entry_used_or_mask[wr_index] = 1'b1;
        end
        else
        begin
            entry_used_and_mask[wr_index] = 1'b0;
        end
        if (rd_en && ~rd_diag_en && hit && (wr_index != hit_index))
        begin
            entry_used_or_mask[hit_index] = 1'b1;
        end
    end
    else if (rd_en && ~rd_diag_en && hit)
    begin
        entry_used_or_mask[hit_index] = 1'b1;
    end
end

always @ *
begin
    entry_used_next = (entry_used_f & entry_used_and_mask) | entry_used_or_mask;
    if (entry_used_next == {`L15_HMC_ENTRIES{1'b1}})
    begin
        entry_used_next = {`L15_HMC_ENTRIES{1'b0}};
    end
end


always @ (posedge clk)
begin
    entry_used_f <= entry_used_next;
end


wire [`L15_HMC_INDEX_WIDTH-1:0] entry_replace_index;
wire replace_hit;


reg [15:0] replace_cmp;

always @ *
begin

    replace_cmp[0] = (~entry_used_f[0] && ~entry_locked_f[0]);

    replace_cmp[1] = (~entry_used_f[1] && ~entry_locked_f[1]);

    replace_cmp[2] = (~entry_used_f[2] && ~entry_locked_f[2]);

    replace_cmp[3] = (~entry_used_f[3] && ~entry_locked_f[3]);

    replace_cmp[4] = (~entry_used_f[4] && ~entry_locked_f[4]);

    replace_cmp[5] = (~entry_used_f[5] && ~entry_locked_f[5]);

    replace_cmp[6] = (~entry_used_f[6] && ~entry_locked_f[6]);

    replace_cmp[7] = (~entry_used_f[7] && ~entry_locked_f[7]);

    replace_cmp[8] = (~entry_used_f[8] && ~entry_locked_f[8]);

    replace_cmp[9] = (~entry_used_f[9] && ~entry_locked_f[9]);

    replace_cmp[10] = (~entry_used_f[10] && ~entry_locked_f[10]);

    replace_cmp[11] = (~entry_used_f[11] && ~entry_locked_f[11]);

    replace_cmp[12] = (~entry_used_f[12] && ~entry_locked_f[12]);

    replace_cmp[13] = (~entry_used_f[13] && ~entry_locked_f[13]);

    replace_cmp[14] = (~entry_used_f[14] && ~entry_locked_f[14]);

    replace_cmp[15] = (~entry_used_f[15] && ~entry_locked_f[15]);

end


l15_priority_encoder_4 priority_encoder_replace_cmp_4bits( 

    .data_in        (replace_cmp),
    .data_out       (entry_replace_index),
    .data_out_mask  (),
    .nonzero_out    (replace_hit)
);


always @ *
begin
    if (replace_hit)
    begin
        replace_index = entry_replace_index;
    end
    else
    begin
        replace_index = {`L15_HMC_INDEX_WIDTH{1'b0}};
    end

end

/*
always @ *
begin
    if (~entry_used_f[0] && ~entry_locked_f[0])
    begin
        replace_index = 4'd0;
    end
    else if (~entry_used_f[1] && ~entry_locked_f[1])
    begin
        replace_index = 4'd1;
    end
    else if (~entry_used_f[2] && ~entry_locked_f[2])
    begin
        replace_index = 4'd2;
    end
    else if (~entry_used_f[3] && ~entry_locked_f[3])
    begin
        replace_index = 4'd3;
    end
    else if (~entry_used_f[4] && ~entry_locked_f[4])
    begin
        replace_index = 4'd4;
    end
    else if (~entry_used_f[5] && ~entry_locked_f[5])
    begin
        replace_index = 4'd5;
    end
    else if (~entry_used_f[6] && ~entry_locked_f[6])
    begin
        replace_index = 4'd6;
    end
    else if (~entry_used_f[7] && ~entry_locked_f[7])
    begin
        replace_index = 4'd7;
    end
    else if (~entry_used_f[8] && ~entry_locked_f[8])
    begin
        replace_index = 4'd8;
    end
    else if (~entry_used_f[9] && ~entry_locked_f[9])
    begin
        replace_index = 4'd9;
    end
    else if (~entry_used_f[10] && ~entry_locked_f[10])
    begin
        replace_index = 4'd10;
    end
    else if (~entry_used_f[11] && ~entry_locked_f[11])
    begin
        replace_index = 4'd11;
    end
    else if (~entry_used_f[12] && ~entry_locked_f[12])
    begin
        replace_index = 4'd12;
    end
    else if (~entry_used_f[13] && ~entry_locked_f[13])
    begin
        replace_index = 4'd13;
    end
    else if (~entry_used_f[14] && ~entry_locked_f[14])
    begin
        replace_index = 4'd14;
    end
    else if (~entry_used_f[15] && ~entry_locked_f[15])
    begin
        replace_index = 4'd15;
    end
    else
    begin
        replace_index = 4'dx;
    end

end
*/

always @ *
begin
    if (wr_en && wr_diag_en)
    begin
        wr_index = wr_index_in;
    end
    else if ((flush_en || wr_en) && wr_hit)
    begin
        wr_index = wr_hit_index;
    end
    else
    begin
        wr_index = replace_index;
    end
end


always @ (posedge clk)
begin
    if (!rst_n)
    begin
        data_mem_f[0] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[1] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[2] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[3] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[4] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[5] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[6] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[7] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[8] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[9] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[10] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[11] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[12] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[13] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[14] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};
        data_mem_f[15] <= {`L15_HMC_ARRAY_WIDTH{1'b0}};

    end
    else if (flush_en)
    begin
        case (addr_op)
        2'd0:
        begin
            data_mem_f[0][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[1][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[2][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[3][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[4][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[5][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[6][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[7][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[8][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[9][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[10][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[11][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[12][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[13][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[14][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            data_mem_f[15][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};

        end
        2'd1:
        begin
            if (wr_hit)
            begin
                data_mem_f[wr_index][`L15_HMC_DATA_WIDTH+wr_offset_in] <= 1'b0;

            end
        end
        2'd2:
        begin
            if ((smc_sdid[0] == wr_sdid_in) && (smc_valid[0] != 0))
                data_mem_f[0][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[1] == wr_sdid_in) && (smc_valid[1] != 0))
                data_mem_f[1][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[2] == wr_sdid_in) && (smc_valid[2] != 0))
                data_mem_f[2][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[3] == wr_sdid_in) && (smc_valid[3] != 0))
                data_mem_f[3][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[4] == wr_sdid_in) && (smc_valid[4] != 0))
                data_mem_f[4][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[5] == wr_sdid_in) && (smc_valid[5] != 0))
                data_mem_f[5][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[6] == wr_sdid_in) && (smc_valid[6] != 0))
                data_mem_f[6][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[7] == wr_sdid_in) && (smc_valid[7] != 0))
                data_mem_f[7][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[8] == wr_sdid_in) && (smc_valid[8] != 0))
                data_mem_f[8][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[9] == wr_sdid_in) && (smc_valid[9] != 0))
                data_mem_f[9][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[10] == wr_sdid_in) && (smc_valid[10] != 0))
                data_mem_f[10][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[11] == wr_sdid_in) && (smc_valid[11] != 0))
                data_mem_f[11][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[12] == wr_sdid_in) && (smc_valid[12] != 0))
                data_mem_f[12][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[13] == wr_sdid_in) && (smc_valid[13] != 0))
                data_mem_f[13][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[14] == wr_sdid_in) && (smc_valid[14] != 0))
                data_mem_f[14][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};
            if ((smc_sdid[15] == wr_sdid_in) && (smc_valid[15] != 0))
                data_mem_f[15][`L15_HMC_VALID] <= {`L15_HMC_VALID_WIDTH{1'b0}};

        end
        default:
        begin
            data_mem_f[wr_index] <= data_mem_f[wr_index];
        end
        endcase
    end
    else if (wr_en)
    begin
        if (wr_diag_en)
        begin
            case (addr_op)
            2'd0:
            begin
                case (wr_offset_in)
                2'd0:
                begin
                    data_mem_f[wr_index][`L15_HMC_DATA_OUT_WIDTH-1:0] <=
                    data_in[`L15_HMC_DATA_OUT_WIDTH-1:0];
                end
                2'd1:
                begin
                    data_mem_f[wr_index][`L15_HMC_DATA_OUT_WIDTH*2-1:`L15_HMC_DATA_OUT_WIDTH] <=
                    data_in[`L15_HMC_DATA_OUT_WIDTH-1:0];
                end
                2'd2:
                begin
                    data_mem_f[wr_index][`L15_HMC_DATA_OUT_WIDTH*3-1:`L15_HMC_DATA_OUT_WIDTH*2] <=
                    data_in[`L15_HMC_DATA_OUT_WIDTH-1:0];
                end
                2'd3:
                begin
                    data_mem_f[wr_index][`L15_HMC_DATA_OUT_WIDTH*4-1:`L15_HMC_DATA_OUT_WIDTH*3] <=
                    data_in[`L15_HMC_DATA_OUT_WIDTH-1:0];
                end
                default:
                begin
                    data_mem_f[wr_index] <= data_mem_f[wr_index];
                end
                endcase
            end
            2'd1:
            begin
                data_mem_f[wr_index][`L15_HMC_VALID] <= data_in[`L15_HMC_VALID_WIDTH-1:0];
            end
            2'd2:
            begin
                data_mem_f[wr_index][`L15_HMC_TAG] <= data_in[`L15_HMC_TAG_WIDTH-1:0];
            end
            default:
            begin
                data_mem_f[wr_index] <= data_mem_f[wr_index];
            end
            endcase
        end
        else
        begin
            data_mem_f[wr_index] <= {wr_tag_in, smc_valid_in, smc_data_in};
        end
    end
end


endmodule

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
//  Filename      : noc1buffer.v
//  Created On    : 2014-02-05 20:06:27
//  Last Modified : 2015-01-22 17:30:55
//  Revision      :
//  Author        : Tri Nguyen
//  Company       : Princeton University
//  Email         : trin@princeton.edu
//
//  Description   :
//
//
//==================================================================================================
`include "l15.tmp.h"



`ifdef DEFAULT_NETTYPE_NONE
`default_nettype none // DEFAULT_NETTYPE_NONE
`endif
module noc1buffer(
   input wire clk,
   input wire rst_n,
   input wire [63:0] l15_noc1buffer_req_data_0,
   input wire [63:0] l15_noc1buffer_req_data_1,
   input wire l15_noc1buffer_req_val,
   input wire [`L15_NOC1_REQTYPE_WIDTH-1:0] l15_noc1buffer_req_type,
   input wire [`L15_MSHR_ID_WIDTH-1:0] l15_noc1buffer_req_mshrid,
   input wire [`L15_THREADID_MASK] l15_noc1buffer_req_threadid,
   input wire [39:0] l15_noc1buffer_req_address,
   input wire l15_noc1buffer_req_non_cacheable,
   input wire [`PCX_SIZE_WIDTH-1:0] l15_noc1buffer_req_size,
   input wire l15_noc1buffer_req_prefetch,
   // input wire l15_noc1buffer_req_blkstore,
   // input wire l15_noc1buffer_req_blkinitstore,
   input wire [`L15_CSM_NUM_TICKETS_LOG2-1:0] l15_noc1buffer_req_csm_ticket,
   input wire [`PACKET_HOME_ID_WIDTH-1:0] l15_noc1buffer_req_homeid,
   input wire l15_noc1buffer_req_homeid_val,
   input wire [`TLB_CSM_WIDTH-1:0] l15_noc1buffer_req_csm_data,

   input wire noc1encoder_noc1buffer_req_ack,

   // csm interface
   input wire [`PACKET_HOME_ID_WIDTH-1:0] csm_l15_read_res_data,
   input wire csm_l15_read_res_val,


   output reg [63:0] noc1buffer_noc1encoder_req_data_0,
   output reg [63:0] noc1buffer_noc1encoder_req_data_1,
   output reg noc1buffer_noc1encoder_req_val,
   output reg [`L15_NOC1_REQTYPE_WIDTH-1:0] noc1buffer_noc1encoder_req_type,
   output reg [`L15_MSHR_ID_WIDTH-1:0] noc1buffer_noc1encoder_req_mshrid,
   output reg [`L15_THREADID_MASK] noc1buffer_noc1encoder_req_threadid,
   output reg [39:0] noc1buffer_noc1encoder_req_address,
   output reg noc1buffer_noc1encoder_req_non_cacheable,
   output reg [`PCX_SIZE_WIDTH-1:0] noc1buffer_noc1encoder_req_size,
   output reg noc1buffer_noc1encoder_req_prefetch,
   // output reg noc1buffer_noc1encoder_req_blkstore,
   // output reg noc1buffer_noc1encoder_req_blkinitstore,
   output reg [`PACKET_HOME_ID_WIDTH-1:0] noc1buffer_noc1encoder_req_homeid,
   output reg [`MSG_SDID_WIDTH-1:0] noc1buffer_noc1encoder_req_csm_sdid,
   output reg [`MSG_LSID_WIDTH-1:0] noc1buffer_noc1encoder_req_csm_lsid,

   // csm interface
   output reg [`L15_CSM_NUM_TICKETS_LOG2-1:0] l15_csm_read_ticket,
   output reg [`L15_CSM_NUM_TICKETS_LOG2-1:0] l15_csm_clear_ticket,
   output reg l15_csm_clear_ticket_val,

   // output to mshrid when we have the csm
   output reg noc1buffer_mshr_homeid_write_val_s4,
   output reg [`L15_MSHR_ID_WIDTH-1:0] noc1buffer_mshr_homeid_write_mshrid_s4,
   output reg [`L15_THREADID_MASK] noc1buffer_mshr_homeid_write_threadid_s4,
   output reg [`PACKET_HOME_ID_WIDTH-1:0] noc1buffer_mshr_homeid_write_data_s4,

   // output reg noc1buffer_l15_req_ack,
   output reg noc1buffer_l15_req_sent,
   output reg [`NOC1_BUFFER_ACK_DATA_WIDTH-1:0] noc1buffer_l15_req_data_sent

);

reg [`L15_COMMAND_BUFFER_LEN-1:0] command_buffer [0:`NOC1_BUFFER_NUM_SLOTS-1];
reg [63:0] data_buffer [0:`NOC1_BUFFER_NUM_DATA_SLOTS-1];
reg [`L15_COMMAND_BUFFER_LEN-1:0] command_buffer_next [0:`NOC1_BUFFER_NUM_SLOTS-1];
reg [63:0] data_buffer_next [0:`NOC1_BUFFER_NUM_DATA_SLOTS-1];

reg command_buffer_val [0:`NOC1_BUFFER_NUM_SLOTS-1];
reg command_buffer_val_next [0:`NOC1_BUFFER_NUM_SLOTS-1];

reg [`NOC1_BUFFER_NUM_SLOTS_LOG-1:0] command_wrindex;
reg [`NOC1_BUFFER_NUM_SLOTS_LOG-1:0] command_wrindex_next;
reg [`NOC1_BUFFER_NUM_SLOTS_LOG-1:0] command_rdindex;
reg [`NOC1_BUFFER_NUM_SLOTS_LOG-1:0] command_rdindex_next;
reg [`NOC1_BUFFER_NUM_SLOTS_LOG-1:0] command_rdindex_plus1;
reg [`NOC1_BUFFER_NUM_DATA_SLOTS_LOG-1:0] data_wrindex;
reg [`NOC1_BUFFER_NUM_DATA_SLOTS_LOG-1:0] data_wrindex_next;
reg [`NOC1_BUFFER_NUM_DATA_SLOTS_LOG-1:0] data_wrindex_plus_1;
reg [`NOC1_BUFFER_NUM_DATA_SLOTS_LOG-1:0] data_wrindex_plus_2;
reg [`NOC1_BUFFER_NUM_DATA_SLOTS_LOG-1:0] data_rdindex;
reg [`NOC1_BUFFER_NUM_DATA_SLOTS_LOG-1:0] data_rdindex_plus1;

always @ (posedge clk)
begin
   if (!rst_n)
   begin
      command_buffer[0] <= 0;
command_buffer_val[0] <= 0;
command_buffer[1] <= 0;
command_buffer_val[1] <= 0;
command_buffer[2] <= 0;
command_buffer_val[2] <= 0;
command_buffer[3] <= 0;
command_buffer_val[3] <= 0;
command_buffer[4] <= 0;
command_buffer_val[4] <= 0;
command_buffer[5] <= 0;
command_buffer_val[5] <= 0;
command_buffer[6] <= 0;
command_buffer_val[6] <= 0;
command_buffer[7] <= 0;
command_buffer_val[7] <= 0;
data_buffer[0] <= 0;
data_buffer[1] <= 0;

      data_wrindex <= 0;
      command_wrindex <= 0;
      command_rdindex <= 0;
   end
   else
   begin
      // for (i = 0; i < `NOC1_BUFFER_NUM_SLOTS; i = i + 1)
      // begin
      //     command_buffer[i] <= command_buffer_next[i];
      //     command_buffer_val[i] <= command_buffer_val_next[i];
      // end
      // for (i = 0; i < `NOC1_BUFFER_NUM_DATA_SLOTS; i = i + 1)
      // begin
      //     data_buffer[i] <= data_buffer_next[i];
      // end
      command_buffer[0] <= command_buffer_next[0];
command_buffer_val[0] <= command_buffer_val_next[0];
command_buffer[1] <= command_buffer_next[1];
command_buffer_val[1] <= command_buffer_val_next[1];
command_buffer[2] <= command_buffer_next[2];
command_buffer_val[2] <= command_buffer_val_next[2];
command_buffer[3] <= command_buffer_next[3];
command_buffer_val[3] <= command_buffer_val_next[3];
command_buffer[4] <= command_buffer_next[4];
command_buffer_val[4] <= command_buffer_val_next[4];
command_buffer[5] <= command_buffer_next[5];
command_buffer_val[5] <= command_buffer_val_next[5];
command_buffer[6] <= command_buffer_next[6];
command_buffer_val[6] <= command_buffer_val_next[6];
command_buffer[7] <= command_buffer_next[7];
command_buffer_val[7] <= command_buffer_val_next[7];
data_buffer[0] <= data_buffer_next[0];
data_buffer[1] <= data_buffer_next[1];

      data_wrindex <= data_wrindex_next;
      command_wrindex <= command_wrindex_next;
      command_rdindex <= command_rdindex_next;
   end
end

// Mostly related to writes
always @ *
begin
   command_buffer_next[0] = command_buffer[0];
command_buffer_next[1] = command_buffer[1];
command_buffer_next[2] = command_buffer[2];
command_buffer_next[3] = command_buffer[3];
command_buffer_next[4] = command_buffer[4];
command_buffer_next[5] = command_buffer[5];
command_buffer_next[6] = command_buffer[6];
command_buffer_next[7] = command_buffer[7];
data_buffer_next[0] = data_buffer[0];
data_buffer_next[1] = data_buffer[1];


   command_wrindex_next = command_wrindex;
   data_wrindex_next = data_wrindex;
   data_wrindex_plus_1 = data_wrindex + 1;
   data_wrindex_plus_2 = data_wrindex + 2;

   if (l15_noc1buffer_req_val)
   begin
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_REQTYPE] = l15_noc1buffer_req_type;
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_MSHRID] = l15_noc1buffer_req_mshrid;
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_THREADID] = l15_noc1buffer_req_threadid;
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_ADDRESS] = l15_noc1buffer_req_address;
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_NON_CACHEABLE] = l15_noc1buffer_req_non_cacheable;
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_SIZE] = l15_noc1buffer_req_size;
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_PREFETCH] = l15_noc1buffer_req_prefetch;
      // command_buffer_next[command_wrindex][`L15_NOC1BUFFER_BLKSTORE] = l15_noc1buffer_req_blkstore;
      // command_buffer_next[command_wrindex][`L15_NOC1BUFFER_BLKINITSTORE] = l15_noc1buffer_req_blkinitstore;
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_DATA_INDEX] = data_wrindex;
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_CSM_TICKET] = l15_noc1buffer_req_csm_ticket;
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_HOMEID] = l15_noc1buffer_req_homeid;
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_HOMEID_VAL] = l15_noc1buffer_req_homeid_val;
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_CSM_SDID] = l15_noc1buffer_req_csm_data[`TLB_CSM_SDID];
      command_buffer_next[command_wrindex][`L15_NOC1BUFFER_CSM_LSID] = l15_noc1buffer_req_csm_data[`TLB_CSM_LSID];

      command_wrindex_next = command_wrindex + 1;

      if (l15_noc1buffer_req_type == `L15_NOC1_REQTYPE_CAS_REQUEST)
      begin
         data_buffer_next[data_wrindex] = l15_noc1buffer_req_data_0;
         data_buffer_next[data_wrindex_plus_1] = l15_noc1buffer_req_data_1;
         data_wrindex_next = data_wrindex_plus_2;
      end
      else if (l15_noc1buffer_req_type == `L15_NOC1_REQTYPE_SWAP_REQUEST ||
               l15_noc1buffer_req_type == `L15_NOC1_REQTYPE_INTERRUPT_FWD ||
               l15_noc1buffer_req_type == `L15_NOC1_REQTYPE_WRITETHROUGH_REQUEST)
      begin
         data_buffer_next[data_wrindex] = l15_noc1buffer_req_data_0;
         data_wrindex_next = data_wrindex_plus_1;
      end
   end
end

// issue port to noc1encoder
reg [`PACKET_HOME_ID_WIDTH-1:0] homeid;
reg homeid_val;
always @ *
begin
   // noc1buffer_l15_req_ack = noc1encoder_noc1buffer_req_ack;    // deprecated as noc1 is non-blocking
                                                // from pipeline's perspective
   data_rdindex_plus1 = data_rdindex + 1;

   noc1buffer_noc1encoder_req_type = command_buffer[command_rdindex][`L15_NOC1BUFFER_REQTYPE];
   noc1buffer_noc1encoder_req_mshrid = command_buffer[command_rdindex][`L15_NOC1BUFFER_MSHRID];
   noc1buffer_noc1encoder_req_threadid = command_buffer[command_rdindex][`L15_NOC1BUFFER_THREADID];
   noc1buffer_noc1encoder_req_address = command_buffer[command_rdindex][`L15_NOC1BUFFER_ADDRESS];
   noc1buffer_noc1encoder_req_non_cacheable = command_buffer[command_rdindex][`L15_NOC1BUFFER_NON_CACHEABLE];
   noc1buffer_noc1encoder_req_size = command_buffer[command_rdindex][`L15_NOC1BUFFER_SIZE];
   noc1buffer_noc1encoder_req_prefetch = command_buffer[command_rdindex][`L15_NOC1BUFFER_PREFETCH];
   // noc1buffer_noc1encoder_req_blkstore = command_buffer[command_rdindex][`L15_NOC1BUFFER_BLKSTORE];
   // noc1buffer_noc1encoder_req_blkinitstore = command_buffer[command_rdindex][`L15_NOC1BUFFER_BLKINITSTORE];
   noc1buffer_noc1encoder_req_csm_sdid = command_buffer[command_rdindex][`L15_NOC1BUFFER_CSM_SDID];
   noc1buffer_noc1encoder_req_csm_lsid = command_buffer[command_rdindex][`L15_NOC1BUFFER_CSM_LSID];

   data_rdindex = command_buffer[command_rdindex][`L15_NOC1BUFFER_DATA_INDEX];
   noc1buffer_noc1encoder_req_data_0 = data_buffer[data_rdindex];
   noc1buffer_noc1encoder_req_data_1 = data_buffer[data_rdindex_plus1];

   noc1buffer_noc1encoder_req_homeid = homeid;

   noc1buffer_noc1encoder_req_val = command_buffer_val[command_rdindex] && homeid_val;
end


// Tri: for now just issue FIFO. we can try OoO issuing later when CSM is verified and stable.
reg [`PACKET_HOME_ID_WIDTH-1:0] cached_homeid;
reg cached_homeid_val;
reg [`PACKET_HOME_ID_WIDTH-1:0] fetch_homeid;
reg fetch_homeid_val;
   // Note: cached value is obtained at s3. meant to speed issuing if ghid is cached in the csm module
   //  the normal value is from reading the csm module (in case the translation wasn't cached)
   //  However for this "blocking single issue" the normal value is just as fast as cached
// CSM and homeid
always @ *
begin
   cached_homeid_val = command_buffer[command_rdindex][`L15_NOC1BUFFER_HOMEID_VAL];
   cached_homeid = command_buffer[command_rdindex][`L15_NOC1BUFFER_HOMEID];
   fetch_homeid_val = csm_l15_read_res_val;
   fetch_homeid = csm_l15_read_res_data;

   homeid_val = cached_homeid_val | fetch_homeid_val;
   homeid = cached_homeid_val ? cached_homeid : fetch_homeid;

   // output to CSM module
   l15_csm_read_ticket = command_buffer[command_rdindex][`L15_NOC1BUFFER_CSM_TICKET]; // read req
   l15_csm_clear_ticket = l15_csm_read_ticket;
   l15_csm_clear_ticket_val = noc1encoder_noc1buffer_req_ack; // clear when sent

   // output to MSHR module
   noc1buffer_mshr_homeid_write_val_s4 = (noc1buffer_noc1encoder_req_mshrid == `L15_MSHR_ID_LD || noc1buffer_noc1encoder_req_mshrid == `L15_MSHR_ID_ST) &&
                                    noc1encoder_noc1buffer_req_ack;
   noc1buffer_mshr_homeid_write_mshrid_s4 = noc1buffer_noc1encoder_req_mshrid;
   noc1buffer_mshr_homeid_write_threadid_s4 = noc1buffer_noc1encoder_req_threadid;
   noc1buffer_mshr_homeid_write_data_s4 = homeid;
end



// handling valid array (and conflicts)
always @ *
begin
   
   if (l15_noc1buffer_req_val && (command_wrindex == 0))
      command_buffer_val_next[0] = 1'b1;
   else if (noc1encoder_noc1buffer_req_ack && (command_rdindex == 0))
      command_buffer_val_next[0] = 1'b0;
   else
      command_buffer_val_next[0] = command_buffer_val[0];
   

   if (l15_noc1buffer_req_val && (command_wrindex == 1))
      command_buffer_val_next[1] = 1'b1;
   else if (noc1encoder_noc1buffer_req_ack && (command_rdindex == 1))
      command_buffer_val_next[1] = 1'b0;
   else
      command_buffer_val_next[1] = command_buffer_val[1];
   

   if (l15_noc1buffer_req_val && (command_wrindex == 2))
      command_buffer_val_next[2] = 1'b1;
   else if (noc1encoder_noc1buffer_req_ack && (command_rdindex == 2))
      command_buffer_val_next[2] = 1'b0;
   else
      command_buffer_val_next[2] = command_buffer_val[2];
   

   if (l15_noc1buffer_req_val && (command_wrindex == 3))
      command_buffer_val_next[3] = 1'b1;
   else if (noc1encoder_noc1buffer_req_ack && (command_rdindex == 3))
      command_buffer_val_next[3] = 1'b0;
   else
      command_buffer_val_next[3] = command_buffer_val[3];
   

   if (l15_noc1buffer_req_val && (command_wrindex == 4))
      command_buffer_val_next[4] = 1'b1;
   else if (noc1encoder_noc1buffer_req_ack && (command_rdindex == 4))
      command_buffer_val_next[4] = 1'b0;
   else
      command_buffer_val_next[4] = command_buffer_val[4];
   

   if (l15_noc1buffer_req_val && (command_wrindex == 5))
      command_buffer_val_next[5] = 1'b1;
   else if (noc1encoder_noc1buffer_req_ack && (command_rdindex == 5))
      command_buffer_val_next[5] = 1'b0;
   else
      command_buffer_val_next[5] = command_buffer_val[5];
   

   if (l15_noc1buffer_req_val && (command_wrindex == 6))
      command_buffer_val_next[6] = 1'b1;
   else if (noc1encoder_noc1buffer_req_ack && (command_rdindex == 6))
      command_buffer_val_next[6] = 1'b0;
   else
      command_buffer_val_next[6] = command_buffer_val[6];
   

   if (l15_noc1buffer_req_val && (command_wrindex == 7))
      command_buffer_val_next[7] = 1'b1;
   else if (noc1encoder_noc1buffer_req_ack && (command_rdindex == 7))
      command_buffer_val_next[7] = 1'b0;
   else
      command_buffer_val_next[7] = command_buffer_val[7];
   

end

// data credit logic
always @ *
begin
   noc1buffer_l15_req_data_sent = 0;
   noc1buffer_l15_req_sent = noc1encoder_noc1buffer_req_ack;
   command_rdindex_plus1 = command_rdindex + 1;
   command_rdindex_next = command_rdindex;
   if (noc1encoder_noc1buffer_req_ack == 1'b1)
   begin
      command_rdindex_next = command_rdindex_plus1;
      case (noc1buffer_noc1encoder_req_type)
         `L15_NOC1_REQTYPE_WRITETHROUGH_REQUEST,
         `L15_NOC1_REQTYPE_SWAP_REQUEST,
         `L15_NOC1_REQTYPE_INTERRUPT_FWD:
         begin
            noc1buffer_l15_req_data_sent = `NOC1_BUFFER_ACK_DATA_8B;
         end
         `L15_NOC1_REQTYPE_CAS_REQUEST:
         begin
            noc1buffer_l15_req_data_sent = `NOC1_BUFFER_ACK_DATA_16B;
         end
      endcase
   end
end
endmodule

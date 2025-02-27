// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_ifu_errdp.v
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
//  Module Name:  sparc_ifu_errdp
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////



`include "sys.h"
`include "lsu.tmp.h"
`include "ifu.tmp.h"

module sparc_ifu_errdp(/*AUTOARG*/
   // Outputs
   so, ifu_lsu_ldxa_data_w2, erb_dtu_imask, erd_erc_tlbt_pe_s1, 
   erd_erc_tlbd_pe_s1, erd_erc_tagpe_s1, erd_erc_nirpe_s1, 
   erd_erc_fetpe_s1, erd_erc_tte_pgsz, 
   // Inputs
   rclk, se, si, erb_reset, itlb_rd_tte_data, itlb_rd_tte_tag, 
   itlb_ifq_paddr_s, wsel_fdp_fetdata_s1, wsel_fdp_topdata_s1, 
   wsel_erb_asidata_s, ict_itlb_tags_f, icv_itlb_valid_f, 
   lsu_ifu_err_addr, spu_ifu_err_addr_w2, fdp_erb_pc_f, 
   exu_ifu_err_reg_m, exu_ifu_err_synd_m, ffu_ifu_err_reg_w2, 
   ffu_ifu_err_synd_w2, tlu_itlb_rw_index_g, erc_erd_pgsz_b0, 
   erc_erd_pgsz_b1, erc_erd_erren_asidata, erc_erd_errstat_asidata, 
   erc_erd_errinj_asidata, ifq_erb_asidata_i2, ifq_erb_wrtag_f, 
   ifq_erb_wrindex_f, erc_erd_asiway_s1_l, fcl_erb_itlbrd_data_s, 
   erc_erd_ld_imask, erc_erd_asisrc_sel_icd_s_l, 
   erc_erd_asisrc_sel_misc_s_l, erc_erd_asisrc_sel_err_s_l, 
   erc_erd_asisrc_sel_itlb_s_l, erc_erd_errasi_sel_en_l, 
   erc_erd_errasi_sel_stat_l, erc_erd_errasi_sel_inj_l, 
   erc_erd_errasi_sel_addr_l, erc_erd_miscasi_sel_ict_l, 
   erc_erd_miscasi_sel_imask_l, erc_erd_miscasi_sel_other_l, 
   erc_erd_asi_thr_l, erc_erd_eadr0_sel_irf_l, 
   erc_erd_eadr0_sel_itlb_l, erc_erd_eadr0_sel_frf_l, 
   erc_erd_eadr0_sel_lsu_l, erc_erd_eadr1_sel_pcd1_l, 
   erc_erd_eadr1_sel_l1pa_l, erc_erd_eadr1_sel_l2pa_l, 
   erc_erd_eadr1_sel_other_l, erc_erd_eadr2_sel_mx1_l, 
   erc_erd_eadr2_sel_wrt_l, erc_erd_eadr2_sel_mx0_l, 
   erc_erd_eadr2_sel_old_l
   );

   input       rclk, 
               se, 
               si, 
               erb_reset;

   input [42:0] itlb_rd_tte_data;   // this is in s1
   input [58:0] itlb_rd_tte_tag;    // this is in s1
   input [39:10] itlb_ifq_paddr_s;
   input [33:0] wsel_fdp_fetdata_s1,    
		            wsel_fdp_topdata_s1;
   input [33:0] wsel_erb_asidata_s;
   
   input [`IC_TLB_TAG_MASK_ALL] ict_itlb_tags_f;
   input [3:0]              icv_itlb_valid_f;

   input [47:4]  lsu_ifu_err_addr;
   input [39:4]  spu_ifu_err_addr_w2;
   input [47:0]  fdp_erb_pc_f;
   
   input [7:0]   exu_ifu_err_reg_m;
   input [7:0]   exu_ifu_err_synd_m;
   input [5:0]   ffu_ifu_err_reg_w2;
   input [13:0]  ffu_ifu_err_synd_w2;
   input [5:0]   tlu_itlb_rw_index_g;

   input         erc_erd_pgsz_b0,
                 erc_erd_pgsz_b1;

   input [1:0]   erc_erd_erren_asidata;
   input [22:0]  erc_erd_errstat_asidata;
   input [31:0]  erc_erd_errinj_asidata;   
   input [47:0]  ifq_erb_asidata_i2;

   input [`IC_TAG_SZ-1:0] ifq_erb_wrtag_f;
   input [`IC_IDX_HI:4]   ifq_erb_wrindex_f;
   
   // mux selects
   input [3:0]  erc_erd_asiway_s1_l;
   input        fcl_erb_itlbrd_data_s;
   input        erc_erd_ld_imask;
   
   input        erc_erd_asisrc_sel_icd_s_l,  
		            erc_erd_asisrc_sel_misc_s_l,
		            erc_erd_asisrc_sel_err_s_l,
		            erc_erd_asisrc_sel_itlb_s_l;

   input        erc_erd_errasi_sel_en_l,
		            erc_erd_errasi_sel_stat_l,
		            erc_erd_errasi_sel_inj_l,
		            erc_erd_errasi_sel_addr_l;

   input        erc_erd_miscasi_sel_ict_l,
		            erc_erd_miscasi_sel_imask_l,
		            erc_erd_miscasi_sel_other_l;

   input [3:0]  erc_erd_asi_thr_l;   
	 
   input [3:0]  erc_erd_eadr0_sel_irf_l,
		            erc_erd_eadr0_sel_itlb_l,
		            erc_erd_eadr0_sel_frf_l,
		            erc_erd_eadr0_sel_lsu_l;
   
   input [3:0]  erc_erd_eadr1_sel_pcd1_l,
		            erc_erd_eadr1_sel_l1pa_l,
		            erc_erd_eadr1_sel_l2pa_l,
		            erc_erd_eadr1_sel_other_l;
   
   input [3:0]  erc_erd_eadr2_sel_mx1_l,
		            erc_erd_eadr2_sel_wrt_l,
		            erc_erd_eadr2_sel_mx0_l,
		            erc_erd_eadr2_sel_old_l;

   
   output       so;
   output [63:0] ifu_lsu_ldxa_data_w2;
   output [38:0] erb_dtu_imask;
//   output [9:0]  erb_ifq_paddr_s;
   
   output [1:0]  erd_erc_tlbt_pe_s1,
		             erd_erc_tlbd_pe_s1;
   output [3:0]  erd_erc_tagpe_s1;
   output        erd_erc_nirpe_s1,
		             erd_erc_fetpe_s1;

   output [2:0]  erd_erc_tte_pgsz;


//   
// local signals   
//

   wire [47:4]   lsu_err_addr;
   
   wire [`IC_TLB_TAG_MASK_ALL]  ictags_s1;
   wire [3:0]               icv_data_s1;
   reg  [34:0]              tag_asi_data;

   wire [47:4]              t0_eadr_mx0_out,
		                        t1_eadr_mx0_out,
		                        t2_eadr_mx0_out,
		                        t3_eadr_mx0_out,
 		                        t0_eadr_mx1_out,
		                        t1_eadr_mx1_out,
		                        t2_eadr_mx1_out,
		                        t3_eadr_mx1_out;
   
   wire [47:4]              t0_err_addr_nxt,
		                        t0_err_addr,
	 	                        t1_err_addr_nxt,
		                        t1_err_addr,
		                        t2_err_addr_nxt,
		                        t2_err_addr,
		                        t3_err_addr_nxt,
		                        t3_err_addr;
   
   wire [47:4]              err_addr_asidata;
	 
   wire [63:0]              formatted_tte_data,
		                        formatted_tte_tag,
		                        tlb_asi_data,
		                        misc_asi_data,
		                        err_asi_data,
                            ldxa_data_s,
                            ldxa_data_d;
   
   wire [39:4]              paddr_s1,
		                        paddr_d1;
   
   wire [39:4]              ifet_addr_f;
   
   wire [47:0]              pc_s1;
   wire [47:4]              pc_d1;
   wire [7:0]               irfaddr_w,
                            irfsynd_w;
   wire                     irfaddr_4_w;
   wire [5:0]               itlb_asi_index;

   wire [38:0]              imask_next;

   wire                     clk;
   
   
//
// Code Begins Here
//
   assign                   clk = rclk;
   
//-------------
// Tags
//-------------   
   dff_s #(`IC_TLB_TAG_SZ * `IC_NUM_WAY) tags_reg(.din (ict_itlb_tags_f),
		                           .q   (ictags_s1),
		                           .clk (clk),
		                           .se  (se), .si(), .so());

   dff_s #(4) vbits_reg(.din (icv_itlb_valid_f[3:0]),
		                  .q   (icv_data_s1),
		                  .clk (clk), .se(se), .si(), .so());

   // // check parity
   // sparc_ifu_par32  tag_par0(.in  ({{`IC_TLB_PARITY_PADDING{1'b0}}, ictags_s1[`IC_TLB_TAG_WAY0_MASK]}),
			//                        .out (erd_erc_tagpe_s1[0]));
   // sparc_ifu_par32  tag_par1(.in  ({{`IC_TLB_PARITY_PADDING{1'b0}}, ictags_s1[`IC_TLB_TAG_WAY1_MASK]}),
			//                        .out (erd_erc_tagpe_s1[1]));
   // sparc_ifu_par32  tag_par2(.in  ({{`IC_TLB_PARITY_PADDING{1'b0}}, ictags_s1[`IC_TLB_TAG_WAY2_MASK]}),
			//                        .out (erd_erc_tagpe_s1[2]));
   // sparc_ifu_par32  tag_par3(.in  ({{`IC_TLB_PARITY_PADDING{1'b0}}, ictags_s1[`IC_TLB_TAG_WAY3_MASK]}),
			//                        .out (erd_erc_tagpe_s1[3]));

`ifdef NO_IC_TLB_PARITY_PADDING
   
      sparc_ifu_par32  tag_par0(.in  (ictags_s1[`IC_TLB_TAG_WAY0_MASK]),
                              .out (erd_erc_tagpe_s1[0]));
   

      sparc_ifu_par32  tag_par1(.in  (ictags_s1[`IC_TLB_TAG_WAY1_MASK]),
                              .out (erd_erc_tagpe_s1[1]));
   

      sparc_ifu_par32  tag_par2(.in  (ictags_s1[`IC_TLB_TAG_WAY2_MASK]),
                              .out (erd_erc_tagpe_s1[2]));
   

      sparc_ifu_par32  tag_par3(.in  (ictags_s1[`IC_TLB_TAG_WAY3_MASK]),
                              .out (erd_erc_tagpe_s1[3]));
   

`else
   
      sparc_ifu_par32  tag_par0(.in  ({{`IC_TLB_PARITY_PADDING{1'b0}}, ictags_s1[`IC_TLB_TAG_WAY0_MASK]}),
                              .out (erd_erc_tagpe_s1[0]));
   

      sparc_ifu_par32  tag_par1(.in  ({{`IC_TLB_PARITY_PADDING{1'b0}}, ictags_s1[`IC_TLB_TAG_WAY1_MASK]}),
                              .out (erd_erc_tagpe_s1[1]));
   

      sparc_ifu_par32  tag_par2(.in  ({{`IC_TLB_PARITY_PADDING{1'b0}}, ictags_s1[`IC_TLB_TAG_WAY2_MASK]}),
                              .out (erd_erc_tagpe_s1[2]));
   

      sparc_ifu_par32  tag_par3(.in  ({{`IC_TLB_PARITY_PADDING{1'b0}}, ictags_s1[`IC_TLB_TAG_WAY3_MASK]}),
                              .out (erd_erc_tagpe_s1[3]));
   

`endif

   // dp_mux4ds #(32) asitag_mux(.dout (tag_asi_data[31:0]),
			//  .in0  ({icv_data_s1[0], 1'b0, ictags_s1[28], 1'b0, ictags_s1[27:0]}),
			//  .in1  ({icv_data_s1[1], 1'b0, ictags_s1[57], 1'b0, ictags_s1[56:29]}),
			//  .in2  ({icv_data_s1[2], 1'b0, ictags_s1[86], 1'b0, ictags_s1[85:58]}),
			//  .in3  ({icv_data_s1[3], 1'b0, ictags_s1[115], 1'b0, ictags_s1[114:87]}),   
			 // .sel0_l (erc_erd_asiway_s1_l[0]),
			 // .sel1_l (erc_erd_asiway_s1_l[1]),
			 // .sel2_l (erc_erd_asiway_s1_l[2]),
			 // .sel3_l (erc_erd_asiway_s1_l[3]));

wire [(`IC_TAG_SZ+2)-1:0] icv_data_s10 = {icv_data_s1[0], ictags_s1[(`IC_TAG_SZ+1)*(0+1)-1], ictags_s1[(`IC_TAG_SZ+1)*(0+1)-2 -: `IC_TAG_SZ]};
wire [(`IC_TAG_SZ+2)-1:0] icv_data_s11 = {icv_data_s1[1], ictags_s1[(`IC_TAG_SZ+1)*(1+1)-1], ictags_s1[(`IC_TAG_SZ+1)*(1+1)-2 -: `IC_TAG_SZ]};
wire [(`IC_TAG_SZ+2)-1:0] icv_data_s12 = {icv_data_s1[2], ictags_s1[(`IC_TAG_SZ+1)*(2+1)-1], ictags_s1[(`IC_TAG_SZ+1)*(2+1)-2 -: `IC_TAG_SZ]};
wire [(`IC_TAG_SZ+2)-1:0] icv_data_s13 = {icv_data_s1[3], ictags_s1[(`IC_TAG_SZ+1)*(3+1)-1], ictags_s1[(`IC_TAG_SZ+1)*(3+1)-2 -: `IC_TAG_SZ]};


always @ *
begin
tag_asi_data = 0;

         if (erc_erd_asiway_s1_l[0] == 1'b0)
         begin
            tag_asi_data[(`IC_TAG_SZ-1):0] = icv_data_s10[(`IC_TAG_SZ-1):0];
            tag_asi_data[32] = icv_data_s10[`IC_TAG_SZ];
            tag_asi_data[34] = icv_data_s10[`IC_TAG_SZ+1];
         end
      

         else if (erc_erd_asiway_s1_l[1] == 1'b0)
         begin
            tag_asi_data[(`IC_TAG_SZ-1):0] = icv_data_s11[(`IC_TAG_SZ-1):0];
            tag_asi_data[32] = icv_data_s11[`IC_TAG_SZ];
            tag_asi_data[34] = icv_data_s11[`IC_TAG_SZ+1];
         end
      

         else if (erc_erd_asiway_s1_l[2] == 1'b0)
         begin
            tag_asi_data[(`IC_TAG_SZ-1):0] = icv_data_s12[(`IC_TAG_SZ-1):0];
            tag_asi_data[32] = icv_data_s12[`IC_TAG_SZ];
            tag_asi_data[34] = icv_data_s12[`IC_TAG_SZ+1];
         end
      

         else if (erc_erd_asiway_s1_l[3] == 1'b0)
         begin
            tag_asi_data[(`IC_TAG_SZ-1):0] = icv_data_s13[(`IC_TAG_SZ-1):0];
            tag_asi_data[32] = icv_data_s13[`IC_TAG_SZ];
            tag_asi_data[34] = icv_data_s13[`IC_TAG_SZ+1];
         end
      

end


//------------------
// Data
//------------------
   // parity check on instruction
   // This may have to be done in the next stage (at least partially)
   
   sparc_ifu_par34 nir_par(.in  (wsel_fdp_topdata_s1[33:0]),
			                     .out (erd_erc_nirpe_s1));
   sparc_ifu_par34 inst_par(.in  (wsel_fdp_fetdata_s1[33:0]),
			                      .out (erd_erc_fetpe_s1));

//----------------------------------------------------------------------
// TLB read data
//----------------------------------------------------------------------

//`ifdef SPARC_HPV_EN
   // don't include v(26) and u(24) bits in parity   
   sparc_ifu_par32 tt_tag_par0(.in  ({itlb_rd_tte_tag[33:27],
				                              itlb_rd_tte_tag[25],
				                              itlb_rd_tte_tag[23:0]}),
			                         .out (erd_erc_tlbt_pe_s1[0]));
//`else
//   // don't include v(28) and u(26) bits in parity
//   sparc_ifu_par32 tt_tag_par0(.in  ({itlb_rd_tte_tag[33:29],
//				                              itlb_rd_tte_tag[27],
//				                              itlb_rd_tte_tag[25:0]}),
//			                         .out (erd_erc_tlbt_pe_s1[0]));
//`endif // !`ifdef SPARC_HPV_EN
   
   
   sparc_ifu_par32 tt_tag_par1(.in  ({7'b0, itlb_rd_tte_tag[58:34]}),
			                         .out (erd_erc_tlbt_pe_s1[1]));
   
   sparc_ifu_par32 tt_data_par0(.in  (itlb_rd_tte_data[31:0]),
				                        .out (erd_erc_tlbd_pe_s1[0]));
   sparc_ifu_par16 tt_data_par1(.in  ({5'b0, itlb_rd_tte_data[42:32]}),
				                        .out (erd_erc_tlbd_pe_s1[1]));

//   assign erd_erc_tte_lock_s1 = itlb_rd_tte_data[`STLB_DATA_L];

   
//`ifdef	SPARC_HPV_EN
   assign erd_erc_tte_pgsz[2:0] = {itlb_rd_tte_data[`STLB_DATA_27_22_SEL],
				                           itlb_rd_tte_data[`STLB_DATA_21_16_SEL],
				                           itlb_rd_tte_data[`STLB_DATA_15_13_SEL]};

   assign formatted_tte_tag[63:0] =
          {
//           `ifdef SUN4V_TAG_RD
           // implement this!
           itlb_rd_tte_tag[58:55],
//           `else
//         {4{itlb_rd_tte_tag[53]}},                                     // 4b
//           `endif

           itlb_rd_tte_tag[`STLB_TAG_PARITY],     // Parity                 1b
           itlb_rd_tte_tag[`STLB_TAG_VA_27_22_V], // mxsel2 - b27:22 vld    1b
           itlb_rd_tte_tag[`STLB_TAG_VA_21_16_V], // mxsel1 - b21:16 vld    1b
           itlb_rd_tte_tag[`STLB_TAG_VA_15_13_V], // mxsel0 - b15:13 vld    1b

           {8{itlb_rd_tte_tag[53]}},                                     // 8b
           itlb_rd_tte_tag[`STLB_TAG_VA_47_28_HI:`STLB_TAG_VA_47_28_LO], // 20b
           itlb_rd_tte_tag[`STLB_TAG_VA_27_22_HI:`STLB_TAG_VA_27_22_LO], // 6b
           itlb_rd_tte_tag[`STLB_TAG_VA_21_16_HI:`STLB_TAG_VA_21_16_LO], // 6b
           itlb_rd_tte_tag[`STLB_TAG_VA_15_13_HI:`STLB_TAG_VA_15_13_LO], // 3b
           itlb_rd_tte_tag[`STLB_TAG_CTXT_12_0_HI:`STLB_TAG_CTXT_12_0_LO]// 13b
           } ;
//`else
//   assign erd_erc_tte_pgsz[2:0] = {itlb_rd_tte_data[`STLB_DATA_21_19_SEL],
//				                           itlb_rd_tte_data[`STLB_DATA_18_16_SEL],
//				                           itlb_rd_tte_data[`STLB_DATA_15_13_SEL]};
//
//   assign formatted_tte_tag[63:0] =
//          {
//           {16{itlb_rd_tte_tag[54]}},                                    // 16b
//           itlb_rd_tte_tag[`STLB_TAG_VA_47_22_HI:`STLB_TAG_VA_47_22_LO], // 26b
//           itlb_rd_tte_tag[`STLB_TAG_VA_21_20_HI:`STLB_TAG_VA_21_20_LO], // 3b
//           itlb_rd_tte_tag[`STLB_TAG_VA_19],
//           itlb_rd_tte_tag[`STLB_TAG_VA_18_17_HI:`STLB_TAG_VA_18_17_LO], // 3b
//           itlb_rd_tte_tag[`STLB_TAG_VA_16],
//           itlb_rd_tte_tag[`STLB_TAG_VA_15_14_HI:`STLB_TAG_VA_15_14_LO], // 3b
//           itlb_rd_tte_tag[`STLB_TAG_VA_13],
//           itlb_rd_tte_tag[`STLB_TAG_CTXT_12_7_HI:`STLB_TAG_CTXT_12_7_LO],//13b
//           itlb_rd_tte_tag[`STLB_TAG_CTXT_6_0_HI:`STLB_TAG_CTXT_6_0_LO]
//           } ;
//`endif // !`ifdef SPARC_HPV_EN
   

//`ifdef	SPARC_HPV_EN
   assign formatted_tte_data[63:0] =
          {      
           itlb_rd_tte_tag[`STLB_TAG_V],           // V    (1b)
           erc_erd_pgsz_b1,                        // pg SZ msb 4m or 512k
           erc_erd_pgsz_b0,                        // pg sz lsb 4m or 64k
           itlb_rd_tte_data[`STLB_DATA_NFO],       // NFO  (1b)
           itlb_rd_tte_data[`STLB_DATA_IE],        // IE   (1b)
           10'b0,                                  // soft2 
           itlb_rd_tte_data[`STLB_DATA_27_22_SEL], // pgsz b2
           itlb_rd_tte_tag[`STLB_TAG_U],

           itlb_rd_tte_data[`STLB_DATA_PARITY],      // Parity   (1b)
           itlb_rd_tte_data[`STLB_DATA_27_22_SEL],   // mxsel2_l (1b)
           itlb_rd_tte_data[`STLB_DATA_21_16_SEL],   // mxsel1_l (1b)
           itlb_rd_tte_data[`STLB_DATA_15_13_SEL],   // mxsel0_l (1b)
  
           2'b0,                                   // unused diag 2b
           1'b0,                                   // ?? PA   (28b)
           itlb_rd_tte_data[`STLB_DATA_PA_39_28_HI:`STLB_DATA_PA_39_28_LO],
           itlb_rd_tte_data[`STLB_DATA_PA_27_22_HI:`STLB_DATA_PA_27_22_LO],
           itlb_rd_tte_data[`STLB_DATA_PA_21_16_HI:`STLB_DATA_PA_21_16_LO],
           itlb_rd_tte_data[`STLB_DATA_PA_15_13_HI:`STLB_DATA_PA_15_13_LO],
           6'b0,                                   // ?? 12-7 (6b)
           itlb_rd_tte_data[`STLB_DATA_L],         // L    (1b)
           itlb_rd_tte_data[`STLB_DATA_CP],        // CP   (1b)
           itlb_rd_tte_data[`STLB_DATA_CV],        // CV   (1b)
           itlb_rd_tte_data[`STLB_DATA_E],         // E    (1b)
           itlb_rd_tte_data[`STLB_DATA_P],         // P    (1b)
           itlb_rd_tte_data[`STLB_DATA_W],         // W    (1b)
	         1'b0
        } ;
//`else // !`ifdef SPARC_HPV_EN
//
//   assign formatted_tte_data[63:0] =
//          {      
//           itlb_rd_tte_tag[`STLB_TAG_V],           // V    (1b)
//           erc_erd_pgsz_b1,                        // pg SZ msb 4m or 512k
//           erc_erd_pgsz_b0,                        // pg sz lsb 4m or 64k
//           itlb_rd_tte_data[`STLB_DATA_NFO],       // NFO  (1b)
//           itlb_rd_tte_data[`STLB_DATA_IE],        // IE   (1b)
//           9'b0,                                   // soft2 58-42 (17b)
//           8'b0,                                   // diag 8b
//	         itlb_rd_tte_tag[`STLB_TAG_U],           // U    (1b)
//           1'b0,                                   // ?? PA   (28b)
//           itlb_rd_tte_data[`STLB_DATA_PA_39_22_HI:`STLB_DATA_PA_39_22_LO],
//           itlb_rd_tte_data[`STLB_DATA_PA_21_19_HI:`STLB_DATA_PA_21_19_LO],
//           itlb_rd_tte_data[`STLB_DATA_PA_18_16_HI:`STLB_DATA_PA_18_16_LO],
//           itlb_rd_tte_data[`STLB_DATA_PA_15_13_HI:`STLB_DATA_PA_15_13_LO],
//           6'b0,                                   // ?? 12-7 (6b)
//           itlb_rd_tte_data[`STLB_DATA_L],         // L    (1b)
//           itlb_rd_tte_data[`STLB_DATA_CP],        // CP   (1b)
//           itlb_rd_tte_data[`STLB_DATA_CV],        // CV   (1b)
//           itlb_rd_tte_data[`STLB_DATA_E],         // E    (1b)
//           itlb_rd_tte_data[`STLB_DATA_P],         // P    (1b)
//           itlb_rd_tte_data[`STLB_DATA_W],         // W    (1b)
//           itlb_rd_tte_data[`STLB_DATA_G]          // G    (1b)
//        } ;
//`endif // !`ifdef SPARC_HPV_EN
   
   

   // mux in all asi values
   dp_mux2es #(64) itlbrd_mux(.dout (tlb_asi_data[63:0]),
			    .in0  (formatted_tte_tag[63:0]),
			    .in1  (formatted_tte_data[63:0]),
			    .sel  (fcl_erb_itlbrd_data_s));

   dp_mux4ds #(64) err_mux(.dout (err_asi_data[63:0]),
			 .in0  ({62'b0, erc_erd_erren_asidata}),
			 .in1  ({32'b0, erc_erd_errstat_asidata, 9'b0}),
			 .in2  ({32'b0, erc_erd_errinj_asidata}),
			 .in3  ({16'b0, err_addr_asidata, 4'b0}),
			 .sel0_l (erc_erd_errasi_sel_en_l),
			 .sel1_l (erc_erd_errasi_sel_stat_l),
			 .sel2_l (erc_erd_errasi_sel_inj_l),
			 .sel3_l (erc_erd_errasi_sel_addr_l));

   dp_mux3ds #(64) misc_asi_mux(.dout (misc_asi_data[63:0]),
			      .in0  ({29'b0, 
				            tag_asi_data[34:0]}),
			      .in1  ({25'b0, erb_dtu_imask}),
			      .in2  (64'b0),
			      .sel0_l (erc_erd_miscasi_sel_ict_l),
			      .sel1_l (erc_erd_miscasi_sel_imask_l),
			      .sel2_l (erc_erd_miscasi_sel_other_l));

   // Final asi data
   // May need to add a flop to this mux output before sending it to the LSU
   dp_mux4ds #(64) final_asi_mux(.dout (ldxa_data_s),
			       .in0  (tlb_asi_data[63:0]),
			       .in1  (err_asi_data),
			       .in2  (misc_asi_data),
			       .in3  ({30'b0,
				             wsel_erb_asidata_s[0],
				             wsel_erb_asidata_s[33:1]}), 
			       .sel0_l (erc_erd_asisrc_sel_itlb_s_l),
			       .sel1_l (erc_erd_asisrc_sel_err_s_l),
			       .sel2_l (erc_erd_asisrc_sel_misc_s_l),
			       .sel3_l (erc_erd_asisrc_sel_icd_s_l));

   dff_s #(64) ldxa_reg(.din (ldxa_data_s),
                      .q   (ldxa_data_d),
                      .clk (clk), .se(se), .si(), .so());
   assign ifu_lsu_ldxa_data_w2 = ldxa_data_d;

				   
//----------------------------------------
// Error Address
//----------------------------------------   

   assign ifet_addr_f = {ifq_erb_wrtag_f[`IC_TAG_SZ-1:0], 
                         ifq_erb_wrindex_f[`IC_IDX_HI:4]};

   // pc of latest access
   dff_s #(48) pcs1_reg(.din (fdp_erb_pc_f[47:0]),
		                  .q   (pc_s1[47:0]),
		                  .clk (clk), .se(se), .si(), .so());
   
   // Physical address
   assign paddr_s1[39:10] = itlb_ifq_paddr_s[39:10];
   assign paddr_s1[9:4]   = pc_s1[9:4];
   dff_s #(36) padd_reg(.din (paddr_s1[39:4]),
		                  .q   (paddr_d1[39:4]),
		                  .clk (clk), .se(se), .si(), .so());

//   assign erb_ifq_paddr_s[9:0] = pc_s1[9:0];

   // stage PC one more cycle
   dff_s #(44) pcd1_reg(.din (pc_s1[47:4]),
		                  .q   (pc_d1[47:4]),
		                  .clk (clk), .se(se), .si(), .so());

   // IRF address
   dff_s #(16) irf_reg(.din ({exu_ifu_err_reg_m[7:0],
                            exu_ifu_err_synd_m[7:0]}),
		                 .q   ({irfaddr_w[7:5], 
                            irfaddr_4_w,
                            irfaddr_w[3:0],
                            irfsynd_w[7:0]}),
		                 .clk (clk), .se(se), .si(), .so());

   // fix for bug 5594
   // nand2 + xnor
   assign irfaddr_w[4] = irfaddr_4_w ^ (irfaddr_w[5] & irfaddr_w[3]);

   // itlb asi address
   dff_s #(6) itlbidx_reg(.din (tlu_itlb_rw_index_g),
                        .q   (itlb_asi_index),
                        .clk (clk), .se(se), .si(), .so());


   // lsu error address
   dff_s #(44) lsadr_reg(.din (lsu_ifu_err_addr),
                       .q   (lsu_err_addr),
                       .clk (clk), .se(se), .si(), .so());

	  
   // mux in the different error addresses
   // thread 0
   dp_mux4ds #(44) t0_eadr_mx0(.dout  (t0_eadr_mx0_out),
			     .in0   ({24'b0, irfsynd_w[7:0], 4'b0, irfaddr_w[7:0]}),
			     .in1   ({38'b0, itlb_asi_index}),
			     .in2   ({17'b0, ffu_ifu_err_synd_w2[13:7], 
                    1'b0, ffu_ifu_err_synd_w2[6:0], 
                    6'b0, ffu_ifu_err_reg_w2[5:0]}),
			     .in3   (lsu_err_addr),
			     .sel0_l (erc_erd_eadr0_sel_irf_l[0]),
			     .sel1_l (erc_erd_eadr0_sel_itlb_l[0]),
			     .sel2_l (erc_erd_eadr0_sel_frf_l[0]),
			     .sel3_l (erc_erd_eadr0_sel_lsu_l[0]));

   dp_mux4ds #(44) t0_eadr_mx1(.dout  (t0_eadr_mx1_out),
			     .in0   (pc_d1[47:4]),
			     .in1   ({8'b0, paddr_d1[39:4]}),
			     .in2   ({8'b0, ifet_addr_f}),
			     .in3   ({8'b0, spu_ifu_err_addr_w2[39:4]}),
			     .sel0_l (erc_erd_eadr1_sel_pcd1_l[0]),
			     .sel1_l (erc_erd_eadr1_sel_l1pa_l[0]),
			     .sel2_l (erc_erd_eadr1_sel_l2pa_l[0]),
			     .sel3_l (erc_erd_eadr1_sel_other_l[0]));

   dp_mux4ds #(44) t0_eadr_mx2(.dout  (t0_err_addr_nxt),
			     .in0   (t0_eadr_mx0_out),
			     .in1   (t0_eadr_mx1_out),
			     .in2   (ifq_erb_asidata_i2[47:4]),
			     .in3   (t0_err_addr),
			     .sel0_l (erc_erd_eadr2_sel_mx0_l[0]),
			     .sel1_l (erc_erd_eadr2_sel_mx1_l[0]),
			     .sel2_l (erc_erd_eadr2_sel_wrt_l[0]),
			     .sel3_l (erc_erd_eadr2_sel_old_l[0]));

   dff_s #(44) t0_eadr_reg(.din (t0_err_addr_nxt),
		       .q   (t0_err_addr),
		       .clk (clk), .se(se), .si(), .so());

`ifndef CONFIG_NUM_THREADS // Use two threads unless this is defined

   // thread 1
   dp_mux4ds #(44) t1_eadr_mx0(.dout  (t1_eadr_mx0_out),
                 .in0   ({24'b0, irfsynd_w[7:0], 4'b0, irfaddr_w[7:0]}),
                 .in1   ({38'b0, itlb_asi_index}),
                 .in2   ({17'b0, ffu_ifu_err_synd_w2[13:7],
                    1'b0, ffu_ifu_err_synd_w2[6:0],
                    6'b0, ffu_ifu_err_reg_w2[5:0]}),
                 .in3   (lsu_err_addr),
                 .sel0_l (erc_erd_eadr0_sel_irf_l[1]),
                 .sel1_l (erc_erd_eadr0_sel_itlb_l[1]),
                 .sel2_l (erc_erd_eadr0_sel_frf_l[1]),
                 .sel3_l (erc_erd_eadr0_sel_lsu_l[1]));

   dp_mux4ds #(44) t1_eadr_mx1(.dout  (t1_eadr_mx1_out),
                 .in0   (pc_d1[47:4]),
                 .in1   ({8'b0, paddr_d1[39:4]}),
                 .in2   ({8'b0, ifet_addr_f}),
                 .in3   ({8'b0, spu_ifu_err_addr_w2[39:4]}),
//               .in3   ({44'b0}),
                 .sel0_l (erc_erd_eadr1_sel_pcd1_l[1]),
                 .sel1_l (erc_erd_eadr1_sel_l1pa_l[1]),
                 .sel2_l (erc_erd_eadr1_sel_l2pa_l[1]),
                 .sel3_l (erc_erd_eadr1_sel_other_l[1]));

   dp_mux4ds #(44) t1_eadr_mx2(.dout  (t1_err_addr_nxt),
                 .in0   (t1_eadr_mx0_out),
                 .in1   (t1_eadr_mx1_out),
                 .in2   (ifq_erb_asidata_i2[47:4]),
                 .in3   (t1_err_addr),
                 .sel0_l (erc_erd_eadr2_sel_mx0_l[1]),
                 .sel1_l (erc_erd_eadr2_sel_mx1_l[1]),
                 .sel2_l (erc_erd_eadr2_sel_wrt_l[1]),
                 .sel3_l (erc_erd_eadr2_sel_old_l[1]));

   dff_s #(44) t1_eadr_reg(.din (t1_err_addr_nxt),
               .q   (t1_err_addr),
               .clk (clk), .se(se), .si(), .so());

   // asi read
   dp_mux2ds #(44) asi_eadr_mx(.dout (err_addr_asidata),
                 .in0  (t0_err_addr),
                 .in1  (t1_err_addr),
                 .sel0_l (erc_erd_asi_thr_l[0]),
                 .sel1_l (erc_erd_asi_thr_l[1]));

`else // `ifndef CONFIG_NUM_THREADS

`ifdef FPGA_SYN_1THREAD
	assign err_addr_asidata = t0_err_addr;

`elsif THREADS_1

   assign err_addr_asidata = t0_err_addr;

`elsif THREADS_2

   // thread 1
   dp_mux4ds #(44) t1_eadr_mx0(.dout  (t1_eadr_mx0_out),
                 .in0   ({24'b0, irfsynd_w[7:0], 4'b0, irfaddr_w[7:0]}),
                 .in1   ({38'b0, itlb_asi_index}),
                 .in2   ({17'b0, ffu_ifu_err_synd_w2[13:7],
                    1'b0, ffu_ifu_err_synd_w2[6:0],
                    6'b0, ffu_ifu_err_reg_w2[5:0]}),
                 .in3   (lsu_err_addr),
                 .sel0_l (erc_erd_eadr0_sel_irf_l[1]),
                 .sel1_l (erc_erd_eadr0_sel_itlb_l[1]),
                 .sel2_l (erc_erd_eadr0_sel_frf_l[1]),
                 .sel3_l (erc_erd_eadr0_sel_lsu_l[1]));

   dp_mux4ds #(44) t1_eadr_mx1(.dout  (t1_eadr_mx1_out),
                 .in0   (pc_d1[47:4]),
                 .in1   ({8'b0, paddr_d1[39:4]}),
                 .in2   ({8'b0, ifet_addr_f}),
                 .in3   ({8'b0, spu_ifu_err_addr_w2[39:4]}),
//               .in3   ({44'b0}),
                 .sel0_l (erc_erd_eadr1_sel_pcd1_l[1]),
                 .sel1_l (erc_erd_eadr1_sel_l1pa_l[1]),
                 .sel2_l (erc_erd_eadr1_sel_l2pa_l[1]),
                 .sel3_l (erc_erd_eadr1_sel_other_l[1]));

   dp_mux4ds #(44) t1_eadr_mx2(.dout  (t1_err_addr_nxt),
                 .in0   (t1_eadr_mx0_out),
                 .in1   (t1_eadr_mx1_out),
                 .in2   (ifq_erb_asidata_i2[47:4]),
                 .in3   (t1_err_addr),
                 .sel0_l (erc_erd_eadr2_sel_mx0_l[1]),
                 .sel1_l (erc_erd_eadr2_sel_mx1_l[1]),
                 .sel2_l (erc_erd_eadr2_sel_wrt_l[1]),
                 .sel3_l (erc_erd_eadr2_sel_old_l[1]));

   dff_s #(44) t1_eadr_reg(.din (t1_err_addr_nxt),
               .q   (t1_err_addr),
               .clk (clk), .se(se), .si(), .so());

   // asi read
   dp_mux2ds #(44) asi_eadr_mx(.dout (err_addr_asidata),
                 .in0  (t0_err_addr),
                 .in1  (t1_err_addr),
                 .sel0_l (erc_erd_asi_thr_l[0]),
                 .sel1_l (erc_erd_asi_thr_l[1]));

`elsif THREADS_3

   // thread 1
   dp_mux4ds #(44) t1_eadr_mx0(.dout  (t1_eadr_mx0_out),
                 .in0   ({24'b0, irfsynd_w[7:0], 4'b0, irfaddr_w[7:0]}),
                 .in1   ({38'b0, itlb_asi_index}),
                 .in2   ({17'b0, ffu_ifu_err_synd_w2[13:7],
                    1'b0, ffu_ifu_err_synd_w2[6:0],
                    6'b0, ffu_ifu_err_reg_w2[5:0]}),
                 .in3   (lsu_err_addr),
                 .sel0_l (erc_erd_eadr0_sel_irf_l[1]),
                 .sel1_l (erc_erd_eadr0_sel_itlb_l[1]),
                 .sel2_l (erc_erd_eadr0_sel_frf_l[1]),
                 .sel3_l (erc_erd_eadr0_sel_lsu_l[1]));

   dp_mux4ds #(44) t1_eadr_mx1(.dout  (t1_eadr_mx1_out),
                 .in0   (pc_d1[47:4]),
                 .in1   ({8'b0, paddr_d1[39:4]}),
                 .in2   ({8'b0, ifet_addr_f}),
                 .in3   ({8'b0, spu_ifu_err_addr_w2[39:4]}),
//               .in3   ({44'b0}),
                 .sel0_l (erc_erd_eadr1_sel_pcd1_l[1]),
                 .sel1_l (erc_erd_eadr1_sel_l1pa_l[1]),
                 .sel2_l (erc_erd_eadr1_sel_l2pa_l[1]),
                 .sel3_l (erc_erd_eadr1_sel_other_l[1]));

   dp_mux4ds #(44) t1_eadr_mx2(.dout  (t1_err_addr_nxt),
                 .in0   (t1_eadr_mx0_out),
                 .in1   (t1_eadr_mx1_out),
                 .in2   (ifq_erb_asidata_i2[47:4]),
                 .in3   (t1_err_addr),
                 .sel0_l (erc_erd_eadr2_sel_mx0_l[1]),
                 .sel1_l (erc_erd_eadr2_sel_mx1_l[1]),
                 .sel2_l (erc_erd_eadr2_sel_wrt_l[1]),
                 .sel3_l (erc_erd_eadr2_sel_old_l[1]));

   dff_s #(44) t1_eadr_reg(.din (t1_err_addr_nxt),
               .q   (t1_err_addr),
               .clk (clk), .se(se), .si(), .so());

   // thread 2
   dp_mux4ds #(44) t2_eadr_mx0(.dout  (t2_eadr_mx0_out),
                 .in0   ({24'b0, irfsynd_w[7:0], 4'b0, irfaddr_w[7:0]}),
                 .in1   ({38'b0, itlb_asi_index}),
                 .in2   ({17'b0, ffu_ifu_err_synd_w2[13:7],
                    1'b0, ffu_ifu_err_synd_w2[6:0],
                    6'b0, ffu_ifu_err_reg_w2[5:0]}),
                 .in3   (lsu_err_addr),
                 .sel0_l (erc_erd_eadr0_sel_irf_l[2]),
                 .sel1_l (erc_erd_eadr0_sel_itlb_l[2]),
                 .sel2_l (erc_erd_eadr0_sel_frf_l[2]),
                 .sel3_l (erc_erd_eadr0_sel_lsu_l[2]));

   dp_mux4ds #(44) t2_eadr_mx1(.dout  (t2_eadr_mx1_out),
                 .in0   (pc_d1[47:4]),
                 .in1   ({8'b0, paddr_d1[39:4]}),
                 .in2   ({8'b0, ifet_addr_f}),
                 .in3   ({8'b0, spu_ifu_err_addr_w2[39:4]}),
//               .in3   ({44'b0}),
                 .sel0_l (erc_erd_eadr1_sel_pcd1_l[2]),
                 .sel1_l (erc_erd_eadr1_sel_l1pa_l[2]),
                 .sel2_l (erc_erd_eadr1_sel_l2pa_l[2]),
                 .sel3_l (erc_erd_eadr1_sel_other_l[2]));

   dp_mux4ds #(44) t2_eadr_mx2(.dout  (t2_err_addr_nxt),
                 .in0   (t2_eadr_mx0_out),
                 .in1   (t2_eadr_mx1_out),
                 .in2   (ifq_erb_asidata_i2[47:4]),
                 .in3   (t2_err_addr),
                 .sel0_l (erc_erd_eadr2_sel_mx0_l[2]),
                 .sel1_l (erc_erd_eadr2_sel_mx1_l[2]),
                 .sel2_l (erc_erd_eadr2_sel_wrt_l[2]),
                 .sel3_l (erc_erd_eadr2_sel_old_l[2]));

   dff_s #(44) t2_eadr_reg(.din (t2_err_addr_nxt),
               .q   (t2_err_addr),
               .clk (clk), .se(se), .si(), .so());

   // asi read
   dp_mux3ds #(44) asi_eadr_mx(.dout (err_addr_asidata),
                 .in0  (t0_err_addr),
                 .in1  (t1_err_addr),
                 .in2  (t2_err_addr),
                 .sel0_l (erc_erd_asi_thr_l[0]),
                 .sel1_l (erc_erd_asi_thr_l[1]),
                 .sel2_l (erc_erd_asi_thr_l[2]));
   
`else
   // thread 1
   dp_mux4ds #(44) t1_eadr_mx0(.dout  (t1_eadr_mx0_out),
			     .in0   ({24'b0, irfsynd_w[7:0], 4'b0, irfaddr_w[7:0]}),
			     .in1   ({38'b0, itlb_asi_index}),
			     .in2   ({17'b0, ffu_ifu_err_synd_w2[13:7], 
                    1'b0, ffu_ifu_err_synd_w2[6:0], 
                    6'b0, ffu_ifu_err_reg_w2[5:0]}),
			     .in3   (lsu_err_addr),
			     .sel0_l (erc_erd_eadr0_sel_irf_l[1]),
			     .sel1_l (erc_erd_eadr0_sel_itlb_l[1]),
			     .sel2_l (erc_erd_eadr0_sel_frf_l[1]),
			     .sel3_l (erc_erd_eadr0_sel_lsu_l[1]));

   dp_mux4ds #(44) t1_eadr_mx1(.dout  (t1_eadr_mx1_out),
			     .in0   (pc_d1[47:4]),
			     .in1   ({8'b0, paddr_d1[39:4]}),
			     .in2   ({8'b0, ifet_addr_f}),
			     .in3   ({8'b0, spu_ifu_err_addr_w2[39:4]}),
//			     .in3   ({44'b0}),
			     .sel0_l (erc_erd_eadr1_sel_pcd1_l[1]),
			     .sel1_l (erc_erd_eadr1_sel_l1pa_l[1]),
			     .sel2_l (erc_erd_eadr1_sel_l2pa_l[1]),
			     .sel3_l (erc_erd_eadr1_sel_other_l[1]));

   dp_mux4ds #(44) t1_eadr_mx2(.dout  (t1_err_addr_nxt),
			     .in0   (t1_eadr_mx0_out),
			     .in1   (t1_eadr_mx1_out),
			     .in2   (ifq_erb_asidata_i2[47:4]),
			     .in3   (t1_err_addr),
			     .sel0_l (erc_erd_eadr2_sel_mx0_l[1]),
			     .sel1_l (erc_erd_eadr2_sel_mx1_l[1]),
			     .sel2_l (erc_erd_eadr2_sel_wrt_l[1]),
			     .sel3_l (erc_erd_eadr2_sel_old_l[1]));

   dff_s #(44) t1_eadr_reg(.din (t1_err_addr_nxt),
		       .q   (t1_err_addr),
		       .clk (clk), .se(se), .si(), .so());

   // thread 2
   dp_mux4ds #(44) t2_eadr_mx0(.dout  (t2_eadr_mx0_out),
			     .in0   ({24'b0, irfsynd_w[7:0], 4'b0, irfaddr_w[7:0]}),
			     .in1   ({38'b0, itlb_asi_index}),
			     .in2   ({17'b0, ffu_ifu_err_synd_w2[13:7], 
                    1'b0, ffu_ifu_err_synd_w2[6:0], 
                    6'b0, ffu_ifu_err_reg_w2[5:0]}),
			     .in3   (lsu_err_addr),
			     .sel0_l (erc_erd_eadr0_sel_irf_l[2]),
			     .sel1_l (erc_erd_eadr0_sel_itlb_l[2]),
			     .sel2_l (erc_erd_eadr0_sel_frf_l[2]),
			     .sel3_l (erc_erd_eadr0_sel_lsu_l[2]));

   dp_mux4ds #(44) t2_eadr_mx1(.dout  (t2_eadr_mx1_out),
			     .in0   (pc_d1[47:4]),
			     .in1   ({8'b0, paddr_d1[39:4]}),
			     .in2   ({8'b0, ifet_addr_f}),
			     .in3   ({8'b0, spu_ifu_err_addr_w2[39:4]}),
//			     .in3   ({44'b0}),
			     .sel0_l (erc_erd_eadr1_sel_pcd1_l[2]),
			     .sel1_l (erc_erd_eadr1_sel_l1pa_l[2]),
			     .sel2_l (erc_erd_eadr1_sel_l2pa_l[2]),
			     .sel3_l (erc_erd_eadr1_sel_other_l[2]));

   dp_mux4ds #(44) t2_eadr_mx2(.dout  (t2_err_addr_nxt),
			     .in0   (t2_eadr_mx0_out),
			     .in1   (t2_eadr_mx1_out),
			     .in2   (ifq_erb_asidata_i2[47:4]),
			     .in3   (t2_err_addr),
			     .sel0_l (erc_erd_eadr2_sel_mx0_l[2]),
			     .sel1_l (erc_erd_eadr2_sel_mx1_l[2]),
			     .sel2_l (erc_erd_eadr2_sel_wrt_l[2]),
			     .sel3_l (erc_erd_eadr2_sel_old_l[2]));

   dff_s #(44) t2_eadr_reg(.din (t2_err_addr_nxt),
		       .q   (t2_err_addr),
		       .clk (clk), .se(se), .si(), .so());

   // thread 3
   dp_mux4ds #(44) t3_eadr_mx0(.dout  (t3_eadr_mx0_out),
			     .in0   ({24'b0, irfsynd_w[7:0], 4'b0, irfaddr_w[7:0]}),
			     .in1   ({38'b0, itlb_asi_index}),
			     .in2   ({17'b0, ffu_ifu_err_synd_w2[13:7], 
                    1'b0, ffu_ifu_err_synd_w2[6:0], 
                    6'b0, ffu_ifu_err_reg_w2[5:0]}),
			     .in3   (lsu_err_addr),
			     .sel0_l (erc_erd_eadr0_sel_irf_l[3]),
			     .sel1_l (erc_erd_eadr0_sel_itlb_l[3]),
			     .sel2_l (erc_erd_eadr0_sel_frf_l[3]),
			     .sel3_l (erc_erd_eadr0_sel_lsu_l[3]));

   dp_mux4ds #(44) t3_eadr_mx1(.dout  (t3_eadr_mx1_out),
			     .in0   (pc_d1[47:4]),
			     .in1   ({8'b0, paddr_d1[39:4]}),
			     .in2   ({8'b0, ifet_addr_f}),
			     .in3   ({8'b0, spu_ifu_err_addr_w2[39:4]}),
//			     .in3   ({44'b0}),
			     .sel0_l (erc_erd_eadr1_sel_pcd1_l[3]),
			     .sel1_l (erc_erd_eadr1_sel_l1pa_l[3]),
			     .sel2_l (erc_erd_eadr1_sel_l2pa_l[3]),
			     .sel3_l (erc_erd_eadr1_sel_other_l[3]));

   dp_mux4ds #(44) t3_eadr_mx2(.dout  (t3_err_addr_nxt),
			     .in0   (t3_eadr_mx0_out),
			     .in1   (t3_eadr_mx1_out),
			     .in2   (ifq_erb_asidata_i2[47:4]),
			     .in3   (t3_err_addr),
			     .sel0_l (erc_erd_eadr2_sel_mx0_l[3]),
			     .sel1_l (erc_erd_eadr2_sel_mx1_l[3]),
			     .sel2_l (erc_erd_eadr2_sel_wrt_l[3]),
			     .sel3_l (erc_erd_eadr2_sel_old_l[3]));

   dff_s #(44) t3_eadr_reg(.din (t3_err_addr_nxt),
		       .q   (t3_err_addr),
		       .clk (clk), .se(se), .si(), .so());


   // asi read
   dp_mux4ds #(44) asi_eadr_mx(.dout (err_addr_asidata),
			     .in0  (t0_err_addr),
			     .in1  (t1_err_addr),
			     .in2  (t2_err_addr),
			     .in3  (t3_err_addr),
			     .sel0_l (erc_erd_asi_thr_l[0]),
			     .sel1_l (erc_erd_asi_thr_l[1]),
			     .sel2_l (erc_erd_asi_thr_l[2]),
			     .sel3_l (erc_erd_asi_thr_l[3]));
`endif

`endif // `ifndef CONFIG_NUM_THREADS
   
   // Instruction Mask
   dp_mux2es #(39) imask_en_mux(.dout (imask_next),
			      .in0  (erb_dtu_imask),
			      .in1  (ifq_erb_asidata_i2[38:0]),
			      .sel  (erc_erd_ld_imask));

   // need to reset top 7 bits only
   dffr_s #(39) imask_reg(.din (imask_next),
		      .q   (erb_dtu_imask),
		      .rst (erb_reset),
		      .clk (clk), .se(se), .si(), .so());

   sink #(4) s0(.in (pc_s1[3:0]));
   
endmodule // sparc_ifu_erb


// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: lsu_qctl2.v
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



/////////////////////////////////////////////////////////////////////
/*
//  Description:  LSU Queue Control for Sparc Core  
//      - includes monitoring for pcx queues
//      - control for lsu datapath
//      - rd/wr control of dfq 
//
*/
////////////////////////////////////////////////////////////////////////
// header file includes
////////////////////////////////////////////////////////////////////////
`include  "sys.h" // system level definition file which contains the 
                  // time scale definition
`include  "iop.h" 

`include  "lsu.tmp.h" 

////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

module lsu_qctl2 ( /*AUTOARG*/
   // Outputs
   so, lsu_fwd_rply_sz1_unc, lsu_dcache_iob_rd_w, ldd_in_dfq_out, 
   lsu_dfq_rd_vld_d1, dfq_byp_ff_en, lsu_dfill_data_sel_hi, 
   lsu_ifill_pkt_vld, cpx_fwd_pkt_en_cx, lsu_cpxpkt_type_dcd_cx, 
   lsu_cpu_dcd_sel, lsu_cpu_uhlf_sel, lsu_iobrdge_rply_data_sel, 
   lsu_iobrdge_fwd_pkt_vld, lsu_tlu_cpx_vld, lsu_tlu_cpx_req, 
   lsu_tlu_intpkt, ld_sec_active, dfq_byp_sel, 
   lsu_cpx_ld_dtag_perror_e, lsu_cpx_ld_dcache_perror_e, 
   lsu_exu_rd_m, lsu_spu_strm_ack_cmplt, lsu_atm_st_cmplt_e, 
   dva_svld_e, dfq_wptr_vld, dfq_wptr, lsu_dfq_flsh_cmplt, 
   dfq_rptr_vld, dfq_rptr, lsu_ifu_stallreq, dva_snp_addr_e, 
   lsu_st_ack_dq_stb, lsu_cpx_rmo_st_ack, lsu_st_wr_dcache, 
   cpx_st_ack_tid0, cpx_st_ack_tid1, cpx_st_ack_tid2, 
   cpx_st_ack_tid3, lsu_tlu_l2_dmiss, lsu_l2fill_vld, 
   lsu_byp_ldd_oddrd_m, lsu_pcx_fwd_reply, lsu_fwdpkt_vld, 
   lsu_dcfill_active_e, lsu_dfq_ld_vld, lsu_fldd_vld_en, 
   lsu_dfill_dcd_thrd, lsu_fwdpkt_dest, dva_snp_bit_wr_en_e, 
   lsu_cpx_spc_inv_vld, lsu_cpx_thrdid, lsu_cpx_stack_dcfill_vld, 
   lsu_dfq_vld_entry_w, lsu_cpx_stack_icfill_vld, lsu_dfq_st_vld, 
   lsu_dfq_ldst_vld, lsu_qdp2_dfq_ld_vld, lsu_qdp2_dfq_st_vld, 
   lsu_cpx_stack_dcfill_vld_b130, lsu_dfq_vld, lsu_dfq_byp_ff_en, 
   // Inputs
   rclk, grst_l, arst_l, si, se, rst_tri_en, ld_inst_vld_e, 
   ifu_pcx_pkt_b51, ifu_pcx_pkt_b41t40, ifu_pcx_pkt_b10t5, 
   lsu_dfq_rdata_flush_bit, lsu_dfq_rdata_b17_b0, 
   cpx_spc_data_cx_b144to140, cpx_spc_data_cx_b138, 
   cpx_spc_data_cx_b135to134, 
   cpx_spc_data_cx_b133, cpx_spc_data_cx_b130, cpx_spc_data_cx_b129, 
   cpx_spc_data_cx_b128, cpx_spc_data_cx_b125, 
   cpx_spc_data_cx_b124to123, cpx_spc_data_cx_b120to118, 

   cpx_spc_data_cx_b71to70, 
   // cpx_spc_data_cx_b0, cpx_spc_data_cx_b4, 
   // cpx_spc_data_cx_b8, cpx_spc_data_cx_b12, cpx_spc_data_cx_b16, 
   // cpx_spc_data_cx_b20, cpx_spc_data_cx_b24, cpx_spc_data_cx_b28, 
   // cpx_spc_data_cx_b32, cpx_spc_data_cx_b35, cpx_spc_data_cx_b38, 
   // cpx_spc_data_cx_b41, cpx_spc_data_cx_b44, cpx_spc_data_cx_b47, 
   // cpx_spc_data_cx_b50, cpx_spc_data_cx_b53, cpx_spc_data_cx_b56, 
   // cpx_spc_data_cx_b60, cpx_spc_data_cx_b64, cpx_spc_data_cx_b68, 
   // cpx_spc_data_cx_b72, cpx_spc_data_cx_b76, cpx_spc_data_cx_b80, 
   // cpx_spc_data_cx_b84, cpx_spc_data_cx_b88, cpx_spc_data_cx_b91, 
   // cpx_spc_data_cx_b94, cpx_spc_data_cx_b97, cpx_spc_data_cx_b100, 
   cpx_spc_data_cx_b103,
   // cpx_spc_data_cx_b106, cpx_spc_data_cx_b109, 
   // cpx_spc_data_cx_b1, cpx_spc_data_cx_b5, cpx_spc_data_cx_b9, 
   // cpx_spc_data_cx_b13, cpx_spc_data_cx_b17, cpx_spc_data_cx_b21, 
   // cpx_spc_data_cx_b25, cpx_spc_data_cx_b29, cpx_spc_data_cx_b57, 
   // cpx_spc_data_cx_b61, cpx_spc_data_cx_b65, cpx_spc_data_cx_b69, 
   // cpx_spc_data_cx_b73, cpx_spc_data_cx_b77, cpx_spc_data_cx_b81, 
   // cpx_spc_data_cx_b85, 

   cpx_spc_data_cx_dcache_inval_val,
   cpx_spc_data_cx_icache_inval_val,

   ifu_lsu_rd_e, lmq_ld_rd1, lmq_ldd_vld, 
   dfq_tid, const_cpuid, lmq_ld_addr_b3, ifu_lsu_ibuf_busy, 
   ifu_lsu_inv_clear, lsu_byp_misc_sz_e, lsu_dfq_byp_tid, 
   lsu_cpx_pkt_atm_st_cmplt, lsu_cpx_pkt_l2miss, lsu_cpx_pkt_tid, 
   lsu_cpx_pkt_invwy, lsu_dfq_byp_flush, lsu_dfq_byp_type, 
   lsu_dfq_byp_invwy_vld, 
   // lsu_cpu_inv_data_b13to9, 
   // lsu_cpu_inv_data_b7to2, 
   // lsu_cpu_inv_data_b0, 
   lsu_cpu_inv_data_val, lsu_cpu_inv_data_way,
   lsu_cpx_pkt_inv_pa, 
   lsu_cpx_pkt_ifill_type, lsu_cpx_pkt_atomic, lsu_cpx_pkt_binit_st, 
   lsu_cpx_pkt_prefetch, lsu_dfq_byp_binit_st, lsu_tlbop_force_swo, 
   lsu_iobrdge_tap_rq_type, lsu_dcache_tag_perror_g, 
   lsu_dcache_data_perror_g, lsu_cpx_pkt_perror_iinv, 
   lsu_cpx_pkt_perror_dinv, lsu_cpx_pkt_perror_set, 
   lsu_l2fill_fpld_e, lsu_cpx_pkt_strm_ack, ifu_lsu_memref_d, 
   lsu_fwdpkt_pcx_rq_sel, lsu_imiss_pcx_rq_sel_d1, 
   lsu_dfq_byp_cpx_inv, lsu_dfq_byp_stack_adr_b54, 
   lsu_dfq_byp_stack_wrway, lsu_dfq_rdata_st_ack_type, 
   lsu_dfq_rdata_stack_dcfill_vld, lsu_dfq_rdata_stack_iinv_vld, 
   lsu_dfq_rdata_cpuid, lsu_dfq_byp_atm, lsu_ld_inst_vld_g, 
   lsu_dfq_rdata_type, lsu_dfq_rdata_invwy_vld, ifu_lsu_fwd_data_vld, 
   ifu_lsu_fwd_wr_ack, lsu_dfq_rdata_rq_type, lsu_dfq_rdata_b103, 
   sehold
   ) ;  


input     rclk ;
input     grst_l;
input     arst_l;
input     si;
input     se;
input     rst_tri_en;
output    so;

input                   ld_inst_vld_e;        // valid ld inst; d-stage
input                   ifu_pcx_pkt_b51;        // pcx pkt from ifu on imiss
input [1:0]             ifu_pcx_pkt_b41t40;     // pcx pkt from ifu on imiss
input [5:0]             ifu_pcx_pkt_b10t5;      // pcx pkt from ifu on imiss
//input                   cpx_spc_data_rdy_cx ;   // data ready to processor
//input [`CPX_WIDTH-1:71] cpx_spc_data_cx ;       // cpx to processor packet
//input [`CPX_WIDTH-1:0] cpx_spc_data_cx ;       // cpx to processor packet
//input [17:0]            cpx_spc_data_b17t0_cx ; // cpx to processor packet
   input                lsu_dfq_rdata_flush_bit;
   input [17:0]         lsu_dfq_rdata_b17_b0;
   
input [`CPX_WIDTH-1:140] cpx_spc_data_cx_b144to140 ;       // vld, req type
input                   cpx_spc_data_cx_b138 ;  
//input                   cpx_spc_data_cx_b136 ;  
input [`CPX_TH_HI:`CPX_TH_LO] cpx_spc_data_cx_b135to134 ;  // thread id
input                   cpx_spc_data_cx_b133 ;  
input                   cpx_spc_data_cx_b130 ;  
input                   cpx_spc_data_cx_b129 ;  
input                   cpx_spc_data_cx_b128 ;  
input                   cpx_spc_data_cx_b125 ;  
input [`CPX_PERR_DINV+1:`CPX_PERR_DINV] cpx_spc_data_cx_b124to123 ;  // inv packet iinv,dinv
input [`CPX_INV_CID_HI:`CPX_INV_CID_LO] cpx_spc_data_cx_b120to118 ;  // inv packet cpu id
input [1:0]             cpx_spc_data_cx_b71to70 ;  

// input        cpx_spc_data_cx_b0 ;
// input        cpx_spc_data_cx_b4 ;
// input        cpx_spc_data_cx_b8 ;
// input        cpx_spc_data_cx_b12 ;
// input        cpx_spc_data_cx_b16 ;
// input        cpx_spc_data_cx_b20 ;
// input        cpx_spc_data_cx_b24 ;
// input        cpx_spc_data_cx_b28 ;

// input        cpx_spc_data_cx_b32 ;
// input        cpx_spc_data_cx_b35 ;
// input        cpx_spc_data_cx_b38 ;
// input        cpx_spc_data_cx_b41 ;
// input        cpx_spc_data_cx_b44 ;
// input        cpx_spc_data_cx_b47 ;
// input        cpx_spc_data_cx_b50 ;
// input        cpx_spc_data_cx_b53 ;

// input        cpx_spc_data_cx_b56 ;
// input        cpx_spc_data_cx_b60 ;
// input        cpx_spc_data_cx_b64 ;
// input        cpx_spc_data_cx_b68 ;
// input        cpx_spc_data_cx_b72 ;
// input        cpx_spc_data_cx_b76 ;
// input        cpx_spc_data_cx_b80 ;
// input        cpx_spc_data_cx_b84 ;

// input        cpx_spc_data_cx_b88 ;
// input        cpx_spc_data_cx_b91 ;
// input        cpx_spc_data_cx_b94 ;
// input        cpx_spc_data_cx_b97 ;
// input        cpx_spc_data_cx_b100 ;
input        cpx_spc_data_cx_b103 ;
// input        cpx_spc_data_cx_b106 ;
// input        cpx_spc_data_cx_b109 ;

// input        cpx_spc_data_cx_b1 ;
// input        cpx_spc_data_cx_b5 ;
// input        cpx_spc_data_cx_b9 ;
// input        cpx_spc_data_cx_b13 ;
// input        cpx_spc_data_cx_b17 ;
// input        cpx_spc_data_cx_b21 ;
// input        cpx_spc_data_cx_b25 ;
// input        cpx_spc_data_cx_b29 ;

// input        cpx_spc_data_cx_b57 ;
// input        cpx_spc_data_cx_b61 ;
// input        cpx_spc_data_cx_b65 ;
// input        cpx_spc_data_cx_b69 ;
// input        cpx_spc_data_cx_b73 ;
// input        cpx_spc_data_cx_b77 ;
// input        cpx_spc_data_cx_b81 ;
// input        cpx_spc_data_cx_b85 ;
input       cpx_spc_data_cx_dcache_inval_val;
input       cpx_spc_data_cx_icache_inval_val;

input [4:0]             ifu_lsu_rd_e ;          // rd for current load request.
//input                   lsu_ld_miss_g ;         // load misses in dcache.
input  [4:0]            lmq_ld_rd1 ;            // rd for all loads
input                   lmq_ldd_vld ;           // ld double   
//input                   ld_stb_full_raw_g ;    // full raw for load - thread0
//input                   ld_stb_partial_raw_g ; // partial raw for load - thread0
/*
input                   ld_sec_hit_thrd0 ;      // ld has sec. hit against th0
input                   ld_sec_hit_thrd1 ;      // ld has sec. hit against th1
input                   ld_sec_hit_thrd2 ;      // ld has sec. hit against th2
input                   ld_sec_hit_thrd3 ;      // ld has sec. hit against th3
*/
input   [1:0]           dfq_tid ;               // thread-id for load at head of DFQ. 
//input   [1:0]           dfq_byp_tid ;           // in-flight thread-id for load at head of DFQ. 
//input                   ldxa_internal ;         // internal ldxa, stg g 
//input [3:0]             ld_thrd_byp_sel ;       // stb,ldxa thread byp sel
input [2:0]             const_cpuid ;           // cpu id
input                   lmq_ld_addr_b3 ;        // bit3 of addr at head of queue.
//input                   ifu_tlu_inst_vld_m ;    // inst is vld - wstage
//input                   tlu_ifu_flush_pipe_w ;  // flush event in wstage
//input                   lsu_ldstub_g ;          // ldstub(a) instruction
//input                   lsu_swap_g ;            // swap(a) instruction 
//input                   tlu_lsu_pcxpkt_vld ;
//input [11:10]           tlu_lsu_pcxpkt_l2baddr ;
//input [19:18]           tlu_lsu_pcxpkt_tid ;
input                   ifu_lsu_ibuf_busy ;
input                   ifu_lsu_inv_clear ;
input   [1:0]           lsu_byp_misc_sz_e ;     // size for ldxa/raw etc
input   [1:0]           lsu_dfq_byp_tid ;
input                   lsu_cpx_pkt_atm_st_cmplt ;
input                   lsu_cpx_pkt_l2miss ;
input   [1:0]           lsu_cpx_pkt_tid ;
input   [`L1D_WAY_MASK]           lsu_cpx_pkt_invwy ;     // invalidate way
input                   lsu_dfq_byp_flush ;
input   [5:0]           lsu_dfq_byp_type ;
input                   lsu_dfq_byp_invwy_vld ;
//input   [13:0]          lsu_cpu_inv_data ;

// input   [13:9]          lsu_cpu_inv_data_b13to9 ;
// input   [7:2]           lsu_cpu_inv_data_b7to2 ;
// input                   lsu_cpu_inv_data_b0 ;
input                        lsu_cpu_inv_data_val ;
input  [`L1D_WAY_WIDTH-1:0]  lsu_cpu_inv_data_way ;

//input   [2:0]           lsu_dfq_byp_cpuid ;
input   [`L1D_ADDRESS_HI-6:0]           lsu_cpx_pkt_inv_pa ;    // invalidate pa [10:6]
input                   lsu_cpx_pkt_ifill_type ;
//input                   stb_cam_hit ; REMOVED
input                   lsu_cpx_pkt_atomic ;
//input                   lsu_dfq_byp_stquad_pkt2 ;
//input                   lsu_cpx_pkt_stquad_pkt2 ;
input                   lsu_cpx_pkt_binit_st ;
input                   lsu_cpx_pkt_prefetch ;
input                   lsu_dfq_byp_binit_st ;
//input   [3:0]           lsu_stb_empty ;
input                   lsu_tlbop_force_swo ;
input   [7:3]           lsu_iobrdge_tap_rq_type ; 
input                   lsu_dcache_tag_perror_g ;  // dcache tag parity error
input                   lsu_dcache_data_perror_g ; // dcache data parity error
//input                   lsu_dfq_byp_perror_dinv ;  // dtag perror corr. st ack
//input                   lsu_dfq_byp_perror_iinv ;  // itag perror corr. st ack


input                   lsu_cpx_pkt_perror_iinv ;   // itag perror corr. st ack
input                   lsu_cpx_pkt_perror_dinv ;   // dtag perror corr. st ack
input   [1:0]           lsu_cpx_pkt_perror_set ;   // dtag perror - spec. b54
//input                   lsu_diagnstc_wr_src_sel_e ;// dcache/dtag/vld
input         		lsu_l2fill_fpld_e ;      // fp load
input                   lsu_cpx_pkt_strm_ack ;
   
input                   ifu_lsu_memref_d ;
//input   [3:0]           lmq_enable;
//input   [3:0]           ld_pcx_rq_sel ;
input                   lsu_fwdpkt_pcx_rq_sel ;
//input                   lsu_ld0_pcx_rq_sel_d1, lsu_ld1_pcx_rq_sel_d1 ;
//input                   lsu_ld2_pcx_rq_sel_d1, lsu_ld3_pcx_rq_sel_d1 ;
input                   lsu_imiss_pcx_rq_sel_d1 ;

//input                   lsu_dc_iob_access_e;

//   input                mbist_dcache_write;
//   input                mbist_dcache_read;
   

input                   lsu_dfq_byp_cpx_inv ;
//input			lsu_dfq_byp_stack_dcfill_vld ;
input  [1:0]            lsu_dfq_byp_stack_adr_b54;
input  [1:0]            lsu_dfq_byp_stack_wrway;

input                   lsu_dfq_rdata_st_ack_type;
input                   lsu_dfq_rdata_stack_dcfill_vld;

input                   lsu_dfq_rdata_stack_iinv_vld;

input  [2:0]            lsu_dfq_rdata_cpuid;

input                   lsu_dfq_byp_atm;

input	[3:0]		lsu_ld_inst_vld_g ;

input	[5:0]		lsu_dfq_rdata_type ;
input			lsu_dfq_rdata_invwy_vld ;

input			ifu_lsu_fwd_data_vld ; // icache ramtest read cmplt
input			ifu_lsu_fwd_wr_ack ;   // icache ramtest wr cmplt

input	[3:0]		lsu_dfq_rdata_rq_type ;
input                   lsu_dfq_rdata_b103 ;

input                   sehold ;

output 			lsu_fwd_rply_sz1_unc ;
output			lsu_dcache_iob_rd_w ;

output     		ldd_in_dfq_out;
   
output                  lsu_dfq_rd_vld_d1 ;
output                  dfq_byp_ff_en ;
output                  lsu_dfill_data_sel_hi;// select hi or low order 8B. 
output                  lsu_ifill_pkt_vld ;   // ifill pkt vld
output                  cpx_fwd_pkt_en_cx ;
output  [5:0]           lsu_cpxpkt_type_dcd_cx ;
output  [7:0]           lsu_cpu_dcd_sel ;
output                  lsu_cpu_uhlf_sel ;
//output                  lsu_st_wr_sel_e ;
//output  [1:0]           lsu_st_ack_addr_b54 ;
//output  [1:0]           lsu_st_ack_wrwy ;       // cache set way to write to.

output  [2:0]           lsu_iobrdge_rply_data_sel ;
output                  lsu_iobrdge_fwd_pkt_vld ;
output                  lsu_tlu_cpx_vld;    // cpx pkt vld
output  [3:0]           lsu_tlu_cpx_req;    // cpx pkt rq type
output  [17:0]          lsu_tlu_intpkt;     // cpx interrupt pkt
//output                  lsu_tlu_pcxpkt_ack; // ack for intr pkt.
//output  [3:0]           lsu_intrpt_cmplt ;      // intrpt can restart thread
//output                  lsu_ld_sec_hit_l2access_g ;
//output  [1:0]           lsu_ld_sec_hit_wy_g ;
output                  ld_sec_active ;     // secondary bypassing
output  [3:0]           dfq_byp_sel ;
//output  [3:0]           lsu_dfq_byp_mxsel ; // to qdp1
//output  [3:0]           lmq_byp_misc_sel ;    // select g-stage lmq source
//output                  lsu_pcx_ld_dtag_perror_w2 ;
output                  lsu_cpx_ld_dtag_perror_e ;
output                  lsu_cpx_ld_dcache_perror_e ;
//output  [1:0]           lsu_cpx_atm_st_err ;
//output                  lsu_ignore_fill ;
//output  [4:0]           lsu_exu_rd_w2 ;
output  [4:0]           lsu_exu_rd_m ;
output  [1:0]           lsu_spu_strm_ack_cmplt ;
output	           	lsu_atm_st_cmplt_e ;  // atm st ack will restart thread
output                  dva_svld_e ;        // snoop is valid
output                  dfq_wptr_vld ;          // write pointer valid
output  [4:0]           dfq_wptr ;              // encoded write pointer
output  [3:0]           lsu_dfq_flsh_cmplt ;
output                  dfq_rptr_vld ;          // read pointer valid
output  [4:0]           dfq_rptr ;              // encoded read pointer
output                  lsu_ifu_stallreq ;      // cfq has crossed high-water mark
output  [`L1D_ADDRESS_HI-6:0]           dva_snp_addr_e;         // Upper 5b of cache set index PA[10:6]
//output  [3:0]           dva_snp_set_vld_e;      // Lower 2b of cache set index - decoded
//output  [1:0]           dva_snp_wy0_e ;         // way for addr<5:4>=00
//output  [1:0]           dva_snp_wy1_e ;         // way for addr<5:4>=01
//output  [1:0]           dva_snp_wy2_e ;         // way for addr<5:4>=10
//output  [1:0]           dva_snp_wy3_e ;         // way for addr<5:4>=11
//output  [3:0]           lsu_st_ack_rq_stb ;
output  [3:0]           lsu_st_ack_dq_stb ;
output  [3:0]           lsu_cpx_rmo_st_ack ;    // rmo ack clears
output                  lsu_st_wr_dcache ;
output                  cpx_st_ack_tid0 ;   // st ack for thread0
output                  cpx_st_ack_tid1 ;   // st ack for thread1
output                  cpx_st_ack_tid2 ;   // st ack for thread2
output                  cpx_st_ack_tid3 ;   // st ack for thread3
output  [3:0]           lsu_tlu_l2_dmiss ;       // performance cntr
//output  [3:0]           lsu_ifu_stq_busy ;         // thread is busy with 1 stq - not used
output                  lsu_l2fill_vld ;        // dfill data vld
output                  lsu_byp_ldd_oddrd_m ; // rd fill for non-alt ldd
output                  lsu_pcx_fwd_reply ;   // fwd reply on pcx pkt
//output                  lsu_intrpt_pkt_vld ;
output                  lsu_fwdpkt_vld;
//output  [3:0]           lsu_error_rst ;
output                  lsu_dcfill_active_e;	// not same as dcfill_active_e; qual'ed w/ ignore_fill
//output                  lsu_dfq_byp_vld ;
output                  lsu_dfq_ld_vld;
output                  lsu_fldd_vld_en;
output  [3:0]           lsu_dfill_dcd_thrd ;
output  [4:0]           lsu_fwdpkt_dest ;
//output                  dcfill_src_dfq_sel ;    // ld-inv is src
output [`L1D_VAL_ARRAY_HI:0]        dva_snp_bit_wr_en_e;

//output [3:0]         lsu_dcfill_mx_sel_e;
//output               lsu_dcfill_addr_mx_sel_e;
//output               lsu_dcfill_data_mx_sel_e;
//output               lsu_dcfill_size_mx_sel_e;

output               lsu_cpx_spc_inv_vld;  // dfq write data in[152]
output [3:0]         lsu_cpx_thrdid;
output               lsu_cpx_stack_dcfill_vld ;

//output	[3:0]		lsu_dtag_perror_w2 ;

output  		lsu_dfq_vld_entry_w ;

output  		lsu_cpx_stack_icfill_vld ;

output                  lsu_dfq_st_vld;
output                  lsu_dfq_ldst_vld;
   //pref counter
//   output [3:0] lsu_cpx_pref_ack;

output                  lsu_qdp2_dfq_ld_vld;
output                  lsu_qdp2_dfq_st_vld;

output                  lsu_cpx_stack_dcfill_vld_b130;
   
output  		lsu_dfq_vld ;

output                  lsu_dfq_byp_ff_en ;

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
// End of automatics


wire        cpx_local_st_ack_type ;
wire  [3:0] cpx_pkt_thrd_sel ;
//wire  [3:0] tap_thread ;
wire      cpx_reverse_req , cpx_reverse_req_d1 ;
wire    cpx_fwd_req,cpx_fwd_reply;
wire    fwdpkt_reset ;
wire        dfq_inv_vld ;
//wire    intrpt_vld_reset ;
//wire    intrpt_vld_en ;
//wire    ld0_sec_hit_g,ld1_sec_hit_g,ld2_sec_hit_g,ld3_sec_hit_g;
//wire  [3:0] intrpt_thread ;
wire    dfq_byp_ld_vld ;
//wire    intrpt_clr ;
wire    dfq_rptr_vld_d1 ;
wire    dfq_rd_advance ;
wire        dfq_wr_en, dfq_byp_full, dcfill_active_e ;
wire    dfq_thread0,dfq_thread1,dfq_thread2,dfq_thread3;
//wire    ld_any_thrd_byp_sel ;
wire    stwr_active_e,stdq_active_e ;
wire  [3:0] error_en ;
wire        ldd_vld_reset, ldd_vld_en, ldd_in_dfq_out ;
wire    ldd_non_alt_space ;
wire    ldd_oddrd_e ;
wire        inv_active_e ;
wire    dfq_st_vld ;
//wire    local_inv ;
wire    dfq_local_inv ;
//wire    st_ack_rq_stb_d1 ;
//wire    cpx_inv ;
wire    dfq_byp_inv_vld ;
wire    dfq_invwy_vld;
wire    local_pkt ;
wire    dfq_byp_st_vld ;
wire        dfq_vld_reset, dfq_vld_en ;
//wire  [3:0] st_wrwy_sel ;
//wire  [13:0]  cpx_cpu_inv_data ;
wire        dfq_vld_entry_exists ;
wire    cpx_st_ack_type,cpx_strm_st_ack_type,cpx_int_type;
wire    cpx_ld_type,cpx_ifill_type,cpx_evict_type;
wire  [5:0]     dfq_wptr_new_w_wrap ;   // 5b ptr with wrap bit.
wire  [5:0]     dfq_rptr_new_w_wrap ;   // 5b ptr with wrap bit.
wire  [5:0]     dfq_wptr_w_wrap ;   // 5b ptr with wrap bit.
//wire    i_and_d_codepend ;
wire    dfq_ld_type,dfq_ifill_type,dfq_evict_type ;
wire    dfq_st_ack_type,dfq_strm_st_ack_type,dfq_int_type;
wire  [5:0]     dfq_rptr_w_wrap ;   // 3b ptr with wrap bit.
wire  [3:0]   imiss_dcd_b54 ;
//wire    st_ack_rq_stb ;
//wire  [1:0] st_ack_tid ;
wire  [3:0] cpu_sel ;
wire  [1:0] fwdpkt_l2bnk_addr ;
//wire  [2:0] intrpt_l2bnk_addr ;
//wire  [3:0] dfq_byp_sel_m, dfq_byp_sel_g ;
//wire  [1:0] ld_error0,ld_error1,ld_error2,ld_error3 ;
//wire  [4:0] ld_l1hit_rd_m,ld_l1hit_rd_g;
wire  [4:0] ld_l1hit_rd_m;
//wire  [13:0]  dfq_inv_data ;
// wire  [13:9]  dfq_inv_data_b13to9 ;
// wire  [7:2]   dfq_inv_data_b7to2 ;
// wire          dfq_inv_data_b0 ;
wire                        dfq_inv_data_val ;
wire  [`L1D_WAY_WIDTH-1:0]  dfq_inv_data_way ;
wire          fwdpkt_vld;
wire  [3:0]   dfill_dcd_thrd ;
wire  [3:0]   error_rst ;
wire          dfq_ld_vld;
wire          dfq_byp_vld ;
wire          reset;
wire          st_rd_advance;
wire	vld_dfq_pkt ;
wire          dfq_vld_entry_exists_w;
wire          dfq_rdata_local_pkt;
wire 	      dfq_st_cmplt ;
wire          cpx_fp_type ;
wire	dfq_stall, dfq_stall_d1 ;
wire          cpx_error_type ;
wire          dfq_error_type ;
wire          cpx_fwd_req_ic ;
wire          dfq_fwd_req_ic_type ;
wire          dfq_rd_vld_d1 ;


    wire dbb_reset_l;
    wire clk;
    dffrl_async rstff(.din (grst_l),
                        .q   (dbb_reset_l),
                        .clk (clk), .se(se), .si(), .so(),
                        .rst_l (arst_l));

assign  reset  =  ~dbb_reset_l;
assign  clk = rclk;



//wire                   lsu_bist_wvld_e;
//wire                   lsu_bist_rvld_e;

//dff #(2) mbist_stge (
//   .din ({mbist_dcache_write, mbist_dcache_read}),
//   .q   ({lsu_bist_wvld_e,    lsu_bist_rvld_e  }),
//   .clk (clk),
//   .se  (1'b0),       .si (),          .so ()
//);   
   
//=================================================================================================
// SHADOW SCAN
//=================================================================================================

// Monitors whether there is a valid entry in the dfq.
assign	lsu_dfq_vld_entry_w = dfq_vld_entry_exists_w ;
// Monitors whether dfq_byp flop remains full
//assign	lsu_sscan_data[?] = dfq_byp_full ;
   
//=================================================================================================
//
// QDP2 Specific Control
//
//=================================================================================================

// Need to be careful. This may prevent stores
//assign  dcfill_src_dfq_sel = dcfill_active_e ;





//=================================================================================================
//  IMISS X-INVALIDATION
//=================================================================================================

// Assume all imisses are alligned to a 32B boundary in L2 ?
// trin note: in piton, xinval is not used

wire  imiss0_inv_en, imiss1_inv_en ;
wire  imiss2_inv_en, imiss3_inv_en ;
wire  [10:5] imiss0_set_index,imiss1_set_index ;
wire  [10:5] imiss2_set_index,imiss3_set_index ;
//8/28/03 - vlint cleanup
//wire  [10:4] imiss0_set_index,imiss1_set_index ;
//wire  [10:4] imiss2_set_index,imiss3_set_index ;

assign  imiss0_inv_en = ifu_pcx_pkt_b51 & ~ifu_pcx_pkt_b41t40[1] & ~ifu_pcx_pkt_b41t40[0] & lsu_imiss_pcx_rq_sel_d1 ;
assign  imiss1_inv_en = ifu_pcx_pkt_b51 & ~ifu_pcx_pkt_b41t40[1] &  ifu_pcx_pkt_b41t40[0] & lsu_imiss_pcx_rq_sel_d1 ;
assign  imiss2_inv_en = ifu_pcx_pkt_b51 &  ifu_pcx_pkt_b41t40[1] & ~ifu_pcx_pkt_b41t40[0] & lsu_imiss_pcx_rq_sel_d1 ;
assign  imiss3_inv_en = ifu_pcx_pkt_b51 &  ifu_pcx_pkt_b41t40[1] &  ifu_pcx_pkt_b41t40[0] & lsu_imiss_pcx_rq_sel_d1 ;

dffe_s #(6) imiss_inv0 (
        .din    ({ifu_pcx_pkt_b10t5[5:0]}),
        .q      ({imiss0_set_index[10:5]}),
        .en (imiss0_inv_en),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        );

dffe_s #(6) imiss_inv1 (
        .din    ({ifu_pcx_pkt_b10t5[5:0]}),
        .q      ({imiss1_set_index[10:5]}),
        .en (imiss1_inv_en),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        );

dffe_s #(6) imiss_inv2 (
        .din    ({ifu_pcx_pkt_b10t5[5:0]}),
        .q      ({imiss2_set_index[10:5]}),
        .en (imiss2_inv_en),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        );

dffe_s #(6) imiss_inv3 (
        .din    ({ifu_pcx_pkt_b10t5[5:0]}),
        .q      ({imiss3_set_index[10:5]}),
        .en (imiss3_inv_en),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        );

assign  cpx_pkt_thrd_sel[0] = ~lsu_cpx_pkt_tid[1] & ~lsu_cpx_pkt_tid[0] ;
assign  cpx_pkt_thrd_sel[1] = ~lsu_cpx_pkt_tid[1] &  lsu_cpx_pkt_tid[0] ;
assign  cpx_pkt_thrd_sel[2] =  lsu_cpx_pkt_tid[1] & ~lsu_cpx_pkt_tid[0] ;
assign  cpx_pkt_thrd_sel[3] =  lsu_cpx_pkt_tid[1] &  lsu_cpx_pkt_tid[0] ;
// This needs to be included once the change for the stb bug is complete
wire  [6:1] imiss_inv_set_index ;
assign  imiss_inv_set_index[6:1] =
  cpx_pkt_thrd_sel[0] ? imiss0_set_index[10:5] : 
    cpx_pkt_thrd_sel[1] ? imiss1_set_index[10:5] : 
      cpx_pkt_thrd_sel[2] ? imiss2_set_index[10:5] : 
        cpx_pkt_thrd_sel[3] ? imiss3_set_index[10:5] : 6'bxx_xxxx ;  



//=================================================================================================
//  FWD REPLY/REQUEST
//=================================================================================================

// cpx pkt decode. fwd req/reply do not go into dfq.


//assign  tap_thread[0] = ~lsu_iobrdge_tap_rq_type[1] & ~lsu_iobrdge_tap_rq_type[0] ;
//assign  tap_thread[1] = ~lsu_iobrdge_tap_rq_type[1] &  lsu_iobrdge_tap_rq_type[0] ;
//assign  tap_thread[2] =  lsu_iobrdge_tap_rq_type[1] & ~lsu_iobrdge_tap_rq_type[0] ;
//assign  tap_thread[3] =  lsu_iobrdge_tap_rq_type[1] &  lsu_iobrdge_tap_rq_type[0] ;

// This is the pkt from the TAP to be returned to the TAP
//assign  cpx_reverse_req = cpx_spc_data_cx[130] ;
assign  cpx_reverse_req = cpx_spc_data_cx_b130;

// removed tap_rq_type[2] from the data_sel logic
assign  lsu_iobrdge_rply_data_sel[0] =  // defeature, margin, bist
  (|lsu_iobrdge_tap_rq_type[5:3]) & cpx_reverse_req_d1 ;
assign  lsu_iobrdge_rply_data_sel[1] =  // i/dcache
  (|lsu_iobrdge_tap_rq_type[7:6] & ~(|lsu_iobrdge_tap_rq_type[5:3])) & cpx_reverse_req_d1 ;
// regular fwd pkt
//  - sothea - 0in bug - can be 0-hot
//assign  lsu_iobrdge_rply_data_sel[2] = ~((|lsu_iobrdge_tap_rq_type[7:3]) & cpx_reverse_req_d1) ;
assign  lsu_iobrdge_rply_data_sel[2] = ~|lsu_iobrdge_rply_data_sel[1:0] ;

wire dcache_iob_rd,dcache_iob_rd_e, dcache_iob_rd_m, dcache_iob_rd_w ;
assign	dcache_iob_rd = lsu_iobrdge_tap_rq_type[6] & lsu_iobrdge_fwd_pkt_vld ;

dff_s  dciob_rd_e (
        .din    (dcache_iob_rd),
        .q      (dcache_iob_rd_e),
        .clk  	(clk),
        .se     (1'b0),       .si (),          .so ()
        );

dff_s  dciob_rd_m (
        .din    (dcache_iob_rd_e),
        .q      (dcache_iob_rd_m),
        .clk  	(clk),
        .se     (1'b0),       .si (),          .so ()
        );

dff_s  dciob_rd_w (
        .din    (dcache_iob_rd_m),
        .q      (dcache_iob_rd_w),
        .clk  	(clk),
        .se     (1'b0),       .si (),          .so ()
        );

assign	lsu_dcache_iob_rd_w = dcache_iob_rd_w ;

wire  cpx_fwd_rq_type ;
assign  cpx_fwd_rq_type =
        cpx_spc_data_cx_b144to140[`CPX_RQ_HI]   & ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO+2] & // fwd req
        cpx_spc_data_cx_b144to140[`CPX_RQ_LO+1] & ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO];
wire  cpx_fwd_rply_type ;
assign  cpx_fwd_rply_type =
        cpx_spc_data_cx_b144to140[`CPX_RQ_HI]   & ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO+2] & // fwd reply
        cpx_spc_data_cx_b144to140[`CPX_RQ_LO+1] &  cpx_spc_data_cx_b144to140[`CPX_RQ_LO] ;

// cpx pkt decode. fwd req/reply do not go into dfq.
assign  cpx_fwd_req =
         cpx_spc_data_cx_b144to140[`CPX_VLD] & ~cpx_reverse_req & cpx_fwd_rq_type ;

//8/25/03: add fwd req to L1I$ for RAMTEST to dfq_wr_en, dfq_rd_dvance
//bug4293 - set fwd_req_ic based on cpx_fwd_req_type and not based on cpx_fwd_req. this causes the request to 
//          de dropped i.e. not written into dfq 'cos cpx_fwd_req_ic is not set
//assign  cpx_fwd_req_ic =  cpx_fwd_req & cpx_spc_data_cx_b103 ;

assign  cpx_fwd_req_ic =  cpx_spc_data_cx_b144to140[`CPX_VLD] & cpx_fwd_rq_type &
                          cpx_reverse_req & cpx_spc_data_cx_b103 ;

assign  cpx_fwd_pkt_en_cx = cpx_fwd_req | cpx_fwd_reply ;

assign  cpx_fwd_reply =
         cpx_spc_data_cx_b144to140[`CPX_VLD] & (cpx_fwd_rply_type | (cpx_fwd_rq_type & cpx_reverse_req)) ;

wire fwd_reply_vld;
dff_s #(1) fwdpkt_stgd1 (
        .din    (fwd_reply_vld),
        .q      (lsu_pcx_fwd_reply),
        .clk  	(clk),
        .se     (1'b0),       .si (),          .so ()
        );


// Requests from iobrdge will not be speculative as core is expected to be quiescent.
assign  fwdpkt_reset = 
  (reset | lsu_fwdpkt_pcx_rq_sel) ; 
  // (reset | (lsu_fwdpkt_pcx_rq_sel & ~pcx_req_squash)) ; 
wire	fwdpkt_vld_unmasked,fwdpkt_vld_unmasked_d1 ;
wire	fwd_unc_err ;
wire    fwd_req_vld;
// There can be only one outstanding fwd reply or request.
dffre_s #(7)  fwdpkt_ff (
        .din    ({cpx_fwd_pkt_en_cx,cpx_fwd_req,cpx_fwd_reply, 
		cpx_spc_data_cx_b138,cpx_spc_data_cx_b71to70[1:0], cpx_reverse_req}),
        .q      ({fwdpkt_vld_unmasked,fwd_req_vld,fwd_reply_vld, 
		fwd_unc_err,fwdpkt_l2bnk_addr[1:0],cpx_reverse_req_d1}),
  .rst  (fwdpkt_reset), .en (cpx_fwd_pkt_en_cx),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        );

wire	fwd_rply_sz1_unc ; // Either size[1] for fwd-rq or unc-err for fwd-rply.
assign	fwd_rply_sz1_unc = fwd_reply_vld ? fwd_unc_err : 1'b1 ;	

dff_s  fpktunc_d1 (
        .din    (fwd_rply_sz1_unc),
        .q      (lsu_fwd_rply_sz1_unc),
        .clk  	(clk),
        .se     (1'b0),       .si (),          .so ()
        );

dff_s  fpktv_d1 (
        .din    (fwdpkt_vld_unmasked),
        .q      (fwdpkt_vld_unmasked_d1),
        .clk  	(clk),
        .se     (1'b0),       .si (),          .so ()
        );


wire icache_rd_done,icache_wr_done ;
dff_s #(2) ifwd_d1 (
        .din    ({ifu_lsu_fwd_data_vld,ifu_lsu_fwd_wr_ack}),
        .q      ({icache_rd_done,icache_wr_done}),
        .clk  	(clk),
        .se     (1'b0),       .si (),          .so ()
        );

// make one-shot : read data may be off.
assign  lsu_iobrdge_fwd_pkt_vld = fwdpkt_vld_unmasked & ~fwdpkt_vld_unmasked_d1 & cpx_reverse_req_d1 ;
//assign  lsu_iobrdge_fwd_pkt_vld = fwdpkt_vld ;
assign  fwdpkt_vld = 
	// immediate for all but dcache rd.
	(fwdpkt_vld_unmasked & ~((|lsu_iobrdge_tap_rq_type[7:6]) & cpx_reverse_req_d1)) |
        // dcache rd - wait until w.
	(fwdpkt_vld_unmasked &  lsu_iobrdge_tap_rq_type[6] & cpx_reverse_req_d1 & 
		~(dcache_iob_rd | dcache_iob_rd_e | dcache_iob_rd_m | dcache_iob_rd_w)) |
	// icache rd - wait for rd & wr 
	(fwdpkt_vld_unmasked &  lsu_iobrdge_tap_rq_type[7] & cpx_reverse_req_d1 &
			(icache_rd_done | icache_wr_done)) ;

assign  lsu_fwdpkt_vld  =  fwdpkt_vld;

assign  lsu_fwdpkt_dest[0] = fwd_req_vld & ~fwdpkt_l2bnk_addr[1] & ~fwdpkt_l2bnk_addr[0] ; // l2bank=0
assign  lsu_fwdpkt_dest[1] = fwd_req_vld & ~fwdpkt_l2bnk_addr[1] &  fwdpkt_l2bnk_addr[0] ; // l2bank=1
assign  lsu_fwdpkt_dest[2] = fwd_req_vld &  fwdpkt_l2bnk_addr[1] & ~fwdpkt_l2bnk_addr[0] ; // l2bank=2
assign  lsu_fwdpkt_dest[3] = fwd_req_vld &  fwdpkt_l2bnk_addr[1] &  fwdpkt_l2bnk_addr[0] ; // l2bank=3
assign  lsu_fwdpkt_dest[4] = fwd_reply_vld ; // reply always goes back to IO Bridge

//=================================================================================================
//  INTERRUPT CPX PKT REQ CTL
//=================================================================================================

//bug6322
//assign  lsu_tlu_cpx_vld = cpx_spc_data_cx_b144to140[`CPX_VLD] & ~cpx_spc_data_cx_b136 ;
//assign  lsu_tlu_cpx_req[3:0] = cpx_spc_data_cx_b144to140[`CPX_RQ_HI:`CPX_RQ_LO] ;
//assign  lsu_tlu_intpkt[17:0] = cpx_spc_data_b17t0_cx[17:0] ;

   wire lsu_tlu_cpx_vld_din_l;
   wire [17:0] lsu_tlu_intpkt_din;
   wire [3:0]  lsu_tlu_cpx_req_din_l;
   
assign  lsu_tlu_cpx_vld_din_l = ~(dfq_int_type & ~lsu_dfq_rdata_flush_bit & dfq_rd_advance) ; 
assign  lsu_tlu_intpkt_din[17:0] = lsu_dfq_rdata_b17_b0[17:0] ;
assign  lsu_tlu_cpx_req_din_l[3:0] = ~ lsu_dfq_rdata_rq_type[3:0];

   wire lsu_tlu_cpx_vld_l;
   wire [3:0] lsu_tlu_cpx_req_l;
   
dff_s  #(23) lsu_tlu_stg (
        .din    ({lsu_tlu_cpx_vld_din_l, lsu_tlu_intpkt_din[17:0], lsu_tlu_cpx_req_din_l[3:0]}),
        .q      ({lsu_tlu_cpx_vld_l,     lsu_tlu_intpkt[17:0], lsu_tlu_cpx_req_l[3:0]}),
        .clk  	(clk),
        .se     (1'b0),       .si (),          .so ()
        );

   assign     lsu_tlu_cpx_vld = ~lsu_tlu_cpx_vld_l;
   assign     lsu_tlu_cpx_req[3:0] = ~lsu_tlu_cpx_req_l[3:0];
   
//=================================================================================================
//  STQUAD PKT CONTROL
//=================================================================================================





//=================================================================================================
// SECONDARY VS. PRIMARY LOADS
//=================================================================================================

   
// NOT USED
//wire  [1:0] dfq_sel_tid ;
//assign  dfq_sel_tid[1:0] = 
//  // select byp tid if ld from cfq or cpx will be latched in byp ff next cycle
//  (dfq_byp_ld_vld & ((dfq_rptr_vld_d1 & dfq_rd_advance) | (cpx_spc_data_cx_b144to140[`CPX_VLD] & ~dfq_wr_en))) ? 
//  dfq_byp_tid[1:0] : dfq_tid[1:0] ;

//temp, send to dctl, phase 2     
assign  ld_sec_active = 1'b0 ;
   
assign  dfq_thread0 = ~dfq_tid[1] & ~dfq_tid[0] ;
assign  dfq_thread1 = ~dfq_tid[1] &  dfq_tid[0] ;
assign  dfq_thread2 =  dfq_tid[1] & ~dfq_tid[0] ;
assign  dfq_thread3 =  dfq_tid[1] &  dfq_tid[0] ;

// NOT USED
//assign  ld_any_thrd_byp_sel = |(ld_thrd_byp_sel[3:0]);

// phase 2 change   
// L2$ sends response for both prim and sec requests. Both will go into DFQ
// and fill D$
// can we eliminate dcfill_active_e ?
   
//11/7/03 - add rst_tri_en
wire  [3:0]  dfq_byp_sel_tmp ;
   assign dfq_byp_sel_tmp[0]  = dfq_thread0  & dcfill_active_e & ~lsu_cpx_pkt_prefetch;
   assign dfq_byp_sel_tmp[1]  = dfq_thread1  & dcfill_active_e & ~lsu_cpx_pkt_prefetch;
   assign dfq_byp_sel_tmp[2]  = dfq_thread2  & dcfill_active_e & ~lsu_cpx_pkt_prefetch;
   assign dfq_byp_sel_tmp[3]  = dfq_thread3  & dcfill_active_e & ~lsu_cpx_pkt_prefetch;

   assign dfq_byp_sel[2:0]  =  dfq_byp_sel_tmp[2:0]  & {3{~rst_tri_en}} ;
   assign dfq_byp_sel[3]    =  dfq_byp_sel_tmp[3]    | rst_tri_en ;
   
//   assign lsu_dfq_byp_mxsel[0]  = dfq_thread0  & dcfill_active_e;
//   assign lsu_dfq_byp_mxsel[1]  = dfq_thread1  & dcfill_active_e;
//   assign lsu_dfq_byp_mxsel[2]  = dfq_thread2  & dcfill_active_e;
//   assign lsu_dfq_byp_mxsel[3]  = ~|lsu_dfq_byp_mxsel[2:0];
   
// includes store cmplt tid also. 
assign  dfill_dcd_thrd[0] =   dfq_byp_sel[0] |    // for load
        (dfq_thread0 & stdq_active_e)  ;// for store
assign  dfill_dcd_thrd[1] =   dfq_byp_sel[1] |    // for load
        (dfq_thread1 & stdq_active_e)  ;// for store
assign  dfill_dcd_thrd[2] =   dfq_byp_sel[2] |    // for load
        (dfq_thread2 & stdq_active_e)  ;// for store
assign  dfill_dcd_thrd[3] =   dfq_byp_sel[3] |    // for load
        (dfq_thread3 & stdq_active_e)  ;// for store

assign  lsu_dfill_dcd_thrd[3:0]  =  dfill_dcd_thrd[3:0];

//=================================================================================================
//  Error Related Logic
//=================================================================================================

// Equivalent of lmq but lmq has run out of bits
// Following bits need to be logged.
// Dtag parity error 
//  - output on bit 130 of equivalent ld pkt
//  - when cpx pkt is at head of cfq, then log error
//  and take corresponding trap synchronous to pipe.
// DCache parity error
//  - when cpx pkt is at head of cfq, then log error
//  and take corresponding trap synchronous to pipe.


// The load component of the cpx response for an atomic will
// save it's error info for the store component. The store
// component will take the trap in the g stage, depending
// on the error information from the ld. However, it can
// always override the parity error info initially written,
// as atomics do not lookup the cache or tag.


//assign  error_en[0] = lmq_enable[0] | (lsu_cpx_pkt_atm_st_cmplt & dcfill_active_e & dfq_byp_sel[0]);
assign  error_en[0] = 
	//lsu_ld_inst_vld_g[0] | (lsu_cpx_pkt_atm_st_cmplt & dcfill_active_e & dfq_byp_sel[0]); // Bug 3624
	lsu_ld_inst_vld_g[0] ; 
assign  error_en[1] = 
	lsu_ld_inst_vld_g[1] ; 
assign  error_en[2] = 
	lsu_ld_inst_vld_g[2] ; 
assign  error_en[3] = 
	lsu_ld_inst_vld_g[3] ;

// 10/15/03: error reset is set only by reset. lsu_ld[0-3]_pcx_rq_sel_d1 is not needed because the
//           the flop is used only for reporting error to ifu. Also, the error_en is set for new requests.
//tmp fix for reset
//wire              lsu_pcx_ld_dtag_perror_w2 ;
//assign lsu_pcx_ld_dtag_perror_w2  = 1'b0;

//assign  error_rst[0] = reset | (lsu_ld0_pcx_rq_sel_d1 & lsu_pcx_ld_dtag_perror_w2) ;
//assign  error_rst[1] = reset | (lsu_ld1_pcx_rq_sel_d1 & lsu_pcx_ld_dtag_perror_w2) ;
//assign  error_rst[2] = reset | (lsu_ld2_pcx_rq_sel_d1 & lsu_pcx_ld_dtag_perror_w2) ;
//assign  error_rst[3] = reset | (lsu_ld3_pcx_rq_sel_d1 & lsu_pcx_ld_dtag_perror_w2) ;

assign  error_rst[0] = reset ;
assign  error_rst[1] = reset ;
assign  error_rst[2] = reset ;
assign  error_rst[3] = reset ;

//assign  lsu_error_rst[3:0]  =  error_rst[3:0];

wire	dtag_perror3,dtag_perror2,dtag_perror1,dtag_perror0;

// Thread 0
wire dcache_perror0;
dffre_s  #(2) error_t0 (
        .din    ({lsu_dcache_tag_perror_g,lsu_dcache_data_perror_g}),
    //lsu_cpx_pkt_ld_err[1:0]}),
        .q      ({dtag_perror0,dcache_perror0}),
        //.q      ({dtag_perror0,dcache_perror0,ld_error0[1:0]}),
        .rst  (error_rst[0]), .en     (error_en[0]),               
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        );            

// Thread 1
wire dcache_perror1;
dffre_s  #(2) error_t1 (
        .din    ({lsu_dcache_tag_perror_g,lsu_dcache_data_perror_g}),
    //lsu_cpx_pkt_ld_err[1:0]}),
        .q      ({dtag_perror1,dcache_perror1}),
        //.q      ({dtag_perror1,dcache_perror1,ld_error1[1:0]}),
        .rst  (error_rst[1]), .en     (error_en[1]),               
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        );            

// Thread 2
wire dcache_perror2;
dffre_s  #(2) error_t2 (
        .din    ({lsu_dcache_tag_perror_g,lsu_dcache_data_perror_g}),
    //lsu_cpx_pkt_ld_err[1:0]}),
        .q      ({dtag_perror2,dcache_perror2}),
        //.q      ({dtag_perror2,dcache_perror2,ld_error2[1:0]}),
        .rst  (error_rst[2]), .en     (error_en[2]),               
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        );            

// Thread 3
wire dcache_perror3;
dffre_s  #(2) error_t3 (
        .din    ({lsu_dcache_tag_perror_g,lsu_dcache_data_perror_g}),
    //lsu_cpx_pkt_ld_err[1:0]}),
        .q      ({dtag_perror3,dcache_perror3}),
        //.q      ({dtag_perror3,dcache_perror3,ld_error3[1:0]}),
        .rst  (error_rst[3]), .en     (error_en[3]),               
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        );            

//assign	lsu_dtag_perror_w2[3] = dtag_perror3 ;
//assign	lsu_dtag_perror_w2[2] = dtag_perror2 ;
//assign	lsu_dtag_perror_w2[1] = dtag_perror1 ;
//assign	lsu_dtag_perror_w2[0] = dtag_perror0 ;

// Determine if ld pkt requires correction due to dtag parity error.
//5/22/03: moved to qctl1
//assign  lsu_pcx_ld_dtag_perror_w2 =
//  ld_pcx_rq_sel[0] ? dtag_perror0 :
//    ld_pcx_rq_sel[1] ? dtag_perror1 :
//      ld_pcx_rq_sel[2] ? dtag_perror2 : dtag_perror3 ;

// Now post sparc related errors and take traps
// error is reset after it is sent to pcx. the logic below will never be set!!
assign  lsu_cpx_ld_dtag_perror_e =
  dfq_byp_sel[0] ? dtag_perror0 :
    dfq_byp_sel[1] ? dtag_perror1 :
      dfq_byp_sel[2] ? dtag_perror2 : (dfq_byp_sel[3] & dtag_perror3) ; // Bug 4655

assign  lsu_cpx_ld_dcache_perror_e =
  dfq_byp_sel[0] ? dcache_perror0 :
    dfq_byp_sel[1] ? dcache_perror1 :
      dfq_byp_sel[2] ? dcache_perror2 : (dfq_byp_sel[3] & dcache_perror3) ; // Bug 4655

//Bug 3624
/*
assign  lsu_cpx_atm_st_err[1:0] =
  cpx_pkt_thrd_sel[0] ? ld_error0[1:0] :
    cpx_pkt_thrd_sel[1] ? ld_error1[1:0] :
      cpx_pkt_thrd_sel[2] ? ld_error2[1:0] : ld_error3[1:0] ;*/ 

//===
wire memref_e;

dff_s #(1) stge_ad_e (
  .din (ifu_lsu_memref_d),
  .q   (memref_e),
  .clk (clk),
  .se     (1'b0),       .si (),          .so ()
);
   
  
  
  
//=================================================================================================
//  LDD HANDLING
//=================================================================================================

assign ldd_vld_reset =
        (reset | (dcfill_active_e & ldd_in_dfq_out)); 

// prefetch qual is required for case where prefetch may get interference
// from lmq contents set by a later load that issues before the prefetch
// is returned.
// integer
assign ldd_vld_en = lmq_ldd_vld & ~lsu_cpx_pkt_prefetch & dcfill_active_e ;
// fp
assign lsu_fldd_vld_en = lmq_ldd_vld & ~lsu_cpx_pkt_prefetch & lsu_l2fill_fpld_e & dcfill_active_e ;


dffre_s   ldd_in_dfq_ff (
        .din    (lmq_ldd_vld), .q  (ldd_in_dfq_out),
        .rst    (ldd_vld_reset),        .en     (ldd_vld_en),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        ); 


wire lsu_ignore_fill;
//dfq_ld_vld is redundant   
assign lsu_ignore_fill = dfq_ld_vld & lmq_ldd_vld & ~ldd_in_dfq_out & dcfill_active_e ;


dff_s #(5)   dfq_rd_m (
        .din    (ifu_lsu_rd_e[4:0]), .q  (ld_l1hit_rd_m[4:0]),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        ); 

//dff #(5)   dfq_rd_g (
//        .din    (ld_l1hit_rd_m[4:0]), .q  (ld_l1hit_rd_g[4:0]),
//        .clk  (clk),
//        .se     (1'b0),       .si (),          .so ()
//        ); 

wire ldd_in_dfq_out_d1;
dff_s #(1)   stgd1_lrd (
        .din    (ldd_in_dfq_out), 
  .q    (ldd_in_dfq_out_d1),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        ); 

//dff #(1)   stgd2_lrd (
//        .din    (ldd_in_dfq_out_d1), 
//  .q    (ldd_in_dfq_out_d2),
//        .clk  (clk),
//        .se     (1'b0),       .si (),          .so ()
//        ); 


//wire [4:0] lmq_ld_rd1_g;   
//dff #(5) ff_lmq_ld_rd1 (
//        .din  (lmq_ld_rd1[4:0]), 
//        .q    (lmq_ld_rd1_g[4:0]),
//        .clk  (clk),
//        .se   (1'b0),       .si (),          .so ()
//        ); 
   

// Stage l2fill vld
//wire	l2fill_vld_m, l2fill_vld_g ;
wire	l2fill_vld_e,l2fill_vld_m ;
dff_s    	l2fv_stgm (
        .din  (l2fill_vld_e), 
  	.q    (l2fill_vld_m),
        .clk  (clk),
        .se   (1'b0),       .si (),          .so ()
        ); 

//dff    	l2fv_stgg (
//        .din  (l2fill_vld_m), 
//  	.q    (l2fill_vld_g),
//        .clk  (clk),
//        .se   (1'b0),       .si (),          .so ()
//        ); 

wire	ld_inst_vld_m ;
dff_s    	lvld_stgm (
        .din  (ld_inst_vld_e), 
  	.q    (ld_inst_vld_m),
        .clk  (clk),
        .se   (1'b0),       .si (),          .so ()
        ); 

//wire	ld_inst_vld_g ;
//dff    	lvld_stgg (
//        .din  (ld_inst_vld_m), 
//  	.q    (ld_inst_vld_g),
//        .clk  (clk),
//        .se   (1'b0),       .si (),          .so ()
//        ); 

wire	ldd_in_dfq_out_vld ;
assign	ldd_in_dfq_out_vld = ldd_in_dfq_out_d1 & l2fill_vld_m ;
assign lsu_exu_rd_m[4:0] = 
  ld_inst_vld_m ? ld_l1hit_rd_m[4:0] : 
    		ldd_in_dfq_out_vld ?  {lmq_ld_rd1[4:1],~lmq_ld_rd1[0]} 
						: lmq_ld_rd1[4:0];
/*wire	ldd_in_dfq_out_vld ;
assign	ldd_in_dfq_out_vld = ldd_in_dfq_out_d2 & l2fill_vld_g ;
assign lsu_exu_rd_w2[4:0] = 
  ld_inst_vld_g ? ld_l1hit_rd_g[4:0] : 
    		ldd_in_dfq_out_vld ?  {lmq_ld_rd1_g[4:1],~lmq_ld_rd1_g[0]} 
						: lmq_ld_rd1_g[4:0];*/


// Generate data select for 128b. ldd will cause hi-order 8B followed by low order
// 8B to be selected.

// ldd will select from same 64b dw.
assign  lsu_dfill_data_sel_hi = ~lmq_ld_addr_b3 ^ (ldd_in_dfq_out & ~ldd_non_alt_space) ;

// ldd non-alternate space. sz distinguishes between quad, fp ldd and int ldd.
// quad ldd, fp ldd sz = 2'b11, int ldd sz = 2'b10   
assign  ldd_non_alt_space = lsu_byp_misc_sz_e[1] & ~lsu_byp_misc_sz_e[0] ;

assign  ldd_oddrd_e = ldd_in_dfq_out & ldd_non_alt_space ;

dff_s   ldd_stgm (
        .din    (ldd_oddrd_e), 
  .q    (lsu_byp_ldd_oddrd_m),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        ); 

// all incoming ld and inv packets must be written to dfq or its bypass flop.
// wrt ptr must be updated in cycle that cpx pkt is sent.

// invalidate does not need bubble, only ld bypass and/or fill.
// fill bypass can only occur if bubble is in pipeline.

//------
// strm ack cmplt - needs to be visible in dcache
//------

//bug4460 - qualify stream store ack w/ local packet
//Bug4969
wire    dfq_local_pkt ;
wire	strmack_cmplt1, strmack_cmplt2, strmack_cmplt3 ;
wire	strmack_cmplt1_d1, strmack_cmplt2_d1, strmack_cmplt3_d1 ;
//wire	strm_ack_cmplt ;
assign	strmack_cmplt1 =
	// check inflight, no inv. if inv, write to dfq_byp.
	(cpx_strm_st_ack_type & ~(dfq_wr_en | lsu_cpx_spc_inv_vld) & 
         (const_cpuid[2:0] == cpx_spc_data_cx_b120to118[`CPX_INV_CID_HI:`CPX_INV_CID_LO])) ;
assign	strmack_cmplt2 = 
	// check dfq-rd - no inv, gets dropped.
	(lsu_dfq_byp_type[1] & dfq_rd_advance & ~lsu_dfq_byp_cpx_inv & local_pkt) ;
assign	strmack_cmplt3 = 
	// check dfq-rd - inv, and thus process from dfq_bypass.
	(lsu_cpx_pkt_strm_ack & inv_active_e & dfq_inv_vld & dfq_local_pkt) ;

/*assign	strm_ack_cmplt =
	// check inflight, no inv. if inv, write to dfq_byp.
	(cpx_strm_st_ack_type & ~(dfq_wr_en | lsu_cpx_spc_inv_vld) & 
         (const_cpuid[2:0] == cpx_spc_data_cx_b120to118[`CPX_INV_CID_HI:`CPX_INV_CID_LO])) |
	// check dfq-rd - no inv, gets dropped.
	(lsu_dfq_byp_type[1] & dfq_rd_advance & ~lsu_dfq_byp_cpx_inv & local_pkt) |
	// check dfq-rd - inv, and thus process from dfq_bypass.
	(lsu_cpx_pkt_strm_ack & inv_active_e & dfq_inv_vld & dfq_local_pkt) ;*/

dff_s #(3)   strmackcnt_stg (
        .din  	({strmack_cmplt3,strmack_cmplt2,strmack_cmplt1}), 
        .q  	({strmack_cmplt3_d1,strmack_cmplt2_d1,strmack_cmplt1_d1}), 
        .clk  	(clk),
        .se     (1'b0),       .si (),          .so ()
        ); 

assign	lsu_spu_strm_ack_cmplt[0] =	// lsb  of cnt, 1 or 3.
	(~strmack_cmplt1_d1 & ~strmack_cmplt2_d1 &  strmack_cmplt3_d1) | //001
	(~strmack_cmplt1_d1 &  strmack_cmplt2_d1 & ~strmack_cmplt3_d1) | //010
	( strmack_cmplt1_d1 &  strmack_cmplt2_d1 &  strmack_cmplt3_d1) | //111
	( strmack_cmplt1_d1 & ~strmack_cmplt2_d1 & ~strmack_cmplt3_d1) ; //100

assign	lsu_spu_strm_ack_cmplt[1] =	// msb  of cnt, 2 or 3.
	(strmack_cmplt1_d1 & strmack_cmplt2_d1) |
	(strmack_cmplt2_d1 & strmack_cmplt3_d1) |
	(strmack_cmplt1_d1 & strmack_cmplt3_d1) ;

/*dff   strmack_d1 (
        .din  (strm_ack_cmplt), 
  	.q    (lsu_spu_strm_ack_cmplt),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        ); */
	
// Active as soon as it is visible in dfq byp ff.
assign  inv_active_e = dfq_inv_vld ;      // evict/icache/strm-st
//wire  st_atm_err ;
// An atomic st is forced to punch a bubble in the pipe if
// an error is encountered on the load. error en is not checked
// at this point.
/*assign  st_atm_err = 
  ((|lsu_cpx_atm_st_err[1:0]) & lsu_cpx_pkt_atm_st_cmplt) ;*/

assign  stwr_active_e = 
  dfq_st_vld & dfq_local_inv  & ~memref_e &
  ~lsu_cpx_pkt_atm_st_cmplt & ~lsu_cpx_pkt_binit_st ;
// & ~lsu_cpx_pkt_stquad_pkt2 ;  // fix for ifill_pkt_vld -b[130]
//  dfq_st_vld & local_inv & ~st_ack_rq_stb_d1 & ~memref_e & //st ack timing fix
//  ~lsu_cpx_pkt_stquad_pkt2 // bug 2942

assign  stdq_active_e = 
  dfq_st_vld & 
  //((~dfq_local_inv & (~st_atm_err | (st_atm_err & ~memref_e))) | //Bug 3624
  ((~dfq_local_inv) | 
   (dfq_local_inv & ~memref_e)) ;
//  ((~local_inv & (~st_atm_err | (st_atm_err & ~memref_e))) | 
//   (local_inv & (~st_ack_rq_stb_d1 & ~memref_e))) ;


assign	dfq_st_cmplt = stdq_active_e | (inv_active_e & dfq_st_vld) ;

wire	atm_st_cmplt ;
assign  atm_st_cmplt = dfq_st_cmplt & lsu_cpx_pkt_atm_st_cmplt ; 
assign  lsu_atm_st_cmplt_e = atm_st_cmplt ;

assign  dcfill_active_e = dfq_ld_vld & ~memref_e ;

//bug3753 - qualify ld*_fill_reset w/ dcfill_active & ~ignore_fill
//          in qctl1 this is qual'ed w/ dfq_ld_vld
assign  lsu_dcfill_active_e  =  dcfill_active_e & ~lsu_ignore_fill;
//assign  lsu_dcfill_active_e  =  dcfill_active_e;

assign  dva_svld_e = 
  inv_active_e |      // evict/icache/strm-st
  (dfq_st_vld & lsu_cpx_pkt_perror_dinv) |	// dtag parity error invalidation.
  (dfq_local_inv & dfq_st_vld & // local st - atomic
  lsu_cpx_pkt_atomic ) ;
  //lsu_cpx_pkt_atomic & ~lsu_cpx_pkt_stquad_pkt2) ; // store quad pkt not present - cmp1_regr fail
  //(local_inv & dfq_st_vld & // local st - stquad/atomic
assign  l2fill_vld_e  = dcfill_active_e & 
			~lsu_cpx_pkt_prefetch ; // prefetch will not fill

assign	lsu_l2fill_vld = dcfill_active_e ;

//=================================================================================================
//  DFQ RD/WR CONTROL
//=================================================================================================
  
//assign  cpx_inv =
//  lsu_cpu_inv_data[`CPX_AX0_INV_DVLD]   |   // line 0
//  lsu_cpu_inv_data[`CPX_AX1_INV_DVLD+4] |   // line 1
//  lsu_cpu_inv_data[`CPX_AX0_INV_DVLD+7] |   // line 2
//  lsu_cpu_inv_data[`CPX_AX1_INV_DVLD+11] ;  // line 3

// All invalidates go into byp buffer
assign  dfq_byp_ld_vld = lsu_dfq_byp_type[5] ;
// local store inv path is separate.
assign  dfq_byp_inv_vld = 
       (lsu_dfq_byp_type[4] & dfq_invwy_vld)  	| // icache x-inv
       (lsu_dfq_byp_type[3]    			| // evict
       (lsu_dfq_byp_type[2] & ~local_pkt)   	| // sparc st-ack - non-local
        lsu_dfq_byp_type[1] 			| // strm st-ack
	(lsu_dfq_byp_type[2] & local_pkt & lsu_dfq_byp_binit_st)) &     
				// blk init st invalidates L1
        lsu_dfq_byp_cpx_inv ;         // local invalidate
        //cpx_inv ;         // local invalidate

// Local store which writes to cache
//timing fix: 7/14/03 - to improve setup of dfq_st_vld and dfq_ld_vld and move the flop to qdp2 -
//            to eventually improve dcache_fill_data timing
//            add byp mux for cpuid in qctl2
wire  [2:0]  dfq_byp_cpuid ;
assign  dfq_byp_cpuid[2:0]  =  dfq_rd_vld_d1 ? lsu_dfq_rdata_cpuid[2:0] : 
                                   cpx_spc_data_cx_b120to118[`CPX_INV_CID_HI:`CPX_INV_CID_LO] ;

//assign  local_pkt =  &(const_cpuid[2:0] ~^ lsu_dfq_byp_cpuid[2:0]) ;
assign  local_pkt =  &(const_cpuid[2:0] ~^ dfq_byp_cpuid[2:0]) ;
assign  dfq_rdata_local_pkt =  &(const_cpuid[2:0] ~^ lsu_dfq_rdata_cpuid[2:0]) ;
assign  dfq_byp_st_vld = lsu_dfq_byp_type[2] & local_pkt ;

// Add ifill invalidate
// screen cpx data which gets written to dfq
assign  dfq_byp_vld = 
(dfq_byp_ld_vld | dfq_byp_inv_vld | dfq_byp_st_vld) & 
(dfq_rd_vld_d1 | (~dfq_rd_vld_d1 & ~dfq_wr_en))  ;  

//assign  lsu_dfq_byp_vld  =  dfq_byp_vld;

/*assign dfq_vld_reset =
        reset | ((dcfill_active_e | inv_active_e | stdq_active_e) & 
    ~dfq_vld_en & // dside pkt in waiting
    ~lsu_ignore_fill &  // ldd
    ~ld_ignore_sec  // secondary loads
    ) ; */

/*wire  ld_sec_rst, ld_sec_rst_d1 ;
assign  ld_sec_rst = dcfill_active_e & ld_ignore_sec_last ;
dff_s   secl_d1 (
        .din    (ld_sec_rst), .q  (ld_sec_rst_d1),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        ); */

/* phase 2 change
assign dfq_vld_reset =
    // dside pkt in waiting, ldd, secondary loads
        reset | (dcfill_active_e & ~(dfq_vld_en | lsu_ignore_fill | (ld_ignore_sec & ~ld_ignore_sec_last))) |
    // dside pkt in waiting
          ((inv_active_e | stdq_active_e) & ~dfq_vld_en) ; 
*/

assign dfq_vld_reset =
    // dside pkt in waiting, ldd, no need secondary loads waiting
        reset | (dcfill_active_e & ~(dfq_vld_en | (lsu_ignore_fill & ~lsu_cpx_pkt_prefetch))) |
    // dside pkt in waiting
          ((inv_active_e | stdq_active_e) & ~dfq_vld_en) ; 
   
// vld is enabled only if both i and d side buffers are clear
// for co-dependent events. co-dependent events are rare.
wire    dfq_rd_advance_buf1 ;
assign dfq_vld_en = dfq_byp_vld & 
		(dfq_rd_advance_buf1 | 
		(cpx_spc_data_cx_b144to140[`CPX_VLD] & vld_dfq_pkt & ~dfq_wr_en)) ;

/* phase 2 change
assign  dfq_byp_ff_en = 
  (~dfq_byp_full |
  ( dfq_byp_full & ((dcfill_active_e & ~(lsu_ignore_fill | ld_ignore_sec)) | 
       (inv_active_e | stdq_active_e)))) ; 
*/

assign  dfq_byp_ff_en = 
  (~dfq_byp_full |
  ( dfq_byp_full & ((dcfill_active_e & ~lsu_ignore_fill) | 
       (inv_active_e | stdq_active_e)))) ; 

//bug4576: add sehold to the flop enable in qdp2
assign lsu_dfq_byp_ff_en  =  sehold | dfq_byp_ff_en ;
   
   // i.e., byp currently filling.

/*
assign  dfq_byp_ff_en = 
  (~dfq_byp_full |
  (dfq_byp_full & (dcfill_active_e | inv_active_e | stdq_active_e) & ~(lsu_ignore_fill | ld_ignore_sec))) ; 
  // i.e., byp currently filling.
*/

// dfq bypass valid
//timing fix: 6/6/03: add duplicate flop for dfq_byp_ld_vld and dfq_byp_st_vld
//timing fix: 10/3/03 - add separate flop for lsu_dfq_vld lsu_dfq_st_vld to dctl
//bug4460:  qualify stream store ack w/ local packet - add local pkt flop
dffre_s  #(10) dfq_vld (
        .din({local_pkt,dfq_byp_st_vld,dfq_byp_vld,dfq_byp_vld,
              dfq_byp_ld_vld,dfq_byp_inv_vld,dfq_byp_st_vld,
              lsu_dfq_byp_cpx_inv,dfq_byp_ld_vld,dfq_byp_st_vld}),
        .q  ({dfq_local_pkt,lsu_dfq_st_vld,lsu_dfq_vld,dfq_byp_full,
              dfq_ld_vld,dfq_inv_vld,dfq_st_vld,
              dfq_local_inv,lsu_qdp2_dfq_ld_vld,lsu_qdp2_dfq_st_vld}),
//.din    ({dfq_byp_vld,dfq_byp_ld_vld,dfq_byp_inv_vld,dfq_byp_st_vld,cpx_inv,lsu_dfq_byp_cpx_inv}),
//.q      ({dfq_byp_full,dfq_ld_vld,dfq_inv_vld,dfq_st_vld,local_inv,dfq_local_inv}),
        .rst    (dfq_vld_reset),        .en     (dfq_vld_en),
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        );                                    

//bug4057: kill diagnostic write if dfq has valid requests to l1d$
//timing fix: 10/3/03 - add separate flop for lsu_dfq_vld
//assign  lsu_dfq_vld  =  dfq_byp_full ;

assign  lsu_dfq_ld_vld  =  dfq_ld_vld;
//timing fix: 9/29/03 - instantiate buffer for dfq_st_vld to dctl
//timing fix: 10/3/03 - remove buffer and add separate flop
//assign  lsu_dfq_st_vld  =  dfq_st_vld;
//bw_u1_buf_30x UZsize_lsu_dfq_st_vld_buf1 ( .a(dfq_st_vld), .z(lsu_dfq_st_vld) );
assign  lsu_dfq_ldst_vld  =  lsu_qdp2_dfq_ld_vld | lsu_qdp2_dfq_st_vld;


// Flop invalidate bits
dffe_s  #(`L1D_WAY_WIDTH+1) dfq_inv (
        .din    ({lsu_cpu_inv_data_val,lsu_cpu_inv_data_way}),
        .q    ({dfq_inv_data_val,dfq_inv_data_way}),
        //.din    (lsu_cpu_inv_data[13:0]),
        //.q      (dfq_inv_data[13:0]),
        .en     (dfq_vld_en),
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        );                                    

// dfq_inv_data_b0


/*
assign  lsu_st_ack_addr_b54[0] = dfq_inv_data[4] | dfq_inv_data[11] ;
assign  lsu_st_ack_addr_b54[1] = dfq_inv_data[7] | dfq_inv_data[11] ;


assign  st_wrwy_sel[0] = ~lsu_st_ack_addr_b54[1] & ~lsu_st_ack_addr_b54[0] ;
assign  st_wrwy_sel[1] = ~lsu_st_ack_addr_b54[1] &  lsu_st_ack_addr_b54[0] ;
assign  st_wrwy_sel[2] =  lsu_st_ack_addr_b54[1] & ~lsu_st_ack_addr_b54[0] ;
assign  st_wrwy_sel[3] =  lsu_st_ack_addr_b54[1] &  lsu_st_ack_addr_b54[0] ;

assign  lsu_st_ack_wrwy[1:0]   = 
st_wrwy_sel[0] ? dfq_inv_data[`CPX_AX0_INV_WY_HI:`CPX_AX0_INV_WY_LO] :
  st_wrwy_sel[1] ? dfq_inv_data[`CPX_AX1_INV_WY_HI+4:`CPX_AX1_INV_WY_LO+4] :
    st_wrwy_sel[2] ? dfq_inv_data[`CPX_AX0_INV_WY_HI+7:`CPX_AX0_INV_WY_LO+7] :
      st_wrwy_sel[3] ? dfq_inv_data[`CPX_AX1_INV_WY_HI+11:`CPX_AX1_INV_WY_LO+11] :
            2'bxx ;
*/

// cpx invalidate data obtained via the cfq.
// b[8[ and b[1] are unused
//8/28/03: vlint cleanup - remove cpx_cpu_inv_data and use dfq_inv_data directly
//assign  cpx_cpu_inv_data[13:0] =  {dfq_inv_data_b13to9,1'b0,dfq_inv_data_b7to2,1'b0,dfq_inv_data_b0} ;
//assign  cpx_cpu_inv_data[13:0] =  dfq_inv_data[13:0] ;

// write control set up.   
// All cpx pkts are written.
// - unwanted pkts are explicity overwritten by next incoming pkt.

   /*wire stb_cam_hit_w2;
   
dff_s #(1)  stb_cam_hit_stg_w2  (
  .din (stb_cam_hit), 
  .q   (stb_cam_hit_w2),
  .clk (clk), 
  .se  (1'b0), .si (), .so ()
  ); */

// Need to include error pkt !!
//8/25/03: add error type to dfq_wr_en, dfq_rd_advance
//8/25/03: add fwd req to L1I$ for RAMTEST to dfq_wr_en, dfq_rd_dvance
assign	vld_dfq_pkt = 
cpx_int_type | cpx_ld_type | cpx_ifill_type | cpx_evict_type | cpx_st_ack_type | cpx_strm_st_ack_type | cpx_error_type | cpx_fwd_req_ic ;

//NOTE: restore cpx_inv qualification after adding cpx_inv part of dfq read - done

assign  dfq_wr_en = 
  // local st wr which writes to cache is put in dfq if cam-hit occurs.
  //(cpx_local_st_ack_type & stb_cam_hit_w2 & cpx_inv) |
  //(cpx_local_st_ack_type & stb_cam_hit_w2 & lsu_dfq_byp_cpx_inv) |
  //(cpx_local_st_ack_type) |  //bug2623
  (cpx_st_ack_type) |
  // always write under these conditions
  //(vld_dfq_pkt & (dfq_vld_entry_exists | dfq_rptr_vld_d1)) | 
  (vld_dfq_pkt & (dfq_vld_entry_exists_w | dfq_rptr_vld_d1)) | 
  //(cpx_spc_data_cx_b144to140[`CPX_VLD] & (dfq_vld_entry_exists | dfq_rptr_vld_d1)) | 
  // interrupts always write to queue
    cpx_int_type |
  // error type or forward request to l1i$ - bypass
   ((cpx_error_type | cpx_fwd_req_ic) & ifu_lsu_ibuf_busy)  |
  // selectively write under these conditions
   ((cpx_ld_type & ~dfq_byp_ff_en)          | 
    (cpx_ld_type &  cpx_spc_data_cx_b133 & ifu_lsu_ibuf_busy)  |
    (cpx_ifill_type & ifu_lsu_ibuf_busy)          |
    (cpx_ifill_type & cpx_spc_data_cx_b133 & ~dfq_byp_ff_en) |
    // the evictions/acks will wr to the dfq if any buffer is full
    ((cpx_evict_type | cpx_st_ack_type | cpx_strm_st_ack_type) & (ifu_lsu_ibuf_busy | ~dfq_byp_ff_en))) ;
      
assign  dfq_wptr_new_w_wrap[5:0]  = dfq_wptr_w_wrap[5:0] + {5'b00000, dfq_wr_en} ;
//assign  dfq_wptr_vld = dfq_wr_en ;
// every pkt is to be written to dfq. The pkt may be rejected by not updating
// write ptr based on certain conditions.
assign  dfq_wptr_vld = cpx_spc_data_cx_b144to140[`CPX_VLD] ;

dffre_s  #(6) dfq_wptr_ff (
        .din    (dfq_wptr_new_w_wrap[5:0]), .q  (dfq_wptr_w_wrap[5:0]),
        .rst    (reset), .en (dfq_wr_en), .clk (clk),
        .se     (1'b0),       .si (),          .so ()
        ); 

//1/20/04: mintime fix - add minbuf to dfq_wptr
//assign  dfq_wptr[4:0] = dfq_wptr_w_wrap[4:0] ;

wire  [4:0]  dfq_wptr_minbuf ;
bw_u1_minbuf_5x UZfix_dfq_wptr_b0_minbuf (.a(dfq_wptr_w_wrap[0]), .z(dfq_wptr_minbuf[0]));
bw_u1_minbuf_5x UZfix_dfq_wptr_b1_minbuf (.a(dfq_wptr_w_wrap[1]), .z(dfq_wptr_minbuf[1]));
bw_u1_minbuf_5x UZfix_dfq_wptr_b2_minbuf (.a(dfq_wptr_w_wrap[2]), .z(dfq_wptr_minbuf[2]));
bw_u1_minbuf_5x UZfix_dfq_wptr_b3_minbuf (.a(dfq_wptr_w_wrap[3]), .z(dfq_wptr_minbuf[3]));
bw_u1_minbuf_5x UZfix_dfq_wptr_b4_minbuf (.a(dfq_wptr_w_wrap[4]), .z(dfq_wptr_minbuf[4]));

bw_u1_buf_10x UZsize_dfq_wptr_b0_buf2 ( .a(dfq_wptr_minbuf[0]), .z(dfq_wptr[0]) );
bw_u1_buf_10x UZsize_dfq_wptr_b1_buf2 ( .a(dfq_wptr_minbuf[1]), .z(dfq_wptr[1]) );
bw_u1_buf_10x UZsize_dfq_wptr_b2_buf2 ( .a(dfq_wptr_minbuf[2]), .z(dfq_wptr[2]) );
bw_u1_buf_10x UZsize_dfq_wptr_b3_buf2 ( .a(dfq_wptr_minbuf[3]), .z(dfq_wptr[3]) );
bw_u1_buf_10x UZsize_dfq_wptr_b4_buf2 ( .a(dfq_wptr_minbuf[4]), .z(dfq_wptr[4]) );

// Bit3 of both pointers is a wrap bit. Including this in the compare
// will tell us whether the queue is empty or not. It is assumed that
// the wptr will never runover the rptr because of flow control.
// This will have to be fine-tuned once dfq is accurate !!!
assign  dfq_vld_entry_exists = (dfq_rptr_new_w_wrap[5:0] != dfq_wptr_w_wrap[5:0]) ;

assign  dfq_vld_entry_exists_w = (dfq_rptr_w_wrap[5:0] != dfq_wptr_w_wrap[5:0]) ;

// dfq is read iff bypass flop is empty and valid entry in dfq available. 
// i.e., we need to initialize bypass ff such that it always contains
// latest entry.
//  (dfq_rptr_vld_d1 & (~i_and_d_codepend | (i_and_d_codepend & dfq_rd_advance))) |

//assign  lsu_ifill_pkt_vld =   
//  (dfq_rptr_vld_d1 & ~(dfq_st_ack_type & lsu_dfq_byp_stack_dcfill_vld) & (~i_and_d_codepend | (i_and_d_codepend & dfq_byp_ff_en))) |
//        (cpx_spc_data_cx[`CPX_VLD] & ~dfq_wr_en) ;
//
//  (dfq_rptr_vld_d1 & ~(dfq_st_ack_type & lsu_dfq_byp_stack_dcfill_vld) & ~ifill_pkt_fwd_done_d1) |
//
//  (dfq_rptr_vld_d1 & ~(lsu_dfq_rdata_st_ack_type & lsu_dfq_rdata_stack_dcfill_vld) & ~ifill_pkt_fwd_done_d1) | // bug:2767
//  change lsu_dfq_rdata_stack_dcfill_vld from b[87] to b[151] in the top level 
//
//timing fix: 6/16/03 - fix for ifill_pkt_vld - use b130 if store_ack_dcfill_vld=1
//            change lsu_dfq_rdata_stack_dcfill_vld from b[151] to b[130] in the top level 
//  (dfq_rptr_vld_d1 & ~(lsu_dfq_rdata_st_ack_type & dfq_rdata_local_pkt & lsu_dfq_rdata_stack_dcfill_vld) & ~ifill_pkt_fwd_done_d1) |
//
//bug3657 - kill ifill vld in bypass path when cpxtype=fp/fwd_reply
//NOTE: stream loads should also be included
//bug5080 - kill ifill vld in bypass path when cpxtype=strm load - similar to bug3657
//          kill bypass when dfq_rptr_vld_d1=1
//  (cpx_spc_data_cx_b144to140[`CPX_VLD] & ~(dfq_wr_en | cpx_fwd_rply_type | cpx_fp_type)) ;
//
//bug6372: ifill dcache x-inv causes incorrect dcache index to be invalidated.
//         - this occurs 'cos the imiss index gets overwritten by another imiss to the same thread.
//           the dcache x-inv(head of dfq) is stalled in dfq 'cos of load in bypass flop being stalled by memref_e=1
//           but the ifill pkt vld is set to 1 and ifu starts issuing the next imiss for same thread
//         
//  (dfq_rptr_vld_d1 & ~(lsu_dfq_rdata_st_ack_type & lsu_dfq_rdata_stack_dcfill_vld) & ~ifill_pkt_fwd_done_d1) |

wire   ifill_pkt_fwd_done,ifill_pkt_fwd_done_d1;
wire   ifill_dinv_head_of_dfq_pend ;


assign  ifill_dinv_head_of_dfq_pend  =  lsu_dfq_rdata_type[4] & lsu_dfq_rdata_invwy_vld & ~dfq_byp_ff_en ;

assign  lsu_ifill_pkt_vld =   
  (dfq_rptr_vld_d1 & ~(lsu_dfq_rdata_st_ack_type & lsu_dfq_rdata_stack_dcfill_vld) & 
                     ~ifill_dinv_head_of_dfq_pend &
                     ~ifill_pkt_fwd_done_d1 ) |
  (~dfq_rptr_vld_d1 & cpx_spc_data_cx_b144to140[`CPX_VLD] & ~(dfq_wr_en | cpx_fwd_rply_type | cpx_fp_type)) ;

// this signal acts as a mask i.e. fill valid will be asserted until the ifu_lsu_ibuf_busy=0. But certain packets need
// both busy=0 and memref_e=0 - in which case it is safer to mask until the dfq_rd_advance=1.

//bug5309: add reset to the flop; x's get recycled from flop o/p until a dfq_rd_advance occurs i.e. flop reset
//         after first ifill; failed in cmp1.92 cmp8 regression w/ vcs7.1

assign  ifill_pkt_fwd_done  =  ~reset & 
                               (((dfq_rptr_vld_d1 & ~ifu_lsu_ibuf_busy & ~ifill_dinv_head_of_dfq_pend) | 
                                ifill_pkt_fwd_done_d1)   // set|hold
                                & ~dfq_rd_advance);				                  // reset

dff_s  #(1) ifill_pkt_fwd_done_ff (
        .din    (ifill_pkt_fwd_done),
        .q      (ifill_pkt_fwd_done_d1),
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        );



// Note that this becomes valid in cycle of read. Flush will be continuously read
// out of dfq until all intermmediate buffers are clear.

// timing fix: 06/04/03: dfq_rd_advance uses byp_mux output; instead use dfq read output
//             i.e. dfq_rd_advance is valid only when there is a valid entry in dfq
//             it is already qual'ed w/ dfq_rd_vld_d1 to determine this.

//assign  dfq_ld_type     = lsu_dfq_byp_type[5] ;
//assign  dfq_ifill_type    = lsu_dfq_byp_type[4] ;
//assign  dfq_evict_type    = lsu_dfq_byp_type[3] ;
//assign  dfq_st_ack_type   = lsu_dfq_byp_type[2] ;
//assign  dfq_strm_st_ack_type  = lsu_dfq_byp_type[1] ;
//assign  dfq_int_type    = lsu_dfq_byp_type[0] ;

assign  dfq_ld_type     = lsu_dfq_rdata_type[5] ;
assign  dfq_ifill_type    = lsu_dfq_rdata_type[4] ;
assign  dfq_evict_type    = lsu_dfq_rdata_type[3] ;
assign  dfq_st_ack_type   = lsu_dfq_rdata_type[2] ;
assign  dfq_strm_st_ack_type  = lsu_dfq_rdata_type[1] ;
assign  dfq_int_type    = lsu_dfq_rdata_type[0] ;

//8/25/03: add error type to dfq_wr_en, dfq_rd_advance
assign  dfq_error_type    = (lsu_dfq_rdata_rq_type[3:0]==4'b1100) ;
//8/25/03: add fwd req to L1I$ for RAMTEST to dfq_wr_en, dfq_rd_dvance
assign  dfq_fwd_req_ic_type  = (lsu_dfq_rdata_rq_type[3:0]==4'b1010) & lsu_dfq_rdata_b103;

assign  dfq_invwy_vld     = lsu_dfq_byp_invwy_vld ;

// if the there is a co-dependent event, then the ifu will not
// be signalled vld until rd_advance is asserted.
//assign  i_and_d_codepend = 
//    ((dfq_ld_type | dfq_ifill_type) &  dfq_invwy_vld)   |
//    (dfq_evict_type | dfq_st_ack_type | dfq_strm_st_ack_type) |
//    dfq_int_type ;

//NOTE: restore cpx_inv qualification after adding cpx_inv part of dfq read - done
//assign  st_rd_advance  =  dfq_byp_st_vld & (~lsu_dfq_byp_cpx_inv | (lsu_dfq_byp_cpx_inv & ~stb_cam_hit_w2)) & dfq_byp_ff_en;
//assign  st_rd_advance  =  dfq_byp_st_vld & dfq_byp_ff_en; // bug:2770
//                          (dfq_byp_st_vld &  lsu_dfq_rdata_stack_iinv_vld & ~ifu_lsu_ibuf_busy) ; // bug:2775

// timing fix: 06/04/03: dfq_rd_advance uses byp_mux output; instead use dfq read output
//             i.e. dfq_rd_advance is valid only when there is a valid entry in dfq
//             it is already qual'ed w/ dfq_rd_vld_d1 to determine this.


assign  st_rd_advance  =  
        (dfq_st_ack_type & dfq_rdata_local_pkt & ~lsu_dfq_rdata_stack_iinv_vld & dfq_byp_ff_en) |
        (dfq_st_ack_type & dfq_rdata_local_pkt &  lsu_dfq_rdata_stack_iinv_vld & ~ifu_lsu_ibuf_busy & dfq_byp_ff_en) ;

// The pointer is advanced based on pre-flop bypass data.

wire inv_clear_d1 ;
dff_s  #(1) invclr_d1 (
        .din    (ifu_lsu_inv_clear),
        .q      (inv_clear_d1),
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        );

//---
// Dealing with skid involving invalidate clear.
// 1. No stall asserted. If the int is immed. preceeded by an inv,
// then the the inv will not be visible thru inv_clear. For this
// reason, int will always wait an additional cycle before examining
// inv_clear.
// 2. In case int has been dispatched to the ifu with stall asserted,
// stalls are conditionally inserted. 
// Note : interrupts are always written into dfq.
//---

wire	dfq_rd_advance_d1 ;
dff_s   rda_d1 (
        .din    (dfq_rd_advance),
        .q      (dfq_rd_advance_d1),
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        );


// Begin Bug 5583
wire	dfq_int_type_d1 ;
wire	int_skid_c1,int_skid_c2;
wire	int_skid_stall ;
dff_s   itype_d1 (
        .din    (dfq_int_type),
        .q      (dfq_int_type_d1),
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        );

// decision made to issue intrpt from dfq even though 
// intr-clear was not high, thus introduce stall for
// 2 more cycles.
assign int_skid_c1 = 
	dfq_int_type_d1 & dfq_rd_advance_d1 & ~inv_clear_d1 ;

dff_s   iskid_c2 (
        .din    (int_skid_c1),
        .q      (int_skid_c2),
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        );

assign	int_skid_stall = int_skid_c1 | int_skid_c2 ;

// End Bug 5583

// timing fix: 06/04/03: dfq_rd_advance uses byp_mux output; instead use dfq read output
//             i.e. dfq_rd_advance is valid only when there is a valid entry in dfq
//             it is already qual'ed w/ dfq_rd_vld_d1 to determine this.
//8/25/03: add error type to dfq_wr_en, dfq_rd_advance
//8/25/03: add fwd req to L1I$ for RAMTEST to dfq_wr_en, dfq_rd_dvance

assign  dfq_rd_advance   =  
  // local st which writes to cache cannot advance if simultaneous cam hit. 
  //((dfq_byp_st_vld & (~cpx_inv | (cpx_inv & ~stb_cam_hit_w2)) & dfq_byp_ff_en)  | 
  (st_rd_advance |
  // advance beyond a dside ld if it can be written to the byp ff
  (dfq_ld_type & ~lsu_dfq_rdata_invwy_vld & dfq_byp_ff_en) |
  // advance beyond a dside & iside ld if it can be written to the byp ff/ibuf clr
  (dfq_ld_type &  lsu_dfq_rdata_invwy_vld & (dfq_byp_ff_en & ~ifu_lsu_ibuf_busy))   |
  // advance beyond a iside ifill if it can be written to the ibuf
  (dfq_ifill_type & ~lsu_dfq_rdata_invwy_vld & ~ifu_lsu_ibuf_busy)      |
  // advance beyond a dside & iside ifill if it can be written to the byp ff/ibuf clr
  (dfq_ifill_type &  lsu_dfq_rdata_invwy_vld & (dfq_byp_ff_en & ~ifu_lsu_ibuf_busy))  |
  // any form of invalidate could invalidate both i and dside.
  ((dfq_evict_type | (dfq_st_ack_type & ~dfq_rdata_local_pkt) | dfq_strm_st_ack_type) & 
        (dfq_byp_ff_en & ~ifu_lsu_ibuf_busy)) |
  // interrupts and flushes have to ensure invalidates are visible in caches.
  // interrupts do not enter d-side byp buffer.  flush needs to look at inv clear.
  (dfq_int_type & (dfq_byp_ff_en & ~ifu_lsu_ibuf_busy & ((inv_clear_d1 & ~dfq_rd_advance_d1) | dfq_stall_d1))) | // Bug 3820.
  //(dfq_int_type & (dfq_byp_ff_en & ~ifu_lsu_ibuf_busy & ((inv_clear_d1 & ~dfq_rd_advance_d1) | dfq_stall_d2))) | // Bug 3820.
  ((dfq_error_type | dfq_fwd_req_ic_type) & ~ifu_lsu_ibuf_busy))
    & dfq_rptr_vld_d1 & ~reset ;

//timing fix: 9/16/03 - dfq_rd_advance is late signal; use it as mux select to pick the correct read pointer
//            add duplicate signal for dfq_rd_advance - has FO16 - adds 3inv to this path
//            fix for dfq_read -> dfq_rd_advance -> dfq_rptr to dfq
wire   dfq_rd_advance_dup ;
assign dfq_rd_advance_dup =  dfq_rd_advance ;

//timing fix: 9/29/03 - instantiate buffer for dfq_rd_advance to dfq_vld_en
bw_u1_buf_30x UZsize_dfq_rd_advance_buf1 ( .a(dfq_rd_advance), .z(dfq_rd_advance_buf1) );

wire	local_flush ;
assign	local_flush = lsu_dfq_byp_type[0] & lsu_dfq_byp_flush & local_pkt & dfq_rd_advance ;

wire	[3:0]	dfq_flsh_cmplt ;
assign	dfq_flsh_cmplt[0] = local_flush & ~lsu_dfq_byp_tid[1] & ~lsu_dfq_byp_tid[0] ;
assign	dfq_flsh_cmplt[1] = local_flush & ~lsu_dfq_byp_tid[1] &  lsu_dfq_byp_tid[0] ;
assign	dfq_flsh_cmplt[2] = local_flush &  lsu_dfq_byp_tid[1] & ~lsu_dfq_byp_tid[0] ;
assign	dfq_flsh_cmplt[3] = local_flush &  lsu_dfq_byp_tid[1] &  lsu_dfq_byp_tid[0] ;

dff_s  #(4) flshcmplt (
        .din    (dfq_flsh_cmplt[3:0]),
        .q      (lsu_dfq_flsh_cmplt[3:0]),
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        );


// Check for extra bubbles in pipeline.
//timing fix: 10/3/03 - use dfq_rd_advance as mux select
//assign  dfq_rptr_new_w_wrap[5:0] =  dfq_rptr_w_wrap[5:0] + {5'b00000, dfq_rd_advance} ;
wire  [5:0]  dfq_rptr_new_w_wrap_inc ;
assign  dfq_rptr_new_w_wrap_inc[5:0] =  dfq_rptr_w_wrap[5:0] + 6'b000001 ;
assign  dfq_rptr_new_w_wrap[5:0]  =  dfq_rd_advance ? dfq_rptr_new_w_wrap_inc[5:0] : dfq_rptr_w_wrap[5:0] ;

// The dfq will always read as long as there is a valid entry.
// ** Design note : If dfq output is held at latches, this is not longer required !! **
//assign  dfq_rptr_vld  =   dfq_vld_entry_exists ;
assign  dfq_rptr_vld  =   dfq_vld_entry_exists_w ;

wire   dfq_rptr_vld_w_d1;

wire dfq_vld_entry_exists_d1;
dff_s   rvld_stgd1_new (
        .din    (dfq_vld_entry_exists), .q  (dfq_vld_entry_exists_d1),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        ); 
dff_s   rvld_stgd1 (
        .din    (dfq_rptr_vld), .q  (dfq_rptr_vld_w_d1),
        //.din    (dfq_rptr_vld), .q  (dfq_rptr_vld_d1),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        ); 
//dff   rdad_stgd1 (
//        .din    (dfq_rd_advance), .q  (dfq_rd_advance_d1),
//        .clk  (clk),
//        .se     (1'b0),       .si (),          .so ()
//        ); 

dffre_s  #(6) dfq_rptr_ff (
        .din    (dfq_rptr_new_w_wrap[5:0]), .q  (dfq_rptr_w_wrap[5:0]),
        .rst    (reset), .en (dfq_rd_advance), .clk (clk),
        .se     (1'b0),       .si (),          .so ()
        ); 

assign  dfq_rptr_vld_d1 = dfq_rptr_vld_w_d1 & dfq_vld_entry_exists_d1;
assign  dfq_rd_vld_d1 = dfq_rptr_vld_d1 ;
//bug4576: add sehold to the dfq_rdata mux select
assign  lsu_dfq_rd_vld_d1 = sehold | dfq_rptr_vld_d1 ;

//timing fix: 9/16/03 - dfq_rd_advance is late signal; use it as mux select to pick the correct read pointer
//            add duplicate signal for dfq_rd_advance - has FO16 - adds 3inv to this path
//            fix for dfq_read -> dfq_rd_advance -> dfq_rptr to dfq
//assign  dfq_rptr[4:0] = dfq_rptr_w_wrap[4:0] + {4'b0000, dfq_rd_advance} ;

//1/20/04: mintime fix - add minbuf to dfq_rptr_w_wrap in dfq_rptr
wire  [4:0]  dfq_rptr_w_wrap_minbuf ;

bw_u1_minbuf_5x UZfix_dfq_rptr_b0 (.a(dfq_rptr_w_wrap[0]), .z(dfq_rptr_w_wrap_minbuf[0]));
bw_u1_minbuf_5x UZfix_dfq_rptr_b1 (.a(dfq_rptr_w_wrap[1]), .z(dfq_rptr_w_wrap_minbuf[1]));
bw_u1_minbuf_5x UZfix_dfq_rptr_b2 (.a(dfq_rptr_w_wrap[2]), .z(dfq_rptr_w_wrap_minbuf[2]));
bw_u1_minbuf_5x UZfix_dfq_rptr_b3 (.a(dfq_rptr_w_wrap[3]), .z(dfq_rptr_w_wrap_minbuf[3]));
bw_u1_minbuf_5x UZfix_dfq_rptr_b4 (.a(dfq_rptr_w_wrap[4]), .z(dfq_rptr_w_wrap_minbuf[4]));

wire  [4:0]  dfq_rptr_inc ;
assign dfq_rptr_inc[4:0]  =  dfq_rptr_w_wrap[4:0] + 5'b00001 ;
assign  dfq_rptr[4:0] = dfq_rd_advance_dup ? dfq_rptr_inc[4:0] : dfq_rptr_w_wrap_minbuf[4:0] ;
//assign  dfq_rptr[4:0] = dfq_rd_advance_dup ? dfq_rptr_inc[4:0] : dfq_rptr_w_wrap[4:0] ;

// Determine whether cfq has crossed high-water mark. IFU must switchout all threads
// for every cycle that this is valid.
// Need to change wptr size once new cfq array description incorporated.
// Wrap bit may not be needed !!!
wire  [5:0] dfq_vld_entries ;
assign  dfq_vld_entries[5:0] = (dfq_wptr_w_wrap[5:0] - dfq_rptr_w_wrap[5:0]) ;
/*assign  dfq_vld_entries[3:0] =
  (dfq_rptr_w_wrap[4] ^ dfq_wptr_w_wrap[4]) ? 
  (dfq_rptr_w_wrap[3:0] - dfq_wptr_w_wrap[3:0]) : (dfq_wptr_w_wrap[3:0] - dfq_rptr_w_wrap[3:0]) ;*/

// High water mark conservatively put at 16-4 = 12
assign	dfq_stall = (dfq_vld_entries[5:0] >= 6'd4) ;
assign  lsu_ifu_stallreq = 
	dfq_stall |  int_skid_stall | lsu_tlbop_force_swo ; 
	//dfq_stall | dfq_stall_d1 | dfq_stall_d2 | int_skid_stall | lsu_tlbop_force_swo ; 

dff_s   dfqst_d1 (
        .din  (dfq_stall), .q  (dfq_stall_d1),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        ); 

//=================================================================================================
//  INVALIDATE PROCESSING
//=================================================================================================

assign  dva_snp_addr_e[`L1D_ADDRESS_HI-6:0]  =  
  lsu_cpx_pkt_ifill_type ? imiss_inv_set_index[6:2] : {lsu_cpx_pkt_inv_pa[`L1D_ADDRESS_HI-6:0]} ; 
// trin: mismatch fine for reconfigurable caches; xinval is not used

//bug3356 - b4 never changed to invalidate the 2nd offset of the i$ fill.
//          l2 now generates b4 in b129 of cpx ifill packet. for ifill pkt
//          b[129] = 0 for 1st ifill packet, b[129]=1 for 2nd ifill packet.

wire    cpxpkt_ifill_b4 ;
assign  cpxpkt_ifill_b4  =  lsu_cpx_pkt_atm_st_cmplt & lsu_cpx_pkt_ifill_type ;

assign  imiss_dcd_b54[0] = ~imiss_inv_set_index[1] & ~cpxpkt_ifill_b4 ;
assign  imiss_dcd_b54[1] = ~imiss_inv_set_index[1] &  cpxpkt_ifill_b4 ;
assign  imiss_dcd_b54[2] =  imiss_inv_set_index[1] & ~cpxpkt_ifill_b4 ;
assign  imiss_dcd_b54[3] =  imiss_inv_set_index[1] &  cpxpkt_ifill_b4 ;

wire  [3:0] perror_dcd_b54 ;
assign  perror_dcd_b54[0] = ~lsu_cpx_pkt_perror_set[1] & ~lsu_cpx_pkt_perror_set[0] ;
assign  perror_dcd_b54[1] = ~lsu_cpx_pkt_perror_set[1] &  lsu_cpx_pkt_perror_set[0] ;
assign  perror_dcd_b54[2] =  lsu_cpx_pkt_perror_set[1] & ~lsu_cpx_pkt_perror_set[0] ;
assign  perror_dcd_b54[3] =  lsu_cpx_pkt_perror_set[1] &  lsu_cpx_pkt_perror_set[0] ;

wire   [3:0]           dva_snp_set_vld_e;      // Lower 2b of cache set index - decoded
wire   [`L1D_WAY_MASK]           dva_snp_wy0_e ;         // way for addr<5:4>=00
wire   [`L1D_WAY_MASK]           dva_snp_wy1_e ;         // way for addr<5:4>=01
wire   [`L1D_WAY_MASK]           dva_snp_wy2_e ;         // way for addr<5:4>=10
wire   [`L1D_WAY_MASK]           dva_snp_wy3_e ;         // way for addr<5:4>=11



/*
assign  dva_snp_set_vld_e[0] = 
lsu_cpx_pkt_ifill_type ? imiss_dcd_b54[0] : 
  lsu_cpx_pkt_perror_dinv ? perror_dcd_b54[0] : cpx_cpu_inv_data[`CPX_AX0_INV_DVLD] ;
assign  dva_snp_set_vld_e[1] = 
lsu_cpx_pkt_ifill_type ? imiss_dcd_b54[1] : 
  lsu_cpx_pkt_perror_dinv ? perror_dcd_b54[1] : cpx_cpu_inv_data[`CPX_AX1_INV_DVLD+4] ;
assign  dva_snp_set_vld_e[2] = 
lsu_cpx_pkt_ifill_type ? imiss_dcd_b54[2] :
  lsu_cpx_pkt_perror_dinv ? perror_dcd_b54[2] : cpx_cpu_inv_data[`CPX_AX0_INV_DVLD+7] ;
assign  dva_snp_set_vld_e[3] = 
lsu_cpx_pkt_ifill_type ? imiss_dcd_b54[3] : 
  lsu_cpx_pkt_perror_dinv ? perror_dcd_b54[3] : cpx_cpu_inv_data[`CPX_AX1_INV_DVLD+11] ; 

assign  dva_snp_wy0_e[1:0]   = 
lsu_cpx_pkt_ifill_type ? lsu_cpx_pkt_invwy[1:0] : cpx_cpu_inv_data[`CPX_AX0_INV_WY_HI:`CPX_AX0_INV_WY_LO];
assign  dva_snp_wy1_e[1:0]   = 
lsu_cpx_pkt_ifill_type ? lsu_cpx_pkt_invwy[1:0] : cpx_cpu_inv_data[`CPX_AX1_INV_WY_HI+4:`CPX_AX1_INV_WY_LO+4];
assign  dva_snp_wy2_e[1:0]   = 
lsu_cpx_pkt_ifill_type ? lsu_cpx_pkt_invwy[1:0] : cpx_cpu_inv_data[`CPX_AX0_INV_WY_HI+7:`CPX_AX0_INV_WY_LO+7];
assign  dva_snp_wy3_e[1:0]   = 
lsu_cpx_pkt_ifill_type ? lsu_cpx_pkt_invwy[1:0] : cpx_cpu_inv_data[`CPX_AX1_INV_WY_HI+11:`CPX_AX1_INV_WY_LO+11];
*/

wire    stack_type_dcfill_vld,
        stack_type_dcfill_vld_d1;
//assign  stack_type_dcfill_vld  =  dfq_st_ack_type & lsu_dfq_byp_stack_dcfill_vld; // bug 2767
//--------------------------------------------------------------
// st_ack_type  local_pkt   b[87]  dcfill_vld==b[151]
//--------------------------------------------------------------
//   1           0          0          -      pkt not modified
//   1           0          1          -      pkt not modified
//--------------------------------------------------------------
//   1           1          0          0      pkt not modified
//   1           1          0          1      pkt modified
//--------------------------------------------------------------
//   1           1          1          0      pkt not modified  <---using b[87] will fail even w/ local pkt qual; hence use b[151]
//   1           1          1          1      pkt modified 
//--------------------------------------------------------------

// 4/7/03: set dcfill_vld only for local dcache data write and not for invalidate
//         atomic and bis do not write dcache and hence dont set dcfill_vld
assign  stack_type_dcfill_vld  =  lsu_dfq_byp_type[2] & local_pkt & lsu_dfq_byp_cpx_inv & ~(lsu_dfq_byp_atm | lsu_dfq_byp_binit_st) ;

wire  [1:0]  lsu_dfq_byp_stack_adr_b54_d1,
             lsu_dfq_byp_stack_wrway_d1;

// bug3375: add enable to this flop - dfq_vld_en
dffe_s #(5)  dfq_by_wrway_ad54_ff (
        .din    ({stack_type_dcfill_vld,lsu_dfq_byp_stack_adr_b54[1:0],lsu_dfq_byp_stack_wrway[1:0]}),
        .q      ({stack_type_dcfill_vld_d1,lsu_dfq_byp_stack_adr_b54_d1[1:0],lsu_dfq_byp_stack_wrway_d1[1:0]}),
        .en     (dfq_vld_en),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        );

//cpx_cpu_inv_data[13:0] =  {dfq_inv_data_b13to9,1'b0,dfq_inv_data_b7to2,1'b0,dfq_inv_data_b0} 
//CPX_AX0_INV_DVLD 0
//CPX_AX0_INV_WY_LO 2
//CPX_AX0_INV_WY_HI 3
//CPX_AX1_INV_DVLD 0
//CPX_AX1_INV_WY_LO 1
//CPX_AX1_INV_WY_HI 2

assign  dva_snp_set_vld_e[0] = 
lsu_cpx_pkt_ifill_type ? imiss_dcd_b54[0] : 
  lsu_cpx_pkt_perror_dinv ? perror_dcd_b54[0] : 
     stack_type_dcfill_vld_d1 ? (lsu_dfq_byp_stack_adr_b54_d1[1:0]==2'b00) : dfq_inv_data_val ;
     //stack_type_dcfill_vld_d1 ? (lsu_dfq_byp_stack_adr_b54_d1[1:0]==2'b00) : cpx_cpu_inv_data[`CPX_AX0_INV_DVLD] ;
assign  dva_snp_set_vld_e[1] = 
lsu_cpx_pkt_ifill_type ? imiss_dcd_b54[1] : 
  lsu_cpx_pkt_perror_dinv ? perror_dcd_b54[1] : 
     stack_type_dcfill_vld_d1 ? (lsu_dfq_byp_stack_adr_b54_d1[1:0]==2'b01) : dfq_inv_data_val;
     //stack_type_dcfill_vld_d1 ? (lsu_dfq_byp_stack_adr_b54_d1[1:0]==2'b01) : cpx_cpu_inv_data[`CPX_AX1_INV_DVLD+4] ;
assign  dva_snp_set_vld_e[2] = 
lsu_cpx_pkt_ifill_type ? imiss_dcd_b54[2] :
  lsu_cpx_pkt_perror_dinv ? perror_dcd_b54[2] : 
     stack_type_dcfill_vld_d1 ? (lsu_dfq_byp_stack_adr_b54_d1[1:0]==2'b10) : dfq_inv_data_val;
     //stack_type_dcfill_vld_d1 ? (lsu_dfq_byp_stack_adr_b54_d1[1:0]==2'b10) : cpx_cpu_inv_data[`CPX_AX0_INV_DVLD+7] ;
assign  dva_snp_set_vld_e[3] = 
lsu_cpx_pkt_ifill_type ? imiss_dcd_b54[3] : 
  lsu_cpx_pkt_perror_dinv ? perror_dcd_b54[3] : 
      stack_type_dcfill_vld_d1 ? (lsu_dfq_byp_stack_adr_b54_d1[1:0]==2'b11) : dfq_inv_data_val;
      //stack_type_dcfill_vld_d1 ? (lsu_dfq_byp_stack_adr_b54_d1[1:0]==2'b11) : cpx_cpu_inv_data[`CPX_AX1_INV_DVLD+11] ; 

assign  dva_snp_wy0_e[`L1D_WAY_MASK]   = 
lsu_cpx_pkt_ifill_type ? lsu_cpx_pkt_invwy[`L1D_WAY_MASK] : 
   stack_type_dcfill_vld_d1 ? lsu_dfq_byp_stack_wrway_d1[`L1D_WAY_MASK] : dfq_inv_data_way;
   //stack_type_dcfill_vld_d1 ? lsu_dfq_byp_stack_wrway_d1[`L1D_WAY_MASK] : cpx_cpu_inv_data[`CPX_AX0_INV_WY_HI:`CPX_AX0_INV_WY_LO] ;
assign  dva_snp_wy1_e[`L1D_WAY_MASK]   = 
lsu_cpx_pkt_ifill_type ? lsu_cpx_pkt_invwy[`L1D_WAY_MASK] : 
   stack_type_dcfill_vld_d1 ? lsu_dfq_byp_stack_wrway_d1[`L1D_WAY_MASK] : dfq_inv_data_way;
   //stack_type_dcfill_vld_d1 ? lsu_dfq_byp_stack_wrway_d1[`L1D_WAY_MASK] : cpx_cpu_inv_data[`CPX_AX1_INV_WY_HI+4:`CPX_AX1_INV_WY_LO+4] ;
assign  dva_snp_wy2_e[`L1D_WAY_MASK]   = 
lsu_cpx_pkt_ifill_type ? lsu_cpx_pkt_invwy[`L1D_WAY_MASK] : 
   stack_type_dcfill_vld_d1 ? lsu_dfq_byp_stack_wrway_d1[`L1D_WAY_MASK] : dfq_inv_data_way;
   //stack_type_dcfill_vld_d1 ? lsu_dfq_byp_stack_wrway_d1[`L1D_WAY_MASK] : cpx_cpu_inv_data[`CPX_AX0_INV_WY_HI+7:`CPX_AX0_INV_WY_LO+7] ;
assign  dva_snp_wy3_e[`L1D_WAY_MASK]   = 
lsu_cpx_pkt_ifill_type ? lsu_cpx_pkt_invwy[`L1D_WAY_MASK] : 
   stack_type_dcfill_vld_d1 ? lsu_dfq_byp_stack_wrway_d1[`L1D_WAY_MASK] : dfq_inv_data_way;
   //stack_type_dcfill_vld_d1 ? lsu_dfq_byp_stack_wrway_d1[`L1D_WAY_MASK] : cpx_cpu_inv_data[`CPX_AX1_INV_WY_HI+11:`CPX_AX1_INV_WY_LO+11] ;



//   wire [1:0] dva_snp_way_e;
//assign dva_snp_way_e[1:0] =  
//  dva_snp_set_vld_e[0] ?  dva_snp_wy0_e[1:0]:
//  dva_snp_set_vld_e[1] ?  dva_snp_wy1_e[1:0]:
//  dva_snp_set_vld_e[2] ?  dva_snp_wy2_e[1:0]:
//  dva_snp_set_vld_e[3] ?  dva_snp_wy3_e[1:0]: 2'bxx;

//bug 2333 fix
//06/09/03: bug 3420 - add logic for dtag parity error invalidate - inv all 4 ways of the index that had error
//bug 3608 - qualify perror_dinv w/ dfq_st_vld
wire     derror_inv_vld ;
assign   derror_inv_vld  =  dfq_st_vld & lsu_cpx_pkt_perror_dinv ;

   // assign dva_snp_bit_wr_en_e [15] =  dva_snp_set_vld_e[3] &  (( dva_snp_wy3_e [1] &  dva_snp_wy3_e[0]) | derror_inv_vld ) ;
   // assign dva_snp_bit_wr_en_e [14] =  dva_snp_set_vld_e[3] &  (( dva_snp_wy3_e [1] & ~dva_snp_wy3_e[0]) | derror_inv_vld );
   // assign dva_snp_bit_wr_en_e [13] =  dva_snp_set_vld_e[3] &  ((~dva_snp_wy3_e [1] &  dva_snp_wy3_e[0]) | derror_inv_vld );
   // assign dva_snp_bit_wr_en_e [12] =  dva_snp_set_vld_e[3] &  ((~dva_snp_wy3_e [1] & ~dva_snp_wy3_e[0]) | derror_inv_vld );
                                                                                               
   // assign dva_snp_bit_wr_en_e [11] =  dva_snp_set_vld_e[2] &  (( dva_snp_wy2_e [1] &  dva_snp_wy2_e[0]) | derror_inv_vld );
   // assign dva_snp_bit_wr_en_e [10] =  dva_snp_set_vld_e[2] &  (( dva_snp_wy2_e [1] & ~dva_snp_wy2_e[0]) | derror_inv_vld );
   // assign dva_snp_bit_wr_en_e [09] =  dva_snp_set_vld_e[2] &  ((~dva_snp_wy2_e [1] &  dva_snp_wy2_e[0]) | derror_inv_vld );
   // assign dva_snp_bit_wr_en_e [08] =  dva_snp_set_vld_e[2] &  ((~dva_snp_wy2_e [1] & ~dva_snp_wy2_e[0]) | derror_inv_vld );
                                                                                               
   // assign dva_snp_bit_wr_en_e [07] =  dva_snp_set_vld_e[1] &  (( dva_snp_wy1_e [1] &  dva_snp_wy1_e[0]) | derror_inv_vld );
   // assign dva_snp_bit_wr_en_e [06] =  dva_snp_set_vld_e[1] &  (( dva_snp_wy1_e [1] & ~dva_snp_wy1_e[0]) | derror_inv_vld );
   // assign dva_snp_bit_wr_en_e [05] =  dva_snp_set_vld_e[1] &  ((~dva_snp_wy1_e [1] &  dva_snp_wy1_e[0]) | derror_inv_vld );
   // assign dva_snp_bit_wr_en_e [04] =  dva_snp_set_vld_e[1] &  ((~dva_snp_wy1_e [1] & ~dva_snp_wy1_e[0]) | derror_inv_vld );
                                                                                               
   // assign dva_snp_bit_wr_en_e [03] =  dva_snp_set_vld_e[0] &  (( dva_snp_wy0_e [1] &  dva_snp_wy0_e[0]) | derror_inv_vld );
   // assign dva_snp_bit_wr_en_e [02] =  dva_snp_set_vld_e[0] &  (( dva_snp_wy0_e [1] & ~dva_snp_wy0_e[0]) | derror_inv_vld );
   // assign dva_snp_bit_wr_en_e [01] =  dva_snp_set_vld_e[0] &  ((~dva_snp_wy0_e [1] &  dva_snp_wy0_e[0]) | derror_inv_vld );
   // assign dva_snp_bit_wr_en_e [00] =  dva_snp_set_vld_e[0] &  ((~dva_snp_wy0_e [1] & ~dva_snp_wy0_e[0]) | derror_inv_vld );
                                                                                               


    assign dva_snp_bit_wr_en_e [(0*`L1D_WAY_COUNT) + 0] =  dva_snp_set_vld_e[0] &  ((dva_snp_wy0_e == 0) | derror_inv_vld );
    assign dva_snp_bit_wr_en_e [(1*`L1D_WAY_COUNT) + 0] =  dva_snp_set_vld_e[1] &  ((dva_snp_wy1_e == 0) | derror_inv_vld );
    assign dva_snp_bit_wr_en_e [(2*`L1D_WAY_COUNT) + 0] =  dva_snp_set_vld_e[2] &  ((dva_snp_wy2_e == 0) | derror_inv_vld );
    assign dva_snp_bit_wr_en_e [(3*`L1D_WAY_COUNT) + 0] =  dva_snp_set_vld_e[3] &  ((dva_snp_wy3_e == 0) | derror_inv_vld );


    assign dva_snp_bit_wr_en_e [(0*`L1D_WAY_COUNT) + 1] =  dva_snp_set_vld_e[0] &  ((dva_snp_wy0_e == 1) | derror_inv_vld );
    assign dva_snp_bit_wr_en_e [(1*`L1D_WAY_COUNT) + 1] =  dva_snp_set_vld_e[1] &  ((dva_snp_wy1_e == 1) | derror_inv_vld );
    assign dva_snp_bit_wr_en_e [(2*`L1D_WAY_COUNT) + 1] =  dva_snp_set_vld_e[2] &  ((dva_snp_wy2_e == 1) | derror_inv_vld );
    assign dva_snp_bit_wr_en_e [(3*`L1D_WAY_COUNT) + 1] =  dva_snp_set_vld_e[3] &  ((dva_snp_wy3_e == 1) | derror_inv_vld );


    assign dva_snp_bit_wr_en_e [(0*`L1D_WAY_COUNT) + 2] =  dva_snp_set_vld_e[0] &  ((dva_snp_wy0_e == 2) | derror_inv_vld );
    assign dva_snp_bit_wr_en_e [(1*`L1D_WAY_COUNT) + 2] =  dva_snp_set_vld_e[1] &  ((dva_snp_wy1_e == 2) | derror_inv_vld );
    assign dva_snp_bit_wr_en_e [(2*`L1D_WAY_COUNT) + 2] =  dva_snp_set_vld_e[2] &  ((dva_snp_wy2_e == 2) | derror_inv_vld );
    assign dva_snp_bit_wr_en_e [(3*`L1D_WAY_COUNT) + 2] =  dva_snp_set_vld_e[3] &  ((dva_snp_wy3_e == 2) | derror_inv_vld );


    assign dva_snp_bit_wr_en_e [(0*`L1D_WAY_COUNT) + 3] =  dva_snp_set_vld_e[0] &  ((dva_snp_wy0_e == 3) | derror_inv_vld );
    assign dva_snp_bit_wr_en_e [(1*`L1D_WAY_COUNT) + 3] =  dva_snp_set_vld_e[1] &  ((dva_snp_wy1_e == 3) | derror_inv_vld );
    assign dva_snp_bit_wr_en_e [(2*`L1D_WAY_COUNT) + 3] =  dva_snp_set_vld_e[2] &  ((dva_snp_wy2_e == 3) | derror_inv_vld );
    assign dva_snp_bit_wr_en_e [(3*`L1D_WAY_COUNT) + 3] =  dva_snp_set_vld_e[3] &  ((dva_snp_wy3_e == 3) | derror_inv_vld );




//=================================================================================================
//  LOCAL ST ACK PROCESSING
//=================================================================================================

// st-ack at head of cfq may write to cache if not indicated as invalid 
// L2.

//wire	byp_tag_perror ;
//assign	byp_tag_perror = lsu_dfq_byp_perror_dinv | lsu_dfq_byp_perror_iinv ;

// one-shot rd-enable for stb for st data.
// st-quad pkt2 will not rd stb
//NOTE: restore cpx_inv qualification after adding cpx_inv part of dfq read - done
/*
assign  st_ack_rq_stb = 
   (dfq_byp_st_vld & st_rd_advance & ~byp_tag_perror)   // local st ack from dfq
  & lsu_dfq_byp_cpx_inv ;
*/
  //((cpx_local_st_ack_type & ~dfq_wr_en & ~(|cpx_spc_data_cx[`CPX_PERR_DINV+1:`CPX_PERR_DINV])) | // local st ack from cpx
  //(dfq_byp_st_vld & dfq_rd_advance & ~byp_tag_perror))   // local st ack from dfq
  //(dfq_byp_st_vld & dfq_rd_advance_d1)) // local st ack from dfq

/*assign  st_ack_rq_stb = 
  ((cpx_local_st_ack_type & ~dfq_wr_en & ~cpx_spc_data_cx[107]) | // local st ack from cpx
  (dfq_byp_st_vld & dfq_rd_advance & ~lsu_dfq_byp_stquad_pkt2))   // local st ack from dfq
  //(dfq_byp_st_vld & dfq_rd_advance_d1)) // local st ack from dfq
  & cpx_inv ; */

/*
dff_s #(1)  stackr_d1 (
        .din    (st_ack_rq_stb),
        .q      (st_ack_rq_stb_d1),
        .clk  (clk),
        .se     (1'b0),       .si (),          .so ()
        );
*/

// Mux's control signal can be flipped - TIMING
//assign  st_ack_tid[1:0] =
//  (dfq_byp_st_vld & dfq_rd_advance) ?  
//	lsu_dfq_byp_tid[1:0] : cpx_spc_data_cx[`CPX_TH_HI:`CPX_TH_LO] ;

// This can be critical !!!
//assign  lsu_st_ack_rq_stb[0] = ~st_ack_tid[1] & ~st_ack_tid[0] & st_ack_rq_stb ;
//assign  lsu_st_ack_rq_stb[1] = ~st_ack_tid[1] &  st_ack_tid[0] & st_ack_rq_stb ;
//assign  lsu_st_ack_rq_stb[2] =  st_ack_tid[1] & ~st_ack_tid[0] & st_ack_rq_stb ;
//assign  lsu_st_ack_rq_stb[3] =  st_ack_tid[1] &  st_ack_tid[0] & st_ack_rq_stb ;

// the ack decode can be combined with the above (grape)

assign  lsu_st_ack_dq_stb[0] = 
	cpx_pkt_thrd_sel[0] & dfq_st_cmplt &
	~(lsu_cpx_pkt_perror_dinv | lsu_cpx_pkt_perror_iinv | lsu_cpx_pkt_binit_st) ;
assign  lsu_st_ack_dq_stb[1] = 
	cpx_pkt_thrd_sel[1] & dfq_st_cmplt &
	~(lsu_cpx_pkt_perror_dinv | lsu_cpx_pkt_perror_iinv | lsu_cpx_pkt_binit_st) ;
assign  lsu_st_ack_dq_stb[2] = 
	cpx_pkt_thrd_sel[2] & dfq_st_cmplt &
	~(lsu_cpx_pkt_perror_dinv | lsu_cpx_pkt_perror_iinv | lsu_cpx_pkt_binit_st) ;
assign  lsu_st_ack_dq_stb[3] = 
	cpx_pkt_thrd_sel[3] & dfq_st_cmplt &
	~(lsu_cpx_pkt_perror_dinv | lsu_cpx_pkt_perror_iinv | lsu_cpx_pkt_binit_st) ;

// Signal rmo ack completion.
assign  lsu_cpx_rmo_st_ack[0] = 
	cpx_pkt_thrd_sel[0] & dfq_st_cmplt  & lsu_cpx_pkt_binit_st ;
assign  lsu_cpx_rmo_st_ack[1] = 
	cpx_pkt_thrd_sel[1] & dfq_st_cmplt  & lsu_cpx_pkt_binit_st ;
assign  lsu_cpx_rmo_st_ack[2] = 
	cpx_pkt_thrd_sel[2] & dfq_st_cmplt  & lsu_cpx_pkt_binit_st ;
assign  lsu_cpx_rmo_st_ack[3] = 
	cpx_pkt_thrd_sel[3] & dfq_st_cmplt  & lsu_cpx_pkt_binit_st ;

assign  lsu_st_wr_dcache = stwr_active_e ;

//assign  lsu_st_wr_sel_e = stwr_active_e |  lsu_diagnstc_wr_src_sel_e ;

//=================================================================================================
//  CPX PKT DECODE
//=================================================================================================

// The decode is meant to qualify writes into the dfq.
// These values are also stored in the dfq to save on decode at the head of the queue.

assign lsu_cpxpkt_type_dcd_cx[5:0] = 
{cpx_ld_type,cpx_ifill_type,cpx_evict_type,cpx_st_ack_type,cpx_strm_st_ack_type,cpx_int_type};

assign  cpx_ld_type = 
         cpx_spc_data_cx_b144to140[`CPX_VLD] &
        ((~cpx_spc_data_cx_b144to140[`CPX_RQ_HI]   & ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO+2] & // 0000
          ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO+1] & ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO]));

assign  cpx_ifill_type = 
         cpx_spc_data_cx_b144to140[`CPX_VLD] &
        ((~cpx_spc_data_cx_b144to140[`CPX_RQ_HI]   & ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO+2] & // 0001
          ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO+1] &  cpx_spc_data_cx_b144to140[`CPX_RQ_LO]));

assign  cpx_evict_type = 
         cpx_spc_data_cx_b144to140[`CPX_VLD] &
        ((~cpx_spc_data_cx_b144to140[`CPX_RQ_HI]   & ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO+2] & // 0011
           cpx_spc_data_cx_b144to140[`CPX_RQ_LO+1] &  cpx_spc_data_cx_b144to140[`CPX_RQ_LO]));

assign  cpx_st_ack_type =
         cpx_spc_data_cx_b144to140[`CPX_VLD] &
        ((~cpx_spc_data_cx_b144to140[`CPX_RQ_HI]  &   cpx_spc_data_cx_b144to140[`CPX_RQ_LO+2] & // 0100
          ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO+1] & ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO])); 
         //~cpx_spc_data_cx[108] ;  // 1st stquad ack is rejected

assign  cpx_strm_st_ack_type =
         cpx_spc_data_cx_b144to140[`CPX_VLD] &
        ((~cpx_spc_data_cx_b144to140[`CPX_RQ_HI]   &  cpx_spc_data_cx_b144to140[`CPX_RQ_LO+2] & // 0110
           cpx_spc_data_cx_b144to140[`CPX_RQ_LO+1] & ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO]));

assign  cpx_int_type =
         cpx_spc_data_cx_b144to140[`CPX_VLD] &
        ((~cpx_spc_data_cx_b144to140[`CPX_RQ_HI]   &  cpx_spc_data_cx_b144to140[`CPX_RQ_LO+2] & // 0111
           cpx_spc_data_cx_b144to140[`CPX_RQ_LO+1] &  cpx_spc_data_cx_b144to140[`CPX_RQ_LO]));

//bug3657  - kill ifill vld in bypass path when cpxtype=fp/fwd_reply

assign  cpx_fp_type =
         cpx_spc_data_cx_b144to140[`CPX_VLD] &
        (( cpx_spc_data_cx_b144to140[`CPX_RQ_HI]   & ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO+2] & // 1000
          ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO+1] & ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO]));

//8/25/03: add error type to dfq_wr_en, dfq_rd_advance
assign  cpx_error_type =
         cpx_spc_data_cx_b144to140[`CPX_VLD] &
        (( cpx_spc_data_cx_b144to140[`CPX_RQ_HI]   &  cpx_spc_data_cx_b144to140[`CPX_RQ_LO+2] & // 1100
          ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO+1] & ~cpx_spc_data_cx_b144to140[`CPX_RQ_LO]));

// Miscellaneous cpu based decode

assign  lsu_cpu_dcd_sel[7:0]  = {cpu_sel[3:0],cpu_sel[3:0]} ;
assign  lsu_cpu_uhlf_sel  = const_cpuid[2] ;

// removed cpu_id[2] qual in the eqn.
assign  cpu_sel[0] =  ~const_cpuid[1] & ~const_cpuid[0] ;
assign  cpu_sel[1] =  ~const_cpuid[1] &  const_cpuid[0] ;
assign  cpu_sel[2] =   const_cpuid[1] & ~const_cpuid[0] ;
assign  cpu_sel[3] =   const_cpuid[1] &  const_cpuid[0] ;


// st ack to respective stb's. will not be generated for blk init stores
// as such stores have already been deallocated.

assign  cpx_local_st_ack_type = 
  cpx_st_ack_type & (const_cpuid[2:0] == cpx_spc_data_cx_b120to118[`CPX_INV_CID_HI:`CPX_INV_CID_LO]) ;
 // & ~(cpx_spc_data_cx[`CPX_BINIT_STACK] | (|cpx_spc_data_cx[`CPX_PERR_DINV+1:`CPX_PERR_DINV])) ;

wire	squash_ack ;
assign squash_ack =
(cpx_spc_data_cx_b125 | (|cpx_spc_data_cx_b124to123[`CPX_PERR_DINV+1:`CPX_PERR_DINV])) ;

assign  cpx_st_ack_tid0 = cpx_local_st_ack_type & ~squash_ack &
                        ~cpx_spc_data_cx_b135to134[`CPX_TH_HI] & ~cpx_spc_data_cx_b135to134[`CPX_TH_LO] ;
                        //~cpx_spc_data_cx[125] ; // rmo st will not ack
                        //~cpx_spc_data_cx[`CPX_WY_LO] ; // stquad1 will not ack - just invalidate.
                                                      // b131 of cpx pkt used.  

assign  cpx_st_ack_tid1 = cpx_local_st_ack_type & ~squash_ack &
                        ~cpx_spc_data_cx_b135to134[`CPX_TH_HI] &  cpx_spc_data_cx_b135to134[`CPX_TH_LO] ;
                        //~cpx_spc_data_cx[125] ; // rmo st will not ack
                        //~cpx_spc_data_cx[`CPX_WY_LO] ; // stquad1 will not ack - just invalidate.
                                                      // b131 of cpx pkt used.

assign  cpx_st_ack_tid2 = cpx_local_st_ack_type & ~squash_ack &
                         cpx_spc_data_cx_b135to134[`CPX_TH_HI] & ~cpx_spc_data_cx_b135to134[`CPX_TH_LO] ;
                        //~cpx_spc_data_cx[125] ; // rmo st will not ack
                        //~cpx_spc_data_cx[`CPX_WY_LO] ; // stquad1 will not ack - just invalidate.
                                                      // b131 of cpx pkt used. 

assign  cpx_st_ack_tid3 = cpx_local_st_ack_type & ~squash_ack &
                         cpx_spc_data_cx_b135to134[`CPX_TH_HI] & cpx_spc_data_cx_b135to134[`CPX_TH_LO] ;
                        //~cpx_spc_data_cx[125] ; // rmo st will not ack
                        //~cpx_spc_data_cx[`CPX_WY_LO] ; // stquad1 will not ack - just invalidate.
                                                      // b131 of cpx pkt used.

// Performance Ctr Info
//assign lsu_tlu_l2_dmiss[0] =  dfill_dcd_thrd[0] & dcfill_active_e & lsu_cpx_pkt_l2miss ;
assign lsu_tlu_l2_dmiss[0] =  dfq_thread0 & dcfill_active_e & lsu_cpx_pkt_l2miss ;
assign lsu_tlu_l2_dmiss[1] =  dfq_thread1 & dcfill_active_e & lsu_cpx_pkt_l2miss ;
assign lsu_tlu_l2_dmiss[2] =  dfq_thread2 & dcfill_active_e & lsu_cpx_pkt_l2miss ;
assign lsu_tlu_l2_dmiss[3] =  dfq_thread3 & dcfill_active_e & lsu_cpx_pkt_l2miss ;

//=================================================================================================
//  GENERATE b[151] of DFQ WRITE DATA
//=================================================================================================
wire  [7:0]  cpx_inv_vld;
wire  [7:0]  cpu_sel_dcd;

// assign  cpx_inv_vld[0] = cpx_spc_data_cx_b88 |
//                          cpx_spc_data_cx_b56 |
//                          cpx_spc_data_cx_b32 |
//                          cpx_spc_data_cx_b0 ;

assign  cpx_inv_vld[0] = cpx_spc_data_cx_dcache_inval_val;
assign  cpx_inv_vld[7:1] = 7'b0;

assign cpu_sel_dcd[7:4] =  ({4{ lsu_cpu_uhlf_sel}} & cpu_sel[3:0]);
assign cpu_sel_dcd[3:0] =  ({4{~lsu_cpu_uhlf_sel}} & cpu_sel[3:0]);

assign lsu_cpx_spc_inv_vld  =  |(cpx_inv_vld[7:0] & cpu_sel_dcd[7:0]);

//=================================================================================================
//  GENERATE ICACHE INVALIDATE VALID (bug:2770)
//=================================================================================================

wire  [7:0]  cpx_iinv_vld;
wire         cpx_spc_iinv_vld;

// assign  cpx_iinv_vld[0] = cpx_spc_data_cx_b57 |
//                           cpx_spc_data_cx_b1  ;

// assign  cpx_iinv_vld[1] = cpx_spc_data_cx_b61 |
//                           cpx_spc_data_cx_b5  ;

// assign  cpx_iinv_vld[2] = cpx_spc_data_cx_b65 |
//                           cpx_spc_data_cx_b9  ;

// assign  cpx_iinv_vld[3] = cpx_spc_data_cx_b69 |
//                           cpx_spc_data_cx_b13 ;

// assign  cpx_iinv_vld[4] = cpx_spc_data_cx_b73 |
//                           cpx_spc_data_cx_b17 ;

// assign  cpx_iinv_vld[5] = cpx_spc_data_cx_b77 |
//                           cpx_spc_data_cx_b21 ;

// assign  cpx_iinv_vld[6] = cpx_spc_data_cx_b81 |
//                           cpx_spc_data_cx_b25 ;

// assign  cpx_iinv_vld[7] = cpx_spc_data_cx_b85 |
//                           cpx_spc_data_cx_b29 ;

assign cpx_iinv_vld[0] = cpx_spc_data_cx_icache_inval_val;
assign cpx_iinv_vld[7:1] = 7'b0;

//bug3701 - include i$ parity error invalidate - b[124]
assign cpx_spc_iinv_vld  =  |( (cpx_iinv_vld[7:0] | {8{cpx_spc_data_cx_b124to123[`CPX_PERR_DINV+1]}}) & cpu_sel_dcd[7:0] )  ;


// dfq_rd_advance - local st ack not qualified w/ ifu_lsu_ibuf_busy
// qualify ifu_busy w/ local_st_ack=1 and iinv=1

assign lsu_cpx_stack_icfill_vld  =  
                  ( cpx_local_st_ack_type & cpx_spc_iinv_vld) |	       //if local st_ack=1, b[128]=iinv
                  (~cpx_local_st_ack_type & cpx_spc_data_cx_b128) ;    //if local st_ack=0, b[128]=cpx_data[128]

//=================================================================================================
//  MISC QDP2 MUX SELECTS
//=================================================================================================

//assign  lsu_dcfill_mx_sel_e[0]  =  lsu_dc_iob_access_e;
//assign  lsu_dcfill_mx_sel_e[1]  =  lsu_bist_wvld_e | lsu_bist_rvld_e;
//assign  lsu_dcfill_mx_sel_e[2]  =  lsu_diagnstc_wr_src_sel_e;
//assign  lsu_dcfill_mx_sel_e[3]  =  ~|lsu_dcfill_mx_sel_e[2:0];

//assign  lsu_dcfill_addr_mx_sel_e  =  ~|lsu_dcfill_mx_sel_e[1:0];

//assign  lsu_dcfill_data_mx_sel_e  =  lsu_dc_iob_access_e | lsu_bist_wvld_e;

assign lsu_cpx_thrdid[0]  =  ~cpx_spc_data_cx_b135to134[`CPX_TH_HI] & ~cpx_spc_data_cx_b135to134[`CPX_TH_LO] ;
assign lsu_cpx_thrdid[1]  =  ~cpx_spc_data_cx_b135to134[`CPX_TH_HI] &  cpx_spc_data_cx_b135to134[`CPX_TH_LO] ;
assign lsu_cpx_thrdid[2]  =   cpx_spc_data_cx_b135to134[`CPX_TH_HI] & ~cpx_spc_data_cx_b135to134[`CPX_TH_LO] ;
assign lsu_cpx_thrdid[3]  =   cpx_spc_data_cx_b135to134[`CPX_TH_HI] &  cpx_spc_data_cx_b135to134[`CPX_TH_LO] ;

// modify cpx packet only if dcache update from stb has to be made. 
// lsu_cpx_spc_inv_vld = 1 => invalidate dcache for atomic- b[129] and bst- b[125]
// 			      update dcache for other requests
//
// i.e. cpx_pkt==st_ack and local and dcfill_vld=1; if dcfill_vld==0, ifill info
// has to be left as is. hence no pkt modification

assign lsu_cpx_stack_dcfill_vld  =  
                       (cpx_local_st_ack_type & ~(cpx_spc_data_cx_b129 | cpx_spc_data_cx_b125))  &
                       lsu_cpx_spc_inv_vld ;

//timing fix: 6/16/03 - fix for ifill_pkt_vld - use b130 if store_ack_dcfill_vld=1
//bug3582 - b[130] for store ack is a dont-care i.e. capture b[130] only if packet type is not store ack
assign lsu_cpx_stack_dcfill_vld_b130  =  // if lsu_cpx_stack_dcfill_vld=1 b[130]=lsu_cpx_stack_dcfill_vld
                                         // if cpx_st_ack=0 b[130]=cpx_data[130]
                                       lsu_cpx_stack_dcfill_vld |    
                                       (~cpx_st_ack_type & cpx_spc_data_cx_b130) ;
endmodule

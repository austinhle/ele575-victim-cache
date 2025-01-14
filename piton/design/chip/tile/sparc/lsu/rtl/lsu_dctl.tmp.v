// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: lsu_dctl.v
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





/////////////////////////////////////////////////////////////////
/*
//  Description:  LSU Data Cache Control and Minor Datapath
//      - Tag Comparison - hit/miss.
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include  "sys.h" // system level definition file which contains the 
          // time scale definition

////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////
`include  "lsu.tmp.h"

module lsu_dctl ( /*AUTOARG*/
   // Outputs
  `ifndef NO_RTL_CSM
  csm_rd_vld_g, lsu_tlb_csm_rd_vld_g, lsu_dtlb_csm_rd_e, lsu_blkst_csm_m,
  `endif
   stb_ncache_pcx_rq_g,
   lsu_tlu_nucleus_ctxt_m, lsu_quad_word_access_g, so, dctl_rst_l, 
   lsu_tlu_wsr_inst_e, lsu_l2fill_fpld_e, dva_vld_m_bf, 
   lsu_no_spc_pref, ifu_tlu_flush_fd_w, ifu_tlu_flush_fd2_w, 
   ifu_tlu_flush_fd3_w, ifu_lsu_flush_w, lsu_tlu_thrid_d, 
   lsu_diagnstc_data_sel, lsu_diagnstc_va_sel, lsu_err_addr_sel, 
   dva_bit_wr_en_e, dva_wr_adr_e, lsu_exu_ldst_miss_w2, 
   lsu_exu_dfill_vld_w2, lsu_ffu_ld_vld, lsu_ld_miss_wb, 
   lsu_dtlb_bypass_e, ld_pcx_pkt_g, tlb_ldst_cam_vld, ldxa_internal, 
   lsu_ifu_ldsta_internal_e, lsu_ifu_ldst_cmplt, lsu_ifu_itlb_en, 
   lsu_ifu_icache_en, lmq_byp_data_en_w2, lmq_byp_data_fmx_sel, 
   lmq_byp_data_mxsel0, lmq_byp_data_mxsel1, lmq_byp_data_mxsel2, 
   lmq_byp_data_mxsel3, lmq_byp_ldxa_mxsel0, lmq_byp_ldxa_mxsel1, 
   lmq_byp_ldxa_mxsel2, lmq_byp_ldxa_mxsel3, lsu_ld_thrd_byp_sel_e, 
   dcache_byte_wr_en_e, lsu_dcache_wr_vld_e, lsu_ldstub_g, 
   lsu_swap_g, lsu_tlu_dtlb_done, lsu_exu_thr_m, merge7_sel_byte0_m, 
   merge7_sel_byte7_m, merge6_sel_byte1_m, merge6_sel_byte6_m, 
   merge5_sel_byte2_m, merge5_sel_byte5_m, merge4_sel_byte3_m, 
   merge4_sel_byte4_m, merge3_sel_byte0_m, merge3_sel_byte3_m, 
   merge3_sel_byte4_m, merge3_sel_byte7_default_m, merge3_sel_byte_m, 
   merge2_sel_byte1_m, merge2_sel_byte2_m, merge2_sel_byte5_m, 
   merge2_sel_byte6_default_m, merge2_sel_byte_m, merge0_sel_byte0_m, 
   merge0_sel_byte1_m, merge0_sel_byte2_m, 
   merge0_sel_byte3_default_m, merge0_sel_byte4_m, 
   merge0_sel_byte5_m, merge0_sel_byte6_m, 
   merge0_sel_byte7_default_m, merge1_sel_byte0_m, 
   merge1_sel_byte1_m, merge1_sel_byte2_m, 
   merge1_sel_byte3_default_m, merge1_sel_byte4_m, 
   merge1_sel_byte5_m, merge1_sel_byte6_m, 
   merge1_sel_byte7_default_m, merge0_sel_byte_1h_m, 
   merge1_sel_byte_1h_m, merge1_sel_byte_2h_m, lsu_dtlb_cam_real_e, 
   lsu_dtagv_wr_vld_e, lsu_dtag_wrreq_x_e, lsu_dtag_index_sel_x_e, 
   lsu_dtlb_wr_vld_e, lsu_dtlb_tag_rd_e, lsu_dtlb_data_rd_e, 
   lsu_dtlb_dmp_vld_e, lsu_dtlb_dmp_all_e, lsu_dtlb_rwindex_vld_e, 
   lsu_dtlb_invalid_all_l_m, lsu_tlu_tlb_ld_inst_m, 
   lsu_tlu_tlb_st_inst_m, lsu_tlu_tlb_access_tid_m, 
   lsu_tlb_data_rd_vld_g, lsu_tlb_st_sel_m, lsu_va_wtchpt0_wr_en_l, 
   lsu_va_wtchpt1_wr_en_l, lsu_va_wtchpt2_wr_en_l, 
   lsu_va_wtchpt3_wr_en_l, thread0_m, thread1_m, thread2_m, 
   thread3_m, lsu_dctldp_thread0_m, lsu_dctldp_thread1_m, 
   lsu_dctldp_thread2_m, lsu_dctldp_thread3_m, thread0_g, thread1_g, 
   thread2_g, thread3_g, lsu_tlu_nonalt_ldst_m, 
   lsu_tlu_xslating_ldst_m, lsu_tlu_ctxt_sel_m, lsu_tlu_write_op_m, 
   lsu_dtlb_addr_mask_l_e, dva_din_e, 
   lsu_diagnstc_dtagv_prty_invrt_e, lsu_ifu_asi_load, 
   lsu_ifu_asi_thrid, lsu_ifu_asi_vld, lsu_quad_asi_e, 
   lsu_local_ldxa_sel_g, lsu_dtag_rsel_m, lsu_tlbop_force_swo, 
   lsu_atomic_pkt2_bsel_g, lsu_dcache_tag_perror_g, 
   lsu_dcache_data_perror_g, lsu_ifu_l2_unc_error, 
   lsu_ifu_l2_corr_error, lsu_ifu_dcache_data_perror, 
   lsu_ifu_dcache_tag_perror, lsu_ifu_error_tid, lsu_ifu_io_error, 
   lsu_tlu_squash_va_oor_m, lsu_squash_va_oor_m, tlb_cam_hit_g, 
   lsu_st_hw_le_g, lsu_st_w_or_dbl_le_g, lsu_st_x_le_g, 
   lsu_swap_sel_default_g, lsu_swap_sel_default_byte_7_2_g, 
   lsu_st_rmo_m, lsu_bst_in_pipe_m, lsu_snap_blk_st_m, lsu_blk_st_m, 
   lsu_blkst_pgnum_m, lsu_ffu_blk_asi_e, lsu_blk_asi_m, 
   lsu_nonalt_nucl_access_m, dcache_alt_mx_sel_e, 
   dcache_alt_mx_sel_e_bf, dcache_rvld_e, lsu_dc_iob_access_e, 
   lsu_ifu_ldst_miss_w, lsu_ifu_dc_parity_error_w2, 
   lsu_ldst_inst_vld_e, lsu_local_ldxa_tlbrd_sel_g, 
   lsu_local_diagnstc_tagrd_sel_g, lsu_va_wtchpt_sel_g, 
   asi_state_wr_thrd, thread0_d, thread1_d, thread2_d, thread3_d, 
   tlu_lsu_asi_update_g, pctxt_state_wr_thrd, sctxt_state_wr_thrd, 
   thread_pctxt, thread_sctxt, thread_actxt, thread_default, 
   thread0_ctxt, thread1_ctxt, thread2_ctxt, thread3_ctxt, 
   pid_state_wr_en, thread0_e, thread1_e, thread2_e, thread3_e, 
   dfture_tap_wr_mx_sel, lctl_rst, lsu_ctl_state_wr_en, 
   lsuctl_ctlbits_wr_en, dfture_tap_rd_en, bist_tap_wr_en, 
   bistctl_wr_en, bist_ctl_reg_wr_en, mrgn_tap_wr_en, ldiagctl_wr_en, 
   misc_ctl_sel_din, lsu_asi_sel_fmx1, lsu_asi_sel_fmx2, 
   tlb_access_en0_g, tlb_access_en1_g, tlb_access_en2_g, 
   tlb_access_en3_g, tlb_access_sel_thrd0, tlb_access_sel_thrd1, 
   tlb_access_sel_thrd2, tlb_access_sel_default, mrgnctl_wr_en, 
   hpv_priv_m, hpstate_en_m, dcache_arry_data_sel_m, dtlb_bypass_m, 
   lsu_alt_space_m, atomic_m, ldst_dbl_m, fp_ldst_m, lda_internal_m, 
   sta_internal_m, cam_real_m, data_rd_vld_g, tag_rd_vld_g, 
   ldst_sz_m, asi_internal_m, rd_only_ltlb_asi_e, wr_only_ltlb_asi_e, 
   dfill_tlb_asi_e, ifill_tlb_asi_e, nofault_asi_m, as_if_user_asi_m, 
   atomic_asi_m, phy_use_ec_asi_m, phy_byp_ec_asi_m, quad_asi_m, 
   binit_quad_asi_m, blk_asi_m, recognized_asi_m, strm_asi_m, 
   mmu_rd_only_asi_m, rd_only_asi_m, wr_only_asi_m, unimp_asi_m, 
   va_wtchpt_cmp_en_m, lsu_tlu_async_ttype_vld_w2, 
   lsu_tlu_async_ttype_w2, lsu_tlu_async_tid_w2, async_tlb_index, 
   l2fill_vld_m, ld_thrd_byp_mxsel_m, morphed_addr_m, 
   signed_ldst_byte_m, signed_ldst_hw_m, signed_ldst_w_m, 
   lsu_tlb_asi_data_perr_g, lsu_tlb_asi_tag_perr_g, lsu_sscan_data, 
   lsu_ld_inst_vld_g, lsu_dcache_rand, lsu_encd_way_hit, 
   lsu_way_hit_or, lsu_memref_m, lsu_flsh_inst_m, 
   lsu_ifu_asi_data_en_l, lsu_dcache_fill_addr_e, 
   lsu_dcache_fill_addr_e_err, lsu_thread_g, lmq_ldd_vld, 
   lsu_bist_rsel_way_e, lsu_dcache_fill_way_e, lmq_ld_addr_b3, 
   lsu_outstanding_rmo_st_max, lsu_dcfill_data_mx_sel_e, 
   // Inputs

  `ifndef NO_RTL_CSM
   tlu_dtlb_csm_rd_g, tlb_rd_tte_csm,
  `endif
   si, se, sehold, rst_tri_en, rclk, grst_l, arst_l, 
   lsu_diag_va_prty_invrt, dva_svld_e, dva_snp_bit_wr_en_e, 
   dva_snp_addr_e, lsu_tte_data_cp_g, lsu_l2fill_vld, ld_inst_vld_e, 
   st_inst_vld_e, ifu_lsu_ldst_fp_e, ldst_sz_e, 
   lsu_ldst_va_b12_b11_m, lsu_ldst_va_b7_b0_m, ifu_lsu_rd_e, 
   tlb_cam_hit, ifu_tlu_sraddr_d, ifu_tlu_wsr_inst_d, 
   ifu_lsu_alt_space_d, tlu_lsu_int_ldxa_vld_w2, 
   tlu_lsu_int_ld_ill_va_w2, tlu_lsu_ldxa_tid_w2, 
   ifu_lsu_ldxa_data_vld_w2, ifu_lsu_ldxa_illgl_va_w2, 
   ifu_lsu_ldxa_tid_w2, ifu_lsu_asi_rd_unc, tlu_lsu_tl_zero, 
   ifu_lsu_thrid_s, ifu_lsu_ldst_dbl_e, ld_stb_full_raw_w2, 
   ld_sec_active, ifu_tlu_inst_vld_m, lsu_l2fill_bendian_m, 
   lmq0_l2fill_fpld, lmq1_l2fill_fpld, lmq2_l2fill_fpld, 
   lmq3_l2fill_fpld, cache_way_hit_buf1, cache_hit, lmq0_byp_misc_sz, 
   lmq1_byp_misc_sz, lmq2_byp_misc_sz, lmq3_byp_misc_sz, 
   lsu_l2fill_sign_extend_m, lsu_l1hit_sign_extend_e, 
   tlu_lsu_pstate_cle, tlu_lsu_pstate_am, tlb_pgnum, tlb_demap_nctxt, 
   tlb_demap_pctxt, tlb_demap_sctxt, tlb_demap_actxt, 
   tlb_demap_thrid, ifu_lsu_casa_e, ifu_lsu_ldstub_e, ifu_lsu_swap_e, 
   lsu_atm_st_cmplt_e, lsu_cpx_pkt_atm_st_cmplt, 
   spu_lsu_ldxa_data_vld_w2, spu_lsu_ldxa_illgl_va_w2, 
   spu_lsu_ldxa_tid_w2, spu_lsu_stxa_ack_tid, spu_lsu_stxa_ack, 
   spu_lsu_unc_error_w2, spu_lsu_int_w2, tlu_lsu_stxa_ack, 
   tlu_lsu_stxa_ack_tid, lsu_tlb_invert_endian_g, lmq0_ncache_ld, 
   lmq1_ncache_ld, lmq2_ncache_ld, lmq3_ncache_ld, ifu_tlu_mb_inst_e, 
   ifu_tlu_flsh_inst_e, lsu_stb_empty, tlu_dtlb_tag_rd_g, 
   tlu_dtlb_data_rd_g, tlu_dtlb_dmp_vld_g, tlu_dtlb_dmp_all_g, 
   tlu_dtlb_rw_index_vld_g, tlu_dtlb_invalidate_all_g, 
   lsu_st_wr_dcache, tlu_lsu_asi_update_m, tlu_lsu_tid_m, 
   lsu_rd_dtag_parity_g, dcache_rparity_err_wb, 
   lsu_diagnstc_wr_data_b0, lsu_byp_ldd_oddrd_m, tlu_lsu_redmode, 
   tlu_lsu_redmode_rst_d1, dva_vld_m, lsu_dfill_tid_e, 
   ifu_lsu_asi_ack, lsu_intrpt_cmplt, lsu_iobrdge_tap_rq_type_b8, 
   lsu_iobrdge_tap_rq_type_b6_b3, lsu_iobrdge_tap_rq_type_b1_b0, 
   lsu_iobrdge_fwd_pkt_vld, lsu_cpx_ld_dtag_perror_e, 
   lsu_cpx_ld_dcache_perror_e, lsu_cpx_pkt_ld_err, ifu_lsu_nceen, 
   tlu_lsu_ldxa_async_data_vld, tlu_lsu_hpv_priv, tlu_lsu_hpstate_en, 
   ifu_lsu_memref_d, ifu_lsu_pref_inst_e, lsu_pref_pcx_req, 
   lsu_cpx_pkt_prefetch2, lsu_ld_pcx_rq_sel_d2, 
   lsu_pcx_req_squash_d1, lsu_bld_helper_cmplt_m, lsu_bld_cnt_m, 
   lsu_bld_reset, ffu_lsu_blk_st_e, lsu_stb_rmo_st_issue, 
   lsu_cpx_rmo_st_ack, lsu_dfq_flsh_cmplt, stb_cam_hit, 
   ifu_tlu_flush_m, ctu_sscan_tid, tte_data_perror_unc, 
   asi_tte_data_perror, asi_tte_tag_perror, tlu_dtlb_rw_index_g, 
   lsu_local_early_flush_g, lsu_dfq_vld, gdbginit_l, dc_direct_map, 
   asi_d, lsu_dctl_asi_state_m, lsu_ldst_va_g, lsu_ifu_err_addr_b39, 
   lsu_dp_ctl_reg0, lsu_dp_ctl_reg1, lsu_dp_ctl_reg2, 
   lsu_dp_ctl_reg3, ldd_in_dfq_out, dcache_iob_addr_e, 
   mbist_dcache_index, mbist_dcache_word, lsu_diagnstc_wr_addr_e, 
   st_dcfill_addr, lsu_dfq_ld_vld, lsu_dfq_st_vld, lmq0_ldd_vld, 
   lmq1_ldd_vld, lmq2_ldd_vld, lmq3_ldd_vld, lsu_dfq_byp_tid, 
   dfq_byp_ff_en, lsu_dcache_iob_way_e, mbist_dcache_way, 
   lsu_diagnstc_wr_way_e, lsu_st_way_e, lmq0_pcx_pkt_way, 
   lmq1_pcx_pkt_way, lmq2_pcx_pkt_way, lmq3_pcx_pkt_way, 
   lmq0_ld_rq_type, lmq1_ld_rq_type, lmq2_ld_rq_type, 
   lmq3_ld_rq_type, lmq0_pcx_pkt_addr, lmq1_pcx_pkt_addr, 
   lmq2_pcx_pkt_addr, lmq3_pcx_pkt_addr, lsu_ttype_vld_m2, 
   tlu_early_flush_pipe2_w, lsu_st_dcfill_size_e, mbist_dcache_write, 
   mbist_dcache_read,
   cfg_asi_lsu_ldxa_vld_w2, cfg_asi_lsu_ldxa_tid_w2
   ) ;  


output                  lsu_tlu_nucleus_ctxt_m ;// access is nucleus context 
output			lsu_quad_word_access_g ; // 128b ld request.

input si;
input se;
input sehold ;
input rst_tri_en ;
output so;    

input      rclk ;
input                   grst_l;
input                   arst_l;
output     dctl_rst_l;

input  lsu_diag_va_prty_invrt ;

   input         dva_svld_e ;
   input [`L1D_VAL_ARRAY_HI:0] dva_snp_bit_wr_en_e;
   input [`L1D_ADDRESS_HI-6:0]  dva_snp_addr_e;

input	      lsu_tte_data_cp_g ; // cp bit from tlb    
input         lsu_l2fill_vld ;    // fill from dfq to d$.
input         ld_inst_vld_e ;     // load accesses d$.
input         st_inst_vld_e ;     // load accesses d$.
input         ifu_lsu_ldst_fp_e ; // fp load or store
input [1:0]   ldst_sz_e ;         // sz of ld/st xsaction.


input [12:11]  lsu_ldst_va_b12_b11_m;      
input [7:0]    lsu_ldst_va_b7_b0_m;      

input [4:0]   ifu_lsu_rd_e;           // primary rd of ld
input         tlb_cam_hit ;           // xlation hits in tlb.     
// Read/Write Privileged State Register Access.
input [6:0]   ifu_tlu_sraddr_d ;      // addr of sr(st/pr)

input         ifu_tlu_wsr_inst_d ;    // valid wr sr(st/pr)
output        lsu_tlu_wsr_inst_e ;    // valid wr sr(st/pr)

input         ifu_lsu_alt_space_d;        // alternate space ld/st

input         tlu_lsu_int_ldxa_vld_w2 ;  // tlu ldxa data is valid (intrpt/scpd)
input         tlu_lsu_int_ld_ill_va_w2 ;  // tlu ldxa'va is invalid (intrpt/scpd)

input [1:0]   tlu_lsu_ldxa_tid_w2 ;       // thread id for tlu ldxa data. 

input         ifu_lsu_ldxa_data_vld_w2 ;  // ifu ldxa data is valid
input         ifu_lsu_ldxa_illgl_va_w2 ;  // ifu ldxa with illgl va
input [1:0]   ifu_lsu_ldxa_tid_w2   ;     // thread id for ifu ldxa data. 
input         ifu_lsu_asi_rd_unc ;        // unc error for tlb rd

input [3:0]   tlu_lsu_tl_zero ;           // trap level is zero.
input [1:0]   ifu_lsu_thrid_s ;           // thread id
input         ifu_lsu_ldst_dbl_e ;        // ldd, atomic quad.

input         ld_stb_full_raw_w2 ;     // full raw for load-thread0
input         ld_sec_active ;          // secondary bypassing
input         ifu_tlu_inst_vld_m ;     // inst vld in w stage

input         lsu_l2fill_bendian_m ;

//input         lsu_l2fill_fpld_e ;      // fp load
output         lsu_l2fill_fpld_e ;      // fp load
input         lmq0_l2fill_fpld ;      // fp load
input         lmq1_l2fill_fpld ;      // fp load
input         lmq2_l2fill_fpld ;      // fp load
input         lmq3_l2fill_fpld ;      // fp load

input [`L1D_WAY_COUNT-1:0]   cache_way_hit_buf1 ;          // hit in set of cache.
   input      cache_hit;
   
//input [3:0]   lsu_byp_misc_addr_m ;   // lower 3bits of addr for ldxa/raw etc
   
input [1:0]   lmq0_byp_misc_sz ;     // size for ldxa/raw etc
input [1:0]   lmq1_byp_misc_sz ;     // size for ldxa/raw etc
input [1:0]   lmq2_byp_misc_sz ;     // size for ldxa/raw etc
input [1:0]   lmq3_byp_misc_sz ;     // size for ldxa/raw etc

input         lsu_l2fill_sign_extend_m ; // l2fill requires sign-extension
input         lsu_l1hit_sign_extend_e ;  // l1hit requires sign-extension
input [3:0]   tlu_lsu_pstate_cle ;       // current little endian
input [3:0]   tlu_lsu_pstate_am ;        // address mask
input [39:10] tlb_pgnum ;
input         tlb_demap_nctxt;         // demap with nctxt
input         tlb_demap_pctxt;         // demap with pctxt
input         tlb_demap_sctxt;         // demap with sctxt
input         tlb_demap_actxt;         // demap w autodemap ctxt
input [1:0]   tlb_demap_thrid;         // demap thrid

input         ifu_lsu_casa_e ;         // compare-swap instr
input         ifu_lsu_ldstub_e ;       // ldstub
input         ifu_lsu_swap_e ;         // swap


input         lsu_atm_st_cmplt_e ;      // atm st ack will restart thread
input	      lsu_cpx_pkt_atm_st_cmplt ; // applies to atomic ld also.

input         spu_lsu_ldxa_data_vld_w2 ; // ldxa data from spu is valid
input         spu_lsu_ldxa_illgl_va_w2 ; // ldxa data from spu with illgl va
input [1:0]   spu_lsu_ldxa_tid_w2 ;      // ldxa data from spu is valid
input [1:0]   spu_lsu_stxa_ack_tid ;     // stxa data from spu is valid
input         spu_lsu_stxa_ack ;         // write to sdata reg complete
input	      spu_lsu_unc_error_w2 ;
input	      spu_lsu_int_w2 ;		 // spu disrupting trap.

input         tlu_lsu_stxa_ack ;         // for mmu reads/writes/demaps
input [1:0]   tlu_lsu_stxa_ack_tid ;      // for mmu reads/writes/demaps - tid

input         lsu_tlb_invert_endian_g ;
//input         lsu_ncache_ld_e ;       // non-cacheable ld from dfq
   input      lmq0_ncache_ld;
   input      lmq1_ncache_ld;
   input      lmq2_ncache_ld;
   input      lmq3_ncache_ld;
   

input         ifu_tlu_mb_inst_e ;     // membar instruction
input         ifu_tlu_flsh_inst_e ;   // flush  instruction

input [3:0]   lsu_stb_empty ;         // thread's stb is empty

//input         tlu_dtlb_wr_vld_g ;
input         tlu_dtlb_tag_rd_g ;
input         tlu_dtlb_data_rd_g ;
input         tlu_dtlb_dmp_vld_g ;
input         tlu_dtlb_dmp_all_g ;
input         tlu_dtlb_rw_index_vld_g ;
input         tlu_dtlb_invalidate_all_g ;

`ifndef NO_RTL_CSM
input         tlu_dtlb_csm_rd_g ;
input [`TLB_CSM] tlb_rd_tte_csm;
`endif


input         lsu_st_wr_dcache ;

input         tlu_lsu_asi_update_m ;  // update asi
input  [1:0]  tlu_lsu_tid_m ;         // thread for asi update
input [`L1D_WAY_ARRAY_MASK]   lsu_rd_dtag_parity_g;     // calculated tag parity

input         dcache_rparity_err_wb;     // calculated tag parity
   
input         lsu_diagnstc_wr_data_b0 ;
input         lsu_byp_ldd_oddrd_m ;   // rd fill for non-alt ldd

input [3:0]   tlu_lsu_redmode ;       // redmode
input [3:0]   tlu_lsu_redmode_rst_d1 ;   // redmode
//input [2:0]   const_cpuid ;           // cpu's id
input [`L1D_WAY_COUNT-1:0]   dva_vld_m ;             // valid bits for cache.
output [`L1D_WAY_COUNT-1:0]  dva_vld_m_bf;
   
input [1:0]   lsu_dfill_tid_e ;       // thread id
input         ifu_lsu_asi_ack;        // asi ack from ifu

input [3:0]   lsu_intrpt_cmplt ;          // intrpt can restart thread
//input [8:0]   lsu_iobrdge_tap_rq_type ;
input  [8:8]  lsu_iobrdge_tap_rq_type_b8 ;
input  [6:3]  lsu_iobrdge_tap_rq_type_b6_b3 ;
input  [1:0]  lsu_iobrdge_tap_rq_type_b1_b0 ;

input         lsu_iobrdge_fwd_pkt_vld ;

input         lsu_cpx_ld_dtag_perror_e ;  // dtag parity error on issue
input         lsu_cpx_ld_dcache_perror_e ;// dcache parity error on issue
//input [1:1]   lsu_cpx_atm_st_err ;        // atomic st error field
input [1:0]   lsu_cpx_pkt_ld_err ;        // err field - cpx ld pkt
input [3:0]   ifu_lsu_nceen ;             // uncorrectible error enable 
input         tlu_lsu_ldxa_async_data_vld ;   // tlu_lsu_ldxa_data_vld is for async op.
input [3:0]   tlu_lsu_hpv_priv ;	  // hypervisor privilege modified
input [3:0]   tlu_lsu_hpstate_en ;	  // enable bit from hpstate

input         ifu_lsu_memref_d;
input         ifu_lsu_pref_inst_e ;       // prefetch inst
input         lsu_pref_pcx_req ;      	  // pref sent to pcx

input	      lsu_cpx_pkt_prefetch2 ;	  // ld is prefetch

// pref counter   
input [3:0]   lsu_ld_pcx_rq_sel_d2 ;
input         lsu_pcx_req_squash_d1;

input	      lsu_bld_helper_cmplt_m ;	  // bld helper completes.
input [2:0]   lsu_bld_cnt_m ;	
input	      lsu_bld_reset ;
   
output [3:0]  lsu_no_spc_pref;
    
input	      ffu_lsu_blk_st_e ;	// blk st helper signalled by ffu
input	[3:0]	lsu_stb_rmo_st_issue ;	// thread's stb issues rmo st
input	[3:0]	lsu_cpx_rmo_st_ack ;	// rmo ack clears

input	[3:0]	lsu_dfq_flsh_cmplt ;

input   	stb_cam_hit ;
 
input   ifu_tlu_flush_m;

output  ifu_tlu_flush_fd_w;
output  ifu_tlu_flush_fd2_w;
output  ifu_tlu_flush_fd3_w;
output  ifu_lsu_flush_w;
   
input   [3:0]           ctu_sscan_tid ;

//input		tte_data_perror_corr ;
input		tte_data_perror_unc ;
input		asi_tte_data_perror ;
input		asi_tte_tag_perror ;

input  	[5:0]	tlu_dtlb_rw_index_g ;

input		lsu_local_early_flush_g ;

//input		lsu_error_pa_b39_m ;

input         lsu_dfq_vld;

input		gdbginit_l ;
input		dc_direct_map ;

input           cfg_asi_lsu_ldxa_vld_w2;
input   [1:0]   cfg_asi_lsu_ldxa_tid_w2;

output 	[1:0]	lsu_tlu_thrid_d ;

output	[3:0] lsu_diagnstc_data_sel ;
output	[3:0] lsu_diagnstc_va_sel ;

output	[2:0] lsu_err_addr_sel ;

output [`L1D_VAL_ARRAY_HI:0] dva_bit_wr_en_e;
output [`L1D_ADDRESS_HI:6] dva_wr_adr_e;
   
output      lsu_exu_ldst_miss_w2 ;  // load misses in d$.
//output  [3:0]   lsu_way_hit ;   // ld/st access hits in d$.
output      lsu_exu_dfill_vld_w2 ;  // data fill to irf(exu).
output      lsu_ffu_ld_vld ;  // fp load writes to frf
output      lsu_ld_miss_wb ;  // load misses in d$.
//output      lsu_ld_hit_wb ;   // load hits in d$.
   
output      lsu_dtlb_bypass_e ; // dtlb is bypassed

output [`LMQ_WIDTH-1:40] ld_pcx_pkt_g ;    // ld miss pkt for thread.
output      tlb_ldst_cam_vld ;
   

//output      stxa_internal ;   // internal stxa, stg g 
output      ldxa_internal ;   // internal ldxa, stg g

output      lsu_ifu_ldsta_internal_e ; // any internal asi
output  [3:0]   lsu_ifu_ldst_cmplt ;
output  [3:0]   lsu_ifu_itlb_en ;
output  [3:0]   lsu_ifu_icache_en ;
   
   
output  [3:0]           lmq_byp_data_en_w2 ;

output  [3:0]           lmq_byp_data_fmx_sel ;  // final data sel for lmq byp
output  [3:0]           lmq_byp_data_mxsel0 ;     // ldxa vs stb bypass data sel.
output  [3:0]           lmq_byp_data_mxsel1 ;     // ldxa vs stb bypass data sel.
output  [3:0]           lmq_byp_data_mxsel2 ;     // ldxa vs stb bypass data sel.
output  [3:0]           lmq_byp_data_mxsel3 ;     // ldxa vs stb bypass data sel.
output  [2:0]           lmq_byp_ldxa_mxsel0 ;     // ldxa data sel - thread0
output  [2:0]           lmq_byp_ldxa_mxsel1 ;     // ldxa data sel - thread1
output  [2:0]           lmq_byp_ldxa_mxsel2 ;     // ldxa data sel - thread2
output  [2:0]           lmq_byp_ldxa_mxsel3 ;     // ldxa data sel - thread3
output  [2:0]   lsu_ld_thrd_byp_sel_e ;
   
output  [15:0]    dcache_byte_wr_en_e ; // 16-byte write enable mask.

output      lsu_dcache_wr_vld_e ; // write to dcache.

output      lsu_ldstub_g ;    // ldstub(a) instruction
output      lsu_swap_g ;    // swap(a) instruction
output                  lsu_tlu_dtlb_done;  // dtlb rd/dmp/wr cmplt
output  [1:0]   lsu_exu_thr_m ;

output                   merge7_sel_byte0_m;
output                   merge7_sel_byte7_m;
   
output                   merge6_sel_byte1_m;
output                   merge6_sel_byte6_m;

output                   merge5_sel_byte2_m;   
output                   merge5_sel_byte5_m;

output                   merge4_sel_byte3_m;
output                   merge4_sel_byte4_m;

output                   merge3_sel_byte0_m;
output                   merge3_sel_byte3_m;
output                   merge3_sel_byte4_m;
output                   merge3_sel_byte7_default_m;
output                   merge3_sel_byte_m ;

output                   merge2_sel_byte1_m;
output                   merge2_sel_byte2_m;
output                   merge2_sel_byte5_m;
output                   merge2_sel_byte6_default_m;
output                   merge2_sel_byte_m ;

output                   merge0_sel_byte0_m, merge0_sel_byte1_m;
output                   merge0_sel_byte2_m, merge0_sel_byte3_default_m;
   
output                   merge0_sel_byte4_m, merge0_sel_byte5_m;
output                   merge0_sel_byte6_m, merge0_sel_byte7_default_m;
                                                               
output                   merge1_sel_byte0_m, merge1_sel_byte1_m;
output                   merge1_sel_byte2_m, merge1_sel_byte3_default_m;
output                   merge1_sel_byte4_m, merge1_sel_byte5_m;
output                   merge1_sel_byte6_m, merge1_sel_byte7_default_m; 

output			             merge0_sel_byte_1h_m ;
   
output			             merge1_sel_byte_1h_m, merge1_sel_byte_2h_m ;
   
output		lsu_dtlb_cam_real_e ;
output      lsu_dtagv_wr_vld_e ;

output      lsu_dtag_wrreq_x_e ;
output      lsu_dtag_index_sel_x_e ;
   
output      lsu_dtlb_wr_vld_e ;
output      lsu_dtlb_tag_rd_e ;
output      lsu_dtlb_data_rd_e ;
output      lsu_dtlb_dmp_vld_e ;
output      lsu_dtlb_dmp_all_e ;
output      lsu_dtlb_rwindex_vld_e ;
output      lsu_dtlb_invalid_all_l_m ;
output      lsu_tlu_tlb_ld_inst_m ;
output      lsu_tlu_tlb_st_inst_m ;
output  [1:0]   lsu_tlu_tlb_access_tid_m ;
output      lsu_tlb_data_rd_vld_g ;

`ifndef NO_RTL_CSM
output      csm_rd_vld_g;
output      lsu_tlb_csm_rd_vld_g;
output      lsu_dtlb_csm_rd_e ;
output	[`TLB_CSM]	lsu_blkst_csm_m ;
`endif

output stb_ncache_pcx_rq_g;
   
output  [3:0]   lsu_tlb_st_sel_m ;
   
output         lsu_va_wtchpt0_wr_en_l;
output         lsu_va_wtchpt1_wr_en_l;
output         lsu_va_wtchpt2_wr_en_l;
output         lsu_va_wtchpt3_wr_en_l;

output         thread0_m;
output         thread1_m;
output         thread2_m;
output         thread3_m;

output         lsu_dctldp_thread0_m;
output         lsu_dctldp_thread1_m;
output         lsu_dctldp_thread2_m;
output         lsu_dctldp_thread3_m;
   
output         thread0_g;
output         thread1_g;
output         thread2_g;
output         thread3_g;
   
output                  lsu_tlu_nonalt_ldst_m ; // non-alternate load or store
output                  lsu_tlu_xslating_ldst_m ;// xslating ldst,atomic etc

output   [2:0]          lsu_tlu_ctxt_sel_m;           // context selected:0-p,1-s,2-n
output                  lsu_tlu_write_op_m;           // fault occurs for data write operation

output                  lsu_dtlb_addr_mask_l_e ;  // address mask applies


output            dva_din_e;

output            lsu_diagnstc_dtagv_prty_invrt_e ;
   
output                  lsu_ifu_asi_load;   // asi load to ifu
output [1:0]            lsu_ifu_asi_thrid;    // asi event thrid to ifu
output                  lsu_ifu_asi_vld;    // asi event vld - ld+st
output      lsu_quad_asi_e ;
//output      lsu_tlu_64kpg_hit_g ;   // 64k page page accessed

output            lsu_local_ldxa_sel_g;
output  [3:0]     lsu_dtag_rsel_m ;  // dtag way sel

output      lsu_tlbop_force_swo ;
output  [2:0]     lsu_atomic_pkt2_bsel_g ;
output      lsu_dcache_tag_perror_g ;       // dcache tag parity error
output      lsu_dcache_data_perror_g ;      // dcache data parity error
   
output      lsu_ifu_l2_unc_error ;    // l2 uncorrectible error
output      lsu_ifu_l2_corr_error ;   // l2 correctible error
output      lsu_ifu_dcache_data_perror ;  // dcache data parity error
output      lsu_ifu_dcache_tag_perror ; // dcache tag parity error
output  [1:0]   lsu_ifu_error_tid ;   // thread id for error
output      lsu_ifu_io_error ;    // error on io ld
//output  [1:0]   lsu_tlu_derr_tid_g ;    // daccess error tid
   
output      lsu_tlu_squash_va_oor_m ;   // squash va_oor for mem-op.
output      lsu_squash_va_oor_m ;   // squash va_oor for mem-op.

output          tlb_cam_hit_g ;           // xlation hits in tlb.     

   output        lsu_st_hw_le_g;
   output        lsu_st_w_or_dbl_le_g;
   output        lsu_st_x_le_g;
   output        lsu_swap_sel_default_g;
   output        lsu_swap_sel_default_byte_7_2_g;

output		lsu_st_rmo_m ;		// rmo store in m stage
output		lsu_bst_in_pipe_m ;	// 1st helper for bst.
output  	lsu_snap_blk_st_m ;	// snap blk st state 
output		lsu_blk_st_m ;		// blk st in m
output	[39:10]	lsu_blkst_pgnum_m ;
output		lsu_ffu_blk_asi_e ;	// blk
output		lsu_blk_asi_m ;

output		lsu_nonalt_nucl_access_m ;

//output	[3:0]	lsu_spu_stb_empty ;

   output     dcache_alt_mx_sel_e;
   output     dcache_alt_mx_sel_e_bf;
   output     dcache_rvld_e;
   
output		lsu_dc_iob_access_e ;	// dcache iob access

output		lsu_ifu_ldst_miss_w ;

   output lsu_ifu_dc_parity_error_w2;
   
   output lsu_ldst_inst_vld_e;

output          lsu_local_ldxa_tlbrd_sel_g;
output          lsu_local_diagnstc_tagrd_sel_g;
output          lsu_va_wtchpt_sel_g;
   

   input [7:0]   asi_d;
   input [7:0]   lsu_dctl_asi_state_m;
   
   output  [3:0] asi_state_wr_thrd;
   output        thread0_d;
   output        thread1_d;
   output        thread2_d;
   output        thread3_d;
   output        tlu_lsu_asi_update_g;

output  [3:0] pctxt_state_wr_thrd ;
output  [3:0] sctxt_state_wr_thrd ;

   output     thread_pctxt;
   output     thread_sctxt;

   output     thread_actxt;
   output     thread_default;
   
   output     thread0_ctxt;  
   output     thread1_ctxt;
   output     thread2_ctxt;
   output     thread3_ctxt;

   output [3:0] pid_state_wr_en;
   output       thread0_e;
   output       thread1_e;
   output       thread2_e;
   output       thread3_e;

   output       dfture_tap_wr_mx_sel;
   output [3:0] lctl_rst;
   output [3:0] lsu_ctl_state_wr_en;
   output [3:0] lsuctl_ctlbits_wr_en;
   output [3:0] dfture_tap_rd_en;

   output      bist_tap_wr_en;
   output      bistctl_wr_en;
   output      bist_ctl_reg_wr_en;
   output      mrgn_tap_wr_en;

   output      ldiagctl_wr_en;

   output [3:0]  misc_ctl_sel_din ;

   output [2:0] lsu_asi_sel_fmx1;
   output [2:0] lsu_asi_sel_fmx2;


   output       tlb_access_en0_g;
   output       tlb_access_en1_g;
   output       tlb_access_en2_g;
   output       tlb_access_en3_g;

   output tlb_access_sel_thrd0;
   output tlb_access_sel_thrd1;
   output tlb_access_sel_thrd2;
   output tlb_access_sel_default;

   input [7:0] lsu_ldst_va_g;
   
   output mrgnctl_wr_en;

   input  lsu_ifu_err_addr_b39;

   input [5:0] lsu_dp_ctl_reg0;
   input [5:0] lsu_dp_ctl_reg1;
   input [5:0] lsu_dp_ctl_reg2;
   input [5:0] lsu_dp_ctl_reg3;

   input       ldd_in_dfq_out;     //from qctl2 
   

   output hpv_priv_m;
   output hpstate_en_m;
   
   output                dcache_arry_data_sel_m;
   
   output                dtlb_bypass_m;
   
   output                lsu_alt_space_m;
   output                atomic_m;

   output                ldst_dbl_m;
   output                fp_ldst_m;

   output                lda_internal_m;
   output                sta_internal_m;
   output                cam_real_m;

   output                data_rd_vld_g;
   output                tag_rd_vld_g;
   output [1:0]          ldst_sz_m;
   output                asi_internal_m;

//   output                ld_inst_vld_unflushed;
//   output                st_inst_vld_unflushed;
   
   output                rd_only_ltlb_asi_e;
   output                wr_only_ltlb_asi_e;
   output                dfill_tlb_asi_e;
   output                ifill_tlb_asi_e;

   output                nofault_asi_m;
   output                as_if_user_asi_m;

   output                atomic_asi_m;
   output                phy_use_ec_asi_m;
   output                phy_byp_ec_asi_m;

   output                quad_asi_m;
   output                binit_quad_asi_m;
   output                blk_asi_m;

   output                recognized_asi_m;
   output                strm_asi_m;
   output                mmu_rd_only_asi_m;
   output                rd_only_asi_m;
   output                wr_only_asi_m;
   output                unimp_asi_m;

   output                va_wtchpt_cmp_en_m;

   output		lsu_tlu_async_ttype_vld_w2 ;	// daccess error - asynchronous
   output   [6:0]	lsu_tlu_async_ttype_w2 ;
   output   [1:0] 	lsu_tlu_async_tid_w2 ;		// asynchronous trap - thread 

   output   [5:0]	async_tlb_index ;
   
//=========================================
//dc_fill CP
//=========================================   
   output                l2fill_vld_m;    //to qdp1
   output  [3:0]   ld_thrd_byp_mxsel_m ;  //to qdp1
   output [7:0]    morphed_addr_m;        //to dcdp
 
   
   output          signed_ldst_byte_m;    //to dcdp
//   output          unsigned_ldst_byte_m;  //to dcdp 
   output          signed_ldst_hw_m;      //to dcdp
//   output          unsigned_ldst_hw_m;    //to dcdp
   output          signed_ldst_w_m;       //to dcdp
//   output          unsigned_ldst_w_m;     //to dcdp

   output	lsu_tlb_asi_data_perr_g ;	
   output	lsu_tlb_asi_tag_perr_g ;

   output  [14:13]   lsu_sscan_data ;

   output  [3:0] 	lsu_ld_inst_vld_g ;
   
   output  [1:0]     lsu_dcache_rand;
   output reg  [1:0]     lsu_encd_way_hit;
   output            lsu_way_hit_or;
//   output            lsu_quad_asi_g;

   output	     lsu_memref_m ;
   output	     lsu_flsh_inst_m ;

   output	    	lsu_ifu_asi_data_en_l ;


//dcfill_addr [`L1D_ADDRESS_HI:0]
   input [`L1D_ADDRESS_HI-3:0]  dcache_iob_addr_e;
   input [`L1D_ADDRESS_HI-4:0]  mbist_dcache_index;
   input        mbist_dcache_word;
   input [`L1D_ADDRESS_HI:0] lsu_diagnstc_wr_addr_e;
   input [`L1D_ADDRESS_HI:0] st_dcfill_addr;
   output [`L1D_ADDRESS_HI:3] lsu_dcache_fill_addr_e;
   output [`L1D_ADDRESS_HI:4] lsu_dcache_fill_addr_e_err;

   input         lsu_dfq_ld_vld;
   input         lsu_dfq_st_vld;

   output [3:0]  lsu_thread_g;

//=========================================
//LMQ thread sel
//=========================================
   input         lmq0_ldd_vld;      //from qdp1
   input         lmq1_ldd_vld;
   input         lmq2_ldd_vld;
   input         lmq3_ldd_vld;
   output        lmq_ldd_vld;       //to  qctl2 
      
   input [1:0]   lsu_dfq_byp_tid;   //from qdp2
   input         dfq_byp_ff_en;     //from qctl2 

   input [`L1D_WAY_MASK]   lsu_dcache_iob_way_e;   //from qdp2
 
   input   [1:0]  mbist_dcache_way;   
   output  [`L1D_WAY_ARRAY_MASK]  lsu_bist_rsel_way_e;
   
   input   [`L1D_WAY_MASK]   lsu_diagnstc_wr_way_e ;  //from dctldp

   input [`L1D_WAY_MASK]     lsu_st_way_e;    //from qdp2

   input [`L1D_WAY_MASK]     lmq0_pcx_pkt_way;  //from qctl1
   input [`L1D_WAY_MASK]     lmq1_pcx_pkt_way;
   input [`L1D_WAY_MASK]     lmq2_pcx_pkt_way;
   input [`L1D_WAY_MASK]     lmq3_pcx_pkt_way;
   output [`L1D_WAY_COUNT-1:0]    lsu_dcache_fill_way_e;

// input  [3*(`L1D_WAY_COUNT)-1:0]             lmq_ld_rq_type ;        // for identifying atomic ld.

input  [2:0]             lmq0_ld_rq_type ;        // for identifying atomic ld.
input  [2:0]             lmq1_ld_rq_type ;        // for identifying atomic ld.
input  [2:0]             lmq2_ld_rq_type ;        // for identifying atomic ld.
input  [2:0]             lmq3_ld_rq_type ;        // for identifying atomic ld.
   
input  [`L1D_ADDRESS_HI:0]            lmq0_pcx_pkt_addr;
input  [`L1D_ADDRESS_HI:0]            lmq1_pcx_pkt_addr;
input  [`L1D_ADDRESS_HI:0]            lmq2_pcx_pkt_addr;
input  [`L1D_ADDRESS_HI:0]            lmq3_pcx_pkt_addr;

output                   lmq_ld_addr_b3;

output [3:0]             lsu_outstanding_rmo_st_max;

input                 lsu_ttype_vld_m2;
input                 tlu_early_flush_pipe2_w;
input [1:0]           lsu_st_dcfill_size_e;

   input              mbist_dcache_write;
   input              mbist_dcache_read;

   output             lsu_dcfill_data_mx_sel_e;
   
wire  [3:0]   ld_thrd_byp_sel_e ;
wire	      ifu_asi_vld,ifu_asi_vld_d1 ;
wire  [1:0]   dcache_wr_size_e ;   
wire          lsu_ncache_ld_e;
wire          lsu_diagnstc_wr_src_sel_e ; // dcache/dtag/v write - diag
   
wire         dctl_flush_pipe_w ;   // flush pipe due to error
 wire        dctl_early_flush_w;
   
wire  [`L1D_ADDRESS_HI:0] lmq_pcx_pkt_addr;
wire  [2:0]  lmq_ld_rq_type_e;
   
wire [`L1D_ADDRESS_HI:0]  dcache_fill_addr_e;
wire [2:0]   dcache_wr_addr_e ;       
wire	lsuctl_dtlb_byp_e ;
   
wire	cam_perr_unc0,asi_data_perr0,asi_tag_perr0,ifu_unc_err0 ;
wire	cam_perr_unc1,asi_data_perr1,asi_tag_perr1,ifu_unc_err1 ;
wire	cam_perr_unc2,asi_data_perr2,asi_tag_perr2,ifu_unc_err2 ;
wire	cam_perr_unc3,asi_data_perr3,asi_tag_perr3,ifu_unc_err3 ;
wire	cam_perr_unc_e, asi_data_perr_e,asi_tag_perr_e,ifu_unc_err_e ;
wire	cam_perr_unc_m, asi_data_perr_m,asi_tag_perr_m,ifu_unc_err_m ;
wire	cam_perr_unc_g, asi_data_perr_g,asi_tag_perr_g,ifu_unc_err_g ;
//wire	cam_real_err_e, cam_real_err_m ;
wire	[3:0] squash_byp_cmplt,squash_byp_cmplt_m, squash_byp_cmplt_g ;
wire      ld_inst_vld_m,ld_inst_vld_g ;
wire      st_inst_vld_m,st_inst_vld_g ;
wire      fp_ldst_m,fp_ldst_g,fp_ldst_w2 ;
wire      lsu_ld_hit_wb, lsu_ld_miss_wb ;
wire  [`L1D_WAY_ARRAY_MASK]   lsu_way_hit ;
wire  [1:0]   ldst_sz_m,ldst_sz_g ;
wire  [4:0]   ld_rd_m, ld_rd_g ;
wire      lsu_dtlb_bypass_g,dtlb_bypass_e,dtlb_bypass_m ;
wire [6:0]  lsu_sraddr_e ;
//wire    lsu_rsr_inst_e,lsu_rsr_inst_m, lsu_rsr_inst_w ;
wire    lsu_wsr_inst_e;
wire    pctxt_state_en, sctxt_state_en ;
wire    asi_state_wr_en ;
//wire  [3:0] pctxt_state_rd_en, sctxt_state_rd_en ;
wire    lsu_alt_space_m,lsu_alt_space_g ;
wire    ldxa_internal, stxa_internal ;
wire    lsu_ctl_state_en;
//wire  [3:0] lsu_ctl_state_rd_en;
wire  [3:0]   lsu_ctl_state_wr_en ;
//wire  [7:0] imm_asi_e,imm_asi_m,imm_asi_g ;
//wire    imm_asi_vld_e,imm_asi_vld_m,imm_asi_vld_g;
//wire  [7:0]   asi_state0,asi_state1,asi_state2,asi_state3 ;

wire    ldsta_internal_e,sta_internal_e,lda_internal_e;
wire    sta_internal_m,lda_internal_m;
wire  [7:0] asi_d ;
wire    [1:0]   thrid_d,thrid_e,thrid_m, thrid_g, thrid_w2, thrid_w3, ldxa_thrid_w2 ;
wire    stxa_internal_d1, stxa_internal_d2 ;
wire    ld_pcx_pkt_vld_e ;
wire    ld_pcx_pkt_vld_m ;
wire    ld_pcx_pkt_vld_g ;
wire    ldst_dbl_m, ldst_dbl_g;
wire    ldd_force_l2access_w2, ldd_force_l2access_w3;
   
//wire    ld_stb_full_raw_w2 ;
wire    ld_stb_full_raw_w3 ;

wire    ldbyp0_vld_rst, ldbyp0_vld_en, ldbyp0_fpld ;
wire    ldbyp1_vld_rst, ldbyp1_vld_en, ldbyp1_fpld ;
wire    ldbyp2_vld_rst, ldbyp2_vld_en, ldbyp2_fpld ;
wire    ldbyp3_vld_rst, ldbyp3_vld_en, ldbyp3_fpld ;
//wire    ldbyp0_vld_en_d1,ldbyp1_vld_en_d1,ldbyp2_vld_en_d1,ldbyp3_vld_en_d1 ;

wire    thread0_e,thread1_e,thread2_e,thread3_e;
wire    thread0_d,thread1_d,thread2_d,thread3_d;
wire    thread0_m,thread1_m,thread2_m,thread3_m;
wire    thread0_g,thread1_g,thread2_g,thread3_g;
wire    thread0_w2,thread1_w2,thread2_w2,thread3_w2;
wire    thread0_w3,thread1_w3,thread2_w3,thread3_w3;
wire    tlu_stxa_thread0_w2,tlu_stxa_thread1_w2 ;
wire    tlu_stxa_thread2_w2,tlu_stxa_thread3_w2 ;
wire    tlu_ldxa_thread0_w2,tlu_ldxa_thread1_w2 ;
wire    tlu_ldxa_thread2_w2,tlu_ldxa_thread3_w2 ;
wire    spu_ldxa_thread0_w2,spu_ldxa_thread1_w2 ;
wire    spu_ldxa_thread2_w2,spu_ldxa_thread3_w2 ;
wire    spu_stxa_thread0,spu_stxa_thread1 ;
wire    spu_stxa_thread2,spu_stxa_thread3 ;
wire    ifu_ldxa_thread0_w2,ifu_ldxa_thread1_w2 ;
wire    ifu_ldxa_thread2_w2,ifu_ldxa_thread3_w2 ;
wire    ifu_stxa_thread0_w2,ifu_stxa_thread1_w2 ;
wire    ifu_stxa_thread2_w2,ifu_stxa_thread3_w2 ;
wire    ldbyp0_vld, ldbyp1_vld, ldbyp2_vld, ldbyp3_vld ;
//wire    ld_any_byp_data_vld ;              
wire  [3:0] asi_state_wr_thrd;
wire  [3:0] pctxt_state_wr_thrd ;
wire  [3:0] sctxt_state_wr_thrd ;
wire    tlb_cam_hit_g ;
wire    ld_inst_vld_unflushed ;
wire    st_inst_vld_unflushed ;

wire  [7:0]  baddr_m ;
wire  [15:0]  byte_wr_enable ;
//wire  [1:0] st_size ;
//wire    l2fill_bendian_g ;
wire    ldst_byte,ldst_hword,ldst_word,ldst_dword;
wire    byte_m,hword_m,word_m,dword_m;
wire    tlb_invert_endian_g ;
//wire  [7:0] l2fill_bytes_msb_m, l2fill_bytes_msb_g ;
//wire    byte_g, hword_g, word_g ;

   wire signed_ldst_m ;
//wire  unsigned_ldst_m ;
//wire    sign_bit_g  ;
//wire  [7:0] align_bytes_msb ;

wire    l2fill_vld_m, l2fill_vld_g ;
wire    l2fill_fpld_e, l2fill_fpld_m, l2fill_fpld_g ;
wire    pstate_cle_e, pstate_cle_m, pstate_cle_g ;
wire    l1hit_lendian_g ;
wire    l1hit_sign_extend_m, l1hit_sign_extend_g ;
wire    demap_thread0, demap_thread1, demap_thread2, demap_thread3 ;

wire    misc_byte_m,misc_hword_m,misc_word_m,misc_dword_m;
wire    byp_word_g;
//wire  [15:0]  byp_baddr_g ;
//wire    ld_stb_hit_g ;
wire    atomic_ld_squash_e ;
wire    atomic_m,atomic_g,atomic_w2, atomic_w3 ;
wire  [2:0] ld_rq_type ;
wire    ncache_pcx_rq_g ;
wire    lmq_pkt_vld_g ;
wire    tlb_lng_ltncy_asi_d,tlb_lng_ltncy_asi_e, tlb_lng_ltncy_asi_m,tlb_lng_ltncy_asi_g ; 
wire    recognized_asi_d,recognized_asi_e,recognized_asi_m,recognized_asi_g,recognized_asi_tmp ;
wire    asi_internal_d, asi_internal_e ;  
wire    asi_internal_m, asi_internal_g ;  
wire    dcache_byp_asi_d, dcache_byp_asi_e ;
wire    dcache_byp_asi_m, dcache_byp_asi_g ;
wire	phy_use_ec_asi_d,phy_use_ec_asi_e,phy_use_ec_asi_m;
wire	phy_byp_ec_asi_d,phy_byp_ec_asi_e,phy_byp_ec_asi_m;
wire    lendian_asi_d, lendian_asi_e;
wire    lendian_asi_m, lendian_asi_g;
wire	intrpt_disp_asi_d,intrpt_disp_asi_e,intrpt_disp_asi_m,intrpt_disp_asi_g ;
wire    nofault_asi_d, nofault_asi_e, nofault_asi_m ;
wire    nucleus_asi_d, nucleus_asi_e ;
wire    primary_asi_d, primary_asi_e ;
wire    quad_asi_d,quad_asi_e,quad_asi_m,quad_asi_g;
wire    binit_quad_asi_d,binit_quad_asi_e,binit_quad_asi_m,binit_quad_asi_g ;
wire    secondary_asi_d, secondary_asi_e ;
wire    tlb_byp_asi_d, tlb_byp_asi_e;
wire    thread0_ctxt, thread1_ctxt ; 
wire    thread2_ctxt, thread3_ctxt ;


wire    altspace_ldst_e, non_altspace_ldst_e ;
wire    altspace_ldst_m, altspace_ldst_g ;
wire    non_altspace_ldst_m, non_altspace_ldst_g ;
wire    thread_pctxt, thread_sctxt, thread_nctxt, thread_actxt ;
wire    ncache_asild_rq_g ;
//SC wire    pstate_priv, pstate_priv_m ;
//SC wire    priv_pg_usr_mode ;
//SC wire    nonwr_pg_st_access ;
//SC wire    nfo_pg_nonnfo_asi ;
//wire    daccess_excptn ;
wire    mbar_inst_m,flsh_inst_m ; 
wire    mbar_inst_g,flsh_inst_g ; 
wire    bsync0_reset,bsync1_reset;
wire    bsync2_reset,bsync3_reset ;
wire    bsync0_en,bsync1_en ;
wire    bsync2_en,bsync3_en ;
wire    flush_inst0_g,mbar_inst0_g ;
wire    flush_inst1_g,mbar_inst1_g ;
wire    flush_inst2_g,mbar_inst2_g ;
wire    flush_inst3_g,mbar_inst3_g ;
wire    dfill_thread0,dfill_thread1;
wire    dfill_thread2,dfill_thread3;
wire    mbar_vld0, flsh_vld0 ;
wire    mbar_vld1, flsh_vld1 ;
wire    mbar_vld2, flsh_vld2 ;
wire    mbar_vld3, flsh_vld3 ;
   wire [1:0] dfq_tid_m,dfq_tid_g;

wire  [1:0]   ldbyp_tid_m ;
wire    stxa_stall_asi_g ;
wire    stxa_stall_wr_cmplt0, stxa_stall_wr_cmplt1 ;
wire    stxa_stall_wr_cmplt2, stxa_stall_wr_cmplt3 ;
wire    stxa_stall_wr_cmplt0_d1, stxa_stall_wr_cmplt1_d1 ;
wire    stxa_stall_wr_cmplt2_d1, stxa_stall_wr_cmplt3_d1 ;
wire    dtlb_done ;
wire    tag_rd_vld_m, tag_rd_vld_g ;
wire    data_rd_vld_m, data_rd_vld_g ;
`ifndef NO_RTL_CSM
wire    csm_rd_vld_m, csm_rd_vld_g ;
`endif
wire    tlb_demap_vld ;
wire    dtlb_done_d1 ;
wire    dtlb_done_d2 ;


wire    tlu_lsu_asi_update_g ;
wire  [1:0] tlu_lsu_tid_g ;
wire    tsa_update_asi0,tsa_update_asi1;
wire    tsa_update_asi2,tsa_update_asi3;
wire    tlb_ld_inst0,tlb_ld_inst1,tlb_ld_inst2,tlb_ld_inst3 ;
wire    tlb_st_inst0,tlb_st_inst1,tlb_st_inst2,tlb_st_inst3 ;
wire    tlb_access_en0_e,tlb_access_en1_e,tlb_access_en2_e,tlb_access_en3_e ;
wire    tlb_access_en0_m,tlb_access_en1_m,tlb_access_en2_m,tlb_access_en3_m ;
wire    tlb_access_en0_tmp,tlb_access_en1_tmp,tlb_access_en2_tmp,tlb_access_en3_tmp ;
wire    tlb_access_en0_g,tlb_access_en1_g,tlb_access_en2_g,tlb_access_en3_g ;
wire    tlb_access_en0_unflushed,tlb_access_en1_unflushed,tlb_access_en2_unflushed,tlb_access_en3_unflushed ;
wire    tlb_access_rst0,tlb_access_rst1,tlb_access_rst2,tlb_access_rst3 ;
wire    tlb_access_sel_thrd0,tlb_access_sel_thrd1;
wire    tlb_access_sel_thrd2,tlb_access_sel_thrd3;
wire    tlb_access_blocked ;
wire    tlb_access_pending ;
wire    tlb_access_initiated ;
//wire    tlb_pending_access_rst ;

wire    vw_wtchpt_cmp_en_m,vr_wtchpt_cmp_en_m ;


//wire    va_b12_3_match_m,va_b47_40_match_m ;
//wire    va_b12_3_match_g,va_b47_40_match_g ;
//wire    wtchpt_msk_match_m,wtchpt_msk_match_g ;

wire    as_if_user_asi_d,as_if_user_asi_e,as_if_user_asi_m;
//SC wire    as_if_usr_priv_pg ;
//SC wire    priv_action,priv_action_m ;
//SC wire    stdf_maddr_not_align, lddf_maddr_not_align ;
//wire  [8:0] early_ttype_m,early_ttype_g ; 
//wire    early_trap_vld_m, early_trap_vld_g ;  
//SC wire    atm_access_w_nc, atm_access_unsup_asi ;
wire    atomic_asi_d,atomic_asi_e,atomic_asi_m ;  
//wire    dflush_asi_d,dflush_asi_e,dflush_asi_m,dflush_asi_g;  
wire    blk_asi_d,blk_asi_e,blk_asi_m, blk_asi_g ;

wire    fpld_byp_data_vld ;
//wire  [7:0] dcache_rd_parity ;
wire    dcache_rd_parity_error ;
//SC wire    tte_data_parity_error ;

wire  [`L1D_WAY_ARRAY_MASK]   dtag_parity_error;
//wire    dtag_mtag_parity_error ;
//wire    daccess_error ;
//SC wire    dmmu_miss_g ;
wire  [2:0]   ctxt_sel_e ;
wire    dc_diagnstc_asi_d, dc_diagnstc_asi_e ;
wire    dc_diagnstc_asi_m, dc_diagnstc_asi_g ;
wire    dtagv_diagnstc_asi_d, dtagv_diagnstc_asi_e ;
wire    dtagv_diagnstc_asi_m, dtagv_diagnstc_asi_g ;
//wire    dc_diagnstc_wr_e,dtagv_diagnstc_wr_e ;
//wire    dside_diagnstc_wr_e ;
wire    dc_diagnstc_wr_en,dtagv_diagnstc_wr_en ;

wire  dtagv_diagnstc_rd_g ;
wire  dc0_diagnstc_asi,dtagv0_diagnstc_asi;
wire  dc1_diagnstc_asi,dtagv1_diagnstc_asi;
wire  dc2_diagnstc_asi,dtagv2_diagnstc_asi;
wire  dc3_diagnstc_asi,dtagv3_diagnstc_asi;
//wire [3:0] lngltncy_st_go ;
wire  [3:0]   tlb_st_data_sel_m ;
wire  dc0_diagnstc_wr_en, dc1_diagnstc_wr_en, dc2_diagnstc_wr_en, dc3_diagnstc_wr_en ;  
wire  dtagv0_diagnstc_wr_en, dtagv1_diagnstc_wr_en, dtagv2_diagnstc_wr_en, dtagv3_diagnstc_wr_en ;  
//wire  merge2_sel_byte7, merge3_sel_byte7 ; 
//SC wire  hw_align_addr,wd_align_addr,dw_align_addr;
wire   hw_size,wd_size,dw_size;
//SC wire  mem_addr_not_align ;

wire  wr_only_asi_d,wr_only_asi_e,wr_only_asi_m ;
wire  rd_only_asi_d,rd_only_asi_e,rd_only_asi_m ;
wire  mmu_rd_only_asi_d,mmu_rd_only_asi_e,mmu_rd_only_asi_m ;
wire  unimp_asi_d,unimp_asi_e,unimp_asi_m;
wire  dmmu_asi58_d,dmmu_asi58_e,dmmu_asi58_m;
wire  immu_asi50_d,immu_asi50_e,immu_asi50_m;

wire  ifu_asi_store ;
wire  nontlb_asi0, nontlb_asi1, nontlb_asi2, nontlb_asi3 ;
//wire  stxa_stall_reset ;
wire  ifu_nontlb0_asi,ifu_nontlb1_asi,ifu_nontlb2_asi,ifu_nontlb3_asi;
wire  ifu_nontlb_asi_d, ifu_nontlb_asi_e,ifu_nontlb_asi_m,ifu_nontlb_asi_g ;
wire  [2:0] lsu_asi_sel_fmx1 ;
wire  [2:0] lsu_asi_sel_fmx2;   
wire    lsu_asi_rd_en, lsu_asi_rd_en_w2 ;
//wire  [12:0]  pctxt_state ;
//wire  [12:0]  sctxt_state ;

//wire  [1:0] dcache_rand,dcache_rand_new ;
wire    dtlb_inv_all_e,dtlb_inv_all_m ;
wire  dtlb_wr_vld_d1,dtlb_tag_rd_d1,dtlb_data_rd_d1,dtlb_dmp_vld_d1,dtlb_inv_all_d1 ;
wire  ldst_in_pipe ;
wire  tlbop_init, tlbop_init_d1, tlbop_init_d2 ;
wire  tlbop_init_d3, tlbop_init_d4, tlbop_init_d5 ;
wire  [3:0] ldxa_illgl_va_cmplt,ldxa_illgl_va_cmplt_d1 ;

wire  lsuctl_va_vld ;
wire  lsuctl_illgl_va ;
wire  sctxt_va_vld;
//wire  scxt_ldxa_illgl_va ;
wire  pctxt_va_vld;

wire  pscxt_ldxa_illgl_va ;
wire  lsu_asi_illgl_va ;
wire  [3:0] lsu_asi_illgl_va_cmplt,lsu_asi_illgl_va_cmplt_w2 ;
wire  bistctl_va_vld,mrgnctl_va_vld,ldiagctl_va_vld ;
wire  bistctl_state_en,mrgnctl_state_en,ldiagctl_state_en ;
wire  mrgnctl_illgl_va ;
wire  asi42_illgl_va ;

wire    [3:0]   tap_thread ;
wire    mrgn_tap_wr_en ;
wire    bist_tap_wr_en ;

wire [3:0] dfture_tap_rd_d1;
wire [3:0] dfture_tap_wr_en;

//wire  dfture_tap_rd_sel ;

wire  misc_asi_rd_en ;

wire [3:0]  lsuctl_ctlbits_wr_en ;
wire  bistctl_wr_en;
wire  mrgnctl_wr_en;
//wire  ldiagctl_rd_en,ldiagctl_wr_en;
wire  casa_m, casa_g ;
wire  tte_data_perror_unc ;
wire  asi_tte_data_perror,asi_tte_tag_perror ;

wire  [1:0] dfill_tid_m,dfill_tid_g ;
wire  dtag_error_m,dcache_error_m;
wire  dtag_error_g,dcache_error_g;
wire  dtag_error_w2,dcache_error_w2;
wire  l2_unc_error_e,l2_corr_error_e;
wire  l2_unc_error_m,l2_corr_error_m;
wire  l2_unc_error_g,l2_corr_error_g;
wire  l2_unc_error_w2,l2_corr_error_w2;
wire  unc_err_trap_e,unc_err_trap_m,unc_err_trap_g ;
//wire  corr_err_trap_e, corr_err_trap_m, corr_err_trap_g ;
wire  dtag_perror_g ;


wire  ifill_tlb_asi_d,dfill_tlb_asi_d,rd_only_ltlb_asi_d,wr_only_ltlb_asi_d ;
wire  ifill_tlb_asi_e,dfill_tlb_asi_e,rd_only_ltlb_asi_e,wr_only_ltlb_asi_e ;
//SC wire  tlb_daccess_excptn_e,tlb_daccess_error_e  ;
//SC wire  tlb_daccess_excptn_m,tlb_daccess_error_m  ;
//SC wire  tlb_daccess_excptn_g,tlb_daccess_error_g  ;
wire  thread_tl_zero ;
wire	pid_va_vld, pid_state_en ;
wire	[3:0]	pid_state_wr_en ;

//wire	[3:0]	pid_state_rd_en ;
//wire	[2:0]	pid_state ;
wire    [3:0]   intld_byp_cmplt ;

//wire	hpv_priv,hpstate_en ;	
wire	hpv_priv_m,hpstate_en_m ;	
wire	hpv_priv_e,hpstate_en_e ;	
wire	blkst_m, blkst_g ;
//wire	dc_direct_map ;		
wire	spubyp_trap_active_e,spubyp_trap_active_m, spubyp_trap_active_g ;
wire [6:0] spubyp_ttype ;
wire	spu_trap ;
wire	spu_trap0, spu_trap1, spu_trap2, spu_trap3 ;
wire	[6:0]	spu_ttype ; 
wire	spubyp0_trap,spubyp1_trap,spubyp2_trap,spubyp3_trap;
wire [6:0]	spubyp0_ttype,spubyp1_ttype,spubyp2_ttype,spubyp3_ttype;
wire	bendian_g ;
//wire va_wtchpt_rd_en, pa_wtchpt_rd_en;   
//wire lsu_bendian_access_g;
wire      lsu_tlb_tag_rd_vld_g ;
wire      lsu_dtlb_invalid_all_m ;

wire  [`L1D_WAY_ARRAY_MASK]   dva_vld_g;
wire          lsu_diagnstc_asi_rd_en;
wire  [3:0]   ld_thrd_byp_sel_g ;
wire  [3:0]           lmq_byp_data_sel0 ;     // ldxa vs stb bypass data sel.
wire  [3:0]           lmq_byp_data_sel1 ;     // ldxa vs stb bypass data sel.
wire  [3:0]           lmq_byp_data_sel2 ;     // ldxa vs stb bypass data sel.
wire  [3:0]           lmq_byp_data_sel3 ;     // ldxa vs stb bypass data sel.
wire  [2:0]           lmq_byp_ldxa_sel0 ;     // ldxa data sel - thread0
wire  [2:0]           lmq_byp_ldxa_sel1 ;     // ldxa data sel - thread1
wire  [2:0]           lmq_byp_ldxa_sel2 ;     // ldxa data sel - thread2
wire  [2:0]           lmq_byp_ldxa_sel3 ;     // ldxa data sel - thread3
wire    endian_mispred_g ;

   wire       ld_inst_vld_w2, ld_inst_vld_w3;

   wire [3:0] lmq_byp_data_raw_sel_d1;
   wire [3:0] lmq_byp_data_raw_sel_d2;

wire	asi_st_vld_g ;
wire  ignore_fill;

wire  [3:0]  pend_atm_ld_ue ;

wire [2:0]   lsu_byp_misc_addr_m ;   // lower 3bits of addr for ldxa/raw etc
wire [1:0]   lsu_byp_misc_sz_m ;     // size for ldxa/raw etc

//==========================================================
//RESET, CLK
//==========================================================     
   wire       reset;

//   assign     reset = ~rst_l;
   wire       dbb_reset_l;
   wire       clk;
   
    dffrl_async rstff(.din (grst_l),
                        .q   (dbb_reset_l),
                        .clk (clk), .se(se), .si(), .so(),
                        .rst_l (arst_l));

   assign  reset  =  ~dbb_reset_l;
   assign dctl_rst_l = dbb_reset_l;
   assign clk = rclk;

wire      lsu_bist_wvld_e ;           // bist writes to cache
wire  		lsu_bist_rvld_e ;	          // bist reads dcache

dff_s #(2) mbist_stge (
   .din ({mbist_dcache_write, mbist_dcache_read}),
   .q   ({lsu_bist_wvld_e,    lsu_bist_rvld_e  }),
   .clk (clk),
   .se  (se),       .si (),          .so ()
);   
  
//===========================================================
//from lsu_excpctl
//wire		lsu_flush_pipe_w ;	// flush - local to lsu

//   assign lsu_flush_pipe_w = dctl_flush_pipe_w;
   
//===========================================================
//   
   assign     lsu_ldst_inst_vld_e = ld_inst_vld_e | st_inst_vld_e;

//wire    lsu_l2fill_bendian_g;

wire memref_e;
   
dff_s #(1) stge_ad_e (
  .din (ifu_lsu_memref_d),
  .q   (memref_e),
  .clk (clk),
  .se     (se),       .si (),          .so ()
);   

//=================================================================================================
// SHADOW SCAN
//=================================================================================================

wire	sscan_data_13, sscan_data_14 ;
// stb status - this monitors the stb state
assign sscan_data_13 =
  ctu_sscan_tid[0] & lsu_stb_empty[0] |
  ctu_sscan_tid[1] & lsu_stb_empty[1] |
  ctu_sscan_tid[2] & lsu_stb_empty[2] |
  ctu_sscan_tid[3] & lsu_stb_empty[3] ;
   
     
// Monitors outstanding long-latency asi transactions - hangs thread. Doesn't cover all asi.
assign  sscan_data_14 =
                ctu_sscan_tid[0] & (tlb_ld_inst0 | tlb_st_inst0) |
               	ctu_sscan_tid[1] & (tlb_ld_inst1 | tlb_st_inst1) |
             		ctu_sscan_tid[2] & (tlb_ld_inst2 | tlb_st_inst2) | 
               	ctu_sscan_tid[3] & (tlb_ld_inst3 | tlb_st_inst3) ;

   
dff_s #(2) stg_d1 (
  .din ({sscan_data_14,sscan_data_13}),
  .q   (lsu_sscan_data[14:13]),
  .clk (clk),
  .se     (se),       .si (),          .so ()
);   

//=========================================================================================
//  INST_VLD_W GENERATION
//=========================================================================================
   
wire    flush_w_inst_vld_m ;
wire    lsu_inst_vld_w ;
assign  flush_w_inst_vld_m =
        ifu_tlu_inst_vld_m &
	~(dctl_flush_pipe_w & (thrid_m[1:0] == thrid_g[1:0])) ; // really lsu_flush_pipe_w

dff_s  stgw_ivld (
        .din    (flush_w_inst_vld_m),
        .q      (lsu_inst_vld_w),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );


// Specifically for qctl2. Does not include flush-pipe, but does include ifu's flush.
wire	ld_vld ;

   wire ifu_lsu_flush_w;

   wire ifu_tlu_flush_fd_w_q, ifu_tlu_flush_fd2_w_q, ifu_tlu_flush_fd3_w_q;
   
dff_s #(4) ifu_tlu_flush_stgw (
        .din    ({ifu_tlu_flush_m,ifu_tlu_flush_m,     ifu_tlu_flush_m,      ifu_tlu_flush_m}     ),
        .q      ({ifu_lsu_flush_w,ifu_tlu_flush_fd_w_q,ifu_tlu_flush_fd2_w_q,ifu_tlu_flush_fd3_w_q}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

bw_u1_buf_30x UZfix_ifu_tlu_flush_fd_w  ( .a(ifu_tlu_flush_fd_w_q),  .z(ifu_tlu_flush_fd_w)  );
bw_u1_buf_30x UZfix_ifu_tlu_flush_fd2_w ( .a(ifu_tlu_flush_fd2_w_q), .z(ifu_tlu_flush_fd2_w) );
bw_u1_buf_30x UZfix_ifu_tlu_flush_fd3_w ( .a(ifu_tlu_flush_fd3_w_q), .z(ifu_tlu_flush_fd3_w) );
   
assign	ld_vld = ld_inst_vld_unflushed & lsu_inst_vld_w & ~ifu_lsu_flush_w ;
wire	ld_vld_w_flush ;
assign	ld_vld_w_flush = ld_vld & ~dctl_flush_pipe_w ;
assign	lsu_ld_inst_vld_g[0] = ld_vld_w_flush & thread0_g ;
assign	lsu_ld_inst_vld_g[1] = ld_vld_w_flush & thread1_g ;
assign	lsu_ld_inst_vld_g[2] = ld_vld_w_flush & thread2_g ;
assign	lsu_ld_inst_vld_g[3] = ld_vld_w_flush & thread3_g ;

//=========================================================================================
//  TLB Control 
//=========================================================================================

wire	alt_space_e ;
dff_s #(1) aspace_e (
        .din    (ifu_lsu_alt_space_d),
        .q      (alt_space_e),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

//Atomics require translation.
assign tlb_ldst_cam_vld = 
  memref_e & 
    ~dtlb_bypass_e & ~(asi_internal_e & alt_space_e)  ;

// in hyper-lite mode, assumption is that real translation is not supported -
// a miss in tlb with real-translation enabled would result in real-address
// translation miss. This would be purely accidental on software's part.
//wire	dtlb_real_byp_e ;
//assign	dtlb_real_byp_e = hpstate_en_e & ~hpv_priv_e ;
// In hyper-lite mode, no concept of real xslation.
assign	lsu_dtlb_cam_real_e =
	// lsu-ctl based RA->PA 
  ( lsuctl_dtlb_byp_e & ~hpv_priv_e & hpstate_en_e) |
	// means RA->PA if used by hypervisor.
  ( tlb_byp_asi_e & hpstate_en_e & altspace_ldst_e) ;  
  //( tlb_byp_asi_e & dtlb_real_byp_e & altspace_ldst_e) ;  

assign  demap_thread0 = ~tlb_demap_thrid[1] & ~tlb_demap_thrid[0] ;
assign  demap_thread1 = ~tlb_demap_thrid[1] &  tlb_demap_thrid[0] ;
assign  demap_thread2 =  tlb_demap_thrid[1] & ~tlb_demap_thrid[0] ;
assign  demap_thread3 =  tlb_demap_thrid[1] &  tlb_demap_thrid[0] ;

// demap access and regular ldst access to tlb are assumed to
// be mutex.
assign thread0_ctxt =   ( demap_thread0 & tlb_demap_vld) | 
      (~tlb_demap_vld & thread0_e) ;
      //(thread0_e & memref_e) ;
assign thread1_ctxt =   ( demap_thread1 & tlb_demap_vld) | 
      (~tlb_demap_vld & thread1_e) ;
      //(thread1_e & memref_e) ;
assign thread2_ctxt =   ( demap_thread2 & tlb_demap_vld) | 
      (~tlb_demap_vld & thread2_e) ;
      //(thread2_e & memref_e) ;
assign thread3_ctxt =   ( demap_thread3 & tlb_demap_vld) | 
      (~tlb_demap_vld & thread3_e) ;
      //(thread3_e & memref_e) ;

assign  altspace_ldst_e   = memref_e &  alt_space_e ;
assign  non_altspace_ldst_e = memref_e & ~alt_space_e ;

dff_s #(2) aspace_stgm (
        .din    ({altspace_ldst_e,non_altspace_ldst_e}),
        .q      ({altspace_ldst_m,non_altspace_ldst_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dff_s #(2) aspace_stgg (
        .din    ({altspace_ldst_m,non_altspace_ldst_m}),
        .q      ({altspace_ldst_g,non_altspace_ldst_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

wire	[3:0]	tl_zero_d1 ;
dff_s #(4) tlz_stgd1 (
        .din    (tlu_lsu_tl_zero[3:0]),
        .q      (tl_zero_d1[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

mux4ds  #(1) trap_level_zero_mux (
        .in0    (tl_zero_d1[0]),
        .in1    (tl_zero_d1[1]),
        .in2    (tl_zero_d1[2]),
        .in3    (tl_zero_d1[3]),
        .sel0   (thread0_e),  
        .sel1   (thread1_e),
        .sel2   (thread2_e),  
        .sel3   (thread3_e),
        .dout   (thread_tl_zero)
);

wire	thread_tl_zero_m ;
dff_s #(1) ttlz_stgm (
        .din    (thread_tl_zero),
        .q      (thread_tl_zero_m),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );


assign	lsu_nonalt_nucl_access_m = non_altspace_ldst_m & ~thread_tl_zero_m ;

// Note : autodemap will need to be or'ed into tlb_demap_vld !!!
// use of tlu_lsu_tl_zero needs to be threaded.
assign  thread_pctxt =  ( tlb_demap_pctxt     &  tlb_demap_vld)      |  // demap
      ( non_altspace_ldst_e &  thread_tl_zero) |  // ldst. non-alt- space
      ( altspace_ldst_e     &  primary_asi_e)      |  // ldst. alt_space
      (~(memref_e | tlb_demap_vld)) ; // default for pipe
      //(~(ld_inst_vld_e | st_inst_vld_e | tlb_demap_vld)) ; // default for pipe
assign  thread_sctxt =  ( tlb_demap_sctxt     &  tlb_demap_vld)      |  // demap
      ( altspace_ldst_e     &  secondary_asi_e) ; // ldst. alt_space
assign  thread_nctxt =  ( tlb_demap_nctxt     &  tlb_demap_vld)      |  // demap
      ( non_altspace_ldst_e & ~thread_tl_zero) |  // ldst. non-alt- space
      ( altspace_ldst_e     &  nucleus_asi_e) ; // ldst. alt_space
assign  thread_actxt =  tlb_demap_actxt & tlb_demap_vld ; 

//tmp
   wire thread_default;
   assign thread_default = ~(thread_pctxt | thread_sctxt | thread_actxt);
   
wire	[3:0]	pstate_am ;
dff_s #(4) psam_stgd1 (
        .din    (tlu_lsu_pstate_am[3:0]),
        .q      (pstate_am[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

//assign  lsu_dtlb_addr_mask_l_e = 
//  thread0_e ? ~pstate_am[0] :
//    thread1_e ? ~pstate_am[1] :
//      thread2_e ? ~pstate_am[2] :
//          ~pstate_am[3] ;

mux4ds  #(1) pstate_am_mux (
        .in0    (~pstate_am[0]),
        .in1    (~pstate_am[1]),
        .in2    (~pstate_am[2]),
        .in3    (~pstate_am[3]),
        .sel0   (thread0_e),  
        .sel1   (thread1_e),
        .sel2   (thread2_e),  
        .sel3   (thread3_e),
        .dout   (lsu_dtlb_addr_mask_l_e)
);
   
//=========================================================================================
//  TLB RD/WR/DMP HANDLING
//=========================================================================================

// To speed up the tlb miss handler, wr_vld will now be generated based on
// admp occurence. lsu_dtlb_wr_vld_g is to be ignored. The following paths
// can be improved
// admp->write initiation (+2)
// write->completion initiation (+3)

wire admp_write ;
assign  admp_write = lsu_dtlb_dmp_vld_e & tlb_demap_actxt ;
wire admp_rst ;
assign  admp_rst = reset | lsu_dtlb_wr_vld_e ;

wire    local_dtlb_wr_vld_g ;
dffre_s #(1) twr_stgd1 (
        .din    (admp_write),
        .q      (local_dtlb_wr_vld_g),
        .clk    (clk),
        .en     (admp_write),   .rst    (admp_rst),
        .se     (se),       .si (),          .so ()
        );


wire    dtlb_wr_init_d1,dtlb_wr_init_d2,dtlb_wr_init_d3 ;
// Handshake between tlu and lsu needs to be fine-tuned !!!
assign  lsu_dtlb_wr_vld_e =  local_dtlb_wr_vld_g & ~(memref_e | dtlb_wr_init_d1 | dtlb_wr_init_d2) ;
//assign  lsu_dtlb_wr_vld_e =  tlu_dtlb_wr_vld_g & ~(memref_e | dtlb_done_d1 | dtlb_done_d2) ;
assign  lsu_dtlb_tag_rd_e =  tlu_dtlb_tag_rd_g & ~(memref_e | dtlb_done_d1 | dtlb_done_d2) ;
assign  lsu_dtlb_data_rd_e =  tlu_dtlb_data_rd_g & ~(memref_e | dtlb_done_d1 | dtlb_done_d2) ;
assign  lsu_dtlb_dmp_vld_e =  tlu_dtlb_dmp_vld_g & ~(memref_e | dtlb_done_d1 | dtlb_done_d2) ;
`ifndef NO_RTL_CSM
assign  lsu_dtlb_csm_rd_e = tlu_dtlb_csm_rd_g & ~(memref_e | dtlb_done_d1 | dtlb_done_d2) ;
`endif

   wire lsu_dtlb_dmp_all_e_tmp;
   
assign  lsu_dtlb_dmp_all_e_tmp =  tlu_dtlb_dmp_all_g & ~(memref_e | dtlb_done_d1 | dtlb_done_d2) ;
 bw_u1_buf_5x UZsize_lsu_dtlb_dmp_all_e (.a(lsu_dtlb_dmp_all_e_tmp), .z(lsu_dtlb_dmp_all_e));
   
assign  lsu_dtlb_rwindex_vld_e =  tlu_dtlb_rw_index_vld_g & ~(memref_e | dtlb_wr_init_d1 | dtlb_wr_init_d2) ;
//assign  lsu_dtlb_rwindex_vld_e =  tlu_dtlb_rw_index_vld_g & ~(memref_e | dtlb_done_d1 | dtlb_done_d2) ;
// Can remove reset once invalidate asi in place !!!
// assign lsu_dtlb_invalid_all_w2 = reset | tlu_dtlb_invalidate_all_g ;

assign  tlb_demap_vld = lsu_dtlb_dmp_vld_e ;

// Switchout for threads. Force threads to swo if tlb operation does not occur for over 5 cycles.

`ifndef NO_RTL_CSM
wire dtlb_csm_rd_d1;
dff_s #(6) tlbop_stgd1 (
        //.din    ({tlu_dtlb_wr_vld_g,tlu_dtlb_tag_rd_g,tlu_dtlb_data_rd_g,tlu_dtlb_dmp_vld_g,
        .din    ({local_dtlb_wr_vld_g,tlu_dtlb_tag_rd_g,tlu_dtlb_data_rd_g,tlu_dtlb_csm_rd_g,tlu_dtlb_dmp_vld_g,
    tlu_dtlb_invalidate_all_g}),
        .q      ({dtlb_wr_vld_d1,dtlb_tag_rd_d1,dtlb_data_rd_d1,dtlb_csm_rd_d1,dtlb_dmp_vld_d1,
    dtlb_inv_all_d1}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
`else
dff_s #(5) tlbop_stgd1 (
        //.din    ({tlu_dtlb_wr_vld_g,tlu_dtlb_tag_rd_g,tlu_dtlb_data_rd_g,tlu_dtlb_dmp_vld_g,
        .din    ({local_dtlb_wr_vld_g,tlu_dtlb_tag_rd_g,tlu_dtlb_data_rd_g,tlu_dtlb_dmp_vld_g,
    tlu_dtlb_invalidate_all_g}),
        .q      ({dtlb_wr_vld_d1,dtlb_tag_rd_d1,dtlb_data_rd_d1,dtlb_dmp_vld_d1,
    dtlb_inv_all_d1}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
`endif
// Detect event.
//bug6193 / ECO bug6511   
assign  ldst_in_pipe = memref_e ;
assign tlbop_init = 
  ((~dtlb_wr_vld_d1 & local_dtlb_wr_vld_g)  |
  (~dtlb_tag_rd_d1  & tlu_dtlb_tag_rd_g)   |
  (~dtlb_data_rd_d1 & tlu_dtlb_data_rd_g) |
  `ifndef NO_RTL_CSM
  (~dtlb_csm_rd_d1 & tlu_dtlb_csm_rd_g) | 
  `endif  
  (~dtlb_inv_all_d1 & tlu_dtlb_invalidate_all_g) |
  (~dtlb_dmp_vld_d1 & tlu_dtlb_dmp_vld_g)) & ldst_in_pipe ;

dff_s #(1) tlbinit_stgd1 ( .din    (tlbop_init), .q      (tlbop_init_d1),
        .clk    (clk), .se     (se),       .si (),          .so ());
dff_s #(1) tlbinit_stgd2 ( .din    (tlbop_init_d1 &  ldst_in_pipe), .q      (tlbop_init_d2),
        .clk    (clk), .se     (se),       .si (),          .so ());
dff_s #(1) tlbinit_stgd3 ( .din    (tlbop_init_d2 &  ldst_in_pipe), .q      (tlbop_init_d3),
        .clk    (clk), .se     (se),       .si (),          .so ());
dff_s #(1) tlbinit_stgd4 ( .din    (tlbop_init_d3 &  ldst_in_pipe), .q      (tlbop_init_d4),
        .clk    (clk), .se     (se),       .si (),          .so ());
dff_s #(1) tlbinit_stgd5 ( .din    (tlbop_init_d4 &  ldst_in_pipe), .q      (tlbop_init_d5),
        .clk    (clk), .se     (se),       .si (),          .so ());


assign  lsu_tlbop_force_swo = tlbop_init_d5 & ldst_in_pipe ;

//assign  dtlb_done =   lsu_dtlb_wr_vld_e  | lsu_dtlb_tag_rd_e | 
assign  dtlb_done =   	lsu_dtlb_tag_rd_e | lsu_dtlb_data_rd_e |
`ifndef NO_RTL_CSM
            lsu_dtlb_csm_rd_e | 
`endif 
			lsu_dtlb_dmp_vld_e | dtlb_inv_all_e ;

assign  dtlb_inv_all_e = tlu_dtlb_invalidate_all_g & ~(memref_e | dtlb_done_d1 | dtlb_done_d2) ;

`ifndef NO_RTL_CSM
dff_s #(4) dn_stgd1 (
        .din    ({dtlb_done,lsu_dtlb_tag_rd_e,lsu_dtlb_data_rd_e,lsu_dtlb_csm_rd_e}),
        .q      ({dtlb_done_d1,tag_rd_vld_m,data_rd_vld_m,csm_rd_vld_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
`else
dff_s #(3) dn_stgd1 (
        .din    ({dtlb_done,lsu_dtlb_tag_rd_e,lsu_dtlb_data_rd_e}),
        .q      ({dtlb_done_d1,tag_rd_vld_m,data_rd_vld_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
`endif
wire	dtlb_inv_all_din ;
assign	dtlb_inv_all_din = sehold ? dtlb_inv_all_m : dtlb_inv_all_e ;

dff_s #(1) dinv_stgd1 (
        .din    (dtlb_inv_all_din),
        .q      (dtlb_inv_all_m),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  lsu_dtlb_invalid_all_m = dtlb_inv_all_m ;
// added by sureshT
assign  lsu_dtlb_invalid_all_l_m = ~lsu_dtlb_invalid_all_m;

`ifndef NO_RTL_CSM
dff_s #(4) dn_stgd2 (
        .din    ({dtlb_done_d1,tag_rd_vld_m,data_rd_vld_m,csm_rd_vld_m}),
        .q      ({dtlb_done_d2,tag_rd_vld_g,data_rd_vld_g,csm_rd_vld_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
`else
dff_s #(3) dn_stgd2 (
        .din    ({dtlb_done_d1,tag_rd_vld_m,data_rd_vld_m}),
        .q      ({dtlb_done_d2,tag_rd_vld_g,data_rd_vld_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
`endif

`ifndef NO_RTL_CSM
assign lsu_tlb_csm_rd_vld_g = csm_rd_vld_g;
`endif
assign  lsu_tlb_data_rd_vld_g = data_rd_vld_g ;
assign  lsu_tlb_tag_rd_vld_g  = tag_rd_vld_g ;
//assign  lsu_tlb_st_vld_g = ~lsu_tlb_tag_rd_vld_g & ~lsu_tlb_data_rd_vld_g ;
   
// The handshake will have to change !!!
assign  lsu_tlu_dtlb_done = 
	dtlb_done_d2 |		// rest
	dtlb_wr_init_d3 ;	// write

// Note : if mx_sel bit is high, then it selects va instead of pa.


   
//=========================================================================================
//  State/ASI Registers.
//=========================================================================================

dff_s #(8) stctl_stg_e (
        .din    ({ifu_tlu_sraddr_d[6:0],ifu_tlu_wsr_inst_d}),
        .q      ({lsu_sraddr_e[6:0],    lsu_wsr_inst_e}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

assign lsu_tlu_wsr_inst_e = lsu_wsr_inst_e;

   wire asi_state_wr_en_e, asi_state_wr_en_m;
   
assign  asi_state_wr_en_e =   
	      ~lsu_sraddr_e[6] &  // 1=hypervisor
	      ~lsu_sraddr_e[5] &  // =0 for state reg. 
        ~lsu_sraddr_e[4] & ~lsu_sraddr_e[3] & 
        ~lsu_sraddr_e[2] &  lsu_sraddr_e[1] & 
         lsu_sraddr_e[0] & 
         lsu_wsr_inst_e ; // write
   
dff_s #(2) stctl_stg_m (
        .din    ({asi_state_wr_en_e, alt_space_e}),
        .q      ({asi_state_wr_en_m, lsu_alt_space_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(2) stctl_stg_w (
        .din    ({asi_state_wr_en_m, lsu_alt_space_m}),
        .q      ({asi_state_wr_en,   lsu_alt_space_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

//assign  asi_state_wr_en =   
//	~lsu_sraddr_w[6] &  // 1=hypervisor
//	~lsu_sraddr_w[5] &  // =0 for state reg. 
//        ~lsu_sraddr_w[4] & ~lsu_sraddr_w[3] & 
//        ~lsu_sraddr_w[2] &  lsu_sraddr_w[1] & 
//         lsu_sraddr_w[0] &  
//         lsu_wsr_inst_w ; // write


dff_s #(3) asi_stgw (
        .din    ({tlu_lsu_asi_update_m,tlu_lsu_tid_m[1:0]}),
        .q      ({tlu_lsu_asi_update_g,tlu_lsu_tid_g[1:0]}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 


assign  tsa_update_asi0 =  ~tlu_lsu_tid_g[1] & ~tlu_lsu_tid_g[0] & tlu_lsu_asi_update_g ;
assign  tsa_update_asi1 =  ~tlu_lsu_tid_g[1] &  tlu_lsu_tid_g[0] & tlu_lsu_asi_update_g ;
assign  tsa_update_asi2 =   tlu_lsu_tid_g[1] & ~tlu_lsu_tid_g[0] & tlu_lsu_asi_update_g ;
assign  tsa_update_asi3 =   tlu_lsu_tid_g[1] &  tlu_lsu_tid_g[0] & tlu_lsu_asi_update_g ;

assign  asi_state_wr_thrd[0] = 
((asi_state_wr_en & thread0_g) | tsa_update_asi0) & lsu_inst_vld_w & ~dctl_early_flush_w ;
//((asi_state_wr_en & thread0_g) | tsa_update_asi0) & lsu_inst_vld_w & ~lsu_flush_pipe_w ;
assign  asi_state_wr_thrd[1] = 
((asi_state_wr_en & thread1_g) | tsa_update_asi1) & lsu_inst_vld_w & ~dctl_early_flush_w ;
assign  asi_state_wr_thrd[2] = 
((asi_state_wr_en & thread2_g) | tsa_update_asi2) & lsu_inst_vld_w & ~dctl_early_flush_w ;
assign  asi_state_wr_thrd[3] = 
((asi_state_wr_en & thread3_g) | tsa_update_asi3) & lsu_inst_vld_w & ~dctl_early_flush_w ;

// dc diagnstc will swo on write.							
assign  sta_internal_e = asi_internal_e & st_inst_vld_e & alt_space_e ;
// dc diagnstc will not swo on read.							
assign  lda_internal_e = asi_internal_e & ~dc_diagnstc_asi_e & ld_inst_vld_e & alt_space_e ;

assign  ldsta_internal_e = sta_internal_e | lda_internal_e ;

// MMU_ASI
// Do no switch out for lds. lds switched out thru ldst_miss.
// qualification must be removed.
assign  lsu_ifu_ldsta_internal_e = asi_internal_e ;
//assign  lsu_ifu_ldsta_internal_e = asi_internal_e & ~ld_inst_vld_e  ;


dff_s #(2)  stai_stgm (
        .din    ({sta_internal_e,lda_internal_e}),
        .q      ({sta_internal_m,lda_internal_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

   wire stxa_internal_m;
   assign stxa_internal_m = sta_internal_m & ~(dtagv_diagnstc_asi_m | dc_diagnstc_asi_m);
   
dff_s #(2)  stai_stgg (
        .din    ({stxa_internal_m, lda_internal_m}),
        .q      ({stxa_internal,   ldxa_internal}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

   wire [7:0] ldst_va_g;
   
   assign ldst_va_g[7:0] = lsu_ldst_va_g[7:0];

   wire	[7:0]	lsu_asi_state ;
dff_s #(8)  asistate_stgg (
        .din    (lsu_dctl_asi_state_m[7:0]),
        .q      (lsu_asi_state[7:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
   
assign  pctxt_va_vld = (ldst_va_g[7:0] == 8'h08) ;
assign  pctxt_state_en =  (lsu_asi_state[7:0] == 8'h21) & pctxt_va_vld &
        lsu_alt_space_g & lsu_inst_vld_w ; 


//assign  pctxt_state_wr_thrd[0] = pctxt_state_en & st_inst_vld_g & thread0_g ;
assign  pctxt_state_wr_thrd[0] = pctxt_state_en & asi_st_vld_g & thread0_g ;
assign  pctxt_state_wr_thrd[1] = pctxt_state_en & asi_st_vld_g & thread1_g ;
assign  pctxt_state_wr_thrd[2] = pctxt_state_en & asi_st_vld_g & thread2_g ;
assign  pctxt_state_wr_thrd[3] = pctxt_state_en & asi_st_vld_g & thread3_g ;

//assign  pctxt_state_rd_en[0] = pctxt_state_en & ld_inst_vld_g & thread0_g ;

//assign  pctxt_state_rd_en[0] = pctxt_state_en & asi_ld_vld_g & thread0_g ;
//assign  pctxt_state_rd_en[1] = pctxt_state_en & asi_ld_vld_g & thread1_g ;
//assign  pctxt_state_rd_en[2] = pctxt_state_en & asi_ld_vld_g & thread2_g ;
//assign  pctxt_state_rd_en[3] = pctxt_state_en & asi_ld_vld_g & thread3_g ;


assign  sctxt_va_vld = (ldst_va_g[7:0] == 8'h10) ;
assign  sctxt_state_en =  (lsu_asi_state[7:0] == 8'h21) & sctxt_va_vld &
        lsu_alt_space_g & lsu_inst_vld_w ; 

assign  pscxt_ldxa_illgl_va = 
	(lsu_asi_state[7:0] == 8'h21) & ~(pctxt_va_vld | sctxt_va_vld) &
        lsu_alt_space_g & lsu_inst_vld_w ; 

//assign  sctxt_state_wr_thrd[0] = sctxt_state_en & st_inst_vld_g & thread0_g ;
assign  sctxt_state_wr_thrd[0] = sctxt_state_en & asi_st_vld_g & thread0_g ;
assign  sctxt_state_wr_thrd[1] = sctxt_state_en & asi_st_vld_g & thread1_g ;
assign  sctxt_state_wr_thrd[2] = sctxt_state_en & asi_st_vld_g & thread2_g ;
assign  sctxt_state_wr_thrd[3] = sctxt_state_en & asi_st_vld_g & thread3_g ;

//assign  sctxt_state_rd_en[0]   = sctxt_state_en & ld_inst_vld_g & thread0_g ;

//assign  sctxt_state_rd_en[0]   = sctxt_state_en & asi_ld_vld_g & thread0_g ;
//assign  sctxt_state_rd_en[1]   = sctxt_state_en & asi_ld_vld_g & thread1_g ;
//assign  sctxt_state_rd_en[2]   = sctxt_state_en & asi_ld_vld_g & thread2_g ;
//assign  sctxt_state_rd_en[3]   = sctxt_state_en & asi_ld_vld_g & thread3_g ;
   

// LSU CONTROL REGISTER. ASI=0x45,VA=0x00.
// b0 - i$ enable.
// b1 - d$ enable. 
// b2 - immu enable.
// b3 - dmmu enable.

assign  lsuctl_va_vld = (ldst_va_g[7:0] == 8'h00);
assign  lsu_ctl_state_en = (lsu_asi_state[7:0] == 8'h45) & lsuctl_va_vld &
        lsu_alt_space_g & lsu_inst_vld_w ; 
assign  lsuctl_illgl_va = (lsu_asi_state[7:0] == 8'h45) & ~lsuctl_va_vld &
        lsu_alt_space_g & lsu_inst_vld_w ; 

wire  [3:0] lctl_rst ;
   
//assign  lsu_ctl_state_wr_en[0] = (lsu_ctl_state_en & st_inst_vld_g & thread0_g) | lctl_rst[0] ;
assign  lsu_ctl_state_wr_en[0] = (lsu_ctl_state_en & asi_st_vld_g & thread0_g) | lctl_rst[0] ;
assign  lsu_ctl_state_wr_en[1] = (lsu_ctl_state_en & asi_st_vld_g & thread1_g) | lctl_rst[1] ;
assign  lsu_ctl_state_wr_en[2] = (lsu_ctl_state_en & asi_st_vld_g & thread2_g) | lctl_rst[2];
assign  lsu_ctl_state_wr_en[3] = (lsu_ctl_state_en & asi_st_vld_g & thread3_g) | lctl_rst[3];

//assign  lsu_ctl_state_rd_en[0] = lsu_ctl_state_en & ld_inst_vld_g & thread0_g ;
//assign  lsu_ctl_state_rd_en[0] = lsu_ctl_state_en & asi_ld_vld_g & thread0_g ;
//assign  lsu_ctl_state_rd_en[1] = lsu_ctl_state_en & asi_ld_vld_g & thread1_g ;
//assign  lsu_ctl_state_rd_en[2] = lsu_ctl_state_en & asi_ld_vld_g & thread2_g ;
//assign  lsu_ctl_state_rd_en[3] = lsu_ctl_state_en & asi_ld_vld_g & thread3_g ;

   

wire	[3:0]	redmode_rst ;
//dff #(4) rdmode_stgd1 (
//        .din    ({tlu_lsu_redmode_rst[3:0]}),
//        .q      ({redmode_rst[3:0]}),
//        .clk    (clk),
//        .se     (se),       .si (),          .so ()
//        );  

   assign   redmode_rst[3:0] =  tlu_lsu_redmode_rst_d1[3:0];
 
assign  lctl_rst[0] = redmode_rst[0] | reset ;
assign  lctl_rst[1] = redmode_rst[1] | reset ;
assign  lctl_rst[2] = redmode_rst[2] | reset ;
assign  lctl_rst[3] = redmode_rst[3] | reset ;

assign  lsuctl_ctlbits_wr_en[0] = lsu_ctl_state_wr_en[0] | dfture_tap_wr_en[0] | lctl_rst[0]; 
assign  lsuctl_ctlbits_wr_en[1] = lsu_ctl_state_wr_en[1] | dfture_tap_wr_en[1] | lctl_rst[1]; 
assign  lsuctl_ctlbits_wr_en[2] = lsu_ctl_state_wr_en[2] | dfture_tap_wr_en[2] | lctl_rst[2]; 
assign  lsuctl_ctlbits_wr_en[3] = lsu_ctl_state_wr_en[3] | dfture_tap_wr_en[3] | lctl_rst[3]; 

   assign dfture_tap_wr_mx_sel = | dfture_tap_wr_en[3:0];
   
// Could enhance bypass/enable conditions by adding all asi conditions.  
wire   [5:0] lsu_ctl_reg0;
wire   [5:0] lsu_ctl_reg1;
wire   [5:0] lsu_ctl_reg2;
wire   [5:0] lsu_ctl_reg3;

   assign lsu_ctl_reg0[5:0] = lsu_dp_ctl_reg0[5:0];
   assign lsu_ctl_reg1[5:0] = lsu_dp_ctl_reg1[5:0];
   assign lsu_ctl_reg2[5:0] = lsu_dp_ctl_reg2[5:0];
   assign lsu_ctl_reg3[5:0] = lsu_dp_ctl_reg3[5:0];

wire lsu_dcache_enable;
assign lsu_dcache_enable = 
  ((lsu_ctl_reg0[1] & thread0_e) | (lsu_ctl_reg1[1] & thread1_e)  | 
   (lsu_ctl_reg2[1] & thread2_e) | (lsu_ctl_reg3[1] & thread3_e)) ;

assign	lsuctl_dtlb_byp_e =
  (~lsu_ctl_reg0[3] & thread0_e) | (~lsu_ctl_reg1[3] & thread1_e) | 
  (~lsu_ctl_reg2[3] & thread2_e) | (~lsu_ctl_reg3[3] & thread3_e) ;
assign dtlb_bypass_e = 
  (lsuctl_dtlb_byp_e & ~hpstate_en_e) | // hpv enabled - byp is RA->PA for supv.
  ( tlb_byp_asi_e & ~hpstate_en_e & altspace_ldst_e) |  // altspace tlb bypass - non-hpv
    ((hpv_priv_e & hpstate_en_e) & ~(alt_space_e & (as_if_user_asi_e | tlb_byp_asi_e)));
	// hpv enabled VA->PA 

assign  lsu_dtlb_bypass_e = dtlb_bypass_e ; 
wire  dcache_enable_m,dcache_enable_g ;
dff_s #(2) dbyp_stgm (
        .din    ({dtlb_bypass_e,lsu_dcache_enable}),
        .q      ({dtlb_bypass_m,dcache_enable_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(2) dbyp_stgg (
        .din    ({dtlb_bypass_m,dcache_enable_m}),
        .q      ({lsu_dtlb_bypass_g,dcache_enable_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

   wire lsu_ctl_reg0_bf_b0, lsu_ctl_reg1_bf_b0, lsu_ctl_reg2_bf_b0, lsu_ctl_reg3_bf_b0;
   wire lsu_ctl_reg0_bf_b2, lsu_ctl_reg1_bf_b2, lsu_ctl_reg2_bf_b2, lsu_ctl_reg3_bf_b2;
   
bw_u1_buf_1x UZsize_ctl_reg0_b0  ( .a(lsu_ctl_reg0[0]),  .z(lsu_ctl_reg0_bf_b0)  );
bw_u1_buf_1x UZsize_ctl_reg0_b2  ( .a(lsu_ctl_reg0[2]),  .z(lsu_ctl_reg0_bf_b2)  );
bw_u1_buf_1x UZsize_ctl_reg1_b0  ( .a(lsu_ctl_reg1[0]),  .z(lsu_ctl_reg1_bf_b0)  );
bw_u1_buf_1x UZsize_ctl_reg1_b2  ( .a(lsu_ctl_reg1[2]),  .z(lsu_ctl_reg1_bf_b2)  );
bw_u1_buf_1x UZsize_ctl_reg2_b0  ( .a(lsu_ctl_reg2[0]),  .z(lsu_ctl_reg2_bf_b0)  );
bw_u1_buf_1x UZsize_ctl_reg2_b2  ( .a(lsu_ctl_reg2[2]),  .z(lsu_ctl_reg2_bf_b2)  );
bw_u1_buf_1x UZsize_ctl_reg3_b0  ( .a(lsu_ctl_reg3[0]),  .z(lsu_ctl_reg3_bf_b0)  );
bw_u1_buf_1x UZsize_ctl_reg3_b2  ( .a(lsu_ctl_reg3[2]),  .z(lsu_ctl_reg3_bf_b2)  );
   
assign lsu_ifu_icache_en[3:0] = 
  {lsu_ctl_reg3_bf_b0,lsu_ctl_reg2_bf_b0,lsu_ctl_reg1_bf_b0,lsu_ctl_reg0_bf_b0} & ~tlu_lsu_redmode[3:0] ;
assign lsu_ifu_itlb_en[3:0] = 
  {lsu_ctl_reg3_bf_b2,lsu_ctl_reg2_bf_b2,lsu_ctl_reg1_bf_b2,lsu_ctl_reg0_bf_b2} & ~tlu_lsu_redmode[3:0] ;

//=========================================================================================
//  DCACHE Access thru IOBrdge
//=========================================================================================

wire	iob_fwdpkt_vld ;
dff_s  iobvld_stg (
        .din    (lsu_iobrdge_fwd_pkt_vld),
        .q      (iob_fwdpkt_vld),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

wire	dcache_iob_wr_e, dcache_iob_rd_e ;
wire	dcache_iob_wr, dcache_iob_rd ;
assign dcache_iob_wr =
~lsu_iobrdge_tap_rq_type_b8[8] & lsu_iobrdge_tap_rq_type_b6_b3[6] & lsu_iobrdge_fwd_pkt_vld ;
assign dcache_iob_rd =
 lsu_iobrdge_tap_rq_type_b8[8] & lsu_iobrdge_tap_rq_type_b6_b3[6] & lsu_iobrdge_fwd_pkt_vld ;

dff_s #(2) dcrw_stge (
        .din    ({dcache_iob_wr,dcache_iob_rd}),
        .q      ({dcache_iob_wr_e,dcache_iob_rd_e}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

assign	lsu_dc_iob_access_e = dcache_iob_wr_e | dcache_iob_rd_e ;

//=========================================================================================
//  Miscellaneous ASI
//=========================================================================================

// Defeature effects the asi lsu_ctl_reg.
// Margin ASI
// Diag  ASI - No TAP access
// BIST ASI   

assign  tap_thread[0] = ~lsu_iobrdge_tap_rq_type_b1_b0[1] & ~lsu_iobrdge_tap_rq_type_b1_b0[0] ;
assign  tap_thread[1] = ~lsu_iobrdge_tap_rq_type_b1_b0[1] &  lsu_iobrdge_tap_rq_type_b1_b0[0] ;
assign  tap_thread[2] =  lsu_iobrdge_tap_rq_type_b1_b0[1] & ~lsu_iobrdge_tap_rq_type_b1_b0[0] ;
assign  tap_thread[3] =  lsu_iobrdge_tap_rq_type_b1_b0[1] &  lsu_iobrdge_tap_rq_type_b1_b0[0] ;

wire bist_tap_rd,bist_tap_wr ;
assign  bist_tap_rd =  
 lsu_iobrdge_tap_rq_type_b8[8] & lsu_iobrdge_tap_rq_type_b6_b3[5] & iob_fwdpkt_vld ;
assign  bist_tap_wr = 
~lsu_iobrdge_tap_rq_type_b8[8] & lsu_iobrdge_tap_rq_type_b6_b3[5] & iob_fwdpkt_vld ;

/*   
dff_s #(2) bstrw_stge (
        .din    ({bist_tap_rd,bist_tap_wr}),
        .q      ({bist_tap_rd_en,bist_tap_wr_en}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  
*/
dff_s #(1) bstrw_stge (
        .din    ({bist_tap_wr}),
        .q      ({bist_tap_wr_en}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  
   
wire mrgn_tap_rd,mrgn_tap_wr ;
assign  mrgn_tap_rd =  
lsu_iobrdge_tap_rq_type_b8[8] & lsu_iobrdge_tap_rq_type_b6_b3[4] & iob_fwdpkt_vld ;
assign  mrgn_tap_wr = 
~lsu_iobrdge_tap_rq_type_b8[8] & lsu_iobrdge_tap_rq_type_b6_b3[4] & iob_fwdpkt_vld ;
/*
dff_s #(2) mrgnrw_stge (
        .din    ({mrgn_tap_rd,mrgn_tap_wr}),
        .q      ({mrgn_tap_rd_en,mrgn_tap_wr_en}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  
*/
dff_s #(1) mrgnrw_stge (
        .din    ({mrgn_tap_wr}),
        .q      ({mrgn_tap_wr_en}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  
   
wire  dfture_access_vld ;
wire	[3:0]	dfture_tap_rd,dfture_tap_wr ;
assign  dfture_access_vld = lsu_iobrdge_tap_rq_type_b6_b3[3] & iob_fwdpkt_vld ;

assign  dfture_tap_rd[0] =  
  lsu_iobrdge_tap_rq_type_b8[8] & dfture_access_vld & tap_thread[0] ;
assign  dfture_tap_rd[1] =  
  lsu_iobrdge_tap_rq_type_b8[8] & dfture_access_vld & tap_thread[1] ;
assign  dfture_tap_rd[2] =  
  lsu_iobrdge_tap_rq_type_b8[8] & dfture_access_vld & tap_thread[2] ;
assign  dfture_tap_rd[3] =  
  lsu_iobrdge_tap_rq_type_b8[8] & dfture_access_vld & tap_thread[3] ;

   wire dfture_tap_rd_default;
   assign dfture_tap_rd_default = ~| dfture_tap_rd[2:0];
   
assign  dfture_tap_wr[0] = 
  ~lsu_iobrdge_tap_rq_type_b8[8] & dfture_access_vld & tap_thread[0] ;
assign  dfture_tap_wr[1] = 
  ~lsu_iobrdge_tap_rq_type_b8[8] & dfture_access_vld & tap_thread[1] ;
assign  dfture_tap_wr[2] = 
  ~lsu_iobrdge_tap_rq_type_b8[8] & dfture_access_vld & tap_thread[2] ;
assign  dfture_tap_wr[3] = 
  ~lsu_iobrdge_tap_rq_type_b8[8] & dfture_access_vld & tap_thread[3] ;

dff_s #(8) dftrw_stge (
        .din    ({dfture_tap_rd_default, dfture_tap_rd[2:0],dfture_tap_wr[3:0]}),
        .q    	({dfture_tap_rd_d1[3:0],                    dfture_tap_wr_en[3:0]}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

   
   assign dfture_tap_rd_en [0] = dfture_tap_rd_d1[0] & ~rst_tri_en;
   assign dfture_tap_rd_en [1] = dfture_tap_rd_d1[1] & ~rst_tri_en;
   assign dfture_tap_rd_en [2] = dfture_tap_rd_d1[2] & ~rst_tri_en;
   assign dfture_tap_rd_en [3] = dfture_tap_rd_d1[3] | rst_tri_en;
   
                                      
// BIST_Controller ASI

wire	bistctl_va_vld_m,bistctl_state_en_m;
assign  bistctl_va_vld_m = (lsu_ldst_va_b7_b0_m[7:0] == 8'h00);
assign  bistctl_state_en_m = (lsu_dctl_asi_state_m[7:0] == 8'h42) & bistctl_va_vld_m &
        lsu_alt_space_m ;
dff_s  #(2) bistdcd_stw (
        .din    ({bistctl_va_vld_m,bistctl_state_en_m}),
        .q    	({bistctl_va_vld,bistctl_state_en}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 
// asi42 dealt with as a whole.
/*assign  bistctl_illgl_va = (lsu_asi_state[7:0] == 8'h42) & ~bistctl_va_vld &
        lsu_alt_space_g ;*/
//assign  bistctl_rd_en = bistctl_state_en & asi_ld_vld_g ;
assign  bistctl_wr_en = (bistctl_state_en & asi_st_vld_g) | bist_tap_wr_en ;
//assign  bistctl_rd_en = bistctl_state_en & ld_inst_vld_g ;
//assign  bistctl_wr_en = (bistctl_state_en & st_inst_vld_g) | bist_tap_wr_en ;
   
//test_stub interface. bist_tap_wr_en should exclude?
assign  bist_ctl_reg_wr_en = bistctl_wr_en;
   

// Self-Timed Margin Control ASI

wire	mrgnctl_va_vld_m,mrgnctl_state_en_m;
assign  mrgnctl_va_vld_m = (lsu_ldst_va_b7_b0_m[7:0] == 8'h00);
assign  mrgnctl_state_en_m = (lsu_dctl_asi_state_m[7:0] == 8'h44) & mrgnctl_va_vld_m &
        lsu_alt_space_m ;
dff_s  #(2) mrgndcd_stw (
        .din    ({mrgnctl_va_vld_m,mrgnctl_state_en_m}),
        .q    	({mrgnctl_va_vld,mrgnctl_state_en}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

assign  mrgnctl_illgl_va = (lsu_asi_state[7:0] == 8'h44) & ~mrgnctl_va_vld &
        lsu_alt_space_g ;

assign  mrgnctl_wr_en = ((mrgnctl_state_en & asi_st_vld_g) | mrgn_tap_wr_en | ~dctl_rst_l) & ~sehold; //bug 4508

// LSU Diag Reg ASI
// No access from tap.
wire	ldiagctl_va_vld_m,ldiagctl_state_en_m;
assign  ldiagctl_va_vld_m = (lsu_ldst_va_b7_b0_m[7:0] == 8'h10);
assign  ldiagctl_state_en_m = (lsu_dctl_asi_state_m[7:0] == 8'h42) & ldiagctl_va_vld_m &
        lsu_alt_space_m ;
dff_s  #(2) ldiagdcd_stw (
        .din    ({ldiagctl_va_vld_m,ldiagctl_state_en_m}),
        .q    	({ldiagctl_va_vld,ldiagctl_state_en}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 
// asi42 dealt with as a whole.
/*assign  ldiagctl_illgl_va = (lsu_asi_state[7:0] == 8'h42) & ~ldiagctl_va_vld &
        lsu_alt_space_g ;*/

wire	asi42_g ;
wire	ifu_asi42_flush_g ;
assign	ifu_asi42_flush_g = 
	bistctl_state_en | ldiagctl_state_en | // lsu's asi42 should not set asi queue.
	(asi42_g & asi42_illgl_va) ; 		// illgl-va should not set asi queue.

//assign  ldiagctl_rd_en = ldiagctl_state_en & asi_ld_vld_g ;
assign  ldiagctl_wr_en = (ldiagctl_state_en & asi_st_vld_g) | reset;
//assign  ldiagctl_rd_en = ldiagctl_state_en & ld_inst_vld_g ;
//assign  ldiagctl_wr_en = (ldiagctl_state_en & st_inst_vld_g) | reset;

wire  instmsk_va_vld ;
assign  instmsk_va_vld = (ldst_va_g[7:0] == 8'h08);
assign	asi42_g = (lsu_asi_state[7:0] == 8'h42) ; 
assign  asi42_illgl_va = 
	asi42_g &
	~(ldiagctl_va_vld | bistctl_va_vld | instmsk_va_vld) &
        lsu_alt_space_g ;



//=========================================================================================
//  Partition ID Register
//=========================================================================================

// ASI=58, VA=0x80, Per thread
// The pid is to be used by tlb-cam, and writes to tlb. It is kept in the lsu
// as it is used by the dtlb, plus changes to mmu_dp are to be kept to a minimum.

// Trap if supervisor accesses hyperpriv asi - see supv_use_hyp. Could be incorrect.
// Correct on merge to mainline.

// The VA compares can probably be shortened.
assign  pid_va_vld = (ldst_va_g[7:0] == 8'h80);
assign  pid_state_en = (lsu_asi_state[7:0] == 8'h58) & pid_va_vld &
        lsu_alt_space_g & lsu_inst_vld_w ; 
//assign  pid_illgl_va = (lsu_asi_state[7:0] == 8'h58) & ~pid_va_vld &
//        lsu_alt_space_g & lsu_inst_vld_w ; 

// remove reset ??
//assign  pid_state_wr_en[0] = (pid_state_en & st_inst_vld_g & thread0_g) | reset ;
assign  pid_state_wr_en[0] = (pid_state_en & asi_st_vld_g & thread0_g) | reset ;
assign  pid_state_wr_en[1] = (pid_state_en & asi_st_vld_g & thread1_g) | reset ;
assign  pid_state_wr_en[2] = (pid_state_en & asi_st_vld_g & thread2_g) | reset ;
assign  pid_state_wr_en[3] = (pid_state_en & asi_st_vld_g & thread3_g) | reset ;

//assign  pid_state_rd_en[0] = pid_state_en & ld_inst_vld_g & thread0_g ;

//assign  pid_state_rd_en[0] = pid_state_en & asi_ld_vld_g & thread0_g ;
//assign  pid_state_rd_en[1] = pid_state_en & asi_ld_vld_g & thread1_g ;
//assign  pid_state_rd_en[2] = pid_state_en & asi_ld_vld_g & thread2_g ;
//assign  pid_state_rd_en[3] = pid_state_en & asi_ld_vld_g & thread3_g ;


//=========================================================================================
//  Local LDXA Read
//=========================================================================================

// Timing : rd_en changed to _en with inst_vld

//wire  [3:0] misc_ctl_sel ;
wire    misc_tap_rd_sel ;
/*
assign  misc_tap_rd_sel = mrgn_tap_rd_en | bist_tap_rd_en |  dfture_tap_rd_sel ;
assign  misc_ctl_sel[0] = bist_tap_rd_en | (~misc_tap_rd_sel &  bistctl_state_en & ld_inst_vld_unflushed) ;
assign  misc_ctl_sel[1] = mrgn_tap_rd_en | (~misc_tap_rd_sel &  mrgnctl_state_en & ld_inst_vld_unflushed) ;
assign  misc_ctl_sel[3] = dfture_tap_rd_sel ;

//assign  misc_ctl_sel[2] = (~misc_tap_rd_sel & ldiagctl_state_en & ld_inst_vld_unflushed) ;
assign  misc_ctl_sel[2] = ~(misc_ctl_sel[0] | misc_ctl_sel[1] | misc_ctl_sel[3] ); //force default
*/
   
//****push misc_ctl_sel in previosu cycle*****
   wire [3:0] misc_ctl_sel_din;

//0-in bug, priority encode tap requests to prevent illegal type through one-hot mux   
   wire       dfture_tap_rd_or ;
   assign     dfture_tap_rd_or = | (dfture_tap_rd [3:0]);
   assign     misc_tap_rd_sel = mrgn_tap_rd | bist_tap_rd |  dfture_tap_rd_or ;
   assign     misc_ctl_sel_din[0] = bist_tap_rd | 
                                   (~misc_tap_rd_sel &  bistctl_state_en_m & ld_inst_vld_m) ;
   assign     misc_ctl_sel_din[1] = (~bist_tap_rd & mrgn_tap_rd) | 
                                    (~misc_tap_rd_sel &  mrgnctl_state_en_m & ld_inst_vld_m) ;
   assign     misc_ctl_sel_din[3] = ~bist_tap_rd & ~mrgn_tap_rd & dfture_tap_rd_or;
   assign     misc_ctl_sel_din[2] = ~(misc_ctl_sel_din[0] | misc_ctl_sel_din[1] | misc_ctl_sel_din[3] ) ;


  
// ASI accesses should be mutex except for non-access cases.
assign  lsu_asi_sel_fmx1[0] = pctxt_state_en & ld_inst_vld_unflushed;  
assign  lsu_asi_sel_fmx1[1] = sctxt_state_en & ld_inst_vld_unflushed & ~lsu_asi_sel_fmx1[0]; 
assign  lsu_asi_sel_fmx1[2] = ~(|lsu_asi_sel_fmx1[1:0]);   //force default

assign  lsu_asi_sel_fmx2[0] = |lsu_asi_sel_fmx1[1:0] | (pid_state_en & ld_inst_vld_unflushed) ;  
assign  lsu_asi_sel_fmx2[1] = lsu_ctl_state_en & ld_inst_vld_unflushed & ~(lsu_asi_sel_fmx2[0]);  
assign  lsu_asi_sel_fmx2[2] = ~(|lsu_asi_sel_fmx2[1:0]) ; //force default

   wire va_wtchpt_en;
  
wire	lsu_asi_rd_sel ; 
//assign  lsu_asi_rd_sel = ((|lsu_asi_sel_fmx1[1:0]) | 
//                         ((pid_state_en | va_wtchpt_en) & ld_inst_vld_unflushed) |
//		                   	 (|lsu_asi_sel_fmx2[1:0]) | 
//                          misc_asi_rd_en) & 
//                        lsu_inst_vld_w ;   

assign  lsu_asi_rd_sel = ((|lsu_asi_sel_fmx1[1:0]) | 
                         (pid_state_en  & ld_inst_vld_unflushed) |     //remove va_wtchpt_en
		                   	 (|lsu_asi_sel_fmx2[1:0]) | 
                          misc_asi_rd_en) & 
                          lsu_inst_vld_w ;   

   
assign	lsu_asi_rd_en = (lsu_asi_rd_sel | lsu_va_wtchpt_sel_g) & ~dctl_early_flush_w ; //add va_wtchpt

//assign	lsu_asi_rd_en = lsu_asi_rd_sel & ~lsu_flush_pipe_w ;

assign  misc_asi_rd_en = (bistctl_state_en | mrgnctl_state_en | ldiagctl_state_en) & ld_inst_vld_unflushed ;

assign        lsu_local_ldxa_sel_g =  lsu_asi_rd_sel  & ~rst_tri_en ; // w/o flush
`ifndef NO_RTL_CSM
assign        lsu_local_ldxa_tlbrd_sel_g  =  (lsu_tlb_tag_rd_vld_g | lsu_tlb_data_rd_vld_g | lsu_tlb_csm_rd_vld_g) & ~rst_tri_en;
`else
assign        lsu_local_ldxa_tlbrd_sel_g  =  (lsu_tlb_tag_rd_vld_g | lsu_tlb_data_rd_vld_g) & ~rst_tri_en;
`endif
assign        lsu_va_wtchpt_sel_g =  (va_wtchpt_en & ld_inst_vld_unflushed) & ~rst_tri_en;

assign        lsu_local_diagnstc_tagrd_sel_g  =  (~(lsu_local_ldxa_sel_g | lsu_local_ldxa_tlbrd_sel_g |
                                                   lsu_va_wtchpt_sel_g)) | rst_tri_en; //add va_wtchpt

// or diagnostic read w/ asi read enable
assign  lsu_diagnstc_asi_rd_en  =  lsu_asi_rd_en | dtagv_diagnstc_rd_g  ; //Bug 3959
//assign  lsu_diagnstc_asi_rd_en  =  lsu_asi_rd_en | dtagv_diagnstc_rd_g  | lsu_local_ldxa_tlbrd_sel_g;


dff_s  #(1) lldxa_stw2 (
        .din    (lsu_diagnstc_asi_rd_en),
        .q      (lsu_asi_rd_en_w2),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

wire	ldxa_tlbrd0_w2,ldxa_tlbrd1_w2,ldxa_tlbrd2_w2,ldxa_tlbrd3_w2;
wire	ldxa_tlbrd0_w3,ldxa_tlbrd1_w3,ldxa_tlbrd2_w3,ldxa_tlbrd3_w3;

// stg mismatched intentionally. stxa_tid decode can be used by ldxa.
assign	ldxa_tlbrd3_w2 = tlu_stxa_thread3_w2 & lsu_local_ldxa_tlbrd_sel_g ;
assign	ldxa_tlbrd2_w2 = tlu_stxa_thread2_w2 & lsu_local_ldxa_tlbrd_sel_g ;
assign	ldxa_tlbrd1_w2 = tlu_stxa_thread1_w2 & lsu_local_ldxa_tlbrd_sel_g ;
assign	ldxa_tlbrd0_w2 = tlu_stxa_thread0_w2 & lsu_local_ldxa_tlbrd_sel_g ;

// Bug 3959
dff_s  #(4) tlbrd_stw3 (
        .din    ({ldxa_tlbrd3_w2,ldxa_tlbrd2_w2,
        	ldxa_tlbrd1_w2,ldxa_tlbrd0_w2}),
        .q    	({ldxa_tlbrd3_w3,ldxa_tlbrd2_w3,
        	ldxa_tlbrd1_w3,ldxa_tlbrd0_w3}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

// pid and va-wtchpt va removed.
assign  lsu_asi_illgl_va = 
  lsuctl_illgl_va | pscxt_ldxa_illgl_va | mrgnctl_illgl_va | asi42_illgl_va ;
assign  lsu_asi_illgl_va_cmplt[0] = lsu_asi_illgl_va & ld_inst_vld_g & thread0_g ;
assign  lsu_asi_illgl_va_cmplt[1] = lsu_asi_illgl_va & ld_inst_vld_g & thread1_g ;
assign  lsu_asi_illgl_va_cmplt[2] = lsu_asi_illgl_va & ld_inst_vld_g & thread2_g ;
assign  lsu_asi_illgl_va_cmplt[3] = lsu_asi_illgl_va & ld_inst_vld_g & thread3_g ;

dff_s  #(4) lsuillgl_stgw2(
        .din    (lsu_asi_illgl_va_cmplt[3:0]),
        .q      (lsu_asi_illgl_va_cmplt_w2[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

//=========================================================================================
//  ASI_DCACHE_TAG way decode
//=========================================================================================

// Bug 4569. 
// add sehold. adding in dctldp flop will cause critical path.

wire	[3:0]	dtag_rsel_dcd,dtag_rsel_hold ;
assign  dtag_rsel_dcd[3:0]  =  	{(lsu_ldst_va_b12_b11_m[12:11] == 2'b11),
                               	(lsu_ldst_va_b12_b11_m[12:11] == 2'b10),
                               	(lsu_ldst_va_b12_b11_m[12:11] == 2'b01),
                                (lsu_ldst_va_b12_b11_m[12:11] == 2'b00)};
//bug5994
dffe_s #(4) dtag_hold (
        .din    (dtag_rsel_dcd[3:0]),
        .q      (dtag_rsel_hold[3:0]),
        .en     (sehold),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign	lsu_dtag_rsel_m[3:0] = sehold ? dtag_rsel_hold[3:0] : dtag_rsel_dcd[3:0] ;


//=========================================================================================
//  Watchpoint Control
//=========================================================================================
   wire va_vld;
   
assign  va_vld = (ldst_va_g[7:0] == 8'h38);
   
assign  va_wtchpt_en = (lsu_asi_state[7:0] == 8'h58)  & va_vld &
      lsu_alt_space_g & lsu_inst_vld_w ; 

// Illegal va checking for asi 58 done in MMU.
   
// one VA watchptr supported per thread

// Need to read register !!!
// Switchout thread on read.
// qualify with inst_vld_w.
//assign  va_wtchpt_rd_en = va_wtchpt_en & ld_inst_vld_g ;

   wire va_wtchpt0_wr_en, va_wtchpt1_wr_en, va_wtchpt2_wr_en, va_wtchpt3_wr_en;
  
//assign  va_wtchpt0_wr_en = va_wtchpt_en & st_inst_vld_g & thread0_g;
assign  va_wtchpt0_wr_en = va_wtchpt_en & asi_st_vld_g & thread0_g;
assign  va_wtchpt1_wr_en = va_wtchpt_en & asi_st_vld_g & thread1_g;
assign  va_wtchpt2_wr_en = va_wtchpt_en & asi_st_vld_g & thread2_g;
assign  va_wtchpt3_wr_en = va_wtchpt_en & asi_st_vld_g & thread3_g;
assign  lsu_va_wtchpt0_wr_en_l = ~va_wtchpt0_wr_en ;
assign  lsu_va_wtchpt1_wr_en_l = ~va_wtchpt1_wr_en ;
assign  lsu_va_wtchpt2_wr_en_l = ~va_wtchpt2_wr_en ;
assign  lsu_va_wtchpt3_wr_en_l = ~va_wtchpt3_wr_en ;

assign  vw_wtchpt_cmp_en_m =  // VA Write Watchpoint Enable
  (thread0_m & lsu_ctl_reg0[4]) | 
  (thread1_m & lsu_ctl_reg1[4]) | 
  (thread2_m & lsu_ctl_reg2[4]) | 
  (thread3_m & lsu_ctl_reg3[4]) ; 

assign  vr_wtchpt_cmp_en_m =  // VA Read Watchpoint Enable
  (thread0_m & lsu_ctl_reg0[5]) | 
  (thread1_m & lsu_ctl_reg1[5]) | 
  (thread2_m & lsu_ctl_reg2[5]) | 
  (thread3_m & lsu_ctl_reg3[5]) ; 

   assign  va_wtchpt_cmp_en_m =
(vw_wtchpt_cmp_en_m & st_inst_vld_m) | 
(vr_wtchpt_cmp_en_m & ld_inst_vld_m) ; 

//=========================================================================================
//  Hit/Miss/Fill Control
//=========================================================================================
dff_s  #(10) stg_m (
        .din    ({ld_inst_vld_e, st_inst_vld_e,ldst_sz_e[1:0],
    ifu_lsu_rd_e[4:0],ifu_lsu_ldst_fp_e}),
        .q      ({ld_inst_vld_m, st_inst_vld_m,ldst_sz_m[1:0],
    ld_rd_m[4:0],fp_ldst_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

wire    dcache_arry_data_sel_e;

assign   dcache_arry_data_sel_e = lsu_bist_rvld_e | ld_inst_vld_e | dcache_iob_rd_e ;
dff_s #(1) dcache_arry_data_sel_stgm (
  .din (dcache_arry_data_sel_e),
  .q   (dcache_arry_data_sel_m),
  .clk    (clk),
  .se     (se),       .si (),          .so ()
); 

   
dff_s  #(10) stg_g (
        .din    ({ld_inst_vld_m, st_inst_vld_m,ldst_sz_m[1:0],
    ld_rd_m[4:0],fp_ldst_m}),
        .q      ({ld_inst_vld_unflushed, st_inst_vld_unflushed,ldst_sz_g[1:0],
    ld_rd_g[4:0],fp_ldst_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 


//assign  asi_ld_vld_g = ld_inst_vld_unflushed & lsu_inst_vld_w & ~dctl_early_flush_w ;
assign  asi_st_vld_g = st_inst_vld_unflushed & lsu_inst_vld_w & ~dctl_early_flush_w ;
assign  ld_inst_vld_g = ld_inst_vld_unflushed & lsu_inst_vld_w & ~dctl_flush_pipe_w ;
assign  st_inst_vld_g = st_inst_vld_unflushed & lsu_inst_vld_w & ~dctl_flush_pipe_w ;

// assign  lsu_way_hit[0] = cache_way_hit_buf1[0] & dcache_enable_g ;
// assign  lsu_way_hit[1] = cache_way_hit_buf1[1] & dcache_enable_g ;
// assign  lsu_way_hit[2] = cache_way_hit_buf1[2] & dcache_enable_g ;
// assign  lsu_way_hit[3] = cache_way_hit_buf1[3] & dcache_enable_g ;
  

 assign  lsu_way_hit[0] = cache_way_hit_buf1[0] & dcache_enable_g ;


 assign  lsu_way_hit[1] = cache_way_hit_buf1[1] & dcache_enable_g ;


 assign  lsu_way_hit[2] = cache_way_hit_buf1[2] & dcache_enable_g ;


 assign  lsu_way_hit[3] = cache_way_hit_buf1[3] & dcache_enable_g ;


 
//assign  st_set_index_g[5:0] = ldst_va_g[9:4] ;
//assign  st_set_way_g[3:1] = lsu_way_hit[3:1] ;

// This should contain ld miss, MMU miss, exception. 
// should tlb_cam_miss be factored in or can miss/hit be solely
// based on way_hit.

wire  tlb_cam_hit_mod ;
dff_s  stgcmiss_g (
        .din    (tlb_cam_hit),
        .q      (tlb_cam_hit_mod),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

// NOTE !! qualification with tte_data_parity_error removed for timing.
assign tlb_cam_hit_g = tlb_cam_hit_mod ;
//assign tlb_cam_hit_g = tlb_cam_hit_mod & ~tte_data_parity_error ;

/*assign  ld_stb_hit_g = 
        ld_stb0_full_raw_g | ld_stb1_full_raw_g |
        ld_stb2_full_raw_g | ld_stb3_full_raw_g |
        ld_stb0_partial_raw_g | ld_stb1_partial_raw_g |
        ld_stb2_partial_raw_g | ld_stb3_partial_raw_g ; */

wire nceen_pipe_m, nceen_pipe_g ;

   wire [3:0] lsu_nceen_d1;
   
dff_s #(4) nceen_stg (
   .din (ifu_lsu_nceen[3:0]),
   .q   (lsu_nceen_d1[3:0]),
   .clk (clk),
   .se  (se),       .si (),          .so ()
);
                
   
assign  nceen_pipe_m = 
(thread0_m & lsu_nceen_d1[0]) | (thread1_m & lsu_nceen_d1[1]) |
(thread2_m & lsu_nceen_d1[2]) | (thread3_m & lsu_nceen_d1[3]) ;

dff_s #(1)  stgg_een (
        .din    (nceen_pipe_m),
        .q      (nceen_pipe_g),
        .clk  	(clk),
        .se     (se),       .si (),          .so ()
        );

//wire	tte_data_perror_corr_en ;
wire	tte_data_perror_unc_en ;
// separate ld from st for error reporting.
assign	tte_data_perror_unc_en = ld_inst_vld_unflushed & tte_data_perror_unc & nceen_pipe_g ;
//assign	tte_data_perror_unc_en = tte_data_perror_unc & nceen_pipe_g ;
//assign	tte_data_perror_corr_en = tte_data_perror_corr ;
//assign	tte_data_perror_corr_en = tte_data_perror_corr & ceen_pipe_g ;

wire	dtlb_perror_en_w,dtlb_perror_en_w2,dtlb_perror_en_w3 ;
assign	dtlb_perror_en_w = tte_data_perror_unc_en ;
//assign	dtlb_perror_en_w = tte_data_perror_unc_en | tte_data_perror_corr_en ;

dff_s #(1)  stgw2_perr (
        .din    (dtlb_perror_en_w),
        .q      (dtlb_perror_en_w2),
        .clk  	(clk),
        .se     (se),       .si (),          .so ()
        );

dff_s #(1)  stgw3_perr (
        .din    (dtlb_perror_en_w2),
        .q      (dtlb_perror_en_w3),
        .clk  	(clk),
        .se     (se),       .si (),          .so ()
        );

// For now, "or" ld_inst_vld_g and ldst_dbl. Ultimately, it ldst_dbl
// needs to cause ld_inst_vld_g to be asserted.
// st and ld ldst_dbl terms are redundant.
// Diagnostic Dcache access will force a hit in cache. Whatever is read
// out will be written back to irf regardless of whether hit or not. The
// expectation is that cache has been set up to hit.
// lsu_dcache_enable is redundant as factored in lsu_way_hit !!!
// squash both ld_miss and ld_hit in cause of dtlb unc data error.
   wire ldd_force_l2access_g;
   
   wire int_ldd_g, fp_ldd_g;
   assign fp_ldd_g = fp_ldst_g & ~(blk_asi_g & lsu_alt_space_g);

   //sas code need int_ldd_g
   assign int_ldd_g = ldst_dbl_g  & ~fp_ldd_g;
   assign ldd_force_l2access_g = int_ldd_g;

assign  lsu_ld_miss_wb  = 
(~(|lsu_way_hit[`L1D_WAY_ARRAY_MASK]) | ~dcache_enable_g | ~(tlb_cam_hit_g | lsu_dtlb_bypass_g) |
  ldxa_internal | ldd_force_l2access_g | atomic_g |  endian_mispred_g | // remove stb_cam_hit
  dcache_rd_parity_error | dtag_perror_g) & 
	~((dc_diagnstc_asi_g & lsu_alt_space_g)) & 
	//~(tte_data_perror_unc_en | tte_data_perror_corr_en | (dc_diagnstc_asi_g & lsu_alt_space_g)) & 
  (ld_vld & (~lsu_alt_space_g | (lsu_alt_space_g & recognized_asi_g))) |
  //(ld_inst_vld_g & (~lsu_alt_space_g | (lsu_alt_space_g & recognized_asi_g))) |
  //(ldst_dbl_g & st_inst_vld_g)  // signal ld-miss for stdbl.
  ncache_asild_rq_g ;   // asi ld requires bypass

assign  lsu_ld_hit_wb   = 
((|lsu_way_hit[`L1D_WAY_ARRAY_MASK])  & dcache_enable_g & (tlb_cam_hit_g | lsu_dtlb_bypass_g) &  //bug3702
  ~ldxa_internal & ~dcache_rd_parity_error & ~dtag_perror_g & ~endian_mispred_g &
  ~ldd_force_l2access_g & ~atomic_g &  ~ncache_asild_rq_g) &  // remove stb_cam_hit
~((dc_diagnstc_asi_g & lsu_alt_space_g)) &
//~(tte_data_perror_unc_en | tte_data_perror_corr_en | (dc_diagnstc_asi_g & lsu_alt_space_g)) &
  ld_vld & (~lsu_alt_space_g | (lsu_alt_space_g & recognized_asi_g)) ;
//ld_inst_vld_g & (~lsu_alt_space_g | (lsu_alt_space_g & recognized_asi_g)) ;
// force hit for diagnostic write. 

// correctible dtlb data parity error on cam will cause dmmu miss.
// prefetch will rely on the ld_inst_vld/st_inst_vld not being asserted
// to prevent mmu_miss from being signalled if prefetch does not translate.
// Timing Change : Remove data perror from dmmu_miss ; to be treated as disrupting trap.
//SC assign dmmu_miss_g = 
//SC   ~tlb_cam_hit_mod & ~lsu_dtlb_bypass_g & 
//SC   //~(tlb_cam_hit_mod & ~tte_data_perror_corr) & ~lsu_dtlb_bypass_g & 
//SC   ((ld_inst_vld_unflushed & lsu_inst_vld_w) | 
//SC    (st_inst_vld_unflushed & lsu_inst_vld_w)) & 
//SC     ~(ldxa_internal | stxa_internal | early_trap_vld_g) ;

//SC    wire dmmu_miss_only_g ;
   
//SC assign dmmu_miss_only_g = 
//SC  ~tlb_cam_hit_mod & ~lsu_dtlb_bypass_g & 
//SC   //~(tlb_cam_hit_mod & ~tte_data_perror_corr) & ~lsu_dtlb_bypass_g & 
//SC   ((ld_inst_vld_unflushed & lsu_inst_vld_w) | 
//SC    (st_inst_vld_unflushed & lsu_inst_vld_w)) & 
//SC     ~(ldxa_internal | stxa_internal);
    
// Atomic Handling :
// Bypass to irf will occur. However, the loads will not write to cache/tag etc.

// Exceptions, tlb miss will have to be included.  
// diagnostic dcache/dtagv will read respective arrays in pipeline. (changed!)
// They will not switch out thread with this assumption. 

//dc_diagnstc will not switch out, dtagv will switch out
 
//wire dc_diagnstc_rd_g;  
//assign  dc_diagnstc_rd_g = dc_diagnstc_asi_g & ld_inst_vld_g & lsu_alt_space_g ; 

//wire	dc0_diagnstc_rd_g,dc1_diagnstc_rd_g,dc2_diagnstc_rd_g,dc3_diagnstc_rd_g ;
//wire	dc0_diagnstc_rd_w2,dc1_diagnstc_rd_w2,dc2_diagnstc_rd_w2,dc3_diagnstc_rd_w2 ;
//assign  dc0_diagnstc_rd_g = dc_diagnstc_rd_g & thread0_g ;
//assign  dc1_diagnstc_rd_g = dc_diagnstc_rd_g & thread1_g ;
//assign  dc2_diagnstc_rd_g = dc_diagnstc_rd_g & thread2_g ;
//assign  dc3_diagnstc_rd_g = dc_diagnstc_rd_g & thread3_g ;

//dff #(4)  stgw2_dcdiag (
//        .din  ({dc3_diagnstc_rd_g,dc2_diagnstc_rd_g,dc1_diagnstc_rd_g,dc0_diagnstc_rd_g}),
//        .q    ({dc3_diagnstc_rd_w2,dc2_diagnstc_rd_w2,dc1_diagnstc_rd_w2,dc0_diagnstc_rd_w2}),
//        .clk  (clk),
//        .se     (se),       .si (),          .so ()
//        );

assign  dtagv_diagnstc_rd_g = dtagv_diagnstc_asi_g & ld_inst_vld_g & lsu_alt_space_g ; 

// Prefetch will swo thread if it does not miss in tlb.
wire pref_inst_m;
wire pref_inst_g;
dff_s  stgm_prf (
        .din    (ifu_lsu_pref_inst_e),
        .q      (pref_inst_m),
        .clk  (clk),
        .se     (se),       .si (),          .so ()
        );

dff_s  stgg_prf (
        .din    (pref_inst_m),
        .q      (pref_inst_g),
        .clk  (clk),
        .se     (se),       .si (),          .so ()
        );



//assign	lsu_ifu_data_error_w = 1'b0 ;

// is this redundant ? isn't lsu_ncache_ld_e sufficient ?
assign  atomic_ld_squash_e = 
  ~lmq_ld_rq_type_e[2] & lmq_ld_rq_type_e[1] & lmq_ld_rq_type_e[0] ;

// bypass will occur with hit in d$ or data return from L2.
// Fill for dcache diagnostic rd will happen regardless. dfill vld qualified with
// flush_pipe and inst_vld !!!

//timing fix. move logic to previous cycle M.   
//assign  lsu_exu_dfill_vld_w2  =   
//  (l2fill_vld_g & ~(unc_err_trap_g | l2fill_fpld_g))  	      | // fill
//  (~fp_ldst_g & ld_inst_vld_unflushed & lsu_inst_vld_w)       | // in pipe
//  intld_byp_data_vld ;	                                        // bypass

   wire lsu_exu_dfill_vld_m;
   wire	intld_byp_data_vld_e,intld_byp_data_vld_m ;
   wire	intld_byp_data_vld ;
   wire	ldxa_swo_annul ;

assign lsu_exu_dfill_vld_m = 
  (l2fill_vld_m & ~(unc_err_trap_m | l2fill_fpld_m))  	      | // fill
  (~fp_ldst_m & ld_inst_vld_m & 
	~(ldxa_swo_annul & lsu_alt_space_m) & flush_w_inst_vld_m) | // in pipe
  intld_byp_data_vld_m ;	                                      // bypass

dff_s #(1) dfill_vld_stgg (
   .din (lsu_exu_dfill_vld_m),
   .q   (lsu_exu_dfill_vld_w2),
   .clk    (clk),
   .se     (se),       .si (),          .so ()
);       

//------              
// Bld errors : Bug 4315
// Errors need to be accummulated across helpers. Once unc error detected 
// in any helper, then all further writes to frf are squashed.
// daccess_error trap taken at very end if *any* helper had an unc error.

wire	bld_cnt_max_m,bld_cnt_max_g ;
assign	bld_cnt_max_m = lsu_bld_cnt_m[2] & lsu_bld_cnt_m[1] & lsu_bld_cnt_m[0] ;

wire	[1:0]	cpx_ld_err_m ;
dff_s #(3) lderr_stgm (
   .din ({lsu_cpx_pkt_ld_err[1:0],bld_cnt_max_m}),
   .q   ({cpx_ld_err_m[1:0],bld_cnt_max_g}),
   .clk    (clk),
   .se     (se),       .si (),          .so ()
);       

wire [1:0] bld_err ;
wire [1:0] bld_err_din ;
wire 	   bld_rst ;
// Accummulate errors.
assign	bld_err_din[1:0] = cpx_ld_err_m[1:0] | bld_err[1:0] ;
assign	bld_rst = reset | lsu_bld_reset ;

dffre_s #(2) blderr_ff (
        .din    (bld_err_din[1:0]),
        .q      (bld_err[1:0]),
        .clk    (clk),
        .en     (lsu_bld_helper_cmplt_m), .rst (bld_rst),
        .se     (se),	.si (),	.so ()
        );

wire	bld_helper_cmplt_g ;
dff_s  bldh_stgg (
   .din (lsu_bld_helper_cmplt_m),
   .q   (bld_helper_cmplt_g),
   .clk    (clk),
   .se     (se),       .si (),          .so ()
);

wire	bld_unc_err_pend_g, bld_unc_err_pend_w2 ;
assign	bld_unc_err_pend_g = bld_err[1] & bld_helper_cmplt_g ;
wire	bld_corr_err_pend_g, bld_corr_err_pend_w2 ;
// pended unc error gets priority.
assign	bld_corr_err_pend_g = bld_err[0] & ~bld_err[1] & bld_helper_cmplt_g ;

wire	bld_squash_err_g,bld_squash_err_w2 ;
// bld cnt should be vld till g
assign	bld_squash_err_g = bld_helper_cmplt_g & ~bld_cnt_max_g ;

dff_s #(3)  bldsq_stgw2 (
   .din ({bld_squash_err_g,bld_unc_err_pend_g,bld_corr_err_pend_g}),
   .q   ({bld_squash_err_w2,bld_unc_err_pend_w2,bld_corr_err_pend_w2}),
   .clk    (clk),
   .se     (se),       .si (),          .so ()
);

//------              
   
wire	stb_cam_hit_w2 ;
wire	fld_vld_sync_no_camhit,fld_vld_sync_no_camhit_w2 ;
wire	fld_vld_async,fld_vld_async_w2 ;
dff_s  #(3) stbchit_stg (
        .din    ({stb_cam_hit,fld_vld_sync_no_camhit,fld_vld_async}),
        .q      ({stb_cam_hit_w2,fld_vld_sync_no_camhit_w2,fld_vld_async_w2}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  fld_vld_sync_no_camhit =  
	(lsu_ld_hit_wb & ~tte_data_perror_unc_en & fp_ldst_g &
	~dctl_flush_pipe_w) ; // l1hit 

assign	fld_vld_async =
        (l2fill_vld_g & l2fill_fpld_g & ~(unc_err_trap_g | bld_unc_err_pend_g))  | 
						// fill from l2, // bug 3705, 4315(err_trap)
        fpld_byp_data_vld ;     // bypass data

assign	lsu_ffu_ld_vld = 
	(fld_vld_sync_no_camhit_w2 & ~stb_cam_hit_w2) |
	fld_vld_async_w2 ;


/*dff  #(1) fldvld_stgw2 (
        .din    (ffu_ld_vld),
        .q      (lsu_ffu_ld_vld),
        .clk    (clk),
        .se     (1'b0),       .si (),          .so ()
        ); */

dff_s  #(2) dtid_stgm (
        .din    (lsu_dfill_tid_e[1:0]),
        .q      (dfq_tid_m[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dff_s  #(2) dtid_stgg (
        .din    (dfq_tid_m[1:0]),
        .q      (dfq_tid_g[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

// Timing Change -  shifting dfill-data sel gen. to m-stage
//assign  ldbyp_tid[0] = ld_thrd_byp_sel_g[1] | ld_thrd_byp_sel_g[3] ;
//assign  ldbyp_tid[1] = ld_thrd_byp_sel_g[2] | ld_thrd_byp_sel_g[3] ;
wire 	[3:0]	ld_thrd_byp_sel_m ;
assign  ldbyp_tid_m[0] = ld_thrd_byp_sel_m[1] | ld_thrd_byp_sel_m[3] ;
assign  ldbyp_tid_m[1] = ld_thrd_byp_sel_m[2] | ld_thrd_byp_sel_m[3] ;


/*assign  lsu_exu_thr_g[1:0] = ld_inst_vld_unflushed ? thrid_g[1:0] :
          l2fill_vld_g ? dfq_tid_g[1:0] : ldbyp_tid[1:0] ; */
assign  lsu_exu_thr_m[1:0] = ld_inst_vld_m ? thrid_m[1:0] :
          l2fill_vld_m ? dfq_tid_m[1:0] : ldbyp_tid_m[1:0] ; 

// What is the policy for load-double/atomics to update cache ?
// cas will not update cache. similary neither will ldstub nor cas.
// BIST will effect dcache only, not tags and vld bits.
// Removed dcache_enable from dc_diagnstc_wr_en !!!
wire	l2fill_vld_e ;
wire	dcache_alt_src_wr_e ;
assign	l2fill_vld_e = lsu_l2fill_vld & ~lsu_cpx_pkt_prefetch2 ;
assign  lsu_dcache_wr_vld_e = 
  (l2fill_vld_e & ~ignore_fill & ~atomic_ld_squash_e & ~ld_sec_active & ~lsu_ncache_ld_e) |
  lsu_st_wr_dcache  | // st writes from stb
  dcache_alt_src_wr_e ;

assign  dcache_alt_src_wr_e =
  (lsu_diagnstc_wr_src_sel_e & dc_diagnstc_wr_en)
  | lsu_bist_wvld_e     // bist engine writes to cache
  | dcache_iob_wr_e ;  // iobridge request write to dcache

//d$ valid bit 
   wire dv_diagnstic_wr;  
assign  dv_diagnstic_wr = (lsu_diagnstc_wr_src_sel_e & dtagv_diagnstc_wr_en & lsu_diagnstc_wr_data_b0) ;

   wire dva_din_e;
   wire ld_fill_e;
   
   assign ld_fill_e= (l2fill_vld_e & ~atomic_ld_squash_e & ~ld_sec_active & ~lsu_ncache_ld_e) ;   //ld-fill
   //######################################
   //snp      => dva_din = 0
   //ld fill  => dva_din = 1
   //diag wrt => dva_din = wrt_value
   //######################################
   assign dva_din_e =  ld_fill_e  | //ld-fill
                       dv_diagnstic_wr; // diagnostic write valid bit

   
// iob rd dominates
   wire lsu_dc_alt_rd_vld_e;
   
assign	lsu_dc_alt_rd_vld_e = dcache_iob_rd_e | lsu_bist_rvld_e ;

   //?? default when no ld in pipe
   assign dcache_alt_mx_sel_e = 
		//lsu_dcache_wr_vld_e | : Timing
		dcache_alt_src_wr_e | // rm st updates/fill - ~ld_inst_vld_e.
		lsu_dcache_wr_vld_e | 
		lsu_dc_alt_rd_vld_e  | ~ld_inst_vld_e;
  
   assign dcache_alt_mx_sel_e_bf = dcache_alt_mx_sel_e;

   wire   dcache_rvld_e_tmp, dcache_rvld_e_minbf;   
   assign dcache_rvld_e_tmp =  ld_inst_vld_e | lsu_dc_alt_rd_vld_e ;
   bw_u1_minbuf_5x  UZfix_dcache_rvld_e_minbf (.a(dcache_rvld_e_tmp), .z(dcache_rvld_e_minbf));
   assign dcache_rvld_e = dcache_rvld_e_minbf;
   
   wire   lsu_dtag_wr_vld_e_tmp;
   
assign  lsu_dtag_wr_vld_e_tmp = 
  ld_fill_e  & ~ignore_fill | //ld fill   //bug3601, 3676
  (lsu_diagnstc_wr_src_sel_e & dtagv_diagnstc_wr_en) ; // dtag/vld diagnostic wr

bw_u1_buf_30x UZsize_lsu_dtag_wrreq_x     ( .a(lsu_dtag_wr_vld_e_tmp), .z(lsu_dtag_wrreq_x_e)     );
bw_u1_buf_30x UZsize_lsu_dtag_index_sel_x ( .a(lsu_dtag_wr_vld_e_tmp), .z(lsu_dtag_index_sel_x_e) );
   
assign  lsu_dtagv_wr_vld_e = 
  lsu_dtag_wr_vld_e_tmp | 	// fill
  dva_svld_e        |   // snp
  lsu_bist_wvld_e ;     // bist clears dva by default

// mem cell change for dva
   wire [`L1D_VAL_ARRAY_HI:0] dva_fill_bit_wr_en_e;

   // assign      dva_fill_bit_wr_en_e[15] = dcache_fill_addr_e[5] & dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[3];
   // assign      dva_fill_bit_wr_en_e[14] = dcache_fill_addr_e[5] & dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[2];
   // assign      dva_fill_bit_wr_en_e[13] = dcache_fill_addr_e[5] & dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[1];
   // assign      dva_fill_bit_wr_en_e[12] = dcache_fill_addr_e[5] & dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[0];
   // assign dva_fill_bit_wr_en_e[15:12] = (dcache_fill_addr_e[5:4] == 2'b11) ? lsu_dcache_fill_way_e[3:0] : 4'b0;

   // assign      dva_fill_bit_wr_en_e[11] = dcache_fill_addr_e[5] & ~dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[3];
   // assign      dva_fill_bit_wr_en_e[10] = dcache_fill_addr_e[5] & ~dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[2];
   // assign      dva_fill_bit_wr_en_e[09] = dcache_fill_addr_e[5] & ~dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[1];
   // assign      dva_fill_bit_wr_en_e[08] = dcache_fill_addr_e[5] & ~dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[0];
   // assign dva_fill_bit_wr_en_e[11:08] = (dcache_fill_addr_e[5:4] == 2'b10) ? lsu_dcache_fill_way_e[3:0] : 4'b0;
  
   // assign      dva_fill_bit_wr_en_e[07] = ~dcache_fill_addr_e[5] & dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[3];
   // assign      dva_fill_bit_wr_en_e[06] = ~dcache_fill_addr_e[5] & dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[2];
   // assign      dva_fill_bit_wr_en_e[05] = ~dcache_fill_addr_e[5] & dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[1];
   // assign      dva_fill_bit_wr_en_e[04] = ~dcache_fill_addr_e[5] & dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[0];
   // assign dva_fill_bit_wr_en_e[07:04] = (dcache_fill_addr_e[5:4] == 2'b01) ? lsu_dcache_fill_way_e[3:0] : 4'b0;

   // assign      dva_fill_bit_wr_en_e[03] = ~dcache_fill_addr_e[5] & ~dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[3];
   // assign      dva_fill_bit_wr_en_e[02] = ~dcache_fill_addr_e[5] & ~dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[2];
   // assign      dva_fill_bit_wr_en_e[01] = ~dcache_fill_addr_e[5] & ~dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[1];
   // assign      dva_fill_bit_wr_en_e[00] = ~dcache_fill_addr_e[5] & ~dcache_fill_addr_e[4] & lsu_dcache_fill_way_e[0];
   // assign dva_fill_bit_wr_en_e[03:00] = (dcache_fill_addr_e[5:4] == 2'b00) ? lsu_dcache_fill_way_e[3:0] : 4'b0;
   assign dva_fill_bit_wr_en_e[`L1D_WAY_COUNT*1-1 -: `L1D_WAY_COUNT] = (dcache_fill_addr_e[5:4] == 2'b00) ? lsu_dcache_fill_way_e[`L1D_WAY_COUNT-1:0] : {`L1D_WAY_COUNT{1'b0}};
   assign dva_fill_bit_wr_en_e[`L1D_WAY_COUNT*2-1 -: `L1D_WAY_COUNT] = (dcache_fill_addr_e[5:4] == 2'b01) ? lsu_dcache_fill_way_e[`L1D_WAY_COUNT-1:0] : {`L1D_WAY_COUNT{1'b0}};
   assign dva_fill_bit_wr_en_e[`L1D_WAY_COUNT*3-1 -: `L1D_WAY_COUNT] = (dcache_fill_addr_e[5:4] == 2'b10) ? lsu_dcache_fill_way_e[`L1D_WAY_COUNT-1:0] : {`L1D_WAY_COUNT{1'b0}};
   assign dva_fill_bit_wr_en_e[`L1D_WAY_COUNT*4-1 -: `L1D_WAY_COUNT] = (dcache_fill_addr_e[5:4] == 2'b11) ? lsu_dcache_fill_way_e[`L1D_WAY_COUNT-1:0] : {`L1D_WAY_COUNT{1'b0}};



   wire [`L1D_VAL_ARRAY_HI:0] dva_bit_wr_en_e;
   assign      dva_bit_wr_en_e[`L1D_VAL_ARRAY_HI:0] = dva_svld_e ? dva_snp_bit_wr_en_e[`L1D_VAL_ARRAY_HI:0] : dva_fill_bit_wr_en_e;

   // wire [`L1D_ADDRESS_HI-6:0]  dva_snp_addr_e_bf;
   // bw_u1_buf_5x UZsize_dva_snp_addr_e_bf_b4 (.a(dva_snp_addr_e[4]), .z(dva_snp_addr_e_bf[4]));
   // bw_u1_buf_5x UZsize_dva_snp_addr_e_bf_b3 (.a(dva_snp_addr_e[3]), .z(dva_snp_addr_e_bf[3]));
   // bw_u1_buf_5x UZsize_dva_snp_addr_e_bf_b2 (.a(dva_snp_addr_e[2]), .z(dva_snp_addr_e_bf[2]));
   // bw_u1_buf_5x UZsize_dva_snp_addr_e_bf_b1 (.a(dva_snp_addr_e[1]), .z(dva_snp_addr_e_bf[1]));
   // bw_u1_buf_5x UZsize_dva_snp_addr_e_bf_b0 (.a(dva_snp_addr_e[0]), .z(dva_snp_addr_e_bf[0]));

   assign      dva_wr_adr_e[`L1D_ADDRESS_HI:6] = dva_svld_e ? dva_snp_addr_e[`L1D_ADDRESS_HI-6:0] : dcache_fill_addr_e[`L1D_ADDRESS_HI:6];

// should ldxa_data_vld be included ?

assign  dfill_thread0 = ~lsu_dfill_tid_e[1] & ~lsu_dfill_tid_e[0] ;
assign  dfill_thread1 = ~lsu_dfill_tid_e[1] &  lsu_dfill_tid_e[0] ;
assign  dfill_thread2 =  lsu_dfill_tid_e[1] & ~lsu_dfill_tid_e[0] ;
assign  dfill_thread3 =  lsu_dfill_tid_e[1] &  lsu_dfill_tid_e[0] ;

assign  l2fill_fpld_e = lsu_l2fill_fpld_e ;

//=========================================================================================
//  LD/ST COMPLETE SIGNAL
//=========================================================================================

// Prefetch

wire	pref_tlbmiss_g ;
assign	pref_tlbmiss_g = 
pref_inst_g & 
(~tlb_cam_hit_g | (tlb_cam_hit_g & tlb_pgnum[39])) // nop on tlbmiss or io access
& lsu_inst_vld_w & ~dctl_flush_pipe_w ; // Bug 4318 bug6406/eco6619
   
//assign	pref_tlbmiss_g = pref_inst_g & lsu_inst_vld_w & ~tlb_cam_hit_g ;
wire	[3:0] pref_tlbmiss_cmplt,pref_tlbmiss_cmplt_d1,pref_tlbmiss_cmplt_d2 ;
assign	pref_tlbmiss_cmplt[0] = pref_tlbmiss_g & thread0_g ;
assign	pref_tlbmiss_cmplt[1] = pref_tlbmiss_g & thread1_g ;
assign	pref_tlbmiss_cmplt[2] = pref_tlbmiss_g & thread2_g ;
assign	pref_tlbmiss_cmplt[3] = pref_tlbmiss_g & thread3_g ;

dff_s  #(4) pfcmpl_stgd1 (
        .din    (pref_tlbmiss_cmplt[3:0]),
        .q      (pref_tlbmiss_cmplt_d1[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dff_s  #(4) pfcmpl_stgd2 (
        .din    (pref_tlbmiss_cmplt_d1[3:0]),
        .q      (pref_tlbmiss_cmplt_d2[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

// *** add diagnstc rd and prefetch(tlb-miss) signals. ***
// *** add ifu asi ack.

// This equation is critical and needs to be optimized.
wire [3:0] 	lsu_pcx_pref_issue;
wire	diag_wr_cmplt0,diag_wr_cmplt1,diag_wr_cmplt2,diag_wr_cmplt3;
wire	ldst_cmplt_late_0, ldst_cmplt_late_1 ;
wire	ldst_cmplt_late_2, ldst_cmplt_late_3 ;
wire	ldst_cmplt_late_0_d1, ldst_cmplt_late_1_d1 ;
wire	ldst_cmplt_late_2_d1, ldst_cmplt_late_3_d1 ;

   assign ignore_fill = lmq_ldd_vld & ~ldd_in_dfq_out;
   
assign  lsu_ifu_ldst_cmplt[0] = 
    // * can be early or
    ((stxa_internal_d2 & thread0_w3) | stxa_stall_wr_cmplt0_d1) | 
    // * late signal and critical.
    // Can this be snapped earlier ?
    //(((l2fill_vld_e & ~atomic_ld_squash_e & ~ignore_fill)) //Bug 3624
    (((l2fill_vld_e & ~ignore_fill))  // 1st fill for ldd.
      & ~l2fill_fpld_e & ~lsu_cpx_pkt_atm_st_cmplt & 
	~(lsu_cpx_pkt_ld_err[1] & lsu_nceen_d1[0]) & dfill_thread0)  |
    intld_byp_cmplt[0] |
    // * early-or signals
    ldst_cmplt_late_0_d1 ;

wire	atm_st_cmplt0 ;
assign	atm_st_cmplt0 = lsu_atm_st_cmplt_e & dfill_thread0 ;
assign	ldst_cmplt_late_0 = 
    (atm_st_cmplt0 & ~pend_atm_ld_ue[0]) |  // Bug 3624,4048
    bsync0_reset    |
    lsu_intrpt_cmplt[0]   |
    diag_wr_cmplt0 |
//    dc0_diagnstc_rd_w2 |
    ldxa_illgl_va_cmplt_d1[0] |
    pref_tlbmiss_cmplt_d2[0] |
    lsu_pcx_pref_issue[0];


assign  lsu_ifu_ldst_cmplt[1] = 
    ((stxa_internal_d2 & thread1_w3) | stxa_stall_wr_cmplt1_d1) | 
    (((l2fill_vld_e & ~ignore_fill)) // // 1st fill for ldd
      & ~l2fill_fpld_e & ~lsu_cpx_pkt_atm_st_cmplt & 
	~(lsu_cpx_pkt_ld_err[1] & lsu_nceen_d1[1]) & dfill_thread1)  |
    intld_byp_cmplt[1] |
    ldst_cmplt_late_1_d1 ;

wire	atm_st_cmplt1 ;
assign	atm_st_cmplt1 = lsu_atm_st_cmplt_e & dfill_thread1 ;
assign	ldst_cmplt_late_1 = 
    (atm_st_cmplt1 & ~pend_atm_ld_ue[1]) |  // Bug 3624,4048
    bsync1_reset    |
    lsu_intrpt_cmplt[1]   |
    diag_wr_cmplt1 |
//    dc1_diagnstc_rd_w2 |
    ldxa_illgl_va_cmplt_d1[1] |
    pref_tlbmiss_cmplt_d2[1] |
    lsu_pcx_pref_issue[1];

assign  lsu_ifu_ldst_cmplt[2] = 
    ((stxa_internal_d2 & thread2_w3) | stxa_stall_wr_cmplt2_d1) | 
    (((l2fill_vld_e & ~ignore_fill)) // 1st fill for ldd.
      & ~l2fill_fpld_e & ~lsu_cpx_pkt_atm_st_cmplt & 
	~(lsu_cpx_pkt_ld_err[1] & lsu_nceen_d1[2]) & dfill_thread2)  |
    intld_byp_cmplt[2] |
    ldst_cmplt_late_2_d1 ;

wire	atm_st_cmplt2 ;
assign	atm_st_cmplt2 = lsu_atm_st_cmplt_e & dfill_thread2 ;
assign	ldst_cmplt_late_2 = 
    (atm_st_cmplt2 & ~pend_atm_ld_ue[2]) |  // Bug 3624,4048
    bsync2_reset    |
    lsu_intrpt_cmplt[2]   |
    diag_wr_cmplt2 |
//    dc2_diagnstc_rd_w2 |
    ldxa_illgl_va_cmplt_d1[2] |
    pref_tlbmiss_cmplt_d2[2] |
    lsu_pcx_pref_issue[2];

assign  lsu_ifu_ldst_cmplt[3] = 
    ((stxa_internal_d2 & thread3_w3) | stxa_stall_wr_cmplt3_d1) | 
    //(((l2fill_vld_e & atomic_st_cmplt) | 
    (((l2fill_vld_e & ~ignore_fill)) // 1st fill for ldd.
      & ~l2fill_fpld_e & ~lsu_cpx_pkt_atm_st_cmplt & 
	~(lsu_cpx_pkt_ld_err[1] & lsu_nceen_d1[3]) & dfill_thread3)  |
    intld_byp_cmplt[3] |
    ldst_cmplt_late_3_d1 ;

wire	atm_st_cmplt3 ;
assign	atm_st_cmplt3 = lsu_atm_st_cmplt_e & dfill_thread3 ;
assign	ldst_cmplt_late_3 = 
    (atm_st_cmplt3 & ~pend_atm_ld_ue[3]) |  // Bug 3624,4048
    bsync3_reset    |
    lsu_intrpt_cmplt[3]   |
    diag_wr_cmplt3 |
//    dc3_diagnstc_rd_w2 |
    ldxa_illgl_va_cmplt_d1[3] |
    pref_tlbmiss_cmplt_d2[3] |
    lsu_pcx_pref_issue[3];

dff_s #(4) ldstcmplt_d1 (
        .din    ({ldst_cmplt_late_3,ldst_cmplt_late_2,ldst_cmplt_late_1,ldst_cmplt_late_0}),
        .q      ({ldst_cmplt_late_3_d1,ldst_cmplt_late_2_d1,
		ldst_cmplt_late_1_d1,ldst_cmplt_late_0_d1}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

//=========================================================================================
//  LD/ST MISS SIGNAL - IFU
//=========================================================================================

// Switchout of internal asi ld
// Do not switchout for tag-target,
assign  ldxa_swo_annul = 
	(lsu_dctl_asi_state_m[7:4] == 4'h3)   | 	// ldxa to 0x3X does not swo
	(((lsu_dctl_asi_state_m[7:0] == 8'h58) &   	// tag-target,tag-access,sfsr,sfar
		~((lsu_ldst_va_b7_b0_m[7:0] == 8'h38) | (lsu_ldst_va_b7_b0_m[7:0] == 8'h80))) | // wtcpt/pid
	 (lsu_dctl_asi_state_m[7:0] == 8'h50)) |
	mmu_rd_only_asi_m ;

wire	ldxa_internal_swo_m,ldxa_internal_swo_g ;
assign	ldxa_internal_swo_m = lda_internal_m & ~ldxa_swo_annul ;

// This represents *all* ld asi.
wire	asi_internal_ld_m,asi_internal_ld_g ;
assign	asi_internal_ld_m =
	asi_internal_m & ld_inst_vld_m & lsu_alt_space_m ;

dff_s #(2) ldaswo_stgg (
        .din    ({ldxa_internal_swo_m,asi_internal_ld_m}),
        .q      ({ldxa_internal_swo_g,asi_internal_ld_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
		   
wire	common_ldst_miss_w ;
assign	common_ldst_miss_w =
(~(cache_hit & (tlb_cam_hit_g | lsu_dtlb_bypass_g)) |	// include miss in tlb;bypass
   ~dcache_enable_g 	| 	// 
    //endian_mispred_g    |	// endian mispredict
    ldd_force_l2access_g 		| 	// ifu to incorporate directly
    ncache_asild_rq_g   ) &	// bypass asi
 	~asi_internal_ld_g ;

assign	lsu_ifu_ldst_miss_w =
  (common_ldst_miss_w  |         // common between ifu and exu.
    // MMU_ASI : ifu must switch out early only for stores.
    ldxa_internal_swo_g)
//  ldxa_internal	|	// ifu incorporates directly
//  atomic_g 		| 	// ifu incorporates directly
//  ld_stb_hit_g 	| 	// late 
//    stb_cam_hit)		// ** rm once ifu uses late signal. ** 
//  dcache_rd_parity_error | 	// late
//  dtag_perror_g) & 	|	// late
    & (lsu_inst_vld_w & ld_inst_vld_unflushed) ;	// flush uptil m accounted for.
//  & ld_inst_vld_g ;		// assume flush=1 clears ldst_miss=1
//  ~tte_data_perror_unc & 	// in flush 
//  (ld_inst_vld_g & (~lsu_alt_space_g | (lsu_alt_space_g & recognized_asi_g))) |
//  ncache_asild_rq_g ;   // asi ld requires bypass


   //timing fix
   wire lsu_ifu_dc_parity_error_w;
   assign lsu_ifu_dc_parity_error_w = 
	( 
	lsu_dcache_data_perror_g | // bug 4267
	lsu_dcache_tag_perror_g  |  
  endian_mispred_g         |	// endian mispredict ; mv'ed from ldst_miss
	tte_data_perror_unc_en) ;
   
/*
   wire   lsu_ld_inst_vld_flush_w, lsu_ld_inst_vld_flush_w2;
   assign lsu_ld_inst_vld_flush_w = lsu_inst_vld_w & ld_inst_vld_unflushed & ~dctl_flush_pipe_w ;

   
dff_s #(1) lsu_ld_inst_vld_flush_stgw2 (
        .din    (lsu_ld_inst_vld_flush_w),
        .q      (lsu_ld_inst_vld_flush_w2),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
*/
   
   wire   lsu_ifu_dc_parity_error_w2_q;
  
dff_s #(1) lsu_ifu_dc_parity_error_stgw2 (
        .din    (lsu_ifu_dc_parity_error_w),
        .q      (lsu_ifu_dc_parity_error_w2_q),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

   assign lsu_ifu_dc_parity_error_w2 = (lsu_ifu_dc_parity_error_w2_q | stb_cam_hit_w2) & ld_inst_vld_w2;
   
//=========================================================================================
//  LD/ST MISS SIGNAL - EXU
//=========================================================================================

// for a diagnstc access to the cache, the if it misses in the cache, then 
// ldst_miss is asserted, preventing a write into the cache, but code is
// allowed to continue executing.
wire	exu_ldst_miss_g_no_stb_cam_hit ;
assign  exu_ldst_miss_g_no_stb_cam_hit =  
  (common_ldst_miss_w 	  |
   ldxa_internal_swo_g	  |
   endian_mispred_g    	  |	
   atomic_g 		  |
   lsu_dcache_data_perror_g 	|
   lsu_dcache_tag_perror_g 	|  
   tte_data_perror_unc_en    	|
   pref_inst_g) & ld_inst_vld_unflushed & lsu_inst_vld_w ; // flush qual done in exu


   wire ld_inst_vld_no_flush_w, ld_inst_vld_no_flush_w2;
   assign ld_inst_vld_no_flush_w = ld_inst_vld_unflushed & lsu_inst_vld_w;
   
dff_s #(1) ld_inst_vld_no_flush_stgw2 (
        .din    (ld_inst_vld_no_flush_w),
        .q      (ld_inst_vld_no_flush_w2),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
   
   wire lsu_exu_ldst_miss_w2_tmp;
 
dff_s #(1) exuldstmiss_stgw2 (
        .din    (exu_ldst_miss_g_no_stb_cam_hit),
        .q      (lsu_exu_ldst_miss_w2_tmp),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

   assign lsu_exu_ldst_miss_w2 =  (lsu_exu_ldst_miss_w2_tmp | stb_cam_hit_w2) & ld_inst_vld_no_flush_w2;
   
                                   
wire	lsu_ldst_miss_w2;
assign	lsu_ldst_miss_w2 = lsu_exu_ldst_miss_w2 ;

//=========================================================================================
//  RMO Store control data
//=========================================================================================

assign	lsu_st_rmo_m = (st_inst_vld_m & (binit_quad_asi_m | blk_asi_m) & lsu_alt_space_m) | blkst_m ;
assign	lsu_bst_in_pipe_m = (st_inst_vld_m &  blk_asi_m & lsu_alt_space_m) ;

//=========================================================================================
//  ASI BUS 
//=========================================================================================

// *** This logic is now used by all long-latency asi operations on chip. ***

// Start with SDATA Reg for Streaming
wire	strm_asi, strm_asi_m ;
assign	strm_asi_m = (lsu_dctl_asi_state_m[7:0]==8'h40) ;

dff_s  strm_stgg (
        .din    (strm_asi_m),
        .q      (strm_asi),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  stxa_stall_asi_g = 
  strm_asi & ((ldst_va_g[7:0] == 8'h80)) ;  	// ma ctl
  /*strm_asi & (	(ldst_va_g[7:0] == 8'h18) |  	// streaming stxa to sdata
  		(ldst_va_g[7:0] == 8'h00) |  	// stream ctl
  		(ldst_va_g[7:0] == 8'h08) ) ;  	// ma ctl */

wire    dtlb_wr_cmplt0, dtlb_wr_cmplt1;
wire    dtlb_wr_cmplt2, dtlb_wr_cmplt3;
assign  dtlb_wr_cmplt0 = demap_thread0 & lsu_dtlb_wr_vld_e ;
assign  dtlb_wr_cmplt1 = demap_thread1 & lsu_dtlb_wr_vld_e ;
assign  dtlb_wr_cmplt2 = demap_thread2 & lsu_dtlb_wr_vld_e ;
assign  dtlb_wr_cmplt3 = demap_thread3 & lsu_dtlb_wr_vld_e ;

dff_s  dtlbw_stgd1 (
        .din    (lsu_dtlb_wr_vld_e),
        .q      (dtlb_wr_init_d1),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dff_s  dtlbw_stgd2 (
        .din    (dtlb_wr_init_d1),
        .q      (dtlb_wr_init_d2),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dff_s  dtlbw_stgd3 (
        .din    (dtlb_wr_init_d2),
        .q      (dtlb_wr_init_d3),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

wire    dtlb_wr_init_d4 ;
dff_s  dtlbw_stgd4 (
        .din    (dtlb_wr_init_d3),
        .q      (dtlb_wr_init_d4),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );



wire	tlb_access_sel_thrd3_d1,tlb_access_sel_thrd2_d1;
wire	tlb_access_sel_thrd1_d1,tlb_access_sel_thrd0_d1 ;
wire	ifu_asi_store_cmplt_en, ifu_asi_store_cmplt_en_d1 ;
assign  stxa_stall_wr_cmplt0 =  (spu_lsu_stxa_ack & spu_stxa_thread0) |
        (tlu_stxa_thread0_w2 & tlu_lsu_stxa_ack & ~dtlb_wr_init_d4) |
	(ifu_asi_store_cmplt_en_d1 & tlb_access_sel_thrd0_d1) |
	dtlb_wr_cmplt0 ;
assign  stxa_stall_wr_cmplt1 =  (spu_lsu_stxa_ack & spu_stxa_thread1) |
        (tlu_stxa_thread1_w2 & tlu_lsu_stxa_ack & ~dtlb_wr_init_d4) |
	(ifu_asi_store_cmplt_en_d1 & tlb_access_sel_thrd1_d1) |
	dtlb_wr_cmplt1 ;
assign  stxa_stall_wr_cmplt2 =  (spu_lsu_stxa_ack & spu_stxa_thread2) |
        (tlu_stxa_thread2_w2 & tlu_lsu_stxa_ack & ~dtlb_wr_init_d4) |
	(ifu_asi_store_cmplt_en_d1 & tlb_access_sel_thrd2_d1) |
	dtlb_wr_cmplt2 ;
assign  stxa_stall_wr_cmplt3 =  (spu_lsu_stxa_ack & spu_stxa_thread3) |
        (tlu_stxa_thread3_w2 & tlu_lsu_stxa_ack & ~dtlb_wr_init_d4) |
	(ifu_asi_store_cmplt_en_d1 & tlb_access_sel_thrd3_d1) |
	dtlb_wr_cmplt3 ;

dff_s  #(4) stxastall_stgd1 (
        .din    ({stxa_stall_wr_cmplt3,stxa_stall_wr_cmplt2,
		stxa_stall_wr_cmplt1,stxa_stall_wr_cmplt0}),
        .q    	({stxa_stall_wr_cmplt3_d1,stxa_stall_wr_cmplt2_d1,
		stxa_stall_wr_cmplt1_d1,stxa_stall_wr_cmplt0_d1}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );


// enable speculates on inst not being flushed
// Only dside diagnostic writes will be logged for long-latency action. dside diagnostic
// reads are aligned to pipe.
wire wr_dc_diag_asi_e, wr_dtagv_diag_asi_e ;

assign	wr_dc_diag_asi_e = dc_diagnstc_asi_e & st_inst_vld_e ;
assign	wr_dtagv_diag_asi_e =  dtagv_diagnstc_asi_e & st_inst_vld_e ;

assign  tlb_access_en0_e = 
  (tlb_lng_ltncy_asi_e | wr_dc_diag_asi_e | wr_dtagv_diag_asi_e | ifu_nontlb_asi_e)  
    & thread0_e & alt_space_e ;
assign  tlb_access_en1_e = 
  (tlb_lng_ltncy_asi_e | wr_dc_diag_asi_e | wr_dtagv_diag_asi_e | ifu_nontlb_asi_e)  
    & thread1_e & alt_space_e ;
assign  tlb_access_en2_e = 
  (tlb_lng_ltncy_asi_e | wr_dc_diag_asi_e | wr_dtagv_diag_asi_e | ifu_nontlb_asi_e)  
    & thread2_e & alt_space_e ;
assign  tlb_access_en3_e = 
  (tlb_lng_ltncy_asi_e | wr_dc_diag_asi_e | wr_dtagv_diag_asi_e | ifu_nontlb_asi_e)  
    & thread3_e & alt_space_e ;

dff_s  #(4) tlbac_stgm (
        .din    ({tlb_access_en0_e,tlb_access_en1_e,tlb_access_en2_e,tlb_access_en3_e}),
        .q      ({tlb_access_en0_tmp,tlb_access_en1_tmp,tlb_access_en2_tmp,tlb_access_en3_tmp}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

wire	ldst_vld_m = ld_inst_vld_m | st_inst_vld_m ;
assign	tlb_access_en0_m = tlb_access_en0_tmp & ldst_vld_m ;
assign	tlb_access_en1_m = tlb_access_en1_tmp & ldst_vld_m ;
assign	tlb_access_en2_m = tlb_access_en2_tmp & ldst_vld_m ;
assign	tlb_access_en3_m = tlb_access_en3_tmp & ldst_vld_m ;

dff_s  #(4) tlbac_stgw (
        .din    ({tlb_access_en0_m,tlb_access_en1_m,tlb_access_en2_m,tlb_access_en3_m}),
        .q      ({tlb_access_en0_unflushed,tlb_access_en1_unflushed,tlb_access_en2_unflushed,tlb_access_en3_unflushed}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

// Flush ld/st with as=42 belonging to lsu. bistctl and ldiag

assign  tlb_access_en0_g = tlb_access_en0_unflushed & lsu_inst_vld_w & ~(dctl_early_flush_w | ifu_asi42_flush_g) ;
//assign  tlb_access_en0_g = tlb_access_en0_unflushed & lsu_inst_vld_w & ~(dctl_flush_pipe_w | ifu_asi42_flush_g) ;
assign  tlb_access_en1_g = tlb_access_en1_unflushed & lsu_inst_vld_w & ~(dctl_early_flush_w | ifu_asi42_flush_g) ;
assign  tlb_access_en2_g = tlb_access_en2_unflushed & lsu_inst_vld_w & ~(dctl_early_flush_w | ifu_asi42_flush_g) ;
assign  tlb_access_en3_g = tlb_access_en3_unflushed & lsu_inst_vld_w & ~(dctl_early_flush_w | ifu_asi42_flush_g) ;

assign	diag_wr_cmplt0 = lsu_diagnstc_wr_src_sel_e & tlb_access_sel_thrd0_d1 ;
assign	diag_wr_cmplt1 = lsu_diagnstc_wr_src_sel_e & tlb_access_sel_thrd1_d1 ;
assign	diag_wr_cmplt2 = lsu_diagnstc_wr_src_sel_e & tlb_access_sel_thrd2_d1 ;
assign	diag_wr_cmplt3 = lsu_diagnstc_wr_src_sel_e & tlb_access_sel_thrd3_d1 ;

wire	ifu_tlb_rd_cmplt0,ifu_tlb_rd_cmplt1,ifu_tlb_rd_cmplt2,ifu_tlb_rd_cmplt3 ;
wire	st_sqsh_m, ifu_asi_ack_d1 ;
assign	ifu_tlb_rd_cmplt0 =  (ifu_ldxa_thread0_w2 & ifu_lsu_ldxa_data_vld_w2 & ~ifu_nontlb0_asi) ;
assign	ifu_tlb_rd_cmplt1 =  (ifu_ldxa_thread1_w2 & ifu_lsu_ldxa_data_vld_w2 & ~ifu_nontlb1_asi) ;
assign	ifu_tlb_rd_cmplt2 =  (ifu_ldxa_thread2_w2 & ifu_lsu_ldxa_data_vld_w2 & ~ifu_nontlb2_asi) ;
assign	ifu_tlb_rd_cmplt3 =  (ifu_ldxa_thread3_w2 & ifu_lsu_ldxa_data_vld_w2 & ~ifu_nontlb3_asi) ;
  
// stxa ack will share tid with ldxa
// This should be qualified with inst_vld_w also !!!
// ldxa_data_vld needs to be removed once full interface in !!!
assign  tlb_access_rst0 =  reset | 
  (tlu_ldxa_thread0_w2 & tlu_lsu_ldxa_async_data_vld) | 
  (tlu_stxa_thread0_w2 & tlu_lsu_stxa_ack) | 
  (ifu_tlb_rd_cmplt0) | 
  (ifu_stxa_thread0_w2 & ifu_lsu_asi_ack) |
  diag_wr_cmplt0 ;
assign  tlb_access_rst1 =  reset | 
  (tlu_ldxa_thread1_w2 & tlu_lsu_ldxa_async_data_vld) |
  (tlu_stxa_thread1_w2 & tlu_lsu_stxa_ack) |
  (ifu_tlb_rd_cmplt1) | 
  (ifu_stxa_thread1_w2 & ifu_lsu_asi_ack) |
  diag_wr_cmplt1 ;
assign  tlb_access_rst2 =  reset | 
  (tlu_ldxa_thread2_w2 & tlu_lsu_ldxa_async_data_vld) |
  (tlu_stxa_thread2_w2 & tlu_lsu_stxa_ack) |
  (ifu_tlb_rd_cmplt2) | 
  (ifu_stxa_thread2_w2 & ifu_lsu_asi_ack) |
  diag_wr_cmplt2 ;
assign  tlb_access_rst3 =  reset | 
  (tlu_ldxa_thread3_w2 & tlu_lsu_ldxa_async_data_vld) |
  (tlu_stxa_thread3_w2 & tlu_lsu_stxa_ack) |
  (ifu_tlb_rd_cmplt3) | 
  (ifu_stxa_thread3_w2 & ifu_lsu_asi_ack) |
  diag_wr_cmplt3 ;


// tlb_ld_inst* and tlb_st_inst* are generically used to indicate a read or write. 
// Thread 0
   
dffre_s #(2)  asiv_thrd0 (
        .din    ({ld_inst_vld_g,st_inst_vld_g}),
        .q      ({tlb_ld_inst0,tlb_st_inst0}),
        .rst    (tlb_access_rst0),        .en     (tlb_access_en0_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dffe_s #(3)  asiv_thrd0_sec (
        .din    ({dc_diagnstc_asi_g,dtagv_diagnstc_asi_g,ifu_nontlb_asi_g}),
        .q      ({dc0_diagnstc_asi,dtagv0_diagnstc_asi,ifu_nontlb0_asi}),
        .en     (tlb_access_en0_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  nontlb_asi0 = dc0_diagnstc_asi | dtagv0_diagnstc_asi | ifu_nontlb0_asi ;

// Thread 1

dffre_s #(2)  asiv_thrd1 (
        .din    ({ld_inst_vld_g,st_inst_vld_g}),
        .q      ({tlb_ld_inst1,tlb_st_inst1}),
        .rst    (tlb_access_rst1),        .en     (tlb_access_en1_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dffe_s #(3)  asiv_thrd1_sec (
        .din    ({dc_diagnstc_asi_g,dtagv_diagnstc_asi_g,ifu_nontlb_asi_g}),
        .q      ({dc1_diagnstc_asi,dtagv1_diagnstc_asi,ifu_nontlb1_asi}),
        .en     (tlb_access_en1_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  nontlb_asi1 = dc1_diagnstc_asi | dtagv1_diagnstc_asi | ifu_nontlb1_asi ;

// Thread 2

dffre_s #(2)  asiv_thrd2 (
        .din    ({ld_inst_vld_g,st_inst_vld_g}),
        .q      ({tlb_ld_inst2,tlb_st_inst2}),
        .rst    (tlb_access_rst2),        .en     (tlb_access_en2_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dffe_s #(3)  asiv_thrd2_sec (
        .din    ({dc_diagnstc_asi_g,dtagv_diagnstc_asi_g,ifu_nontlb_asi_g}),
        .q      ({dc2_diagnstc_asi,dtagv2_diagnstc_asi,ifu_nontlb2_asi}),
        .en     (tlb_access_en2_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  nontlb_asi2 = dc2_diagnstc_asi | dtagv2_diagnstc_asi | ifu_nontlb2_asi ;

// Thread 3

dffre_s #(2)  asiv_thrd3 (
        .din    ({ld_inst_vld_g,st_inst_vld_g}),
        .q      ({tlb_ld_inst3,tlb_st_inst3}),
        .rst    (tlb_access_rst3),        .en     (tlb_access_en3_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dffe_s #(3)  asiv_thrd3_sec (
        .din    ({dc_diagnstc_asi_g,dtagv_diagnstc_asi_g,ifu_nontlb_asi_g}),
        .q      ({dc3_diagnstc_asi,dtagv3_diagnstc_asi,ifu_nontlb3_asi}),
        .en     (tlb_access_en3_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  nontlb_asi3 = dc3_diagnstc_asi | dtagv3_diagnstc_asi | ifu_nontlb3_asi ;

//---
//  Prioritization of threaded events from asi queue.
//  - It is not expected that a significant bias will exist in selecting
//  1 of 4 possible events from the asi queue because of the low frequency
//  of such events. However, to bulletproof we will prioritize the events
//  in a fifo manner.
//---

// Control :

wire	[3:0]	fifo_top ;
wire	asi_fifo0_vld,asi_fifo1_vld,asi_fifo2_vld,asi_fifo3_vld;

assign	fifo_top[0] = ~asi_fifo0_vld ; 
assign	fifo_top[1] = ~asi_fifo1_vld & asi_fifo0_vld ; 
assign	fifo_top[2] = ~asi_fifo2_vld & asi_fifo1_vld & asi_fifo0_vld ; 
assign	fifo_top[3] = ~asi_fifo3_vld & asi_fifo2_vld & asi_fifo1_vld & asi_fifo0_vld ; 

// Check for timing on flush.
// Do not confuse thread# with fifo entry#.
wire	fifo_wr, fifo_shift ;
assign	fifo_wr = 
tlb_access_en0_g | tlb_access_en1_g | tlb_access_en2_g | tlb_access_en3_g ;
assign	fifo_shift =
tlb_access_rst0 | tlb_access_rst1 | tlb_access_rst2 | tlb_access_rst3 ;

wire	[3:0]	fifo_top_wr ;
assign	fifo_top_wr[0] = fifo_top[0] & fifo_wr ;
assign	fifo_top_wr[1] = fifo_top[1] & fifo_wr ;
assign	fifo_top_wr[2] = fifo_top[2] & fifo_wr ;
assign	fifo_top_wr[3] = fifo_top[3] & fifo_wr ;

// Matrix for Data Selection.
// shift | wr | din for entry
// 0	   0	na
// 0	   1	thrid_g
// 1	   0	q
// 1	   1	q if top is not 1 above
// 1	   1	thrid_g if top is 1 above

// shift writeable entry into correct position, if exists.
wire	asi_fifo0_sel,asi_fifo1_sel,asi_fifo2_sel ;
assign	asi_fifo0_sel = fifo_shift ? fifo_top_wr[1] : fifo_top_wr[0] ;
assign	asi_fifo1_sel = fifo_shift ? fifo_top_wr[2] : fifo_top_wr[1] ;
assign	asi_fifo2_sel = fifo_shift ? fifo_top_wr[3] : fifo_top_wr[2] ;

wire	[1:0]	asi_fifo3_din,asi_fifo2_din,asi_fifo1_din,asi_fifo0_din ;
wire	[1:0] 	asi_fifo3_q,asi_fifo2_q,asi_fifo1_q,asi_fifo0_q ;
assign	asi_fifo0_din[1:0] = asi_fifo0_sel ? thrid_g[1:0] : asi_fifo1_q[1:0] ;
assign	asi_fifo1_din[1:0] = asi_fifo1_sel ? thrid_g[1:0] : asi_fifo2_q[1:0] ;
assign	asi_fifo2_din[1:0] = asi_fifo2_sel ? thrid_g[1:0] : asi_fifo3_q[1:0] ;
assign	asi_fifo3_din[1:0] = thrid_g[1:0] ; // can never shift into.

// Matrix for Enable 
// shift | wr | Entry Written ?
// 0	   0	0
// 0	   1	if top
// 1	   0	if entry+1 is vld
// 1	   1	if entry itself is vld => as is.

wire	wr_not_sh,sh_not_wr,wr_and_sh ;
assign	wr_not_sh =  fifo_wr & ~fifo_shift ; // write not shift
assign	sh_not_wr = ~fifo_wr &  fifo_shift ; // shift not write
assign	wr_and_sh =  fifo_wr &  fifo_shift ; // shift and write

wire	asi_fifo0_vin,asi_fifo1_vin,asi_fifo2_vin,asi_fifo3_vin ;
assign	asi_fifo0_vin =  
	(wr_not_sh & fifo_top[0]) |
	(sh_not_wr & asi_fifo1_vld) |
	(wr_and_sh & asi_fifo0_vld) ;
assign	asi_fifo1_vin =  
	(wr_not_sh & fifo_top[1]) |
	(sh_not_wr & asi_fifo2_vld) |
	(wr_and_sh & asi_fifo1_vld) ;
assign	asi_fifo2_vin =  
	(wr_not_sh & fifo_top[2]) |
	(sh_not_wr & asi_fifo3_vld) |
	(wr_and_sh & asi_fifo2_vld) ;
assign	asi_fifo3_vin =  
	(wr_not_sh & fifo_top[3]) |
	(wr_and_sh & asi_fifo3_vld) ;

wire	asi_fifo0_en,asi_fifo1_en,asi_fifo2_en,asi_fifo3_en ;
assign	asi_fifo0_en = (fifo_wr & fifo_top[0]) | fifo_shift ; 
assign	asi_fifo1_en = (fifo_wr & fifo_top[1]) | fifo_shift ; 
assign	asi_fifo2_en = (fifo_wr & fifo_top[2]) | fifo_shift ; 
assign	asi_fifo3_en = (fifo_wr & fifo_top[3]) | fifo_shift ; 

wire	asi_fifo3_rst,asi_fifo2_rst,asi_fifo1_rst,asi_fifo0_rst ;
assign	asi_fifo0_rst = reset ;
assign	asi_fifo1_rst = reset ;
assign	asi_fifo2_rst = reset ;
assign	asi_fifo3_rst = reset ;

// Datapath :
// fifo entry 0 is earliest. fifo entry 3 is latest.
dffe_s #(2)  asiq_fifo_0 (
        .din    (asi_fifo0_din[1:0]),
        .q      (asi_fifo0_q[1:0]),
        .en     (asi_fifo0_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

dffre_s   asiqv_fifo_0 (
        .din    (asi_fifo0_vin),
        .q      (asi_fifo0_vld),
        .en     (asi_fifo0_en),	.rst (asi_fifo0_rst),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

wire	asi_sel_thrd3,asi_sel_thrd2,asi_sel_thrd1,asi_sel_thrd0;
assign	asi_sel_thrd0 = ~asi_fifo0_q[1] & ~asi_fifo0_q[0] & (tlb_ld_inst0 | tlb_st_inst0) ;
assign	asi_sel_thrd1 = ~asi_fifo0_q[1] &  asi_fifo0_q[0] & (tlb_ld_inst1 | tlb_st_inst1) ;
assign	asi_sel_thrd2 =  asi_fifo0_q[1] & ~asi_fifo0_q[0] & (tlb_ld_inst2 | tlb_st_inst2) ;
assign	asi_sel_thrd3 =  asi_fifo0_q[1] &  asi_fifo0_q[0] & (tlb_ld_inst3 | tlb_st_inst3) ;

dffe_s #(2)  asiq_fifo_1 (
        .din    (asi_fifo1_din[1:0]),
        .q      (asi_fifo1_q[1:0]),
        .en     (asi_fifo1_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

dffre_s  asiqv_fifo_1 (
        .din    (asi_fifo1_vin),
        .q      (asi_fifo1_vld),
        .en     (asi_fifo1_en),	.rst	(asi_fifo1_rst),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

dffe_s #(2)  asiq_fifo_2 (
        .din    (asi_fifo2_din[1:0]),
        .q      (asi_fifo2_q[1:0]),
        .en     (asi_fifo2_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

dffre_s   asiqv_fifo_2 (
        .din    (asi_fifo2_vin),
        .q      (asi_fifo2_vld),
        .en     (asi_fifo2_en),	.rst	(asi_fifo2_rst),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

dffe_s #(2)  asiq_fifo_3 (
        .din    (asi_fifo3_din[1:0]),
        .q      (asi_fifo3_q[1:0]),
        .en     (asi_fifo3_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

dffre_s  asiqv_fifo_3 (
        .din    (asi_fifo3_vin),
        .q      (asi_fifo3_vld),
        .en     (asi_fifo3_en),	.rst	(asi_fifo3_rst),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

//---

assign  tlb_access_initiated =
  ((tlb_access_sel_thrd0 & ~tlb_access_rst0) |
   (tlb_access_sel_thrd1 & ~tlb_access_rst1) |
   (tlb_access_sel_thrd2 & ~tlb_access_rst2) |
   (tlb_access_sel_thrd3 & ~tlb_access_rst3)) & ~tlb_access_pending ;
   

wire  tlb_blocking_rst ;
assign  tlb_blocking_rst = reset |
  tlu_lsu_stxa_ack | tlu_lsu_ldxa_async_data_vld |
  ifu_tlb_rd_cmplt0 | ifu_tlb_rd_cmplt1 | 
  ifu_tlb_rd_cmplt2 | ifu_tlb_rd_cmplt3 | 
  ifu_lsu_asi_ack |
  lsu_diagnstc_wr_src_sel_e;


// MMU/IFU/DIAG Action is pending
dffre_s #(1)  tlbpnd (
        .din    (tlb_access_initiated),
        .q      (tlb_access_pending),
        .rst    (tlb_blocking_rst),        .en     (tlb_access_initiated),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

/*wire	asi_pend0,asi_pend1,asi_pend2,asi_pend3 ;
dffre_s #(4)  asithrdpnd (
      	.din	({tlb_access_sel_thrd3,tlb_access_sel_thrd2,
		            tlb_access_sel_thrd1,tlb_access_sel_thrd0}),
        .q    ({asi_pend3,asi_pend2,asi_pend1,asi_pend0}),
        .rst	(tlb_blocking_rst), 	.en     (tlb_access_initiated),
        .clk  (clk),
        .se   (se),       .si (),          .so ()
        );

wire	asi_pend_non_thrd0 ;
assign	asi_pend_non_thrd0 = asi_pend1 | asi_pend2 | asi_pend3 ;
wire	asi_pend_non_thrd1 ;
assign	asi_pend_non_thrd1 = asi_pend0 | asi_pend2 | asi_pend3 ;
wire	asi_pend_non_thrd2 ;
assign	asi_pend_non_thrd2 = asi_pend0 | asi_pend1 | asi_pend3 ;
wire	asi_pend_non_thrd3 ;
assign	asi_pend_non_thrd3 = asi_pend0 | asi_pend1 | asi_pend2 ; */

// Would like to remove st_inst_vld_m. This is however required to
// source rs3 data to tlu/mmu. Send rs3_data directly !!!

wire	diag_wr_src, diag_wr_src_d1, diag_wr_src_d2 ;
   
assign  tlb_access_blocked = 
  (tlb_access_pending & ~ifu_asi_vld_d1 & ~diag_wr_src_d1) |
  (st_sqsh_m & ~(ifu_asi_vld_d1 & ~ifu_asi_ack_d1) & ~diag_wr_src_d1) ; // Bug 4875
  //(st_inst_vld_m & ~lsu_ifu_asi_vld_d1 & ~diag_wr_src_d1) ;

// fixed priority. tlb accesses are issued speculatively in the m-stage and are
// Change priority to round-robin !!!
// flushed in the g-stage in the tlu if necessary.
// diagnstc writes will block for cache/tag access.
// This means that access can be blocked if a st is 
// in the m-stage or a memref in the d stage. (!!!)
// In this case, it is better to stage a different
// bus for rs3 data.

// Note : Selection Process.
// 1. Priority Encoded selection if no access pending.
// This may have to be changed to prevent bias towards a
// single thread.
// 2. Once thread is selected :
//	a. generate single pulse - mmu. tlb_access_blocked
//	used for this purpose.
//	b. generate window - ifu/diag. To prevent spurious change
// 	in selects, asi_pend_non_thrdx and tlb_access_pending
//	qual. is required.


assign  tlb_access_sel_thrd0 = ~rst_tri_en &  
  asi_sel_thrd0 & ~tlb_access_blocked ;
assign  tlb_access_sel_thrd1 = ~rst_tri_en & 
  asi_sel_thrd1 & ~tlb_access_blocked ;
assign  tlb_access_sel_thrd2 = ~rst_tri_en &  
  asi_sel_thrd2 & ~tlb_access_blocked ;
assign  tlb_access_sel_thrd3 = ~rst_tri_en &  
  asi_sel_thrd3 & ~tlb_access_blocked ;

//assign  tlb_access_sel_thrd0 = ~rst_tri_en & ( 
//  (tlb_ld_inst0 | tlb_st_inst0) & ~tlb_access_blocked & 
//  ~asi_pend_non_thrd0 );
//assign  tlb_access_sel_thrd1 = ~rst_tri_en & (
//  (tlb_ld_inst1 | tlb_st_inst1) & 
//  ~(((tlb_ld_inst0 | tlb_st_inst0) & ~tlb_access_pending) | tlb_access_blocked) & 
//  ~asi_pend_non_thrd1 );
//assign  tlb_access_sel_thrd2 = ~rst_tri_en & ( 
//  (tlb_ld_inst2 | tlb_st_inst2) & 
//  ~(((tlb_ld_inst0 | tlb_st_inst0 | tlb_ld_inst1 | tlb_st_inst1) & ~tlb_access_pending) 
//		| tlb_access_blocked) &
//  ~asi_pend_non_thrd2 );
//assign  tlb_access_sel_thrd3 = ~rst_tri_en & ( 
//  (tlb_ld_inst3 | tlb_st_inst3) & 
//  ~(((tlb_ld_inst0 | tlb_st_inst0 | tlb_ld_inst1 | tlb_st_inst1 | 
//    tlb_ld_inst2 | tlb_st_inst2) & ~tlb_access_pending) | tlb_access_blocked) &
//  ~asi_pend_non_thrd3 );
        
dff_s  #(4) selt_stgd1 (
        .din    ({tlb_access_sel_thrd3,tlb_access_sel_thrd2,
		tlb_access_sel_thrd1,tlb_access_sel_thrd0}),
        .q     ({tlb_access_sel_thrd3_d1,tlb_access_sel_thrd2_d1,
		tlb_access_sel_thrd1_d1,tlb_access_sel_thrd0_d1}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

   wire tlb_access_sel_default;
assign  tlb_access_sel_default = rst_tri_en | ( 
        ~(tlb_access_sel_thrd2 | tlb_access_sel_thrd1 | tlb_access_sel_thrd0));
   
dff_s  #(4) lsu_diagnstc_data_sel_ff (
        .din    ({tlb_access_sel_default,tlb_access_sel_thrd2,
		tlb_access_sel_thrd1,tlb_access_sel_thrd0}),
        .q     ({lsu_diagnstc_data_sel[3:0]}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dff_s  #(4) lsu_diagnstc_va_sel_ff (
        .din    ({tlb_access_sel_default,tlb_access_sel_thrd2,
		tlb_access_sel_thrd1,tlb_access_sel_thrd0}),
        .q     ({lsu_diagnstc_va_sel[3:0]}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

   
// Begin - Bug 3487
assign	st_sqsh_m = 
	(st_inst_vld_m & asi_internal_m & lsu_alt_space_m) ; // Squash as bus required for stxa.
assign  tlb_st_data_sel_m[0] = (tlb_access_sel_thrd0 & ~st_sqsh_m) | (st_sqsh_m & thread0_m) ;
assign  tlb_st_data_sel_m[1] = (tlb_access_sel_thrd1 & ~st_sqsh_m) | (st_sqsh_m & thread1_m) ;
assign  tlb_st_data_sel_m[2] = (tlb_access_sel_thrd2 & ~st_sqsh_m) | (st_sqsh_m & thread2_m) ;
assign  tlb_st_data_sel_m[3] = ~|tlb_st_data_sel_m[2:0];

assign	lsu_ifu_asi_data_en_l = ~(ifu_asi_vld & tlb_access_initiated) ;

// End - Bug 3487

/*assign  tlb_st_data_sel_m[0] = tlb_access_sel_thrd0 | ((st_inst_vld_m & thread0_m) & tlb_access_blocked) ;
assign  tlb_st_data_sel_m[1] = tlb_access_sel_thrd1 | ((st_inst_vld_m & thread1_m) & tlb_access_blocked) ;
assign  tlb_st_data_sel_m[2] = tlb_access_sel_thrd2 | ((st_inst_vld_m & thread2_m) & tlb_access_blocked) ;
assign  tlb_st_data_sel_m[3] = ~|tlb_st_data_sel_m[2:0];*/

//assign	lsu_tlb_st_sel_m[3:0] = tlb_st_data_sel_m[3:0] ;
assign	lsu_tlb_st_sel_m[0] = tlb_st_data_sel_m[0] & ~rst_tri_en;
assign	lsu_tlb_st_sel_m[1] = tlb_st_data_sel_m[1] & ~rst_tri_en;
assign	lsu_tlb_st_sel_m[2] = tlb_st_data_sel_m[2] & ~rst_tri_en;
assign	lsu_tlb_st_sel_m[3] = tlb_st_data_sel_m[3] |  rst_tri_en;

assign  lsu_tlu_tlb_ld_inst_m =
  (tlb_access_sel_thrd0 & tlb_ld_inst0 & ~nontlb_asi0) |
  (tlb_access_sel_thrd1 & tlb_ld_inst1 & ~nontlb_asi1) |
  (tlb_access_sel_thrd2 & tlb_ld_inst2 & ~nontlb_asi2) |
  (tlb_access_sel_thrd3 & tlb_ld_inst3 & ~nontlb_asi3) ;

// diagnstic write for dside will not go thru tlu.
assign  lsu_tlu_tlb_st_inst_m =
  (tlb_access_sel_thrd0 & tlb_st_inst0 & ~nontlb_asi0) |
  (tlb_access_sel_thrd1 & tlb_st_inst1 & ~nontlb_asi1) |
  (tlb_access_sel_thrd2 & tlb_st_inst2 & ~nontlb_asi2) |
  (tlb_access_sel_thrd3 & tlb_st_inst3 & ~nontlb_asi3) ;

assign  lsu_tlu_tlb_access_tid_m[0] = tlb_access_sel_thrd1 | tlb_access_sel_thrd3 ;
assign  lsu_tlu_tlb_access_tid_m[1] = tlb_access_sel_thrd2 | tlb_access_sel_thrd3 ;

// Diagnostic write to dcache
assign  dc0_diagnstc_wr_en = (tlb_access_sel_thrd0 & tlb_st_inst0 & dc0_diagnstc_asi) ;
assign  dc1_diagnstc_wr_en = (tlb_access_sel_thrd1 & tlb_st_inst1 & dc1_diagnstc_asi) ;
assign  dc2_diagnstc_wr_en = (tlb_access_sel_thrd2 & tlb_st_inst2 & dc2_diagnstc_asi) ;
assign  dc3_diagnstc_wr_en = (tlb_access_sel_thrd3 & tlb_st_inst3 & dc3_diagnstc_asi) ;
assign  dc_diagnstc_wr_en = 
  dc0_diagnstc_wr_en | dc1_diagnstc_wr_en | dc2_diagnstc_wr_en | dc3_diagnstc_wr_en ;

// Diagnostic write to dtag/vld
assign  dtagv0_diagnstc_wr_en = (tlb_access_sel_thrd0 & tlb_st_inst0 & dtagv0_diagnstc_asi) ;
assign  dtagv1_diagnstc_wr_en = (tlb_access_sel_thrd1 & tlb_st_inst1 & dtagv1_diagnstc_asi) ;
assign  dtagv2_diagnstc_wr_en = (tlb_access_sel_thrd2 & tlb_st_inst2 & dtagv2_diagnstc_asi) ;
assign  dtagv3_diagnstc_wr_en = (tlb_access_sel_thrd3 & tlb_st_inst3 & dtagv3_diagnstc_asi) ;
assign  dtagv_diagnstc_wr_en = 
  dtagv0_diagnstc_wr_en | dtagv1_diagnstc_wr_en | dtagv2_diagnstc_wr_en | dtagv3_diagnstc_wr_en ;

// If a diagnostic access is selected in a cycle, then the earliest the
// e-stage can occur for the write is 2-cycles later.

assign  diag_wr_src = dtagv_diagnstc_wr_en | dc_diagnstc_wr_en ;

   wire diag_wr_src_with_rst;
   assign diag_wr_src_with_rst = diag_wr_src & ~lsu_diagnstc_wr_src_sel_e;
   
dff_s  #(1) diagwr_d1 (
        .din    (diag_wr_src_with_rst),
        .q      (diag_wr_src_d1),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
   
   wire diag_wr_src_d1_with_rst;
   assign diag_wr_src_d1_with_rst = diag_wr_src_d1 & ~lsu_diagnstc_wr_src_sel_e;
     
dff_s  #(1) diagwr_d2 (
        .din    (diag_wr_src_d1_with_rst),
        .q      (diag_wr_src_d2),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
   
// If there is no memory reference, then the diag access is free to go.
// tlb_access_blocked must be set appr. 
wire diag_wr_src_sel_d1, diag_wr_src_sel_din;

//bug4057: kill diagnostic write if dfq has valid requests to l1d$
//assign diag_wr_src_sel_din = diag_wr_src_d2 & ~memref_e;
assign diag_wr_src_sel_din = diag_wr_src_d2 & ~(memref_e | lsu_dfq_vld);
   
assign  lsu_diagnstc_wr_src_sel_e =  ~diag_wr_src_sel_d1 & diag_wr_src_sel_din ;

dff_s  #(1) diagwrsel_d1 (
        .din    (diag_wr_src_sel_din),
        .q      (diag_wr_src_sel_d1),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

// Decode for diagnostic cache/dtag/vld write 
   //wire [13:11] lngltncy_ldst_va;
   
   //assign lngltncy_ldst_va[13:11]= lsu_lngltncy_ldst_va[13:11];

//assign  lsu_diagnstc_wr_way_e[0] = ~lngltncy_ldst_va[12] & ~lngltncy_ldst_va[11] ;
//assign  lsu_diagnstc_wr_way_e[1] = ~lngltncy_ldst_va[12] &  lngltncy_ldst_va[11] ;
//assign  lsu_diagnstc_wr_way_e[2] =  lngltncy_ldst_va[12] & ~lngltncy_ldst_va[11] ;
//assign  lsu_diagnstc_wr_way_e[3] =  lngltncy_ldst_va[12] &  lngltncy_ldst_va[11] ;

assign  lsu_diagnstc_dtagv_prty_invrt_e = 
	lsu_diag_va_prty_invrt & dtagv_diagnstc_wr_en & lsu_diagnstc_wr_src_sel_e ;   

// ASI Interface to IFU

assign  lsu_ifu_asi_load =
  (tlb_access_sel_thrd0 & tlb_ld_inst0 & ifu_nontlb0_asi) |
  (tlb_access_sel_thrd1 & tlb_ld_inst1 & ifu_nontlb1_asi) |
  (tlb_access_sel_thrd2 & tlb_ld_inst2 & ifu_nontlb2_asi) |
  (tlb_access_sel_thrd3 & tlb_ld_inst3 & ifu_nontlb3_asi) ;

assign  ifu_asi_store =
  (tlb_access_sel_thrd0 & tlb_st_inst0 & ifu_nontlb0_asi) |
  (tlb_access_sel_thrd1 & tlb_st_inst1 & ifu_nontlb1_asi) |
  (tlb_access_sel_thrd2 & tlb_st_inst2 & ifu_nontlb2_asi) |
  (tlb_access_sel_thrd3 & tlb_st_inst3 & ifu_nontlb3_asi) ;

assign  ifu_asi_vld = lsu_ifu_asi_load | ifu_asi_store ;

dff_s  #(2) iasiv_d1 (
        .din    ({ifu_asi_vld,ifu_lsu_asi_ack}),
        .q      ({ifu_asi_vld_d1,ifu_asi_ack_d1}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

// Bug 3932 - delay asi_vld for ifu.
assign	lsu_ifu_asi_vld = ifu_asi_vld_d1 & ~ifu_asi_ack_d1 ;

assign	ifu_asi_store_cmplt_en = ifu_asi_store & ifu_lsu_asi_ack ;
dff_s  #(1) iasist_d1 (
        .din    (ifu_asi_store_cmplt_en),
        .q      (ifu_asi_store_cmplt_en_d1),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

assign  lsu_ifu_asi_thrid[1:0] = lsu_tlu_tlb_access_tid_m[1:0] ;


//=========================================================================================
//  MEMBAR/FLUSH HANDLING
//=========================================================================================

// Check for skids in this area - verification.

wire [3:0] no_spc_rmo_st ;

// Can membar/flush cause switch out from front end ??? Need to remove from
// ldst_miss if case.
// membar/flush will both swo thread and assert flush.
// membar will signal completion once stb for thread empty
// flush  will signal completion once flush pkt is visible at head of cfq and
// i-side invalidates are complete
// ** flush bit needs to be added to dfq **

dff_s  #(2) bsync_stgm (
        .din    ({ifu_tlu_mb_inst_e,ifu_tlu_flsh_inst_e}),
        .q      ({mbar_inst_m,flsh_inst_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign	lsu_flsh_inst_m = flsh_inst_m ;

wire  mbar_inst_unflushed,flsh_inst_unflushed ;

dff_s  #(2) bsync_stgg (
        .din    ({mbar_inst_m,flsh_inst_m}),
        .q      ({mbar_inst_unflushed,flsh_inst_unflushed}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

wire	[3:0]	flsh_cmplt_d1 ;
/*dff  #(4) flshcmplt (
        .din    (lsu_dfq_flsh_cmplt[3:0]),
        .q      (flsh_cmplt_d1[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );*/

// now flopped in dctl
assign	flsh_cmplt_d1[3:0] = lsu_dfq_flsh_cmplt[3:0] ;

assign  mbar_inst_g = mbar_inst_unflushed & lsu_inst_vld_w ;
assign  flsh_inst_g = flsh_inst_unflushed & lsu_inst_vld_w ;

// THREAD0 MEMBAR/FLUSH

// barrier sync
assign bsync0_reset = 
        reset  | (mbar_vld0 & lsu_stb_empty[0] & no_spc_rmo_st[0]) 
               | (flsh_vld0 & flsh_cmplt_d1[0]) ;

assign  bsync0_en = (flush_inst0_g | mbar_inst0_g) & lsu_inst_vld_w & ~dctl_flush_pipe_w ;

assign  flush_inst0_g = flsh_inst_g & thread0_g ; 
assign  mbar_inst0_g  = mbar_inst_g & thread0_g ; 

// bsyncs are set in g-stage to allow earlier stores in pipe to drain to 
// thread's stb
dffre_s #(2)  bsync_vld0 (
        .din    ({mbar_inst0_g,flush_inst0_g}),
        .q      ({mbar_vld0,flsh_vld0}),
        .rst    (bsync0_reset),        .en     (bsync0_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

// THREAD1 MEMBAR/FLUSH

// barrier sync
assign bsync1_reset = 
        reset  | (mbar_vld1 & lsu_stb_empty[1] & no_spc_rmo_st[1])  
               | (flsh_vld1 & flsh_cmplt_d1[1]) ;

assign  bsync1_en = (flush_inst1_g | mbar_inst1_g) & lsu_inst_vld_w & ~dctl_flush_pipe_w ;

assign  flush_inst1_g = flsh_inst_g & thread1_g ; 
assign  mbar_inst1_g  = mbar_inst_g & thread1_g ; 

// bsyncs are set in g-stage to allow earlier stores in pipe to drain to 
// thread's stb
dffre_s #(2)  bsync_vld1 (
        .din    ({mbar_inst1_g,flush_inst1_g}),
        .q      ({mbar_vld1,flsh_vld1}),
        .rst    (bsync1_reset),        .en     (bsync1_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

// THREAD2 MEMBAR/FLUSH

// barrier sync
assign bsync2_reset = 
        reset  | (mbar_vld2 & lsu_stb_empty[2] & no_spc_rmo_st[2]) 
               | (flsh_vld2 & flsh_cmplt_d1[2]) ;

assign  bsync2_en = (flush_inst2_g | mbar_inst2_g) & lsu_inst_vld_w & ~dctl_flush_pipe_w ;

assign  flush_inst2_g = flsh_inst_g & thread2_g ; 
assign  mbar_inst2_g  = mbar_inst_g & thread2_g ; 

// bsyncs are set in g-stage to allow earlier stores in pipe to drain to 
// thread's stb
dffre_s #(2)  bsync_vld2 (
        .din    ({mbar_inst2_g,flush_inst2_g}),
        .q      ({mbar_vld2,flsh_vld2}),
        .rst    (bsync2_reset),        .en     (bsync2_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

// THREAD3 MEMBAR/FLUSH

// barrier sync
assign bsync3_reset = 
        reset  | (mbar_vld3 & lsu_stb_empty[3] & no_spc_rmo_st[3]) 
               | (flsh_vld3 & flsh_cmplt_d1[3]) ;

assign  bsync3_en = (flush_inst3_g | mbar_inst3_g) & lsu_inst_vld_w & ~dctl_flush_pipe_w ;

assign  flush_inst3_g = flsh_inst_g & thread3_g ; 
assign  mbar_inst3_g  = mbar_inst_g & thread3_g ; 

// bsyncs are set in g-stage to allow earlier stores in pipe to drain to 
// thread's stb
dffre_s #(2)  bsync_vld3 (
        .din    ({mbar_inst3_g,flush_inst3_g}),
        .q      ({mbar_vld3,flsh_vld3}),
        .rst    (bsync3_reset),        .en     (bsync3_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

//=========================================================================================
//  RMO Store Ack Count
//=========================================================================================

// Each thread maintains an 8b outstanding rmo ack count. To avoid overflow,
// it is the responsiblity of software to insert a membar after at most 256 rmo stores.
// 03/08/2003 now change from 256 to 16
// 8 outstanding instead of 16   

wire	[3:0]	ackcnt0,ackcnt1,ackcnt2,ackcnt3 ;
wire	[3:0]	ackcnt0_din,ackcnt1_din,ackcnt2_din,ackcnt3_din ;

// st_rmo_issue/st_rmo_ack vectors are one hot.
// Adders(2). Need two as two separate threads can be incremented and decremented
// in a cycle.
wire 	[3:0]	ackcnt_incr, ackcnt_decr ;
wire 	[3:0]	ackcnt_mx_incr, ackcnt_mx_decr ;

   wire [3:0] acknt_mx_incr_sel;
   assign     acknt_mx_incr_sel[3:0] = lsu_stb_rmo_st_issue[3:0];

assign ackcnt_mx_incr[3:0] =
  (acknt_mx_incr_sel[0] ? ackcnt0[3:0] :  4'b0) |
  (acknt_mx_incr_sel[1] ? ackcnt1[3:0] :  4'b0) |
  (acknt_mx_incr_sel[2] ? ackcnt2[3:0] :  4'b0) |
  (acknt_mx_incr_sel[3] ? ackcnt3[3:0] :  4'b0) ;
   

   wire [3:0] acknt_mx_decr_sel;
   assign     acknt_mx_decr_sel[3:0] = lsu_cpx_rmo_st_ack[3:0];

assign ackcnt_mx_decr[3:0] =
  (acknt_mx_decr_sel[0] ? ackcnt0[3:0] : 4'b0 ) |
  (acknt_mx_decr_sel[1] ? ackcnt1[3:0] : 4'b0 ) |
  (acknt_mx_decr_sel[2] ? ackcnt2[3:0] : 4'b0 ) |
  (acknt_mx_decr_sel[3] ? ackcnt3[3:0] : 4'b0 ) ;
   
    
assign	ackcnt_incr[3:0] = ackcnt_mx_incr[3:0] + 4'b0001 ;
assign	ackcnt_decr[3:0] = ackcnt_mx_decr[3:0] - 4'b0001 ;

assign	ackcnt0_din[3:0] = lsu_cpx_rmo_st_ack[0] ? ackcnt_decr[3:0] : ackcnt_incr[3:0] ;
assign	ackcnt1_din[3:0] = lsu_cpx_rmo_st_ack[1] ? ackcnt_decr[3:0] : ackcnt_incr[3:0] ;
assign	ackcnt2_din[3:0] = lsu_cpx_rmo_st_ack[2] ? ackcnt_decr[3:0] : ackcnt_incr[3:0] ;
assign	ackcnt3_din[3:0] = lsu_cpx_rmo_st_ack[3] ? ackcnt_decr[3:0] : ackcnt_incr[3:0] ;

wire	[3:0]	ackcnt_en ;
// if both occur in the same cycle then they cancel out.
assign	ackcnt_en[0] = lsu_stb_rmo_st_issue[0] ^ lsu_cpx_rmo_st_ack[0] ;
assign	ackcnt_en[1] = lsu_stb_rmo_st_issue[1] ^ lsu_cpx_rmo_st_ack[1] ;
assign	ackcnt_en[2] = lsu_stb_rmo_st_issue[2] ^ lsu_cpx_rmo_st_ack[2] ;
assign	ackcnt_en[3] = lsu_stb_rmo_st_issue[3] ^ lsu_cpx_rmo_st_ack[3] ;

// Thread0
dffre_s #(4)  ackcnt0_ff (
        .din    (ackcnt0_din[3:0]),
        .q      (ackcnt0[3:0]),
        .rst    (reset),        .en     (ackcnt_en[0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

// Thread1
dffre_s #(4)  ackcnt1_ff (
        .din    (ackcnt1_din[3:0]),
        .q      (ackcnt1[3:0]),
        .rst    (reset),        .en     (ackcnt_en[1]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

// Thread2
dffre_s #(4)  ackcnt2_ff (
        .din    (ackcnt2_din[3:0]),
        .q      (ackcnt2[3:0]),
        .rst    (reset),        .en     (ackcnt_en[2]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

// Thread3
dffre_s #(4)  ackcnt3_ff (
        .din    (ackcnt3_din[3:0]),
        .q      (ackcnt3[3:0]),
        .rst    (reset),        .en     (ackcnt_en[3]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

assign	no_spc_rmo_st[0] = ~(|ackcnt0[3:0]) ;
assign	no_spc_rmo_st[1] = ~(|ackcnt1[3:0]) ;
assign	no_spc_rmo_st[2] = ~(|ackcnt2[3:0]) ;
assign	no_spc_rmo_st[3] = ~(|ackcnt3[3:0]) ;

//8 outstanding rmo st will throttle the PCX issue st   
assign lsu_outstanding_rmo_st_max [0] = ackcnt0[3];
assign lsu_outstanding_rmo_st_max [1] = ackcnt1[3];
assign lsu_outstanding_rmo_st_max [2] = ackcnt2[3];
assign lsu_outstanding_rmo_st_max [3] = ackcnt3[3];
  
// streaming unit does not have to care about outstanding rmo sparc-stores.
// membar will take care of that. spu must insert appr. delay in sampling signal.

/*dff #(4)  spustb_d1 ( // moved to stb_rwctl
        .din    (lsu_stb_empty[3:0]),
        .q      (lsu_spu_stb_empty[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); */              

//assign		lsu_spu_stb_empty[3:0] = lsu_stb_empty[3:0] ;

//=========================================================================================
//  Thread Staging
//=========================================================================================

// Thread staging can be optimized. 

dff_s  #(2) thrid_stgd (
        .din    (ifu_lsu_thrid_s[1:0]),
        .q      (thrid_d[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dff_s  #(2) lsu_tlu_thrid_stgd (
        .din    (ifu_lsu_thrid_s[1:0]),
        .q      (lsu_tlu_thrid_d[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
   
//assign	lsu_tlu_thrid_d[1:0] = thrid_d[1:0] ;

assign  thread0_d = ~thrid_d[1] & ~thrid_d[0] ;
assign  thread1_d = ~thrid_d[1] &  thrid_d[0] ;
assign  thread2_d =  thrid_d[1] & ~thrid_d[0] ;
assign  thread3_d =  thrid_d[1] &  thrid_d[0] ;

dff_s  #(2) thrid_stge (
        .din    (thrid_d[1:0]),
        .q      (thrid_e[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  thread0_e = ~thrid_e[1] & ~thrid_e[0] ;
assign  thread1_e = ~thrid_e[1] &  thrid_e[0] ;
assign  thread2_e =  thrid_e[1] & ~thrid_e[0] ;
assign  thread3_e =  thrid_e[1] &  thrid_e[0] ;

dff_s  #(2) thrid_stgm (
        .din    (thrid_e[1:0]),
        .q      (thrid_m[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  thread0_m = ~thrid_m[1] & ~thrid_m[0] ;
assign  thread1_m = ~thrid_m[1] &  thrid_m[0] ;
assign  thread2_m =  thrid_m[1] & ~thrid_m[0] ;
assign  thread3_m =  thrid_m[1] &  thrid_m[0] ;
   
bw_u1_buf_30x UZfix_thread0_m  ( .a(thread0_m),  .z(lsu_dctldp_thread0_m)  );
bw_u1_buf_30x UZfix_thread1_m  ( .a(thread1_m),  .z(lsu_dctldp_thread1_m)  );
bw_u1_buf_30x UZfix_thread2_m  ( .a(thread2_m),  .z(lsu_dctldp_thread2_m)  );
bw_u1_buf_30x UZfix_thread3_m  ( .a(thread3_m),  .z(lsu_dctldp_thread3_m)  );
   
dff_s  #(2) thrid_stgg (
        .din    (thrid_m[1:0]),
        .q      (thrid_g[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  thread0_g = ~thrid_g[1] & ~thrid_g[0] ;
assign  thread1_g = ~thrid_g[1] &  thrid_g[0] ;
assign  thread2_g =  thrid_g[1] & ~thrid_g[0] ;
assign  thread3_g =  thrid_g[1] &  thrid_g[0] ;

dff_s  #(2) thrid_stgw2 (
        .din    (thrid_g[1:0]),
        .q      (thrid_w2[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  thread0_w2 = ~thrid_w2[1] & ~thrid_w2[0] ;
assign  thread1_w2 = ~thrid_w2[1] &  thrid_w2[0] ;
assign  thread2_w2 =  thrid_w2[1] & ~thrid_w2[0] ;
assign  thread3_w2 =  thrid_w2[1] &  thrid_w2[0] ;

dff_s  #(2) thrid_stgw3 (
        .din    (thrid_w2[1:0]),
        .q      (thrid_w3[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  thread0_w3 = ~thrid_w3[1] & ~thrid_w3[0] ;
assign  thread1_w3 = ~thrid_w3[1] &  thrid_w3[0] ;
assign  thread2_w3 =  thrid_w3[1] & ~thrid_w3[0] ;
assign  thread3_w3 =  thrid_w3[1] &  thrid_w3[0] ;
   
//dff  #(4) thrid_stgw3 (
//        .din    ({thread0_w2,thread1_w2,thread2_w2,thread3_w2}),
//        .q      ({thread0_w3,thread1_w3,thread2_w3,thread3_w3}),
//        .clk    (clk),
//        .se     (se),       .si (),          .so ()
//        );

// ldxa thread id

//assign  ldxa_thrid_w2[1:0] = tlu_lsu_ldxa_tid_w2[1:0] ; // Removed original assign as per OpenSPARC T1 Internals 

assign ldxa_thrid_w2[1:0] = cfg_asi_lsu_ldxa_vld_w2 ? 
                            cfg_asi_lsu_ldxa_tid_w2[1:0] :
                            tlu_lsu_ldxa_tid_w2[1:0];

assign  tlu_ldxa_thread0_w2 = ~ldxa_thrid_w2[1] & ~ldxa_thrid_w2[0] ;
assign  tlu_ldxa_thread1_w2 = ~ldxa_thrid_w2[1] &  ldxa_thrid_w2[0] ;
assign  tlu_ldxa_thread2_w2 =  ldxa_thrid_w2[1] & ~ldxa_thrid_w2[0] ;
assign  tlu_ldxa_thread3_w2 =  ldxa_thrid_w2[1] &  ldxa_thrid_w2[0] ;

assign  spu_stxa_thread0 = ~spu_lsu_stxa_ack_tid[1] & ~spu_lsu_stxa_ack_tid[0] ;
assign  spu_stxa_thread1 = ~spu_lsu_stxa_ack_tid[1] &  spu_lsu_stxa_ack_tid[0] ;
assign  spu_stxa_thread2 =  spu_lsu_stxa_ack_tid[1] & ~spu_lsu_stxa_ack_tid[0] ;
assign  spu_stxa_thread3 =  spu_lsu_stxa_ack_tid[1] &  spu_lsu_stxa_ack_tid[0] ;

assign  spu_ldxa_thread0_w2 = ~spu_lsu_ldxa_tid_w2[1] & ~spu_lsu_ldxa_tid_w2[0] ;
assign  spu_ldxa_thread1_w2 = ~spu_lsu_ldxa_tid_w2[1] &  spu_lsu_ldxa_tid_w2[0] ;
assign  spu_ldxa_thread2_w2 =  spu_lsu_ldxa_tid_w2[1] & ~spu_lsu_ldxa_tid_w2[0] ;
assign  spu_ldxa_thread3_w2 =  spu_lsu_ldxa_tid_w2[1] &  spu_lsu_ldxa_tid_w2[0] ;

assign  ifu_ldxa_thread0_w2 = ~ifu_lsu_ldxa_tid_w2[1] & ~ifu_lsu_ldxa_tid_w2[0] ;
assign  ifu_ldxa_thread1_w2 = ~ifu_lsu_ldxa_tid_w2[1] &  ifu_lsu_ldxa_tid_w2[0] ;
assign  ifu_ldxa_thread2_w2 =  ifu_lsu_ldxa_tid_w2[1] & ~ifu_lsu_ldxa_tid_w2[0] ;
assign  ifu_ldxa_thread3_w2 =  ifu_lsu_ldxa_tid_w2[1] &  ifu_lsu_ldxa_tid_w2[0] ;

wire	[1:0]	ifu_nontlb_asi_tid ;
dff_s  #(2) iasi_tid (
        .din    (lsu_ifu_asi_thrid[1:0]),
        .q      (ifu_nontlb_asi_tid[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  ifu_stxa_thread0_w2 = ~ifu_nontlb_asi_tid[1] & ~ifu_nontlb_asi_tid[0] ;
assign  ifu_stxa_thread1_w2 = ~ifu_nontlb_asi_tid[1] &  ifu_nontlb_asi_tid[0] ;
assign  ifu_stxa_thread2_w2 =  ifu_nontlb_asi_tid[1] & ~ifu_nontlb_asi_tid[0] ;
assign  ifu_stxa_thread3_w2 =  ifu_nontlb_asi_tid[1] &  ifu_nontlb_asi_tid[0] ;

assign  tlu_stxa_thread0_w2 = ~tlu_lsu_stxa_ack_tid[1] & ~tlu_lsu_stxa_ack_tid[0] ;
assign  tlu_stxa_thread1_w2 = ~tlu_lsu_stxa_ack_tid[1] &  tlu_lsu_stxa_ack_tid[0] ;
assign  tlu_stxa_thread2_w2 =  tlu_lsu_stxa_ack_tid[1] & ~tlu_lsu_stxa_ack_tid[0] ;
assign  tlu_stxa_thread3_w2 =  tlu_lsu_stxa_ack_tid[1] &  tlu_lsu_stxa_ack_tid[0] ;

//=========================================================================================
//  Exception Handling
//=========================================================================================


// tlb related exceptions/errors
//SC assign  tlb_daccess_excptn_e  =
//SC  ((rd_only_ltlb_asi_e &  st_inst_vld_e)  |
//SC   (wr_only_ltlb_asi_e &  ld_inst_vld_e)) & alt_space_e   ;

//SC assign  tlb_daccess_error_e =
//SC   ((dfill_tlb_asi_e & ~lsu_tlb_writeable)     | 
//SC   (ifill_tlb_asi_e & ~ifu_lsu_tlb_writeable)) & st_inst_vld_e & alt_space_e ; 

//SC dff  #(2) tlbex_stgm (
//SC         .din    ({tlb_daccess_excptn_e,tlb_daccess_error_e}),
//SC         .q      ({tlb_daccess_excptn_m,tlb_daccess_error_m}),
//SC         .clk    (clk),
//SC         .se     (se),       .si (),          .so ()
//SC         );

//SC dff  #(2) tlbex_stgg (
//SC         .din    ({tlb_daccess_excptn_m,tlb_daccess_error_m}),
//SC         .q      ({tlb_daccess_excptn_g,tlb_daccess_error_g}),
//SC         .clk    (clk),
//SC         .se     (se),       .si (),          .so ()
//SC         );

//assign  pstate_priv_m = 
//  thread0_m ? tlu_lsu_pstate_priv[0] :
//    thread1_m ? tlu_lsu_pstate_priv[1] :
//      thread2_m ? tlu_lsu_pstate_priv[2] :
//          tlu_lsu_pstate_priv[3] ;

//SC mux4ds  #(1) pstate_priv_m_mux (
//SC         .in0    (tlu_lsu_pstate_priv[0]),
//SC         .in1    (tlu_lsu_pstate_priv[1]),
//SC         .in2    (tlu_lsu_pstate_priv[2]),
//SC         .in3    (tlu_lsu_pstate_priv[3]),
//SC         .sel0   (thread0_m),  
//SC         .sel1   (thread1_m),
//SC         .sel2   (thread2_m),  
//SC         .sel3   (thread3_m),
//SC         .dout   (pstate_priv_m)
//SC );
   
//SC dff  priv_stgg (
//SC         .din    (pstate_priv_m),
//SC         .q      (pstate_priv),
//SC         .clk    (clk),
//SC         .se     (se),       .si (),          .so ()
//SC         );

// privilege violation - priv page accessed in user mode
//SC assign  priv_pg_usr_mode =  // data access exception; TT=h30
//SC   (ld_inst_vld_unflushed | st_inst_vld_unflushed) & ~(pstate_priv | hpv_priv) & tlb_rd_tte_data[`STLB_DATA_P] ;

// protection violation - store to a page that does not have write permission
//SC assign  nonwr_pg_st_access =  // data access protection; TT=h33
//SC   st_inst_vld_unflushed   & 
//SC   ~tlb_rd_tte_data[`STLB_DATA_W] & ~lsu_dtlb_bypass_g & tlb_cam_hit_g ;
   //lsu_dtlb_bypass_g) ; // W=1 in bypass mode - In bypass mode this trap will never happen !!!

//SC wire  daccess_prot ;
//SC assign  daccess_prot = nonwr_pg_st_access  ;
    //((~lsu_dtlb_bypass_g & tlb_cam_hit_g) | (tlb_byp_asi_g & lsu_alt_space_g)) ;

// access to a page marked with the nfo with an asi other than nfo asi.
//SC assign  nfo_pg_nonnfo_asi  =  // data access exception; TT=h30
//SC   (ld_inst_vld_unflushed | st_inst_vld_unflushed) &   // any access
//SC   ((~nofault_asi_g & lsu_alt_space_g) | ~lsu_alt_space_g) // in alternate space or not
//SC   & tlb_rd_tte_data[`STLB_DATA_NFO] ;

// as_if_usr asi accesses priv page.
//SC assign  as_if_usr_priv_pg  =  // data access exception; TT=h30
//SC   (ld_inst_vld_unflushed | st_inst_vld_unflushed) & as_if_user_asi_g & lsu_alt_space_g & 
//SC       tlb_rd_tte_data[`STLB_DATA_P] ;


// non-cacheable address - iospace or cp=0 (???)
// atomic access to non-cacheable space.
//SC assign  atm_access_w_nc = atomic_g & tlb_pgnum[39] ; // io space 

// atomic inst with unsupported asi.
//SC assign  atm_access_unsup_asi = atomic_g & ~atomic_asi_g & lsu_alt_space_g ;

//SC wire  tlb_tte_vld_g ;
//SC assign  tlb_tte_vld_g = ~lsu_dtlb_bypass_g & tlb_cam_hit_g ;

//SC wire  pg_with_ebit ;
//SC assign	pg_with_ebit = 
//SC 	(tlb_rd_tte_data[`STLB_DATA_E] & tlb_tte_vld_g)  | // tte
//SC         (lsu_dtlb_bypass_g & ~(phy_use_ec_asi_g & lsu_alt_space_g)) | // regular bypass 
//SC         (tlb_byp_asi_g & ~phy_use_ec_asi_g & lsu_alt_space_g) ; // phy_byp
	
//SC wire  spec_access_epage ;
//SC assign  spec_access_epage = 
//SC   ((ld_inst_vld_unflushed & nofault_asi_g & lsu_alt_space_g) |  // spec load
//SC   flsh_inst_g) & // flush inst
//SC   pg_with_ebit ; // page with side effects
//  tlb_rd_tte_data[`STLB_DATA_E] ; // page with side effects

//SC wire  quad_asi_non_ldstda ;
// quad-asi used with non ldda/stda
// remove st_inst_vld - stquad unused
// the equation may be incorrect - needs to be for a non-ldda
//SC assign  quad_asi_non_ldstda = quad_asi_g & lsu_alt_space_g & ~ldst_dbl_g & 
//SC      (ld_inst_vld_unflushed | st_inst_vld_unflushed) ;
// need to put in similar exception for binit st
//SC wire  binit_asi_non_ldda ;
//SC assign  binit_asi_non_ldda = binit_quad_asi_g & lsu_alt_space_g & ~ldst_dbl_g & 
//SC      (ld_inst_vld_unflushed) ;
//SC wire  blk_asi_non_ldstdfa ;
//SC assign  blk_asi_non_ldstdfa = blk_asi_g & lsu_alt_space_g & 
//SC      ~(ldst_dbl_g & fp_ldst_g) & (ld_inst_vld_unflushed | st_inst_vld_unflushed) ;

// trap on illegal asi
//SC wire  illegal_asi_trap_g ;
//SC assign  illegal_asi_trap_g = 
//SC (ld_inst_vld_unflushed | st_inst_vld_unflushed) &
//SC lsu_alt_space_g & ~recognized_asi_g & lsu_inst_vld_w ;

// This can be pushed back into previous cycle.
//SC wire wr_to_strm_sync ;
//SC assign	wr_to_strm_sync =  	
//SC   strm_asi & ((ldst_va_g[7:0] == 8'hA0) | (ldst_va_g[7:0] == 8'h68)) &
//SC   st_inst_vld_unflushed & lsu_alt_space_g ;

// This should not be double-anded with tlb_tte_vld_g. Check !!!
//SC assign  daccess_excptn =  
//SC     ((priv_pg_usr_mode | as_if_usr_priv_pg | nfo_pg_nonnfo_asi | 
//SC     atm_access_w_nc | atm_access_unsup_asi)) 
//SC       & tlb_tte_vld_g | 
//SC     spec_access_epage |
//SC     asi_related_trap_g | quad_asi_non_ldstda | tlb_daccess_excptn_g |
//SC     illegal_asi_trap_g | spv_use_hpv | binit_asi_non_ldda | wr_to_strm_sync | 
//SC    blk_asi_non_ldstdfa ;

// HPV Changes 
// Push back into previous stage.
// qualification with hpv_priv and hpstate_en required to ensure hypervisor
// is not trying to access.

//assign  hpv_priv_e = 
//  thread0_e ? tlu_lsu_hpv_priv[0] :
//    thread1_e ? tlu_lsu_hpv_priv[1] :
//      thread2_e ? tlu_lsu_hpv_priv[2] :
//          		tlu_lsu_hpv_priv[3] ;

// Timing change :

wire [3:0] hpv_priv_d1 ;
wire [3:0] hpstate_en_d1 ;

dff_s #(8) hpv_stgd1 (
        .din    ({tlu_lsu_hpv_priv[3:0],tlu_lsu_hpstate_en[3:0]}),
        .q    	({hpv_priv_d1[3:0],hpstate_en_d1[3:0]}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
  
mux4ds  #(1) hpv_priv_e_mux (
        .in0    (hpv_priv_d1[0]),
        .in1    (hpv_priv_d1[1]),
        .in2    (hpv_priv_d1[2]),
        .in3    (hpv_priv_d1[3]),
        .sel0   (thread0_e),  
        .sel1   (thread1_e),
        .sel2   (thread2_e),  
        .sel3   (thread3_e),
        .dout   (hpv_priv_e)
);
 
//assign  hpstate_en_e = 
//  thread0_e ? tlu_lsu_hpstate_en[0] :
//    thread1_e ? tlu_lsu_hpstate_en[1] :
//      thread2_e ? tlu_lsu_hpstate_en[2] :
//          		tlu_lsu_hpstate_en[3] ;

mux4ds  #(1) hpstate_en_e_mux (
        .in0    (hpstate_en_d1[0]),
        .in1    (hpstate_en_d1[1]),
        .in2    (hpstate_en_d1[2]),
        .in3    (hpstate_en_d1[3]),
        .sel0   (thread0_e),  
        .sel1   (thread1_e),
        .sel2   (thread2_e),  
        .sel3   (thread3_e),
        .dout   (hpstate_en_e)
);
   
dff_s #(2) hpv_stgm (
        .din    ({hpv_priv_e, hpstate_en_e}),
        .q    	({hpv_priv_m, hpstate_en_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

//dff #(2) hpv_stgg (
//        .din    ({hpv_priv_m, hpstate_en_m}),
//        .q    	({hpv_priv,   hpstate_en}),
//        .clk    (clk),
//        .se     (se),       .si (),          .so ()
//        );

/*assign  priv_action = (ld_inst_vld_unflushed | st_inst_vld_unflushed) & ~lsu_asi_state[7] & 
      ~pstate_priv & ~(hpv_priv & hpstate_en) & lsu_alt_space_g ;*/
// Generate a stage earlier
//SC assign  priv_action_m = (ld_inst_vld_m | st_inst_vld_m) & ~lsu_dctl_asi_state_m[7] & 
//SC       ~pstate_priv_m & ~(hpv_priv_m & hpstate_en_m) & lsu_alt_space_m ;

//SC dff  pact_stgg (
//SC         .din    (priv_action_m),
//SC         .q    	(priv_action),
//SC         .clk    (clk),
//SC         .se     (se),       .si (),          .so ()
//SC         );

// Take data_access exception if supervisor uses hypervisor asi
//SC wire    hpv_asi_range ;
//SC assign  hpv_asi_range =
//SC                     ~lsu_asi_state[7] & (
//SC                          (~lsu_asi_state[6] & lsu_asi_state[5] & lsu_asi_state[4]) | // 0x3?
//SC                          ( lsu_asi_state[6]));                                   // 0x4?,5?,6?,7?

// Take data_access exception if supervisor uses hypervisor asi
//SC `ifdef  SPARC_HPV_EN
//SC assign  spv_use_hpv = (ld_inst_vld_unflushed | st_inst_vld_unflushed) &
//SC                          hpv_asi_range &
//SC                          //~lsu_asi_state[7] & lsu_asi_state[6] & lsu_asi_state[5] & // 0x30-0x7f
//SC                          pstate_priv & ~hpv_priv & lsu_alt_space_g ;
//SC `else
//SC assign  spv_use_hpv = 1'b0 ;
//SC `endif


// EARLY TRAPS

// memory address not aligned
//SC wire  qw_align_addr,blk_align_addr ;
//SC assign  hw_align_addr = ~ldst_va_m[0] ;         // half-word addr
//SC assign  wd_align_addr = ~ldst_va_m[1] & ~ldst_va_m[0] ;     // word addr
//SC assign  dw_align_addr = ~ldst_va_m[2] & ~ldst_va_m[1] & ~ldst_va_m[0] ; // dw addr
//SC assign  qw_align_addr = ~ldst_va_m[3] & ~ldst_va_m[2] & ~ldst_va_m[1] & ~ldst_va_m[0] ; // qw addr
//SC assign  blk_align_addr = 
//SC ~ldst_va_m[5] & ~ldst_va_m[4] & ~ldst_va_m[3] & 
//SC ~ldst_va_m[2] & ~ldst_va_m[1] & ~ldst_va_m[0] ; // 64B aligned addr for block ld/st

//assign  byte_size = ~ldst_sz_m[1] &  ~ldst_sz_m[0] ; // byte size    
//assign  hw_size = ~ldst_sz_m[1] &  ldst_sz_m[0] ; // half-word size 
//assign  wd_size =  ldst_sz_m[1] & ~ldst_sz_m[0] ; // word size
//assign  dw_size =  ldst_sz_m[1] &  ldst_sz_m[0] ; // double-word size

//assign  byte_size = byte_m;
assign  hw_size = hword_m; 
assign  wd_size = word_m;
assign  dw_size = dword_m;
   
//SC assign  mem_addr_not_align
//SC   = ((hw_size & ~hw_align_addr) | // half-word check
//SC     (wd_size & ~wd_align_addr)  | // word check
//SC     (dw_size & ~dw_align_addr)  | // double word check
//SC    ((quad_asi_m | binit_quad_asi_m) & lsu_alt_space_m & ldst_dbl_m & ~qw_align_addr) | // quad word check
//SC     (blk_asi_m & lsu_alt_space_m & fp_ldst_m & ldst_dbl_m & ~blk_align_addr)) & // 64B blk ld/st check
//SC     //(blk_asi_m & lsu_alt_space_m & blk_asi_m & ~blk_align_addr)) & // 64B blk ld/st check
//SC     (ld_inst_vld_m | st_inst_vld_m) ;

//SC assign  stdf_maddr_not_align
//SC     = st_inst_vld_m & fp_ldst_m & ldst_dbl_m & wd_align_addr & ~dw_align_addr ;

//SC assign  lddf_maddr_not_align
//SC     = ld_inst_vld_m & fp_ldst_m & ldst_dbl_m & wd_align_addr & ~dw_align_addr ;

// internal asi access by ld/st other than ldxa/stxa/lddfa/stdfa.
// qual with ldst_dbl_m needed. lda and stda should take trap if accessing internal asi.
//SC assign  asi_internal_non_xdw 
//SC     = (st_inst_vld_m | ld_inst_vld_m) & lsu_alt_space_m & asi_internal_m  & ~(dw_size & ~ldst_dbl_m) ;


// asi related
// rd-only mmu asi requiring va decode.
//SC wire	mmu_rd_only_asi_wva_m ;
//SC assign	mmu_rd_only_asi_wva_m =
//SC 	((lsu_dctl_asi_state_m[7:0]==8'h58) & (
//SC 		(ldst_va_m[8:0] == 9'h000) | 	// dtag_target
//SC 		(ldst_va_m[8:0] == 9'h020))) | 	// dsync_far
//SC 	((lsu_dctl_asi_state_m[7:0]==8'h50) & 
//SC 		(ldst_va_m[8:0] == 9'h000)) ; 	// itag_target

//SC assign  wr_to_rd_only_asi = 
//SC 	(mmu_rd_only_asi_wva_m |// mmu with non-unique asi
//SC 	mmu_rd_only_asi_m |	// mmu with unique asi
//SC 	rd_only_asi_m)		// non mmu
//SC 	 &  st_inst_vld_m & lsu_alt_space_m ;

//SC assign  rd_of_wr_only_asi = wr_only_asi_m &  ld_inst_vld_m & lsu_alt_space_m ;
//SC assign  unimp_asi_used = unimp_asi_m &  (ld_inst_vld_m | st_inst_vld_m) & lsu_alt_space_m ;
//assign  asi_related_trap_m = wr_to_rd_only_asi | rd_of_wr_only_asi | unimp_asi_used | asi_internal_non_xdw ;

//SC assign  early_trap_vld_m =  stdf_maddr_not_align | lddf_maddr_not_align | mem_addr_not_align ;
      
//SC assign  lsu_tlu_misalign_addr_ldst_atm_m = early_trap_vld_m ;

// mux select order must be maintained
//SC assign  early_ttype_m[8:0] = 
//SC       stdf_maddr_not_align ? 9'h036 :
//SC         lddf_maddr_not_align ? 9'h035 : 
//SC           mem_addr_not_align ? 9'h034 : 9'hxxx ;

//SC dff #(11)   etrp_stgg (
//SC         .din    ({early_ttype_m[8:0],early_trap_vld_m,asi_related_trap_m}),
//SC         .q      ({early_ttype_g[8:0],early_trap_vld_g,asi_related_trap_g}),
//SC         .clk    (clk),
//SC         .se     (se),       .si (),          .so ()
//SC         );

//SC wire nceen_pipe_g ;
//SC assign  nceen_pipe_g = 
//SC   (thread0_g & ifu_lsu_nceen[0]) | (thread1_g & ifu_lsu_nceen[1]) |
//SC   (thread2_g & ifu_lsu_nceen[2]) | (thread3_g & ifu_lsu_nceen[3]) ;
//SC wire nceen_fill_e,nceen_fill_m,nceen_fill_g ;
//SC assign  nceen_fill_e = 
//SC   (dfill_thread0 & ifu_lsu_nceen[0]) | (dfill_thread1 & ifu_lsu_nceen[1]) |
//SC   (dfill_thread2 & ifu_lsu_nceen[2]) | (dfill_thread3 & ifu_lsu_nceen[3]) ;

//SC dff  #(1) nce_stgm (
//SC         .din    (nceen_fill_e),
//SC         .q      (nceen_fill_m),
//SC         .clk    (clk),
//SC         .se     (se),       .si (),          .so ()
//SC         );

//SC dff  #(1) nce_stgg (
//SC         .din    (nceen_fill_m),
//SC         .q      (nceen_fill_g),
//SC         .clk    (clk),
//SC         .se     (se),       .si (),          .so ()
//SC         );

//SC assign  daccess_error = 1'b0 ;
  // Commented out currently for timing reasons. This needs to be
  // rolled into the ttype_vld sent to the tlu, but can be left out
  // of the flush sent to the remaining units.
  /*((tte_data_perror_unc) & nceen_pipe_g & // on xslate 
  ~(early_trap_vld_g | priv_action | va_wtchpt_match | dmmu_miss_g)) |
  tlb_asi_unc_err_g |     // asi read
  (unc_err_trap_g & nceen_fill_g) | // cache data
  tlb_daccess_error_g ;     // tlb not writeable */

//SC assign  lsu_tlu_async_dacc_err_g = unc_err_trap_g | tlb_asi_unc_err_g ;

//SC assign  lsu_tlu_dmmu_miss_g = dmmu_miss_g ;

 wire  cam_real_m ;
 dff_s   real_stgm (
         .din    (lsu_dtlb_cam_real_e),
         .q      (cam_real_m),
         .clk    (clk),
         .se     (se),       .si (),          .so ()
         );
 
// dff   real_stgg (
//         .din    (cam_real_m),
//         .q      (cam_real_g),
//         .clk    (clk),
//         .se     (se),       .si (),          .so ()
//         );
 
assign  lsu_tlu_nonalt_ldst_m =  (st_inst_vld_m | ld_inst_vld_m) & ~lsu_alt_space_m  ;
assign  lsu_tlu_xslating_ldst_m = (st_inst_vld_m | ld_inst_vld_m) & 
	(((~asi_internal_m  & recognized_asi_m) & lsu_alt_space_m)  | // Bug 4327
	~lsu_alt_space_m) ;

assign  ctxt_sel_e[0] = thread_pctxt ; 
assign  ctxt_sel_e[1] = thread_sctxt ; 
assign  ctxt_sel_e[2] = 
	thread_nctxt | 
	(~(thread_pctxt | thread_sctxt) &  // default to nucleus - translating asi
	~(alt_space_e & (asi_internal_e | ~recognized_asi_e ))) ; //bug3660
					   // nontranslating asi to select 11 in CT
					   // field of dsfsr.

dff_s  #(3) ctxsel (
        .din    (ctxt_sel_e[2:0]),
        .q      (lsu_tlu_ctxt_sel_m[2:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign	lsu_tlu_nucleus_ctxt_m = lsu_tlu_ctxt_sel_m[2] ;

assign  lsu_tlu_write_op_m = st_inst_vld_m | atomic_m ;

// va_oor_m check needs to be in case of bypass, pstate.am=1, internal and illegal asi. 
// pstate.am squashing is done locally in tlu.

assign  lsu_tlu_squash_va_oor_m =
  dtlb_bypass_m   |     // bypass
  //sta_internal_m  | lda_internal_m |  // internal asi
  (asi_internal_m & lsu_alt_space_m) |	// Bug 5156
  (~recognized_asi_tmp & lsu_alt_space_m) ; // illegal asi // Timing change.

   assign lsu_squash_va_oor_m =  lsu_tlu_squash_va_oor_m;
  
//=========================================================================================
//  Generate Flush Pipe
//=========================================================================================

//SC wire	other_flush_pipe_w ;
// lsu_tlu_ttype_vld needs to be optimized in terms of timing.
//SC assign	other_flush_pipe_w = tlu_early_flush_pipe_w | (lsu_tlu_ttype_vld_m2 & lsu_inst_vld_w);
//SC assign	lsu_ifu_flush_pipe_w = other_flush_pipe_w ;
//SC assign	lsu_exu_flush_pipe_w = other_flush_pipe_w ;
//SC assign	lsu_ffu_flush_pipe_w = other_flush_pipe_w ;

//SC //assign	lsu_flush_pipe_w = other_flush_pipe_w | ifu_tlu_flush_w ;

//=========================================================================================
//  Early Traps to SPU
//=========================================================================================

// detect st to ma/strm sync - data-access exception.
//SC wire	st_to_sync_dexcp_m ;
// qual with alt_space not required - spu will do it.
//SC assign	st_to_sync_dexcp_m = 
//SC   strm_asi_m & ((ldst_va_m[7:0] == 8'ha0) | (ldst_va_m[7:0] == 8'h68)) & st_inst_vld_m ;  

//SC wire	spu_early_flush_m ;

//SC assign	spu_early_flush_m =
//SC 	priv_action_m 		|
//SC 	mem_addr_not_align 	|
//SC 	st_to_sync_dexcp_m 	; 

//SC dff  eflushspu_g (
//SC         .din    (spu_early_flush_m),
//SC         .q      (lsu_spu_early_flush_g),
//SC         .clk    (clk),
//SC         .se     (se),       .si (),          .so ()
//SC         );

//SC dff  eflushtlu_g (
//SC         .din    (spu_early_flush_m),
//SC         .q      (lsu_tlu_early_flush_w),
//SC        .clk    (clk),
//SC         .se     (se),       .si (),          .so ()
 //SC        );

//=========================================================================================
//  Parity Error Checking
//=========================================================================================

// DCache Parity Error
// - Parity Check is done for entire 64b. No attempt is made to match on size. A
// parity error will force a miss and refetch a line to the same way of the cache.
// - Logging of error is done in g-stage of issue.
// - Trap taken on data return

wire	dcache_perr_en ;
assign	dcache_perr_en  =
  dcache_enable_g & ~(asi_internal_g & lsu_alt_space_g) & 
  ~atomic_g  & 
  // dcache_rd_parity_err qualified with cache_way_hit - could be x.
  (lsu_dtlb_bypass_g | (~lsu_dtlb_bypass_g & tlb_cam_hit_g)) ;
assign dcache_rd_parity_error = dcache_rparity_err_wb & dcache_perr_en ;
 
// dtag parity error gets priority over dcache priority.
assign  lsu_dcache_data_perror_g = 
  dcache_rd_parity_error & ld_inst_vld_unflushed & lsu_inst_vld_w & ~dtag_perror_g & 
  dcache_perr_en ;
//  dcache_enable_g & ~(asi_internal_g & lsu_alt_space_g) & 
//  ~atomic_g ; 

// DTLB Parity Errors. 
// ASI read of Tag/Data :
//  - uncorrectible error
//  - logging occurs on read.
//  - precise trap is taken when ldxa completes if nceen set.
//  - if not set then ldxa is allowed to complete.
// CAM Read of Tag/Data :
//  - correctible if locked bit not set.
//    - takes disrupting trap later.
//  - uncorrectible if locked bit set.
//  - both are treated as precise traps.
//  - if errors not enabled, then load completes as if hit in L1.
// ** TLB error will cause a trap which will preclude concurrent dcache,dtag  **
// ** parity errors.                **

//SC assign  tte_data_parity_error = 
//SC   tlb_rd_tte_data_parity ^ lsu_rd_tte_data_parity ;
//SC assign  tte_tag_parity_error  = 
//SC   tlb_rd_tte_tag_parity ^ lsu_rd_tte_tag_parity ;

// cam related tte data parity error - error assumed correctible if locked
// bit is not set. Will cause a dmmu_miss for correction.
// qualify with cam_hit ??
//SC assign  tte_data_perror_corr = 
//SC   tte_data_parity_error & ~tlb_rd_tte_data_locked & tlb_tte_vld_g & 
//SC   (ld_inst_vld_unflushed | st_inst_vld_unflushed) & lsu_inst_vld_w ;
// same as above except error is treated as uncorrectible. This is to be posted to 
// error status register which will cause a disrupting trap later.
//SC assign  tte_data_perror_unc  = 
//SC   tte_data_parity_error &  tlb_rd_tte_data_locked & tlb_tte_vld_g & 
//SC   (ld_inst_vld_unflushed | st_inst_vld_unflushed) & lsu_inst_vld_w ;
// Asi rd parity error detection
//SC assign  asi_tte_data_perror =
//SC   tte_data_parity_error & data_rd_vld_g ;
// For data tte read, both tag and data arrays are read.
// Parity error on asi read of tag should not be reported.
//SC assign  asi_tte_tag_perror =
//SC   tte_tag_parity_error & tag_rd_vld_g & ~data_rd_vld_g ;
//SC assign  lsu_tlu_asi_rd_unc = asi_tte_data_perror | asi_tte_tag_perror ;

// asi rd parity errors need to be reported thru asi bus
/*assign  lsu_ifu_tlb_data_ce = tte_data_perror_corr ;
assign  lsu_ifu_tlb_data_ue = tte_data_perror_unc | asi_tte_data_perror ;
assign  lsu_ifu_tlb_tag_ue  = asi_tte_tag_perror ; */


//SC wire  tlb_data_ue_g ;
//SC assign  tlb_data_ue_g = tte_data_perror_unc | asi_tte_data_perror ;

//SC dff  #(3) terr_stgd1 (
//SC         .din    ({tte_data_perror_corr,tlb_data_ue_g,asi_tte_tag_perror}),
//SC         .q      ({lsu_ifu_tlb_data_ce,lsu_ifu_tlb_data_ue,lsu_ifu_tlb_tag_ue}),
//SC         .clk    (clk),
//SC         .se     (se),       .si (),          .so ()
//SC         );

// Dtag Parity Error
// - corrected thru special mechanism
// - correctible error
// - Trap taken on data return

// move parity error calculation to g stage

dff_s  #(`L1D_WAY_COUNT) dva_vld_g_ff (
         .din    (dva_vld_m[`L1D_WAY_COUNT-1:0]),
         .q      (dva_vld_g[`L1D_WAY_COUNT-1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

   assign dva_vld_m_bf[`L1D_WAY_COUNT-1:0] = dva_vld_m[`L1D_WAY_COUNT-1:0];
   
wire	dtag_perr_en ; 
assign	dtag_perr_en = 
dcache_enable_g & ~(asi_internal_g & lsu_alt_space_g) & // Bug 3541
  ~(lsu_alt_space_g & blk_asi_g) &  // Bug 3926. 
  ~atomic_g & // Bug 4274,4297 
  ~pref_inst_g ; // Bug 5046
// assign  dtag_parity_error[0] = 
//       lsu_rd_dtag_parity_g[0] & dva_vld_g[0] & dtag_perr_en;
// assign  dtag_parity_error[1] = 
//       lsu_rd_dtag_parity_g[1] & dva_vld_g[1] & dtag_perr_en ;
// assign  dtag_parity_error[2] = 
//       lsu_rd_dtag_parity_g[2] & dva_vld_g[2] & dtag_perr_en ;
// assign  dtag_parity_error[3] = 
//       lsu_rd_dtag_parity_g[3] & dva_vld_g[3] & dtag_perr_en ;

    assign  dtag_parity_error[0] = 
          lsu_rd_dtag_parity_g[0] & dva_vld_g[0] & dtag_perr_en ;


    assign  dtag_parity_error[1] = 
          lsu_rd_dtag_parity_g[1] & dva_vld_g[1] & dtag_perr_en ;


    assign  dtag_parity_error[2] = 
          lsu_rd_dtag_parity_g[2] & dva_vld_g[2] & dtag_perr_en ;


    assign  dtag_parity_error[3] = 
          lsu_rd_dtag_parity_g[3] & dva_vld_g[3] & dtag_perr_en ;





assign  dtag_perror_g = |dtag_parity_error[`L1D_WAY_COUNT-1:0] ;
assign  lsu_dcache_tag_perror_g = 
  (|dtag_parity_error[`L1D_WAY_COUNT-1:0]) & ld_inst_vld_unflushed & lsu_inst_vld_w &
  // Correction pkt should not be generated to io.
  ~(tlb_pgnum[39] & (lsu_dtlb_bypass_g | (~lsu_dtlb_bypass_g & tlb_cam_hit_g))) ;
//  (|dtag_parity_error[3:0]) & ld_inst_vld_unflushed & lsu_inst_vld_w &
//  ~(lsu_alt_space_g & blk_asi_g) &  // Bug 3926. 
//  // Correction pkt should not be generated to io.
//  ~(tlb_pgnum[39] & (lsu_dtlb_bypass_g | (~lsu_dtlb_bypass_g & tlb_cam_hit_g))) &
//  ~atomic_g ; // Bug 4274,4297 
//=========================================================================================
//  Error Related Traps 
//=========================================================================================

//bug6382/eco6621   
dff_s #(2)  derrtrp_stgm (
        .din    ({lsu_cpx_ld_dtag_perror_e & ~ignore_fill, lsu_cpx_ld_dcache_perror_e & ~ignore_fill}),
        .q      ({dtag_error_m,dcache_error_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(2)  derrtrp_stgg (
        .din    ({dtag_error_m,dcache_error_m}),
        .q      ({dtag_error_g,dcache_error_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(2)  derrtrp_stgw2 (
        .din    ({dtag_error_g,dcache_error_g}),
        .q      ({dtag_error_w2,dcache_error_w2}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

assign  lsu_ifu_dcache_data_perror = dcache_error_w2 & ~bld_squash_err_w2;  //bug6382/eco6621
assign  lsu_ifu_dcache_tag_perror  = dtag_error_w2  ;

assign  l2_unc_error_e  = lsu_cpx_pkt_ld_err[1] & l2fill_vld_e & ~ignore_fill  ; // Bug 4998
assign  l2_corr_error_e = lsu_cpx_pkt_ld_err[0] & l2fill_vld_e & ~ignore_fill  ;

dff_s #(2)  lerrtrp_stgm (
        .din    ({l2_unc_error_e,l2_corr_error_e}),
        .q      ({l2_unc_error_m,l2_corr_error_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(2)  lerrtrp_stgg (
        .din    ({l2_unc_error_m,l2_corr_error_m}),
        .q      ({l2_unc_error_g,l2_corr_error_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(2)  lerrtrp_stgw2 (
        .din    ({l2_unc_error_g,l2_corr_error_g}),
        .q      ({l2_unc_error_w2,l2_corr_error_w2}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

assign  lsu_ifu_l2_unc_error  = // Bug 4315
(l2_unc_error_w2 | bld_unc_err_pend_w2) & ~lsu_ifu_err_addr_b39 & ~bld_squash_err_w2 ;
assign  lsu_ifu_l2_corr_error = 
(l2_corr_error_w2 | bld_corr_err_pend_w2) & ~bld_squash_err_w2 ;

wire	fill_err_trap_e ;

//assign  unc_err_trap_e = 
assign  fill_err_trap_e = 
  (lsu_cpx_pkt_ld_err[1] & l2fill_vld_e) ;
   /*(lsu_cpx_atm_st_err[1] & lsu_atm_st_cmplt_e)) & 
      ((dfill_thread0 & ifu_lsu_nceen[0]) |
       (dfill_thread1 & ifu_lsu_nceen[1]) |
       (dfill_thread2 & ifu_lsu_nceen[2]) |
       (dfill_thread3 & ifu_lsu_nceen[3])) ; */ // Bug 3624

assign	unc_err_trap_e = fill_err_trap_e ;

/*assign  corr_err_trap_e = 
  ((lsu_cpx_pkt_ld_err[0] | lsu_cpx_ld_dtag_perror_e | lsu_cpx_ld_dcache_perror_e) & 
   l2fill_vld_e) |
   (lsu_cpx_atm_st_err[0] & lsu_atm_st_cmplt_e)) & 
   & ~unc_err_trap_e &
      ((dfill_thread0 & ifu_lsu_ceen[0]) |
       (dfill_thread1 & ifu_lsu_ceen[1]) |
       (dfill_thread2 & ifu_lsu_ceen[2]) |
       (dfill_thread3 & ifu_lsu_ceen[3])) ; */


dff_s #(1)  errtrp_stgm (
        .din    ({unc_err_trap_e}),
        .q      ({unc_err_trap_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(1)  errtrp_stgg (
        .din    ({unc_err_trap_m}),
        .q      ({unc_err_trap_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

// The tlu should source demap_thrid for all tlb operations !!!
dff_s #(2)  filla_stgm (
        .din    ({lsu_dfill_tid_e[1:0]}),
        .q      ({dfill_tid_m[1:0]}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

dff_s #(2)  filla_stgg (
        .din    ({dfill_tid_m[1:0]}),
        .q      ({dfill_tid_g[1:0]}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 



//=========================================================================================
//  LSU to IRF Data Bypass Control
//=========================================================================================

assign	spu_trap =  spu_lsu_unc_error_w2 ;
assign	spu_trap0 = spu_trap & spu_ldxa_thread0_w2 ;
assign	spu_trap1 = spu_trap & spu_ldxa_thread1_w2 ;
assign	spu_trap2 = spu_trap & spu_ldxa_thread2_w2 ;
assign	spu_trap3 = spu_trap & spu_ldxa_thread3_w2 ;

assign	spu_ttype[6:0]	= spu_lsu_int_w2 ? 7'h70 : 7'h32 ;

dff_s #(2)   lfraw_stgw2 (
        .din    ({ld_inst_vld_g,fp_ldst_g}),
        .q      ({ld_inst_vld_w2,fp_ldst_w2}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dff_s #(2)   lfraw_stgw3 (
        .din    ({ld_stb_full_raw_w2, ld_inst_vld_w2}),
        .q      ({ld_stb_full_raw_w3, ld_inst_vld_w3}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

// Delay all ldbyp*vld_en by a cycle for write of unc error
//dff #(4)  lbypen_stgd1 (
//        .din    ({ldbyp0_vld_en,ldbyp1_vld_en,ldbyp2_vld_en,ldbyp3_vld_en}),
//        .q      ({ldbyp0_vld_en_d1,ldbyp1_vld_en_d1,ldbyp2_vld_en_d1,ldbyp3_vld_en_d1}),
//        .clk    (clk),
//        .se     (se),       .si (),          .so ()
//        ); 


wire   fp_ldst_thrd0_w2,fp_ldst_thrd1_w2,fp_ldst_thrd2_w2,fp_ldst_thrd3_w2 ;
wire   fp_ldst_thrd0_w3,fp_ldst_thrd1_w3,fp_ldst_thrd2_w3,fp_ldst_thrd3_w3 ;
wire   fp_ldst_thrd0_w4,fp_ldst_thrd1_w4,fp_ldst_thrd2_w4,fp_ldst_thrd3_w4 ;
wire   fp_ldst_thrd0_w5,fp_ldst_thrd1_w5,fp_ldst_thrd2_w5,fp_ldst_thrd3_w5 ;

//RAW read STB at W3 (changed from W2)
   
dff_s #(4) fp_ldst_stg_w3 (
  .din ({fp_ldst_thrd0_w2,fp_ldst_thrd1_w2,fp_ldst_thrd2_w2,fp_ldst_thrd3_w2}),
  .q   ({fp_ldst_thrd0_w3,fp_ldst_thrd1_w3,fp_ldst_thrd2_w3,fp_ldst_thrd3_w3}),
  .clk    (clk),
  .se     (se),       .si (),          .so ()
  );

dff_s #(4) fp_ldst_stg_w4 (
  .din ({fp_ldst_thrd0_w3,fp_ldst_thrd1_w3,fp_ldst_thrd2_w3,fp_ldst_thrd3_w3}),
  .q   ({fp_ldst_thrd0_w4,fp_ldst_thrd1_w4,fp_ldst_thrd2_w4,fp_ldst_thrd3_w4}),
  .clk    (clk),
  .se     (se),       .si (),          .so ()
  );

dff_s #(4) fp_ldst_stg_w5 (
  .din ({fp_ldst_thrd0_w4,fp_ldst_thrd1_w4,fp_ldst_thrd2_w4,fp_ldst_thrd3_w4}),
  .q   ({fp_ldst_thrd0_w5,fp_ldst_thrd1_w5,fp_ldst_thrd2_w5,fp_ldst_thrd3_w5}),
  .clk    (clk),
  .se     (se),       .si (),          .so ()
  );
   
// THREAD 0

wire	tte_data_perror_unc_w2,asi_tte_data_perror_w2,asi_tte_tag_perror_w2 ;
// if nceen/ceen=0, then tte_data_perror* are not logged for trap generation. Earlier error-reporting
// is however never screened off.
// asi_tte* however has to be logged in order to report errors thru the asiQ. Traps must be squashed. 
dff_s #(3) ltlbrd_w2 (
  .din ({tte_data_perror_unc_en,asi_tte_data_perror,asi_tte_tag_perror}),
  .q   ({tte_data_perror_unc_w2,asi_tte_data_perror_w2,asi_tte_tag_perror_w2}),
  .clk    (clk),
  .se     (se),       .si (),          .so ()
  );


// Error Table for Queue
// ** In all cases; squash writes to irf.
//				| Error Reporting	| Trap ?	| 
// ifu_lsu_asi_rd_unc		| NA;done by ifu	| daccess-error	|
// tte_data_perror_unc_w2	| sync;in pipe		| daccess-error	|
// tte_data_perror_corr_w2	| sync;in pipe		| dmmu-miss	| --> NA !! all unc.
// asi_tte_data_perror_w2	| async;out of Q	| daccess-error	|
// asi_tte_tag_perror_w2	| async;out of Q	| daccess-error	|

wire [3:0] tlb_err_en_w2 ; 
// used for xslate errors - enable queues
//assign	tlb_err_en_w2[0] = (tte_data_perror_unc_w2 | tte_data_perror_corr_w2) & thread0_w2 ;	
assign	tlb_err_en_w2[0] = tte_data_perror_unc_w2 & thread0_w2 ;	
assign	tlb_err_en_w2[1] = tte_data_perror_unc_w2 & thread1_w2 ;	
assign	tlb_err_en_w2[2] = tte_data_perror_unc_w2 & thread2_w2 ;	
assign	tlb_err_en_w2[3] = tte_data_perror_unc_w2 & thread3_w2 ;	

assign ldbyp0_vld_rst =
        (reset | (ld_thrd_byp_sel_e[0])) | 
	atm_st_cmplt0 ; // Bug 4048

// thread qualification required.
//assign ldbyp0_vld_en = (lmq_byp_data_en_w2[0] & 
//        ~(|lmq_byp_data_sel0[2:1]))  // do not set vld for cas/stdbl
//	| spu_trap0 ;

wire 		atm_ld_w_uerr ;
assign		atm_ld_w_uerr = l2fill_vld_e & lsu_cpx_pkt_atm_st_cmplt & lsu_cpx_pkt_ld_err[1] ;

//bug6525 notes
// spu ldxa and spu trap can async with the main pipe, and cause more than one ldbyp*_vld_en asserted 
// at the same cycle   
assign ldbyp0_vld_en = lmq_byp_data_raw_sel_d2[0] |                  //ld hit stb RAW bypass
                       lmq_byp_data_sel0[3]       |                  //ldxa (ifu, spu*, lsu)
		       (atm_ld_w_uerr & lsu_nceen_d1[0] & dfill_thread0) |       //atomic
                       lmq_byp_data_fmx_sel[0]    |                  //tlu ldxa
		       tlb_err_en_w2[0]	  |                                      //tlb parity err
                       spu_trap0 ;                                   //spu trap*
                  
assign   fp_ldst_thrd0_w2 = fp_ldst_w2 & thread0_w2 & ld_inst_vld_w2 ;
   
// ld valid
wire	ldbyp0_vld_tmp ;
dffre_s #(1)  ldbyp0_vld_ff (
        .din    (ldbyp0_vld_en),
        .q      (ldbyp0_vld_tmp),
        .rst    (ldbyp0_vld_rst),        .en     (ldbyp0_vld_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              
// Bug 5379 - make ld ue invisible in q until atm st ack resets.

assign	ldbyp0_vld = ldbyp0_vld_tmp & ~pend_atm_ld_ue[0] ;


// assumes that rw_index is not reset at mmu.
wire [6:0]	misc_data_in ;
wire [6:0]	misc_data0,misc_data1,misc_data2,misc_data3 ;
wire		misc_sel ;
wire [5:0]	rw_index_d1 ;
dff_s #(6)  rwind_d1 (
        .din    (tlu_dtlb_rw_index_g[5:0]),
        .q      (rw_index_d1[5:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              
assign	misc_sel = asi_tte_data_perror_w2 | asi_tte_tag_perror_w2 ;
assign	misc_data_in[6:0] = misc_sel ? {1'b0,rw_index_d1[5:0]} : spu_ttype[6:0] ; 

dffe_s #(9)  ldbyp0_other_ff (
        .din    ({fp_ldst_thrd0_w5,spu_trap0,misc_data_in[6:0]}),  //bug6525 fix2
        .q      ({ldbyp0_fpld,spubyp0_trap,misc_data0[6:0]}),
        .en     (ldbyp0_vld_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              


dffre_s #(5)  ldbyp0_err_ff (
  	.din   	({tte_data_perror_unc_w2,atm_ld_w_uerr,
		asi_tte_data_perror_w2,asi_tte_tag_perror_w2,ifu_lsu_asi_rd_unc}),
	.q	({cam_perr_unc0,pend_atm_ld_ue[0],asi_data_perr0,asi_tag_perr0,
		ifu_unc_err0}),
        .rst    (ldbyp0_vld_rst), .en     (ldbyp0_vld_en & ~spu_trap0 & ~lmq_byp_ldxa_sel0[1]), //bug6525 fix2
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              


//assign  ldbyp0_unc_err = ldbyp0_unc_err_q & ifu_lsu_nceen[0] ;

// THREAD 1

assign ldbyp1_vld_rst =
        (reset | (ld_thrd_byp_sel_e[1])) |
	atm_st_cmplt1 ; // Bug 4048

assign   fp_ldst_thrd1_w2 = fp_ldst_w2 & thread1_w2 & ld_inst_vld_w2 ;

// thread qualification required.
//assign ldbyp1_vld_en = (lmq_byp_data_en_w2[1] &
//        ~(|lmq_byp_data_sel1[2:1])) | // do not set vld for cas/stdbl
//	| spu_trap1 ;

assign ldbyp1_vld_en = lmq_byp_data_raw_sel_d2[1] |
                       lmq_byp_data_sel1[3]       |
		       (atm_ld_w_uerr & lsu_nceen_d1[1] & dfill_thread1) |
                       lmq_byp_data_fmx_sel[1]    |
		       tlb_err_en_w2[1]	  |
                       spu_trap1 ;
   
// ld valid
wire	ldbyp1_vld_tmp ;
dffre_s #(1)  ldbyp1_vld_ff (
        .din    (ldbyp1_vld_en),
        .q      (ldbyp1_vld_tmp),
        .rst    (ldbyp1_vld_rst),        .en     (ldbyp1_vld_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              
assign	ldbyp1_vld = ldbyp1_vld_tmp & ~pend_atm_ld_ue[1] ;


dffe_s #(9)  ldbyp1_other_ff (
        .din    ({fp_ldst_thrd1_w5,spu_trap1,misc_data_in[6:0]}),  //bug6525 fix2
        .q      ({ldbyp1_fpld,spubyp1_trap,misc_data1[6:0]}),
        .en     (ldbyp1_vld_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

// The tlb rd unc errors are delayed a cycle wrt to ldxa_data
// No reset required
dffre_s #(5)  ldbyp1_err_ff (
  	.din   	({tte_data_perror_unc_w2,atm_ld_w_uerr,
		asi_tte_data_perror_w2,asi_tte_tag_perror_w2,ifu_lsu_asi_rd_unc}),
	.q	({cam_perr_unc1,pend_atm_ld_ue[1],asi_data_perr1,asi_tag_perr1,
		ifu_unc_err1}),
        .rst    (ldbyp1_vld_rst), .en     (ldbyp1_vld_en & ~spu_trap1 & ~lmq_byp_ldxa_sel1[1]), //bug6525 fix2
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

//assign  ldbyp1_unc_err = ldbyp1_unc_err_q & ifu_lsu_nceen[1] ;

// THREAD 2

assign ldbyp2_vld_rst =
        (reset | (ld_thrd_byp_sel_e[2])) |
	atm_st_cmplt2 ; // Bug 4048

// thread qualification required.
//assign ldbyp2_vld_en = (lmq_byp_data_en_w2[2] &
//        ~(|lmq_byp_data_sel2[2:1])) | // do not set vld for cas/stdbl
//	spu_trap2 ;

assign ldbyp2_vld_en = lmq_byp_data_raw_sel_d2[2] |
                       lmq_byp_data_sel2[3]       |
		       (atm_ld_w_uerr & lsu_nceen_d1[2] & dfill_thread2) |
                       lmq_byp_data_fmx_sel[2]    |
		       tlb_err_en_w2[2]	  |
                       spu_trap2 ;

assign   fp_ldst_thrd2_w2 = fp_ldst_w2 & thread2_w2 & ld_inst_vld_w2 ;

// ld valid
wire	ldbyp2_vld_tmp ;
dffre_s #(1)  ldbyp2_vld_ff (
        .din    (ldbyp2_vld_en),
        .q      (ldbyp2_vld_tmp),
        .rst    (ldbyp2_vld_rst),        .en     (ldbyp2_vld_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              
assign	ldbyp2_vld = ldbyp2_vld_tmp & ~pend_atm_ld_ue[2] ;

dffe_s #(9)  ldbyp2_other_ff (
        .din    ({fp_ldst_thrd2_w5,spu_trap2,misc_data_in[6:0]}),  //bug6525 fix2
        .q      ({ldbyp2_fpld,spubyp2_trap,misc_data2[6:0]}),
        .en     (ldbyp2_vld_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

dffre_s #(5)  ldbyp2_err_ff (
  	.din   	({tte_data_perror_unc_w2, atm_ld_w_uerr,
		asi_tte_data_perror_w2,asi_tte_tag_perror_w2,ifu_lsu_asi_rd_unc}),
	.q	({cam_perr_unc2,pend_atm_ld_ue[2],asi_data_perr2,asi_tag_perr2,
		ifu_unc_err2}),
        .rst    (ldbyp2_vld_rst), .en     (ldbyp2_vld_en & ~spu_trap2 & ~lmq_byp_ldxa_sel2[1]), //bug6525 fix2
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

//assign  ldbyp2_unc_err = ldbyp2_unc_err_q & ifu_lsu_nceen[2] ;

// THREAD 3

assign ldbyp3_vld_rst =
        (reset | (ld_thrd_byp_sel_e[3])) |
	atm_st_cmplt3 ; // Bug 4048

// thread qualification required.
//assign ldbyp3_vld_en = (lmq_byp_data_en_w2[3] &
//        ~(|lmq_byp_data_sel3[2:1])) | // do not set vld for cas/stdbl
//	| spu_trap3 ;

assign ldbyp3_vld_en = lmq_byp_data_raw_sel_d2[3] |
                       lmq_byp_data_sel3[3]       |
		       (atm_ld_w_uerr & lsu_nceen_d1[3] & dfill_thread3) |
                       lmq_byp_data_fmx_sel[3]    |
		       tlb_err_en_w2[3]	  |
                       spu_trap3 ;

assign   fp_ldst_thrd3_w2 = fp_ldst_w2 & thread3_w2 & ld_inst_vld_w2 ;

// ld valid
wire	ldbyp3_vld_tmp ;
dffre_s #(1)  ldbyp3_vld_ff (
        .din    (ldbyp3_vld_en),
        .q      (ldbyp3_vld_tmp),
        .rst    (ldbyp3_vld_rst),        .en     (ldbyp3_vld_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
assign	ldbyp3_vld = ldbyp3_vld_tmp & ~pend_atm_ld_ue[3] ;


dffe_s #(9)  ldbyp3_other_ff (
        .din    ({fp_ldst_thrd3_w5,spu_trap3,misc_data_in[6:0]}),  //bug6525 fix2
        .q      ({ldbyp3_fpld,spubyp3_trap,misc_data3[6:0]}),
        .en     (ldbyp3_vld_en),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

dffre_s #(5)  ldbyp3_err_ff (
  	.din   	({tte_data_perror_unc_w2,atm_ld_w_uerr,
		asi_tte_data_perror_w2,asi_tte_tag_perror_w2,ifu_lsu_asi_rd_unc}),
	.q	({cam_perr_unc3,pend_atm_ld_ue[3],asi_data_perr3,asi_tag_perr3,
		ifu_unc_err3}),
        .rst    (ldbyp3_vld_rst), .en     (ldbyp3_vld_en & ~spu_trap3 & ~lmq_byp_ldxa_sel3[1]), //bug6525 fix2
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

//assign  ldbyp3_unc_err = ldbyp3_unc_err_q & ifu_lsu_nceen[3] ;

//assign  ld_any_byp_data_vld = 
//  ldbyp0_vld | ldbyp1_vld | ldbyp2_vld | ldbyp3_vld ;

dff_s #(4)   stgm_sqshcmplt (
        .din    (squash_byp_cmplt[3:0]),
        .q      (squash_byp_cmplt_m[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(4)  stgg_sqshcmplt (
        .din    (squash_byp_cmplt_m[3:0]),
        .q      (squash_byp_cmplt_g[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

assign  fpld_byp_data_vld = 
  (ld_thrd_byp_sel_g[0] & ldbyp0_fpld & ~squash_byp_cmplt_g[0]) | // Bug 4998
  (ld_thrd_byp_sel_g[1] & ldbyp1_fpld & ~squash_byp_cmplt_g[1]) |
  (ld_thrd_byp_sel_g[2] & ldbyp2_fpld & ~squash_byp_cmplt_g[2]) |
  (ld_thrd_byp_sel_g[3] & ldbyp3_fpld & ~squash_byp_cmplt_g[3]) ;

//assign  intld_byp_data_vld = |intld_byp_cmplt[3:0] ;
// squash for spu-trap situation.
assign  intld_byp_data_vld_e = 
	//(intld_byp_cmplt[0] & ~spubyp0_trap) |
	(intld_byp_cmplt[0]) | // squash now thru squash_byp_cmplt
	(intld_byp_cmplt[1]) |
	(intld_byp_cmplt[2]) |
	(intld_byp_cmplt[3]) ;

dff_s   stgm_ibvld (
        .din    (intld_byp_data_vld_e),
        .q      (intld_byp_data_vld_m),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

// to be removed - intld_byp_data_vld in lsu_mon.v
/*
dff_s   stgg_ibvld (
        .din    (intld_byp_data_vld_m),
        .q      (intld_byp_data_vld),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 
*/
assign	spubyp_trap_active_e =
	//(intld_byp_cmplt[0] & spubyp0_trap) | // Bug 4040
	(ld_thrd_byp_sel_e[0] & spubyp0_trap) |
	(ld_thrd_byp_sel_e[1] & spubyp1_trap) |
	(ld_thrd_byp_sel_e[2] & spubyp2_trap) |
	(ld_thrd_byp_sel_e[3] & spubyp3_trap) ;

dff_s   stgm_strmtrp (
        .din    (spubyp_trap_active_e),
        .q      (spubyp_trap_active_m),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s   stgg_strmtrp (
        .din    (spubyp_trap_active_m),
        .q      (spubyp_trap_active_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

assign	spubyp0_ttype[6:0] = misc_data0[6:0] ;
assign	spubyp1_ttype[6:0] = misc_data1[6:0] ;
assign	spubyp2_ttype[6:0] = misc_data2[6:0] ;
assign	spubyp3_ttype[6:0] = misc_data3[6:0] ;

mux4ds #(7) mux_spubyp_ttype (
        .in0(spubyp0_ttype[6:0]),
        .in1(spubyp1_ttype[6:0]),
        .in2(spubyp2_ttype[6:0]),
        .in3(spubyp3_ttype[6:0]),
        .sel0(ld_thrd_byp_mxsel_m[0]),
        .sel1(ld_thrd_byp_mxsel_m[1]),
        .sel2(ld_thrd_byp_mxsel_m[2]),
        .sel3(ld_thrd_byp_mxsel_m[3]),
        .dout(spubyp_ttype[6:0])
);               
              
assign  intld_byp_cmplt[0] = (ld_thrd_byp_sel_e[0] & ~(ldbyp0_fpld | squash_byp_cmplt[0])) ;
assign  intld_byp_cmplt[1] = (ld_thrd_byp_sel_e[1] & ~(ldbyp1_fpld | squash_byp_cmplt[1])) ;
assign  intld_byp_cmplt[2] = (ld_thrd_byp_sel_e[2] & ~(ldbyp2_fpld | squash_byp_cmplt[2])) ;
assign  intld_byp_cmplt[3] = (ld_thrd_byp_sel_e[3] & ~(ldbyp3_fpld | squash_byp_cmplt[3])) ;

dff_s #(2)  stgm_l2fv (
        .din    ({l2fill_vld_e,lsu_l2fill_fpld_e}),
        .q      ({l2fill_vld_m,l2fill_fpld_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(2) stgg_l2fv (
        .din    ({l2fill_vld_m,l2fill_fpld_m}),
        .q      ({l2fill_vld_g,l2fill_fpld_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

// write to irf will need to be postphoned by a few cycles. 
// may wish to find more bubbles by counting misses !!!
//assign  lsu_irf_byp_data_src[0]  =      ld_inst_vld_unflushed ;
//assign  lsu_irf_byp_data_src[1]  =    l2fill_vld_g ;
//assign  lsu_irf_byp_data_src[2]  =    
//  ~l2fill_vld_g    &      // no dfq fill
//  ~ld_inst_vld_unflushed ;  // no ld/st in pipe.

  //~(ld_inst_vld_unflushed | st_inst_vld_unflushed) ;  // no ld/st in pipe.
   // Timing Change.
   //ld_any_byp_data_vld ;      // full raw bypasses data


// Store to load full raw bypassing. Plus ldxa data bypassing.
// ldxa-data may be bypassed asap if port available.
// ldxa/stb raw and atomics assumed to be mutually exclusive.

wire int_ldxa_vld ;
assign int_ldxa_vld = tlu_lsu_int_ldxa_vld_w2 & ~tlu_lsu_int_ld_ill_va_w2 ;
assign	lmq_byp_data_fmx_sel[0] = (int_ldxa_vld | cfg_asi_lsu_ldxa_vld_w2) & thread0_w2 ;
assign	lmq_byp_data_fmx_sel[1] = (int_ldxa_vld | cfg_asi_lsu_ldxa_vld_w2) & thread1_w2 ;
assign	lmq_byp_data_fmx_sel[2] = (int_ldxa_vld | cfg_asi_lsu_ldxa_vld_w2) & thread2_w2 ;
assign	lmq_byp_data_fmx_sel[3] = (int_ldxa_vld | cfg_asi_lsu_ldxa_vld_w2) & thread3_w2 ;

assign lmq_byp_data_en_w2[0] =  (|lmq_byp_data_sel0[3:0]) | lmq_byp_data_fmx_sel[0] ;
assign lmq_byp_data_en_w2[1] =  (|lmq_byp_data_sel1[3:0]) | lmq_byp_data_fmx_sel[1] ;
assign lmq_byp_data_en_w2[2] =  (|lmq_byp_data_sel2[3:0]) | lmq_byp_data_fmx_sel[2] ;
assign lmq_byp_data_en_w2[3] =  (|lmq_byp_data_sel3[3:0]) | lmq_byp_data_fmx_sel[3] ;

/*
assign  stq_pkt2_data_en[0] = 
  st_inst_vld_g & ldst_dbl_g & quad_asi_g & thread0_g ;
assign  stq_pkt2_data_en[1] = 
  st_inst_vld_g & ldst_dbl_g & quad_asi_g & thread1_g ;
assign  stq_pkt2_data_en[2] = 
  st_inst_vld_g & ldst_dbl_g & quad_asi_g & thread2_g ;
assign  stq_pkt2_data_en[3] = 
  st_inst_vld_g & ldst_dbl_g & quad_asi_g & thread3_g ;
*/
   
// casxa to be decoded as doubleword.
// casa to be decoded as word.
// ldstuba to be decoded as byte.
// casa, casxa and ldstuba needed to be decoded as alternate space insts with optional
// imm_asi use.
// An atomic will switch out a thread.


wire  ifu_ldxa_vld,  spu_ldxa_vld ;
assign  ifu_ldxa_vld = ifu_lsu_ldxa_data_vld_w2 & ~ifu_lsu_ldxa_illgl_va_w2 ;
//assign  tlu_ldxa_vld = tlu_lsu_ldxa_data_vld_w2 & ~tlu_lsu_ldxa_illgl_va_w2 ;
assign  spu_ldxa_vld = spu_lsu_ldxa_data_vld_w2 & ~spu_lsu_ldxa_illgl_va_w2 ; 

wire int_ldxa_ivld ;
assign int_ldxa_ivld = tlu_lsu_int_ldxa_vld_w2 & tlu_lsu_int_ld_ill_va_w2 ;
// ldxa data returns need to cmplt thread without writing to register file
assign  ldxa_illgl_va_cmplt[0] =
  ((ifu_lsu_ldxa_data_vld_w2 & ifu_lsu_ldxa_illgl_va_w2) & ifu_ldxa_thread0_w2) |
  //((tlu_lsu_ldxa_data_vld_w2 & tlu_lsu_ldxa_illgl_va_w2) & tlu_ldxa_thread0_w2) |
  ((spu_lsu_ldxa_data_vld_w2 & spu_lsu_ldxa_illgl_va_w2) & spu_ldxa_thread0_w2) |
  (int_ldxa_ivld & thread0_w2) |
  lsu_asi_illgl_va_cmplt_w2[0] ; 
assign  ldxa_illgl_va_cmplt[1] =
  ((ifu_lsu_ldxa_data_vld_w2 & ifu_lsu_ldxa_illgl_va_w2) & ifu_ldxa_thread1_w2) |
  //((tlu_lsu_ldxa_data_vld_w2 & tlu_lsu_ldxa_illgl_va_w2) & tlu_ldxa_thread1_w2) |
  ((spu_lsu_ldxa_data_vld_w2 & spu_lsu_ldxa_illgl_va_w2) & spu_ldxa_thread1_w2) |
  (int_ldxa_ivld & thread1_w2) |
  lsu_asi_illgl_va_cmplt_w2[1] ; 
assign  ldxa_illgl_va_cmplt[2] =
  ((ifu_lsu_ldxa_data_vld_w2 & ifu_lsu_ldxa_illgl_va_w2) & ifu_ldxa_thread2_w2) |
  //((tlu_lsu_ldxa_data_vld_w2 & tlu_lsu_ldxa_illgl_va_w2) & tlu_ldxa_thread2_w2) |
  ((spu_lsu_ldxa_data_vld_w2 & spu_lsu_ldxa_illgl_va_w2) & spu_ldxa_thread2_w2) |
  (int_ldxa_ivld & thread2_w2) |
  lsu_asi_illgl_va_cmplt_w2[2] ; 
assign  ldxa_illgl_va_cmplt[3] =
  ((ifu_lsu_ldxa_data_vld_w2 & ifu_lsu_ldxa_illgl_va_w2) & ifu_ldxa_thread3_w2) |
  //((tlu_lsu_ldxa_data_vld_w2 & tlu_lsu_ldxa_illgl_va_w2) & tlu_ldxa_thread3_w2) |
  ((spu_lsu_ldxa_data_vld_w2 & spu_lsu_ldxa_illgl_va_w2) & spu_ldxa_thread3_w2) |
  (int_ldxa_ivld & thread3_w2) |
  lsu_asi_illgl_va_cmplt_w2[3] ; 

dff_s #(4)  illglva_cmplt_d1 (
        .din    (ldxa_illgl_va_cmplt[3:0]),
        .q      (ldxa_illgl_va_cmplt_d1[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

// Thread0
// Should be able to remove thread qualification for full-raw.
// Could have and e stage store and w2 stage stb rd in same cycle !!! Qualify select3
// with select0 to give the earlier event priority. 
assign  lmq_byp_ldxa_sel0[0] = ifu_ldxa_vld & ifu_ldxa_thread0_w2 ; 
//assign  lmq_byp_ldxa_sel0[1] = tlu_ldxa_vld & tlu_ldxa_thread0_w2 ; 
assign  lmq_byp_ldxa_sel0[1] = spu_ldxa_vld & spu_ldxa_thread0_w2 ; 
assign  lmq_byp_ldxa_sel0[2] = (lsu_asi_rd_en_w2 & thread0_w2) | ldxa_tlbrd0_w3 ;

wire	fraw_annul0,fraw_annul1,fraw_annul2,fraw_annul3 ;
wire	ldst_miss0,ldst_miss1,ldst_miss2,ldst_miss3 ;

//RAW read STB at W3 (not W2)
//   E M W        W2 W3                      w4
//LD     cam_hit     RD STB, flop in byp FFs
//inst+1 D        E  
//inst+2          D  E                            <= squash (stxa) rs3_e to write into byp FFs
//  
assign	fraw_annul0 = ld_stb_full_raw_w3 & thread0_w3 & ld_inst_vld_w3;
assign	fraw_annul1 = ld_stb_full_raw_w3 & thread1_w3 & ld_inst_vld_w3;
assign	fraw_annul2 = ld_stb_full_raw_w3 & thread2_w3 & ld_inst_vld_w3;
assign	fraw_annul3 = ld_stb_full_raw_w3 & thread3_w3 & ld_inst_vld_w3;

assign	ldst_miss0 = lsu_ldst_miss_w2 & thread0_w2 ;
assign	ldst_miss1 = lsu_ldst_miss_w2 & thread1_w2 ;
assign	ldst_miss2 = lsu_ldst_miss_w2 & thread2_w2 ;
assign	ldst_miss3 = lsu_ldst_miss_w2 & thread3_w2 ;

wire	fraw_annul0_d1,fraw_annul1_d1,fraw_annul2_d1,fraw_annul3_d1 ;
wire	ldst_miss0_d1,ldst_miss1_d1,ldst_miss2_d1,ldst_miss3_d1 ;

dff_s #(4)  fraw_d1 (
        .din    ({fraw_annul3,fraw_annul2,fraw_annul1,fraw_annul0}),
        .q      ({fraw_annul3_d1,fraw_annul2_d1,fraw_annul1_d1,fraw_annul0_d1}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(4)  ldstm_d1 (
        .din    ({ldst_miss3,ldst_miss2,ldst_miss1,ldst_miss0}),
        .q      ({ldst_miss3_d1,ldst_miss2_d1,ldst_miss1_d1,ldst_miss0_d1}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

//wire	memref_d ;
//assign	memref_d = ifu_lsu_memref_d ;
/*wire	mref_vld0,mref_vld1,mref_vld2,mref_vld3;
wire	mref_vld0_d1,mref_vld1_d1,mref_vld2_d1,mref_vld3_d1;

// Bug 3053 - prevent overwrite of ldxa data with subsequent st-data
assign	mref_vld0 = (memref_d | memref_e) & ~(lsu_ldst_miss_w2 & thread0_w2) ;
assign	mref_vld1 = (memref_d | memref_e) & ~(lsu_ldst_miss_w2 & thread1_w2) ;
assign	mref_vld2 = (memref_d | memref_e) & ~(lsu_ldst_miss_w2 & thread2_w2) ;
assign	mref_vld3 = (memref_d | memref_e) & ~(lsu_ldst_miss_w2 & thread3_w2) ;

dff_s #(4)  mrefv_d1 (
        .din    ({mref_vld3,mref_vld2,mref_vld1,mref_vld0}),
        .q      ({mref_vld3_d1,mref_vld2_d1,mref_vld1_d1,mref_vld0_d1}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  */

//RAW timing change   
assign  lmq_byp_data_sel0[0] = ld_stb_full_raw_w3 & ~(ldd_force_l2access_w3 | atomic_w3 | dtlb_perror_en_w3)  & thread0_w3 & ld_inst_vld_w3 ;  
//assign  lmq_byp_data_sel0[1] = st_inst_vld_e & thread0_e & ~ifu_lsu_casa_e & ~fraw_annul0 ;
// Timing fix - at most ld will also update the bypass buffer also.
//assign  lmq_byp_data_sel0[1] = memref_e & thread0_e & ~ifu_lsu_casa_e & ~fraw_annul0 ; //bug3009
assign  lmq_byp_data_sel0[1] =  ~lmq_byp_data_sel0[0] & memref_e & thread0_e & ~ifu_lsu_casa_e & 
			~(fraw_annul0 | fraw_annul0_d1 | ldst_miss0 | ldst_miss0_d1); // Bug 3053,3180
//assign  lmq_byp_data_sel0[1] = mref_vld0_d1 & thread0_e & ~ifu_lsu_casa_e & ~(fraw_annul0 | fraw_annul0_d1); // Bug 3053
//assign  lmq_byp_data_sel0[1] = memref_e & thread0_e & ~ifu_lsu_casa_e & ~(fraw_annul0 | fraw_annul0_d1);
assign  lmq_byp_data_sel0[2] = ~(|lmq_byp_data_sel0[1:0]) & casa_g & thread0_g & lsu_inst_vld_w & ~fraw_annul0_d1 ;
assign  lmq_byp_data_sel0[3] = |lmq_byp_ldxa_sel0[2:0];
//assign  lmq_byp_data_sel0[3] = |lmq_byp_ldxa_sel0[3:0];
   
// Thread1
assign  lmq_byp_ldxa_sel1[0] = ifu_ldxa_vld & ifu_ldxa_thread1_w2 ; 
//assign  lmq_byp_ldxa_sel1[1] = tlu_ldxa_vld & tlu_ldxa_thread1_w2 ; 
assign  lmq_byp_ldxa_sel1[1] = spu_ldxa_vld & spu_ldxa_thread1_w2 ; 
assign  lmq_byp_ldxa_sel1[2] = (lsu_asi_rd_en_w2 & thread1_w2) | ldxa_tlbrd1_w3 ;

assign  lmq_byp_data_sel1[0] = ld_stb_full_raw_w3 & ~(ldd_force_l2access_w3 | atomic_w3 | dtlb_perror_en_w3) & ld_inst_vld_w3 & thread1_w3 ;   
assign  lmq_byp_data_sel1[1] = ~lmq_byp_data_sel1[0] & memref_e & thread1_e & ~ifu_lsu_casa_e & 
			~(fraw_annul1 | fraw_annul1_d1 | ldst_miss1 | ldst_miss1_d1); // Bug 3053,3180
//assign  lmq_byp_data_sel1[1] = memref_e & thread1_e & ~ifu_lsu_casa_e & ~fraw_annul1; // bug3009
//assign  lmq_byp_data_sel1[1] = mref_vld1_d1 & thread1_e & ~ifu_lsu_casa_e & ~(fraw_annul1 | fraw_annul1_d1);
//assign  lmq_byp_data_sel1[1] = memref_e & thread1_e & ~ifu_lsu_casa_e & ~(fraw_annul1 | fraw_annul1_d1); // Bug 3053
assign  lmq_byp_data_sel1[2] =  ~(|lmq_byp_data_sel1[1:0]) & casa_g & thread1_g & lsu_inst_vld_w & ~fraw_annul1_d1 ;
assign  lmq_byp_data_sel1[3] = |lmq_byp_ldxa_sel1[2:0];

// Thread2
assign  lmq_byp_ldxa_sel2[0] = ifu_ldxa_vld & ifu_ldxa_thread2_w2 ; 
//assign  lmq_byp_ldxa_sel2[1] = tlu_ldxa_vld & tlu_ldxa_thread2_w2 ; 
assign  lmq_byp_ldxa_sel2[1] = spu_ldxa_vld & spu_ldxa_thread2_w2 ; 
assign  lmq_byp_ldxa_sel2[2] = (lsu_asi_rd_en_w2 & thread2_w2) | ldxa_tlbrd2_w3 ;

assign  lmq_byp_data_sel2[0] = ld_stb_full_raw_w3 & ~(ldd_force_l2access_w3 | atomic_w3 | dtlb_perror_en_w3) & ld_inst_vld_w3 & thread2_w3 ;   
//assign  lmq_byp_data_sel2[1] = memref_e & thread2_e & ~ifu_lsu_casa_e & ~fraw_annul2; // bug3009
assign  lmq_byp_data_sel2[1] = ~lmq_byp_data_sel2[0] & memref_e & thread2_e & ~ifu_lsu_casa_e & 
			~(fraw_annul2 | fraw_annul2_d1 | ldst_miss2 | ldst_miss2_d1); // Bug 3053,3180
//assign  lmq_byp_data_sel2[1] = memref_e & thread2_e & ~ifu_lsu_casa_e & ~(fraw_annul2 | fraw_annul2_d1); // Bug 3053
assign  lmq_byp_data_sel2[2] =  ~(|lmq_byp_data_sel2[1:0]) & casa_g & thread2_g & lsu_inst_vld_w & ~fraw_annul2_d1 ;
assign  lmq_byp_data_sel2[3] = |lmq_byp_ldxa_sel2[2:0];

// Thread3
assign  lmq_byp_ldxa_sel3[0] = ifu_ldxa_vld & ifu_ldxa_thread3_w2 ; 
//assign  lmq_byp_ldxa_sel3[1] = tlu_ldxa_vld & tlu_ldxa_thread3_w2 ; 
assign  lmq_byp_ldxa_sel3[1] = spu_ldxa_vld & spu_ldxa_thread3_w2 ; 
assign  lmq_byp_ldxa_sel3[2] =  (lsu_asi_rd_en_w2 & thread3_w2) | ldxa_tlbrd3_w3 ;

assign  lmq_byp_data_sel3[0] = ld_stb_full_raw_w3 & ~(ldd_force_l2access_w3 | atomic_w3 | dtlb_perror_en_w3) & ld_inst_vld_w3 & thread3_w3 ;   
assign  lmq_byp_data_sel3[1] = ~lmq_byp_data_sel3[0] & memref_e & thread3_e & ~ifu_lsu_casa_e & 
			~(fraw_annul3 | fraw_annul3_d1 | ldst_miss3 | ldst_miss3_d1); // Bug 3053,3180
//assign  lmq_byp_data_sel3[1] = memref_e & thread3_e & ~ifu_lsu_casa_e & ~(fraw_annul3 | fraw_annul3_d1); // Bug 3053
assign  lmq_byp_data_sel3[2] = ~(|lmq_byp_data_sel3[1:0]) & casa_g & thread3_g & lsu_inst_vld_w & ~fraw_annul3_d1 ;
assign  lmq_byp_data_sel3[3] = |lmq_byp_ldxa_sel3[2:0];


dff_s #(4)  ff_lmq_byp_data_raw_sel_d1 (
        .din    ({lmq_byp_data_sel3[0], lmq_byp_data_sel2[0],
                  lmq_byp_data_sel1[0], lmq_byp_data_sel0[0]}),
        .q      (lmq_byp_data_raw_sel_d1[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(4)  ff_lmq_byp_data_raw_sel_d2 (
        .din    (lmq_byp_data_raw_sel_d1[3:0]),
        .q      (lmq_byp_data_raw_sel_d2[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  
   
wire 		lsu_irf_raw_byp_e;   
// Includes both ldxa and raw bypass. 
assign  lsu_irf_raw_byp_e  =    
  ~l2fill_vld_e    &      // no dfq fill
  ~(memref_e) ; // no ld/st in pipe. 
  //~(ld_inst_vld_e | st_inst_vld_e) ; // no ld/st in pipe. 

// bug 5379 plus misc (randomize selection to prevent deadlock.
wire [3:0] bypass_sel ;
assign	bypass_sel[0] = lsu_dcache_rand[0] ? 
	ldbyp0_vld : (ldbyp0_vld & ~(ldbyp3_vld | ldbyp2_vld | ldbyp1_vld)) ; 
assign	bypass_sel[1] = lsu_dcache_rand[0] ? 
	(ldbyp1_vld & ~ldbyp0_vld) : (ldbyp1_vld & ~(ldbyp3_vld | ldbyp2_vld)) ; 
assign	bypass_sel[2] = lsu_dcache_rand[0] ? 
	(ldbyp2_vld & ~(ldbyp0_vld | ldbyp1_vld)) : (ldbyp2_vld & ~ldbyp3_vld) ; 
assign	bypass_sel[3] = lsu_dcache_rand[0] ? 
	(ldbyp3_vld & ~(ldbyp0_vld | ldbyp1_vld | ldbyp2_vld)) : ldbyp3_vld ; 
  
assign ld_thrd_byp_sel_e[0] = bypass_sel[0] & lsu_irf_raw_byp_e ;
assign ld_thrd_byp_sel_e[1] = bypass_sel[1] & lsu_irf_raw_byp_e ;
assign ld_thrd_byp_sel_e[2] = bypass_sel[2] & lsu_irf_raw_byp_e ;
assign ld_thrd_byp_sel_e[3] = bypass_sel[3] & lsu_irf_raw_byp_e ;

/*assign ld_thrd_byp_sel_e[0] = ldbyp0_vld & lsu_irf_raw_byp_e ;
assign ld_thrd_byp_sel_e[1] = ldbyp1_vld & lsu_irf_raw_byp_e &
      ~ldbyp0_vld ;                                     
assign ld_thrd_byp_sel_e[2] = ldbyp2_vld & lsu_irf_raw_byp_e &
      ~(ldbyp0_vld | ldbyp1_vld);                       
assign ld_thrd_byp_sel_e[3] = ldbyp3_vld & lsu_irf_raw_byp_e &
      ~(ldbyp0_vld | ldbyp1_vld | ldbyp2_vld) ; */

   
   //assign lsu_ld_thrd_byp_sel_e[2:0] = ld_thrd_byp_sel_e[2:0];
    bw_u1_buf_30x UZsize_lsu_ld_thrd_byp_sel_e_b2 (.a(ld_thrd_byp_sel_e[2]), .z(lsu_ld_thrd_byp_sel_e[2]));  
    bw_u1_buf_30x UZsize_lsu_ld_thrd_byp_sel_e_b1 (.a(ld_thrd_byp_sel_e[1]), .z(lsu_ld_thrd_byp_sel_e[1]));  
    bw_u1_buf_30x UZsize_lsu_ld_thrd_byp_sel_e_b0 (.a(ld_thrd_byp_sel_e[0]), .z(lsu_ld_thrd_byp_sel_e[0]));  
   
dff_s #(4)  tbyp_stgd1 (
        .din    (ld_thrd_byp_sel_e[3:0]),
        .q      (ld_thrd_byp_sel_m[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

//assign ld_thrd_byp_mxsel_m[2:0]  =    ld_thrd_byp_sel_m[2:0];
//assign ld_thrd_byp_mxsel_m[3]    =  ~|ld_thrd_byp_sel_m[2:0];

assign ld_thrd_byp_mxsel_m[0]  =    ld_thrd_byp_sel_m[0] & ~rst_tri_en;
assign ld_thrd_byp_mxsel_m[1]  =    ld_thrd_byp_sel_m[1] & ~rst_tri_en;
assign ld_thrd_byp_mxsel_m[2]  =    ld_thrd_byp_sel_m[2] & ~rst_tri_en;
assign ld_thrd_byp_mxsel_m[3]  =    (~|ld_thrd_byp_sel_m[2:0]) |  rst_tri_en;
   
dff_s #(4)  tbyp_stgd2 (
        .din    (ld_thrd_byp_sel_m[3:0]),
        .q      (ld_thrd_byp_sel_g[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

  //should move to M stage 
   
//assign ld_thrd_byp_mxsel_g[2:0]  =    ld_thrd_byp_sel_g[2:0];
//assign ld_thrd_byp_mxsel_g[3]    =  ~|ld_thrd_byp_sel_g[2:0];

assign  lmq_byp_ldxa_mxsel0[1:0] =   lmq_byp_ldxa_sel0[1:0];
assign  lmq_byp_ldxa_mxsel0[2]   = ~|lmq_byp_ldxa_sel0[1:0];
assign  lmq_byp_ldxa_mxsel1[1:0] =   lmq_byp_ldxa_sel1[1:0];
assign  lmq_byp_ldxa_mxsel1[2]   = ~|lmq_byp_ldxa_sel1[1:0];
assign  lmq_byp_ldxa_mxsel2[1:0] =   lmq_byp_ldxa_sel2[1:0];
assign  lmq_byp_ldxa_mxsel2[2]   = ~|lmq_byp_ldxa_sel2[1:0];
assign  lmq_byp_ldxa_mxsel3[1:0] =   lmq_byp_ldxa_sel3[1:0];
assign  lmq_byp_ldxa_mxsel3[2]   = ~|lmq_byp_ldxa_sel3[1:0];

assign  lmq_byp_data_mxsel0[0] =   lmq_byp_data_sel0[0] & ~rst_tri_en |  sehold;
assign  lmq_byp_data_mxsel0[1] =   lmq_byp_data_sel0[1] & ~rst_tri_en & ~sehold;
assign  lmq_byp_data_mxsel0[2] =   lmq_byp_data_sel0[2] & ~rst_tri_en & ~sehold;
assign  lmq_byp_data_mxsel0[3]   = (~|lmq_byp_data_sel0[2:0] | rst_tri_en) & ~sehold;

assign  lmq_byp_data_mxsel1[0] =   lmq_byp_data_sel1[0] & ~rst_tri_en |  sehold;
assign  lmq_byp_data_mxsel1[1] =   lmq_byp_data_sel1[1] & ~rst_tri_en & ~sehold;
assign  lmq_byp_data_mxsel1[2] =   lmq_byp_data_sel1[2] & ~rst_tri_en & ~sehold;
assign  lmq_byp_data_mxsel1[3]   = (~|lmq_byp_data_sel1[2:0] | rst_tri_en) & ~sehold;

assign  lmq_byp_data_mxsel2[0] =   lmq_byp_data_sel2[0] & ~rst_tri_en |  sehold;
assign  lmq_byp_data_mxsel2[1] =   lmq_byp_data_sel2[1] & ~rst_tri_en & ~sehold;
assign  lmq_byp_data_mxsel2[2] =   lmq_byp_data_sel2[2] & ~rst_tri_en & ~sehold;
assign  lmq_byp_data_mxsel2[3]   = (~|lmq_byp_data_sel2[2:0] | rst_tri_en) & ~sehold;

assign  lmq_byp_data_mxsel3[0] =   lmq_byp_data_sel3[0] & ~rst_tri_en |  sehold;
assign  lmq_byp_data_mxsel3[1] =   lmq_byp_data_sel3[1] & ~rst_tri_en & ~sehold;
assign  lmq_byp_data_mxsel3[2] =   lmq_byp_data_sel3[2] & ~rst_tri_en & ~sehold;
assign  lmq_byp_data_mxsel3[3]   = (~|lmq_byp_data_sel3[2:0] | rst_tri_en) & ~sehold;

//=========================================================================================
//	Error Based Traps/Reporting
//
//=========================================================================================

// !!! ORIGINAL ABOVE !!!
// Error Table for Queue
// ** In all cases; squash writes to irf.
//				| Error Reporting	| Trap ?	| 
// ifu_lsu_asi_rd_unc		| NA;done by ifu	| daccess-error	|
// tte_data_perror_unc_w2	| sync;in pipe		| daccess-error	|
// tte_data_perror_corr_w2	| sync;in pipe		| dmmu-miss	|
// asi_tte_data_perror_w2	| async;out of Q	| daccess-error	|
// asi_tte_tag_perror_w2	| async;out of Q	| daccess-error	|

assign	squash_byp_cmplt[0] = 
	((cam_perr_unc0  |  		
	asi_data_perr0 |  		
	asi_tag_perr0  |  		
	ifu_unc_err0   ) & lsu_nceen_d1[0]) |
	pend_atm_ld_ue[0] |
	spubyp0_trap ; // Bug 3873. add spu trap squash. (change reverted).
assign	squash_byp_cmplt[1] = 
	((cam_perr_unc1 | asi_data_perr1 | asi_tag_perr1 | ifu_unc_err1) & lsu_nceen_d1[1]) | 
	pend_atm_ld_ue[1] | spubyp1_trap ;	
assign	squash_byp_cmplt[2] = 
	((cam_perr_unc2 | asi_data_perr2 | asi_tag_perr2 | ifu_unc_err2) & lsu_nceen_d1[2]) | 
	pend_atm_ld_ue[2] | spubyp2_trap ;	
assign	squash_byp_cmplt[3] = 
	((cam_perr_unc3 | asi_data_perr3 | asi_tag_perr3 | ifu_unc_err3) & lsu_nceen_d1[3]) | 
	pend_atm_ld_ue[3] | spubyp3_trap ;	

assign  cam_perr_unc_e = 
  (ld_thrd_byp_sel_e[0] & cam_perr_unc0) |
  (ld_thrd_byp_sel_e[1] & cam_perr_unc1) |
  (ld_thrd_byp_sel_e[2] & cam_perr_unc2) |
  (ld_thrd_byp_sel_e[3] & cam_perr_unc3) ;
assign  asi_data_perr_e = 
  (ld_thrd_byp_sel_e[0] & asi_data_perr0) |
  (ld_thrd_byp_sel_e[1] & asi_data_perr1) |
  (ld_thrd_byp_sel_e[2] & asi_data_perr2) |
  (ld_thrd_byp_sel_e[3] & asi_data_perr3) ;
assign  asi_tag_perr_e = 
  (ld_thrd_byp_sel_e[0] & asi_tag_perr0) |
  (ld_thrd_byp_sel_e[1] & asi_tag_perr1) |
  (ld_thrd_byp_sel_e[2] & asi_tag_perr2) |
  (ld_thrd_byp_sel_e[3] & asi_tag_perr3) ;
assign  ifu_unc_err_e = 
  (ld_thrd_byp_sel_e[0] & ifu_unc_err0) |
  (ld_thrd_byp_sel_e[1] & ifu_unc_err1) |
  (ld_thrd_byp_sel_e[2] & ifu_unc_err2) |
  (ld_thrd_byp_sel_e[3] & ifu_unc_err3) ;
wire atm_st_unc_err_e,atm_st_unc_err_m,atm_st_unc_err_g ;
assign	atm_st_unc_err_e = 
(atm_st_cmplt0 & pend_atm_ld_ue[0]) | 
(atm_st_cmplt1 & pend_atm_ld_ue[1]) | 
(atm_st_cmplt2 & pend_atm_ld_ue[2]) | 
(atm_st_cmplt3 & pend_atm_ld_ue[3]) ; 

dff_s #(5)  stgm_tlberr (
        .din    ({cam_perr_unc_e,asi_data_perr_e,
		asi_tag_perr_e,ifu_unc_err_e,atm_st_unc_err_e}),
        .q      ({cam_perr_unc_m,asi_data_perr_m,
		asi_tag_perr_m,ifu_unc_err_m,atm_st_unc_err_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  


dff_s #(5)  stgg_tlberr (
        .din    ({cam_perr_unc_m,asi_data_perr_m,
		asi_tag_perr_m,ifu_unc_err_m,atm_st_unc_err_m}),
        .q      ({cam_perr_unc_g,asi_data_perr_g,
		asi_tag_perr_g,ifu_unc_err_g,atm_st_unc_err_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

assign	lsu_tlb_asi_data_perr_g = asi_data_perr_g ;
assign	lsu_tlb_asi_tag_perr_g = asi_tag_perr_g ;

// Asynchronous Trap Reporting to TLU (Traps are still precise).
// This version of nceen is meant specifically for trap reporting
// out of the asi queue.
wire nceen_m, nceen_g ;
assign nceen_m =
	(ld_thrd_byp_sel_m[0] & lsu_nceen_d1[0]) |
	(ld_thrd_byp_sel_m[1] & lsu_nceen_d1[1]) |
	(ld_thrd_byp_sel_m[2] & lsu_nceen_d1[2]) |
	(ld_thrd_byp_sel_m[3] & lsu_nceen_d1[3]) ;

wire nceen_dfq_m,nceen_dfq_g ;

// This version is meant specifically for lds reporting traps
// from the dfq.
assign	nceen_dfq_m =
	((~dfq_tid_m[1] & ~dfq_tid_m[0]) & lsu_nceen_d1[0]) |
	((~dfq_tid_m[1] &  dfq_tid_m[0]) & lsu_nceen_d1[1]) |
	(( dfq_tid_m[1] & ~dfq_tid_m[0]) & lsu_nceen_d1[2]) |
	(( dfq_tid_m[1] &  dfq_tid_m[0]) & lsu_nceen_d1[3]) ;

dff_s #(2)  trpen_stg (
        .din    ({nceen_m,nceen_dfq_m}),
        .q    	({nceen_g,nceen_dfq_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 


// l2c/dram
wire	atm_ld_w_uerr_m ;
dff_s #(1)  atmldu_stm (
        .din    (atm_ld_w_uerr),
        .q    	(atm_ld_w_uerr_m),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

wire	pmem_unc_error_m,pmem_unc_error_g ;
assign	pmem_unc_error_m = 
	l2_unc_error_m &  // bug3666
	~atm_ld_w_uerr_m ; //bug4048 - squash for atm ld with error.

wire	pmem_unc_error_tmp ;
dff_s #(1)  pmem_stg (
        .din    (pmem_unc_error_m),
        .q    	(pmem_unc_error_tmp),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

assign	pmem_unc_error_g = 
	(pmem_unc_error_tmp | bld_unc_err_pend_g) & ~bld_squash_err_g ;

wire	async_ttype_vld_g ;
wire [6:0] async_ttype_g ;
wire [1:0] async_tid_g ;

//wire	st_dtlb_perr_en ;
//assign	st_dtlb_perr_en = st_inst_vld_unflushed & tte_data_perror_unc & nceen_pipe_g ;

// traps are not to be taken if enables are not set. The asi rds of the tlb must
// thus complete as usual.
assign	async_ttype_vld_g =
	(((cam_perr_unc_g | asi_data_perr_g | asi_tag_perr_g | ifu_unc_err_g) & nceen_g) | 
		(pmem_unc_error_g & nceen_dfq_g)) | // Bug 3335,3518
	atm_st_unc_err_g |	// Bug 4048
	//lsu_defr_trp_taken_g |
	//st_dtlb_perr_en |
	//cam_perr_corr_g |
	spubyp_trap_active_g ;

wire [6:0]	async_ttype_m ;
assign	async_ttype_m[6:0] =
	spubyp_trap_active_m ? spubyp_ttype[6:0] : 7'h32 ;

dff_s #(7)  attype_stg (
        .din    (async_ttype_m[6:0]),
        .q      (async_ttype_g[6:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

wire [1:0]	async_err_tid_e,async_err_tid_m,async_err_tid_g ;
assign	async_err_tid_e[0] = ld_thrd_byp_sel_e[1] | ld_thrd_byp_sel_e[3] ;
assign	async_err_tid_e[1] = ld_thrd_byp_sel_e[3] | ld_thrd_byp_sel_e[2] ;

dff_s #(2)  ldbyperr_stgm (
        .din    (async_err_tid_e[1:0]),
        .q      (async_err_tid_m[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

dff_s #(2)  ldbyperr_stgg (
        .din    (async_err_tid_m[1:0]),
        .q      (async_err_tid_g[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

wire	sel_dfq_tid ;
assign	sel_dfq_tid = pmem_unc_error_g | atm_st_unc_err_g ;
assign	async_tid_g[1:0] = 
	//lsu_defr_trp_taken_g ? thrid_g[1:0] : // Bug 4660 - remove.
	sel_dfq_tid ? // Bug 3335,4048
	dfq_tid_g[1:0] : async_err_tid_g[1:0] ;

// Delay async_trp interface to TLU by a cycle.

dff_s #(10)  asynctrp_stgw2 (
        .din    ({async_ttype_vld_g,async_tid_g[1:0],async_ttype_g[6:0]}),
        .q      ({lsu_tlu_async_ttype_vld_w2,lsu_tlu_async_tid_w2[1:0],
		lsu_tlu_async_ttype_w2[6:0]}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

// Asynchronous Error Reporting to IFU 
// Partial.

wire  sync_error_sel ;
wire	memref_m ,memref_g;
   
dff_s #(1) memref_stgg (
        .din    (memref_m),
        .q    	(memref_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
   
//assign  sync_error_sel = tte_data_perror_unc | tte_data_perror_corr ;

//for in1 or in2 to be selected, memref_g must be 0.
//in1 is reported thru the bypass/asi queues, in2 thru the dfq.
//So err_addr_sel[0] can be memref_g.
   assign sync_error_sel = memref_g;
   
wire	async_error_sel ;
assign	async_error_sel = asi_data_perr_g | asi_tag_perr_g ;

assign	lsu_err_addr_sel[0] =  sync_error_sel & ~rst_tri_en;
assign	lsu_err_addr_sel[1] =  async_error_sel & ~rst_tri_en;
assign	lsu_err_addr_sel[2] = ~(sync_error_sel | async_error_sel) | rst_tri_en;

//mux4ds  #(6) async_tlb_index_mx(
//  .in0  (misc_data0[5:0]),
//  .in1  (misc_data1[5:0]),
//  .in2  (misc_data2[5:0]),
//  .in3  (misc_data3[5:0]),
//  .sel0 (ld_thrd_byp_sel_g[0]),
//  .sel1 (ld_thrd_byp_sel_g[1]),
//  .sel2 (ld_thrd_byp_sel_g[2]),
//  .sel3 (ld_thrd_byp_sel_g[3]),
//  .dout (async_tlb_index[5:0])
//   );
   
assign async_tlb_index[5:0] =  
  (ld_thrd_byp_sel_g[0] ? misc_data0[5:0] : 6'b0) |
  (ld_thrd_byp_sel_g[1] ? misc_data1[5:0] : 6'b0) |
  (ld_thrd_byp_sel_g[2] ? misc_data2[5:0] : 6'b0) |
  (ld_thrd_byp_sel_g[3] ? misc_data3[5:0] : 6'b0) ;
        
wire	[1:0] err_tid_g ;
//assign  err_tid_g[1:0] =
//  sync_error_sel ? thrid_g[1:0] :
//  	async_error_sel ? async_err_tid_g[1:0] : dfill_tid_g[1:0] ;

mux3ds #(2) err_tid_mx (
  .in0 (thrid_g[1:0]),
  .in1 (async_err_tid_g[1:0]),
  .in2 (dfill_tid_g[1:0]),
  .sel0(lsu_err_addr_sel[0]),
  .sel1(lsu_err_addr_sel[1]),
  .sel2(lsu_err_addr_sel[2]),
  .dout(err_tid_g[1:0])
                   );
                
// Can shift to m.
//assign  lsu_tlu_derr_tid_g[1:0] = err_tid_g[1:0] ;

dff_s #(2)  errad_stgg (
        .din    (err_tid_g[1:0]),
        .q      (lsu_ifu_error_tid[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        ); 

assign  lsu_ifu_io_error = //l2_unc_error_w2 & lsu_ifu_err_addr_b39 ;
// extend for bld to io space.
(l2_unc_error_w2 | bld_unc_err_pend_w2) & lsu_ifu_err_addr_b39 & ~bld_squash_err_w2 ;

 
//=========================================================================================


wire stxa_internal_cmplt ;
assign	stxa_internal_cmplt = 
stxa_internal & 
~(intrpt_disp_asi_g | stxa_stall_asi_g | (ifu_nontlb_asi_g & ~ifu_asi42_flush_g) | tlb_lng_ltncy_asi_g) & 
					lsu_inst_vld_w & ~dctl_early_flush_w ;
					//lsu_inst_vld_w & ~dctl_flush_pipe_w ;

// Need to add stxa's related to ifu non-tlb asi.
dff_s  stxa_int_d1 (
        .din    (stxa_internal_cmplt),
        //.din    (stxa_internal & ~(stxa_stall_asi_g | tlb_lng_ltncy_asi_g) & lsu_inst_vld_w),
        .q      (stxa_internal_d1),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s  stxa_int_d2 (
        .din    (stxa_internal_d1),
        .q      (stxa_internal_d2),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  


//=========================================================================================
//  Replacement Algorithm for Cache
//=========================================================================================



// Increment Condition.
wire	lfsr_incr, lfsr_incr_d1 ;
assign	lfsr_incr = 
	ld_inst_vld_g & ~lsu_way_hit_or & ~ldxa_internal & 
	~ncache_pcx_rq_g ; // must be cacheable

dff_s  lfsrd1_ff (
        .din    (lfsr_incr),
        .q      (lfsr_incr_d1),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

wire	lfsr_rst ;
assign	lfsr_rst = 
		reset 		| 	
		~gdbginit_l 	| // debug init.
		dc_direct_map 	; // direct map mode will reset.

// Bug 4027
lsu_dcache_lfsr lfsr(.out (lsu_dcache_rand[1:0]),
                                           .clk  (clk),
                                           .advance (lfsr_incr_d1),
                                           .reset (lfsr_rst),
                                           .se (se),
                                           .si (),
                                           .so ());

//assign  lsu_dcache_rand[1:0]  =  dcache_rand[1:0]; 


/*assign  dcache_rand_new[1:0] = dcache_rand[1:0] + {1'b0, lsu_ld_miss_wb} ;
dffre_s #(2) drand (
        .din    (dcache_rand_new[1:0]),
        .q      (dcache_rand[1:0]),
        .rst  (reset), .en    (lsu_ld_miss_wb),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

assign  lsu_dcache_rand[1:0]  =  dcache_rand[1:0]; */

//=========================================================================================
//  Packet Assembly
//=========================================================================================

// assign lsu_encd_way_hit[0] = cache_way_hit_buf1[1] | cache_way_hit_buf1[3] ;
// assign lsu_encd_way_hit[1] = cache_way_hit_buf1[2] | cache_way_hit_buf1[3] ;
always @ *
begin
lsu_encd_way_hit = 0;
if (cache_way_hit_buf1[0])
   lsu_encd_way_hit = 0;
else if (cache_way_hit_buf1[1])
   lsu_encd_way_hit = 1;
else if (cache_way_hit_buf1[2])
   lsu_encd_way_hit = 2;
else if (cache_way_hit_buf1[3])
   lsu_encd_way_hit = 3;
end


//assign lsu_way_hit_or  =  |lsu_way_hit[3:0];
assign lsu_way_hit_or  =  |cache_way_hit_buf1; // Bug 3940
   
//assign  stb_byp_pkt_vld_e = st_inst_vld_e & ~(ldsta_internal_e & alt_space_e);
assign  ld_pcx_pkt_vld_e = ld_inst_vld_e & ~(ldsta_internal_e & alt_space_e);

wire ldstub_m;
wire swap_m;
dff_s #(5)  pktctl_stgm (
        .din    ({ifu_lsu_ldst_dbl_e, ld_pcx_pkt_vld_e,
    ifu_lsu_casa_e,ifu_lsu_ldstub_e,ifu_lsu_swap_e}),
        .q      ({ldst_dbl_m, ld_pcx_pkt_vld_m,
    casa_m,ldstub_m,swap_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

assign  atomic_m = casa_m | ldstub_m | swap_m ;

wire ldstub_g;
wire swap_g;
dff_s #(6) pktctl_stgg (
        .din    ({ldst_dbl_m, ld_pcx_pkt_vld_m,
    casa_m,ldstub_m,swap_m,atomic_m}),
        .q      ({ldst_dbl_g, ld_pcx_pkt_vld_g,
    casa_g,ldstub_g,swap_g,atomic_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(2) pktctl_stgw2 (
        .din    ({ldd_force_l2access_g, atomic_g}),
        .q      ({ldd_force_l2access_w2,atomic_w2}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

dff_s #(2) pktctl_stgw3 (
        .din    ({ldd_force_l2access_w2, atomic_w2}),
        .q      ({ldd_force_l2access_w3, atomic_w3}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  
   
assign  lsu_ldstub_g = ldstub_g ;
assign  lsu_swap_g = swap_g ;

// Choose way for load. If load hits in dcache but sent out to xbar because
// of partial raw then need to use hit way else use random. Similarly, dcache
// parity error will force a miss and fill to same way.

// Moved to qctl1
// For direct-map mode, assume that addition set-index bits 12:11 are
// used to file line in set.
//assign  ld_way[1:0] = 
//    (|lsu_way_hit[3:0]) ? 
//        {lsu_encd_way_hit[1],lsu_encd_way_hit[0]} : 
//          	lsu_ld_sec_hit_l2access_g ? lsu_ld_sec_hit_wy_g[1:0] :
//	   		(dc_direct_map ? ldst_va_g[12:11] : dcache_rand[1:0]) ;

// set to 011 for atomic - only cas encoding used for pcx pkt.
assign  ld_rq_type[2:0] =
    atomic_g ? 3'b011 :       // cas pkt 2/ldstub/swap 
//        (ldst_dbl_g & st_inst_vld_g & quad_asi_g) ? 3'b001 : // stquad - label as store.
    3'b000 ;      // normal load


//assign  lmq_pkt_vld_g = ld_pcx_pkt_vld_g | (ldst_dbl_g & st_inst_vld_unflushed) | pref_inst_g ; 
assign  lmq_pkt_vld_g = ld_pcx_pkt_vld_g | pref_inst_g ; 

// Moved to qctl1
// 2'b01 encodes ld as st-quad pkt2. 2'b00 needed for cas-pkt2
//assign  lmq_pkt_way_g[1:0] = 
//(ldst_dbl_g & st_inst_vld_unflushed & quad_asi_g) ? 2'b01 :
//        casa_g ? 2'b00 : ld_way[1:0] ;

// ld is 128b request.
wire	qword_access_g;
assign	qword_access_g = 
(quad_asi_g | blk_asi_g ) & lsu_alt_space_g & ld_inst_vld_unflushed ;

assign	lsu_quad_word_access_g = qword_access_g ;

wire  fp_ld_inst_g ;
assign  fp_ld_inst_g  = fp_ldst_g & ld_inst_vld_g ;  

wire  ldst_sz_b0_g ;
assign  ldst_sz_b0_g =  
  ldst_sz_g[0] & 
  ~(ldst_dbl_g & ~fp_ldst_g & 
    (~lsu_alt_space_g | (lsu_alt_space_g & ~quad_asi_g))) ; 
                // word for ld-dbl

wire	asi_real_iomem_m,asi_real_iomem_g ;
assign	asi_real_iomem_m = 
(dtlb_bypass_m & (phy_use_ec_asi_m | phy_byp_ec_asi_m) & lsu_alt_space_m) ;

dff_s #(1) stgg_asir (
        .din    (asi_real_iomem_m),
        .q    	(asi_real_iomem_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign  ncache_pcx_rq_g   = 
  atomic_g    |   // cas,ldstub,swap  
  asi_real_iomem_g | // real_mem, real_io
  ~dcache_enable_g | // dcache disabled : Bug 5174 (accidental removal)
  ((tlb_pgnum[39] & ~lsu_dtlb_bypass_g & tlb_cam_hit_g) | // IO - tlb not in bypass
   (tlb_pgnum[39] &  lsu_dtlb_bypass_g)) |    // IO - tlb bypass
  (~lsu_tte_data_cp_g & tlb_cam_hit_g) |      // cp bit is clear
  ((quad_asi_g | binit_quad_asi_g | blk_asi_g)  & lsu_alt_space_g & ldst_dbl_g & ld_inst_vld_unflushed) |  // quad-ld
  pref_inst_g ; // pref will not alloc. in L2 dir

assign  stb_ncache_pcx_rq_g   = 
  asi_real_iomem_g | // real_mem, real_io
  ~dcache_enable_g | // dcache disabled : Bug 5174 (accidental removal)
  ((tlb_pgnum[39] & ~lsu_dtlb_bypass_g & tlb_cam_hit_g) | // IO - tlb not in bypass
   (tlb_pgnum[39] &  lsu_dtlb_bypass_g)) |    // IO - tlb bypass
  (~lsu_tte_data_cp_g & tlb_cam_hit_g);      // cp bit is clear


//wire	dflush_ld_g ;
//assign  dflush_ld_g = dflush_asi_g & lsu_alt_space_g ;

// st-quad pkt1 and pkt2 need different addresses !!
// ** should be able to reduce the width, rd2,stquad,lmq_pkt_way ** 
//assign  ld_pcx_pkt_g[`LMQ_WIDTH-1:0] =

//bug3601
//dbl_data_return will become lmq_ldd
//it includes quad ld, int ldd, block ld, all these cases need return data twice.    
   wire dbl_data_return;
   assign dbl_data_return = ldst_dbl_g & ~ (fp_ldst_g & ~ (blk_asi_g & lsu_alt_space_g));
   
assign  ld_pcx_pkt_g[`LMQ_WIDTH-1:40] =
  {lmq_pkt_vld_g,
  1'b0,                  //dflush_ld_g, bug 4580 
  pref_inst_g, 
  fp_ld_inst_g, 
  l1hit_sign_extend_g,
  //lsu_bendian_access_g,
  bendian_g,	// l2fill_bendian removed.
  ld_rd_g[4:0], // use rd1 only for now.
  dbl_data_return,  //bug 3601
  //ldst_dbl_g & ~fp_ldst_g,  // rd2 used by ld double.
  {ld_rd_g[4:1],~ld_rd_g[0]}, // rd2 to be used with atomics.
  ld_rq_type[2:0],
  ncache_pcx_rq_g,  // NC.
  //lmq_pkt_way_g[1:0], // replacement way
  2'b00,
  ldst_sz_g[1],ldst_sz_b0_g};
  //{tlb_pgnum[39:10], ldst_va_g[9:0]}};

//=========================================================================================
//  Byte Masking for writes
//=========================================================================================

// Byte-enables will be generated in cycle prior to fill (E-stage)
// Reads and writes are mutex as array is single-ported.
// byte-enables are handled thru read-modify-writes.

// Create 16b Write Mask based on size and va ;
// This is to be put in the DFQ once the DFQ is on-line.


wire [2:0] dc_waddr_m ;
dff_s #(4) stgm_addr (
        .din    ({memref_e, dcache_wr_addr_e[2:0]}),
        .q    	({memref_m, dc_waddr_m[2:0]}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign	lsu_memref_m = memref_m ;

//wire [3:0] rwaddr_enc ;
//assign  rwaddr_enc[3:0] = memref_m ? 
//        lsu_ldst_va_b7_b0_m[3:0] : dc_waddr_m[3:0];

wire [2:0] rwaddr_enc ;
assign  rwaddr_enc[2:0] = memref_m ? 
        lsu_ldst_va_b7_b0_m[2:0] : dc_waddr_m[2:0];
   

   wire [1:0] wr_size;
   
   assign wr_size[1:0] = dcache_wr_size_e[1:0];

   wire   wr_hword, wr_word, wr_dword;
   
//assign  wr_byte    = ~wr_size[1] & ~wr_size[0] ; // 01
assign  wr_hword   = ~wr_size[1] &  wr_size[0] ; // 01
assign  wr_word    =  wr_size[1] & ~wr_size[0] ; // 10
assign  wr_dword   =  wr_size[1] &  wr_size[0] ; // 11

assign  ldst_byte    = ~ldst_sz_e[1] & ~ldst_sz_e[0] ; // 01
assign  ldst_hword   = ~ldst_sz_e[1] &  ldst_sz_e[0] ; // 01
assign  ldst_word    =  ldst_sz_e[1] & ~ldst_sz_e[0] ; // 10
assign  ldst_dword   =  ldst_sz_e[1] &  ldst_sz_e[0] ; // 11

// In Bypass mode, endianness is determined by asi.
// Need to complete this equation.

// Note : add MMU disable bypass conditions !!!
assign  tlb_invert_endian_g = lsu_tlb_invert_endian_g & ~lsu_dtlb_bypass_g & tlb_cam_hit_g ; 

// Is qualification with reset needed ?
//assign  l2fill_bendian_g = lsu_l2fill_bendian_g & ~reset;

//assign  pstate_cle_m = 
//  thread0_m ? tlu_lsu_pstate_cle[0] :
//    thread1_m ? tlu_lsu_pstate_cle[1] :
//      thread2_m ? tlu_lsu_pstate_cle[2] :
//          tlu_lsu_pstate_cle[3] ;

mux4ds  #(1) pstate_cle_e_mux (
        .in0    (tlu_lsu_pstate_cle[0]),
        .in1    (tlu_lsu_pstate_cle[1]),
        .in2    (tlu_lsu_pstate_cle[2]),
        .in3    (tlu_lsu_pstate_cle[3]),
        .sel0   (thread0_e),  
        .sel1   (thread1_e),
        .sel2   (thread2_e),  
        .sel3   (thread3_e),
        .dout   (pstate_cle_e)
);

dff_s #(1) stgm_pstatecle (
        .din    (pstate_cle_e),
        .q      (pstate_cle_m),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
   
dff_s #(1) stgg_pstatecle (
        .din    (pstate_cle_m),
        .q      (pstate_cle_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

//SPARC V9 page 52. pstate.cle should only affect implicit ASI   
assign  l1hit_lendian_g = 
    ((non_altspace_ldst_g & (pstate_cle_g ^ tlb_invert_endian_g)) |       // non altspace ldst
     (altspace_ldst_g     & (lendian_asi_g ^ tlb_invert_endian_g)))       // altspace ldst
    & ~(asi_internal_g & lsu_alt_space_g);                                // internal asi is big-endian

wire    l1hit_lendian_predict_m ;
// Predict endian-ness in m-stage. Assume tte.IE=0
assign  l1hit_lendian_predict_m =
    ((non_altspace_ldst_m & pstate_cle_m) |        // non altspace ldst
     (altspace_ldst_m     & lendian_asi_m))        // altspace ldst
    & ~asi_internal_m ;                            // internal asi is big-endian
   
// Further, decode of ASI is not factored into endian calculation. 
//assign  lsu_bendian_access_g = (ld_inst_vld_unflushed | st_inst_vld_unflushed) ?
//    ~l1hit_lendian_g : l2fill_bendian_g ;

// m stage endian signal is predicted for in-pipe lds only.
wire    bendian_pred_m, bendian_pred_g ;
assign  bendian_pred_m = (ld_inst_vld_m | st_inst_vld_m) ?
    ~l1hit_lendian_predict_m : lsu_l2fill_bendian_m ;

dff_s #(1) stgg_bendpr(
        .din    (bendian_pred_m),
        .q      (bendian_pred_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

// mispredict applies to only in-pipe lds.
assign  endian_mispred_g =  bendian_pred_g ^ ~l1hit_lendian_g ;

// Staging for alignment on read from l1 or fill to l2.
dff_s #(4) stgm_sz (
        .din    ({ldst_byte,  ldst_hword,  ldst_word,  ldst_dword}),
        .q      ({byte_m,hword_m,word_m,dword_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  

wire	[7:0]	rwaddr_dcd_part ;

assign  rwaddr_dcd_part[0]  = ~rwaddr_enc[2] & ~rwaddr_enc[1] & ~rwaddr_enc[0] ; 
assign  rwaddr_dcd_part[1]  = ~rwaddr_enc[2] & ~rwaddr_enc[1] &  rwaddr_enc[0] ; 
assign  rwaddr_dcd_part[2]  = ~rwaddr_enc[2] &  rwaddr_enc[1] & ~rwaddr_enc[0] ; 
assign  rwaddr_dcd_part[3]  = ~rwaddr_enc[2] &  rwaddr_enc[1] &  rwaddr_enc[0] ; 
assign  rwaddr_dcd_part[4]  =  rwaddr_enc[2] & ~rwaddr_enc[1] & ~rwaddr_enc[0] ; 
assign  rwaddr_dcd_part[5]  =  rwaddr_enc[2] & ~rwaddr_enc[1] &  rwaddr_enc[0] ; 
assign  rwaddr_dcd_part[6]  =  rwaddr_enc[2] &  rwaddr_enc[1] & ~rwaddr_enc[0] ; 
assign  rwaddr_dcd_part[7]  =  rwaddr_enc[2] &  rwaddr_enc[1] &  rwaddr_enc[0] ; 

   assign baddr_m[7:0] = rwaddr_dcd_part[7:0];
/*    
assign baddr_m[0]  = ~rwaddr_enc[3] & rwaddr_dcd_part[0] ;
assign baddr_m[1]  = ~rwaddr_enc[3] & rwaddr_dcd_part[1] ;
assign baddr_m[2]  = ~rwaddr_enc[3] & rwaddr_dcd_part[2] ;
assign baddr_m[3]  = ~rwaddr_enc[3] & rwaddr_dcd_part[3] ;
assign baddr_m[4]  = ~rwaddr_enc[3] & rwaddr_dcd_part[4] ; 
assign baddr_m[5]  = ~rwaddr_enc[3] & rwaddr_dcd_part[5] ;
assign baddr_m[6]  = ~rwaddr_enc[3] & rwaddr_dcd_part[6] ;
assign baddr_m[7]  = ~rwaddr_enc[3] & rwaddr_dcd_part[7] ;
assign baddr_m[8]  =  rwaddr_enc[3] & rwaddr_dcd_part[0] ;
assign baddr_m[9]  =  rwaddr_enc[3] & rwaddr_dcd_part[1] ;
assign baddr_m[10] =  rwaddr_enc[3] & rwaddr_dcd_part[2] ;
assign baddr_m[11] =  rwaddr_enc[3] & rwaddr_dcd_part[3] ;
assign baddr_m[12] =  rwaddr_enc[3] & rwaddr_dcd_part[4] ;
assign baddr_m[13] =  rwaddr_enc[3] & rwaddr_dcd_part[5] ;
assign baddr_m[14] =  rwaddr_enc[3] & rwaddr_dcd_part[6] ;
assign baddr_m[15] =  rwaddr_enc[3] & rwaddr_dcd_part[7] ;
*/
// Byte Address to start write from. Quantity can be byte/hword/word/dword.
// E-stage decoding for write to cache.

wire	[3:0]	waddr_enc ;
wire	[7:0]	waddr_dcd_part ;
wire	[15:0]	waddr_dcd ;

assign  waddr_dcd_part[0]  = ~waddr_enc[2] & ~waddr_enc[1] & ~waddr_enc[0] ; 
assign  waddr_dcd_part[1]  = ~waddr_enc[2] & ~waddr_enc[1] &  waddr_enc[0] ; 
assign  waddr_dcd_part[2]  = ~waddr_enc[2] &  waddr_enc[1] & ~waddr_enc[0] ; 
assign  waddr_dcd_part[3]  = ~waddr_enc[2] &  waddr_enc[1] &  waddr_enc[0] ; 
assign  waddr_dcd_part[4]  =  waddr_enc[2] & ~waddr_enc[1] & ~waddr_enc[0] ; 
assign  waddr_dcd_part[5]  =  waddr_enc[2] & ~waddr_enc[1] &  waddr_enc[0] ; 
assign  waddr_dcd_part[6]  =  waddr_enc[2] &  waddr_enc[1] & ~waddr_enc[0] ; 
assign  waddr_dcd_part[7]  =  waddr_enc[2] &  waddr_enc[1] &  waddr_enc[0] ; 

assign  waddr_dcd[0]  = ~waddr_enc[3] & waddr_dcd_part[0] ;
assign  waddr_dcd[1]  = ~waddr_enc[3] & waddr_dcd_part[1] ;
assign  waddr_dcd[2]  = ~waddr_enc[3] & waddr_dcd_part[2] ;
assign  waddr_dcd[3]  = ~waddr_enc[3] & waddr_dcd_part[3] ;
assign  waddr_dcd[4]  = ~waddr_enc[3] & waddr_dcd_part[4] ; 
assign  waddr_dcd[5]  = ~waddr_enc[3] & waddr_dcd_part[5] ;
assign  waddr_dcd[6]  = ~waddr_enc[3] & waddr_dcd_part[6] ;
assign  waddr_dcd[7]  = ~waddr_enc[3] & waddr_dcd_part[7] ;
assign  waddr_dcd[8]  =  waddr_enc[3] & waddr_dcd_part[0] ;
assign  waddr_dcd[9]  =  waddr_enc[3] & waddr_dcd_part[1] ;
assign  waddr_dcd[10] =  waddr_enc[3] & waddr_dcd_part[2] ;
assign  waddr_dcd[11] =  waddr_enc[3] & waddr_dcd_part[3] ;
assign  waddr_dcd[12] =  waddr_enc[3] & waddr_dcd_part[4] ;
assign  waddr_dcd[13] =  waddr_enc[3] & waddr_dcd_part[5] ;
assign  waddr_dcd[14] =  waddr_enc[3] & waddr_dcd_part[6] ;
assign  waddr_dcd[15] =  waddr_enc[3] & waddr_dcd_part[7] ;

// Byte enables for 16 bytes.
   //bug6216/eco6624
   wire write_16byte_e;
   assign write_16byte_e = l2fill_vld_e | lsu_bist_wvld_e;
    
assign byte_wr_enable[15] = 
    write_16byte_e  |   waddr_dcd[0] ;    
assign byte_wr_enable[14] = 
    write_16byte_e  |   waddr_dcd[1]    |   
    (wr_hword & waddr_dcd[0])  |   (wr_word & waddr_dcd[0]) |
    (wr_dword & waddr_dcd[0])  ;     
assign byte_wr_enable[13] = 
    write_16byte_e  |   waddr_dcd[2]    |
    (wr_word & waddr_dcd[0]) |     (wr_dword & waddr_dcd[0])  ;   
assign byte_wr_enable[12] = 
    write_16byte_e  |   waddr_dcd[3]    |
    (wr_hword & waddr_dcd[2])  |   (wr_word & waddr_dcd[0]) |
    (wr_dword & waddr_dcd[0])  ;   
assign byte_wr_enable[11] = 
    write_16byte_e  |   waddr_dcd[4]    |     
    (wr_dword & waddr_dcd[0])  ;   
assign byte_wr_enable[10] = 
    write_16byte_e  |   waddr_dcd[5]    |
    (wr_hword & waddr_dcd[4])  |   (wr_word & waddr_dcd[4]) |
    (wr_dword & waddr_dcd[0])  ;   
assign byte_wr_enable[9] = 
    write_16byte_e  |   waddr_dcd[6]    |
    (wr_word & waddr_dcd[4]) |     (wr_dword & waddr_dcd[0])  ;   
assign byte_wr_enable[8] = 
    write_16byte_e  |   waddr_dcd[7]    |
    (wr_hword & waddr_dcd[6])  |   (wr_word & waddr_dcd[4]) |
    (wr_dword & waddr_dcd[0])  ;   
assign byte_wr_enable[7] = 
    write_16byte_e  |   waddr_dcd[8] ;    
assign byte_wr_enable[6] = 
    write_16byte_e  |   waddr_dcd[9]    |   
    (wr_hword & waddr_dcd[8])  |   (wr_word & waddr_dcd[8]) |
    (wr_dword & waddr_dcd[8])  ;     
assign byte_wr_enable[5] = 
    write_16byte_e  |   waddr_dcd[10]   |
    (wr_word & waddr_dcd[8]) |     (wr_dword & waddr_dcd[8])  ;   
assign byte_wr_enable[4] = 
    write_16byte_e  |   waddr_dcd[11]   |
    (wr_hword & waddr_dcd[10]) |   (wr_word & waddr_dcd[8]) |
    (wr_dword & waddr_dcd[8])  ;   
assign byte_wr_enable[3] = 
    write_16byte_e  |   waddr_dcd[12]   |     
    (wr_dword & waddr_dcd[8])  ;   
assign byte_wr_enable[2] = 
    write_16byte_e  |   waddr_dcd[13]   |
    (wr_hword & waddr_dcd[12]) |   (wr_word & waddr_dcd[12])  |
    (wr_dword & waddr_dcd[8])  ;   
assign byte_wr_enable[1] = 
    write_16byte_e  |   waddr_dcd[14]   |
    (wr_word & waddr_dcd[12])  |   (wr_dword & waddr_dcd[8])  ;   
assign byte_wr_enable[0] = 
    write_16byte_e  |   waddr_dcd[15]   |
    (wr_hword & waddr_dcd[14]) |   (wr_word & waddr_dcd[12])  |
    (wr_dword & waddr_dcd[8])  ; 

assign  dcache_byte_wr_en_e[15:0] = byte_wr_enable[15:0] ;
//assign  lsu_st_byte_addr_g[15:0]  = byp_baddr_g[15:0] ;

//=========================================================================================
//  Sign/Zero-Extension
//=========================================================================================

dff_s #(1) stgm_msb (
       .din    ({lsu_l1hit_sign_extend_e}),
       .q      ({l1hit_sign_extend_m}),
       .clk    (clk),
       .se     (se),       .si (),          .so ()
       );  

dff_s #(1) stgg_msb (
       .din    ({l1hit_sign_extend_m}),
       .q      ({l1hit_sign_extend_g}),
       .clk    (clk),
       .se     (se),       .si (),          .so ()
       ); 


//wire [1:0] lsu_byp_misc_sz_g ;   

/*dff #(2) ff_lsu_byp_misc_sz_g (
        .din   (lsu_byp_misc_sz_m[1:0]),
        .q     (lsu_byp_misc_sz_g[1:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );  */

assign  misc_byte_m   = ~lsu_byp_misc_sz_m[1] & ~lsu_byp_misc_sz_m[0] ; // 00
assign  misc_hword_m  = ~lsu_byp_misc_sz_m[1] &  lsu_byp_misc_sz_m[0] ; // 01
assign  misc_word_m   =  lsu_byp_misc_sz_m[1] & ~lsu_byp_misc_sz_m[0] ; // 10
assign  misc_dword_m  =  lsu_byp_misc_sz_m[1] &  lsu_byp_misc_sz_m[0] ; // 11

wire    byp_byte_m,byp_hword_m,byp_word_m,byp_dword_m;
assign  byp_byte_m =  (ld_inst_vld_m) ?  byte_m :  misc_byte_m ;
assign  byp_hword_m = (ld_inst_vld_m) ? hword_m :  misc_hword_m ;
assign  byp_word_m =  (ld_inst_vld_m) ?  word_m :  misc_word_m ;
assign  byp_dword_m = (ld_inst_vld_m) ? dword_m :  misc_dword_m ;

/*assign  byp_byte_g =  (|lsu_irf_byp_data_src[2:1]) ? misc_byte_g : byte_g ;
assign  byp_hword_g = (|lsu_irf_byp_data_src[2:1]) ? misc_hword_g : hword_g ;
assign  byp_word_g =  (|lsu_irf_byp_data_src[2:1]) ? misc_word_g : word_g ;*/

dff_s #(1) bypsz_stgg(
        .din   ({byp_word_m}),
        .q     ({byp_word_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

//wire [3:0]	misc_waddr_m ; 
//assign  misc_waddr_m[3:0] = {lsu_byp_misc_addr_m[3],lsu_byp_misc_addr_m[2]^lsu_byp_ldd_oddrd_m,lsu_byp_misc_addr_m[1:0]} ;

wire [2:0]	misc_waddr_m ; 
assign  misc_waddr_m[2:0] = {lsu_byp_misc_addr_m[2]^lsu_byp_ldd_oddrd_m,lsu_byp_misc_addr_m[1:0]} ;
   
//wire    [15:0] misc_baddr_m ;
wire    [7:0] misc_baddr_m ;

// m-stage decoding
// Might be better to stage encoded waddr, mux and then decode.
/*
assign  misc_baddr_m[0] = ~misc_waddr_m[3] & ~misc_waddr_m[2] & ~misc_waddr_m[1] & ~misc_waddr_m[0] ; 
assign  misc_baddr_m[1] = ~misc_waddr_m[3] & ~misc_waddr_m[2] & ~misc_waddr_m[1] &  misc_waddr_m[0] ; 
assign  misc_baddr_m[2] = ~misc_waddr_m[3] & ~misc_waddr_m[2] &  misc_waddr_m[1] & ~misc_waddr_m[0] ; 
assign  misc_baddr_m[3] = ~misc_waddr_m[3] & ~misc_waddr_m[2] &  misc_waddr_m[1] &  misc_waddr_m[0] ; 
assign  misc_baddr_m[4] = ~misc_waddr_m[3] &  misc_waddr_m[2] & ~misc_waddr_m[1] & ~misc_waddr_m[0] ; 
assign  misc_baddr_m[5] = ~misc_waddr_m[3] &  misc_waddr_m[2] & ~misc_waddr_m[1] &  misc_waddr_m[0] ; 
assign  misc_baddr_m[6] = ~misc_waddr_m[3] &  misc_waddr_m[2] &  misc_waddr_m[1] & ~misc_waddr_m[0] ; 
assign  misc_baddr_m[7] = ~misc_waddr_m[3] &  misc_waddr_m[2] &  misc_waddr_m[1] &  misc_waddr_m[0] ; 
assign  misc_baddr_m[8] =  misc_waddr_m[3] & ~misc_waddr_m[2] & ~misc_waddr_m[1] & ~misc_waddr_m[0] ; 
assign  misc_baddr_m[9] =  misc_waddr_m[3] & ~misc_waddr_m[2] & ~misc_waddr_m[1] &  misc_waddr_m[0] ; 
assign  misc_baddr_m[10] =  misc_waddr_m[3] & ~misc_waddr_m[2] &  misc_waddr_m[1] & ~misc_waddr_m[0] ; 
assign  misc_baddr_m[11] =  misc_waddr_m[3] & ~misc_waddr_m[2] &  misc_waddr_m[1] &  misc_waddr_m[0] ; 
assign  misc_baddr_m[12] =  misc_waddr_m[3] &  misc_waddr_m[2] & ~misc_waddr_m[1] & ~misc_waddr_m[0] ; 
assign  misc_baddr_m[13] =  misc_waddr_m[3] &  misc_waddr_m[2] & ~misc_waddr_m[1] &  misc_waddr_m[0] ; 
assign  misc_baddr_m[14] =  misc_waddr_m[3] &  misc_waddr_m[2] &  misc_waddr_m[1] & ~misc_waddr_m[0] ; 
assign  misc_baddr_m[15] =  misc_waddr_m[3] &  misc_waddr_m[2] &  misc_waddr_m[1] &  misc_waddr_m[0] ; 
*/
assign  misc_baddr_m[0] = ~misc_waddr_m[2] & ~misc_waddr_m[1] & ~misc_waddr_m[0] ; 
assign  misc_baddr_m[1] = ~misc_waddr_m[2] & ~misc_waddr_m[1] &  misc_waddr_m[0] ; 
assign  misc_baddr_m[2] = ~misc_waddr_m[2] &  misc_waddr_m[1] & ~misc_waddr_m[0] ; 
assign  misc_baddr_m[3] = ~misc_waddr_m[2] &  misc_waddr_m[1] &  misc_waddr_m[0] ; 
assign  misc_baddr_m[4] =  misc_waddr_m[2] & ~misc_waddr_m[1] & ~misc_waddr_m[0] ; 
assign  misc_baddr_m[5] =  misc_waddr_m[2] & ~misc_waddr_m[1] &  misc_waddr_m[0] ; 
assign  misc_baddr_m[6] =  misc_waddr_m[2] &  misc_waddr_m[1] & ~misc_waddr_m[0] ; 
assign  misc_baddr_m[7] =  misc_waddr_m[2] &  misc_waddr_m[1] &  misc_waddr_m[0] ; 
   
//wire [15:0] byp_baddr_m ;
//assign  byp_baddr_m[15:0] = (~(ld_inst_vld_m | st_inst_vld_m)) ? misc_baddr_m[15:0] : baddr_m[15:0] ;
wire [7:0] byp_baddr_m ;
assign  byp_baddr_m[7:0] = (~(ld_inst_vld_m | st_inst_vld_m)) ? misc_baddr_m[7:0] : baddr_m[7:0] ;

   wire l2fill_sign_extend_m;
   
assign  l2fill_sign_extend_m = lsu_l2fill_sign_extend_m ;
//?? why need st ??
assign  signed_ldst_m = (ld_inst_vld_m | st_inst_vld_m) ?
                         l1hit_sign_extend_m : l2fill_sign_extend_m ; 

//assign  unsigned_ldst_m = ~signed_ldst_m ;

   assign signed_ldst_byte_m = signed_ldst_m & byp_byte_m;
//   assign unsigned_ldst_byte_m = unsigned_ldst_m & byp_byte_m;

   assign signed_ldst_hw_m = signed_ldst_m & ( byp_byte_m | byp_hword_m );
//   assign unsigned_ldst_hw_m = unsigned_ldst_m & ( byp_byte_m | byp_hword_m );
 
   assign signed_ldst_w_m = signed_ldst_m & ( byp_byte_m | byp_hword_m | byp_word_m );
//   assign unsigned_ldst_w_m = unsigned_ldst_m & ( byp_byte_m | byp_hword_m | byp_word_m );
   
//C assign  align_bytes_msb[7:0] = (ld_inst_vld_unflushed | st_inst_vld_unflushed) ? lsu_l1hit_bytes_msb_g[7:0] :
//C	(l2fill_vld_g ? l2fill_bytes_msb_g[7:0] : lsu_misc_bytes_msb_g[7:0])  ;

//assign  align_bytes_msb[7:0] = (ld_inst_vld_unflushed | st_inst_vld_unflushed) ? lsu_l1hit_bytes_msb_g[7:0] :
//    (lsu_irf_byp_data_src[2] ? lsu_misc_bytes_msb_g[7:0] : l2fill_bytes_msb_g[7:0])  ;


// For little-endian accesses, the following morphing must occur to the byte addr.
//
// Byte Addr(lower 3b)  
//  000(0)  ->  001(1) (hw)
//    ->  011(3) (w)
//    ->  111(7) (dw)
//  001(1)  ->  not morphed
//  010(2)  ->  011(3) (hw)
//  011(3)  ->  not morphed
//  100(4)  ->  101(5) (hw)
//    ->  111(7) (w)
//  101(5)  ->  not morphed
//  110(6)  ->  111(7) (hw)
//  111(7)  ->  not morphed

wire  [7:0] merged_addr_m ;   
wire  [7:0] morphed_addr_m ;    

//wire  bendian ;

//assign  merged_addr_m[7:0] = byp_baddr_m[15:8] | byp_baddr_m[7:0] ;
assign  merged_addr_m[7:0] = byp_baddr_m[7:0] ;

assign  morphed_addr_m[0] 
  =  merged_addr_m[0] & ~(~bendian_pred_m & ~byp_byte_m) ;
assign  morphed_addr_m[1] 
  =  merged_addr_m[1] | (merged_addr_m[0] & ~bendian_pred_m & byp_hword_m) ;
assign  morphed_addr_m[2] 
  =  merged_addr_m[2] & ~(~bendian_pred_m & byp_hword_m) ;
assign  morphed_addr_m[3] 
  =  merged_addr_m[3] | (merged_addr_m[0] & ~bendian_pred_m & byp_word_m) |
  (merged_addr_m[2] & ~bendian_pred_m & byp_hword_m) ;
assign  morphed_addr_m[4] 
  =  merged_addr_m[4] & ~(~bendian_pred_m & (byp_hword_m | byp_word_m)) ;
assign  morphed_addr_m[5] 
  =  merged_addr_m[5] | (merged_addr_m[4] & ~bendian_pred_m & byp_hword_m) ;
assign  morphed_addr_m[6] 
  =  merged_addr_m[6] & ~(~bendian_pred_m & byp_hword_m) ;
assign  morphed_addr_m[7] 
  =  merged_addr_m[7] | (merged_addr_m[0] & ~bendian_pred_m & ~(byp_byte_m | byp_hword_m | byp_word_m))  |
  (merged_addr_m[4] & ~bendian_pred_m & byp_word_m) | (merged_addr_m[6] & ~bendian_pred_m & byp_hword_m) ;


   
   
//=========================================================================================
//  ALIGNMENT CONTROL FOR DCDP 
//=========================================================================================

// First generate control for swapping related to endianness.
// byte7-byte0 is source data from cache etc.
// swap7-swap0 is result of endianness swapping.

// First logical level - Swapping of bytes. 
// Swap byte 0 

wire  swap0_sel_byte0, swap0_sel_byte1, swap0_sel_byte3  ;
wire  swap1_sel_byte0, swap1_sel_byte1, swap1_sel_byte2, swap1_sel_byte6 ;
wire  swap2_sel_byte1, swap2_sel_byte2, swap2_sel_byte3, swap2_sel_byte5 ;
wire  swap3_sel_byte0, swap3_sel_byte2, swap3_sel_byte3, swap3_sel_byte4 ;
wire  swap4_sel_byte3, swap4_sel_byte4, swap4_sel_byte5 ;
wire  swap5_sel_byte2, swap5_sel_byte4, swap5_sel_byte5, swap5_sel_byte6 ;
wire  swap6_sel_byte1, swap6_sel_byte5, swap6_sel_byte6 ;
wire  swap7_sel_byte0, swap7_sel_byte4, swap7_sel_byte6, swap7_sel_byte7 ;

//assign  bendian = bendian_pred_m ;
//assign  bendian = lsu_bendian_access_g ;

assign  swap0_sel_byte0   = bendian_pred_m | (~bendian_pred_m & byp_byte_m) ;
assign  swap0_sel_byte1   = ~bendian_pred_m & byp_hword_m ;
assign  swap0_sel_byte3   = ~bendian_pred_m & byp_word_m ;
// could be substituted with dword encoding.
//assign  swap0_sel_byte7   = ~bendian_pred_m & ~(byp_word_m | byp_hword_m | byp_byte_m) ;

// Swap byp_byte_m 1 
assign  swap1_sel_byte0   = ~bendian_pred_m & byp_hword_m ;
assign  swap1_sel_byte1   = bendian_pred_m | (~bendian_pred_m & byp_byte_m) ;
assign  swap1_sel_byte2   = ~bendian_pred_m & byp_word_m ;
assign  swap1_sel_byte6   = ~bendian_pred_m & ~(byp_word_m | byp_hword_m | byp_byte_m) ;

// Swap byp_byte_m 2 
assign  swap2_sel_byte1   = ~bendian_pred_m & byp_word_m ;
assign  swap2_sel_byte2   = bendian_pred_m | (~bendian_pred_m & byp_byte_m) ;
assign  swap2_sel_byte3   = ~bendian_pred_m & byp_hword_m ;
assign  swap2_sel_byte5   = ~bendian_pred_m & ~(byp_word_m | byp_hword_m | byp_byte_m) ;

// Swap byp_byte_m 3 
assign  swap3_sel_byte0   = ~bendian_pred_m & byp_word_m ;
assign  swap3_sel_byte2   = ~bendian_pred_m & byp_hword_m ;
assign  swap3_sel_byte3   = bendian_pred_m | (~bendian_pred_m & byp_byte_m) ;
assign  swap3_sel_byte4   = ~bendian_pred_m & ~(byp_word_m | byp_hword_m | byp_byte_m) ;

// Swap byp_byte_m 4 
assign  swap4_sel_byte3   = ~bendian_pred_m & ~(byp_word_m | byp_hword_m | byp_byte_m) ;
assign  swap4_sel_byte4   = bendian_pred_m | (~bendian_pred_m & byp_byte_m) ;
assign  swap4_sel_byte5   = ~bendian_pred_m & byp_hword_m ;
//assign  swap4_sel_byte7   = ~bendian_pred_m & byp_word_m ;

// Swap byp_byte_m 5 
assign  swap5_sel_byte2   = ~bendian_pred_m & ~(byp_word_m | byp_hword_m | byp_byte_m) ;
assign  swap5_sel_byte4   = ~bendian_pred_m & byp_hword_m ;
assign  swap5_sel_byte5   = bendian_pred_m | (~bendian_pred_m & byp_byte_m) ;
assign  swap5_sel_byte6   = ~bendian_pred_m & byp_word_m ;

// Swap byp_byte_m 6 
assign  swap6_sel_byte1   = ~bendian_pred_m & ~(byp_word_m | byp_hword_m | byp_byte_m) ;
assign  swap6_sel_byte5   = ~bendian_pred_m & byp_word_m ;
assign  swap6_sel_byte6   = bendian_pred_m | (~bendian_pred_m & byp_byte_m) ;
//assign  swap6_sel_byte7   = ~bendian_pred_m & byp_hword_m ;

// Swap byp_byte_m 7 
assign  swap7_sel_byte0   = ~bendian_pred_m & ~(byp_word_m | byp_hword_m | byp_byte_m) ;
assign  swap7_sel_byte4   = ~bendian_pred_m & byp_word_m ;
assign  swap7_sel_byte6   = ~bendian_pred_m & byp_hword_m ;
assign  swap7_sel_byte7   = bendian_pred_m | (~bendian_pred_m & byp_byte_m) ;

// 2nd logical level - Alignment. 
// rjust7-rjust0 is result of alignment operation.
// sbyte7-sbyte0 is the result of the endian swapping from the 1st logic level.

wire  rjust0_sel_sbyte0, rjust0_sel_sbyte1, rjust0_sel_sbyte2, rjust0_sel_sbyte3 ;
wire  rjust0_sel_sbyte4, rjust0_sel_sbyte5, rjust0_sel_sbyte6, rjust0_sel_sbyte7 ;
wire  rjust1_sel_sbyte1, rjust1_sel_sbyte3, rjust1_sel_sbyte5, rjust1_sel_sbyte7 ;
wire  rjust2_sel_sbyte2, rjust2_sel_sbyte6 ;
wire  rjust3_sel_sbyte3, rjust3_sel_sbyte7 ;

// Aligned Byte 0
assign  rjust0_sel_sbyte0   = 
  ~(rjust0_sel_sbyte1 | rjust0_sel_sbyte2 | rjust0_sel_sbyte3 |
    rjust0_sel_sbyte4 | rjust0_sel_sbyte5 | rjust0_sel_sbyte6 |
    rjust0_sel_sbyte7) ;
assign  rjust0_sel_sbyte1   = 
//  ((byp_baddr_m[14] | byp_baddr_m[6]) & byp_byte_m) ;
  ((byp_baddr_m[6]) & byp_byte_m) ;

assign  rjust0_sel_sbyte2   = 
//  ((byp_baddr_m[12] | byp_baddr_m[4]) & byp_hword_m) | 
  ((byp_baddr_m[4]) & byp_hword_m) | 
//  ((byp_baddr_m[13] | byp_baddr_m[5]) & byp_byte_m) ;
  ((byp_baddr_m[5]) & byp_byte_m) ;
assign  rjust0_sel_sbyte3 = 
//  (byp_baddr_m[12] | byp_baddr_m[4]) & byp_byte_m ; 
  (byp_baddr_m[4]) & byp_byte_m ; 
assign  rjust0_sel_sbyte4 = 
//  ((byp_baddr_m[10] | byp_baddr_m[2]) & byp_hword_m) | 
//  ((byp_baddr_m[11] | byp_baddr_m[3]) & byp_byte_m) |
//  ((byp_baddr_m[8] | byp_baddr_m[0]) & byp_word_m) ;
  ((byp_baddr_m[2]) & byp_hword_m) | 
  ((byp_baddr_m[3]) & byp_byte_m) |
  ((byp_baddr_m[0]) & byp_word_m) ;
assign  rjust0_sel_sbyte5 = 
//  ((byp_baddr_m[10] | byp_baddr_m[2]) & byp_byte_m) ; 
  ((byp_baddr_m[2]) & byp_byte_m) ; 
assign  rjust0_sel_sbyte6 = 
//  ((byp_baddr_m[8] | byp_baddr_m[0]) & byp_hword_m) | 
//  ((byp_baddr_m[9] | byp_baddr_m[1]) & byp_byte_m) ;
  ((byp_baddr_m[0]) & byp_hword_m) | 
  ((byp_baddr_m[1]) & byp_byte_m) ;
assign  rjust0_sel_sbyte7 = 
//  (byp_baddr_m[8] | byp_baddr_m[0]) & byp_byte_m ;
  (byp_baddr_m[0]) & byp_byte_m ;

// Aligned Byte 1
assign  rjust1_sel_sbyte1   = 
  ~(rjust1_sel_sbyte3 | rjust1_sel_sbyte5 | rjust1_sel_sbyte7) ;
assign  rjust1_sel_sbyte3   = 
//  (byp_baddr_m[12] | byp_baddr_m[4]) & byp_hword_m ;
  (byp_baddr_m[4]) & byp_hword_m ;
assign  rjust1_sel_sbyte5   = 
//  ((byp_baddr_m[10] | byp_baddr_m[2]) & byp_hword_m) | 
//  ((byp_baddr_m[8] | byp_baddr_m[0]) & byp_word_m) ;
  ((byp_baddr_m[2]) & byp_hword_m) | 
  ((byp_baddr_m[0]) & byp_word_m) ;
assign  rjust1_sel_sbyte7   = 
//  (byp_baddr_m[8] | byp_baddr_m[0]) & byp_hword_m ;
  (byp_baddr_m[0]) & byp_hword_m ;

// Aligned Byte 2
assign  rjust2_sel_sbyte2   = ~rjust2_sel_sbyte6 ;
//assign  rjust2_sel_sbyte6   = (byp_baddr_m[8] | byp_baddr_m[0]) & byp_word_m ;
assign  rjust2_sel_sbyte6   = (byp_baddr_m[0]) & byp_word_m ;

// Aligned Byte 3
assign  rjust3_sel_sbyte3   = ~rjust3_sel_sbyte7 ;
//assign  rjust3_sel_sbyte7   = (byp_baddr_m[8] | byp_baddr_m[0]) & byp_word_m ;
assign  rjust3_sel_sbyte7   = (byp_baddr_m[0]) & byp_word_m ;

// 3rd logical level - Complete alignment. Sign-Extension/Zero-Extension.
// merge7-merge0 corresponds to cumulative swapping and alignment result.
// byte[7]-byte[0] refers to the original pre-swap/alignment data.

wire merge7_sel_byte0_m, merge7_sel_byte7_m;
wire merge6_sel_byte1_m, merge6_sel_byte6_m;
wire merge5_sel_byte2_m, merge5_sel_byte5_m;
wire merge4_sel_byte3_m, merge4_sel_byte4_m;
wire merge3_sel_byte0_m, merge3_sel_byte3_m;
wire merge3_sel_byte4_m, merge3_sel_byte7_m,merge3_sel_byte_m;
wire merge2_sel_byte1_m, merge2_sel_byte2_m, merge2_sel_byte5_m;
wire merge2_sel_byte6_m, merge2_sel_byte_m;
wire merge0_sel_byte0_m, merge0_sel_byte1_m;
wire merge0_sel_byte2_m, merge0_sel_byte3_m;
wire merge0_sel_byte4_m, merge0_sel_byte5_m;
wire merge0_sel_byte6_m;
wire merge1_sel_byte0_m, merge1_sel_byte1_m;
wire merge1_sel_byte2_m, merge1_sel_byte3_m;
wire merge1_sel_byte4_m, merge1_sel_byte5_m;
wire merge1_sel_byte6_m, merge1_sel_byte7_m;
wire merge0_sel_byte_1h_m,merge1_sel_byte_1h_m, merge1_sel_byte_2h_m;

// Final Merged Byte 0
assign  merge0_sel_byte0_m  = 
  (rjust0_sel_sbyte0 & swap0_sel_byte0) |
  (rjust0_sel_sbyte1 & swap1_sel_byte0) |
  (rjust0_sel_sbyte3 & swap3_sel_byte0) |
  (rjust0_sel_sbyte7 & swap7_sel_byte0) ;

assign  merge0_sel_byte1_m  = 
  (rjust0_sel_sbyte0 & swap0_sel_byte1) |
  (rjust0_sel_sbyte1 & swap1_sel_byte1) |
  (rjust0_sel_sbyte2 & swap2_sel_byte1) |
  (rjust0_sel_sbyte6 & swap6_sel_byte1) ;

assign  merge0_sel_byte2_m  = 
  (rjust0_sel_sbyte1 & swap1_sel_byte2) |
  (rjust0_sel_sbyte2 & swap2_sel_byte2) |
  (rjust0_sel_sbyte3 & swap3_sel_byte2) |
  (rjust0_sel_sbyte5 & swap5_sel_byte2) ;

   
assign  merge0_sel_byte3_m  = 
  (rjust0_sel_sbyte0 & swap0_sel_byte3) |
  (rjust0_sel_sbyte2 & swap2_sel_byte3) |
  (rjust0_sel_sbyte3 & swap3_sel_byte3) |
  (rjust0_sel_sbyte4 & swap4_sel_byte3) ;

assign merge0_sel_byte3_default_m = ~ (merge0_sel_byte0_m | merge0_sel_byte1_m | merge0_sel_byte2_m);

assign  merge0_sel_byte4_m  = 
  (rjust0_sel_sbyte3 & swap3_sel_byte4) |
  (rjust0_sel_sbyte4 & swap4_sel_byte4) |
  (rjust0_sel_sbyte5 & swap5_sel_byte4) |
  (rjust0_sel_sbyte7 & swap7_sel_byte4) ;

assign  merge0_sel_byte5_m  = 
  (rjust0_sel_sbyte2 & swap2_sel_byte5) |
  (rjust0_sel_sbyte4 & swap4_sel_byte5) |
  (rjust0_sel_sbyte5 & swap5_sel_byte5) |
  (rjust0_sel_sbyte6 & swap6_sel_byte5) ;

assign  merge0_sel_byte6_m  = 
  (rjust0_sel_sbyte1 & swap1_sel_byte6) |
  (rjust0_sel_sbyte5 & swap5_sel_byte6) |
  (rjust0_sel_sbyte6 & swap6_sel_byte6) |
  (rjust0_sel_sbyte7 & swap7_sel_byte6) ;

//assign  merge0_sel_byte7_m  = 
//  (rjust0_sel_sbyte0 & swap0_sel_byte7) |
//  (rjust0_sel_sbyte4 & swap4_sel_byte7) |
//  (rjust0_sel_sbyte6 & swap6_sel_byte7) |
//  (rjust0_sel_sbyte7 & swap7_sel_byte7) ;

   assign merge0_sel_byte7_default_m = ~(merge0_sel_byte4_m | merge0_sel_byte5_m |  merge0_sel_byte6_m);
   
assign  merge0_sel_byte_1h_m = 
  merge0_sel_byte0_m |  merge0_sel_byte1_m | merge0_sel_byte2_m | merge0_sel_byte3_m ;

// Final Merged Byte 1
assign  merge1_sel_byte0_m  = 
  (rjust1_sel_sbyte1 & swap1_sel_byte0) |
  (rjust1_sel_sbyte3 & swap3_sel_byte0) |
  (rjust1_sel_sbyte7 & swap7_sel_byte0) ;

assign  merge1_sel_byte1_m  = 
  (rjust1_sel_sbyte1 & swap1_sel_byte1) ;

assign  merge1_sel_byte2_m  = 
  (rjust1_sel_sbyte1 & swap1_sel_byte2) |
  (rjust1_sel_sbyte3 & swap3_sel_byte2) |
  (rjust1_sel_sbyte5 & swap5_sel_byte2) ;

assign  merge1_sel_byte3_m  = 
  (rjust1_sel_sbyte3 & swap3_sel_byte3) ;

   assign merge1_sel_byte3_default_m = ~( merge1_sel_byte0_m | merge1_sel_byte1_m | merge1_sel_byte2_m);
                                              
assign  merge1_sel_byte4_m  = 
  (rjust1_sel_sbyte3 & swap3_sel_byte4) |
  (rjust1_sel_sbyte5 & swap5_sel_byte4) |
  (rjust1_sel_sbyte7 & swap7_sel_byte4) ;

assign  merge1_sel_byte5_m  = 
  (rjust1_sel_sbyte5 & swap5_sel_byte5) ;

assign  merge1_sel_byte6_m  = 
  (rjust1_sel_sbyte1 & swap1_sel_byte6) |
  (rjust1_sel_sbyte5 & swap5_sel_byte6) |
  (rjust1_sel_sbyte7 & swap7_sel_byte6) ;

assign  merge1_sel_byte7_m  = 
  (rjust1_sel_sbyte7 & swap7_sel_byte7) ;

   assign merge1_sel_byte7_default_m = ~( merge1_sel_byte4_m | merge1_sel_byte5_m | merge1_sel_byte6_m);
   
assign  merge1_sel_byte_1h_m = ~byp_byte_m &
  (merge1_sel_byte0_m |  merge1_sel_byte1_m | merge1_sel_byte2_m | merge1_sel_byte3_m) ;
   
assign  merge1_sel_byte_2h_m = ~byp_byte_m &
  (merge1_sel_byte4_m |  merge1_sel_byte5_m | merge1_sel_byte6_m | merge1_sel_byte7_m) ;


// Final Merged Byte 2

assign  merge2_sel_byte1_m  = 
  (rjust2_sel_sbyte2 & swap2_sel_byte1) |
  (rjust2_sel_sbyte6 & swap6_sel_byte1) ;

assign  merge2_sel_byte2_m  = 
  (rjust2_sel_sbyte2 & swap2_sel_byte2) ;

assign  merge2_sel_byte5_m  = 
  (rjust2_sel_sbyte2 & swap2_sel_byte5) |
  (rjust2_sel_sbyte6 & swap6_sel_byte5) ;

assign  merge2_sel_byte6_m  = 
  (rjust2_sel_sbyte6 & swap6_sel_byte6) ;

   assign merge2_sel_byte6_default_m  = ~(merge2_sel_byte1_m | merge2_sel_byte2_m | merge2_sel_byte5_m);
    
assign merge2_sel_byte_m = ~byp_byte_m & ~byp_hword_m &
(merge2_sel_byte1_m | merge2_sel_byte2_m | merge2_sel_byte5_m | merge2_sel_byte6_m);   

// Final Merged Byte 3
assign  merge3_sel_byte0_m  = 
  (rjust3_sel_sbyte3 & swap3_sel_byte0) |
  (rjust3_sel_sbyte7 & swap7_sel_byte0) ;

assign  merge3_sel_byte3_m  = 
  (rjust3_sel_sbyte3 & swap3_sel_byte3) ;

assign  merge3_sel_byte4_m  = 
  (rjust3_sel_sbyte3 & swap3_sel_byte4) |
  (rjust3_sel_sbyte7 & swap7_sel_byte4) ;

assign  merge3_sel_byte7_m  = 
  (rjust3_sel_sbyte7 & swap7_sel_byte7) ;

assign merge3_sel_byte7_default_m  =  ~(merge3_sel_byte0_m | merge3_sel_byte3_m | merge3_sel_byte4_m);

assign merge3_sel_byte_m = ~byp_byte_m & ~byp_hword_m & 
(merge3_sel_byte0_m | merge3_sel_byte3_m | merge3_sel_byte4_m | merge3_sel_byte7_m);
   
// Final Merged Byte 4
assign  merge4_sel_byte3_m = byp_dword_m & swap4_sel_byte3 ;
assign  merge4_sel_byte4_m = byp_dword_m & swap4_sel_byte4 ;


// Final Merged Byte 5
assign  merge5_sel_byte2_m = byp_dword_m & swap5_sel_byte2 ;
assign  merge5_sel_byte5_m = byp_dword_m & swap5_sel_byte5 ;

// Final Merged Byte 6
assign  merge6_sel_byte1_m = byp_dword_m & swap6_sel_byte1 ;
assign  merge6_sel_byte6_m = byp_dword_m & swap6_sel_byte6 ;

// Final Merged Byte 7
assign  merge7_sel_byte0_m = byp_dword_m & swap7_sel_byte0 ;
assign  merge7_sel_byte7_m = byp_dword_m & swap7_sel_byte7 ;



//=========================================================================================
//  STQ/CAS 2ND PKT FORMATTING 
//=========================================================================================

// stq and cas write to an extra buffer. stq always uses a full 64bits.
// cas may use either 64b or 32b. stq requires at most endian alignment.
// cas may require both address and endian alignment.

// Byte Alignment. Assume 8 bytes, 7-0
//  Case 1 : 7,6,5,4,3,2,1,0 
//  Case 2 : 3,2,1,0,0,1,2,3 
//  Case 3 : 0,1,2,3,4,5,6,7  

wire casa_wd_g ;
assign  casa_wd_g = casa_g & byp_word_g ;
wire casa_dwd_g ;
assign  casa_dwd_g = casa_g & ~byp_word_g ;

// Change bendian to bendian_g - should not be dependent on fill. 

//assign  lsu_atomic_pkt2_bsel_g[2] =   // Case 1
//  (casa_dwd_g &  bendian_g)   |  // bendian stq and dw cas
//  (casa_wd_g &  bendian_g &  ldst_va_g[2]) ;  // bendian_g wd casa addr to uhalf

assign lsu_atomic_pkt2_bsel_g[2] = ~| (lsu_atomic_pkt2_bsel_g[1:0]) | rst_tri_en ; //one-hot default

assign  lsu_atomic_pkt2_bsel_g[1] =   // Case 2
  ((casa_wd_g &  bendian_g & ~ldst_va_g[2]) |  // bendian_g wd casa addr to lhalf
  (casa_wd_g & ~bendian_g &  ldst_va_g[2])) &  ~rst_tri_en ;  // lendian wd casa addr to uhalf
assign  lsu_atomic_pkt2_bsel_g[0] =   // Case 3 
  ((casa_dwd_g & ~bendian_g) |    // lendian stq and dw cas
  (casa_wd_g & ~bendian_g & ~ldst_va_g[2])) &  ~rst_tri_en ;  // lendian wd cas addr to lhalf

// Alignment done in qdp1

//=========================================================================================
//  ASI DECODE
//=========================================================================================

// Note : tlb_byp_asi same as phy_use/phy_byp asi.


lsu_asi_decode asi_decode (/*AUTOINST*/
                           // Outputs
                           .asi_internal_d(asi_internal_d),
                           .nucleus_asi_d(nucleus_asi_d),
                           .primary_asi_d(primary_asi_d),
                           .secondary_asi_d(secondary_asi_d),
                           .lendian_asi_d(lendian_asi_d),
                           .nofault_asi_d(nofault_asi_d),
                           .quad_asi_d  (quad_asi_d),
                           .binit_quad_asi_d(binit_quad_asi_d),
                           .dcache_byp_asi_d(dcache_byp_asi_d),
                           .tlb_lng_ltncy_asi_d(tlb_lng_ltncy_asi_d),
                           .tlb_byp_asi_d(tlb_byp_asi_d),
                           .as_if_user_asi_d(as_if_user_asi_d),
                           .atomic_asi_d(atomic_asi_d),
                           .blk_asi_d   (blk_asi_d),
                           .dc_diagnstc_asi_d(dc_diagnstc_asi_d),
                           .dtagv_diagnstc_asi_d(dtagv_diagnstc_asi_d),
                           .wr_only_asi_d(wr_only_asi_d),
                           .rd_only_asi_d(rd_only_asi_d),
                           .unimp_asi_d (unimp_asi_d),
                           .ifu_nontlb_asi_d(ifu_nontlb_asi_d),
                           .recognized_asi_d(recognized_asi_d),
                           .ifill_tlb_asi_d(ifill_tlb_asi_d),
                           .dfill_tlb_asi_d(dfill_tlb_asi_d),
                           .rd_only_ltlb_asi_d(rd_only_ltlb_asi_d),
                           .wr_only_ltlb_asi_d(wr_only_ltlb_asi_d),
                           .phy_use_ec_asi_d(phy_use_ec_asi_d),
                           .phy_byp_ec_asi_d(phy_byp_ec_asi_d),
                           .mmu_rd_only_asi_d(mmu_rd_only_asi_d),
                           .intrpt_disp_asi_d(intrpt_disp_asi_d),
                           .dmmu_asi58_d(dmmu_asi58_d),
                           .immu_asi50_d(immu_asi50_d),
                           // Inputs
                           .asi_d       (asi_d[7:0]));

dff_s #(31)  asidcd_stge (
        .din    ({asi_internal_d,primary_asi_d,secondary_asi_d,nucleus_asi_d,
    lendian_asi_d, tlb_byp_asi_d, dcache_byp_asi_d,nofault_asi_d,
    tlb_lng_ltncy_asi_d,as_if_user_asi_d,atomic_asi_d, blk_asi_d,
    dc_diagnstc_asi_d,dtagv_diagnstc_asi_d,
    wr_only_asi_d, rd_only_asi_d,mmu_rd_only_asi_d,unimp_asi_d,dmmu_asi58_d, immu_asi50_d, quad_asi_d, binit_quad_asi_d,
    ifu_nontlb_asi_d,recognized_asi_d, ifill_tlb_asi_d,
    dfill_tlb_asi_d, rd_only_ltlb_asi_d,wr_only_ltlb_asi_d,phy_use_ec_asi_d, phy_byp_ec_asi_d, intrpt_disp_asi_d}),
        .q      ({asi_internal_e,primary_asi_e,secondary_asi_e,nucleus_asi_e,
    lendian_asi_e, tlb_byp_asi_e, dcache_byp_asi_e,nofault_asi_e,
    tlb_lng_ltncy_asi_e,as_if_user_asi_e,atomic_asi_e, blk_asi_e,
    dc_diagnstc_asi_e,dtagv_diagnstc_asi_e,
    wr_only_asi_e, rd_only_asi_e,mmu_rd_only_asi_e,unimp_asi_e,dmmu_asi58_e, immu_asi50_e, quad_asi_e, binit_quad_asi_e,
    ifu_nontlb_asi_e,recognized_asi_e,ifill_tlb_asi_e,
    dfill_tlb_asi_e,rd_only_ltlb_asi_e,wr_only_ltlb_asi_e,phy_use_ec_asi_e, phy_byp_ec_asi_e, intrpt_disp_asi_e}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign	lsu_ffu_blk_asi_e = blk_asi_e & alt_space_e;
assign  lsu_quad_asi_e = quad_asi_e ;

wire	unimp_asi_tmp ;
dff_s #(23)  asidcd_stgm (
        .din    ({asi_internal_e,dcache_byp_asi_e,nofault_asi_e,lendian_asi_e,tlb_lng_ltncy_asi_e,
    as_if_user_asi_e,atomic_asi_e, blk_asi_e,dc_diagnstc_asi_e,dtagv_diagnstc_asi_e,
    wr_only_asi_e, rd_only_asi_e,mmu_rd_only_asi_e,unimp_asi_e,dmmu_asi58_e, immu_asi50_e, quad_asi_e,binit_quad_asi_e,recognized_asi_e,
    ifu_nontlb_asi_e,phy_use_ec_asi_e, phy_byp_ec_asi_e, intrpt_disp_asi_e}),
        .q      ({asi_internal_m,dcache_byp_asi_m,nofault_asi_m,lendian_asi_m,tlb_lng_ltncy_asi_m,
    as_if_user_asi_m,atomic_asi_m, blk_asi_m,dc_diagnstc_asi_m,dtagv_diagnstc_asi_m,
    wr_only_asi_m, rd_only_asi_m,mmu_rd_only_asi_m,unimp_asi_tmp,dmmu_asi58_m, immu_asi50_m, quad_asi_m,binit_quad_asi_m,recognized_asi_tmp,
    ifu_nontlb_asi_m,phy_use_ec_asi_m, phy_byp_ec_asi_m, intrpt_disp_asi_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

assign	lsu_blk_asi_m = blk_asi_m ;

   wire	pa_wtchpt_unimp_m ; // Bug 3408
   wire d_tsb_unimp_m, i_tsb_unimp_m, pctxt_unimp_m, sctxt_unimp_m;
   wire unimp_m;
   
assign  pa_wtchpt_unimp_m  = dmmu_asi58_m & (lsu_ldst_va_b7_b0_m[7:0] == 8'h40);
assign  d_tsb_unimp_m = dmmu_asi58_m & (lsu_ldst_va_b7_b0_m[7:0] == 8'h28);
assign  pctxt_unimp_m = dmmu_asi58_m & (lsu_ldst_va_b7_b0_m[7:0] == 8'h8);   
assign  sctxt_unimp_m = dmmu_asi58_m & (lsu_ldst_va_b7_b0_m[7:0] == 8'h10);
assign  i_tsb_unimp_m = immu_asi50_m & (lsu_ldst_va_b7_b0_m[7:0] == 8'h28);
assign  unimp_m =  pa_wtchpt_unimp_m |  
                   d_tsb_unimp_m | i_tsb_unimp_m |
                   pctxt_unimp_m | sctxt_unimp_m;
   
assign	unimp_asi_m = unimp_asi_tmp | unimp_m ;
assign	recognized_asi_m = recognized_asi_tmp | unimp_m ;

dff_s #(12)  asidcd_stgg (
        .din    ({asi_internal_m,dcache_byp_asi_m, lendian_asi_m,tlb_lng_ltncy_asi_m,
  blk_asi_m,dc_diagnstc_asi_m,dtagv_diagnstc_asi_m,quad_asi_m,
  binit_quad_asi_m,recognized_asi_m,ifu_nontlb_asi_m,  intrpt_disp_asi_m}),
        .q      ({asi_internal_g,dcache_byp_asi_g, lendian_asi_g,tlb_lng_ltncy_asi_g,
  blk_asi_g,dc_diagnstc_asi_g,dtagv_diagnstc_asi_g,quad_asi_g,
  binit_quad_asi_g,recognized_asi_g,ifu_nontlb_asi_g,  intrpt_disp_asi_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

//assign lsu_quad_asi_g = quad_asi_g;
assign  ncache_asild_rq_g   = dcache_byp_asi_g & altspace_ldst_g ;

//st data alignment control signals
wire st_sz_hw_g, st_sz_w_g, st_sz_dw_g, stdbl_g;
wire stdbl_m;

//assign stdbl_m =  ldst_dbl_m & (~lsu_alt_space_m | (lsu_alt_space_m & ~blk_asi_m)) ;
assign stdbl_m =  ldst_dbl_m ;
         
dff_s #(4) ff_st_sz_m (
  .din ({hw_size, wd_size, dw_size, stdbl_m }),
  .q   ({st_sz_hw_g, st_sz_w_g, st_sz_dw_g, stdbl_g}),
  .clk (clk),                   
  .se  (se), .si (), .so ()
);   

   
//assign	bendian = lsu_bendian_access_g ;	// bendian store

wire	swap_sel_default_g, swap_sel_default_byte_7_2_g, st_hw_le_g,st_w_or_dbl_le_g,st_x_le_g;
assign	bendian_g = ~l1hit_lendian_g ;
//assign	swap_sel_default_g = (bendian_g | (~bendian_g & st_sz_b_g)) ;

assign swap_sel_default_g = ~ (st_hw_le_g | st_w_or_dbl_le_g | st_x_le_g);
assign swap_sel_default_byte_7_2_g = ~ (st_w_or_dbl_le_g | st_x_le_g);
   
assign  st_hw_le_g = (st_sz_hw_g & ~bendian_g) & (~stdbl_g | fp_ldst_g) & st_inst_vld_unflushed ;  //0-in bug
//bug 3169 
// std(a) on floating point is the same as stx(a)
assign  st_w_or_dbl_le_g = ((st_sz_w_g | (stdbl_g & ~fp_ldst_g)) & ~bendian_g) &  st_inst_vld_unflushed ;
assign  st_x_le_g = (st_sz_dw_g & (~stdbl_g | fp_ldst_g)  & ~bendian_g) &  st_inst_vld_unflushed;

wire blkst_m_tmp ;
dff_s  stgm_bst (
  .din (ffu_lsu_blk_st_e),
  .q   (blkst_m_tmp),
  .clk (clk),
  .se     (se),       .si (),          .so ()
);

assign	blkst_m = blkst_m_tmp & ~(st_inst_vld_m  | flsh_inst_m 
		| ld_inst_vld_m) ; // Bug 3444

assign	lsu_blk_st_m = blkst_m ;

dff_s  stgg_bst (
  .din (blkst_m),
  .q   (blkst_g),
  .clk (clk),
  .se     (se),       .si (),          .so ()
);

wire	bst_swap_sel_default_g,	bst_swap_sel_default_byte_7_2_g,bst_st_hw_le_g,bst_st_w_or_dbl_le_g,bst_st_x_le_g;
assign	lsu_swap_sel_default_g = (blkst_g ? bst_swap_sel_default_g : swap_sel_default_g) | rst_tri_en ;
assign	lsu_swap_sel_default_byte_7_2_g = (blkst_g ? bst_swap_sel_default_byte_7_2_g : swap_sel_default_byte_7_2_g) 
                                         | rst_tri_en ;

assign	lsu_st_hw_le_g	= (blkst_g ? bst_st_hw_le_g : st_hw_le_g) & ~rst_tri_en ;
assign	lsu_st_w_or_dbl_le_g = (blkst_g ? bst_st_w_or_dbl_le_g : st_w_or_dbl_le_g) & ~rst_tri_en ;
assign	lsu_st_x_le_g = (blkst_g ? bst_st_x_le_g : st_x_le_g) & ~rst_tri_en ;


//=========================================================================================
//	BLK STORE
//=========================================================================================

// Blk-St Handling : Snap state in g-stage of issue from IFU.

wire snap_blk_st_m,snap_blk_st_g ;
assign snap_blk_st_m = st_inst_vld_m & blk_asi_m & lsu_alt_space_m & fp_ldst_m;

assign lsu_snap_blk_st_m = snap_blk_st_m ; 

wire	snap_blk_st_local_m;
assign	snap_blk_st_local_m = snap_blk_st_m & ifu_tlu_inst_vld_m ;

dff_s  stgg_snap (
  .din (snap_blk_st_local_m),
  .q   (snap_blk_st_g),
  .clk (clk),
  .se     (se),       .si (),          .so ()
);

// output to be used in g-stage.
dffe_s #(5) bst_state_g (
        .din    ({lsu_swap_sel_default_g, lsu_swap_sel_default_byte_7_2_g, lsu_st_hw_le_g,
		lsu_st_w_or_dbl_le_g,lsu_st_x_le_g}),
        .q      ({bst_swap_sel_default_g, bst_swap_sel_default_byte_7_2_g,  bst_st_hw_le_g,
		bst_st_w_or_dbl_le_g,bst_st_x_le_g}),
        .en     (snap_blk_st_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );


// snapped in g, used in m

   wire [39:10] blkst_pgnum_m;
   
dffe_s #(30) bst_pg_g (
        .din    (tlb_pgnum[39:10]),
        .q      (blkst_pgnum_m[39:10]),
        .en     (snap_blk_st_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b10 (.a(blkst_pgnum_m[10]), .z(lsu_blkst_pgnum_m[10]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b11 (.a(blkst_pgnum_m[11]), .z(lsu_blkst_pgnum_m[11]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b12 (.a(blkst_pgnum_m[12]), .z(lsu_blkst_pgnum_m[12]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b13 (.a(blkst_pgnum_m[13]), .z(lsu_blkst_pgnum_m[13]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b14 (.a(blkst_pgnum_m[14]), .z(lsu_blkst_pgnum_m[14]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b15 (.a(blkst_pgnum_m[15]), .z(lsu_blkst_pgnum_m[15]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b16 (.a(blkst_pgnum_m[16]), .z(lsu_blkst_pgnum_m[16]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b17 (.a(blkst_pgnum_m[17]), .z(lsu_blkst_pgnum_m[17]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b18 (.a(blkst_pgnum_m[18]), .z(lsu_blkst_pgnum_m[18]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b19 (.a(blkst_pgnum_m[19]), .z(lsu_blkst_pgnum_m[19]));

bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b20 (.a(blkst_pgnum_m[20]), .z(lsu_blkst_pgnum_m[20]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b21 (.a(blkst_pgnum_m[21]), .z(lsu_blkst_pgnum_m[21]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b22 (.a(blkst_pgnum_m[22]), .z(lsu_blkst_pgnum_m[22]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b23 (.a(blkst_pgnum_m[23]), .z(lsu_blkst_pgnum_m[23]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b24 (.a(blkst_pgnum_m[24]), .z(lsu_blkst_pgnum_m[24]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b25 (.a(blkst_pgnum_m[25]), .z(lsu_blkst_pgnum_m[25]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b26 (.a(blkst_pgnum_m[26]), .z(lsu_blkst_pgnum_m[26]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b27 (.a(blkst_pgnum_m[27]), .z(lsu_blkst_pgnum_m[27]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b28 (.a(blkst_pgnum_m[28]), .z(lsu_blkst_pgnum_m[28]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b29 (.a(blkst_pgnum_m[29]), .z(lsu_blkst_pgnum_m[29]));
   
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b30 (.a(blkst_pgnum_m[30]), .z(lsu_blkst_pgnum_m[30]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b31 (.a(blkst_pgnum_m[31]), .z(lsu_blkst_pgnum_m[31]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b32 (.a(blkst_pgnum_m[32]), .z(lsu_blkst_pgnum_m[32]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b33 (.a(blkst_pgnum_m[33]), .z(lsu_blkst_pgnum_m[33]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b34 (.a(blkst_pgnum_m[34]), .z(lsu_blkst_pgnum_m[34]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b35 (.a(blkst_pgnum_m[35]), .z(lsu_blkst_pgnum_m[35]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b36 (.a(blkst_pgnum_m[36]), .z(lsu_blkst_pgnum_m[36]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b37 (.a(blkst_pgnum_m[37]), .z(lsu_blkst_pgnum_m[37]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b38 (.a(blkst_pgnum_m[38]), .z(lsu_blkst_pgnum_m[38]));
bw_u1_minbuf_5x UZfix_lsu_blkst_pgnum_m_b39 (.a(blkst_pgnum_m[39]), .z(lsu_blkst_pgnum_m[39]));


`ifndef NO_RTL_CSM
   
dffe_s #(`TLB_CSM_WIDTH) bst_csm_g (
        .din    (tlb_rd_tte_csm),
        .q      (lsu_blkst_csm_m),
        .en     (snap_blk_st_g),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

`endif



//=========================================================================================
//  Prefetch Count
//=========================================================================================

wire [3:0] lsu_cpx_pref_ack;
wire [3:0] no_spc_pref;

wire	[3:0]	pref_ackcnt0,pref_ackcnt1,pref_ackcnt2,pref_ackcnt3 ;
wire	[3:0]	pref_ackcnt0_din,pref_ackcnt1_din,pref_ackcnt2_din,pref_ackcnt3_din ;

wire 	[3:0]	pref_ackcnt_incr, pref_ackcnt_decr ;
wire 	[3:0]	pref_ackcnt_mx_incr, pref_ackcnt_mx_decr ;

   wire     lsu_pref_pcx_req_d1;
   
dff_s #(1) pref_pcx_req_stg (
         .din (lsu_pref_pcx_req),
         .q   (lsu_pref_pcx_req_d1),
         .clk (clk),
         .se  (se),       .si (),          .so ()
);                   

assign   lsu_pcx_pref_issue[0] =  lsu_pref_pcx_req_d1 & lsu_ld_pcx_rq_sel_d2[0] & ~lsu_pcx_req_squash_d1;
assign   lsu_pcx_pref_issue[1] =  lsu_pref_pcx_req_d1 & lsu_ld_pcx_rq_sel_d2[1] & ~lsu_pcx_req_squash_d1;
assign   lsu_pcx_pref_issue[2] =  lsu_pref_pcx_req_d1 & lsu_ld_pcx_rq_sel_d2[2] & ~lsu_pcx_req_squash_d1;
assign   lsu_pcx_pref_issue[3] =  lsu_pref_pcx_req_d1 & lsu_ld_pcx_rq_sel_d2[3] & ~lsu_pcx_req_squash_d1;
  

   wire [3:0] pref_acknt_mx_incr_sel;
   assign     pref_acknt_mx_incr_sel[3:0] = lsu_pcx_pref_issue[3:0];

assign  pref_ackcnt_mx_incr[3:0] = 
  (pref_acknt_mx_incr_sel[0] ? pref_ackcnt0[3:0] : 4'b0) |
  (pref_acknt_mx_incr_sel[1] ? pref_ackcnt1[3:0] : 4'b0) |
  (pref_acknt_mx_incr_sel[2] ? pref_ackcnt2[3:0] : 4'b0) |
  (pref_acknt_mx_incr_sel[3] ? pref_ackcnt3[3:0] : 4'b0) ;
   
  
//====================================================================================
// prefetch ack back from CPX
   wire       dcfill_active_e;   
   assign dcfill_active_e = lsu_dfq_ld_vld & ~memref_e ;

   wire   dfq_thread0, dfq_thread1, dfq_thread2, dfq_thread3;

   assign dfq_thread0 = dfill_thread0;
   assign dfq_thread1 = dfill_thread1;
   assign dfq_thread2 = dfill_thread2;
   assign dfq_thread3 = dfill_thread3;
   
   assign lsu_cpx_pref_ack[0]  = dfq_thread0  & dcfill_active_e & lsu_cpx_pkt_prefetch2;
   assign lsu_cpx_pref_ack[1]  = dfq_thread1  & dcfill_active_e & lsu_cpx_pkt_prefetch2;
   assign lsu_cpx_pref_ack[2]  = dfq_thread2  & dcfill_active_e & lsu_cpx_pkt_prefetch2;
   assign lsu_cpx_pref_ack[3]  = dfq_thread3  & dcfill_active_e & lsu_cpx_pkt_prefetch2;
   
   wire [3:0] pref_acknt_mx_decr_sel;
   assign     pref_acknt_mx_decr_sel[3:0] = lsu_cpx_pref_ack[3:0];

assign    pref_ackcnt_mx_decr[3:0] =
  (pref_acknt_mx_decr_sel[0] ? pref_ackcnt0[3:0] : 4'b0) |
  (pref_acknt_mx_decr_sel[1] ? pref_ackcnt1[3:0] : 4'b0) |
  (pref_acknt_mx_decr_sel[2] ? pref_ackcnt2[3:0] : 4'b0) |
  (pref_acknt_mx_decr_sel[3] ? pref_ackcnt3[3:0] : 4'b0) ;
   
    
assign	pref_ackcnt_incr[3:0] = pref_ackcnt_mx_incr[3:0] + 4'b0001 ;
assign	pref_ackcnt_decr[3:0] = pref_ackcnt_mx_decr[3:0] - 4'b0001 ;

assign	pref_ackcnt0_din[3:0] = lsu_cpx_pref_ack[0] ? pref_ackcnt_decr[3:0] : pref_ackcnt_incr[3:0] ;
assign	pref_ackcnt1_din[3:0] = lsu_cpx_pref_ack[1] ? pref_ackcnt_decr[3:0] : pref_ackcnt_incr[3:0] ;
assign	pref_ackcnt2_din[3:0] = lsu_cpx_pref_ack[2] ? pref_ackcnt_decr[3:0] : pref_ackcnt_incr[3:0] ;
assign	pref_ackcnt3_din[3:0] = lsu_cpx_pref_ack[3] ? pref_ackcnt_decr[3:0] : pref_ackcnt_incr[3:0] ;

wire	[3:0]	pref_ackcnt_en ;
// if both occur in the same cycle then they cancel out.
assign	pref_ackcnt_en[0] = lsu_pcx_pref_issue[0] ^ lsu_cpx_pref_ack[0] ;
assign	pref_ackcnt_en[1] = lsu_pcx_pref_issue[1] ^ lsu_cpx_pref_ack[1] ;
assign	pref_ackcnt_en[2] = lsu_pcx_pref_issue[2] ^ lsu_cpx_pref_ack[2] ;
assign	pref_ackcnt_en[3] = lsu_pcx_pref_issue[3] ^ lsu_cpx_pref_ack[3] ;

// Thread0
dffre_s #(4)  pref_ackcnt0_ff (
        .din    (pref_ackcnt0_din[3:0]),
        .q      (pref_ackcnt0[3:0]),
        .rst    (reset),        .en     (pref_ackcnt_en[0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

// Thread1
dffre_s #(4)  pref_ackcnt1_ff (
        .din    (pref_ackcnt1_din[3:0]),
        .q      (pref_ackcnt1[3:0]),
        .rst    (reset),        .en     (pref_ackcnt_en[1]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

// Thread2
dffre_s #(4)  pref_ackcnt2_ff (
        .din    (pref_ackcnt2_din[3:0]),
        .q      (pref_ackcnt2[3:0]),
        .rst    (reset),        .en     (pref_ackcnt_en[2]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

// Thread3
dffre_s #(4)  pref_ackcnt3_ff (
        .din    (pref_ackcnt3_din[3:0]),
        .q      (pref_ackcnt3[3:0]),
        .rst    (reset),        .en     (pref_ackcnt_en[3]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );              

assign	no_spc_pref[0] = pref_ackcnt0[3] ;
assign	no_spc_pref[1] = pref_ackcnt1[3] ;
assign	no_spc_pref[2] = pref_ackcnt2[3] ;
assign	no_spc_pref[3] = pref_ackcnt3[3] ;

assign  lsu_no_spc_pref[3:0] = no_spc_pref[3:0];

//====================================================================
   wire lsu_bist_e;

   assign lsu_bist_e = lsu_bist_wvld_e | lsu_bist_rvld_e;

   wire [`L1D_ADDRESS_HI:0]      lmq_pcx_pkt_addr_din;

   wire [3:0] dfq_byp_thrd_sel;
   
mux4ds #(`L1D_ADDRESS_HI+1) lmq_pcx_pkt_addr_mux (
       .in0 ({lmq0_pcx_pkt_addr[`L1D_ADDRESS_HI:0]}),
       .in1 ({lmq1_pcx_pkt_addr[`L1D_ADDRESS_HI:0]}),
       .in2 ({lmq2_pcx_pkt_addr[`L1D_ADDRESS_HI:0]}),
       .in3 ({lmq3_pcx_pkt_addr[`L1D_ADDRESS_HI:0]}),
       .sel0(dfq_byp_thrd_sel[0]),
       .sel1(dfq_byp_thrd_sel[1]),
       .sel2(dfq_byp_thrd_sel[2]),
       .sel3(dfq_byp_thrd_sel[3]),
       .dout({lmq_pcx_pkt_addr_din[`L1D_ADDRESS_HI:0]})
);
                    
dffe_s #(`L1D_ADDRESS_HI+1)  lmq_pcx_pkt_addr_ff (
           .din    ({lmq_pcx_pkt_addr_din[`L1D_ADDRESS_HI:0]}),
           .q      ({lmq_pcx_pkt_addr[`L1D_ADDRESS_HI:0]}),
           .en     (dfq_byp_ff_en),
           .clk    (clk),
           .se     (se),       .si (),          .so ()
           );


   wire [`L1D_ADDRESS_HI:4] lmq_pcx_pkt_addr_minbf;
   // bw_u1_minbuf_5x UZfix_lmq_pcx_pkt_addr_minbf_b10 (.a(lmq_pcx_pkt_addr[10]), .z(lmq_pcx_pkt_addr_minbf[10]));
   // bw_u1_minbuf_5x UZfix_lmq_pcx_pkt_addr_minbf_b9 (.a(lmq_pcx_pkt_addr[9]), .z(lmq_pcx_pkt_addr_minbf[9]));
   // bw_u1_minbuf_5x UZfix_lmq_pcx_pkt_addr_minbf_b8 (.a(lmq_pcx_pkt_addr[8]), .z(lmq_pcx_pkt_addr_minbf[8]));
   // bw_u1_minbuf_5x UZfix_lmq_pcx_pkt_addr_minbf_b7 (.a(lmq_pcx_pkt_addr[7]), .z(lmq_pcx_pkt_addr_minbf[7]));
   // bw_u1_minbuf_5x UZfix_lmq_pcx_pkt_addr_minbf_b6 (.a(lmq_pcx_pkt_addr[6]), .z(lmq_pcx_pkt_addr_minbf[6]));
   // bw_u1_minbuf_5x UZfix_lmq_pcx_pkt_addr_minbf_b5 (.a(lmq_pcx_pkt_addr[5]), .z(lmq_pcx_pkt_addr_minbf[5]));
   // bw_u1_minbuf_5x UZfix_lmq_pcx_pkt_addr_minbf_b4 (.a(lmq_pcx_pkt_addr[4]), .z(lmq_pcx_pkt_addr_minbf[4]));
   assign lmq_pcx_pkt_addr_minbf = lmq_pcx_pkt_addr[`L1D_ADDRESS_HI:4];
   
   
assign           lmq_ld_addr_b3 = lmq_pcx_pkt_addr[3];
   
   
assign  dcache_fill_addr_e[`L1D_ADDRESS_HI:0] =
{`L1D_ADDRESS_HI+1{lsu_dc_iob_access_e}}               & {dcache_iob_addr_e[`L1D_ADDRESS_HI-3:0],3'b000} |
{`L1D_ADDRESS_HI+1{lsu_bist_wvld_e | lsu_bist_rvld_e}} & {mbist_dcache_index[`L1D_ADDRESS_HI-4:0], mbist_dcache_word, 3'b000} | 
{`L1D_ADDRESS_HI+1{lsu_diagnstc_wr_src_sel_e}}         & lsu_diagnstc_wr_addr_e[`L1D_ADDRESS_HI:0] |
{`L1D_ADDRESS_HI+1{lsu_dfq_st_vld}}                    & st_dcfill_addr[`L1D_ADDRESS_HI:0] |
{`L1D_ADDRESS_HI+1{lsu_dfq_ld_vld}}                    & {lmq_pcx_pkt_addr_minbf[`L1D_ADDRESS_HI:4], lmq_pcx_pkt_addr[3:0]}; 

assign lsu_dcache_fill_addr_e[`L1D_ADDRESS_HI:3] = dcache_fill_addr_e[`L1D_ADDRESS_HI:3];  

   wire [`L1D_ADDRESS_HI:4] dcache_fill_addr_e_tmp;
assign dcache_fill_addr_e_tmp[`L1D_ADDRESS_HI:4]    = dcache_fill_addr_e[`L1D_ADDRESS_HI:4];
// bw_u1_buf_30x UZfix_lsu_dcache_fill_addr_e_err_b10 ( .a(dcache_fill_addr_e_tmp[10]),  .z(lsu_dcache_fill_addr_e_err[10]));
// bw_u1_buf_30x UZfix_lsu_dcache_fill_addr_e_err_b9  ( .a(dcache_fill_addr_e_tmp[9]),  .z(lsu_dcache_fill_addr_e_err[9] ));
// bw_u1_buf_30x UZfix_lsu_dcache_fill_addr_e_err_b8  ( .a(dcache_fill_addr_e_tmp[8]),  .z(lsu_dcache_fill_addr_e_err[8]));
// bw_u1_buf_30x UZfix_lsu_dcache_fill_addr_e_err_b7  ( .a(dcache_fill_addr_e_tmp[7]),  .z(lsu_dcache_fill_addr_e_err[7]));
// bw_u1_buf_30x UZfix_lsu_dcache_fill_addr_e_err_b6  ( .a(dcache_fill_addr_e_tmp[6]),  .z(lsu_dcache_fill_addr_e_err[6]));
// bw_u1_buf_30x UZfix_lsu_dcache_fill_addr_e_err_b5  ( .a(dcache_fill_addr_e_tmp[5]),  .z(lsu_dcache_fill_addr_e_err[5]));
// bw_u1_buf_30x UZfix_lsu_dcache_fill_addr_e_err_b4  ( .a(dcache_fill_addr_e_tmp[4]),  .z(lsu_dcache_fill_addr_e_err[4]));
assign lsu_dcache_fill_addr_e_err[`L1D_ADDRESS_HI:4] = dcache_fill_addr_e[`L1D_ADDRESS_HI:4];

// used as ld bypass 
assign dcache_wr_addr_e[2:0] = dcache_fill_addr_e[2:0];

//ldfill doesn't need to create wrt byte msk, always fill one line
assign waddr_enc[3:0] = 
{4{lsu_dc_iob_access_e}}               & {dcache_iob_addr_e[0],3'b000} |
{4{lsu_bist_e}}                        & {mbist_dcache_word, 3'b000} | 
{4{lsu_diagnstc_wr_src_sel_e}}         & lsu_diagnstc_wr_addr_e[3:0] |
{4{lsu_dfq_st_vld}}                    & st_dcfill_addr[3:0] ;

//==============================================================
/*
dff_s  #(4) lsu_thread_stgg (
        .din    ({thread3_m, thread2_m, thread1_m,thread0_m}),
        .q      (lsu_thread_g[3:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
*/
   assign lsu_thread_g[3] = thread3_g;
   assign lsu_thread_g[2] = thread2_g;
   assign lsu_thread_g[1] = thread1_g;
   assign lsu_thread_g[0] = thread0_g;
   
//===============================================================
//LMQ thread sel
//===============================================================
//lmq_ldd_vld
   assign     dfq_byp_thrd_sel[0] = ~lsu_dfq_byp_tid[1] & ~lsu_dfq_byp_tid[0];
   assign     dfq_byp_thrd_sel[1] = ~lsu_dfq_byp_tid[1] &  lsu_dfq_byp_tid[0];
   assign     dfq_byp_thrd_sel[2] =  lsu_dfq_byp_tid[1] & ~lsu_dfq_byp_tid[0];
   assign     dfq_byp_thrd_sel[3] =  lsu_dfq_byp_tid[1] &  lsu_dfq_byp_tid[0];

   wire       lmq_ldd_vld_din;
   
mux4ds #(1) lmq_ldd_vld_mux (
       .in0 ({lmq0_ldd_vld}),
       .in1 ({lmq1_ldd_vld}),
       .in2 ({lmq2_ldd_vld}),
       .in3 ({lmq3_ldd_vld}),
       .sel0(dfq_byp_thrd_sel[0]),
       .sel1(dfq_byp_thrd_sel[1]),
       .sel2(dfq_byp_thrd_sel[2]),
       .sel3(dfq_byp_thrd_sel[3]),
       .dout({lmq_ldd_vld_din})
);
                    
dffe_s #(1)  lmq_ldd_vld_ff (
           .din    ({lmq_ldd_vld_din}),
           .q      ({lmq_ldd_vld}),
           .en     (dfq_byp_ff_en),
           .clk    (clk),
           .se     (se),       .si (),          .so ()
           );
                       
//bist
wire [`L1D_WAY_MASK] bist_way_enc_e;
reg [`L1D_WAY_ARRAY_MASK] bist_way_e;


assign bist_way_enc_e[`L1D_WAY_MASK] =  lsu_dc_iob_access_e ?  
       lsu_dcache_iob_way_e[`L1D_WAY_MASK] : mbist_dcache_way[`L1D_WAY_MASK] ;
   
// assign  bist_way_e[0] = ~bist_way_enc_e[1] & ~bist_way_enc_e[0] ;
// assign  bist_way_e[1] = ~bist_way_enc_e[1] &  bist_way_enc_e[0] ;
// assign  bist_way_e[2] =  bist_way_enc_e[1] & ~bist_way_enc_e[0] ;
// assign  bist_way_e[3] =  bist_way_enc_e[1] &  bist_way_enc_e[0] ;
always @ *
begin
bist_way_e = 0;
if (bist_way_enc_e == 0)
   bist_way_e[0] = 1'b1;
else if (bist_way_enc_e == 1)
   bist_way_e[1] = 1'b1;
else if (bist_way_enc_e == 2)
   bist_way_e[2] = 1'b1;
else if (bist_way_enc_e == 3)
   bist_way_e[3] = 1'b1;
end


assign lsu_bist_rsel_way_e[`L1D_WAY_ARRAY_MASK] = bist_way_e[`L1D_WAY_ARRAY_MASK];

   wire lmq_l2fill_fp_din;
assign    lmq_l2fill_fp_din =
       dfq_byp_thrd_sel[0] & lmq0_l2fill_fpld | 
       dfq_byp_thrd_sel[1] & lmq1_l2fill_fpld | 
       dfq_byp_thrd_sel[2] & lmq2_l2fill_fpld | 
       dfq_byp_thrd_sel[3] & lmq3_l2fill_fpld ;
 
dffe_s #(1) lmq_l2fill_fp_ff (
           .din (lmq_l2fill_fp_din),
           .q   (lsu_l2fill_fpld_e),
           .en  (dfq_byp_ff_en),
           .clk (clk),
           .se  (se),       .si (),          .so ()
           );   

   wire lmq_ncache_ld_din;
assign    lmq_ncache_ld_din =
       dfq_byp_thrd_sel[0] & lmq0_ncache_ld | 
       dfq_byp_thrd_sel[1] & lmq1_ncache_ld | 
       dfq_byp_thrd_sel[2] & lmq2_ncache_ld | 
       dfq_byp_thrd_sel[3] & lmq3_ncache_ld ;
 
dffe_s #(1) lmq_ncache_ld_ff (
           .din (lmq_ncache_ld_din),
           .q   (lsu_ncache_ld_e),
           .en  (dfq_byp_ff_en),
           .clk (clk),
           .se  (se),       .si (),          .so ()
           );   
                         
//lmq
   wire [`L1D_WAY_MASK]      lmq_ldfill_way_din;
   
mux4ds #(`L1D_WAY_WIDTH) lmq_ldfill_way_mux (
       .in0 ({lmq0_pcx_pkt_way[`L1D_WAY_MASK]}),
       .in1 ({lmq1_pcx_pkt_way[`L1D_WAY_MASK]}),
       .in2 ({lmq2_pcx_pkt_way[`L1D_WAY_MASK]}),
       .in3 ({lmq3_pcx_pkt_way[`L1D_WAY_MASK]}),
       .sel0(dfq_byp_thrd_sel[0]),
       .sel1(dfq_byp_thrd_sel[1]),
       .sel2(dfq_byp_thrd_sel[2]),
       .sel3(dfq_byp_thrd_sel[3]),
       .dout({lmq_ldfill_way_din[`L1D_WAY_MASK]})
);
   wire [`L1D_WAY_MASK]      lmq_ldfill_way;
                    
dffe_s #(`L1D_WAY_WIDTH)  lmq_ldfill_way_ff (
           .din    ({lmq_ldfill_way_din[`L1D_WAY_MASK]}),
           .q      ({lmq_ldfill_way[`L1D_WAY_MASK]}),
           .en     (dfq_byp_ff_en),
           .clk    (clk),
           .se     (se),       .si (),          .so ()
           );

wire [`L1D_WAY_MASK] dcache_fill_way_enc_e;
   
assign dcache_fill_way_enc_e[`L1D_WAY_MASK] = 
{`L1D_WAY_WIDTH{lsu_dc_iob_access_e}}               & lsu_dcache_iob_way_e[`L1D_WAY_MASK] |
{`L1D_WAY_WIDTH{lsu_bist_e}}                        & bist_way_enc_e[`L1D_WAY_MASK]       | 
{`L1D_WAY_WIDTH{lsu_diagnstc_wr_src_sel_e}}         & lsu_diagnstc_wr_way_e[`L1D_WAY_MASK]|
{`L1D_WAY_WIDTH{lsu_dfq_st_vld}}                    & lsu_st_way_e[`L1D_WAY_MASK]         |
{`L1D_WAY_WIDTH{lsu_dfq_ld_vld}}                    & lmq_ldfill_way[`L1D_WAY_MASK]; 

   // assign lsu_dcache_fill_way_e[0] =   ~dcache_fill_way_enc_e[1] & ~dcache_fill_way_enc_e[0];
   // assign lsu_dcache_fill_way_e[1] =   ~dcache_fill_way_enc_e[1] &  dcache_fill_way_enc_e[0];
   // assign lsu_dcache_fill_way_e[2] =    dcache_fill_way_enc_e[1] & ~dcache_fill_way_enc_e[0];
   // assign lsu_dcache_fill_way_e[3] =    dcache_fill_way_enc_e[1] &  dcache_fill_way_enc_e[0];


    assign lsu_dcache_fill_way_e[0] = (dcache_fill_way_enc_e == 0);


    assign lsu_dcache_fill_way_e[1] = (dcache_fill_way_enc_e == 1);


    assign lsu_dcache_fill_way_e[2] = (dcache_fill_way_enc_e == 2);


    assign lsu_dcache_fill_way_e[3] = (dcache_fill_way_enc_e == 3);



//ld_rq_type

   wire [2:0]      lmq_ld_rq_type_din;
   
mux4ds #(3) lmq_ld_rq_type_mux (
       .in0 ({lmq0_ld_rq_type[2:0]}),
       .in1 ({lmq1_ld_rq_type[2:0]}),
       .in2 ({lmq2_ld_rq_type[2:0]}),
       .in3 ({lmq3_ld_rq_type[2:0]}),
       .sel0(dfq_byp_thrd_sel[0]),
       .sel1(dfq_byp_thrd_sel[1]),
       .sel2(dfq_byp_thrd_sel[2]),
       .sel3(dfq_byp_thrd_sel[3]),
       .dout({lmq_ld_rq_type_din[2:0]})
);
                    
dffe_s #(3)  lmq_ld_rq_type_e_ff (
           .din    ({lmq_ld_rq_type_din[2:0]}),
           .q      ({lmq_ld_rq_type_e[2:0]}),
           .en     (dfq_byp_ff_en),
           .clk    (clk),
           .se     (se),       .si (),          .so ()
           );

//================================================================
wire	other_flush_pipe_w ;

assign	other_flush_pipe_w = tlu_early_flush_pipe2_w | (lsu_ttype_vld_m2 & lsu_inst_vld_w);     
assign	dctl_flush_pipe_w = other_flush_pipe_w | ifu_lsu_flush_w ;
// Staged ifu_tlu_flush_m should be used !!
assign  dctl_early_flush_w = (lsu_local_early_flush_g | tlu_early_flush_pipe2_w | ifu_lsu_flush_w) ;

//================================================================
// dcfill size
   wire dcfill_size_mx_sel_e;
//bug6216/eco6624 
assign  dcfill_size_mx_sel_e  =  lsu_dc_iob_access_e | lsu_diagnstc_wr_src_sel_e;    

mux2ds  #(2)  dcache_wr_size_e_mux (
              .in0(2'b11),
              .in1(lsu_st_dcfill_size_e[1:0]),
              .sel0(dcfill_size_mx_sel_e),
              .sel1(~dcfill_size_mx_sel_e),
              .dout(dcache_wr_size_e[1:0])
);


//assign  lsu_dcfill_data_mx_sel_e  =   (dcache_iob_wr_e | dcache_iob_rd_e | lsu_bist_wvld_e);   
   wire dcfill_data_mx_sel_e_l;
   
bw_u1_nor3_8x  UZsize_dcfill_data_mx_sel_e_l (.a (dcache_iob_wr_e),
                                              .b (dcache_iob_rd_e), 
                                              .c (lsu_bist_wvld_e),
                                              .z (dcfill_data_mx_sel_e_l));

bw_u1_inv_30x  UZsize_dcfill_data_mx_sel_e   ( .a(dcfill_data_mx_sel_e_l), .z (lsu_dcfill_data_mx_sel_e));
   
//================================================================
   wire [3:0] dfq_thread_e;
   assign     dfq_thread_e[0] = ~lsu_dfill_tid_e[1] & ~lsu_dfill_tid_e[0];
   assign     dfq_thread_e[1] = ~lsu_dfill_tid_e[1] &  lsu_dfill_tid_e[0];
   assign     dfq_thread_e[2] =  lsu_dfill_tid_e[1] & ~lsu_dfill_tid_e[0];
   assign     dfq_thread_e[3] =  lsu_dfill_tid_e[1] &  lsu_dfill_tid_e[0];

   wire [3:0] dfq_byp_sel_e;
   assign     dfq_byp_sel_e[0] = dfq_thread_e[0] & dcfill_active_e & ~lsu_cpx_pkt_prefetch2;
   assign     dfq_byp_sel_e[1] = dfq_thread_e[1] & dcfill_active_e & ~lsu_cpx_pkt_prefetch2;
   assign     dfq_byp_sel_e[2] = dfq_thread_e[2] & dcfill_active_e & ~lsu_cpx_pkt_prefetch2;
   assign     dfq_byp_sel_e[3] = dfq_thread_e[3] & dcfill_active_e & ~lsu_cpx_pkt_prefetch2;
   
wire	[3:0] lmq_byp_misc_sel_e ;

assign  lmq_byp_misc_sel_e[0] = ld_thrd_byp_sel_e[0]  |        // select for ldxa/raw.
                                dfq_byp_sel_e[0]  ;              // select for dfq.
assign  lmq_byp_misc_sel_e[1] = ld_thrd_byp_sel_e[1]  |        // select for ldxa/raw.
                                dfq_byp_sel_e[1] ;               // select for dfq.
assign  lmq_byp_misc_sel_e[2] = ld_thrd_byp_sel_e[2]  |        // select for ldxa/raw.
                                dfq_byp_sel_e[2] ;               // select for dfq.
assign  lmq_byp_misc_sel_e[3] = ld_thrd_byp_sel_e[3]  | 
                                dfq_byp_sel_e[3] ; 

   wire [2:0] byp_misc_addr_e;
assign byp_misc_addr_e[2:0] = (lmq_byp_misc_sel_e[0] ? lmq0_pcx_pkt_addr[2:0] : 3'b0) |
                              (lmq_byp_misc_sel_e[1] ? lmq1_pcx_pkt_addr[2:0] : 3'b0) |
                              (lmq_byp_misc_sel_e[2] ? lmq2_pcx_pkt_addr[2:0] : 3'b0) |
                              (lmq_byp_misc_sel_e[3] ? lmq3_pcx_pkt_addr[2:0] : 3'b0) ;
   
   wire [1:0] byp_misc_sz_e;
assign byp_misc_sz_e[1:0] = (lmq_byp_misc_sel_e[0] ? lmq0_byp_misc_sz[1:0] : 2'b0) |
                            (lmq_byp_misc_sel_e[1] ? lmq1_byp_misc_sz[1:0] : 2'b0) |
                            (lmq_byp_misc_sel_e[2] ? lmq2_byp_misc_sz[1:0] : 2'b0) |
                            (lmq_byp_misc_sel_e[3] ? lmq3_byp_misc_sz[1:0] : 2'b0) ;
   
                                
dff_s #(5)  lmq_byp_misc_stgm (
           .din    ({byp_misc_addr_e[2:0], byp_misc_sz_e[1:0]}),
           .q      ({lsu_byp_misc_addr_m[2:0], lsu_byp_misc_sz_m[1:0]}),
           .clk    (clk),
           .se     (se),       .si (),          .so ()
           );
  
endmodule



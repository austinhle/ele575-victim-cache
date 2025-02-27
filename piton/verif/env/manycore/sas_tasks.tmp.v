// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: sas_tasks.v
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
`ifdef PITON_PROTO
    //`define FPGA_SYN_16x160
`endif

`ifdef USE_IBM_SRAMS
// `define FPGA_SYN_16x160
`endif

`define NUM_TILES 1




`ifndef RTL_SPU
`define LSU_PATH lsu.lsu
`else
`define LSU_PATH lsu
`endif

//
//define special register
//define special register
`define MONITOR_SIGNAL                    155
`define FLOAT_X                           154
`define FLOAT_I                           153
`define REG_WRITE_BACK                    152

`define     PC                         32
`define     NPC                        33
`define     Y                          34
`define     CCR                        35
`define     FPRS                       36
`define     FSR                        37
`define     ASI                        38
`define     TICK_SAS                   39
`define     GSR                        40
`define     TICK_CMPR                  41
`define     STICK                      42
`define     STICK_CMPR                 43
`define     PSTATE_SAS                 44
`define     TL_SAS                     45
`define     PIL_SAS                    46

`define     TPC1                       47
`define     TPC2                       48
`define     TPC3                       49
`define     TPC4                       50
`define     TPC5                       51
`define     TPC6                       52

`define     TNPC1                      57
`define     TNPC2                      58
`define     TNPC3                      59
`define     TNPC4                      60
`define     TNPC5                      61
`define     TNPC6                      62

`define     TSTATE1                    67
`define     TSTATE2                    68
`define     TSTATE3                    69
`define     TSTATE4                    70
`define     TSTATE5                    71
`define     TSTATE6                    72

`define     TT1                        77
`define     TT2                        78
`define     TT3                        79
`define     TT4                        80
`define     TT5                        81
`define     TT6                        82
`define     TBA_SAS                    87
`define     VER                        88
`define     CWP                        89
`define     CANSAVE                    90
`define     CANRESTORE                 91
`define     OTHERWIN                   92
`define     WSTATE                     93
`define     CLEANWIN                   94
`define     SOFTINT                    95
`define     ECACHE_ERROR_ENABLE        96
`define     ASYNCHRONOUS_FAULT_STATUS  97
`define     ASYNCHRONOUS_FAULT_ADDRESS 98
`define     OUT_INTR_DATA0             99
`define     OUT_INTR_DATA1             100
`define     OUT_INTR_DATA2             101
`define     INTR_DISPATCH_STATUS       102
`define     IN_INTR_DATA0              103
`define     IN_INTR_DATA1              104
`define     IN_INTR_DATA2              105
`define     INTR_RECEIVE               106
`define     GL                         107
`define     HPSTATE_SAS                108
`define     HTSTATE1                   109
`define     HTSTATE2                   110
`define     HTSTATE3                   111
`define     HTSTATE4                   112
`define     HTSTATE5                   113
`define     HTSTATE6                   114
`define     HTSTATE7                   115
`define     HTSTATE8                   116
`define     HTSTATE9                   117
`define     HTSTATE10                  118
`define     HTBA_SAS                   119
`define     HINTP_SAS                  120
`define     HSTICK_CMPR                121
`define     MID                        122
`define     ISFSR                      123
`define     DSFSR                      124
`define     SFAR                       125

//new mmu registers
`define     I_TAG_ACCESS            126
`define     D_TAG_ACCESS            127
`define     CTXT_PRIM               128
`define     CTXT_SEC                129
`define     SFP_REG                 130
`define     I_CTXT_ZERO_PS0         131
`define     D_CTXT_ZERO_PS0         132
`define     I_CTXT_ZERO_PS1         133
`define     D_CTXT_ZERO_PS1         134
`define     I_CTXT_ZERO_CONFIG      135
`define     D_CTXT_ZERO_CONFIG      136
`define     I_CTXT_NONZERO_PS0      137
`define     D_CTXT_NONZERO_PS0      138
`define     I_CTXT_NONZERO_PS1      139
`define     D_CTXT_NONZERO_PS1      140
`define     I_CTXT_NONZERO_CONFIG   141
`define     D_CTXT_NONZERO_CONFIG   142
`define     I_TAG_TARGET            143
`define     D_TAG_TARGET            144
`define     I_TSB_PTR_PS0           145
`define     D_TSB_PTR_PS0           146
`define     I_TSB_PTR_PS1           147
`define     D_TSB_PTR_PS1           148
`define     D_TSB_DIR_PTR           149
`define     VA_WP_ADDR              150
`define     PID                     151
`define     RESET_COMMAND           500
`define     PLI_INST_TTE           17    /* %1 th id, %2-%9 I-TTE value */
`define     PLI_DATA_TTE           18    /* %1 th id, %2-%9 D-TTE value */
`define  TIMESTAMP              19    /* %1-%8 RTL timestamp value */
module sas_tasks (/*AUTOARG*/
           // Inputs
           clk, rst_l
       );
//inputs
input   clk;
input   rst_l;
reg [7:0] in_used;
reg [2:0] cpu_num;
reg        kill_fsr;
reg       dead_socket;
reg       inst_checker_off;
reg       fprs_on;

`ifdef SAS_DISABLE
reg  sas_def;
initial begin
    if($test$plusargs("use_sas_tasks"))sas_def = 1;
    else sas_def = 0;
    // sas_def = 1;
end // initial
`else
initial begin
    in_used = 0;
    if($value$plusargs("cpu_num=%d", cpu_num))
        $display("Info:Number of cpu = %d", cpu_num);
    else cpu_num = 0;
    if($test$plusargs("kill_fsr"))kill_fsr = 1;
    else kill_fsr = 0;
    dead_socket      = 0;
    inst_checker_off = 0;
    if($value$plusargs("inst_check_off=%d", inst_checker_off))begin
        $display("Info:instruction checker is on", inst_checker_off);
        inst_checker_off =1;
    end
end // initial begin
initial begin
    fprs_on = 0;
    if($value$plusargs("fprs_comp_on=%d", fprs_on))fprs_on = 1;
end

`ifdef SAS_DISABLE
`else



 `ifdef RTL_SPARC0
sas_task task0 (/*AUTOINST*/
             // Inputs
             .tlu_pich_wrap_flg_m (`TLUPATH0.tcl.tlu_pich_wrap_flg_m), // Templated
             .tlu_pic_cnt_en_m  (`TLUPATH0.tcl.tlu_pic_cnt_en_m), // Templated
             .final_ttype_sel_g (`TLUPATH0.tcl.final_ttype_sel_g), // Templated
             .rst_ttype_w2  (`TLUPATH0.tcl.rst_ttype_w2), // Templated
             .sync_trap_taken_m (`TLUPATH0.tcl.sync_trap_taken_m), // Templated
             .pib_picl_wrap (`TLUPATH0.pib_picl_wrap), // Templated
             .pib_pich_wrap_m (`TLUPATH0.tcl.pib_pich_wrap_m), // Templated
             .pib_pich_wrap (`TLUPATH0.pib_pich_wrap), // Templated
             .pic_wrap_trap_g (`TLUPATH0.tcl.pib_wrap_trap_g), // Templated
             .pib_wrap_trap_m (`TLUPATH0.tcl.pib_wrap_trap_m), // Templated
             .pcr_rw_e    (`TLUPATH0.tlu_pib.pcr_rw_e), // Templated
             .tlu_rsr_inst_e  (`TLUPATH0.tlu_pib.tlu_rsr_inst_e), // Templated
             .pcr0    (`TLUPATH0.tlu_pib.pcr0), // Templated
             .pcr1    (`TLUPATH0.tlu_pib.pcr1), // Templated
             .pcr2    (`TLUPATH0.tlu_pib.pcr2), // Templated
             .pcr3    (`TLUPATH0.tlu_pib.pcr3), // Templated
             .wsr_pcr_sel   (`TLUPATH0.tlu_pib.wsr_pcr_sel), // Templated
             .pich_cnt0   (`TLUPATH0.tlu_pib.pich_cnt0), // Templated
             .pich_cnt1   (`TLUPATH0.tlu_pib.pich_cnt1), // Templated
             .pich_cnt2   (`TLUPATH0.tlu_pib.pich_cnt2), // Templated
             .pich_cnt3   (`TLUPATH0.tlu_pib.pich_cnt3), // Templated
             .picl_cnt0   (`TLUPATH0.tlu_pib.picl_cnt0), // Templated
             .picl_cnt1   (`TLUPATH0.tlu_pib.picl_cnt1), // Templated
             .picl_cnt2   (`TLUPATH0.tlu_pib.picl_cnt2), // Templated
             .picl_cnt3   (`TLUPATH0.tlu_pib.picl_cnt3), // Templated
             .update_pich_sel (`TLUPATH0.tlu_pib.update_pich_sel), // Templated
             .update_picl_sel (`TLUPATH0.tlu_pib.update_picl_sel), // Templated
`ifndef RTL_SPU
             .const_maskid  (`PCXPATH0.ifu.ifu.fdp.const_maskid), // Templated
             .fprs_sel_wrt  (`PCXPATH0.ifu.ifu.swl.fprs_sel_wrt), // Templated
             .fprs_sel_set  (`PCXPATH0.ifu.ifu.swl.fprs_sel_set), // Templated
             .fprs_wrt_data (`PCXPATH0.ifu.ifu.swl.fprs_wrt_data), // Templated
             .new_fprs    (`PCXPATH0.ifu.ifu.swl.new_fprs), // Templated
             .ifu_lsu_pref_inst_e (`PCXPATH0.ifu_lsu_pref_inst_e), // Templated
             .formatted_tte_data  (`PCXPATH0.ifu.ifu.errdp.formatted_tte_data), // Templated
`else
             .const_maskid  (`PCXPATH0.ifu.fdp.const_maskid), // Templated
             .fprs_sel_wrt  (`PCXPATH0.ifu.swl.fprs_sel_wrt), // Templated
             .fprs_sel_set  (`PCXPATH0.ifu.swl.fprs_sel_set), // Templated
             .fprs_wrt_data (`PCXPATH0.ifu.swl.fprs_wrt_data), // Templated
             .new_fprs    (`PCXPATH0.ifu.swl.new_fprs), // Templated
             .ifu_lsu_pref_inst_e (`PCXPATH0.ifu_lsu_pref_inst_e), // Templated
             .formatted_tte_data  (`PCXPATH0.ifu.errdp.formatted_tte_data), // Templated
`endif                 
             .dformatted_tte_data (`PCXPATH0.`LSU_PATH.tlbdp.formatted_tte_data), // Templated
             .dtlb_cam_vld  (`PCXPATH0.`LSU_PATH.dtlb.tlb_cam_vld), // Templated
             .dtlb_tte_vld_g  (`PCXPATH0.`LSU_PATH.excpctl.tlb_tte_vld_g), // Templated
             .tlu_hpstate_priv  (`PCXPATH0.tlu_hpstate_priv), // Templated
             .tlu_hpstate_enb (`PCXPATH0.tlu_hpstate_enb), // Templated
`ifndef RTL_SPU
             .fcl_dtu_inst_vld_d  (`PCXPATH0.ifu.ifu.fcl_dtu_inst_vld_d), // Templated
             .icache_hit    (`PCXPATH0.ifu.ifu.itlb.cache_hit), // Templated
             .xlate_en    (`PCXPATH0.ifu.ifu.fcl.xlate_en), // Templated
`else                 
             .fcl_dtu_inst_vld_d  (`PCXPATH0.ifu.fcl_dtu_inst_vld_d), // Templated
             .icache_hit    (`PCXPATH0.ifu.itlb.cache_hit), // Templated
             .xlate_en    (`PCXPATH0.ifu.fcl.xlate_en), // Templated
`endif
             .ifu_lsu_thrid_s (`PCXPATH0.ifu_lsu_thrid_s), // Templated
             .fcl_ifq_icmiss_s1 (`IFUPATH0.fcl.fcl_ifq_icmiss_s1), // Templated
             .tlu_exu_early_flush_pipe_w(`PCXPATH0.tlu_exu_early_flush_pipe_w), // Templated
             .rst_hwint_ttype_g (`TLUPATH0.tcl.rst_hwint_ttype_g), // Templated
             .trap_taken_g  (`TLUPATH0.tcl.trap_taken_g), // Templated
`ifndef RTL_SPU
             .spu_lsu_ldxa_illgl_va_w2(1'b0), // Templated
             .spu_lsu_ldxa_data_vld_w2(1'b0), // Templated
             .spu_lsu_ldxa_tid_w2 (2'b0), // Templated 
`else
             .spu_lsu_ldxa_illgl_va_w2(`PCXPATH0.spu.spu_ctl.spu_lsu_ldxa_illgl_va_w2), // Templated
             .spu_lsu_ldxa_data_vld_w2(`PCXPATH0.spu.spu_ctl.spu_lsu_ldxa_data_vld_w2), // Templated
             .spu_lsu_ldxa_tid_w2 (`PCXPATH0.spu.spu_ctl.spu_lsu_ldxa_tid_w2), // Templated
`endif
             .mra_field1_en (`TLUPATH0.mmu_ctl.mra_field1_en), // Templated
             .mra_field2_en (`TLUPATH0.mmu_ctl.mra_field2_en), // Templated
             .mra_field3_en (`TLUPATH0.mmu_ctl.mra_field3_en), // Templated
             .mra_field4_en (`TLUPATH0.mmu_ctl.mra_field4_en), // Templated
             .pmem_unc_error_g  (`PCXPATH0.`LSU_PATH.dctl.pmem_unc_error_g), // Templated
`ifndef RTL_SPU
             .pc_f    (`PCXPATH0.ifu.ifu.fdp.pc_f), // Templated
             .cam_vld_f   (`PCXPATH0.ifu.ifu.fcl.cam_vld_f), // Templated
`else
             .pc_f    (`PCXPATH0.ifu.fdp.pc_f), // Templated
             .cam_vld_f   (`PCXPATH0.ifu.fcl.cam_vld_f), // Templated
`endif
             .cam_vld   (`PCXPATH0.`LSU_PATH.dtlb.cam_vld), // Templated
             .defr_trp_taken_m_din(`PCXPATH0.`LSU_PATH.excpctl.defr_trp_taken_m_din), // Templated
             .illgl_va_vld_or_drop_ldxa2masync(1'b0), // Templated
`ifndef RTL_SPU
             .ecc_wen   (`PCXPATH0.ffu.ffu.ctl.ecc_wen), // Templated
`else
             .ecc_wen   (`PCXPATH0.ffu.ctl.ecc_wen), // Templated
`endif                 
             .fpdis_trap_e  (`IFUPATH0.dec.fpdis_trap_e), // Templated
             .ceen    (`IFUPATH0.errctl.ceen), // Templated
             .nceen   (`IFUPATH0.errctl.nceen), // Templated
             .ifu_tlu_flush_m (`TLUPATH0.ifu_tlu_flush_m), // Templated
             .lsu_tlu_ttype_m2  (`TLUPATH0.lsu_tlu_ttype_m2), // Templated
             .lsu_tlu_ttype_vld_m2(`TLUPATH0.lsu_tlu_ttype_vld_m2), // Templated
             .tlu_final_ttype_w2  (`TLUPATH0.tlu_final_ttype_w2), // Templated
             .tlu_ifu_trappc_vld_w1(`TLUPATH0.tlu_ifu_trappc_vld_w1), // Templated
             .mra_wr_ptr    (`TLUPATH0.mra_wr_ptr),  // Templated
             .mra_wr_vld    (`TLUPATH0.mra_wr_vld),  // Templated
             .lsu_pid_state0  (`PCXPATH0.`LSU_PATH.lsu_pid_state0), // Templated
             .lsu_pid_state1  (`PCXPATH0.`LSU_PATH.lsu_pid_state1), // Templated
             .lsu_pid_state2  (`PCXPATH0.`LSU_PATH.lsu_pid_state2), // Templated
             .lsu_pid_state3  (`PCXPATH0.`LSU_PATH.lsu_pid_state3), // Templated
             .pid_state_wr_en (`PCXPATH0.`LSU_PATH.pid_state_wr_en), // Templated
             .lsu_t0_pctxt_state  (`PCXPATH0.`LSU_PATH.lsu_t0_pctxt_state), // Templated
             .lsu_t1_pctxt_state  (`PCXPATH0.`LSU_PATH.lsu_t1_pctxt_state), // Templated
             .lsu_t2_pctxt_state  (`PCXPATH0.`LSU_PATH.lsu_t2_pctxt_state), // Templated
             .lsu_t3_pctxt_state  (`PCXPATH0.`LSU_PATH.lsu_t3_pctxt_state), // Templated
             .pctxt_state_wr_thrd (`PCXPATH0.`LSU_PATH.pctxt_state_wr_thrd), // Templated
             .sctxt_state0  (`PCXPATH0.`LSU_PATH.dctldp.sctxt_state0), // Templated
             .sctxt_state1  (`PCXPATH0.`LSU_PATH.dctldp.sctxt_state1), // Templated
             .sctxt_state2  (`PCXPATH0.`LSU_PATH.dctldp.sctxt_state2), // Templated
             .sctxt_state3  (`PCXPATH0.`LSU_PATH.dctldp.sctxt_state3), // Templated
             .sctxt_state_wr_thrd (`PCXPATH0.`LSU_PATH.dctldp.sctxt_state_wr_thrd), // Templated
             .va_wtchpt0_addr (`PCXPATH0.`LSU_PATH.qdp1.va_wtchpt0_addr), // Templated
             .va_wtchpt1_addr (`PCXPATH0.`LSU_PATH.qdp1.va_wtchpt1_addr), // Templated
             .va_wtchpt2_addr (`PCXPATH0.`LSU_PATH.qdp1.va_wtchpt2_addr), // Templated
             .va_wtchpt3_addr (`PCXPATH0.`LSU_PATH.qdp1.va_wtchpt3_addr), // Templated
             .lsu_va_wtchpt0_wr_en_l(`PCXPATH0.`LSU_PATH.lsu_va_wtchpt0_wr_en_l), // Templated
             .lsu_va_wtchpt1_wr_en_l(`PCXPATH0.`LSU_PATH.lsu_va_wtchpt1_wr_en_l), // Templated
             .lsu_va_wtchpt2_wr_en_l(`PCXPATH0.`LSU_PATH.lsu_va_wtchpt2_wr_en_l), // Templated
             .lsu_va_wtchpt3_wr_en_l(`PCXPATH0.`LSU_PATH.lsu_va_wtchpt3_wr_en_l), // Templated
             .ifu_rstint_m  (`TLPATH0.ifu_rstint_m), // Templated
`ifndef RTL_SPU                 
             .spu_tlu_rsrv_illgl_m(`PCXPATH0.tlu.tlu.spu_tlu_rsrv_illgl_m), // Templated
`else
             .spu_tlu_rsrv_illgl_m(`PCXPATH0.tlu.spu_tlu_rsrv_illgl_m), // Templated
`endif                 
             .cam_vld_s1    (`IFUPATH0.fcl.cam_vld_s1), // Templated
             .val_thr_s1    (`IFUPATH0.fcl.val_thr_s1), // Templated
             .pc_s    (`IFUPATH0.fdp.pc_s),  // Templated
`ifndef RTL_SPU
             .rs2_fst_ue_w3 (`PCXPATH0.ffu.ffu.ctl.rs2_fst_ue_w3), // Templated
             .rs2_fst_ce_w3 (`PCXPATH0.ffu.ffu.ctl.rs2_fst_ce_w3), // Templated
`else
             .rs2_fst_ue_w3 (`PCXPATH0.ffu.ctl.rs2_fst_ue_w3), // Templated
             .rs2_fst_ce_w3 (`PCXPATH0.ffu.ctl.rs2_fst_ce_w3), // Templated
`endif
             .lsu_tlu_async_ttype_vld_w2(`PCXPATH0.lsu_tlu_async_ttype_vld_w2), // Templated
             .lsu_tlu_defr_trp_taken_g(`PCXPATH0.lsu_tlu_defr_trp_taken_g), // Templated
             .lsu_tlu_async_ttype_w2(`PCXPATH0.lsu_tlu_async_ttype_w2), // Templated
             .lsu_tlu_async_tid_w2(`PCXPATH0.lsu_tlu_async_tid_w2), // Templated
`ifndef RTL_SPU
             .itlb_rw_index (`PCXPATH0.ifu.ifu.itlb.tlb_rw_index), // Templated
             .itlb_rw_index_vld (`PCXPATH0.ifu.ifu.itlb.tlb_rw_index_vld), // Templated
             .itlb_rd_tte_tag (`PCXPATH0.ifu.ifu.itlb.tlb_rd_tte_tag), // Templated
             .itlb_rd_tte_data  (`PCXPATH0.ifu.ifu.itlb.rd_tte_data), // Templated
             .icam_hit    ({48'b0,`PCXPATH0.ifu.ifu.itlb.cam_hit}), // Templated
`else
             .itlb_rw_index (`PCXPATH0.ifu.itlb.tlb_rw_index), // Templated
             .itlb_rw_index_vld (`PCXPATH0.ifu.itlb.tlb_rw_index_vld), // Templated
             .itlb_rd_tte_tag (`PCXPATH0.ifu.itlb.tlb_rd_tte_tag), // Templated
             .itlb_rd_tte_data  (`PCXPATH0.ifu.itlb.rd_tte_data), // Templated
             .icam_hit    ({48'b0,`PCXPATH0.ifu.itlb.cam_hit}), // Templated
`endif
             .dtlb_rw_index (`PCXPATH0.`LSU_PATH.dtlb.tlb_rw_index), // Templated
             .dtlb_rw_index_vld (`PCXPATH0.`LSU_PATH.dtlb.tlb_rw_index_vld), // Templated
             .dtlb_rd_tte_tag (`PCXPATH0.`LSU_PATH.dtlb.tlb_rd_tte_tag), // Templated
             .dtlb_rd_tte_data  (`PCXPATH0.`LSU_PATH.dtlb.rd_tte_data), // Templated
             .dcam_hit    ({48'b0,`PCXPATH0.`LSU_PATH.dtlb.cam_hit}), // Templated
             .wrt_spec_w    (`IFUPATH0.swl.wrt_spec_w), // Templated
             .spc_pcx_data_pa (124'b0), // Templated //tttttttttttttt
             .fcl_fdp_inst_sel_nop_s_l(`IFUPATH0.fdp.fcl_fdp_inst_sel_nop_s_l), // Templated
             .retract_iferr_d (`IFUPATH0.swl.retract_iferr_d), // Templated
             .inst_vld_w    (`INSTPATH0.inst_vld_w), // Templated
             .dmmu_async_illgl_va_g(`TLUPATH0.mmu_ctl.dmmu_async_illgl_va_g), // Templated
             .immu_async_illgl_va_g(`TLUPATH0.mmu_ctl.immu_async_illgl_va_g), // Templated
             .lsu_tlu_tlb_ld_inst_m(`TLUPATH0.mmu_ctl.lsu_tlu_tlb_ld_inst_m), // Templated
             .lsu_tlu_tlb_st_inst_m(`TLUPATH0.mmu_ctl.lsu_tlu_tlb_st_inst_m), // Templated
             .immu_sfsr_wr_en_l (`TLUPATH0.immu_sfsr_wr_en_l), // Templated
             .dmmu_sfsr_wr_en_l (`TLUPATH0.dmmu_sfsr_wr_en_l), // Templated
             .dmmu_sfar_wr_en_l (`TLUPATH0.dmmu_sfar_wr_en_l), // Templated
             .lsu_quad_asi_e  (`SPCPATH0.`LSU_PATH.lsu_quad_asi_e), // Templated
             .clk     (clk),       // Templated
             .rst_l   (rst_l),     // Templated
             .back    (`PC_CMP.back_thread[1*4-1:0*4]), // Templated
             .lsu_ifu_ldsta_internal_e(`IFUPATH0.lsu_ifu_ldsta_internal_e), // Templated
             .lsu_mmu_flush_pipe_w(`TLUPATH0.lsu_mmu_flush_pipe_w), // Templated
             .dtlb_wr_vld   (`DTLBPATH0.tlb_wr_vld), // Templated
             .dtlb_demap    (`DTLBPATH0.tlb_demap),  // Templated
             .dtlb_rd_tag_vld (`DTLBPATH0.tlb_rd_tag_vld), // Templated
             .dtlb_rd_data_vld  (`DTLBPATH0.tlb_rd_data_vld), // Templated
             .dtlb_entry_vld  ({48'd0,`DTLBPATH0.tlb_entry_vld}), // Templated
             .itlb_wr_vld   (`ITLBPATH0.tlb_wr_vld), // Templated
             .itlb_demap    (`ITLBPATH0.tlb_demap),  // Templated
             .itlb_rd_tag_vld (`ITLBPATH0.tlb_rd_tag_vld), // Templated
             .itlb_rd_data_vld  (`ITLBPATH0.tlb_rd_data_vld), // Templated
             .itlb_entry_vld  ({48'd0,`ITLBPATH0.tlb_entry_vld}), // Templated
             .tlb_access_tid_g  (`TLUPATH0.mmu_ctl.tlb_access_tid_g), // Templated
             .dsfar0_clk    (`TLUPATH0.mmu_dp.dsfar0_clk), // Templated
             .dsfar1_clk    (`TLUPATH0.mmu_dp.dsfar1_clk), // Templated
             .dsfar2_clk    (`TLUPATH0.mmu_dp.dsfar2_clk), // Templated
             .dsfar3_clk    (`TLUPATH0.mmu_dp.dsfar3_clk), // Templated
             .dsfar_din   (`TLUPATH0.mmu_dp.dsfar_din), // Templated
             .dtu_inst_d    (`IFUPATH0.dec.dtu_inst_d), // Templated
             .local_rdpr_mx1_sel  (`TLPATH0.local_rdpr_mx1_sel), // Templated
             .tlu_rdpr_mx5_sel  (`TLPATH0.tlu_rdpr_mx5_sel), // Templated
             .tlu_rdpr_mx7_sel  (`TLPATH0.tlu_rdpr_mx7_sel), // Templated
             .tlu_rst_l   (`TLPATH0.tlu_rst_l),  // Templated
             .tick_match    (`TDPPATH0.tick_match),  // Templated
             .tlu_wr_sftint_l_g (`TLUPATH0.tlu_wr_sftint_l_g), // Templated
             .dsfsr_din   (`TLUPATH0.mmu_dp.dsfsr_din), // Templated
             .dsfsr0_clk    (`TLUPATH0.mmu_dp.dsfsr0_clk), // Templated
             .dsfsr1_clk    (`TLUPATH0.mmu_dp.dsfsr1_clk), // Templated
             .dsfsr2_clk    (`TLUPATH0.mmu_dp.dsfsr2_clk), // Templated
             .dsfsr3_clk    (`TLUPATH0.mmu_dp.dsfsr3_clk), // Templated
             .isfsr_din   (`TLUPATH0.mmu_dp.isfsr_din), // Templated
             .isfsr0_clk    (`TLUPATH0.mmu_dp.isfsr0_clk), // Templated
             .isfsr1_clk    (`TLUPATH0.mmu_dp.isfsr1_clk), // Templated
             .isfsr2_clk    (`TLUPATH0.mmu_dp.isfsr2_clk), // Templated
             .isfsr3_clk    (`TLUPATH0.mmu_dp.isfsr3_clk), // Templated
             .ecl_byp_sel_ecc_w (`IFUPATH0.errctl.irf_ce_unq), // Templated
             .ifu_exu_inst_w  (`INSTPATH0.ifu_exu_inst_vld_w), // Templated
             .ctl_dp_fp_thr (`FLOATPATH0.ctl_dp_fp_thr), // Templated
             .ifu_ffu_fst_d (`FLOATPATH0.ifu_ffu_fst_d), // Templated
             .pc_e    (`DTUPATH0.pc_e),  // Templated
             .fcl_dtu_inst_vld_e  (`INSTPATH0.fcl_dtu_inst_vld_e), // Templated
             .exu_lsu_rs3_data_e  (`PCXPATH0.exu_lsu_rs3_data_e), // Templated
             .tick_ctl_din  (`TLPATH0.tick_ctl_din), // Templated
             .ifu_tlu_ttype_m (`PCXPATH0.ifu_tlu_ttype_m), // Templated
             .tlu_rerr_vld  (`PCXPATH0.tlu_rerr_vld), // Templated
             .sftint0   (`TDPPATH0.sftint0),   // Templated
             .sftint1   (`TDPPATH0.sftint1),   // Templated
             .sftint2   (`TDPPATH0.sftint2),   // Templated
             .sftint3   (`TDPPATH0.sftint3),   // Templated
             .sftint0_clk   (`TDPPATH0.sftint0_clk), // Templated
             .sftint1_clk   (`TDPPATH0.sftint1_clk), // Templated
             .sftint2_clk   (`TDPPATH0.sftint2_clk), // Templated
             .sftint3_clk   (`TDPPATH0.sftint3_clk), // Templated
             .sftint_b0_en  (`TDPPATH0.sftint_b0_en), // Templated
             .sftint_b15_en (`TDPPATH0.sftint_b15_en), // Templated
             .sftint_b16_en (`TDPPATH0.sftint_b16_en), // Templated
             .cpx_spc_data_cx2  (`PCXPATH0.cpx_spc_data_cx2), // Templated
             .ifu_exu_save_d  (`PCXPATH0.ifu_exu_save_d), // Templated
             .ifu_exu_restore_d (`PCXPATH0.ifu_exu_restore_d), // Templated
             .ifu_tlu_thrid_d (`PCXPATH0.ifu_tlu_thrid_d), // Templated
             .tlu_ifu_hwint_i3  (`TLUPATH0.tlu_ifu_hwint_i3), // Templated
             .ifu_tlu_hwint_m (`TLUPATH0.ifu_tlu_hwint_m), // Templated
             .ifu_tlu_rstint_m  (`TLUPATH0.ifu_tlu_rstint_m), // Templated
             .ifu_tlu_swint_m (`TLUPATH0.ifu_tlu_swint_m), // Templated
             .tlu_ifu_flush_pipe_w(`TLPATH0.tlu_ifu_flush_pipe_w), // Templated
             .ifu_tlu_flush_w (`PCXPATH0.ifu_tlu_flush_w), // Templated
             .ffu_ifu_fst_ce_w  (`PCXPATH0.ffu_ifu_fst_ce_w), // Templated
`ifndef RTL_SPU
             .ffu_ifu_ecc_ue_w2 (`PCXPATH0.ffu.ffu.ffu_ifu_ecc_ue_w2), // Templated
             .ffu_ifu_ecc_ce_w2 (`PCXPATH0.ffu.ffu.ffu_ifu_ecc_ce_w2), // Templated
`else
             .ffu_ifu_ecc_ue_w2 (`PCXPATH0.ffu.ffu_ifu_ecc_ue_w2), // Templated
             .ffu_ifu_ecc_ce_w2 (`PCXPATH0.ffu.ffu_ifu_ecc_ce_w2), // Templated
`endif
             .any_err_vld   (`IFUPATH0.errctl.any_err_vld), // Templated
             .any_ue_vld    (`IFUPATH0.errctl.any_ue_vld), // Templated
             .tsa_htstate_en  (`TLPATH0.tsa_htstate_en), // Templated
             .stickcmp_intdis_en  (`TDPPATH0.stickcmp_intdis_en), // Templated
             .tick_npt0   (`TLPATH0.tick_npt0),  // Templated
             .tick_npt1   (`TLPATH0.tick_npt1),  // Templated
             .tick_npt2   (`TLPATH0.tick_npt2),  // Templated
             .tick_npt3   (`TLPATH0.tick_npt3),  // Templated
             .true_tick   (`TDPPATH0.true_tick),   // Templated
             .htick_intdis0 (`TLU_HYPER0.htick_intdis0), // Templated
             .htick_intdis1 (`TLU_HYPER0.htick_intdis1), // Templated
             .htick_intdis2 (`TLU_HYPER0.htick_intdis2), // Templated
             .htick_intdis3 (`TLU_HYPER0.htick_intdis3), // Templated
             .true_stickcmp0  (`TDPPATH0.true_stickcmp0), // Templated
             .true_stickcmp1  (`TDPPATH0.true_stickcmp1), // Templated
             .true_stickcmp2  (`TDPPATH0.true_stickcmp2), // Templated
             .true_stickcmp3  (`TDPPATH0.true_stickcmp3), // Templated
             .tlu_hintp_en_l_g  (`TDPPATH0.tlu_hintp_en_l_g), // Templated
             .tlu_hintp   (`TDPPATH0.tlu_hintp),   // Templated
             .tlu_htba_en_l (`TDPPATH0.tlu_htba_en_l), // Templated
             .true_htba0    (`TDPPATH0.true_htba0),  // Templated
             .true_htba1    (`TDPPATH0.true_htba1),  // Templated
             .true_htba2    (`TDPPATH0.true_htba2),  // Templated
             .true_htba3    (`TDPPATH0.true_htba3),  // Templated
             .update_hpstate_l_w2 (`TDPPATH0.tlu_update_hpstate_l_w2[3:0]), // Templated
             .restore_hpstate0  (`TDPPATH0.restore_hpstate0), // Templated
             .restore_hpstate1  (`TDPPATH0.restore_hpstate1), // Templated
             .restore_hpstate2  (`TDPPATH0.restore_hpstate2), // Templated
             .restore_hpstate3  (`TDPPATH0.restore_hpstate3), // Templated
             .htickcmp_intdis_en  (`TLU_HYPER0.htickcmp_intdis_en), // Templated
             .true_htickcmp0  (`TDPPATH0.true_htickcmp0), // Templated
             .true_htickcmp1  (`TDPPATH0.true_htickcmp1), // Templated
             .true_htickcmp2  (`TDPPATH0.true_htickcmp2), // Templated
             .true_htickcmp3  (`TDPPATH0.true_htickcmp3), // Templated
             .gl0_en    (`TLU_HYPER0.gl0_en),  // Templated
             .gl1_en    (`TLU_HYPER0.gl1_en),  // Templated
             .gl2_en    (`TLU_HYPER0.gl2_en),  // Templated
             .gl3_en    (`TLU_HYPER0.gl3_en),  // Templated
             .gl_lvl0_new   (`TLU_HYPER0.gl_lvl0_new), // Templated
             .gl_lvl1_new   (`TLU_HYPER0.gl_lvl1_new), // Templated
             .gl_lvl2_new   (`TLU_HYPER0.gl_lvl2_new), // Templated
             .gl_lvl3_new   (`TLU_HYPER0.gl_lvl3_new), // Templated
             .t0_gsr_nxt    (`FFUPATH0.dp.t0_gsr_nxt), // Templated
             .t0_gsr_rnd_next (`FFUPATH0.ctl.visctl.t0_gsr_rnd_next), // Templated
             .t0_gsr_align_next (`FFUPATH0.ctl.visctl.t0_gsr_align_next), // Templated
             .t0_gsr_wsr_w  (`FFUPATH0.ctl.visctl.t0_gsr_wsr_w2), // Templated
             .t0_siam_w   (`FFUPATH0.ctl.visctl.t0_siam_w2), // Templated
             .t0_alignaddr_w  (`FFUPATH0.ctl.visctl.t0_alignaddr_w2), // Templated
             .t1_gsr_nxt    (`FFUPATH0.dp.t1_gsr_nxt), // Templated
             .t1_gsr_rnd_next (`FFUPATH0.ctl.visctl.t1_gsr_rnd_next), // Templated
             .t1_gsr_align_next (`FFUPATH0.ctl.visctl.t1_gsr_align_next), // Templated
             .t1_gsr_wsr_w  (`FFUPATH0.ctl.visctl.t1_gsr_wsr_w2), // Templated
             .t1_siam_w   (`FFUPATH0.ctl.visctl.t1_siam_w2), // Templated
             .t1_alignaddr_w  (`FFUPATH0.ctl.visctl.t1_alignaddr_w2), // Templated
             .t2_gsr_nxt    (`FFUPATH0.dp.t2_gsr_nxt), // Templated
             .t2_gsr_rnd_next (`FFUPATH0.ctl.visctl.t2_gsr_rnd_next), // Templated
             .t2_gsr_align_next (`FFUPATH0.ctl.visctl.t2_gsr_align_next), // Templated
             .t2_gsr_wsr_w  (`FFUPATH0.ctl.visctl.t2_gsr_wsr_w2), // Templated
             .t2_siam_w   (`FFUPATH0.ctl.visctl.t2_siam_w2), // Templated
             .t2_alignaddr_w  (`FFUPATH0.ctl.visctl.t2_alignaddr_w2), // Templated
             .t3_gsr_nxt    (`FFUPATH0.dp.t3_gsr_nxt), // Templated
             .t3_gsr_rnd_next (`FFUPATH0.ctl.visctl.t3_gsr_rnd_next), // Templated
             .t3_gsr_align_next (`FFUPATH0.ctl.visctl.t3_gsr_align_next), // Templated
             .t3_gsr_wsr_w  (`FFUPATH0.ctl.visctl.t3_gsr_wsr_w2), // Templated
             .t3_siam_w   (`FFUPATH0.ctl.visctl.t3_siam_w2), // Templated
             .t3_alignaddr_w  (`FFUPATH0.ctl.visctl.t3_alignaddr_w2), // Templated
             .exu_lsu_ldst_va_e (`ASIDPPATH0.exu_lsu_ldst_va_e[47:0]), // Templated
             .asi_state_e   (`ASIDPPATH0.asi_state_e[7:0]), // Templated
             .cpu_num   (cpu_num),     // Templated
             .good    (`PC_CMP.good[1*4-1:0*4]),   // Templated
             .active    (`PC_CMP.active_thread[1*4-1:0*4]), // Templated
             .finish    (`PC_CMP.finish_mask[1*4-1:0*4]), // Templated
             .lda_internal_e  (`ASIPATH0.lda_internal_e), // Templated
             .sta_internal_e  (`ASIPATH0.sta_internal_e), // Templated
             .ifu_spu_trap_ack  ({1'b0,`SPCPATH0.ifu_spu_trap_ack}), // Templated
             .ifu_exu_muls_d  (`SPCPATH0.ifu_exu_muls_d), // Templated
             .ifu_exu_tid_s2  (`EXUPATH0.ifu_exu_tid_s2[1:0]), // Templated
             .rml_irf_restore_local_m(`EXUPATH0.irf.irf.swap_local_w), // Templated
             .rml_irf_cwp_m (`EXUPATH0.irf.irf.old_lo_cwp_m[2:0]), // Templated
             .rml_irf_save_local_m(`EXUPATH0.irf.irf.swap_local_m), // Templated
             .rml_irf_thr_m (`EXUPATH0.irf.irf.cwpswap_tid_m[1:0]), // Templated
             .ifu_exu_save_e  (`EXUPATH0.rml.save_e),  // Templated
             .exu_tlu_spill_e (`EXUPATH0.rml.exu_tlu_spill_e), // Templated
             .t0_fsr_nxt    (`FLOATPATH0.dp.t0_fsr_nxt[27:0]), // Templated
             .t1_fsr_nxt    (`FLOATPATH0.dp.t1_fsr_nxt[27:0]), // Templated
             .t2_fsr_nxt    (`FLOATPATH0.dp.t2_fsr_nxt[27:0]), // Templated
             .t3_fsr_nxt    (`FLOATPATH0.dp.t3_fsr_nxt[27:0]), // Templated
             .ctl_dp_fsr_sel_old  (`FLOATPATH0.ctl_dp_fsr_sel_old[3:0]), // Templated
             .tlu_sftint_en_l_g (`TLUPATH0.tlu_sftint_en_l_g[3:0]), // Templated
             .true_tickcmp0 (`TDPPATH0.true_tickcmp0), // Templated
             .true_tickcmp1 (`TDPPATH0.true_tickcmp1), // Templated
             .true_tickcmp2 (`TDPPATH0.true_tickcmp2), // Templated
             .true_tickcmp3 (`TDPPATH0.true_tickcmp3), // Templated
             .tickcmp_intdis_en (`TDPPATH0.tickcmp_intdis_en[3:0]), // Templated
             .dtu_fdp_rdsr_sel_thr_e_l(`DTUPATH0.fcl_fdp_rdsr_sel_thr_e_l), // Templated
             .ifu_exu_rd_ifusr_e  (`EXUPATH0.ifu_exu_rd_ifusr_e), // Templated
             .ifu_exu_use_rsr_e_l (`EXUPATH0.ifu_exu_use_rsr_e_l), // Templated
             .rml_irf_global_tid  (`EXUPATH0.irf.irf.rml_irf_global_tid[1:0]), // Templated
             .ecl_irf_wen_w (`REGPATH0.ecl_irf_wen_w), // Templated
             .ecl_irf_wen_w2  (`REGPATH0.ecl_irf_wen_w2), // Templated
             .byp_irf_rd_data_w (`REGPATH0.byp_irf_rd_data_w[71:0]), // Templated
             .byp_irf_rd_data_w2  (`REGPATH0.byp_irf_rd_data_w2[71:0]), // Templated
             .thr_rd_w    (`REGPATH0.thr_rd_w[4:0]), // Templated
             .thr_rd_w2   (`REGPATH0.thr_rd_w2[4:0]), // Templated
             .ecl_irf_tid_w (`REGPATH0.ecl_irf_tid_w[1:0]), // Templated
             .ecl_irf_tid_w2  (`REGPATH0.ecl_irf_tid_w2[1:0]), // Templated
`ifndef RTL_SPU
             .ifu_tlu_thrid_w (`SPCPATH0.ifu.ifu.fcl.sas_thrid_w[1:0]), // Templated
`else
             .ifu_tlu_thrid_w (`SPCPATH0.ifu.fcl.sas_thrid_w[1:0]), // Templated
`endif
             .wen_thr0_l    (`CCRPATH0.wen_thr0_l),  // Templated
             .wen_thr1_l    (`CCRPATH0.wen_thr1_l),  // Templated
             .wen_thr2_l    (`CCRPATH0.wen_thr2_l),  // Templated
             .wen_thr3_l    (`CCRPATH0.wen_thr3_l),  // Templated
             .ccrin_thr0    (`CCRPATH0.ccrin_thr0[7:0]), // Templated
             .ccrin_thr1    (`CCRPATH0.ccrin_thr1[7:0]), // Templated
             .ccrin_thr2    (`CCRPATH0.ccrin_thr2[7:0]), // Templated
             .ccrin_thr3    (`CCRPATH0.ccrin_thr3[7:0]), // Templated
             .cwp_thr0_next (`EXUPATH0.rml.cwp.cwp_thr0_next), // Templated
             .cwp_thr1_next (`EXUPATH0.rml.cwp.cwp_thr1_next), // Templated
             .cwp_thr2_next (`EXUPATH0.rml.cwp.cwp_thr2_next), // Templated
             .cwp_thr3_next (`EXUPATH0.rml.cwp.cwp_thr3_next), // Templated
             .cwp_wen_l   (`EXUPATH0.rml.cwp.cwp_wen_l[3:0]), // Templated
             .next_cansave_w  (`EXUPATH0.rml.next_cansave_w[2:0]), // Templated
             .cansave_wen_w (`EXUPATH0.rml.cansave_wen_w), // Templated
             .next_canrestore_w (`EXUPATH0.rml.next_canrestore_w[2:0]), // Templated
             .canrestore_wen_w  (`EXUPATH0.rml.canrestore_wen_w), // Templated
             .next_otherwin_w (`EXUPATH0.rml.next_otherwin_w[2:0]), // Templated
             .otherwin_wen_w  (`EXUPATH0.rml.otherwin_wen_w), // Templated
             .tl_exu_tlu_wsr_data_w(`EXUPATH0.rml.exu_tlu_wsr_data_w[5:0]), // Templated
             .ecl_rml_wstate_wen_w(`EXUPATH0.rml.wstate_wen_w), // Templated
             .next_cleanwin_w (`EXUPATH0.rml.next_cleanwin_w[2:0]), // Templated
             .cleanwin_wen_w  (`EXUPATH0.rml.cleanwin_wen_w), // Templated
             .next_yreg_thr0  (`EXUPATH0.div.yreg.next_yreg_thr0[31:0]), // Templated
             .next_yreg_thr1  (`EXUPATH0.div.yreg.next_yreg_thr1[31:0]), // Templated
             .next_yreg_thr2  (`EXUPATH0.div.yreg.next_yreg_thr2[31:0]), // Templated
             .next_yreg_thr3  (`EXUPATH0.div.yreg.next_yreg_thr3[31:0]), // Templated
             .ecl_div_yreg_wen_l  (`EXUPATH0.ecl_div_yreg_wen_l[3:0]), // Templated
             .ifu_tlu_wsr_inst_d  (`EXUPATH0.ifu_tlu_wsr_inst_d), // Templated
             .ifu_tlu_sraddr_d  (`EXUPATH0.ifu_tlu_sraddr_d[3:0]), // Templated
             .inst_done_w_for_sas (`PC_CMP.spc0_inst_done), // Templated
`ifndef RTL_SPU
             .ifu_tlu_pc_w  (`SPCPATH0.ifu.ifu.fdp.pc_w[47:0]), // Templated
             .ifu_tlu_npc_w (`SPCPATH0.ifu.ifu.fdp.npc_w[47:0]), // Templated
`else
             .ifu_tlu_pc_w  (`SPCPATH0.ifu.fdp.pc_w[47:0]), // Templated
             .ifu_tlu_npc_w (`SPCPATH0.ifu.fdp.npc_w[47:0]), // Templated
`endif
             .tl0_en    (`TLPATH0.tl0_en),   // Templated
             .tl1_en    (`TLPATH0.tl1_en),   // Templated
             .tl2_en    (`TLPATH0.tl2_en),   // Templated
             .tl3_en    (`TLPATH0.tl3_en),   // Templated
             .trp_lvl0_new  (`TLPATH0.trp_lvl0_new[2:0]), // Templated
             .trp_lvl1_new  (`TLPATH0.trp_lvl1_new[2:0]), // Templated
             .trp_lvl2_new  (`TLPATH0.trp_lvl2_new[2:0]), // Templated
             .trp_lvl3_new  (`TLPATH0.trp_lvl3_new[2:0]), // Templated
             .update_pstate0_w2 (`TLPATH0.update_pstate_w2[0]), // Templated
             .update_pstate1_w2 (`TLPATH0.update_pstate_w2[1]), // Templated
             .update_pstate2_w2 (`TLPATH0.update_pstate_w2[2]), // Templated
             .update_pstate3_w2 (`TLPATH0.update_pstate_w2[3]), // Templated
             .pstate_priv_update_w2(`TDPPATH0.pstate_priv_update_w2), // Templated
             .hpstate_priv_update_w2(`TDPPATH0.hpstate_priv_update_w2), // Templated
             .restore_pstate0 (`TDPPATH0.restore_pstate0), // Templated
             .restore_pstate1 (`TDPPATH0.restore_pstate1), // Templated
             .restore_pstate2 (`TDPPATH0.restore_pstate2), // Templated
             .restore_pstate3 (`TDPPATH0.restore_pstate3), // Templated
             .tick0_en    (`TLPATH0.tick_en[0]),   // Templated
             .tick1_en    (`TLPATH0.tick_en[1]),   // Templated
             .tick2_en    (`TLPATH0.tick_en[2]),   // Templated
             .tick3_en    (`TLPATH0.tick_en[3]),   // Templated
             .exu_tlu_wsr_data_w  (`TDPPATH0.tlu_wsr_data_w[63:0]), // Templated
             .tba0_en   (`TLPATH0.tlu_tba_en_l[0]), // Templated
             .tba1_en   (`TLPATH0.tlu_tba_en_l[1]), // Templated
             .tba2_en   (`TLPATH0.tlu_tba_en_l[2]), // Templated
             .tba3_en   (`TLPATH0.tlu_tba_en_l[3]), // Templated
             .tsa_wr_vld    (`TLPATH0.tsa_wr_vld[1:0]), // Templated
             .tsa_pc_en   (`TLPATH0.tsa_pc_en),  // Templated
             .tsa_npc_en    (`TLPATH0.tsa_npc_en),   // Templated
             .tsa_tstate_en (`TLPATH0.tsa_tstate_en), // Templated
             .tsa_ttype_en  (`TLPATH0.tsa_ttype_en), // Templated
             .tsa_wr_tid    (`TLPATH0.tsa_wr_tid[1:0]), // Templated
             .tsa_wr_tpl    (`TLPATH0.tsa_wr_tpl[2:0]), // Templated
             // .temp_tlvl0    (`TS0PATH0.temp_tlvl),   // Templated
             .temp_tlvl0    (),   // Templated
             .tsa0_wdata    (`TS0PATH0.din),   // Templated
             .write_mask0   (`TS0PATH0.write_mask),  // Templated
             //.temp_tlvl1    (`TS1PATH0.temp_tlvl),   // Templated
             .temp_tlvl1    (),   // Templated
             .tsa1_wdata    (`TS1PATH0.din),   // Templated
             .write_mask1   (`TS1PATH0.write_mask),  // Templated
             .cpu_id    (10'd0),       // Templated
             .next_t0_inrr_i1 (`INTPATH0.next_t0_inrr_i1[63:0]), // Templated
             .next_t1_inrr_i1 (`INTPATH0.next_t1_inrr_i1[63:0]), // Templated
             .next_t2_inrr_i1 (`INTPATH0.next_t2_inrr_i1[63:0]), // Templated
             .next_t3_inrr_i1 (`INTPATH0.next_t3_inrr_i1[63:0]), // Templated
             .ifu_lsu_st_inst_e (`SPCPATH0.ifu_lsu_st_inst_e), // Templated
             .ifu_lsu_ld_inst_e (`SPCPATH0.ifu_lsu_ld_inst_e), // Templated
             .ifu_lsu_alt_space_e (`PCXPATH0.ifu_lsu_alt_space_e), // Templated
             .ifu_lsu_ldst_fp_e (`PCXPATH0.ifu_lsu_ldst_fp_e), // Templated
             .ifu_lsu_ldst_dbl_e  (`PCXPATH0.ifu_lsu_ldst_dbl_e), // Templated
             .lsu_ffu_blk_asi_e (`PCXPATH0.lsu_ffu_blk_asi_e), // Templated
             .ifu_tlu_inst_vld_m  (`PCXPATH0.ifu_tlu_inst_vld_m), // Templated
             .ifu_lsu_swap_e  (`SPCPATH0.ifu_lsu_swap_e), // Templated
             .ifu_tlu_thrid_e (`SPCPATH0.ifu_tlu_thrid_e[1:0]), // Templated
             .asi_wr_din    (`ASIDPPATH0.asi_wr_din), // Templated
             .asi_state_wr_thrd (`ASIDPPATH0.asi_state_wr_thrd[3:0]), // Templated
             .pil     (`TLPATH0.tlu_wsr_data_w[3:0]), // Templated
             .pil0_en   (`TLPATH0.pil0_en),  // Templated
             .pil1_en   (`TLPATH0.pil1_en),  // Templated
             .pil2_en   (`TLPATH0.pil2_en),  // Templated
             .pil3_en   (`TLPATH0.pil3_en),  // Templated
             .dp_frf_data   (`FLOATPATH0.dp_frf_data[70:0]), // Templated
             .ctl_frf_addr  (`FLOATPATH0.ctl_frf_addr[6:0]), // Templated
             .ctl_frf_wen   (`FLOATPATH0.ctl_frf_wen[1:0]), // Templated
             .regfile_index (`FLOATPATH0.frf.regfile_index[7:0]), // Templated
             .ifu_exu_rs1_s (`EXUPATH0.ifu_exu_rs1_s[4:0]), // Templated
             .ifu_exu_rs2_s (`EXUPATH0.ifu_exu_rs2_s[4:0]), // Templated
             .byp_alu_rs1_data_e  (`EXUPATH0.byp_alu_rs1_data_e[63:0]), // Templated
             .byp_alu_rs2_data_e  (`EXUPATH0.byp_alu_rs2_data_e[63:0]), // Templated
             .ifu_lsu_imm_asi_d (`SPCPATH0.ifu_lsu_imm_asi_d[7:0]), // Templated
             .ifu_lsu_imm_asi_vld_d(`SPCPATH0.ifu_lsu_imm_asi_vld_d), // Templated
             .ifu_tlu_itlb_done (`SPCPATH0.ifu_tlu_itlb_done), // Templated
             .tlu_itlb_wr_vld_g (`SPCPATH0.tlu_itlb_wr_vld_g), // Templated
             .tlu_itlb_dmp_vld_g  (`SPCPATH0.tlu_itlb_dmp_vld_g), // Templated
             .lsu_tlu_dtlb_done (`SPCPATH0.lsu_tlu_dtlb_done), // Templated
             .tlu_dtlb_wr_vld_g (`TLUPATH0.mmu_ctl.pre_dtlb_wr_vld_g), // Templated
             .tlu_dtlb_dmp_vld_g  (`SPCPATH0.tlu_dtlb_dmp_vld_g), // Templated
             .tlu_idtlb_dmp_thrid_g(`SPCPATH0.tlu_idtlb_dmp_thrid_g[1:0]), // Templated
             .inst_vld_qual_e (`INSTPATH0.inst_vld_qual_e), // Templated
             .t0_inrr_i2    (`TLUPATH0.intdp.t0_inrr_i2[63:0]), // Templated
             .t1_inrr_i2    (`TLUPATH0.intdp.t1_inrr_i2[63:0]), // Templated
             .t2_inrr_i2    (`TLUPATH0.intdp.t2_inrr_i2[63:0]), // Templated
             .t3_inrr_i2    (`TLUPATH0.intdp.t3_inrr_i2[63:0]), // Templated
             .t0_indr   (`TLUPATH0.intdp.t0_indr[10:0]), // Templated
             .t1_indr   (`TLUPATH0.intdp.t1_indr[10:0]), // Templated
             .t2_indr   (`TLUPATH0.intdp.t2_indr[10:0]), // Templated
             .t3_indr   (`TLUPATH0.intdp.t3_indr[10:0]), // Templated
             .ttype_sel_hstk_cmp_e(`INSTPATH0.ttype_sel_hstk_cmp_e), // Templated
             .ifu_tlu_ttype_vld_m (`INSTPATH0.ifu_tlu_ttype_vld_m)); // Templated
`endif // ifdef RTL_SPARC0




`endif // SAS_DISABLE
reg         sas_def;
// asdf;
reg [71:0] active_window [127:0];
reg [71:0] locals        [255:0];
reg [71:0] evens         [255:0];
reg [71:0] odds          [255:0];
reg [71:0] globals       [255:0];
reg [38:0] regfile       [255:0];
//signals for fifo
time    sas_time;
reg [63:0] sas_timer;

reg [7:0]  sas_which;
reg [9:0]  sas_spc; // seems to be unused
reg [1:0]  sas_thread;
reg [2:0]  sas_win;
reg [5:0]  sas_addr;
reg [4:0]  sas_cond;
reg [63:0] sas_reg;
reg [63:0] sas_val;
reg        dummy;
reg        sas_int;

integer    i, max;
reg         reset_status, expected_warm, swap;
reg       debug_sas;
initial begin
    reset_status = 0;
    expected_warm= 0;
    swap         = 0;

    if($test$plusargs("use_sas_tasks"))
    begin
        sas_def = 1;
        $display("ttt:sas_def = 1");
    end
    else
    begin
        sas_def = 0;
        $display("ttt:sas_def = 0");
    end

    // sas_def = 1; //ttttttt
    if(sas_def)begin
        dummy = $bw_decoder(1);//create handle for this core.
        $bw_force_by_name(1);
    end
    if($test$plusargs("debug_sas")) debug_sas =1;
    else debug_sas = 0;
end // initial begin

//mra memory contets
`ifndef __ICARUS__
task mra_val;
    input [9:0] cpu;
    input [3:0] idx;
    output [159:0] mra_wdata;
    reg [159:0] mra_wdata;

`ifdef FPGA_SYN_16x160
    reg [7:0] tmp;
`endif
    begin
        case(cpu)
            
    `ifdef RTL_SPARC0
               10'd0 : begin
    `ifndef PITON_PROTO
    `ifdef FPGA_SYN_16x160
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr0.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr0.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr0.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr0.inq_ary3, tmp[7:6]);
                    mra_wdata[7:0] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr1.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr1.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr1.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr1.inq_ary3, tmp[7:6]);
                    mra_wdata[15:8] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr2.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr2.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr2.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr2.inq_ary3, tmp[7:6]);
                    mra_wdata[23:16] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr3.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr3.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr3.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr3.inq_ary3, tmp[7:6]);
                    mra_wdata[31:24] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr4.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr4.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr4.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr4.inq_ary3, tmp[7:6]);
                    mra_wdata[39:32] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr5.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr5.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr5.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr5.inq_ary3, tmp[7:6]);
                    mra_wdata[47:40] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr6.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr6.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr6.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr6.inq_ary3, tmp[7:6]);
                    mra_wdata[55:48] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr7.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr7.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr7.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr7.inq_ary3, tmp[7:6]);
                    mra_wdata[63:56] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr8.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr8.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr8.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr8.inq_ary3, tmp[7:6]);
                    mra_wdata[71:64] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr9.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr9.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr9.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr9.inq_ary3, tmp[7:6]);
                    mra_wdata[79:72] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr10.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr10.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr10.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr10.inq_ary3, tmp[7:6]);
                    mra_wdata[87:80] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr11.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr11.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr11.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr11.inq_ary3, tmp[7:6]);
                    mra_wdata[95:88] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr12.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr12.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr12.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr12.inq_ary3, tmp[7:6]);
                    mra_wdata[103:96] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr13.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr13.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr13.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr13.inq_ary3, tmp[7:6]);
                    mra_wdata[111:104] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr14.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr14.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr14.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr14.inq_ary3, tmp[7:6]);
                    mra_wdata[119:112] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr15.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr15.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr15.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr15.inq_ary3, tmp[7:6]);
                    mra_wdata[127:120] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr16.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr16.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr16.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr16.inq_ary3, tmp[7:6]);
                    mra_wdata[135:128] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr17.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr17.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr17.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr17.inq_ary3, tmp[7:6]);
                    mra_wdata[143:136] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr18.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr18.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr18.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr18.inq_ary3, tmp[7:6]);
                    mra_wdata[151:144] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr19.inq_ary0, tmp[1:0]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr19.inq_ary1, tmp[3:2]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr19.inq_ary2, tmp[5:4]);
                    $bw_force_by_name(2, idx, `TLUPATH0.mra.arr19.inq_ary3, tmp[7:6]);
                    mra_wdata[159:152] = {tmp[7],tmp[5],tmp[3],tmp[1],tmp[6],tmp[4],tmp[2],tmp[0]};
        `else
            $bw_force_by_name(2, idx, `TLUPATH0.mra.inq_ary, mra_wdata);
        `endif
    `else
    $bw_force_by_name(2, idx, `TLUPATH0.mra.inq_ary, mra_wdata);
    `endif // PITON_PROTO
                end
    `endif



        endcase // case(cpu)
    end
endtask // mra_val
//do reset tlb valid bit.
task tlb_reset;
    input [9:0] core;
    input [5:0] idx;
    input [1:0] which_tlb;

    begin
        case(core)
        
    `ifdef RTL_SPARC0
                10'd0 : if(which_tlb == 1)$bw_force_by_name(3, `DTLBPATH0.tlb_entry_vld, idx);
                    else $bw_force_by_name(3, `ITLBPATH0.tlb_entry_vld, idx);
    `endif



        endcase // case(core)
    end
endtask // tlb_reset
`endif
reg timestamp, timest;
reg [63:0] time_stamp;
reg         pli_flag;

integer    rtl_counter;
initial begin
    timestamp = 1;
    timest = 1;
end
//send rtl cycle
always @(posedge clk)begin
    if(rst_l)begin
        sas_int      = 0;
        reset_status = 1;
        if(sas_def)begin
            if(timest)begin
                timest = 0;
                time_stamp = $time;
            end
            `SAS_INTER.send_model;
            rtl_counter = rtl_counter + 1;
            //if(pli_flag)$display("Info:Debug Time(%0t) rtl_cycle(%0d)", $time, rtl_counter);
        end
        sas_int      = 1;

        `ifdef SAS_DISABLE
        `else
        
     `ifdef RTL_SPARC0
    `SAS_TASKS.task0.process;
      `endif



        `endif // SAS_DISABLE

        if(sas_def)begin
	    `ifndef __ICARUS__
            rdAndcmp;
            if(`TOP_MOD.diag_done)send_cmd(`PLI_RETRY, 0, 0, 0, 0, 0);
            if(expected_warm)begin
                //if(`TOP_MOD.init_done)begin
                if(`FAKE_IOB.cpx_data[`CPX_VLD]                            &&
                        (`FAKE_IOB.cpx_data[`CPX_RQ_HI:`CPX_RQ_LO] == `INT_RET) &&
                        `FAKE_IOB.cpx_data[17:16] == 1)begin
                    expected_warm = 0;
                    //reset list and buffer
                    $bw_reset_buf();//always send C0T0
                    //dummy = $bw_list(`TOP_MOD.list_handle, `RESET_COMMAND);//clean instruction and register buffer
                    dummy = $bw_decoder(`RESET_COMMAND, `TOP_MOD.list_handle);
                    dummy = $bw_sas_send(`PLI_FORCE_TRAP_TYPE, 0, 8'b0000_0001);//trap type one

                    
    `ifdef RTL_SPARC0
      `SAS_TASKS.task0.reset_clean;
    `endif




                    for(i = 0; i < `NUM_TILES;i = i + 1)begin
                        `TOP_MOD.monitor.pc_cmp.timeout[i]       = 0;
                        `TOP_MOD.monitor.pc_cmp.active_thread[i] = 0;
                    end
                    //set active thread.
                    //`TOP_MOD.monitor.pc_cmp.active_thread[0] = 1;
                    $display("Get wake up signal from cpx");
                    $display("wake up thread: %b", `FAKE_IOB.cpx_data[12:8]);
                    `TOP_MOD.monitor.pc_cmp.active_thread[`FAKE_IOB.cpx_data[12:8]] = 1;
                    max = `TOP_MOD.monitor.pc_cmp.max;
                    `TOP_MOD.monitor.pc_cmp.max = 4000000;//waiting for dram wake up.
                    swap = 1;
                end // if (`TOP_DESIGN.iob_cpx_data_ca[`CPX_VLD] &&...
            end // if (expected_warm)
	    `endif
        end // if (sas_def)
    end // if (rst_l)
    else if(reset_status)expected_warm = 1;
    if(swap &&
            // `DCTLPATH0.dramctl0.dram_dctl.dram_que.que_bank_idle_cnt == 5'h1c &&
            // `DCTLPATH0.dramctl1.dram_dctl.dram_que.que_bank_idle_cnt == 5'h1c &&
            // `DCTLPATH1.dramctl0.dram_dctl.dram_que.que_bank_idle_cnt == 5'h1c &&
            // `DCTLPATH1.dramctl1.dram_dctl.dram_que.que_bank_idle_cnt == 5'h1c)begin
            1'b1) begin // tttttttttttt
        `TOP_MOD.monitor.pc_cmp.max = max;
        swap  = 0;
    end

end // always @ (posedge clk)

integer   sent;
/*-----------------------------------------------------------------
assign symbolic name.
----------------------------------------------------------------*/
//regs symbol.
reg [7:0] sym_tab[3:0];
reg [7:0] sym;
reg [240:0] str[`FLOAT_X:`PC];

initial begin

    sym_tab[0]                       = "g";
    sym_tab[1]                       = "o";
    sym_tab[2]                       = "l";
    sym_tab[3]                       = "i";
    sent                             = 0;
    str[`PC]                         = "PC";
    str[`NPC]                        = "NPC";
    str[`Y]                          = "Y";
    str[`CCR]                        = "CCR";
    str[`FPRS]                       = "FPRS";
    str[`FSR]                        = "FSR";
    str[`ASI]                        = "ASI";
    str[`TICK_SAS]                   = "TICK";
    str[`GSR]                        = "GSR";
    str[`TICK_CMPR]                  = "TICK_CMPR";
    str[`STICK]                      = "STICK";
    str[`STICK_CMPR]                 = "STICK_CMPR";
    str[`PSTATE_SAS]                 = "PSTATE";
    str[`TL_SAS]                     = "TL";
    str[`PIL_SAS]                    = "PIL";
    str[`TPC1]                       = "TPC1";
    str[`TPC2]                       = "TPC2";
    str[`TPC3]                       = "TPC3";
    str[`TPC4]                       = "TPC4";
    str[`TPC5]                       = "TPC5";
    str[`TPC6]                       = "TPC6";
    str[`TNPC1]                      = "TNPC1";
    str[`TNPC2]                      = "TNPC2";
    str[`TNPC3]                      = "TNPC3";
    str[`TNPC4]                      = "TNPC4";
    str[`TNPC5]                      = "TNPC5";
    str[`TNPC6]                      = "TNPC6";
    str[`TSTATE1]                    = "TSTATE1";
    str[`TSTATE2]                    = "TSTATE2";
    str[`TSTATE3]                    = "TSTATE3";
    str[`TSTATE4]                    = "TSTATE4";
    str[`TSTATE5]                    = "TSTATE5";
    str[`TSTATE6]                    = "TSTATE6";
    str[`TT1]                        = "TT1";
    str[`TT2]                        = "TT2";
    str[`TT3]                        = "TT3";
    str[`TT4]                        = "TT4";
    str[`TT5]                        = "TT5";
    str[`TT6]                        = "TT6";
    str[`TBA_SAS]                    = "TBA";
    str[`VER]                        = "VER";
    str[`CWP]                        = "CWP";
    str[`CANSAVE]                    = "CANSAVE";
    str[`CANRESTORE]                 = "CANRESTORE";
    str[`OTHERWIN]                   = "OTHERWIN";
    str[`WSTATE]                     = "WSTATE";
    str[`CLEANWIN]                   = "CLEANWIN";
    str[`SOFTINT]                    = "SOFTINT";
    str[`ECACHE_ERROR_ENABLE]        = "ECACHE_ERROR_ENABLE";
    str[`ASYNCHRONOUS_FAULT_STATUS]  = "ASYNCHRONOUS_FAULT_STATUS";
    str[`ASYNCHRONOUS_FAULT_ADDRESS] = "ASYNCHRONOUS_FAULT_ADDRESS";
    str[`OUT_INTR_DATA0]             = "OUT_INTR_DATA0";
    str[`OUT_INTR_DATA1]             = "OUT_INTR_DATA1";
    str[`OUT_INTR_DATA2]             = "OUT_INTR_DATA2";
    str[`INTR_DISPATCH_STATUS]       = "INTR_DISPATCH_STATUS";
    str[`IN_INTR_DATA0]              = "IN_INTR_DATA0";
    str[`IN_INTR_DATA1]              = "IN_INTR_DATA1";
    str[`IN_INTR_DATA2]              = "IN_INTR_DATA2";
    str[`INTR_RECEIVE]               = "INTR_RECEIVE";
    str[`GL]                         = "GL";
    str[`HPSTATE_SAS]                = "HPSTATE";
    str[`HTSTATE1]                   = "HTSTATE1";
    str[`HTSTATE2]                   = "HTSTATE2";
    str[`HTSTATE3]                   = "HTSTATE3";
    str[`HTSTATE4]                   = "HTSTATE4";
    str[`HTSTATE5]                   = "HTSTATE5";
    str[`HTSTATE6]                   = "HTSTATE6";
    str[`HTSTATE7]                   = "HTSTATE7";
    str[`HTSTATE8]                   = "HTSTATE8";
    str[`HTSTATE9]                   = "HTSTATE9";
    str[`HTSTATE10]                  = "HTSTATE10";
    str[`HTBA_SAS]                   = "HTBA";
    str[`HINTP_SAS]                  = "HINTP";
    str[`HSTICK_CMPR]                = "HSTICK_CMPR";
    str[`MID]                        = "MID";
    str[`ISFSR]                      = "ISFSR";
    str[`DSFSR]                      = "DSFSR";
    str[`SFAR]                       = "SFAR";
    str[`I_TAG_ACCESS]               = "I_TAG_ACCESS";
    str[`D_TAG_ACCESS]               = "D_TAG_ACCESS";
    str[`CTXT_PRIM]                  = "CTXT_PRIM";
    str[`CTXT_SEC]                   = "CTXT_SEC";
    str[`SFP_REG]                    = "SFP_REG";
    str[`I_CTXT_ZERO_PS0]            = "I_CTXT_ZERO_PS0";
    str[`D_CTXT_ZERO_PS0]            = "D_CTXT_ZERO_PS0";
    str[`I_CTXT_ZERO_PS1]            = "I_CTXT_ZERO_PS1";
    str[`D_CTXT_ZERO_PS1]            = "D_CTXT_ZERO_PS1";
    str[`I_CTXT_ZERO_CONFIG]         = "I_CTXT_ZERO_CONFIG";
    str[`D_CTXT_ZERO_CONFIG]         = "D_CTXT_ZERO_CONFIG";
    str[`I_CTXT_NONZERO_PS0]         = "I_CTXT_NONZERO_PS0";
    str[`D_CTXT_NONZERO_PS0]         = "D_CTXT_NONZERO_PS0";
    str[`I_CTXT_NONZERO_PS1]         = "I_CTXT_NONZERO_PS1";
    str[`D_CTXT_NONZERO_PS1]         = "D_CTXT_NONZERO_PS1";
    str[`I_CTXT_NONZERO_CONFIG]      = "I_CTXT_NONZERO_CONFIG";
    str[`D_CTXT_NONZERO_CONFIG]      = "D_CTXT_NONZERO_CONFIG";
    str[`I_TAG_TARGET]               = "I_TAG_TARGET";
    str[`D_TAG_TARGET]               = "D_TAG_TARGET";
    str[`I_TSB_PTR_PS0]              = "I_TSB_PTR_PS0";
    str[`D_TSB_PTR_PS0]              = "D_TSB_PTR_PS0";
    str[`I_TSB_PTR_PS1]              = "I_TSB_PTR_PS1";
    str[`D_TSB_PTR_PS1]              = "D_TSB_PTR_PS1";
    str[`D_TSB_DIR_PTR]              = "D_TSB_DIR_PTR";
    str[`VA_WP_ADDR]                 = "VA_WP_ADDR";
    str[`PID]                        = "PID";
    str[`REG_WRITE_BACK]             = "general register";
    str[`FLOAT_I]                    = "floating point";
    str[`FLOAT_X]                    = "floating point";
end // initial begin

/*-----------------------------------------------------------------
read data from socket and do comparsion.
----------------------------------------------------------------*/
reg [4:0]   next_thread;
reg [3:0]   recv_status;
reg [3:0]   ready;
reg [240:0] t_str;
reg [7:0]   which;
reg [9:0]   next_which;
reg [63:0]  rtl_val;
integer     good_timeout;
//keep the drop invr data
reg [31:0]  drop_vld;
reg [63:0]  drop_val[31:0];
reg [2:0]   drop_win[31:0];
reg [3:0]   drop_cond[31:0];

reg [31:0]  mul_vld;
reg [63:0]  mul_val[31:0];
reg [4:0]   mul_reg[31:0];
reg [4:0]   mul_win[31:0];

reg [31:0]  smul_vld;
reg [63:0]  smul_val[31:0];
reg [4:0]   smul_reg[31:0];
reg [4:0]   smul_win[31:0];

reg [3:0]   tmp_val;
reg [63:0]  mulv;
reg [4:0]   mulr;
reg          mul, inst_cond;
reg [4:0]   mulw;
//use for instruction checker.
reg [4:0]   inst_thread;
reg          wasthere, once_try;
reg [7:0]   ccr_req;

integer          idx;
reg            less;

initial begin
    good_timeout = 0;
    drop_vld     = 0;
    mul_vld      = 0;
    wasthere     = 1;
    once_try     = 1;
    smul_vld     = 0;
end

always @(posedge clk)begin
    if(`TOP_MOD.diag_done)good_timeout = good_timeout + 1;
    if(good_timeout > 3200000)begin
        // Tri: original time out is 2000 but will timeout before the interrupt gets to the farther tile
        less = 1;
        for(idx = 0; idx < `NUM_TILES;idx = idx + 1)begin
            if(`PC_CMP.finish_mask[idx])begin
                if(`PC_CMP.active_thread[idx] == 0)begin
                    less = 0;
                    $display("%0t:sas_tasks info->you turn on less thread than finish_mask. finish_mask(%x) active_thread(%x)",
                             $time, `PC_CMP.finish_mask, `PC_CMP.active_thread);
                    `MONITOR_PATH.fail("you turn on less thread than finish_mask");
                    idx = `NUM_TILES;
                end
            end
        end
        if(less)begin
            if(which == `INTR_RECEIVE || which == `HINTP_SAS)begin
                dummy = $bw_list(`TOP_MOD.list_handle, 2,sas_which, sas_spc,  sas_thread,
                                 sas_win, sas_addr,      sas_reg,   sas_cond, sas_timer);
                sas_time = sas_timer;

                if (debug_sas)
                    $display("%0t BW_LIST: Pop data type(%d) core(%d) thread(%d) win(%d) reg_num(%d) val(%0x)",$time, sas_which, sas_spc, sas_thread, sas_win, sas_addr, sas_reg);
            end
            else begin
                if(wasthere)begin
                    // tri: disable bc of segfault when calling bw_list
                    // `MONITOR_PATH.fail("sas_fault");
                    // dummy = $bw_list(`TOP_MOD.list_handle, 1,  next_thread,
                    //                  sas_win, sas_addr, which, ready, rtl_val, sas_timer);
                    // sas_time = sas_timer;
                    // wasthere = 0;
                    // if(!dummy)begin
                    //     $display("%0t:Info-> empty list", $time);
                    //     `MONITOR_PATH.fail("No empty list(sas_task)");
                    // end
                    // else begin
                    //     if(once_try && $bw_empty())begin
                    //         dummy = $bw_list(`TOP_MOD.list_handle, 11);
                    //         once_try = 0;

                    //     end
                    //     else begin
                    //         $display("%0t:Info->No response from simics", $time);
                    //         $display("Info:debug for no response thread(%d) command(%s) type(%d)", next_thread, str[which], ready);
                    //         `MONITOR_PATH.fail("No response from bas");
                    //     end
                    // end

                end
            end
        end
    end // if (good_timeout > 2000)
end
//compare instruction
task check_inst;
    begin
        dummy = $bw_sas_recv(sas_val, inst_thread, sas_win, sas_addr, 200, ready,
                             sas_timer, next_which, mul, mulv, mulr, mulw);//got phyical address
        if(sas_def && dummy)begin
            dummy = $bw_list(`TOP_MOD.list_handle, 21, sas_reg,  sas_timer, inst_cond);
            sas_time = sas_timer;
            //      if(mul_vld[inst_thread])mul_vld[inst_thread]  = 0;
            if(inst_cond)begin
                if(sas_val[31:0] == sas_reg[31:0])begin
                    $display("%0t:instruction-MATCH -> spc(%1d) thread(%d) physical_pc(%x) instruction(%x)",
                             sas_time, inst_thread[4:2], inst_thread[1:0], mulv, sas_val[31:0]);
                end
                else begin
                    if(inst_checker_off)begin
                        $display("%0t:(Warning)-instruction -> spc(%1d) thread(%d)  physical_pc(%x) rtl_inst_reg = %x, sas_inst_reg =%x",
                                 sas_time, inst_thread[4:2], inst_thread[1:0], mulv, sas_reg[31:0], sas_val[31:0]);
                        recv_status  = 0;
                    end
                    else if(mulv)begin
                        $display("%0t:MISMATCH-instruction -> spc(%1d) thread(%d)  physical_pc(%x) rtl_inst_reg = %x, sas_inst_reg =%x",
                                 sas_time, inst_thread[4:2], inst_thread[1:0], mulv, sas_reg[31:0], sas_val[31:0]);
                        recv_status  = 0;
                        `MONITOR_PATH.fail("instruction-MISMATCH");
                    end
                end
            end // if (mulv)
        end // if (sas_def && dummy)
    end
endtask // check_inst
//we want to compare the instruction after virtual pc match.
reg [7:0] save_which;

task rdAndcmp;
    begin
        if(sas_def)begin
            recv_status = 1;
            while($bw_list(`TOP_MOD.list_handle, 1,  next_thread,
                           sas_win, sas_addr, which, ready, rtl_val, sas_timer) && recv_status && (`TOP_MOD.fail_flag == 0))begin
                sas_time = sas_timer;
                if(which == `HINTP_SAS && ready)begin
                    dummy = $bw_list(`TOP_MOD.list_handle, 2, sas_which, sas_spc,  sas_thread,
                                     sas_win, sas_addr,  sas_reg,   sas_cond, sas_timer);
                    if (debug_sas)
                        $display("%0t BW_LIST: Pop data type(%d) core(%d) thread(%d) win(%d) reg_num(%d) val(%0x)",$time, sas_which, sas_spc, sas_thread, sas_win, sas_addr, sas_reg);
                    sas_time = sas_timer;
                    register_cmp(sas_which, sas_spc, sas_thread, sas_win, sas_addr, sas_reg,
                                 sas_reg, sas_reg, 0, 0, 0, 0, sas_cond);
                end
                else begin
                    save_which = which;
                    //if((which == `PC) && $bw_list(`TOP_MOD.list_handle, 22, inst_thread))check_inst;
                    //process the core registers.
                    mul  = mul_vld[next_thread];
                    mulv = mul_val[next_thread];
                    mulr = mul_reg[next_thread];
                    mulw = mul_win[next_thread];

                    if(which == `REG_WRITE_BACK         &&
                            smul_vld[next_thread]            &&
                            smul_val[next_thread] == rtl_val &&
                            // ready < 2                        &&
                            smul_reg[next_thread] == sas_addr)begin
                        sas_val = smul_val[next_thread];
                        dummy = $bw_list(`TOP_MOD.list_handle, 2, sas_which, sas_spc,  sas_thread,
                                         sas_win, sas_addr,  sas_reg,   sas_cond, sas_timer);
                        if (debug_sas)
                            $display("%0t BW_LIST: Pop data type(%d) core(%d) thread(%d) win(%d) reg_num(%d) val(%0x)",$time, sas_which, sas_spc, sas_thread, sas_win, sas_addr, sas_reg);
                        sas_time = sas_timer;
                        if(ready < 2)
                            register_cmp(sas_which, sas_spc, sas_thread, sas_win, sas_addr, sas_reg,
                                         sas_val, sas_val, 0, 0, 0, 0, sas_cond);
                        smul_vld[next_thread] = 0;
                        recv_status           = 0;
                        dummy = $bw_sas_recv(sas_val, next_thread, sas_win, sas_addr, which, ready, sas_timer, next_which,
                                             mul, mulv, mulr, mulw);
                    end
                    else begin
                        if(which == `REG_WRITE_BACK)smul_vld[next_thread] = 0;
                        case($bw_sas_recv(sas_val, next_thread, sas_win, sas_addr, which, ready, sas_timer, next_which,
                                              mul, mulv, mulr, mulw))
                            0 : begin
                                recv_status                   = 0;
                                if(!mulv)mul_vld[next_thread] = mulv;
                            end
                            1 : begin
                                // if(!((which == `PC || which == `NPC) && !sas_val))begin
                                if((which == `INTR_RECEIVE) &&
                                        drop_vld[next_thread]    &&
                                        (sas_val == drop_val[next_thread]))begin
                                    sas_val   = drop_val[next_thread];
                                    sas_which = which;
                                    sas_spc   = next_thread[4:2];
                                    sas_win   = drop_win[next_thread];
                                    sas_cond  = drop_cond[next_thread];

                                    if(sas_val != sas_reg)begin
                                        dummy = $bw_list(`TOP_MOD.list_handle, 2, sas_which, sas_spc,  sas_thread,
                                                         sas_win, sas_addr,       sas_reg,   sas_cond, sas_timer);
                                        if (debug_sas)
                                            $display("%0t BW_LIST: Pop data type(%d) core(%d) thread(%d) win(%d) reg_num(%d) val(%0x)",$time, sas_which, sas_spc, sas_thread, sas_win, sas_addr, sas_reg);
                                        sas_time = sas_timer;
                                    end

                                    else
                                        register_cmp(sas_which, sas_spc, sas_thread, sas_win, sas_addr, sas_reg,
                                                     sas_val, sas_val, 0, 0, 0, 0, sas_cond);
                                    drop_vld[next_thread] = 0;
                                end
                                else begin
                                    if(mul_vld[next_thread]               &&
                                            (mul_val[next_thread] == sas_val)  &&
                                            (sas_win == mul_win[next_thread])  &&
                                            (mul_reg[next_thread] == sas_addr) &&
                                            (sas_val != rtl_val) &&
                                            (ready != 1))begin
                                        mul_vld[next_thread] = 0;
                                        $display("Info:Mulcc data thread(%d) reg(%d) val(%x)", next_thread, sas_addr, sas_val);
                                    end
                                    else begin
                                        dummy = $bw_list(`TOP_MOD.list_handle, 2,sas_which, sas_spc,  sas_thread,
                                                         sas_win, sas_addr,      sas_reg,   sas_cond, sas_timer);
                                        if (debug_sas)
                                            $display("%0t BW_LIST: Pop data type(%d) core(%d) thread(%d) window(%d) reg(%d) val(%0x)\n", $time, sas_which, sas_spc, sas_thread, sas_win, sas_addr, sas_reg);
                                        sas_time = sas_timer;
                                        if((which == `REG_WRITE_BACK) &&
                                                mul_vld[next_thread])begin
                                            if(mul_reg[next_thread] == sas_addr)mul_vld[next_thread] = 0;
                                        end
                                        if(ready >= 2 || (which == `INTR_RECEIVE))begin//dummy compare
                                            if(sas_reg != sas_val)begin
                                                if(which == `INTR_RECEIVE)
                                                    dummy =  $bw_sas_recv(sas_val, next_thread, sas_win, sas_addr, 254, 9, sas_timer);
                                                else
                                                    dummy =  $bw_sas_recv(sas_val, next_thread, sas_win, sas_addr, 254, ready, sas_timer);
                                            end
                                            else if(which == `INTR_RECEIVE && ready == 1)begin
                                                $display("(%0t):drop intr_receive = %x thread(%d)", sas_time, sas_val, next_thread);
                                            end
                                            if(ready >= 2)begin
                                                if(mul_vld[sas_thread])begin
                                                    smul_vld[sas_thread] = 1;
                                                    $display("Info: dummy mulcc data thread(%d) reg(%d) value(%x)",
                                                             sas_thread, sas_addr, sas_val);
                                                end
                                                mul_vld[sas_thread] = 0;
                                                //smul_vld[sas_thread] = 1;
                                                smul_val[sas_thread] = sas_val;
                                                smul_reg[sas_thread] = sas_addr;
                                                smul_win[sas_thread] = sas_win;
                                            end
                                        end
                                        else begin
                                            register_cmp(sas_which, sas_spc, sas_thread, sas_win, sas_addr, sas_reg,
                                                         sas_val, sas_val, 0, 0, 0, 0, sas_cond);
                                        end // else: !if(ready >= 2 || (which == `INTR_RECEIVE))

                                        if(which == `INTR_RECEIVE)drop_vld[next_thread] = 0;
                                    end // else: !if(mul_vld[next_thread])
                                end // else: !if((which == `INTR_RECEIVE) &&...
                                //end // if (!((which == `PC || which == `NPC) && !sas_val))

                                good_timeout = 0;
                            end
                            2 : begin
                                recv_status = 0;
                                dead_socket = 1;
                                $display("Info:type(%0s) thread(%x) rtl-expected(%x)", str[which], next_thread, sas_reg);
                                `MONITOR_PATH.fail("missed_trigger");
                            end
                            3 : begin
                                dummy = $bw_list(`TOP_MOD.list_handle, 2,         sas_which, sas_spc, sas_thread,
                                                 sas_win, sas_addr,     sas_reg,  sas_cond, sas_timer);
                                if (debug_sas)
                                    $display("%0t BW_LIST: Pop data type(%d) core(%d) thread(%d) window(%d) reg(%d) val(%0x)\n", $time, sas_which, sas_spc, sas_thread, sas_win, sas_addr, sas_reg);
                                sas_time = sas_timer;
                                if(!(ready >= 2))begin
                                    if(which == `REG_WRITE_BACK)begin
                                        if(sas_addr < 8)
                                            $display("%0t:wrong_trigger->spc(%1d) thread(%x) window(%x) type(global) reg(%d) rtl-expected(%x)",
                                                     sas_time, sas_spc, sas_thread, sas_win,  sas_addr[2:0], sas_reg);
                                        else if(sas_addr < 16)
                                            $display("%0t:wrong_trigger->spc(%1d) thread(%x) window(%x) type(out) reg(%d) rtl-expected(%x)",
                                                     sas_time, sas_spc, sas_thread, sas_win,  sas_addr[2:0], sas_reg);
                                        else if(sas_addr < 24)
                                            $display("%0t:wrong_trigger->spc(%1d) thread(%x) window(%x) type(local) reg(%d) rtl-expected(%x)",
                                                     sas_time, sas_spc, sas_thread, sas_win,  sas_addr[2:0], sas_reg);
                                        else
                                            $display("%0t:wrong_trigger->spc(%1d) thread(%x) window(%x) type(in) reg(%d) rtl-expected(%x)",
                                                     sas_time, sas_spc, sas_thread, sas_win,  sas_addr[2:0], sas_reg);
                                    end // if (which == `REG_WRITE_BACK)
                                    else $display("%0t:wrong_trigger->spc(%1d) thread(%x) window(%x) type(%0s) reg(%d) rtl-expected(%x)",
                                                      sas_time, sas_spc, sas_thread, sas_win, str[which], sas_addr, sas_reg);
                                    dead_socket = 1;
                                    `MONITOR_PATH.fail("Wrong_trigger");
                                end // if (ready != 2)
                                else begin //drop data.
                                    $display("Info: pop thread(%x) addr(%d) val(%x)", next_thread, sas_addr, sas_reg);
                                    dummy =  $bw_sas_recv(sas_val, next_thread, sas_win, sas_addr, 254, 10, sas_which, sas_reg);
                                end // else: !if(!(ready >= 2))
                                recv_status = 0;
                            end
                            4 : begin
                                recv_status = 0;
                                dead_socket = 1;
                                $display("%0t:Info->Cannot send data to simics", $time);
                                `MONITOR_PATH.fail("simics socket dead");
                            end
                            5 : begin//interrupt receiver register

                                tmp_val = $bw_list(`TOP_MOD.list_handle, 4, sas_val, sas_win, sas_cond, next_thread);
                                if(tmp_val == 1)begin
                                    drop_vld[next_thread]  = 1;
                                    drop_val[next_thread]  = sas_val;
                                    drop_win[next_thread]  = sas_win;
                                    drop_cond[next_thread] = sas_cond;
                                end
                                else if(tmp_val == 2)begin
                                    mul_vld[next_thread]   = 1;
                                    mul_val[next_thread]   = sas_val;
                                    mul_reg[next_thread]   = sas_cond;
                                    mul_win[next_thread]   = sas_win;
                                end
                                recv_status = 0;
                            end
                            7 : begin//shift by one
                                dummy       = $bw_list(`TOP_MOD.list_handle, 5);
                                recv_status = 0;
                            end
                            8: begin
                                recv_status = 0;
                                dead_socket = 1;
                                $display("%0t:Info->Maybe simics in infinite loop.", $time);
                                `MONITOR_PATH.fail("simics doesn't send data to RTL.");
                            end
                            9 : begin//search for the potential matching value.
                                if($bw_list(`TOP_MOD.list_handle, 6, next_which))begin
                                    dummy =  $bw_sas_recv(sas_val, next_thread, sas_win, sas_addr, 254, 11, sas_which);
                                    if(!(ready >= 2))begin
                                        dummy = $bw_list(`TOP_MOD.list_handle, 2, sas_which, sas_spc, sas_thread,
                                                         sas_win, sas_addr, sas_reg,  sas_cond, sas_timer);
                                        if (debug_sas)
                                            $display("%0t BW_LIST: Pop data type(%d) core(%d) thread(%d) window(%d) reg(%d) val(%0x)\n", $time, sas_which, sas_spc, sas_thread, sas_win, sas_addr, sas_reg);
                                        sas_time = sas_timer;
                                        if(which == `REG_WRITE_BACK)begin
                                            if(sas_addr < 8)
                                                $display("%0t:wrong_trigger->spc(%1d) thread(%x) window(%x) type(global) reg(%d) rtl-expected(%x)",
                                                         sas_time, sas_spc, sas_thread, sas_win,  sas_addr[2:0], sas_reg);
                                            else if(sas_addr < 16)
                                                $display("%0t:wrong_trigger->spc(%1d) thread(%x) window(%x) type(out) reg(%d) rtl-expected(%x)",
                                                         sas_time, sas_spc, sas_thread, sas_win,  sas_addr[2:0], sas_reg);
                                            else if(sas_addr < 24)
                                                $display("%0t:wrong_trigger->spc(%1d) thread(%x) window(%x) type(local) reg(%d) rtl-expected(%x)",
                                                         sas_time, sas_spc, sas_thread, sas_win,  sas_addr[2:0], sas_reg);
                                            else
                                                $display("%0t:wrong_trigger->spc(%1d) thread(%x) window(%x) type(in) reg(%d) rtl-expected(%x)",
                                                         sas_time, sas_spc, sas_thread, sas_win,  sas_addr[2:0], sas_reg);
                                        end
                                        else $display("%0t:wrong_trigger->spc(%1d) thread(%x) window(%x) type(%0s) reg(%d) rtl-expected(%x)",
                                                          sas_time, sas_spc, sas_thread, sas_win, str[which], sas_addr, sas_reg);
                                        dead_socket = 1;
                                        `MONITOR_PATH.fail("Wrong_trigger");
                                    end
                                end // if ($bw_list(`TOP_MOD.list_handle, 6, next_which))
                                else begin
                                    recv_status = 0;
                                    dummy =  $bw_sas_recv(sas_val, next_thread, sas_win, sas_addr, 254, 12, next_which);
                                end // else: !if($bw_list(`TOP_MOD.list_handle, 6, next_which))

                            end // case: 9
                            10 : //hit good trap
                            begin
                                dummy = $bw_list(`TOP_MOD.list_handle, 2,sas_which, sas_spc,  sas_thread,
                                                 sas_win, sas_addr,      sas_reg,   sas_cond, sas_timer);
                                if (debug_sas)
                                    $display("%0t BW_LIST: Pop data type(%d) core(%d) thread(%d) window(%d) reg(%d) val(%0x)\n", $time, sas_which, sas_spc, sas_thread, sas_win, sas_addr, sas_reg);
                                sas_time = sas_timer;
                                recv_status = 0;
                            end
                        endcase // case($bw_sas_recv(sas_val, next_thread, sas_win, sas_addr))
                    end // else: !if(which == `REG_WRITE_BACK &&...

                    if((which == `PC) && $bw_list(`TOP_MOD.list_handle, 22, inst_thread))check_inst;

                end
            end // if (sas_def)
        end // if (sas_def)
    end
endtask // endtask

//integrate all socket send request to prevent the deadlock case.
/*   task send_cmd;
input [7:0]    cmd;
input [7:0]    thr;
input [7:0]    win;
input [7:0]    addr;
input [10:0]   counter;
input [4287:0] data;//4288


begin
case(cmd)
`PLI_QUIT             : sent = sent + 1;
`PLI_SSTEP            : sent = sent + 2;
`PLI_READ_TH_REG      : sent = sent + 4;
`PLI_READ_TH_CTL_REG  : sent = sent + 3;
`PLI_READ_TH_FP_REG_I : sent = sent + 3;
`PLI_READ_TH_FP_REG_X : sent = sent + 3;
`PLI_RTL_CYCLE        : sent = sent + counter ;
`PLI_RTL_DATA         : sent = sent + 536;
`PLI_WRITE_TH_XCC_REG : sent = sent + 3;
endcase // case(cmd)
if((sent >=  `CMD_BUFSIZE) && (cmd != `PLI_QUIT))begin
while(sent != 0)begin
sent = $bw_sas_send(`PLI_RETRY);
rdAndcmp;
if(dead_socket)begin
sent = `CMD_BUFSIZE;
@ (posedge clk);
end
end
end
case(cmd)
`PLI_QUIT             : sent = $bw_sas_send(`PLI_QUIT);
`PLI_SSTEP            : sent = $bw_sas_send(`PLI_SSTEP, thr);
`PLI_READ_TH_REG      : sent = $bw_sas_send(`PLI_READ_TH_REG, thr, win, addr);
`PLI_READ_TH_CTL_REG  : sent = $bw_sas_send(`PLI_READ_TH_CTL_REG, thr, win);
`PLI_READ_TH_FP_REG_I : sent = $bw_sas_send(`PLI_READ_TH_FP_REG_I, thr, addr);
`PLI_READ_TH_FP_REG_X : sent = $bw_sas_send(`PLI_READ_TH_FP_REG_X, thr, addr);
`PLI_RTL_CYCLE        : sent = $bw_sas_send(`PLI_RTL_CYCLE, counter);
`PLI_RTL_DATA         : sent = $bw_sas_send(`PLI_RTL_DATA, data);
`PLI_WRITE_TH_XCC_REG : sent = $bw_sas_send(`PLI_WRITE_TH_XCC_REG, thr, win);
`PLI_RETRY            : sent = $bw_sas_send(`PLI_RETRY);
endcase // case(cmd)
end
endtask // send_cmd
*/
// reg timestamp;
// reg [63:0] time_stamp;

reg [31:0] max_32;

initial
begin
    timestamp   = 1;
    rtl_counter = 0;
    pli_flag    = 0;
    if($test$plusargs("debug_cycle"))pli_flag = 1;
end



task send_cmd;
    input [7:0]    cmd;
    input [7:0]    thr;
    input [7:0]    win;
    input [7:0]    addr;
    input [10:0]   counter;
    input [4287:0] data;//4288

    begin //send rtl cycle before sending any request to simics.
        if(sas_int && `SAS_INTER.counter)begin
            sent = $bw_sas_send(`PLI_RTL_CYCLE, `SAS_INTER.counter);
            `SAS_INTER.counter = 0;
        end
        case(cmd)
            `PLI_QUIT             : sent = $bw_sas_send(`PLI_QUIT);
            `PLI_SSTEP            : sent = $bw_sas_send(`PLI_SSTEP, thr);
            `PLI_READ_TH_REG      : sent = $bw_sas_send(`PLI_READ_TH_REG, thr, win, addr);
            `PLI_READ_TH_CTL_REG  : sent = $bw_sas_send(`PLI_READ_TH_CTL_REG, thr, win);
            `PLI_READ_TH_FP_REG_I : sent = $bw_sas_send(`PLI_READ_TH_FP_REG_I, thr, addr);
            `PLI_READ_TH_FP_REG_X : sent = $bw_sas_send(`PLI_READ_TH_FP_REG_X, thr, addr);
            `PLI_RTL_CYCLE        : begin
                if(timestamp)begin
                    timestamp  = 0;
                    sent = $bw_sas_send(`TIMESTAMP, time_stamp[63:56], time_stamp[55:48],  time_stamp[47:40], time_stamp[39:32],
                                        time_stamp[31:24], time_stamp[23:16],  time_stamp[15:8],  time_stamp[7:0]);

                end
                sent = $bw_sas_send(`PLI_RTL_CYCLE, counter);

            end

            `PLI_RTL_DATA         : begin
                sent = $bw_sas_send(`PLI_RTL_DATA, data);
            end

            `PLI_WRITE_TH_XCC_REG : sent = $bw_sas_send(`PLI_WRITE_TH_XCC_REG, thr, win);
            `PLI_WRITE_TH_REG_HI  : sent = $bw_sas_send(`PLI_WRITE_TH_REG_HI, thr, win, addr,
                        data[31:24], data[23:16],  data[15:8], data[7:0]);
            `PLI_WRITE_TH_REG     : sent = $bw_sas_send(`PLI_WRITE_TH_REG, thr, win, addr,
                        data[63:56], data[55:48],  data[47:40], data[39:32],
                        data[31:24], data[23:16],  data[15:8], data[7:0]);
            `PLI_WRITE_TH_CTL_REG : sent = $bw_sas_send(`PLI_WRITE_TH_CTL_REG, thr, addr,
                        data[63:56], data[55:48],  data[47:40], data[39:32],
                        data[31:24], data[23:16],  data[15:8],  data[7:0]);
            `PLI_RETRY            : sent = $bw_sas_send(`PLI_RETRY);
            `PLI_FORCE_TRAP_TYPE  : sent = $bw_sas_send(`PLI_FORCE_TRAP_TYPE, thr, data[7:0]);
            `PLI_RESET_TLB_ENTRY  : sent = $bw_sas_send(`PLI_RESET_TLB_ENTRY, thr, win, addr);
            `PLI_INST_TTE         : sent = $bw_sas_send(`PLI_INST_TTE, thr,
                        data[63:56], data[55:48],  data[47:40], data[39:32],
                        data[31:24], data[23:16],  data[15:8],  data[7:0]);
            `PLI_DATA_TTE         : sent = $bw_sas_send(`PLI_DATA_TTE, thr,
                        data[63:56], data[55:48],  data[47:40], data[39:32],
                        data[31:24], data[23:16],  data[15:8],  data[7:0]);
        endcase // case(cmd)
    end
endtask // send_cmd
task register_cmp;
    input [7:0]  type;
    input [9:0]  spc;
    input [1:0]  thread;
    input [2:0]  window;
    input [5:0]  rtl_reg_addr;
    input [63:0] rtl_reg_val;
    input [63:0] sas_reg_val;
    input [63:0] sas_sps_val;
    input [4:0]  rs1;
    input [63:0] val1;
    input [4:0]  rs2;
    input [63:0] val2;
    input [3:0]  cond;
    reg   [63:0] sas_temp;

    begin
        case(type)
            `REG_WRITE_BACK : begin
                sym = sym_tab[rtl_reg_addr[5:3]];
                if(sas_def == 0)begin
                    $display("%0t:reg_updated -> spc(%1d) thread(%d) window(%d) rs1(%x)->%x rs2(%x)->%x reg#(%s%0x) val = %x",
                             $time, spc,  thread, window, rs1, val1, rs2, val2, sym, rtl_reg_addr[2:0], rtl_reg_val);
                end

                else if(rtl_reg_addr == 6'b00_0000)begin
                    /*$display("%0d:Warning : reg-MISMATCH -> spc(%1d) thread(%d) window(%d) rs1(%x)->%x rs2(%x)->%x reg#(%s%0x) rtl_reg_val = %x, sas_reg_val =%x",
                    $time, spc, thread, window, rs1, val1, rs2, val2, sym, rtl_reg_addr[2:0], rtl_reg_val, sas_reg_val);*/
                end // if (rtl_reg_addr == 6'b00_0000)
                else if(cond)begin
                    if(cond[2])begin
                        if(rtl_reg_val[7:0] == sas_reg_val[7:0])begin
                            $display("%0t:reg-MATCH -> spc(%1d)  thread(%d) window(%d) rs1(%x)->%x rs2(%x)->%x reg#(%s%0x) val = %x",
                                     sas_time, spc,  thread, window, rs1, val1, rs2, val2, sym, rtl_reg_addr[2:0], rtl_reg_val[7:0]);
                        end
                        else begin
                            $display("%0t:reg-MISMATCH -> spc(%1d) thread(%d) window(%d) rs1(%x)->%x rs2(%x)->%x reg#(%s%0x) rtl_reg_val = %x, sas_reg_val =%x",
                                     sas_time, spc,  thread, window, rs1, val1, rs2, val2, sym, rtl_reg_addr[2:0], rtl_reg_val[15:0], sas_reg_val[15:0]);
                            `MONITOR_PATH.fail("reg-MISMATCH");
                        end
                    end
                    else if(rtl_reg_val[31:0] == sas_reg_val[31:0])begin
                        $display("%0t:reg-MATCH -> spc(%1d)  thread(%d) window(%d) rs1(%x)->%x rs2(%x)->%x reg#(%s%0x) val = %x",
                                 sas_time, spc,  thread, window, rs1, val1, rs2, val2, sym, rtl_reg_addr[2:0], rtl_reg_val[31:0]);
                    end
                    else begin
                        $display("%0t:reg-MISMATCH -> spc(%1d) thread(%d) window(%d) rs1(%x)->%x rs2(%x)->%x reg#(%s%0x) rtl_reg_val = %x, sas_reg_val =%x",
                                 sas_time, spc,  thread, window, rs1, val1, rs2, val2, sym, rtl_reg_addr[2:0], rtl_reg_val[31:0], sas_reg_val[31:0]);
                        `MONITOR_PATH.fail("reg-MISMATCH");
                    end
                end
                else  if(rtl_reg_val == sas_reg_val)begin
                    $display("%0t:reg-MATCH -> spc(%1d)  thread(%d) window(%d) rs1(%x)->%x rs2(%x)->%x reg#(%s%0x) val = %x",
                             sas_time, spc,  thread, window, rs1, val1, rs2, val2, sym, rtl_reg_addr[2:0], rtl_reg_val);
                end
                else begin
                    dummy =  $bw_sas_recv(sas_val, next_thread, sas_win, sas_addr, 254, 77, sas_which, sas_temp);
                    //  $display("MISM %x %x %x\n", dummy, sas_temp, sas_reg_val);

                    if(dummy && (sas_temp == sas_reg_val) )begin
                        dummy  = $bw_list(`TOP_MOD.list_handle, 7);//push back
                    end
                    else begin
                        $display("%0t:reg-MISMATCH -> spc(%1d) thread(%d) window(%d) rs1(%x)->%x rs2(%x)->%x reg#(%s%0x) rtl_reg_val = %x, sas_reg_val =%x",
                                 sas_time, spc,  thread, window, rs1, val1, rs2, val2, sym, rtl_reg_addr[2:0], rtl_reg_val, sas_reg_val);
                        `MONITOR_PATH.fail("reg-MISMATCH");
                    end
                end
            end
            `PC             : begin
                if(sas_def == 0)begin
                    $display("%0t:pc-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(cond[3])begin//AM bit set
                    if(rtl_reg_val[31:0] == sas_sps_val[31:0])begin
                        $display("%0t:pc-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                 sas_time, spc, thread, window, rtl_reg_val[31:0]);
                    end
                    else begin
                        $display("%0t:pc-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_pc_reg = %x, sas_pc_reg =%x",
                                 sas_time, spc, thread, window, rtl_reg_val[31:0], sas_sps_val[31:0]);
                        `MONITOR_PATH.fail("pc-MISMATCH");
                    end
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:pc-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else begin
                    $display("%0t:pc-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_pc_reg = %x, sas_pc_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("pc-MISMATCH");
                end
            end
            `NPC             : begin
                if(sas_def == 0)begin
                    $display("%0t:npc-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(cond[3])begin//PSTATE.AM=1
                    if(rtl_reg_val[31:0] == sas_sps_val[31:0])begin
                        $display("%0t:npc-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                 sas_time, spc, thread, window, rtl_reg_val[31:0]);
                    end
                    else begin
                        $display("%0t:npc-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_npc_reg = %x, sas_npc_reg =%x",
                                 sas_time, spc, thread, window, rtl_reg_val[31:0], sas_sps_val[31:0]);
                        `MONITOR_PATH.fail("npc-MISMATCH");
                    end
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:npc-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end

                else begin
                    $display("%0t:npc-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_npc_reg = %x, sas_npc_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("npc-MISMATCH");
                end
            end
            `Y              : begin
                if(sas_def == 0)begin
                    $display("%0t:y_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[31:0]);
                end
                else if(rtl_reg_val[31:0] == sas_sps_val[31:0])begin
                    $display("%0t:y_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[31:0]);

                end
                else begin
                    $display("%0t:y_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_y_reg = %x, sas_y_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[31:0], sas_sps_val[31:0]);
                    `MONITOR_PATH.fail("Y_reg-MISMATCH");
                end
            end
            `CCR            : begin
                if(sas_def == 0)begin
                    $display("%0t:ccr_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[7:0]);
                end
                else if(cond)begin
                    if(rtl_reg_val[7:0] == sas_sps_val[7:0])begin

                        $display("%0t:ccr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                 sas_time, spc, thread, window, rtl_reg_val[7:0]);


                    end
                    else begin
                        dummy =  $bw_sas_recv(ccr_req, thread, sas_win, sas_addr, 254, 35, sas_timer, sas_sps_val[7:0]);
                        //$display("MISMATC CCR", ccr_req);

                        if(rtl_reg_val[7:0] == ccr_req[7:0])begin
                            $display("%0t:ccr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                     sas_time, spc, thread, window, rtl_reg_val[7:0]);
                        end
                        else begin
                            $display("%0t:ccr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_ccr_reg = %x, sas_ccr_reg =%x",
                                     sas_time, spc, thread, window, rtl_reg_val[7:0], sas_sps_val[7:0]);
                            `MONITOR_PATH.fail("ccr_reg-MISMATCH");
                        end

                    end
                end
                else if(rtl_reg_val[7:0] == sas_sps_val[7:0])begin
                    $display("%0t:ccr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[7:0]);

                end
                else begin
                    dummy =  $bw_sas_recv(ccr_req, thread, sas_win, sas_addr, 254, 35, sas_timer, sas_sps_val[7:0]);
                    //$display("MISMATC CCR", ccr_req);
                    if(rtl_reg_val[7:0] == ccr_req[7:0])begin
                        $display("%0t:ccr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                 sas_time, spc, thread, window, rtl_reg_val[7:0]);
                    end
                    else begin
                        $display("%0t:ccr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_ccr_reg = %x, sas_ccr_reg =%x",
                                 sas_time, spc, thread, window, rtl_reg_val[7:0], sas_sps_val[7:0]);
                        `MONITOR_PATH.fail("ccr_reg-MISMATCH");
                    end
                end
            end
            `FPRS            : begin
                if(sas_def == 0)begin
                    $display("%0t:fprs_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, cond ? rtl_reg_val[2:0] : rtl_reg_val[1:0] );
                end
                else if(fprs_on)begin
                    if(cond)begin
                        if(rtl_reg_val[2:0] == sas_sps_val[2:0])begin
                            $display("%0t:fprs_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                     sas_time, spc, thread, window, rtl_reg_val[2:0]);
                        end
                        else begin
                            $display("%0t:fprs_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_fprs_reg = %x, sas_fprs_reg =%x",
                                     sas_time, spc, thread, window, rtl_reg_val[2:0], sas_sps_val[2:0]);
                            `MONITOR_PATH.fail("fprs_reg-MISMATCH");
                        end
                    end // if (cond)
                    else begin
                        if(rtl_reg_val[1:0] == sas_sps_val[1:0])begin
                            $display("%0t:fprs_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                     sas_time, spc, thread, window, rtl_reg_val[1:0]);
                        end
                        else begin
                            if((sas_sps_val[0] == 0) && rtl_reg_val[0] || (sas_sps_val[1] == 0) && rtl_reg_val[1])begin
                                $display("%0t:fprs_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                         sas_time, spc, thread, window, rtl_reg_val[1:0]);
                            end
                            else begin
                                $display("%0t:fprs_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_fprs_reg = %x, sas_fprs_reg =%x",
                                         sas_time, spc, thread, window, rtl_reg_val[1:0], sas_sps_val[1:0]);
                                `MONITOR_PATH.fail("fprs_reg-MISMATCH");
                            end
                        end
                    end // else: !if(cond)
                end // if (fprs_on)
            end // case: `FPRS
            `FSR            : begin
                rtl_reg_val[22] = 0;//mask ns
                sas_sps_val[22] = 0;
                rtl_reg_val[13] = 0;//mask gne
                sas_sps_val[13] = 0;
                if(sas_def == 0)begin
                    $display("%0t:fsr_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[37:0]);
                end
                else if(rtl_reg_val[37:0] == sas_sps_val[37:0])begin//temp.
                    $display("%0t:fsr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[37:0]);
                end
                /* else if(rtl_reg_val[0] == 0)begin
                $display("%0t:WARNING fsr_reg -> spc(%1d) thread(%d)  window(%d)  rtl_fsr_reg = %x, sas_fsr_reg =%x",
                $time, spc, thread, window, rtl_reg_val[37:0], sas_sps_val[37:0]);
                end*/
                else begin
                    $display("%0t:fsr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_fsr_reg = %x, sas_fsr_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[37:0], sas_sps_val[37:0]);
                    `MONITOR_PATH.fail("fsr_reg-MISMATCH");
                end
            end
            `ASI            : begin
                if(sas_def == 0)begin
                    $display("%0t:asi_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[7:0]);
                end
                else if(rtl_reg_val[7:0] == sas_sps_val[7:0])begin
                    $display("%0t:asi_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[7:0]);
                end
                else begin
                    $display("%0t:asi_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_asi_reg = %x, sas_asi_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[7:0], sas_sps_val[7:0]);
                    `MONITOR_PATH.fail("ccr_reg-MISMATCH");
                end
            end // case: `CCR
            `TICK_SAS           : begin
                sas_temp = sas_sps_val - 1;

                if(sas_def == 0)begin
                    $display("%0t:tick_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[63:0]);
                end
                else if(rtl_reg_val[63:4] == sas_temp[63:4])begin
                    $display("%0t:tick_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[63:0]);
                end
                else begin
                    $display("%0t:tick_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_tick_reg = %x, sas_tick_reg =%x",
                             $time, spc, thread, window, rtl_reg_val[63:0], sas_sps_val[63:0]);
                    // `MONITOR_PATH.fail("tick_reg-MISMATCH");
                end
            end
            `TICK_CMPR           : begin
                if(sas_def == 0)begin
                    $display("%0t:tick_cmpr_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[63:0]);
                end

                else if((cond == 7) && (rtl_reg_val[63] == sas_sps_val[63]))begin
                    $display("%0t:tick_cmpr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[63]);
                end
                else if((cond == 0) && (rtl_reg_val[63:0] == sas_sps_val[63:0]))begin
                    $display("%0t:tick_cmpr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[63:0]);
                end
                else begin
                    if(cond == 7)
                        $display("%0t:tick_cmpr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_tick_cmpr_reg[63] = %x, sas_tick_cmpr_reg[63] =%x",
                                 $time, spc, thread, window, rtl_reg_val[63], sas_sps_val[63]);
                    else $display("%0t:tick_cmpr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_tick_cmpr_reg = %x, sas_tick_cmpr_reg =%x",
                                      $time, spc, thread, window, rtl_reg_val[63:0], sas_sps_val[63:0]);
                    `MONITOR_PATH.fail("tick_cmpr_reg-MISMATCH");
                end
            end
            `STICK_CMPR           : begin
                if(sas_def == 0)begin
                    $display("%0t:stick_cmpr_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[63:0]);
                end
                else if((cond == 7) && (rtl_reg_val[63] == sas_sps_val[63]))begin
                    $display("%0t:stick_cmpr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[63]);
                end
                else if((cond == 0) && (rtl_reg_val[63:0] == sas_sps_val[63:0]))begin
                    $display("%0t:stick_cmpr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[63:0]);
                end
                else begin
                    if(cond == 7)
                        $display("%0t:stick_cmpr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_stick_cmpr_reg[63] = %x, sas_stick_cmpr_reg[63] =%x",
                                 $time, spc, thread, window, rtl_reg_val[63], sas_sps_val[63]);
                    else $display("%0t:stick_cmpr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_stick_cmpr_reg = %x, sas_stick_cmpr_reg =%x",
                                      $time, spc, thread, window, rtl_reg_val[63:0], sas_sps_val[63:0]);
                    `MONITOR_PATH.fail("stick_cmpr_reg-MISMATCH");
                end
            end
            `GSR            : begin
                if(sas_def == 0)begin
                    $display("%0t:gsr_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[63:0]);
                end

                else if(rtl_reg_val[63:0] == sas_sps_val[63:0])begin
                    $display("%0t:gsr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[63:0]);
                end
                else begin
                    $display("%0t:gsr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_gsr_reg = %x, sas_gsr_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[63:0], sas_sps_val[63:0]);
                    `MONITOR_PATH.fail("gsr_reg-MISMATCH");
                end
            end // case: `TICK_CMPR
            `PSTATE_SAS            : begin
                if(sas_def == 0)begin
                    $display("%0t:pstate_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[11:0]);
                end
                else if(rtl_reg_val[11:0] == sas_sps_val[11:0])begin
                    $display("%0t:pstate_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[11:0]);
                end
                else begin
                    $display("%0t:pstate_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_pstate_reg = %x, sas_pstate_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[11:0], sas_sps_val[11:0]);
                    `MONITOR_PATH.fail("pstate_reg MISMATCH");
                end
            end
            `TL_SAS            : begin
                if(sas_def == 0)begin
                    $display("%0t:tl_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else if(rtl_reg_val[2:0] == sas_sps_val[2:0])begin
                    $display("%0t:tl_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else begin
                    $display("%0t:tl_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_tl_reg = %x, sas_tl_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0], sas_sps_val[2:0]);
                    `MONITOR_PATH.fail("tl_reg-MISMATCH");
                end
            end
            `PIL_SAS            : begin
                if(sas_def == 0)begin
                    $display("%0t:pil_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[3:0]);
                end
                else if(rtl_reg_val[3:0] == sas_sps_val[3:0])begin
                    $display("%0t:pil_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[3:0]);
                end
                else begin
                    $display("%0t:pil_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_pil_reg = %x, sas_pil_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[3:0], sas_sps_val[3:0]);
                    `MONITOR_PATH.fail("pil_reg-MISMATCH");
                end
            end
            `TPC1, `TPC2, `TPC3, `TPC4, `TPC5, `TPC6 : begin
                if(sas_def == 0)begin
                    $display("%0t:tpc%0d_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, type - `PIL_SAS, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(!cond[2])begin
                    if(cond[3])//pstaet.am bit
                    begin
                        if(rtl_reg_val[31:0] == sas_sps_val[31:0])begin
                            $display("%0t:tpc%0d_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                     sas_time, type - `PIL_SAS, spc, thread, window, rtl_reg_val[31:0]);
                        end // if (rtl_reg_val[31:0] == sas_sps_val[31:0])
                        else begin
                            $display("%0t:tpc%0d_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_tpc_reg = %x, sas_tpc_reg =%x",
                                     sas_time, type - `PIL_SAS, spc, thread, window, rtl_reg_val[31:0], sas_sps_val[31:0]);
                            `MONITOR_PATH.fail("tpc_reg-MISMATCH");
                        end
                    end
                    else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                        $display("%0t:tpc%0d_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                 sas_time, type - `PIL_SAS, spc, thread, window, rtl_reg_val[47:0]);
                    end
                    else begin
                        $display("%0t:tpc%0d_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_tpc_reg = %x, sas_tpc_reg =%x",
                                 sas_time, type - `PIL_SAS, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                        `MONITOR_PATH.fail("tpc_reg-MISMATCH");
                    end
                end
            end
            `TNPC1, `TNPC2, `TNPC3, `TNPC4, `TNPC5, `TNPC6 : begin
                if(sas_def == 0)begin
                    $display("%0t:tnpc%0d_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, type - 56, spc, thread, window, rtl_reg_val[47:0]);
                end

                else if(!cond[2])begin
                    if(cond[3])begin
                        if(rtl_reg_val[31:0] == sas_sps_val[31:0])begin
                            $display("%0t:tnpc%0d_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                     sas_time, type - 56, spc, thread, window, rtl_reg_val[31:0]);
                        end
                        else begin
                            $display("%0t:tnpc%0d_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_tnpc_reg = %x, sas_tnpc_reg =%x",
                                     sas_time, type - 56, spc, thread, window, rtl_reg_val[31:0], sas_sps_val[31:0]);
                            `MONITOR_PATH.fail("tnpc_reg-MISMATCH");
                        end
                    end
                    else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                        $display("%0t:tnpc%0d_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                 sas_time, type - 56, spc, thread, window, rtl_reg_val[47:0]);
                    end
                    else begin
                        $display("%0t:tnpc%0d_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_tnpc_reg = %x, sas_tnpc_reg =%x",
                                 sas_time, type - 56, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                        `MONITOR_PATH.fail("tnpc_reg-MISMATCH");
                    end
                end
            end
            `TSTATE1, `TSTATE2, `TSTATE3, `TSTATE4, `TSTATE5, `TSTATE6 : begin
                if(sas_def == 0)begin
                    $display("%0t:tstate%0d_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, type - 66, spc, thread, window, rtl_reg_val[39:0]);
                end
                else if(!cond[2])begin
                    if(rtl_reg_val[39:0] == sas_sps_val[39:0])begin
                        $display("%0t:tstate%0d_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                 sas_time, type - 66, spc, thread, window, rtl_reg_val[39:0]);
                    end
                    else begin
                        $display("%0t:tstate%0d_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_tstate_reg = %x, sas_tstate_reg =%x",
                                 sas_time, type - 66, spc, thread, window, rtl_reg_val[39:0], sas_sps_val[39:0]);
                        `MONITOR_PATH.fail("tstate_reg-MISMATCH");
                    end
                end
            end
            `TT1, `TT2, `TT3, `TT4, `TT5, `TT6 : begin
                if(sas_def == 0)begin
                    $display("%0t:ttype%0d_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, type - 76, spc, thread, window, rtl_reg_val[8:0]);
                end
                else if(rtl_reg_val[8:0] == sas_sps_val[8:0])begin
                    $display("%0t:ttype%0d_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, type - 76, spc, thread, window, rtl_reg_val[8:0]);
                end
                else begin
                    $display("%0t:ttype%0d_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_ttype_reg = %x, sas_ttype_reg =%x",
                             sas_time, type - 76, spc, thread, window, rtl_reg_val[8:0], sas_sps_val[8:0]);
                    `MONITOR_PATH.fail("ttype_reg-MISMATCH");
                end
            end // case: `TT1, `TT2, `TT3, `TT4, `TT5, `TT6

            `TBA_SAS            : begin
                if(sas_def == 0)begin
                    $display("%0t:tba_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(rtl_reg_val[47:15] == sas_sps_val[47:15])begin
                    $display("%0t:tba_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:15]);
                end
                else begin
                    $display("%0t:tba_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_tba_reg = %x, sas_tba_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:15], sas_sps_val[47:15]);
                    `MONITOR_PATH.fail("tba_reg-MISMATCH");
                end
            end // case: `TBA
            `VER            : begin
                if(sas_def == 0)begin
                    $display("%0t:ver_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[32:0]);
                end
                else if(rtl_reg_val[32:0] == sas_sps_val[32:0])begin
                    $display("%0t:ver_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[32:0]);
                end
                else begin
                    $display("%0t:ver_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_tba_reg = %x, sas_tba_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[32:0], sas_sps_val[47:15]);
                    `MONITOR_PATH.fail("ver_reg-MISMATCH");
                end
            end // case: `TBA
            `CWP            : begin
                if(sas_def == 0)begin
                    $display("%0t:cwp_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else if(rtl_reg_val[2:0] == sas_sps_val[2:0])begin
                    $display("%0t:cwp_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else begin
                    $display("%0t:cwp_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_cwp_reg = %x, sas_cwp_reg =%x",
                             $time, spc, thread, window, rtl_reg_val[2:0], sas_sps_val[2:0]);
                    `MONITOR_PATH.fail("cwp_reg-MISMATCH");
                end
            end
            `CANSAVE            : begin
                if(sas_def == 0)begin
                    $display("%0t:cansave_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else if(rtl_reg_val[2:0] == sas_sps_val[2:0])begin
                    $display("%0t:cansave_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else begin
                    $display("%0t:cansave_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_cansave_reg = %x, sas_cansave_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0], sas_sps_val[2:0]);
                    `MONITOR_PATH.fail("cansave_reg-MISMATCH");
                end
            end
            `CANRESTORE           : begin
                if(sas_def == 0)begin
                    $display("%0t:canrestore_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else if(rtl_reg_val[2:0] == sas_sps_val[2:0])begin
                    $display("%0t:canrestore_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else begin
                    $display("%0t:canrestore_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_restore_reg = %x, sas_restore_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0], sas_sps_val[2:0]);
                    `MONITOR_PATH.fail("canrestore_reg-MISMATCH");
                end
            end
            `OTHERWIN           : begin
                if(sas_def == 0)begin
                    $display("%0t:otherwin_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else if(rtl_reg_val[2:0] == sas_sps_val[2:0])begin
                    $display("%0t:otherwin_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else begin
                    $display("%0t:otherwin_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_otherwin_reg = %x, sas_otherwin_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0], sas_sps_val[2:0]);
                    `MONITOR_PATH.fail("otherwin_reg-MISMATCH");
                end
            end
            `WSTATE           : begin
                if(sas_def == 0)begin
                    $display("%0t:wstate_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[5:0]);

                end
                else if(rtl_reg_val[5:0] == sas_sps_val[5:0])begin
                    $display("%0t:wstate_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[5:0]);
                end
                else begin
                    $display("%0t:wstate_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_wstate_reg = %x, sas_wstate_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[5:0], sas_sps_val[5:0]);
                    `MONITOR_PATH.fail("wstate_reg-MISMATCH");
                end
            end
            `CLEANWIN           : begin
                if(sas_def == 0)begin
                    $display("%0t:cleanwin_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[2:0]);
                end

                else if(rtl_reg_val[2:0] == sas_sps_val[2:0])begin
                    $display("%0t:cleanwin_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else begin
                    $display("%0t:cleanwin_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_cleanwin_reg = %x, sas_cleanwin_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0], sas_sps_val[2:0]);
                    `MONITOR_PATH.fail("cleanwin_reg-MISMATCH");
                end
            end // case: `CLEANWIN
            `SOFTINT           : begin
                if(sas_def == 0)begin
                    $display("%0t:softint_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, 1'b1);
                end

                else if(rtl_reg_val[16:0] == sas_sps_val[16:0])begin
                    $display("%0t:softint_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[16:0]);
                end
                else begin
                    $display("%0t:softint_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_soft_reg = %x, sas_soft_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[16:0], sas_sps_val[16:0]);
                    `MONITOR_PATH.fail("softint_reg-MISMATCH");
                end
            end
            `ECACHE_ERROR_ENABLE           : begin
                if(sas_def == 0)begin
                    $display("%0t:ecache_error_enable_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else if(rtl_reg_val[2:0] == sas_sps_val[2:0])begin
                    $display("%0t:ecache_error_enable_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else begin
                    $display("%0t:ecache_error_enable_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_cleanwin_reg = %x, sas_cleanwin_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0], sas_sps_val[2:0]);
                    `MONITOR_PATH.fail("ecache_error_enable_reg-MISMATCH");
                end
            end // case: `UPAD_CONFIG
            `ASYNCHRONOUS_FAULT_STATUS           : begin
                if(sas_def == 0)begin
                    $display("%0t:asynchronous_fault_status_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else if(rtl_reg_val[2:0] == sas_sps_val[2:0])begin
                    $display("%0t:asynchronous_fault_status_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else begin
                    $display("%0t:asynchronous_fault_status_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_cleanwin_reg = %x, sas_cleanwin_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0], sas_sps_val[2:0]);
                    `MONITOR_PATH.fail("asynchronous_fault_status_reg-MISMATCH");
                end
            end // case: `UPAD_CONFIG
            `ASYNCHRONOUS_FAULT_ADDRESS           : begin
                if(sas_def == 0)begin
                    $display("%0t:asynchronous_fault_address_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else if(rtl_reg_val[2:0] == sas_sps_val[2:0])begin
                    $display("%0t:asynchronous_fault_address_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else begin
                    $display("%0t:asynchronous_fault_address_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_cleanwin_reg = %x, sas_cleanwin_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0], sas_sps_val[2:0]);
                    `MONITOR_PATH.fail("asynchronous_fault_status_reg-MISMATCH");
                end
            end
            `INTR_DISPATCH_STATUS           : begin
                if(sas_def == 0)begin
                    $display("%0t:intr_dispatch_status_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[10:0]);
                end
                else if(rtl_reg_val[10:0] == sas_sps_val[10:0])begin
                    $display("%0t:intr_dispatch_status_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[10:0]);
                end
                else begin
                    $display("%0t:intr_dispatch_status_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_intr_dispatch_status_reg = %x, sas_intr_dispatch_status_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[10:0], sas_sps_val[10:0]);
                    `MONITOR_PATH.fail("intr_dispatch_status_reg-MISMATCH");
                end
            end
            `INTR_RECEIVE          : begin
                if(sas_def == 0)begin
                    $display("%0t:intr_receive_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else if(rtl_reg_val[63:0] == sas_sps_val[63:0])begin
                    $display("%0t:intr_receive_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[63:0]);
                end
                else begin
                    $display("%0t:intr_receive_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_intr_receive_reg = %x, sas_intr_receive_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[63:0], sas_sps_val[63:0]);
                    `MONITOR_PATH.fail("intr_receive_reg-MISMATCH");
                end
            end // case: `IN_INTR_DATA2
            `FLOAT_I           : begin
                if((rtl_reg_addr > 31) && rtl_reg_addr[1])sas_reg_val[31:0] = sas_reg_val[63:32];
                if(sas_def == 0)begin
                    $display("%0t:float_reg-updated -> spc(%1d) thread(%d) reg#(%0d) val = %x",
                             $time, spc, thread, rtl_reg_addr, rtl_reg_val[31:0]);
                end
                else if(rtl_reg_val[31:0] == sas_reg_val[31:0])begin
                    $display("%0t:float_reg-MATCH -> spc(%1d) thread(%d) reg#(f%0d) val = %x",
                             sas_time, spc, thread, rtl_reg_addr, rtl_reg_val[31:0]);
                end
                else begin
                    $display("%0t:float_reg-MISMATCH -> spc(%1d) thread(%d)  reg#(f%0d) rtl_float_reg = %x, sas_float_reg =%x",
                             sas_time, spc, thread, rtl_reg_addr, rtl_reg_val[31:0], sas_reg_val[31:0]);
                    `MONITOR_PATH.fail("float_reg-MISMATCH");
                end
            end // case: `FLOAT_I
            `FLOAT_X           : begin
                if(sas_def == 0)begin
                    $display("%0t:float_reg-updated -> spc(%1d) thread(%d) reg#(f%0d) val = %x",
                             $time, spc, thread, rtl_reg_addr, rtl_reg_val[63:0]);
                end
                else if(rtl_reg_val[63:0] == sas_reg_val[63:0])begin
                    $display("%0t:float_reg-MATCH -> spc(%1d) thread(%d) reg#(f%0d) val = %x",
                             sas_time, spc, thread, rtl_reg_addr, rtl_reg_val[63:0]);
                end
                else begin
                    $display("%0t:float_reg-MISMATCH -> spc(%1d) thread(%d)  reg#(f%0d) rtl_float_reg = %x, sas_float_reg =%x",
                             sas_time, spc, thread, rtl_reg_addr, rtl_reg_val[63:0], sas_reg_val[63:0]);
                    `MONITOR_PATH.fail("float_reg-MISMATCH");
                end
            end // case: `FLOAT_I
            `HTBA_SAS            : begin
                if(sas_def == 0)begin
                    $display("%0t:htba_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[33:0]);
                end
                else if(rtl_reg_val[33:0] == sas_sps_val[33:0])begin
                    $display("%0t:htba_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[33:0]);
                end
                else begin
                    $display("%0t:htba_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_htba_reg = %x, sas_htba_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[33:0], sas_sps_val[33:0]);
                    `MONITOR_PATH.fail("htba_reg-MISMATCH");
                end
            end // case: `TBA
            `HINTP_SAS            : begin
                if(sas_def == 0)begin
                    $display("%0t:hintp_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[3:0]);
                end
                else if(rtl_reg_val[3:0] == sas_sps_val[3:0])begin
                    $display("%0t:hintp_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[3:0]);
                end
                else begin
                    $display("%0t:hintp_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_hintp_reg = %x, sas_hintp_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[3:0], sas_sps_val[3:0]);
                    `MONITOR_PATH.fail("hintp_reg-MISMATCH");
                end
            end // case: `HINTP
            `HSTICK_CMPR            : begin
                if(sas_def == 0)begin
                    $display("%0t:hstick_cmpr_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[63:0]);
                end
                else if((cond == 7) && (rtl_reg_val[63] == sas_sps_val[63]))begin
                    $display("%0t:hstick_cmpr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[63]);
                end
                else if((cond == 0) && (rtl_reg_val[63:0] == sas_sps_val[63:0]))begin
                    $display("%0t:hstick_cmpr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[63:0]);
                end
                else begin
                    if(cond == 7)
                        $display("%0t:hstick_cmpr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_stick_cmpr_reg[63] = %x, sas_hstick_cmpr_reg[63] =%x",
                                 sas_time, spc, thread, window, rtl_reg_val[63], sas_sps_val[63]);
                    else  $display("%0t:hstick_cmpr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_stick_cmpr_reg = %x, sas_hstick_cmpr_reg =%x",
                                       sas_time, spc, thread, window, rtl_reg_val[63:0], sas_sps_val[63:0]);
                    `MONITOR_PATH.fail("hstick_cmpr_reg-MISMATCH");
                end
            end // case: `HINTP
            `HPSTATE_SAS            : begin
                sas_sps_val[4:0] = {sas_sps_val[10], sas_sps_val[11], sas_sps_val[5], sas_sps_val[2], sas_sps_val[0]};

                if(sas_def == 0)begin
                    $display("%0t:hpstate_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[3:0]);
                end
                else if(rtl_reg_val[4:0] == sas_sps_val[4:0])begin
                    $display("%0t:hpstate_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[4:0]);
                end
                else begin
                    $display("%0t:hpstate_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_hpstate_reg = %x, sas_hpstate_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[4:0], sas_sps_val[4:0]);
                    `MONITOR_PATH.fail("hpstate_reg MISMATCH");
                end
            end // case: `HPSTATE
            `GL            : begin
                if(sas_def == 0)begin
                    $display("%0t:gl_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[1:0]);
                end
                else if(rtl_reg_val[1:0] == sas_sps_val[1:0])begin
                    $display("%0t:gl_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[1:0]);
                end
                else begin
                    $display("%0t:gl_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_gl_reg = %x, sas_gl_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[1:0], sas_sps_val[1:0]);
                    `MONITOR_PATH.fail("gl_reg MISMATCH");
                end
            end // case: `HPSTATE
            `HTSTATE1, `HTSTATE2, `HTSTATE3, `HTSTATE4, `HTSTATE5, `HTSTATE6 : begin
                if(sas_def == 0)begin
                    $display("%0t:htstate%0d_reg-updated -> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, type - 108, spc, thread, window, rtl_reg_val[2:0]);
                end
                else if(!cond[2])begin
                    if(rtl_reg_val[2:0] == sas_sps_val[2:0])begin
                        $display("%0t:htstate%0d_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                 sas_time, type - 108, spc, thread, window, rtl_reg_val[2:0]);
                    end
                    else begin
                        $display("%0t:htstate%0d_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_htstate_reg = %x, sas_htstate_reg =%x",
                                 sas_time, type - 108, spc, thread, window, rtl_reg_val[2:0], sas_sps_val[2:0]);
                        `MONITOR_PATH.fail("htstate_reg-MISMATCH");
                    end
                end // if (!cond[2])

            end // case: `HTSTATE1, `HTSTATE2, `HTSTATE3, `HTSTATE4, `HTSTATE5, `HTSTATE6
            `ISFSR            : begin
                if(sas_def == 0)begin
                    $display("%0t:isfsr_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[23:0]);
                end
                else if(rtl_reg_val[23:0] == sas_sps_val[23:0])begin
                    $display("%0t:isfsr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[23:0]);
                end
                else begin
                    rtl_reg_val[4:3] = 2'b00;
                    sas_sps_val[4:3] = 2'b00;
                    if(rtl_reg_val[23:0] == sas_sps_val[23:0])begin
                        $display("%0t:isfsr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                 sas_time, spc, thread, window, rtl_reg_val[23:0]);
                    end
                    else begin
                        $display("%0t:isfsr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_isfsr_reg = %x, sas_isfsr_reg =%x",
                                 sas_time, spc, thread, window, rtl_reg_val[23:0], sas_sps_val[23:0]);
                        `MONITOR_PATH.fail("isfsr_reg MISMATCH");
                    end
                end
            end // case: `HPSTATE
            `DSFSR            : begin
                if(sas_def == 0)begin
                    $display("%0t:dsfsr_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[23:0]);
                end
                else if(rtl_reg_val[23:0] == sas_sps_val[23:0])begin
                    $display("%0t:dsfsr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[23:0]);
                end
                else begin
                    // modified for bug 3323
                    //assign  tlu_isfsr_din_g[23:0] =
                    //{isfsr_asi_g[7:0],2'b0,isfsr_ftype_g[6:0],1'b0, isfsr_ctxt_g[1:0], 2'b0,isfsr_flt_vld_g, 1'b1};
                    rtl_reg_val[4:3] = 2'b00;
                    sas_sps_val[4:3] = 2'b00;
                    rtl_reg_val[7]   = 0;
                    rtl_reg_val[11:10] = 2'b00;
                    rtl_reg_val[5:4]   = 2'b00;
                    sas_sps_val[7]     = 0;
                    sas_sps_val[11:10] = 2'b00;
                    sas_sps_val[5:4]   = 2'b00;
                    if(rtl_reg_val[23:0] == sas_sps_val[23:0])
                        $display("%0t:dsfsr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                                 sas_time, spc, thread, window, rtl_reg_val[23:0]);
                    else begin
                        $display("%0t:dsfsr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_dsfsr_reg = %x, sas_dsfsr_reg =%x",
                                 sas_time, spc, thread, window, rtl_reg_val[23:0], sas_sps_val[23:0]);
                        `MONITOR_PATH.fail("dsfsr_reg MISMATCH");
                    end
                end
            end // case: `HPSTATE
            `SFAR           : begin
                if(sas_def == 0)begin
                    $display("%0t:sfar_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:sfar_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else begin
                    $display("%0t:sfar_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_sfar_reg = %x, sas_sfar_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("sfar_reg MISMATCH");
                end
            end // case: `HPSTATE
            `I_TAG_ACCESS          : begin
                if(sas_def == 0)begin
                    $display("%0t:itag_access_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:itag_access_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else begin
                    $display("%0t:itag_access_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_itag_access_reg = %x, sas_itag_access_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("itag_access_reg MISMATCH");
                end
            end // case: `I_TAG_ACCESS
            `D_TAG_ACCESS          : begin
                if(sas_def == 0)begin
                    $display("%0t:dtag_access_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:dtag_access_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else begin
                    $display("%0t:dtag_access_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_dtag_access_reg = %x, sas_dtag_access_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("dtag_access_reg MISMATCH");
                end
            end // case: `D_TAG_ACCESS
            `CTXT_PRIM   : begin
                if(sas_def == 0)begin
                    $display("%0t:ctxt_prim_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[12:0]);
                end
                else if(rtl_reg_val[12:0] == sas_sps_val[12:0])begin
                    $display("%0t:ctxt_prim_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[12:0]);
                end
                else begin
                    $display("%0t:ctxt_prim_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_ctxt_prim_reg = %x, sas_ctxt_prim_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[12:0], sas_sps_val[12:0]);
                    `MONITOR_PATH.fail("ctxt_prim_reg MISMATCH");
                end
            end // case: `CTXT_PRIM
            `CTXT_SEC   : begin
                if(sas_def == 0)begin
                    $display("%0t:ctxt_sec_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[12:0]);
                end
                else if(rtl_reg_val[12:0] == sas_sps_val[12:0])begin
                    $display("%0t:ctxt_sec_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[12:0]);
                end
                else begin
                    $display("%0t:ctxt_sec_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_ctxt_sec_reg = %x, sas_ctxt_sec_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[12:0], sas_sps_val[12:0]);
                    `MONITOR_PATH.fail("ctxt_sec_reg MISMATCH");
                end
            end // case: `CTXT_SEC
            `I_CTXT_ZERO_PS0   : begin
                if(sas_def == 0)begin
                    $display("%0t:i_ctxt_zero_ps0_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:i_ctxt_zero_ps0_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else begin
                    $display("%0t:i_ctxt_zero_ps0_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_i_ctxt_zero_ps0_reg = %x, sas_i_ctxt_zero_ps0_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("i_ctxt_zero_ps0_reg MISMATCH");
                end
            end // case: `I_CTXT_ZERO_PS0
            `D_CTXT_ZERO_PS0   : begin
                if(sas_def == 0)begin
                    $display("%0t:d_ctxt_zero_ps0_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:d_ctxt_zero_ps0_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else begin
                    $display("%0t:d_ctxt_zero_ps0_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_d_ctxt_zero_ps0_reg = %x, sas_d_ctxt_zero_ps0_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("d_ctxt_zero_ps0_reg MISMATCH");
                end
            end // case: `D_CTXT_ZERO_PS0
            `I_CTXT_ZERO_PS1   : begin
                if(sas_def == 0)begin
                    $display("%0t:i_ctxt_zero_ps1_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:i_ctxt_zero_ps1_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else begin
                    $display("%0t:i_ctxt_zero_ps1_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_i_ctxt_zero_ps1_reg = %x, sas_i_ctxt_zero_ps1_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("i_ctxt_zero_ps1_reg MISMATCH");
                end
            end // case: `I_CTXT_ZERO_PS1
            `D_CTXT_ZERO_PS1   : begin
                if(sas_def == 0)begin
                    $display("%0t:d_ctxt_zero_ps1_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:d_ctxt_zero_ps1_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else begin
                    $display("%0t:d_ctxt_zero_ps1_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_d_ctxt_zero_ps1_reg = %x, sas_d_ctxt_zero_ps1_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("d_ctxt_zero_ps1_reg MISMATCH");
                end
            end // case: `D_CTXT_ZERO_PS0
            `I_CTXT_ZERO_CONFIG   : begin
                if(sas_def == 0)begin
                    $display("%0t:i_ctxt_zero_config_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[5:0]);
                end
                else if(rtl_reg_val[5:0] == sas_sps_val[5:0])begin
                    $display("%0t:i_ctxt_zero_config_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[5:0]);
                end
                else begin
                    $display("%0t:i_ctxt_zero_config_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_i_ctxt_zero_config_reg = %x, sas_i_ctxt_zero_config_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[5:0], sas_sps_val[5:0]);
                    `MONITOR_PATH.fail("i_ctxt_zero_config_reg MISMATCH");
                end
            end // case: `I_CTXT_ZERO_CONFIG
            `D_CTXT_ZERO_CONFIG   : begin
                if(sas_def == 0)begin
                    $display("%0t:d_ctxt_zero_config_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[5:0]);
                end
                else if(rtl_reg_val[5:0] == sas_sps_val[5:0])begin
                    $display("%0t:d_ctxt_zero_config_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[5:0]);
                end
                else begin
                    $display("%0t:d_ctxt_zero_config_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_d_ctxt_zero_config_reg = %x, sas_d_ctxt_zero_config_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[5:0], sas_sps_val[5:0]);
                    `MONITOR_PATH.fail("d_ctxt_zero_config_reg MISMATCH");
                end
            end // case: `D_CTXT_ZERO_CONFIG
            `I_CTXT_NONZERO_PS0   : begin
                if(sas_def == 0)begin
                    $display("%0t:i_ctxt_nonzero_ps0_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:i_ctxt_nonzero_ps0_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else begin
                    $display("%0t:i_ctxt_nonzero_ps0_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_i_ctxt_nonzero_ps0_reg = %x, sas_i_ctxt_nonzero_ps0__reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("i_ctxt_nonzero_ps0__reg MISMATCH");
                end
            end // case: `I_CTXT_ZERO_PS0
            `D_CTXT_NONZERO_PS0   : begin
                if(sas_def == 0)begin
                    $display("%0t:d_ctxt_nonzero_ps0_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:d_ctxt_nonzero_ps0_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else begin
                    $display("%0t:d_ctxt_nonzero_ps0_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_d_ctxt_nonzero_ps0_reg = %x, sasd_ctxt_nonzero_ps0_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("d_ctxt_nonzero_ps0_reg MISMATCH");
                end
            end // case: `D_CTXT_ZERO_PS0
            `I_CTXT_NONZERO_PS1   : begin
                if(sas_def == 0)begin
                    $display("%0t:i_ctxt_nonzero_ps1_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:i_ctxt_nonzero_ps1_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else begin
                    $display("%0t:i_ctxt_nonzero_ps1_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_i_ctxt_nonzero_ps1_reg = %x, sasi_ctxt_nonzero_ps1_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("i_ctxt_nonzero_ps1_reg MISMATCH");
                end
            end // case: `I_CTXT_ZERO_PS1
            `D_CTXT_NONZERO_PS1   : begin
                if(sas_def == 0)begin
                    $display("%0t:d_ctxt_nonzero_ps1_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else if(rtl_reg_val[47:0] == sas_sps_val[47:0])begin
                    $display("%0t:d_ctxt_nonzero_ps1_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0]);
                end
                else begin
                    $display("%0t:d_ctxt_nonzero_ps1_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_d_ctxt_nonzero_ps1_reg = %x, sasd_ctxt_nonzero_ps1_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[47:0], sas_sps_val[47:0]);
                    `MONITOR_PATH.fail("d_ctxt_nonzero_ps1__reg MISMATCH");
                end
            end // case: `D_CTXT_ZERO_PS0
            `I_CTXT_NONZERO_CONFIG   : begin
                if(sas_def == 0)begin
                    $display("%0t:i_ctxt_nonzero_config_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[5:0]);
                end
                else if(rtl_reg_val[5:0] == sas_sps_val[5:0])begin
                    $display("%0t:i_ctxt_nonzero_config_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[5:0]);
                end
                else begin
                    $display("%0t:i_ctxt_nonzero_config_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_i_ctxt_nonzero_config_reg = %x, sas_i_ctxt_nonzero_config_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[5:0], sas_sps_val[5:0]);
                    `MONITOR_PATH.fail("i_ctxt_nonzero_config_reg MISMATCH");
                end
            end // case: `I_CTXT_ZERO_CONFIG
            `D_CTXT_NONZERO_CONFIG   : begin
                if(sas_def == 0)begin
                    $display("%0t:d_ctxt_nonzero_config_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[5:0]);
                end
                else if(rtl_reg_val[5:0] == sas_sps_val[5:0])begin
                    $display("%0t:d_ctxt_nonzero_config_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[5:0]);
                end
                else begin
                    $display("%0t:d_ctxt_nonzero_config_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_d_ctxt_nonzero_configreg = %x, sas_d_ctxt_nonzero_config_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[5:0], sas_sps_val[5:0]);
                    `MONITOR_PATH.fail("d_ctxt_nonzero_config_reg MISMATCH");
                end
            end // case: `D_CTXT_NONZERO_CONFIG
            `VA_WP_ADDR  : begin
                if(sas_def == 0)begin
                    $display("%0t:va_wp_addr_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[44:0]);
                end
                else if(rtl_reg_val[44:0] == sas_sps_val[44:0])begin
                    $display("%0t:va_wp_addr_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[44:0]);
                end
                else begin
                    $display("%0t:va_wp_addr_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_va_wp_addr_reg = %x, sas_va_wp_addr_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[44:0], sas_sps_val[44:0]);
                    `MONITOR_PATH.fail("va_wp_addr_reg MISMATCH");
                end
            end // case: `VA_WP_ADDR
            `PID  : begin
                if(sas_def == 0)begin
                    $display("%0t:pid_reg-updated-> spc(%1d) thread(%d) window(%d) val = %x",
                             $time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else if(rtl_reg_val[2:0] == sas_sps_val[2:0])begin
                    $display("%0t:pid_reg-MATCH -> spc(%1d) thread(%d) window(%d) val = %x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0]);
                end
                else begin
                    $display("%0t:pid_reg-MISMATCH -> spc(%1d) thread(%d)  window(%d)  rtl_pid_reg = %x, sas_pid_reg =%x",
                             sas_time, spc, thread, window, rtl_reg_val[2:0], sas_sps_val[2:0]);
                    `MONITOR_PATH.fail("pid_reg MISMATCH");
                end
            end // case: `VA_WP_ADDR
        endcase
    end
endtask
`endif // SAS_DISABLE

endmodule // sas_tasks
          // Local Variables:
          // verilog-library-directories:("." "../../../design/rtl")
          // verilog-library-extensions:(".v" ".h")
          // End:


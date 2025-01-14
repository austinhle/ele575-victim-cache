// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: slam_init.v
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
`include "sys.h"
`include "iop.h"
`include "cross_module.tmp.h"


`define MAX_TILE 64



`ifdef PITON_PROTO
`define FPGA_SYN_FRF
`define FPGA_SYN_IDCT
`define FPGA_SYN_IRF
`define FPGA_SYN_TLB
`endif

`ifdef USE_IBM_SRAMS
//`define FPGA_SYN_FRF
//`define FPGA_SYN_IDCT
//`define FPGA_SYN_IRF
//`define FPGA_SYN_TLB
`endif

module slam_init () ;

integer j;
wire dram_queue_empty ;


// skip fetching from boot rom after reset

`ifdef GATE_SIM_TLU
initial begin
    if ($test$plusargs("fast_boot")) begin

    `ifdef RTL_SPARC0
            force {   `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_33.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_32.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_31.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_30.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_29.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_28.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_27.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_26.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_25.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_24.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_23.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_22.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_21.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_20.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_19.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_18.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_17.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_16.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_15.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_14.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_13.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_12.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_11.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_10.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_9.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_8.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_7.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_6.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_5.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_4.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_3.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_2.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_1.d0,
                      `SPARC_CORE0.sparc0.tlu_tdp.nrmlpc_sel_w2_0.d0} = 34'h0_0000_0010 ;
    `endif // RTL_SPARC0




    end // if fast_boot begin
end //initial begin
`else
initial begin
    if ($test$plusargs("fast_boot")) begin

    `ifdef RTL_SPARC0
        `ifndef RTL_SPU
            force `SPARC_CORE0.sparc0.tlu.tlu.tdp.tlu_rstvaddr_base[33:0] = 34'h0_0000_0010 ;
        `else
            force `SPARC_CORE0.sparc0.tlu.tdp.tlu_rstvaddr_base[33:0] = 34'h0_0000_0010 ;
        `endif
    `endif



    end
end
`endif // ifdef GATE_SIM_TLU
// force the reset stat register to have defined values ...

`ifdef RTL_IOBDG
initial begin
    if (!$test$plusargs("no_reset_stat_slam")) begin
`ifdef GATE_SIM_IOBDG
        force cmp_top.iop.iobdg.iobdg_ctrl_creg_resetstat_lo_ff_u_dffe_0_.q = 1'b0 ;
        force cmp_top.iop.iobdg.iobdg_ctrl_creg_resetstat_lo_ff_u_dffe_1_.q = 1'b0 ;
        force cmp_top.iop.iobdg.iobdg_ctrl_creg_resetstat_lo_ff_u_dffe_2_.q = 1'b0 ;
        repeat (4) @(posedge cmp_top.iop.iobdg.jbus_rclk) ;
        release cmp_top.iop.iobdg.iobdg_ctrl_creg_resetstat_lo_ff_u_dffe_0_.q ;
        release cmp_top.iop.iobdg.iobdg_ctrl_creg_resetstat_lo_ff_u_dffe_1_.q ;
        release cmp_top.iop.iobdg.iobdg_ctrl_creg_resetstat_lo_ff_u_dffe_2_.q ;
`else
        force cmp_top.iop.iobdg.iobdg_ctrl.creg_resetstat_lo_ff.q = 3'b000 ;
        repeat (4) @(posedge cmp_top.iop.iobdg.iobdg_ctrl.clk) ;
        release cmp_top.iop.iobdg.iobdg_ctrl.creg_resetstat_lo_ff.q ;
`endif
    end
end
`endif

// force the ctu row addr to have defined values

`ifdef RTL_CTU

`ifdef GATE_SIM_CTU
initial begin
    if (!$test$plusargs("no_ctu_efc_row_addr_slam")) begin
        force cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_6_.q = 1'b1 ;
        force cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_5_.q = 1'b0 ;
        force cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_4_.q = 1'b1 ;
        force cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_3_.q = 1'b1 ;
        force cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_2_.q = 1'b0 ;
        force cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_1_.q = 1'b1 ;
        force cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_0_.q = 1'b0 ;

        @(posedge cmp_top.iop.ctu.tck_l_cts) ;

        release cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_6_.q ;
        release cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_5_.q ;
        release cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_4_.q ;
        release cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_3_.q ;
        release cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_2_.q ;
        release cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_1_.q ;
        release cmp_top.iop.ctu.ctu_dft_u_jtag_u_dffrl_async_ctu_efc_rowaddr_u_dffrl_async_ns_0_.q ;
    end
end
`else
initial begin
    if (!$test$plusargs("no_ctu_efc_row_addr_slam")) begin
        $slam_random (cmp_top.iop.ctu.ctu_dft.u_jtag.u_dff_efc_rowaddr.q, 7, 2) ;
    end
end
`endif

`endif

// force the pll to lock quickly

`ifdef RTL_CTU

`ifdef GATE_SIM_CTU
always @(posedge cmp_top.iop.ctu.pll_raw_clk_out) begin
    if (!$test$plusargs("no_fast_pll_lock")) begin
        // speed up the pll reset counter
        if ({cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_6_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_5_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_4_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_3_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_2_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_1_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_0_.q} == 7'h02) begin

            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_6_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_5_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_4_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_3_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_2_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_1_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_0_.q = 1'b0 ;

            @(posedge cmp_top.iop.ctu.pll_raw_clk_out) ;

            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_6_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_5_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_4_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_3_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_2_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_1_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_rst_cnt_u_dffrl_async_ns_0_.q ;
        end
    end
end
`else
always @(posedge cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_pllcnt.pll_raw_clk_out) begin
    if (!$test$plusargs("no_fast_pll_lock")) begin
        // speed up the pll reset counter
        if (cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_pllcnt.pll_rst_cnt == 7'h02) begin
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_pllcnt.pll_rst_cnt = 7'h60 ;
            @(posedge cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_pllcnt.pll_raw_clk_out) ;
            release  cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_pllcnt.pll_rst_cnt ;
        end
    end
end
`endif // ifdef GATE_SIM_CTU

`ifdef GATE_SIM_CTU
wire [14:0] pll_lck_cnt ;
assign pll_lck_cnt = {cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_14_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_13_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_12_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_11_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_10_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_9_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_8_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_7_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_6_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_5_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_4_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_3_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_2_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_1_.q,
                      cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_0_.q} ;

always @(posedge cmp_top.iop.ctu.pll_raw_clk_out) begin
    if (!$test$plusargs("no_fast_pll_lock")) begin
        // speed up the pll lock counter
        if ((pll_lck_cnt == 15'h7b00) ||
                (pll_lck_cnt == 15'h7d0) ||
                (pll_lck_cnt == 15'h100)) begin

            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_14_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_13_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_12_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_11_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_10_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_9_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_8_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_7_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_6_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_5_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_4_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_3_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_2_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_1_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_0_.q = 1'b1 ;

            @(posedge cmp_top.iop.ctu.pll_raw_clk_out) ;

            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_14_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_13_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_12_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_11_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_10_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_9_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_8_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_7_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_6_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_5_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_4_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_3_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_2_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_1_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_pllcnt_u_pll_lck_cnt_init_u_dffrl_async_ns_0_.q ;

        end
    end
end
`else
always @(posedge cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_pllcnt.pll_raw_clk_out) begin
    if (!$test$plusargs("no_fast_pll_lock")) begin
        // speed up the pll lock counter
        if ((cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_pllcnt.pll_lck_cnt == 15'h7b00) ||
                (cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_pllcnt.pll_lck_cnt == 15'h7d0) ||
                (cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_pllcnt.pll_lck_cnt == 15'h100)) begin
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_pllcnt.pll_lck_cnt = 15'h0059 ;
            @(posedge cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_pllcnt.pll_raw_clk_out) ;
            release cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_pllcnt.pll_lck_cnt ;
        end
    end
end
`endif // ifdef GATE_SIM_CTU

`ifdef GATE_SIM_CTU
always @(posedge cmp_top.iop.ctu.cmp_clk) begin
    if (!$test$plusargs("no_slam_clken")) begin
        // speed up the cken counter
        if ({cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_6_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_5_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_4_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_3_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_2_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_1_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_0_.q} == 7'h01) begin
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_6_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_5_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_4_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_3_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_2_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_1_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_0_.q = 1'b0 ;

            @(posedge cmp_top.iop.ctu.cmp_clk) ;

            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_6_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_5_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_4_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_3_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_2_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_1_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_clkctrl_u_clk_dcnt_u_dffrl_ns_0_.q ;
        end
    end
end
`else
always @(posedge cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkctrl.cmp_clk) begin
    if (!$test$plusargs("no_slam_clken")) begin
        // speed up the cken counter
        if (cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkctrl.clk_dcnt == 7'h01) begin
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkctrl.clk_dcnt = 7'h7e ;
            @(posedge cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkctrl.cmp_clk) ;
            release cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkctrl.clk_dcnt ;
        end
    end
end
`endif // GATE_SIM_CTU

`ifdef GATE_SIM_CTU
always @(posedge cmp_top.iop.ctu.jbus_clk) begin
    if (!$test$plusargs("no_slam_efc_rd")) begin
        // speed up the efc read counter
        if ({cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_12_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_11_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_10_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_9_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_8_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_7_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_6_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_5_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_4_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_3_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_2_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_1_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_0_.q} == 13'h1d) begin
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_12_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_11_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_10_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_9_.q  = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_8_.q  = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_7_.q  = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_6_.q  = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_5_.q  = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_4_.q  = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_3_.q  = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_2_.q  = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_1_.q  = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_0_.q  = 1'b1 ;

            @(posedge cmp_top.iop.ctu.jbus_clk) ;

            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_12_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_11_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_10_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_9_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_8_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_7_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_6_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_5_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_4_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_3_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_2_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_1_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_efc_rdcnt_u_dffrl_ns_0_.q ;
        end
    end
end
`else
always @(posedge cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_ctrl.jbus_clk) begin
    if (!$test$plusargs("no_slam_efc_rd")) begin
        // speed up the efc read counter
        if (cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_ctrl.efc_rd_cnt == 13'h1d) begin
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_ctrl.efc_rd_cnt = 13'h1ed5 ;
            @(posedge cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_ctrl.jbus_clk) ;
            release cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_ctrl.efc_rd_cnt ;
        end
    end
end
`endif // GATE_SIM_CTU

`ifdef GATE_SIM_DRAM
assign dram_queue_empty = (({`DCTLPATH0.ch0_que_pos [4], `DCTLPATH0.ch0_que_pos [3], `DCTLPATH0.ch0_que_pos [2], `DCTLPATH0.ch0_que_pos [1], `DCTLPATH0.ch0_que_pos [0]} == 5'he) &&
                           ({`DCTLPATH0.ch1_que_pos [4], `DCTLPATH0.ch1_que_pos [3], `DCTLPATH0.ch1_que_pos [2], `DCTLPATH0.ch1_que_pos [1], `DCTLPATH0.ch1_que_pos [0]} == 5'he) &&
                           ({`DCTLPATH1.ch0_que_pos [4], `DCTLPATH1.ch0_que_pos [3], `DCTLPATH1.ch0_que_pos [2], `DCTLPATH1.ch0_que_pos [1], `DCTLPATH1.ch0_que_pos [0]} == 5'he) &&
                           ({`DCTLPATH1.ch1_que_pos [4], `DCTLPATH1.ch1_que_pos [3], `DCTLPATH1.ch1_que_pos [2], `DCTLPATH1.ch1_que_pos [1], `DCTLPATH1.ch1_que_pos [0]} == 5'he)) ? 1'b1 : 1'b0 ;
`else
assign dram_queue_empty = ((`DCTLPATH0.dramctl0.dram_dctl.dram_que.que_pos == 5'he) &&
                           (`DCTLPATH0.dramctl1.dram_dctl.dram_que.que_pos == 5'he) &&
                           (`DCTLPATH1.dramctl0.dram_dctl.dram_que.que_pos == 5'he) &&
                           (`DCTLPATH1.dramctl1.dram_dctl.dram_que.que_pos == 5'he)) ? 1'b1 : 1'b0 ;
`endif

`ifdef GATE_SIM_CTU
always @(posedge cmp_top.iop.ctu.jbus_clk) begin
    if (!$test$plusargs("no_fast_dram_rst")) begin
        // speed up the dram grst counter
        if ({cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_11_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_10_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_9_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_8_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_7_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_6_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_5_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_4_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_3_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_2_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_1_.q,
                cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_0_.q} == 12'h0f) begin
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_11_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_10_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_9_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_8_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_7_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_6_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_5_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_4_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_3_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_2_.q = 1'b1 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_1_.q = 1'b0 ;
            force cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_0_.q = 1'b0 ;

            while (dram_queue_empty === 1'b0) @(posedge cmp_top.iop.ctu.jbus_clk) ;

            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_11_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_10_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_9_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_8_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_7_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_6_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_5_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_4_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_3_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_2_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_1_.q ;
            release cmp_top.iop.ctu.ctu_clsp_u_ctu_clsp_ctrl_u_dram_rstcnt_u_dffrl_ns_0_.q ;
        end
    end
end
`else
always @(posedge cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_ctrl.jbus_clk) begin
    if (!$test$plusargs("no_fast_dram_rst")) begin
        // speed up the dram grst counter
        if (cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_ctrl.dram_grst_cnt == 12'h0f) begin
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_ctrl.dram_grst_cnt = 12'h62c ;
            while (dram_queue_empty === 1'b0) @(posedge cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_ctrl.jbus_clk) ;
            release cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_ctrl.dram_grst_cnt ;
        end
    end
end
`endif

// force the ctu to power up in selected ratio

`ifdef GATE_SIM_CTU
`else
always @(cmp_top.cmp_clk.cmp_div or cmp_top.cmp_clk.jbus_div or cmp_top.cmp_clk.dram_div)  begin
    if (!$test$plusargs("no_ctu_reg_slam")) begin
        if (cmp_top.cmp_clk.cmp_div == 2) begin
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.reg_cdiv = 5'd2 ;
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.reg_div_cmult = 13'd168 ;
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.reg_cdiv_vec= 15'b000_001_0000_0001_1;
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.shadreg_div_cmult = 13'd168 ;
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.shadreg_cdiv_vec= 15'b000_001_0000_0001_1;
        end

        if (cmp_top.cmp_clk.jbus_div == 12) begin
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.reg_jdiv = 5'd12 ;
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.reg_div_jmult = 10'd28 ;
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.reg_jdiv_vec= 15'b000_100_0001_0001_0;
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.shadreg_div_jmult = 10'd28 ;
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.shadreg_jdiv_vec= 15'b000_100_0001_0001_0;

            if (cmp_top.cmp_clk.cmp_div == 2) begin
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.jsync_reg_init = 5'd4 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.jsync_reg_period = 5'd5 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.jsync_reg_tx0 = 5'd2 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.jsync_reg_tx1 = 5'd2 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.jsync_reg_tx2 = 5'd2 ;

                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.jsync_shadreg_init  = 5'd4 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.jsync_shadreg_period = 5'd5 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.jsync_shadreg_tx0 = 5'd2 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.jsync_shadreg_tx1 = 5'd2 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.jsync_shadreg_tx2 = 5'd2 ;
            end
        end

        if (cmp_top.cmp_clk.dram_div == 14) begin
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.reg_ddiv = 5'd14 ;
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.reg_div_dmult = 10'd24 ;
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.reg_ddiv_vec= 15'b010_010_0001_0001_0;
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.shadreg_div_dmult = 10'd24 ;
            force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.shadreg_ddiv_vec= 15'b010_010_0001_0001_0;

            if (cmp_top.cmp_clk.cmp_div == 2) begin
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.dsync_reg_init = 5'd5 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.dsync_reg_period = 5'd6 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.dsync_reg_tx0 = 5'd1 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.dsync_reg_tx1 = 5'd1 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_creg.dsync_reg_tx2 = 5'd1 ;

                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.dsync_shadreg_init  = 5'd5 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.dsync_shadreg_period = 5'd6 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.dsync_shadreg_tx0 = 5'd1 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.dsync_shadreg_tx1 = 5'd1 ;
                force cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_clkgn.u_ctu_clsp_clkgn_shadreg.dsync_shadreg_tx2 = 5'd1 ;
            end
        end
    end
end
`endif // ifdef GATE_SIM_CTU
`endif // ifdef RTL_CTU

// BIST will be used to reset icache/dcache in real chip

always @(posedge `SPARC_CORE0.cmp_grst_l) begin
    if (!$test$plusargs("no_bisi_init") &&
            !$test$plusargs("l1warm")) begin


               `ifdef RTL_SPARC0
    `ifdef FPGA_SYN_IDCT
            `ICVPATH0.idcv_ary_0000[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_0001[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_0010[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_0011[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_0100[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_0101[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_0110[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_0111[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_1000[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_1001[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_1010[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_1011[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_1100[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_1101[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_1110[31:0] = 32'h0;
            `ICVPATH0.idcv_ary_1111[31:0] = 32'h0;
            `DVLD0.idcv_ary_0000[31:0] = 32'h0;
            `DVLD0.idcv_ary_0001[31:0] = 32'h0;
            `DVLD0.idcv_ary_0010[31:0] = 32'h0;
            `DVLD0.idcv_ary_0011[31:0] = 32'h0;
            `DVLD0.idcv_ary_0100[31:0] = 32'h0;
            `DVLD0.idcv_ary_0101[31:0] = 32'h0;
            `DVLD0.idcv_ary_0110[31:0] = 32'h0;
            `DVLD0.idcv_ary_0111[31:0] = 32'h0;
            `DVLD0.idcv_ary_1000[31:0] = 32'h0;
            `DVLD0.idcv_ary_1001[31:0] = 32'h0;
            `DVLD0.idcv_ary_1010[31:0] = 32'h0;
            `DVLD0.idcv_ary_1011[31:0] = 32'h0;
            `DVLD0.idcv_ary_1100[31:0] = 32'h0;
            `DVLD0.idcv_ary_1101[31:0] = 32'h0;
            `DVLD0.idcv_ary_1110[31:0] = 32'h0;
            `DVLD0.idcv_ary_1111[31:0] = 32'h0;
    `else
    `ifdef USE_IBM_SRAMS
            // `ICVPATH0.idcv_ary[511:0] = 512'h0;
            // `ICVPATH0.idcv_ary_0000[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_0001[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_0010[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_0011[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_0100[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_0101[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_0110[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_0111[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_1000[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_1001[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_1010[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_1011[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_1100[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_1101[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_1110[31:0] = 32'h0;
            // `ICVPATH0.idcv_ary_1111[31:0] = 32'h0;


            // for(j=0; j<(`IC_ENTRY_HI+1)/4; j=j+1) begin
            //     `ICTPATH0.ictag_ary_00.array[j] = {{`IC_TAG_SZ{1'b0}}, 1'b0};
            //     `ICTPATH0.ictag_ary_01.array[j] = {{`IC_TAG_SZ{1'b0}}, 1'b0};
            //     `ICTPATH0.ictag_ary_10.array[j] = {{`IC_TAG_SZ{1'b0}}, 1'b0};
            //     `ICTPATH0.ictag_ary_11.array[j] = {{`IC_TAG_SZ{1'b0}}, 1'b0};
            // end
            // for(j=0; j<=`IC_ENTRY_HI; j=j+1) begin
            //     `ICTPATH0.ictag_ary[j] = {{`IC_TAG_SZ{1'b0}}, 1'b0};
            // end



            // `DVLD0.idcv_ary[511:0] = 512'h0;
            // `DVLD0.idcv_ary_0000[31:0] = 32'h0;
            // `DVLD0.idcv_ary_0001[31:0] = 32'h0;
            // `DVLD0.idcv_ary_0010[31:0] = 32'h0;
            // `DVLD0.idcv_ary_0011[31:0] = 32'h0;
            // `DVLD0.idcv_ary_0100[31:0] = 32'h0;
            // `DVLD0.idcv_ary_0101[31:0] = 32'h0;
            // `DVLD0.idcv_ary_0110[31:0] = 32'h0;
            // `DVLD0.idcv_ary_0111[31:0] = 32'h0;
            // `DVLD0.idcv_ary_1000[31:0] = 32'h0;
            // `DVLD0.idcv_ary_1001[31:0] = 32'h0;
            // `DVLD0.idcv_ary_1010[31:0] = 32'h0;
            // `DVLD0.idcv_ary_1011[31:0] = 32'h0;
            // `DVLD0.idcv_ary_1100[31:0] = 32'h0;
            // `DVLD0.idcv_ary_1101[31:0] = 32'h0;
            // `DVLD0.idcv_ary_1110[31:0] = 32'h0;
            // `DVLD0.idcv_ary_1111[31:0] = 32'h0;


            // for(j=0; j<=127; j=j+1) begin
            //     `DTAG0.ictag_ary_00.array[j] = 33'h0;
            //     `DTAG0.ictag_ary_01.array[j] = 33'h0;
            //     `DTAG0.ictag_ary_10.array[j] = 33'h0;
            //     `DTAG0.ictag_ary_11.array[j] = 33'h0;
            // end
      `ifdef IBM_SRAM_CACHE_TAG_SIMULATION
            for(j=0; j<=128; j=j+1) begin
                `ICTPATH0.cache[j] = 132'b0;
            end
            for(j=0; j<=128; j=j+1) begin
                `DTAG0.cache[j] = 132'b0;
            end
      `endif
            // `DVLD0.idcv_ary[511:0] = 512'h0;
            // for(j=0; j<=511; j=j+1) begin
            //     `DTAG0.ictag_ary[j] = 33'h0;
            // end

      `endif
      `endif // ibm
      `endif // sparc0





    end // if (!$test$plusargs("no_bisi_init"))
end // always @ (posedge cmp_top.iop.J_RST_L)

`ifdef NO_L2_WARM
`else

`ifdef GATE_SIM
`else
//l2warm l2warm();
//l1warm l1warm();
reg [`MAX_TILE:0]   status;
reg [7:0]   cmd, thrid, idx;
reg [63:0]  tlb_tag, tlb_data;
reg 	       dummy;
reg [1:0]   tlb_slam;
reg [7:0]   ind;

initial begin
    status = 0;

 `ifdef RTL_SPARC0
    status[0] = 1;
 `endif




    if($value$plusargs("tlb_slam=%h", tlb_slam))begin
        if(tlb_slam == 1)$display ("%t: tlb slam option is on using midas data.", $time);
        else   $display ("%t: tlb slam option is on using Rust data.", $time);
    end
    else tlb_slam = 0;
    if(tlb_slam)begin
`ifndef RTL_SPU
        @(posedge `PCXPATH0.ifu.ifu.itlb.demap_all);
`else
        @(posedge `PCXPATH0.ifu.itlb.demap_all);
`endif
        //`TOP_MOD.cmp_grst_l);

        repeat(800) @(posedge `TOP_MOD.clk);//waiting for tlb reset operation
`ifdef FPGA_SYN_TLB
//asdf; // tri: can't extend to 64 cores
        $slam_cache(3,
                    tlb_slam,
                    status,
		     `ifdef RTL_SPARC0 //10
`ifndef RTL_SPU
                    `PCXPATH0.ifu.ifu.itlb.bw_r_tlb_tag_ram.tte_tag_ram,
                    `PCXPATH0.ifu.ifu.itlb.bw_r_tlb_data_ram.tte_data_ram,
                    `PCXPATH0.ifu.ifu.itlb.tlb_entry_used,
                    `PCXPATH0.ifu.ifu.itlb.tlb_entry_locked,
                    `PCXPATH0.ifu.ifu.itlb.tlb_entry_vld,  
`else
                    `PCXPATH0.ifu.itlb.bw_r_tlb_tag_ram.tte_tag_ram,
                    `PCXPATH0.ifu.itlb.bw_r_tlb_data_ram.tte_data_ram,
                    `PCXPATH0.ifu.itlb.tlb_entry_used,
                    `PCXPATH0.ifu.itlb.tlb_entry_locked,
                    `PCXPATH0.ifu.itlb.tlb_entry_vld,
`endif                    

                    `PCXPATH0.lsu.dtlb.bw_r_tlb_tag_ram.tte_tag_ram,
                    `PCXPATH0.lsu.dtlb.bw_r_tlb_data_ram.tte_data_ram,
                    `PCXPATH0.lsu.dtlb.tlb_entry_used,
                    `PCXPATH0.lsu.dtlb.tlb_entry_locked,
                    `PCXPATH0.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC1
`ifndef RTL_SPU
                    `PCXPATH1.ifu.ifu.itlb.tte_tag_ram,
                    `PCXPATH1.ifu.ifu.itlb.tte_data_ram,
                    `PCXPATH1.ifu.ifu.itlb.tlb_entry_used,
                    `PCXPATH1.ifu.ifu.itlb.tlb_entry_locked,
                    `PCXPATH1.ifu.ifu.itlb.tlb_entry_vld,
`else
                    `PCXPATH1.ifu.itlb.tte_tag_ram,
                    `PCXPATH1.ifu.itlb.tte_data_ram,
                    `PCXPATH1.ifu.itlb.tlb_entry_used,
                    `PCXPATH1.ifu.itlb.tlb_entry_locked,
                    `PCXPATH1.ifu.itlb.tlb_entry_vld,
`endif                    

                    `PCXPATH1.lsu.dtlb.tte_tag_ram,
                    `PCXPATH1.lsu.dtlb.tte_data_ram,
                    `PCXPATH1.lsu.dtlb.tlb_entry_used,
                    `PCXPATH1.lsu.dtlb.tlb_entry_locked,
                    `PCXPATH1.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC2
`ifndef RTL_SPU
                    `PCXPATH2.ifu.ifu.itlb.tte_tag_ram,
                    `PCXPATH2.ifu.ifu.itlb.tte_data_ram,
                    `PCXPATH2.ifu.ifu.itlb.tlb_entry_used,
                    `PCXPATH2.ifu.ifu.itlb.tlb_entry_locked,
                    `PCXPATH2.ifu.ifu.itlb.tlb_entry_vld,
`else
                    `PCXPATH2.ifu.itlb.tte_tag_ram,
                    `PCXPATH2.ifu.itlb.tte_data_ram,
                    `PCXPATH2.ifu.itlb.tlb_entry_used,
                    `PCXPATH2.ifu.itlb.tlb_entry_locked,
                    `PCXPATH2.ifu.itlb.tlb_entry_vld,
`endif

                    `PCXPATH2.lsu.dtlb.tte_tag_ram,
                    `PCXPATH2.lsu.dtlb.tte_data_ram,
                    `PCXPATH2.lsu.dtlb.tlb_entry_used,
                    `PCXPATH2.lsu.dtlb.tlb_entry_locked,
                    `PCXPATH2.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC3
`ifndef RTL_SPU
                    `PCXPATH3.ifu.ifu.itlb.tte_tag_ram,
                    `PCXPATH3.ifu.ifu.itlb.tte_data_ram,
                    `PCXPATH3.ifu.ifu.itlb.tlb_entry_used,
                    `PCXPATH3.ifu.ifu.itlb.tlb_entry_locked,
                    `PCXPATH3.ifu.ifu.itlb.tlb_entry_vld,
`else
                    `PCXPATH3.ifu.itlb.tte_tag_ram,
                    `PCXPATH3.ifu.itlb.tte_data_ram,
                    `PCXPATH3.ifu.itlb.tlb_entry_used,
                    `PCXPATH3.ifu.itlb.tlb_entry_locked,
                    `PCXPATH3.ifu.itlb.tlb_entry_vld,
`endif

                    `PCXPATH3.lsu.dtlb.tte_tag_ram,
                    `PCXPATH3.lsu.dtlb.tte_data_ram,
                    `PCXPATH3.lsu.dtlb.tlb_entry_used,
                    `PCXPATH3.lsu.dtlb.tlb_entry_locked,
                    `PCXPATH3.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC4
`ifndef RTL_SPU
                    `PCXPATH4.ifu.ifu.itlb.tte_tag_ram,
                    `PCXPATH4.ifu.ifu.itlb.tte_data_ram,
                    `PCXPATH4.ifu.ifu.itlb.tlb_entry_used,
                    `PCXPATH4.ifu.ifu.itlb.tlb_entry_locked,
                    `PCXPATH4.ifu.ifu.itlb.tlb_entry_vld,
`else
                    `PCXPATH4.ifu.itlb.tte_tag_ram,
                    `PCXPATH4.ifu.itlb.tte_data_ram,
                    `PCXPATH4.ifu.itlb.tlb_entry_used,
                    `PCXPATH4.ifu.itlb.tlb_entry_locked,
                    `PCXPATH4.ifu.itlb.tlb_entry_vld,
`endif

                    `PCXPATH4.lsu.dtlb.tte_tag_ram,
                    `PCXPATH4.lsu.dtlb.tte_data_ram,
                    `PCXPATH4.lsu.dtlb.tlb_entry_used,
                    `PCXPATH4.lsu.dtlb.tlb_entry_locked,
                    `PCXPATH4.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC5
`ifndef RTL_SPU
                    `PCXPATH5.ifu.ifu.itlb.tte_tag_ram,
                    `PCXPATH5.ifu.ifu.itlb.tte_data_ram,
                    `PCXPATH5.ifu.ifu.itlb.tlb_entry_used,
                    `PCXPATH5.ifu.ifu.itlb.tlb_entry_locked,
                    `PCXPATH5.ifu.ifu.itlb.tlb_entry_vld,
`else
                    `PCXPATH5.ifu.itlb.tte_tag_ram,
                    `PCXPATH5.ifu.itlb.tte_data_ram,
                    `PCXPATH5.ifu.itlb.tlb_entry_used,
                    `PCXPATH5.ifu.itlb.tlb_entry_locked,
                    `PCXPATH5.ifu.itlb.tlb_entry_vld,
`endif

                    `PCXPATH5.lsu.dtlb.tte_tag_ram,
                    `PCXPATH5.lsu.dtlb.tte_data_ram,
                    `PCXPATH5.lsu.dtlb.tlb_entry_used,
                    `PCXPATH5.lsu.dtlb.tlb_entry_locked,
                    `PCXPATH5.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC6
`ifndef RTL_SPU
                    `PCXPATH6.ifu.ifu.itlb.tte_tag_ram,
                    `PCXPATH6.ifu.ifu.itlb.tte_data_ram,
                    `PCXPATH6.ifu.ifu.itlb.tlb_entry_used,
                    `PCXPATH6.ifu.ifu.itlb.tlb_entry_locked,
                    `PCXPATH6.ifu.ifu.itlb.tlb_entry_vld,
`else
                    `PCXPATH6.ifu.itlb.tte_tag_ram,
                    `PCXPATH6.ifu.itlb.tte_data_ram,
                    `PCXPATH6.ifu.itlb.tlb_entry_used,
                    `PCXPATH6.ifu.itlb.tlb_entry_locked,
                    `PCXPATH6.ifu.itlb.tlb_entry_vld,
`endif

                    `PCXPATH6.lsu.dtlb.tte_tag_ram,
                    `PCXPATH6.lsu.dtlb.tte_data_ram,
                    `PCXPATH6.lsu.dtlb.tlb_entry_used,
                    `PCXPATH6.lsu.dtlb.tlb_entry_locked,
                    `PCXPATH6.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC7
`ifndef RTL_SPU
                    `PCXPATH7.ifu.ifu.itlb.tte_tag_ram,
                    `PCXPATH7.ifu.ifu.itlb.tte_data_ram,
                    `PCXPATH7.ifu.ifu.itlb.tlb_entry_used,
                    `PCXPATH7.ifu.ifu.itlb.tlb_entry_locked,
                    `PCXPATH7.ifu.ifu.itlb.tlb_entry_vld,
`else
                    `PCXPATH7.ifu.itlb.tte_tag_ram,
                    `PCXPATH7.ifu.itlb.tte_data_ram,
                    `PCXPATH7.ifu.itlb.tlb_entry_used,
                    `PCXPATH7.ifu.itlb.tlb_entry_locked,
                    `PCXPATH7.ifu.itlb.tlb_entry_vld,
`endif

                    `PCXPATH7.lsu.dtlb.tte_tag_ram,
                    `PCXPATH7.lsu.dtlb.tte_data_ram,
                    `PCXPATH7.lsu.dtlb.tlb_entry_used,
                    `PCXPATH7.lsu.dtlb.tlb_entry_locked,
                    `PCXPATH7.lsu.dtlb.tlb_entry_vld,
		     `endif
                   );

`else
`ifdef NOT_USED // tri: can't extend to 64 cores
$slam_cache(3,
            tlb_slam,
            status,
		     `ifdef RTL_SPARC0 //10
`ifndef RTL_SPU
            `PCXPATH0.ifu.ifu.itlb.tte_tag_ram,
            `PCXPATH0.ifu.ifu.itlb.tte_data_ram,
            `PCXPATH0.ifu.ifu.itlb.tlb_entry_used,
            `PCXPATH0.ifu.ifu.itlb.tlb_entry_locked,
            `PCXPATH0.ifu.ifu.itlb.tlb_entry_vld,
`else
            `PCXPATH0.ifu.itlb.tte_tag_ram,
            `PCXPATH0.ifu.itlb.tte_data_ram,
            `PCXPATH0.ifu.itlb.tlb_entry_used,
            `PCXPATH0.ifu.itlb.tlb_entry_locked,
            `PCXPATH0.ifu.itlb.tlb_entry_vld,
`endif

            `PCXPATH0.lsu.dtlb.tte_tag_ram,
            `PCXPATH0.lsu.dtlb.tte_data_ram,
            `PCXPATH0.lsu.dtlb.tlb_entry_used,
            `PCXPATH0.lsu.dtlb.tlb_entry_locked,
            `PCXPATH0.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC1
`ifndef RTL_SPU
            `PCXPATH1.ifu.ifu.itlb.tte_tag_ram,
            `PCXPATH1.ifu.ifu.itlb.tte_data_ram,
            `PCXPATH1.ifu.ifu.itlb.tlb_entry_used,
            `PCXPATH1.ifu.ifu.itlb.tlb_entry_locked,
            `PCXPATH1.ifu.ifu.itlb.tlb_entry_vld,
`else
            `PCXPATH1.ifu.itlb.tte_tag_ram,
            `PCXPATH1.ifu.itlb.tte_data_ram,
            `PCXPATH1.ifu.itlb.tlb_entry_used,
            `PCXPATH1.ifu.itlb.tlb_entry_locked,
            `PCXPATH1.ifu.itlb.tlb_entry_vld,
`endif

            `PCXPATH1.lsu.dtlb.tte_tag_ram,
            `PCXPATH1.lsu.dtlb.tte_data_ram,
            `PCXPATH1.lsu.dtlb.tlb_entry_used,
            `PCXPATH1.lsu.dtlb.tlb_entry_locked,
            `PCXPATH1.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC2
`ifndef RTL_SPU
            `PCXPATH2.ifu.ifu.itlb.tte_tag_ram,
            `PCXPATH2.ifu.ifu.itlb.tte_data_ram,
            `PCXPATH2.ifu.ifu.itlb.tlb_entry_used,
            `PCXPATH2.ifu.ifu.itlb.tlb_entry_locked,
            `PCXPATH2.ifu.ifu.itlb.tlb_entry_vld,
`else
            `PCXPATH2.ifu.itlb.tte_tag_ram,
            `PCXPATH2.ifu.itlb.tte_data_ram,
            `PCXPATH2.ifu.itlb.tlb_entry_used,
            `PCXPATH2.ifu.itlb.tlb_entry_locked,
            `PCXPATH2.ifu.itlb.tlb_entry_vld,
`endif

            `PCXPATH2.lsu.dtlb.tte_tag_ram,
            `PCXPATH2.lsu.dtlb.tte_data_ram,
            `PCXPATH2.lsu.dtlb.tlb_entry_used,
            `PCXPATH2.lsu.dtlb.tlb_entry_locked,
            `PCXPATH2.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC3
`ifndef RTL_SPU
            `PCXPATH3.ifu.ifu.itlb.tte_tag_ram,
            `PCXPATH3.ifu.ifu.itlb.tte_data_ram,
            `PCXPATH3.ifu.ifu.itlb.tlb_entry_used,
            `PCXPATH3.ifu.ifu.itlb.tlb_entry_locked,
            `PCXPATH3.ifu.ifu.itlb.tlb_entry_vld,
`else
            `PCXPATH3.ifu.itlb.tte_tag_ram,
            `PCXPATH3.ifu.itlb.tte_data_ram,
            `PCXPATH3.ifu.itlb.tlb_entry_used,
            `PCXPATH3.ifu.itlb.tlb_entry_locked,
            `PCXPATH3.ifu.itlb.tlb_entry_vld,
`endif

            `PCXPATH3.lsu.dtlb.tte_tag_ram,
            `PCXPATH3.lsu.dtlb.tte_data_ram,
            `PCXPATH3.lsu.dtlb.tlb_entry_used,
            `PCXPATH3.lsu.dtlb.tlb_entry_locked,
            `PCXPATH3.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC4
`ifndef RTL_SPU
            `PCXPATH4.ifu.ifu.itlb.tte_tag_ram,
            `PCXPATH4.ifu.ifu.itlb.tte_data_ram,
            `PCXPATH4.ifu.ifu.itlb.tlb_entry_used,
            `PCXPATH4.ifu.ifu.itlb.tlb_entry_locked,
            `PCXPATH4.ifu.ifu.itlb.tlb_entry_vld,
`else
            `PCXPATH4.ifu.itlb.tte_tag_ram,
            `PCXPATH4.ifu.itlb.tte_data_ram,
            `PCXPATH4.ifu.itlb.tlb_entry_used,
            `PCXPATH4.ifu.itlb.tlb_entry_locked,
            `PCXPATH4.ifu.itlb.tlb_entry_vld,
`endif

            `PCXPATH4.lsu.dtlb.tte_tag_ram,
            `PCXPATH4.lsu.dtlb.tte_data_ram,
            `PCXPATH4.lsu.dtlb.tlb_entry_used,
            `PCXPATH4.lsu.dtlb.tlb_entry_locked,
            `PCXPATH4.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC5
`ifndef RTL_SPU
            `PCXPATH5.ifu.ifu.itlb.tte_tag_ram,
            `PCXPATH5.ifu.ifu.itlb.tte_data_ram,
            `PCXPATH5.ifu.ifu.itlb.tlb_entry_used,
            `PCXPATH5.ifu.ifu.itlb.tlb_entry_locked,
            `PCXPATH5.ifu.ifu.itlb.tlb_entry_vld,
`else
            `PCXPATH5.ifu.itlb.tte_tag_ram,
            `PCXPATH5.ifu.itlb.tte_data_ram,
            `PCXPATH5.ifu.itlb.tlb_entry_used,
            `PCXPATH5.ifu.itlb.tlb_entry_locked,
            `PCXPATH5.ifu.itlb.tlb_entry_vld,
`endif

            `PCXPATH5.lsu.dtlb.tte_tag_ram,
            `PCXPATH5.lsu.dtlb.tte_data_ram,
            `PCXPATH5.lsu.dtlb.tlb_entry_used,
            `PCXPATH5.lsu.dtlb.tlb_entry_locked,
            `PCXPATH5.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC6
`ifndef RTL_SPU
            `PCXPATH6.ifu.ifu.itlb.tte_tag_ram,
            `PCXPATH6.ifu.ifu.itlb.tte_data_ram,
            `PCXPATH6.ifu.ifu.itlb.tlb_entry_used,
            `PCXPATH6.ifu.ifu.itlb.tlb_entry_locked,
            `PCXPATH6.ifu.ifu.itlb.tlb_entry_vld,
`else
            `PCXPATH6.ifu.itlb.tte_tag_ram,
            `PCXPATH6.ifu.itlb.tte_data_ram,
            `PCXPATH6.ifu.itlb.tlb_entry_used,
            `PCXPATH6.ifu.itlb.tlb_entry_locked,
            `PCXPATH6.ifu.itlb.tlb_entry_vld,
`endif

            `PCXPATH6.lsu.dtlb.tte_tag_ram,
            `PCXPATH6.lsu.dtlb.tte_data_ram,
            `PCXPATH6.lsu.dtlb.tlb_entry_used,
            `PCXPATH6.lsu.dtlb.tlb_entry_locked,
            `PCXPATH6.lsu.dtlb.tlb_entry_vld,
		     `endif

		     `ifdef RTL_SPARC7
`ifndef RTL_SPU
            `PCXPATH7.ifu.ifu.itlb.tte_tag_ram,
            `PCXPATH7.ifu.ifu.itlb.tte_data_ram,
            `PCXPATH7.ifu.ifu.itlb.tlb_entry_used,
            `PCXPATH7.ifu.ifu.itlb.tlb_entry_locked,
            `PCXPATH7.ifu.ifu.itlb.tlb_entry_vld,
`else
            `PCXPATH7.ifu.itlb.tte_tag_ram,
            `PCXPATH7.ifu.itlb.tte_data_ram,
            `PCXPATH7.ifu.itlb.tlb_entry_used,
            `PCXPATH7.ifu.itlb.tlb_entry_locked,
            `PCXPATH7.ifu.itlb.tlb_entry_vld,
`endif

            `PCXPATH7.lsu.dtlb.tte_tag_ram,
            `PCXPATH7.lsu.dtlb.tte_data_ram,
            `PCXPATH7.lsu.dtlb.tlb_entry_used,
            `PCXPATH7.lsu.dtlb.tlb_entry_locked,
            `PCXPATH7.lsu.dtlb.tlb_entry_vld,
		     `endif
           );
`endif // NOT_USED
`endif
        cmd = 1;
        //slam sas site
        if($test$plusargs("use_sas_tasks"))begin
            while(cmd)begin
                $slam_cache(4, cmd, thrid, idx, tlb_tag, tlb_data);
                if(cmd)begin
                    dummy = $bw_sas_send(cmd, thrid, idx,
                                         tlb_tag[63:56], tlb_tag[55:48], tlb_tag[47:40], tlb_tag[39:32],
                                         tlb_tag[31:24], tlb_tag[23:16], tlb_tag[15:8],  tlb_tag[7:0],
                                         tlb_data[63:56], tlb_data[55:48], tlb_data[47:40], tlb_data[39:32],
                                         tlb_data[31:24], tlb_data[23:16], tlb_data[15:8], tlb_data[7:0]);
                end
            end
        end // if ($test$plusargs("use_sas_tasks"))
        /* for(ind = 0; ind < 64;ind = ind + 1)begin
        $display("TAG = %x DATA = %x used = %x valid = %x",
`ifndef RTL_SPU
        `PCXPATH0.ifu.ifu.itlb.tte_tag_ram[ind],
        `PCXPATH0.ifu.ifu.itlb.tte_tag_ram[ind],
`else
        `PCXPATH0.ifu.itlb.tte_tag_ram[ind],
        `PCXPATH0.ifu.itlb.tte_tag_ram[ind],
`endif
        `PCXPATH0.lsu.dtlb.tlb_entry_used,
        `PCXPATH0.lsu.dtlb.tlb_entry_vld);

        end*/
    end // if (tlb_slam)
end // initial begin
`endif
`endif

// BISI will be used to reset l2 cache in real chip

always @(posedge `SPARC_CORE0.cmp_grst_l) begin
    if (!$test$plusargs("no_bisi_init") &&
            !$test$plusargs("l2warm")) begin
        for(j=0; j < 32; j=j+1) begin
        `ifdef RTL_SCTAG0
            `SCPATH0.subarray_0.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_1.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_2.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_3.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_4.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_5.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_6.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_7.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_8.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_9.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_10.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_11.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_12.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_13.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_14.inq_ary[j] = 108'b0 ;
            `SCPATH0.subarray_15.inq_ary[j] = 108'b0 ;
        `endif

        `ifdef RTL_SCTAG1
            `SCPATH1.subarray_0.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_1.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_2.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_3.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_4.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_5.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_6.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_7.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_8.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_9.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_10.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_11.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_12.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_13.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_14.inq_ary[j] = 108'b0 ;
            `SCPATH1.subarray_15.inq_ary[j] = 108'b0 ;
        `endif

        `ifdef RTL_SCTAG2
            `SCPATH2.subarray_0.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_1.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_2.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_3.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_4.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_5.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_6.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_7.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_8.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_9.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_10.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_11.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_12.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_13.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_14.inq_ary[j] = 108'b0 ;
            `SCPATH2.subarray_15.inq_ary[j] = 108'b0 ;
        `endif

        `ifdef RTL_SCTAG3
            `SCPATH3.subarray_0.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_1.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_2.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_3.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_4.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_5.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_6.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_7.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_8.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_9.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_10.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_11.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_12.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_13.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_14.inq_ary[j] = 108'b0 ;
            `SCPATH3.subarray_15.inq_ary[j] = 108'b0 ;
        `endif
        end
    end
end

// integer ind;

integer regc;

initial begin
    if (!$test$plusargs("no_slam_init")) begin

`ifdef RTL_SPARC0
`ifdef FPGA_SYN_IRF
`ifdef FPGA_SYN_1THREAD
        `SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window[0] = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window[1] = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window[2] = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window[3] = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window[4] = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window[5] = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window[6] = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window[7] = 72'b0;

        `SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register01.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register02.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register03.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register04.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register05.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register06.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register07.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register08.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register09.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register10.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register11.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register12.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register13.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register14.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register15.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register16.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register17.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register18.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register19.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register20.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register21.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register22.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register23.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register24.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register25.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register26.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register27.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register28.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register29.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register30.bw_r_irf_register.onereg = 72'b0;
        `SPARC_REG0.bw_r_irf_core.register31.bw_r_irf_register.onereg = 72'b0;


        //$slam_random(`SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register01.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register02.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register03.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register04.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register05.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register06.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register07.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register08.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register09.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register10.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register11.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register12.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register13.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register14.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register15.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register16.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register17.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register18.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register19.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register20.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register21.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register22.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register23.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register24.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register25.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register26.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register27.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register28.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register29.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register30.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register31.bw_r_irf_register.window, 8, 0);
`else
        for(regc = 0; regc < 32; regc = regc + 1)
            `SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window[regc] = 72'b0;

        //$slam_random(`SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register01.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register02.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register03.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register04.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register05.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register06.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register07.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register08.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register09.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register10.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register11.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register12.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register13.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register14.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register15.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register16.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register17.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register18.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register19.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register20.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register21.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register22.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register23.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register24.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register25.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register26.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register27.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register28.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register29.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register30.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register31.bw_r_irf_register.window, 32, 0);
`endif
`else
`ifndef CONFIG_NUM_THREADS
        //for(regc = 0; regc < 32; regc = regc + 1)
        //    `SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window[regc] = 72'b0;

        //$slam_random(`SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window, 32, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register01.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register02.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register03.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register04.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register05.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register06.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register07.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register08.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register09.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register10.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register11.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register12.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register13.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register14.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register15.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register16.bw_r_irf_register.window, 16, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register17.bw_r_irf_register.window, 16, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register18.bw_r_irf_register.window, 16, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register19.bw_r_irf_register.window, 16, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register20.bw_r_irf_register.window, 16, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register21.bw_r_irf_register.window, 16, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register22.bw_r_irf_register.window, 16, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register23.bw_r_irf_register.window, 16, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register24.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register25.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register26.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register27.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register28.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register29.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register30.bw_r_irf_register.window, 8, 0);
        $slam_random(`SPARC_REG0.bw_r_irf_core.register31.bw_r_irf_register.window, 8, 0);
`else
        $slam_random(`SPARC_REG0.active_window, 128, 0);
        $slam_random(`SPARC_REG0.evens, 128, 0);
        $slam_random(`SPARC_REG0.odds, 128, 0);
        $slam_random(`SPARC_REG0.globals, 128, 0);
`endif
`endif

      `ifdef GATE_SIM_SPARC
        // $slam_random(`FLOATPATH0.ffu_frf.regfile, 256, 1);
      `else
`ifdef FPGA_SYN_FRF
        // $slam_random(`FLOATPATH0.frf.regfile_high, 128, 1);
        // $slam_random(`FLOATPATH0.frf.regfile_low, 128, 1);
`else
        // $slam_random(`FLOATPATH0.frf.regfile, 256, 1);
`endif
      `endif //ifdef GATE_SIM_SPARC

`ifdef FPGA_SYN_IRF
`ifdef FPGA_SYN_1THREAD
`else
`endif
`else
`ifndef CONFIG_NUM_THREADS
`else
        $slam_random(`SPARC_REG0.locals, 256, 0);
`endif
`endif // FPGA_SYN

        //       for(ind = 0;ind < 256;ind = ind+4)begin
        //	  $display("info: slam_data of floating point register num(%d) val(%x) num(%d) val(%x) num(%d) val(%x) num(%d) val(%x)",
        //		   ind,  `FLOATPATH0.frf.regfile[ind],
        //		   ind+1,`FLOATPATH0.frf.regfile[ind+1],
        //		   ind+2, `FLOATPATH0.frf.regfile[ind+2],
        //		   ind+3, `FLOATPATH0.frf.regfile[ind+3]);
        //
        //       end

`endif


  `ifdef RTL_SPARC0
  `ifdef FPGA_SYN
          $slam_random(`SPARC_REG0.active_window_00000, 4, 0);
          $slam_random(`SPARC_REG0.active_window_00001, 4, 0);
          $slam_random(`SPARC_REG0.active_window_00010, 4, 0);
          $slam_random(`SPARC_REG0.active_window_00011, 4, 0);
          $slam_random(`SPARC_REG0.active_window_00100, 4, 0);
          $slam_random(`SPARC_REG0.active_window_00101, 4, 0);
          $slam_random(`SPARC_REG0.active_window_00110, 4, 0);
          $slam_random(`SPARC_REG0.active_window_00111, 4, 0);
          $slam_random(`SPARC_REG0.active_window_01000, 4, 0);
          $slam_random(`SPARC_REG0.active_window_01001, 4, 0);
          $slam_random(`SPARC_REG0.active_window_01010, 4, 0);
          $slam_random(`SPARC_REG0.active_window_01011, 4, 0);
          $slam_random(`SPARC_REG0.active_window_01100, 4, 0);
          $slam_random(`SPARC_REG0.active_window_01101, 4, 0);
          $slam_random(`SPARC_REG0.active_window_01110, 4, 0);
          $slam_random(`SPARC_REG0.active_window_01111, 4, 0);
          $slam_random(`SPARC_REG0.active_window_10000, 4, 0);
          $slam_random(`SPARC_REG0.active_window_10001, 4, 0);
          $slam_random(`SPARC_REG0.active_window_10010, 4, 0);
          $slam_random(`SPARC_REG0.active_window_10011, 4, 0);
          $slam_random(`SPARC_REG0.active_window_10100, 4, 0);
          $slam_random(`SPARC_REG0.active_window_10101, 4, 0);
          $slam_random(`SPARC_REG0.active_window_10110, 4, 0);
          $slam_random(`SPARC_REG0.active_window_10111, 4, 0);
          $slam_random(`SPARC_REG0.active_window_11000, 4, 0);
          $slam_random(`SPARC_REG0.active_window_11001, 4, 0);
          $slam_random(`SPARC_REG0.active_window_11010, 4, 0);
          $slam_random(`SPARC_REG0.active_window_11011, 4, 0);
          $slam_random(`SPARC_REG0.active_window_11100, 4, 0);
          $slam_random(`SPARC_REG0.active_window_11101, 4, 0);
          $slam_random(`SPARC_REG0.active_window_11110, 4, 0);
          $slam_random(`SPARC_REG0.active_window_11111, 4, 0);

          $slam_random(`SPARC_REG0.evens_000, 16, 0);
          $slam_random(`SPARC_REG0.evens_001, 16, 0);
          $slam_random(`SPARC_REG0.evens_010, 16, 0);
          $slam_random(`SPARC_REG0.evens_011, 16, 0);
          $slam_random(`SPARC_REG0.evens_100, 16, 0);
          $slam_random(`SPARC_REG0.evens_101, 16, 0);
          $slam_random(`SPARC_REG0.evens_110, 16, 0);
          $slam_random(`SPARC_REG0.evens_111, 16, 0);

          $slam_random(`SPARC_REG0.odds_000, 16, 0);
          $slam_random(`SPARC_REG0.odds_001, 16, 0);
          $slam_random(`SPARC_REG0.odds_010, 16, 0);
          $slam_random(`SPARC_REG0.odds_011, 16, 0);
          $slam_random(`SPARC_REG0.odds_100, 16, 0);
          $slam_random(`SPARC_REG0.odds_101, 16, 0);
          $slam_random(`SPARC_REG0.odds_110, 16, 0);
          $slam_random(`SPARC_REG0.odds_111, 16, 0);

          $slam_random(`SPARC_REG0.globals_000, 16, 0);
          $slam_random(`SPARC_REG0.globals_001, 16, 0);
          $slam_random(`SPARC_REG0.globals_010, 16, 0);
          $slam_random(`SPARC_REG0.globals_011, 16, 0);
          $slam_random(`SPARC_REG0.globals_100, 16, 0);
          $slam_random(`SPARC_REG0.globals_101, 16, 0);
          $slam_random(`SPARC_REG0.globals_110, 16, 0);
          $slam_random(`SPARC_REG0.globals_111, 16, 0);

          // $slam_random(`FLOATPATH0.frf.regfile_high, 128, 1);
          // $slam_random(`FLOATPATH0.frf.regfile_low, 128, 1);

          $slam_random(`SPARC_REG0.locals_000, 32, 0);
          $slam_random(`SPARC_REG0.locals_001, 32, 0);
          $slam_random(`SPARC_REG0.locals_010, 32, 0);
          $slam_random(`SPARC_REG0.locals_011, 32, 0);
          $slam_random(`SPARC_REG0.locals_100, 32, 0);
          $slam_random(`SPARC_REG0.locals_101, 32, 0);
          $slam_random(`SPARC_REG0.locals_110, 32, 0);
          $slam_random(`SPARC_REG0.locals_111, 32, 0);
  `else
  `ifndef CONFIG_NUM_THREADS
          //for(regc = 0; regc < 32; regc = regc + 1)
          //    `SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window[regc] = 72'b0;

          //$slam_random(`SPARC_REG0.bw_r_irf_core.register00.bw_r_irf_register.window, 32, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register01.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register02.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register03.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register04.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register05.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register06.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register07.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register08.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register09.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register10.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register11.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register12.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register13.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register14.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register15.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register16.bw_r_irf_register.window, 16, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register17.bw_r_irf_register.window, 16, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register18.bw_r_irf_register.window, 16, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register19.bw_r_irf_register.window, 16, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register20.bw_r_irf_register.window, 16, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register21.bw_r_irf_register.window, 16, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register22.bw_r_irf_register.window, 16, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register23.bw_r_irf_register.window, 16, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register24.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register25.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register26.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register27.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register28.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register29.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register30.bw_r_irf_register.window, 8, 0);
          $slam_random(`SPARC_REG0.bw_r_irf_core.register31.bw_r_irf_register.window, 8, 0);
  `else
          $slam_random(`SPARC_REG0.active_window, 128, 0);
          $slam_random(`SPARC_REG0.evens, 128, 0);
          $slam_random(`SPARC_REG0.odds, 128, 0);
          $slam_random(`SPARC_REG0.globals, 128, 0);
          // $slam_random(`FLOATPATH0.frf.regfile, 256, 1);
          $slam_random(`SPARC_REG0.locals,256, 0);
  `endif
  `endif // FPGA_SYN
  `endif





    end // if no_slam_init
end // initial

endmodule

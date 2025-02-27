// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: pc_cmp.v
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

`include "ifu.tmp.h"
`define GOOD_TRAP_COUNTER 32

`define NUM_TILES 1


 module pc_cmp(/*AUTOARG*/
     // Inputs
     clk,
     rst_l
 );
input clk;
input rst_l;

// trap register

reg [3:0]   finish_mask, diag_mask;
reg [3:0]    active_thread, back_thread, good_delay;
reg [3:0]    good, good_for;
reg [4:0]    thread_status[3:0];
reg [0:0]   done;
reg [31:0]     timeout [3:0];


 reg [39:0]      good_trap[`GOOD_TRAP_COUNTER-1:0];
reg [39:0]   bad_trap [`GOOD_TRAP_COUNTER-1:0];

reg           dum;
reg           hit_bad;

integer       max, time_tmp, trap_count;


    reg spc0_inst_done;
    wire [1:0]   spc0_thread_id;
    wire [63:0]      spc0_rtl_pc;
    wire sas_m0;
    reg [63:0] spc0_phy_pc_w;

    


reg          sas_def;
reg           max_cycle;
integer      good_trap_count;
integer      bad_trap_count;
//argment for stub
reg [7:0]    stub_mask;
reg [7:0]     stub_good;
reg          good_flag;

//use this for the second reset.
initial begin
    back_thread = 0;
    good_delay  = 0;
    good_for    = 0;
    stub_good   = 0;

    if($test$plusargs("use_sas_tasks"))sas_def = 1;
    else sas_def = 0;
    if($test$plusargs("stop_2nd_good"))good_flag= 1;
    else good_flag = 0;

    max_cycle = 1;
    if($test$plusargs("thread_timeout_off"))max_cycle = 0;
end
//-----------------------------------------------------------
// check bad trap
task check_bad_trap;
    input [39:0] pc;
    input [2:0] i;
    input [9:0] thread;
    integer l, j;

    begin
        if(active_thread[thread])begin
            for(l = 0; l < bad_trap_count; l = l + 1)begin
                if(bad_trap[l] == pc)begin
                    hit_bad     = 1'b1;
                    good[l]     = 1;
                    `TOP_MOD.diag_done = 1;
`ifdef INCLUDE_SAS_TASKS
                    if(sas_def && ($bw_list(`TOP_MOD.list_handle, 1) == 0))begin//wait until drain out.
`else
                    if(sas_def)begin
`endif          $display("%0d: Info - > Hit Bad trap. spc(%0d) thread(%0d)", $time, i, l % 4);
                        `MONITOR_PATH.fail("HIT BAD TRAP");
                    end
                    else begin
                        $display("%0d: Info - > Hit Bad trap. spc(%0d) thread(%0d)", $time, i, l % 4);
                        `MONITOR_PATH.fail("HIT BAD TRAP");
                    end
                end
            end
        end
    end // if (active_thread[thread])
endtask // endtask

`ifdef INCLUDE_SAS_TASKS
task get_thread_status;
    begin
    thread_status[0] = `IFUPATH0.swl.thr0_state;
thread_status[1] = `IFUPATH0.swl.thr1_state;
thread_status[2] = `IFUPATH0.swl.thr2_state;
thread_status[3] = `IFUPATH0.swl.thr3_state;

    end
endtask // get_thread_status
`endif


    `ifdef GATE_SIM_SPARC
    assign sas_m0                = `INSTPATH0.runw_ff_u_dff_0_.d &
           (~`INSTPATH0.exu_ifu_ecc_ce_m | `INSTPATH0.trapm_ff_u_dff_0_.q);
    assign spc0_thread_id        = {`PCPATH0.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH0.ifu_fcl.thrw_reg_q_tmp_2_,
                                    `PCPATH0.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH0.ifu_fcl.thrw_reg_q_tmp_1_};
    assign spc0_rtl_pc           = `SPCPATH0.ifu_fdp.pc_w[47:0];
    `else
    assign sas_m0                = `INSTPATH0.inst_vld_m       & ~`INSTPATH0.kill_thread_m &
           ~(`INSTPATH0.exu_ifu_ecc_ce_m & `INSTPATH0.inst_vld_m & ~`INSTPATH0.trap_m);
    assign spc0_thread_id        = `PCPATH0.fcl.sas_thrid_w;
`ifndef RTL_SPU
    assign spc0_rtl_pc           = `SPCPATH0.ifu.ifu.fdp.pc_w[47:0];
`else
    assign spc0_rtl_pc           = `SPCPATH0.ifu.fdp.pc_w[47:0];
`endif
    `endif // ifdef GATE_SIM_SPARC

    reg [63:0] spc0_phy_pc_d,  spc0_phy_pc_e,  spc0_phy_pc_m,
        spc0_t0pc_s,    spc0_t1pc_s,    spc0_t2pc_s,  spc0_t3pc_s ;

    reg [3:0]  spc0_fcl_fdp_nextpcs_sel_pcf_f_l_e,
        spc0_fcl_fdp_nextpcs_sel_pcs_f_l_e,
        spc0_fcl_fdp_nextpcs_sel_pcd_f_l_e,
        spc0_fcl_fdp_nextpcs_sel_pce_f_l_e;

    wire [3:0] pcs0 = spc0_fcl_fdp_nextpcs_sel_pcs_f_l_e;
    wire [3:0] pcf0 = spc0_fcl_fdp_nextpcs_sel_pcf_f_l_e;
    wire [3:0] pcd0 = spc0_fcl_fdp_nextpcs_sel_pcd_f_l_e;
    wire [3:0] pce0 = spc0_fcl_fdp_nextpcs_sel_pce_f_l_e;

    wire [63:0]  spc0_imiss_paddr_s ;

    `ifdef  GATE_SIM_SPARC
    assign spc0_imiss_paddr_s = {`IFQDP0.itlb_ifq_paddr_s, `IFQDP0.lcl_paddr_s, 2'b0} ;
    `else
    assign spc0_imiss_paddr_s = `IFQDP0.imiss_paddr_s ;
    `endif // GATE_SIM_SPARC



    always @(posedge clk) begin
        //done
        spc0_inst_done                     <= sas_m0;

        //next pc select
        spc0_fcl_fdp_nextpcs_sel_pcs_f_l_e <= `DTUPATH0.fcl_fdp_nextpcs_sel_pcs_f_l;
        spc0_fcl_fdp_nextpcs_sel_pcf_f_l_e <= `DTUPATH0.fcl_fdp_nextpcs_sel_pcf_f_l;
        spc0_fcl_fdp_nextpcs_sel_pcd_f_l_e <= `DTUPATH0.fcl_fdp_nextpcs_sel_pcd_f_l;
        spc0_fcl_fdp_nextpcs_sel_pce_f_l_e <= `DTUPATH0.fcl_fdp_nextpcs_sel_pce_f_l;

        //pipe physical pc

        if(pcf0[0] == 0)spc0_t0pc_s          <= spc0_imiss_paddr_s;
        else if(pcs0[0] == 0)spc0_t0pc_s     <= spc0_t0pc_s;
        else if(pcd0[0] == 0)spc0_t0pc_s     <= spc0_phy_pc_e;
        else if(pce0[0] == 0)spc0_t0pc_s     <= spc0_phy_pc_m;

        if(pcf0[1] == 0)spc0_t1pc_s          <= spc0_imiss_paddr_s;
        else if(pcs0[1] == 0)spc0_t1pc_s     <= spc0_t1pc_s;
        else if(pcd0[1] == 0)spc0_t1pc_s     <= spc0_phy_pc_e;
        else if(pce0[1] == 0)spc0_t1pc_s     <= spc0_phy_pc_m;

        if(pcf0[2] == 0)spc0_t2pc_s          <= spc0_imiss_paddr_s;
        else if(pcs0[2] == 0)spc0_t2pc_s     <= spc0_t2pc_s;
        else if(pcd0[2] == 0)spc0_t2pc_s     <= spc0_phy_pc_e;
        else if(pce0[2] == 0)spc0_t2pc_s     <= spc0_phy_pc_m;

        if(pcf0[3] == 0)spc0_t3pc_s          <= spc0_imiss_paddr_s;
        else if(pcs0[3] == 0)spc0_t3pc_s     <= spc0_t3pc_s;
        else if(pcd0[3] == 0)spc0_t3pc_s     <= spc0_phy_pc_e;
        else if(pce0[3] == 0)spc0_t3pc_s     <= spc0_phy_pc_m;

        if(~`DTUPATH0.fcl_fdp_thr_s2_l[0])     spc0_phy_pc_d <= pcf0[0] ? spc0_t0pc_s : spc0_imiss_paddr_s;
        else if(~`DTUPATH0.fcl_fdp_thr_s2_l[1])spc0_phy_pc_d <= pcf0[1] ? spc0_t1pc_s : spc0_imiss_paddr_s;
        else if(~`DTUPATH0.fcl_fdp_thr_s2_l[2])spc0_phy_pc_d <= pcf0[2] ? spc0_t2pc_s : spc0_imiss_paddr_s;
        else if(~`DTUPATH0.fcl_fdp_thr_s2_l[3])spc0_phy_pc_d <= pcf0[3] ? spc0_t3pc_s : spc0_imiss_paddr_s;

        spc0_phy_pc_e   <= spc0_phy_pc_d;
        spc0_phy_pc_m   <= spc0_phy_pc_e;
        spc0_phy_pc_w   <= {{8{spc0_phy_pc_m[39]}}, spc0_phy_pc_m[39:0]};

        if(spc0_inst_done &&
                active_thread[{3'b000,spc0_thread_id[1:0]}])begin
            /*
                 if(0 & $x_checker(`DTUPATH0.pc_w))begin
                    $display("%0d: Detected unkown pc value spc(%d) thread(%x) value(%x)",
                         $time, 3'b000, spc0_thread_id[1:0], `DTUPATH0.pc_w);
                    `MONITOR_PATH.fail("Detected unkown pc");
                 end
            */
        end
    end




reg           dummy;

task trap_extract;
    reg [2048:0] pc_str;
    reg [63:0]  tmp_val;
    integer     i;
    begin
        bad_trap_count = 0;
        finish_mask    = 1;
        diag_mask      = 0;
        stub_mask      = 0;
        if($value$plusargs("finish_mask=%h", finish_mask))$display ("%t: finish_mask %h", $time, finish_mask);
        if($value$plusargs("good_trap=%s", pc_str))       $display ("%t: good_trap list %s", $time, pc_str);
        if($value$plusargs("stub_mask=%h", stub_mask))    $display ("%t: stub_mask  %h", $time, stub_mask);

        for(i = 0; i < `NUM_TILES;i = i + 1)if(finish_mask[i] === 1'bx)finish_mask[i] = 1'b0;
        if(sas_def)dummy = $bw_good_trap(1, finish_mask);
        for(i = 0; i < 8;i = i + 1) if(stub_mask[i] === 1'bx)stub_mask[i] = 1'b0;

        good_trap_count = 0;
        while ($parse (pc_str, "%h:", tmp_val))
        begin
            good_trap[good_trap_count] = tmp_val;
            $display ("%t: good_trap %h", $time, good_trap[good_trap_count]);
            good_trap_count = good_trap_count + 1;
            if (good_trap_count > `GOOD_TRAP_COUNTER)
            begin
                $display ("%t: good_trap_count more than max-count %d.", $time, `GOOD_TRAP_COUNTER);
                `MONITOR_PATH.fail("good_trap_count more than max-count");
            end
        end
        if($value$plusargs("bad_trap=%s", pc_str))$display ("%t: bad_trap list %s", $time, pc_str);
        bad_trap_count = 0;
        while ($parse (pc_str, "%h:", tmp_val))
        begin
            bad_trap[bad_trap_count] = tmp_val;
            $display ("%t: bad_trap %h", $time, bad_trap[bad_trap_count]);
            bad_trap_count = bad_trap_count + 1;
            if (bad_trap_count > `GOOD_TRAP_COUNTER)
            begin
                $display ("%t: bad_trap_count more than max-count %d.", $time,`GOOD_TRAP_COUNTER);
                `MONITOR_PATH.fail("bad_trap_count more than max-count.");
            end
        end // while ($parse (pc_str, "%h:", tmp_val))
        trap_count = good_trap_count > bad_trap_count ? good_trap_count :  bad_trap_count;

    end
endtask // trap_extract
// deceide pass or fail
reg [63:0]    rpc;
integer       ind;
//post-silicon request
reg [63:0]    last_hit [31:0];
//indicate the 2nd time hit.
reg [31:0]    hitted;
initial hitted = 0;

task check_done;
    input   [`NUM_TILES:0] cpu;
    integer       j, l;
    reg     [63:0]pc;
    reg     [9:0] i; // Tri
    // reg     [7:0] tileid;

    begin
        for(i = 0; i < `NUM_TILES; i = i + 1)
        begin
            if(cpu[i])
            begin
                // tileid = i[]
                case(i)
                    
0 : 
begin j = {i, spc0_thread_id};pc = spc0_phy_pc_w;rpc = spc0_rtl_pc;end


                endcase
                timeout[j] = 0;
                check_bad_trap(pc, i, j);
                if(active_thread[j])
                begin
                    for(l = 0; l < good_trap_count; l = l + 1)
                    begin
                        if(good_trap[l] == pc[39:0])
                        begin
                            if(sas_def && (good[j] == 0))
                                dummy = $bw_good_trap(2, j, rpc);//command thread, pc

                            if(good[j] == 0)
                                $display("Info: spc(%0x) thread(%0x) Hit Good trap", j / 4, j % 4);

                            //post-silicon debug
                            if((sas_def == 0) && finish_mask[j])
                            begin
                                if(good_flag)
                                begin
                                    if(!hitted[j])
                                    begin
                                        last_hit[j] = pc[39:0];
                                        hitted[j]   = 1;
                                    end
                                    else if(last_hit[j] == pc[39:0])
                                        good[j] = 1'b1;
                                end
                                else
                                begin
                                    good[j] = 1'b1;
                                end
                            end

                            if(sas_def && active_thread[j])
                                good[j]   = 1'b1;

                            if(sas_def && finish_mask[j])
                                good_for[j] = 1'b1;
                        end

                        if((sas_def == 0)        &&
                                (good == finish_mask) &&
                                (hit_bad == 0)        &&
                                (stub_mask == stub_good))
                        begin
                            `TOP_MOD.diag_done = 1;
                            @(posedge clk);
                            $display("%0d: Simulation -> PASS (HIT GOOD TRAP)", $time);
                            $finish;
                        end

                        if(sas_def && (good == active_thread))
                            `TOP_MOD.diag_done = 1;

                        if(sas_def)
                        begin
                            if($bw_good_trap(3, j) &&
                                    (hit_bad == 0)      &&
                                    (stub_mask == stub_good))
                            begin
                                `TOP_MOD.diag_done = 1;
                                if(`TOP_MOD.fail_flag == 1'b0)
                                begin
                                    repeat(2) @(posedge clk);
                                    $display("%0d: Simulation -> PASS (HIT GOOD TRAP)", $time);
                                    dum = $bw_sas_send(`PLI_QUIT);
                                    $finish;
                                end
                            end
                        end
                    end // for (l = 0; l < good_trap_count; l = l + 1)
                end // if (active_thread[j])
            end // if (cpu[i])
        end
    end
endtask

// get done signal;
task gen_done;
    begin
        done[0]   = spc0_inst_done;//sparc 0


    end
endtask // gen_done

reg first_rst;
initial begin
    if($value$plusargs("TIMEOUT=%d", time_tmp))max = time_tmp;
    else max = 1000;
    #20//need to wait for socket initializing.
     trap_extract;
    done    = 0;
    good    = 0;
    active_thread = 0;
    hit_bad   = 0;
    first_rst = 1;
    for(ind = 0;ind < `NUM_TILES; ind = ind + 1)timeout[ind] = 0;
end // initial begin
always @(posedge rst_l)begin
    if(first_rst)begin
        active_thread = 0;
        first_rst     = 0;
        done          = 0;
        good          = 0;
        hit_bad       = 0;
    end
end
//speed up checkeing
task check_time;
    input [9:0] head; // Tri
    input [9:0] tail;

    integer  ind;
    begin
        for(ind = head; ind < tail; ind = ind + 1)begin
            if(timeout[ind] > max && (good[ind] == 0))begin
                if((max_cycle == 0 || finish_mask[ind] == 0) && (thread_status[ind] == `THRFSM_HALT)
                  )begin
                    timeout[ind] = 0;
                end
                else begin
                    $display("Info: spc(%0d) thread(%0d) -> timeout happen", ind / 4, ind % 4);
                    `MONITOR_PATH.fail("TIMEOUT");
                end
            end
            else if(active_thread[ind] != good[ind])begin
                timeout[ind] = timeout[ind] + 1;
            end // if (finish_mask[ind] != good[ind])
        end // for (ind = head; ind < tail; ind = ind + 1)
    end
endtask // check_time

//check good trap status after threads hit the good trap.
//The reason for this is that the threads stay on halt status.
task check_good;
    begin
        if($bw_good_trap(3, 0) && (hit_bad == 0))begin
            `TOP_MOD.diag_done = 1;
            if(!`TOP_MOD.fail_flag)begin
                repeat(2) @(posedge clk);
                $display("%0d: Simulation -> PASS (HIT GOOD TRAP)", $time);
                dum = $bw_sas_send(`PLI_QUIT);
                $finish;
            end
        end
    end
endtask // check_good

//deceide whether stub done or not.
task check_stub;
    reg [3:0] i;
    begin
        for(i = 0; i < 8; i = i + 1)begin
            if(stub_mask[i] &&
                    `TOP_MOD.stub_done[i] &&
                    `TOP_MOD.stub_pass[i])stub_good[i] = 1'b1;
            else if(stub_mask[i] &&
                    `TOP_MOD.stub_done[i] &&
                    `TOP_MOD.stub_pass[i] == 0)begin
                $display("Info->Simulation terminated by stub.");
                `MONITOR_PATH.fail("HIT BAD TRAP");
            end
        end
        if (sas_def) begin
            if(stub_mask                &&
                    (stub_mask == stub_good) &&
                    (active_thread && $bw_good_trap(3, 0)   ||
                     active_thread == 0))begin
                `TOP_MOD.diag_done = 1;
                @(posedge clk);
                $display("Info->Simulation terminated by stub.");
                $display("%0d: Simulation -> PASS (HIT GOOD TRAP)", $time);
                $finish;
            end
        end
        else if ((good == finish_mask) && (stub_mask == stub_good)) begin
            `TOP_MOD.diag_done = 1;
            @(posedge clk);
            $display("Info->Simulation terminated by stub.");
            $display("%0d: Simulation -> PASS (HIT GOOD TRAP)", $time);
            $finish;
        end
    end
endtask // check_stub


//main routine of pc cmp to finish the simulation.
always @(posedge clk)begin
    if(rst_l)begin
        if(`TOP_MOD.stub_done)check_stub;
        gen_done;
        if(|done[`NUM_TILES-1:0])check_done(done);
        else if(sas_def && (good_for == finish_mask))check_good;
`ifdef INCLUDE_SAS_TASKS
        get_thread_status;
`endif
        if(active_thread[3:0])check_time(0, 4);

    end // if (rst_l)
end // always @ (posedge clk)
endmodule



// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: multicycle_mon.v
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
////////////////////////////////////////////////////////;
//
// multicycle_mon.vpal
//
// Description: Multi cyclec monitor that injects X's on  cycles that the values
//		of the long paths should not be sampled
//	Right now the signals are hand coded but eventually this file will be generated
//	based on multi cycle path list file
//
//      To add a new multicycle path add destination_pins directive
//           The key is the src pin and the value is the dest pin
//      You need to change no_of_signals accordingly
//
//      Right now, all the multicycle paths are supposed to be 2 cycles long
//           If the new path has a different length you need to specify in no_of_cycles{net} hash
//      
//      This also checks for const values like cpu id not to change during sim 
//      To add a new constant you need to populate consts hash and update no_of_consts
//
//      Run pal to get .v using: pal -r -o multicycle_mon.v multicycle_mon.vpal
////////////////////////////////////////////////////////

`include "cross_module.tmp.h"
`include "sys.h"
`include "iop.h"

`define NO_OF_SIGNALS 1



module multicycle_mon(/*AUTOARG*/
   // Inputs
   clk, rst_l
   );

   input        clk;
   input        rst_l;

   reg 		enable;
   event	start_monitors;
   integer 	cycle_count;


   initial begin
      enable = 1'b0;
      cycle_count = 0;
      if ($test$plusargs("multicycle_mon")) enable = 1'b1;
      fork
	if(enable)
	begin
         @(posedge rst_l) -> start_monitors;
         @(posedge rst_l) $display("%d: Starting mult cycle monitor\n", $time);
        end
      join
   end
   
always @(posedge clk)
begin
   cycle_count = cycle_count + 1;
end

`ifdef GATE_SIM
`else


//////////////////////////////////////////////////////////////////////////////////////////////
// Source net 1 : `SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_dtlb_tte_tag_w2[54:13]
//////////////////////////////////////////////////////////////////////////////////////////////

    // Last value on source net (for monitor message)
    reg [7:0] spc0_last_value_s1;
    
    // $time of last transition
    integer spc0_last_transition_time_s1; initial spc0_last_transition_time_s1 = 0;

    // No transitions on source net may occur until after this cycle.
    integer spc0_stable_thru_s1; initial spc0_stable_thru_s1 = 0;
    
    integer spc0_src_changed_1; initial spc0_src_changed_1 = 2  + 1;

    // Monitor source net transitions.
    reg spc0_too_soon_s1; initial spc0_too_soon_s1= 1'b0;
`ifndef RTL_SPU
    initial @start_monitors forever @(`SPARC_CORE0.sparc0.tlu.tlu.mmu_dp.tlu_dtlb_tte_tag_w2[54:13])
`else
    initial @start_monitors forever @(`SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_dtlb_tte_tag_w2[54:13])
`endif
       if(spc0_src_changed_1 == (2 +1))
       begin
          if (enable) begin
`ifndef RTL_SPU
              $display("%d: multicyclemon: net `SPARC_CORE0.sparc0.tlu.tlu.mmu_dp.tlu_dtlb_tte_tag_w2[54:13] changed\n",$time);
`else
              $display("%d: multicyclemon: net `SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_dtlb_tte_tag_w2[54:13] changed\n",$time);
`endif

`ifndef RTL_SPU
          #1 force  `SPARC_CORE0.sparc0.lsu.lsu.dtlb.tlb_wr_tte_tag[54:13] = { 42 {1'bx} } ;
`else
	      #1 force  `SPARC_CORE0.sparc0.lsu.dtlb.tlb_wr_tte_tag[54:13] = { 42 {1'bx} } ;
`endif          

              spc0_src_changed_1 = 0;


          end // if (enable)
      end // spc0_src_changed_1 == (2 +1)
      // end of initial

      always @ (negedge clk)
      begin
          if(spc0_src_changed_1 < 2)
          begin
             spc0_src_changed_1 = spc0_src_changed_1 + 1;
             if (spc0_src_changed_1 == 2) 
             begin
`ifndef RTL_SPU
                 #1 release `SPARC_CORE0.sparc0.lsu.lsu.dtlb.tlb_wr_tte_tag[54:13];
`else
                 #1 release `SPARC_CORE0.sparc0.lsu.dtlb.tlb_wr_tte_tag[54:13];
`endif                 
                 #3 spc0_src_changed_1 = 2 + 1;
	     end
          end
      end // always @ (negedge clk)
 


//////////////////////////////////////////////////////////////////////////////////////////////
// Source net 2 : `SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_itlb_tte_tag_w2[54:13]
//////////////////////////////////////////////////////////////////////////////////////////////

    // Last value on source net (for monitor message)
    reg [7:0] spc0_last_value_s2;
    
    // $time of last transition
    integer spc0_last_transition_time_s2; initial spc0_last_transition_time_s2 = 0;

    // No transitions on source net may occur until after this cycle.
    integer spc0_stable_thru_s2; initial spc0_stable_thru_s2 = 0;
    
    integer spc0_src_changed_2; initial spc0_src_changed_2 = 2  + 1;

    // Monitor source net transitions.
    reg spc0_too_soon_s2; initial spc0_too_soon_s2= 2'b0;
`ifndef RTL_SPU
    initial @start_monitors forever @(`SPARC_CORE0.sparc0.tlu.tlu.mmu_dp.tlu_itlb_tte_tag_w2[54:13])
`else
    initial @start_monitors forever @(`SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_itlb_tte_tag_w2[54:13])
`endif
       if(spc0_src_changed_2 == (2 +1))
       begin
          if (enable) begin
`ifndef RTL_SPU
              $display("%d: multicyclemon: net `SPARC_CORE0.sparc0.tlu.tlu.mmu_dp.tlu_itlb_tte_tag_w2[54:13] changed\n",$time);
`else
              $display("%d: multicyclemon: net `SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_itlb_tte_tag_w2[54:13] changed\n",$time);
`endif

`ifndef RTL_SPU
          #1 force  `SPARC_CORE0.sparc0.ifu.ifu.itlb.tlb_wr_tte_tag[54:13] = { 42 {1'bx} } ;
`else
	      #1 force  `SPARC_CORE0.sparc0.ifu.itlb.tlb_wr_tte_tag[54:13] = { 42 {1'bx} } ;
`endif          

              spc0_src_changed_2 = 0;


          end // if (enable)
      end // spc0_src_changed_2 == (2 +1)
      // end of initial

      always @ (negedge clk)
      begin
          if(spc0_src_changed_2 < 2)
          begin
             spc0_src_changed_2 = spc0_src_changed_2 + 1;
             if (spc0_src_changed_2 == 2) 
             begin
`ifndef RTL_SPU
                 #1 release `SPARC_CORE0.sparc0.ifu.ifu.itlb.tlb_wr_tte_tag[54:13];
`else
                 #1 release `SPARC_CORE0.sparc0.ifu.itlb.tlb_wr_tte_tag[54:13];
`endif                 
                 #3 spc0_src_changed_2 = 2 + 1;
	     end
          end
      end // always @ (negedge clk)
 


//////////////////////////////////////////////////////////////////////////////////////////////
// Source net 3 : `SPARC_CORE0.sparc0.ifu.errctl.ifu_exu_ecc_mask[6:0]
//////////////////////////////////////////////////////////////////////////////////////////////

    // Last value on source net (for monitor message)
    reg [7:0] spc0_last_value_s3;
    
    // $time of last transition
    integer spc0_last_transition_time_s3; initial spc0_last_transition_time_s3 = 0;

    // No transitions on source net may occur until after this cycle.
    integer spc0_stable_thru_s3; initial spc0_stable_thru_s3 = 0;
    
    integer spc0_src_changed_3; initial spc0_src_changed_3 = 2  + 1;

    // Monitor source net transitions.
    reg spc0_too_soon_s3; initial spc0_too_soon_s3= 3'b0;
`ifndef RTL_SPU
    initial @start_monitors forever @(`SPARC_CORE0.sparc0.ifu.ifu.errctl.ifu_exu_ecc_mask[6:0])
`else
    initial @start_monitors forever @(`SPARC_CORE0.sparc0.ifu.errctl.ifu_exu_ecc_mask[6:0])
`endif    
       if(spc0_src_changed_3 == (2 +1))
       begin
          if (enable) begin
              $display("%d: multicyclemon: net `SPARC_CORE0.sparc0.ifu.errctl.ifu_exu_ecc_mask[6:0] changed\n",$time);

`ifndef RTL_SPU
          #1 force  `SPARC_CORE0.sparc0.ffu.ffu.ctl.ifu_exu_ecc_mask[6:0] = { 7 {1'bx} } ;
`else
	      #1 force  `SPARC_CORE0.sparc0.ffu.ctl.ifu_exu_ecc_mask[6:0] = { 7 {1'bx} } ;
`endif

              spc0_src_changed_3 = 0;


          end // if (enable)
      end // spc0_src_changed_3 == (2 +1)
      // end of initial

      always @ (negedge clk)
      begin
          if(spc0_src_changed_3 < 2)
          begin
             spc0_src_changed_3 = spc0_src_changed_3 + 1;
             if (spc0_src_changed_3 == 2) 
             begin
`ifndef RTL_SPU
                 #1 release `SPARC_CORE0.sparc0.ffu.ffu.ctl.ifu_exu_ecc_mask[6:0];
`else
                 #1 release `SPARC_CORE0.sparc0.ffu.ctl.ifu_exu_ecc_mask[6:0];
`endif
                 #3 spc0_src_changed_3 = 2 + 1;
	     end
          end
      end // always @ (negedge clk)
 


//////////////////////////////////////////////////////////////////////////////////////////////
// Source net 4 : `SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_itlb_tte_data_w2[42:0]
//////////////////////////////////////////////////////////////////////////////////////////////

    // Last value on source net (for monitor message)
    reg [7:0] spc0_last_value_s4;
    
    // $time of last transition
    integer spc0_last_transition_time_s4; initial spc0_last_transition_time_s4 = 0;

    // No transitions on source net may occur until after this cycle.
    integer spc0_stable_thru_s4; initial spc0_stable_thru_s4 = 0;
    
    integer spc0_src_changed_4; initial spc0_src_changed_4 = 2  + 1;

    // Monitor source net transitions.
    reg spc0_too_soon_s4; initial spc0_too_soon_s4= 4'b0;
`ifndef RTL_SPU
    initial @start_monitors forever @(`SPARC_CORE0.sparc0.tlu.tlu.mmu_dp.tlu_itlb_tte_data_w2[42:0])
`else
    initial @start_monitors forever @(`SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_itlb_tte_data_w2[42:0])
`endif
       if(spc0_src_changed_4 == (2 +1))
       begin
          if (enable) begin
`ifndef RTL_SPU
              $display("%d: multicyclemon: net `SPARC_CORE0.sparc0.tlu.tlu.mmu_dp.tlu_itlb_tte_data_w2[42:0] changed\n",$time);
`else
              $display("%d: multicyclemon: net `SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_itlb_tte_data_w2[42:0] changed\n",$time);
`endif

`ifndef RTL_SPU
          #1 force  `SPARC_CORE0.sparc0.ifu.ifu.itlb.tlb_wr_tte_data[42:0] = { 43 {1'bx} } ;
`else
	      #1 force  `SPARC_CORE0.sparc0.ifu.itlb.tlb_wr_tte_data[42:0] = { 43 {1'bx} } ;
`endif          

              spc0_src_changed_4 = 0;


          end // if (enable)
      end // spc0_src_changed_4 == (2 +1)
      // end of initial

      always @ (negedge clk)
      begin
          if(spc0_src_changed_4 < 2)
          begin
             spc0_src_changed_4 = spc0_src_changed_4 + 1;
             if (spc0_src_changed_4 == 2) 
             begin
`ifndef RTL_SPU
                 #1 release `SPARC_CORE0.sparc0.ifu.ifu.itlb.tlb_wr_tte_data[42:0];
`else
                 #1 release `SPARC_CORE0.sparc0.ifu.itlb.tlb_wr_tte_data[42:0];
`endif                 
                 #3 spc0_src_changed_4 = 2 + 1;
	     end
          end
      end // always @ (negedge clk)
 


//////////////////////////////////////////////////////////////////////////////////////////////
// Source net 5 : `SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_dtlb_tte_data_w2[42:0]
//////////////////////////////////////////////////////////////////////////////////////////////

    // Last value on source net (for monitor message)
    reg [7:0] spc0_last_value_s5;
    
    // $time of last transition
    integer spc0_last_transition_time_s5; initial spc0_last_transition_time_s5 = 0;

    // No transitions on source net may occur until after this cycle.
    integer spc0_stable_thru_s5; initial spc0_stable_thru_s5 = 0;
    
    integer spc0_src_changed_5; initial spc0_src_changed_5 = 2  + 1;

    // Monitor source net transitions.
    reg spc0_too_soon_s5; initial spc0_too_soon_s5= 5'b0;
`ifndef RTL_SPU    
    initial @start_monitors forever @(`SPARC_CORE0.sparc0.tlu.tlu.mmu_dp.tlu_dtlb_tte_data_w2[42:0])
`else
    initial @start_monitors forever @(`SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_dtlb_tte_data_w2[42:0])
`endif
       if(spc0_src_changed_5 == (2 +1))
       begin
          if (enable) begin
`ifndef RTL_SPU
              $display("%d: multicyclemon: net `SPARC_CORE0.sparc0.tlu.tlu.mmu_dp.tlu_dtlb_tte_data_w2[42:0] changed\n",$time);
`else
              $display("%d: multicyclemon: net `SPARC_CORE0.sparc0.tlu.mmu_dp.tlu_dtlb_tte_data_w2[42:0] changed\n",$time);
`endif

`ifndef RTL_SPU
          #1 force  `SPARC_CORE0.sparc0.lsu.lsu.dtlb.tlb_wr_tte_data[42:0] = { 43 {1'bx} } ;
`else
	      #1 force  `SPARC_CORE0.sparc0.lsu.dtlb.tlb_wr_tte_data[42:0] = { 43 {1'bx} } ;
`endif          

              spc0_src_changed_5 = 0;


          end // if (enable)
      end // spc0_src_changed_5 == (2 +1)
      // end of initial

      always @ (negedge clk)
      begin
          if(spc0_src_changed_5 < 2)
          begin
             spc0_src_changed_5 = spc0_src_changed_5 + 1;
             if (spc0_src_changed_5 == 2) 
             begin
`ifndef RTL_SPU
                 #1 release `SPARC_CORE0.sparc0.lsu.lsu.dtlb.tlb_wr_tte_data[42:0];
`else
                 #1 release `SPARC_CORE0.sparc0.lsu.dtlb.tlb_wr_tte_data[42:0];
`endif                 
                 #3 spc0_src_changed_5 = 2 + 1;
	     end
          end
      end // always @ (negedge clk)
 


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Check for constant values not to change during simulation
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`ifndef RTL_SPU
   initial @start_monitors forever @(`SPARC_CORE0.sparc0.ifu.ifu.const_maskid[7:0])
`else
   initial @start_monitors forever @(`SPARC_CORE0.sparc0.ifu.const_maskid[7:0]) 
`endif   
       $display("%d: ERROR: multicyclemon: Value of `SPARC_CORE0.sparc0.ifu.const_maskid[7:0] changed after reset\n",$time);
`ifndef  RTL_SPU
   initial @start_monitors forever @(`SPARC_CORE0.sparc0.ifu.ifu.invctl.const_cpuid[2:0]) 
`else
   initial @start_monitors forever @(`SPARC_CORE0.sparc0.ifu.invctl.const_cpuid[2:0]) 
`endif
       $display("%d: ERROR: multicyclemon: Value of `SPARC_CORE0.sparc0.ifu.invctl.const_cpuid[2:0] changed after reset\n",$time);



   

`endif // GATESIM



/// tasks

  task fail;
    input [1023:0] comment;
    begin
      $display("%d : Simulation -> FAIL(%0s)", $time, comment);
      $finish;
    end
  endtask // fail


endmodule



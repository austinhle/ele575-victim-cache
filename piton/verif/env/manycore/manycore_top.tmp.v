// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: cmp_top.v
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
////////////////////////////////////////////////////////

`ifndef USE_TEST_TOP // don't compile if user wants to use deprecated TOPs
`include "sys.h"
`include "iop.h"
`include "cross_module.tmp.h"
`include "ifu.tmp.h"
`include "define.vh"
`include "piton_system.vh"




`timescale 1ps/1ps
module cmp_top ();

//////////////////////
// Type Declarations
//////////////////////

reg                             core_ref_clk;
reg                             io_clk;
reg                             jtag_clk;
reg                             chipset_clk_osc_p;
reg                             chipset_clk_osc_n;
reg                             chipset_clk_osc;
reg                             chipset_clk;
reg                             mem_clk;
reg                             spi_sys_clk;
reg                             chipset_passthru_clk_p;
reg                             chipset_passthru_clk_n;
reg                             passthru_clk_osc_p;
reg                             passthru_clk_osc_n;
reg                             passthru_chipset_clk_p;
reg                             passthru_chipset_clk_n;

reg                             sys_rst_n;

reg                             jtag_rst_l;
reg                             pll_rst_n;

reg                             clk_en;

reg                             pll_bypass;
reg [4:0]                       pll_rangea;
wire                            pll_lock;

reg [1:0]                       clk_mux_sel;

reg                             jtag_modesel;
reg                             jtag_datain;
wire                            jtag_dataout;

reg                             async_mux;

wire                            chipset_mem_val;
wire [`NOC_DATA_WIDTH-1:0]      chipset_mem_data;
wire                            chipset_mem_rdy;
wire                            mem_chipset_val;
wire [`NOC_DATA_WIDTH-1:0]      mem_chipset_data;
wire                            mem_chipset_rdy;

wire                            chipset_fake_iob_val;
wire [`NOC_DATA_WIDTH-1:0]      chipset_fake_iob_data;
wire                            chipset_fake_iob_rdy;
wire                            fake_iob_chipset_val;
wire [`NOC_DATA_WIDTH-1:0]      fake_iob_chipset_data;
wire                            fake_iob_chipset_rdy;

wire                            chipset_io_val;
wire [`NOC_DATA_WIDTH-1:0]      chipset_io_data;
wire                            chipset_io_rdy;
wire                            io_chipset_val;
wire [`NOC_DATA_WIDTH-1:0]      io_chipset_data;
wire                            io_chipset_rdy;

// For simulation only, monitor stuff.  Only cross-module referenced
// do not delete.
reg                             diag_done;
reg                             fail_flag;
reg [3:0]                       stub_done;
reg [3:0]                       stub_pass;

////////////////////
// Simulated Clocks
////////////////////

`ifndef USE_FAKE_PLL_AND_CLKMUX
always #5000 core_ref_clk = ~core_ref_clk;                      // 100MHz
`else
always #500 core_ref_clk = ~core_ref_clk;                       // 1000MHz
`endif

`ifndef SYNC_MUX
always #1429 io_clk = ~io_clk;                                  // 350MHz
`else
always @ * io_clk = core_ref_clk;
`endif

always #50000 jtag_clk = ~jtag_clk;                             // 10MHz

always #2500 chipset_clk_osc_p = ~chipset_clk_osc_p;            // 200MHz
always @ * chipset_clk_osc_n = ~chipset_clk_osc_p;

always #5000 chipset_clk_osc = ~chipset_clk_osc;                // 100MHz

always #2500 chipset_clk = ~chipset_clk;                        // 200MHz

always #3333 passthru_clk_osc_p = ~passthru_clk_osc_p;          // 150MHz
always @ * passthru_clk_osc_n = ~passthru_clk_osc_p; 

always #1429 passthru_chipset_clk_p = ~passthru_chipset_clk_p;  // 350MHz
always @ * passthru_chipset_clk_n = ~passthru_chipset_clk_p;

always #1000 mem_clk = ~mem_clk;                                // 500MHz

always #25000 spi_sys_clk = ~spi_sys_clk;                       // 20MHz

////////////////////////////////////////////////////////
// SIMULATED BOOT SEQUENCE
////////////////////////////////////////////////////////

initial
begin
    // These are not referenced elsewhere in this module,
    // but are cross referenced from monitor.v.pyv.  Do not
    // delete
    fail_flag = 1'b0;
    stub_done = 4'b0;
    stub_pass = 4'b0;

    // Clocks initial value
    core_ref_clk = 1'b0;
    io_clk = 1'b0;
    jtag_clk = 1'b0;
    chipset_clk_osc_p = 1'b0;
    chipset_clk_osc_n = 1'b1;
    chipset_clk_osc = 1'b0;
    chipset_clk = 1'b0;
    mem_clk = 1'b0;
    spi_sys_clk = 1'b0;
    chipset_passthru_clk_p = 1'b0;
    chipset_passthru_clk_n = 1'b1;
    passthru_clk_osc_p = 1'b0;
    passthru_clk_osc_n = 1'b1;
    passthru_chipset_clk_p = 1'b0;
    passthru_chipset_clk_n = 1'b1;

    // Resets are held low at start of boot
    sys_rst_n = 1'b0;
    jtag_rst_l = 1'b0;
    pll_rst_n = 1'b0;

    // Mostly DC signals set at start of boot
    clk_en = 1'b0;
    if ($test$plusargs("pll_en"))
    begin
        // PLL is disabled by default
        pll_bypass = 1'b0; // trin: pll_bypass is a switch in the pll; not reliable
        clk_mux_sel[1:0] = 2'b10; // selecting pll
    end
    else
    begin
        pll_bypass = 1'b1; // trin: pll_bypass is a switch in the pll; not reliable
        clk_mux_sel[1:0] = 2'b00; // selecting ref clock
    end
    // rangeA = x10 ? 5'b1 : x5 ? 5'b11110 : x2 ? 5'b10100 : x1 ? 5'b10010 : x20 ? 5'b0 : 5'b1;
    pll_rangea = 5'b00001; // 10x ref clock
    // pll_rangea = 5'b11110; // 5x ref clock
    // pll_rangea = 5'b00000; // 20x ref clock
    
    // JTAG simulation currently not supported here
    jtag_modesel = 1'b1;
    jtag_datain = 1'b0;

`ifndef SYNC_MUX
    async_mux = 1'b1;
`else
    async_mux = 1'b0;
`endif
    
    // Init JBUS model plus some ORAM stuff
    if ($test$plusargs("oram"))
    begin
        $init_jbus_model("mem.image", 1);
`ifndef __ICARUS__
        force system.chip.ctap_oram_clk_en = 1'b1;
`endif
    end
    else
    begin
        $init_jbus_model("mem.image", 0);
    end 


    // Reset PLL for 100 cycles
    repeat(100)@(posedge core_ref_clk);
    pll_rst_n = 1'b1;

    // Wait for PLL lock
    wait( pll_lock == 1'b1 );

    // After 10 cycles turn on chip-level clock enable
    repeat(10)@(posedge `CHIP_INT_CLK);
    clk_en = 1'b1;

    // After 100 cycles release reset
    repeat(100)@(posedge `CHIP_INT_CLK);
    sys_rst_n = 1'b1;
    jtag_rst_l = 1'b1;

    // Wait for SRAM init, trin: 5000 cycles is about the lowest
    repeat(5000)@(posedge `CHIP_INT_CLK);

    diag_done = 1'b1;
`ifndef PITONSYS_IOCTRL
    // Signal fake IOB to send wake up packet to first tile
    ciop_fake_iob.ok_iob = 1'b1;
`endif // endif PITONSYS_IOCTRL
end

////////////////////////////////////////////////////////
// SYNTHESIZABLE SYSTEM
// INCLUDES CHIP + CHIPSET (AND OPTIONAL PASSTHRU)
///////////////////////////////////////////////////////

system system(
`ifndef PITON_FPGA_SYNTH
    // I/O settings, just set to 
    // fastest for simulation
    .chip_io_slew(1'b1),
    .chip_io_impsel(2'b11),
`endif // endif PITON_FPGA_SYNTH

    // Clocks and resets
`ifdef PITON_CLKS_SIM
    .core_ref_clk(core_ref_clk),
    .io_clk(io_clk),
`endif // endif PITON_CLKS_SIM

`ifdef PITONSYS_INC_PASSTHRU
`ifdef PITON_PASSTHRU_CLKS_GEN
    .passthru_clk_osc_p(passthru_clk_osc_p),
    .passthru_clk_osc_n(passthru_clk_osc_n),
`else // ifndef PITON_PASSTHRU_CLKS_GEN
    .passthru_chipset_clk_p(passthru_chipset_clk_p),
    .passthru_chipset_clk_n(passthru_chipset_clk_n),
`endif // endif PITON_PASSTHRU_CLKS_GEN
`endif // endif PITON_SYS_INC_PASSTHRU

`ifdef PITON_CHIPSET_CLKS_GEN
`ifdef PITON_CHIPSET_DIFF_CLK
    .chipset_clk_osc_p(chipset_clk_osc_p),
    .chipset_clk_osc_n(chipset_clk_osc_n),
`else // ifndef PITON_CHIPSET_DIFF_CLK
    .chipset_clk_osc(chipset_clk_osc),
`endif // endif PITON_CHIPSET_DIFF_CLK
`else // ifndef PITON_CHIPSET_CLKS_GEN
    .chipset_clk(chipset_clk),
`ifndef PITONSYS_NO_MC
`ifdef PITON_FPGA_MC_DDR3
    .mc_clk(mem_clk),
`endif // endif PITON_FPGA_MC_DDR3
`endif // endif PITONSYS_NO_MC
`ifdef PITONSYS_SPI
    .spi_sys_clk(spi_sys_clk),
`endif // endif PITONSYS_SPI
`ifdef PITONSYS_INC_PASSTHRU
    .chipset_passthru_clk_p(chipset_passthru_clk_p),
    .chipset_passthru_clk_n(chipset_passthru_clk_n),
`endif // endif PITONSYS_INC_PASSTHRU
`endif // endif PITON_CHIPSET_CLKS_GEN

    .sys_rst_n(sys_rst_n),

    // Piton chip specific
`ifndef PITON_FPGA_SYNTH
    .pll_rst_n(pll_rst_n),
`endif // endif PITON_FPGA_SYNTH

`ifndef PITON_FPGA_SYNTH
    // Chip level clock enable
    .clk_en(clk_en),
`endif // endif PITON_FPGA_SYNTH

`ifndef PITON_FPGA_SYNTH
    // Chip PLL settings
    .pll_bypass(pll_bypass),
    .pll_rangea(pll_rangea),
    .pll_lock(pll_lock),
`endif // endif PITON_FPGA_SYNTH

`ifndef PITON_FPGA_SYNTH
    // Chip clock mux selection (bypass PLL or not)
    .clk_mux_sel(clk_mux_sel),
`endif // endif PITON_FPGA_SYNTH

`ifndef PITON_NO_JTAG
    // Chip JTAG
    .jtag_clk(jtag_clk),
    .jtag_rst_l(jtag_rst_l),
    .jtag_modesel(jtag_modesel),
    .jtag_datain(jtag_datain),
    .jtag_dataout(jtag_dataout),
`endif  // endif PITON_NO_JTAG

`ifndef PITON_NO_CHIP_BRIDGE
    // Chip async FIFOs enable for 
    // bridign core<->io clk domain
    .async_mux(async_mux),
`endif // endif PITON_FPGA_SYNTH

    // DRAM and I/O interfaces
`ifndef PITONSYS_NO_MC
`ifdef PITON_FPGA_MC_DDR3
    // FPGA DDR MC interface, currently not supported in simulation
    .init_calib_complete(),
    .ddr_addr(),
    .ddr_ba(),
    .ddr_cas_n(),
    .ddr_ck_n(),
    .ddr_ck_p(),
    .ddr_cke(),
    .ddr_ras_n(),
    .ddr_reset_n(),
    .ddr_we_n(),
    .ddr_dq(),
    .ddr_dqs_n(),
    .ddr_dqs_p(),
    .ddr_cs_n(),
    .ddr_dm(),
    .ddr_odt(),
`else // ifndef PITON_FPGA_MC_DDR3
    // Simulation "fake" DRAM interface
    .chipset_mem_val(chipset_mem_val),
    .chipset_mem_data(chipset_mem_data),
    .chipset_mem_rdy(chipset_mem_rdy),
    .mem_chipset_val(mem_chipset_val),
    .mem_chipset_data(mem_chipset_data),
    .mem_chipset_rdy(mem_chipset_rdy),
`endif // endif PITON_FPGA_MC_DDR3
`endif // endif PITONSYS_NO_MC

`ifdef PITONSYS_IOCTRL
`ifdef PITONSYS_UART
    // UART interface for bootloading and 
    // serial port interface.  Currently
    // not supported in simulation
    .uart_tx(),
    .uart_rx(),
`endif // endif PITONSYS_UART

`ifdef PITONSYS_SPI
    // SPI interface for boot device and disk.
    // Currently not supported in simulation
    .spi_data_in(),
    .spi_data_out(),
    .spi_clk_out(),
    .spi_cs_n(),
`endif // endif PITONSYS_SPI

`else // ifndef PITONSYS_IOCTRL
    // Fake I/O interface emulated in PLI C calls
    .chipset_fake_iob_val(chipset_fake_iob_val),
    .chipset_fake_iob_data(chipset_fake_iob_data),
    .chipset_fake_iob_rdy(chipset_fake_iob_rdy),
    .fake_iob_chipset_val(fake_iob_chipset_val),
    .fake_iob_chipset_data(fake_iob_chipset_data),
    .fake_iob_chipset_rdy(fake_iob_chipset_rdy),

    .chipset_io_val(chipset_io_val),
    .chipset_io_data(chipset_io_data),
    .chipset_io_rdy(chipset_io_rdy),
    .io_chipset_val(io_chipset_val),
    .io_chipset_data(io_chipset_data),
    .io_chipset_rdy(io_chipset_rdy), 
`endif // endif PITONSYS_IOCTRL

    // Switches
`ifdef PITON_NOC_POWER_CHIPSET_TEST
    .sw({4'bz, 4'd`PITON_NOC_POWER_CHIPSET_TEST_HOP_COUNT}),
`else // ifndef PITON_NOC_POWER_CHIPSET_TEST
    .sw(),
`endif // endif PITON_NOC_POWER_CHIPSET_TEST

    // Do not provide any functionality
    .leds()
);

///////////////////////////
// Fake Memory Controller
///////////////////////////
// input: noc2
// output: noc3
// Memory controller val/rdy interface
`ifndef PITONSYS_NO_MC
`ifndef PITON_FPGA_MC_DDR3

fake_mem_ctrl fake_mem_ctrl(
    .clk                (chipset_clk),
    .rst_n              (sys_rst_n),
    .noc_valid_in       (chipset_mem_val),
    .noc_data_in        (chipset_mem_data),
    .noc_ready_in       (chipset_mem_rdy),
    .noc_valid_out      (mem_chipset_val),
    .noc_data_out       (mem_chipset_data),
    .noc_ready_out      (mem_chipset_rdy)
);

`endif // endif PITON_FPGA_MC_DDR3
`endif // endif PITONSYS_NO_MC

////////////////////////////////////////////////////////
// Fake iobridge
////////////////////////////////////////////////////////
// input: noc1
// output: noc2
// Iob val/rdy interface
`ifndef PITONSYS_IOCTRL

ciop_fake_iob ciop_fake_iob(
    .noc_in_val        (chipset_fake_iob_val),
    .noc_in_rdy        (chipset_fake_iob_rdy),
    .noc_in_data       (chipset_fake_iob_data),

    .noc_out_val       (fake_iob_chipset_val),
    .noc_out_rdy       (fake_iob_chipset_rdy),
    .noc_out_data      (fake_iob_chipset_data),

    
.spc0_inst_done    (`TOP_MOD.monitor.pc_cmp.spc0_inst_done),
.pc_w0             (`PCPATH0.fdp.pc_w),


    .clk               (chipset_clk),
    .rst_n             (sys_rst_n)
//    .rst_n             (`SPARC_CORE0.reset_l)
);

`endif // endif PITONSYS_IOCTRL

////////////////////////////////////////////////////////
// I/O AXI splitter, needed for uart-hello-world.s
////////////////////////////////////////////////////////

iosplitter_axi_lite_updated iosplitter_axi_lite(
    .clk(chipset_clk),
    .rst(~sys_rst_n),

    .splitter_io_val(chipset_io_val),
    .splitter_io_data(chipset_io_data),
    .io_splitter_rdy(chipset_io_rdy),

    .io_splitter_val(io_chipset_val),
    .io_splitter_data(io_chipset_data),
    .splitter_io_rdy(io_chipset_rdy),

    //axi lite signals             
    //write address channel
    .m_axi_awaddr(),
    .m_axi_awvalid(),
    .m_axi_awready(1'b1),

    //write data channel
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wvalid(),
    .m_axi_wready(1'b1),

    //read address channel
    .m_axi_araddr(),
    .m_axi_arvalid(),
    .m_axi_arready(1'b1),

    //read data channel
    .m_axi_rdata(`NOC_DATA_WIDTH'hef),
    .m_axi_rresp(2'b0),
    .m_axi_rvalid(1'b1),
    .m_axi_rready(),

    //write response channel
    .m_axi_bresp(2'b0),
    .m_axi_bvalid(1'b1),
    .m_axi_bready()
);

////////////////////////////////////////////////////////
// MONITOR STUFF
////////////////////////////////////////////////////////
`ifndef DISABLE_ALL_MONITORS
    integer j;

    // Tri: slam init is taken out because it's too complicated to extend to 64 cores
    // slam_init slam_init () ;

    // The only thing that we will "slam init" is the integer register file
    //  and it is randomized. For some reason if we left it as X's some tests will fail
    
`ifndef __ICARUS__
initial begin
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
end
`endif




    // T1's TSO monitor, stripped of all L2 references
    tso_mon tso_mon(`CHIP_INT_CLK, `SPARC_CORE0.reset_l);

    // this is the T1 sparc core monitor
    monitor   monitor(
        .clk    (`CHIP_INT_CLK),
        .cmp_gclk  (`CHIP_INT_CLK),
        .rst_l     (`SPARC_CORE0.reset_l)
        );

    // L15 MONITORS
    cmp_l15_messages_mon l15_messages_mon(
        .clk (`CHIP_INT_CLK)
        );

    // DMBR MONITOR
    dmbr_mon dmbr_mon (
        .clk(`CHIP_INT_CLK)
     );

    //L2 MONITORS
    `ifdef FAKE_L2
    `else
    l2_mon l2_mon(
        .clk (`CHIP_INT_CLK)
    );
    `endif

    //only works if clk == chipset_clk
    //async_fifo_mon async_fifo_mon(
    //   .clk (core_ref_clk)
    //);

    jtag_mon jtag_mon(
        .clk (jtag_clk)
        );

    iob_mon iob_mon(
        .clk (chipset_clk)
    );
    // sas, more debug info

    // turn on sas interface after a delay
//    reg   need_sas_sparc_intf_update;
//    initial begin
//        need_sas_sparc_intf_update  = 0;
//        #12500;
//        need_sas_sparc_intf_update  = 1;
//    end // initial begin

    sas_intf  sas_intf(/*AUTOINST*/
        // Inputs
        .clk       (`CHIP_INT_CLK),      // Templated
        .rst_l     (`SPARC_CORE0.reset_l));       // Templated

    // create sas tasks
    sas_tasks sas_tasks(/*AUTOINST*/
        // Inputs
        .clk      (`CHIP_INT_CLK),      // Templated
        .rst_l        (`SPARC_CORE0.reset_l));       // Templated

    // sparc pipe flow monitor
    sparc_pipe_flow sparc_pipe_flow(/*AUTOINST*/
        // Inputs
        .clk  (`CHIP_INT_CLK));         // Templated


    // initialize client to communicate with ref model through socket
    integer   vsocket, i, list_handle;
    initial begin
        //list_handle = $bw_list(list_handle, 0);chin's change
         //if not use sas, list should not be called
        if($test$plusargs("use_sas_tasks"))begin
            list_handle = $bw_list(list_handle, 0);
                $bw_socket_init();
        end
    end

    manycore_network_mon network_mon (`CHIP_INT_CLK);

`endif // DISABLE_ALL_MONITORS
    // Alexey
    // UART monitor
    /*reg      prev_tx_state;
    always @(posedge core_ref_clk)
        prev_tx_state <= tx;

    always @(posedge core_ref_clk)
        if (prev_tx_state != tx) begin
            $display("UART: TX changed to %d at", tx, $time);
        end*/

endmodule // cmp_top

`endif

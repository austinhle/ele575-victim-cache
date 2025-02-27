// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: lsu_dcdp.v
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
//	Description:	LSU Data Cache Data Path
//			- Final Way-Select Mux.
//			- Alignment, Sign-Extension, Endianness.
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

module lsu_dcdp ( /*AUTOARG*/
   // Outputs
   so, dcache_rdata_wb_buf, mbist_dcache_data_in, 
   lsu_exu_dfill_data_w2, lsu_ffu_ld_data, stb_rdata_ramc_buf, 
   // Inputs
   rclk, si, se, rst_tri_en, dcache_rdata_wb, dcache_rparity_wb, 
   // dcache_rdata_msb_w0_m, dcache_rdata_msb_w1_m, 
   // dcache_rdata_msb_w2_m, dcache_rdata_msb_w3_m, 
   dcache_rdata_msb_m,
   lsu_bist_rsel_way_e, 
   dcache_alt_mx_sel_e, cache_way_hit_buf2, morphed_addr_m, 
   signed_ldst_byte_m, signed_ldst_hw_m, signed_ldst_w_m, 
   merge7_sel_byte0_m, merge7_sel_byte7_m, merge6_sel_byte1_m, 
   merge6_sel_byte6_m, merge5_sel_byte2_m, merge5_sel_byte5_m, 
   merge4_sel_byte3_m, merge4_sel_byte4_m, merge3_sel_byte0_m, 
   merge3_sel_byte3_m, merge3_sel_byte4_m, 
   merge3_sel_byte7_default_m, merge3_sel_byte_m, merge2_sel_byte1_m, 
   merge2_sel_byte2_m, merge2_sel_byte5_m, 
   merge2_sel_byte6_default_m, merge2_sel_byte_m, merge0_sel_byte0_m, 
   merge0_sel_byte1_m, merge0_sel_byte2_m, 
   merge0_sel_byte3_default_m, merge0_sel_byte4_m, 
   merge0_sel_byte5_m, merge0_sel_byte6_m, 
   merge0_sel_byte7_default_m, merge1_sel_byte0_m, 
   merge1_sel_byte1_m, merge1_sel_byte2_m, 
   merge1_sel_byte3_default_m, merge1_sel_byte4_m, 
   merge1_sel_byte5_m, merge1_sel_byte6_m, 
   merge1_sel_byte7_default_m, merge0_sel_byte_1h_m, 
   merge1_sel_byte_1h_m, merge1_sel_byte_2h_m, stb_rdata_ramc
   ) ;	

   input rclk;
   input si;
   input se;
   output so;
   input  rst_tri_en;
   
input  [63:0]  dcache_rdata_wb;
output [63:0]  dcache_rdata_wb_buf;

input [7:0] dcache_rparity_wb;
output [71:0] mbist_dcache_data_in;

output [63:0]		lsu_exu_dfill_data_w2; 	// bypass data - d$ fill or hit
output [63:0]		lsu_ffu_ld_data ;	      // ld data to frf
   

//=========================================
//dc_fill CP
//=========================================
   // input [7:0]           dcache_rdata_msb_w0_m;    //from D$
   // input [7:0]           dcache_rdata_msb_w1_m;    //from D$
   // input [7:0]           dcache_rdata_msb_w2_m;    //from D$
   // input [7:0]           dcache_rdata_msb_w3_m;    //from D$
   input [`L1D_WAY_COUNT*8-1:0]           dcache_rdata_msb_m;    //from D$

  wire [7:0]           dcache_rdata_msb_w0_m = dcache_rdata_msb_m[((0+1)*8)-1 -: 8];


  wire [7:0]           dcache_rdata_msb_w1_m = dcache_rdata_msb_m[((1+1)*8)-1 -: 8];


  wire [7:0]           dcache_rdata_msb_w2_m = dcache_rdata_msb_m[((2+1)*8)-1 -: 8];


  wire [7:0]           dcache_rdata_msb_w3_m = dcache_rdata_msb_m[((3+1)*8)-1 -: 8];




   input [`L1D_WAY_COUNT-1:0]           lsu_bist_rsel_way_e;     //from qdp2

   input                 dcache_alt_mx_sel_e;
   input [`L1D_WAY_COUNT-1:0]           cache_way_hit_buf2;    //from dtlb
   
   input [7:0]           morphed_addr_m;  //from dctl

   input          signed_ldst_byte_m;    //from dctl
//   input          unsigned_ldst_byte_m;  //from dctl 
   input          signed_ldst_hw_m;      //from dctl
//   input          unsigned_ldst_hw_m;    //from dctl
   input          signed_ldst_w_m;       //from dctl
//   input          unsigned_ldst_w_m;     //from dctl

input                   merge7_sel_byte0_m;
input                   merge7_sel_byte7_m;
   
input                   merge6_sel_byte1_m;
input                   merge6_sel_byte6_m;

input                   merge5_sel_byte2_m;   
input                   merge5_sel_byte5_m;

input                   merge4_sel_byte3_m;
input                   merge4_sel_byte4_m;

input                   merge3_sel_byte0_m;
input                   merge3_sel_byte3_m;
input                   merge3_sel_byte4_m;
input                   merge3_sel_byte7_default_m;
input                   merge3_sel_byte_m ;

input                   merge2_sel_byte1_m;
input                   merge2_sel_byte2_m;
input                   merge2_sel_byte5_m;
input                   merge2_sel_byte6_default_m;
input                   merge2_sel_byte_m ;

input                   merge0_sel_byte0_m, merge0_sel_byte1_m;
input                   merge0_sel_byte2_m, merge0_sel_byte3_default_m;
   
input                   merge0_sel_byte4_m, merge0_sel_byte5_m;
input                   merge0_sel_byte6_m, merge0_sel_byte7_default_m;
                                                               
input                   merge1_sel_byte0_m, merge1_sel_byte1_m;
input                   merge1_sel_byte2_m, merge1_sel_byte3_default_m;
input                   merge1_sel_byte4_m, merge1_sel_byte5_m;
input                   merge1_sel_byte6_m, merge1_sel_byte7_default_m; 

input			             merge0_sel_byte_1h_m ;
   
input			             merge1_sel_byte_1h_m, merge1_sel_byte_2h_m ;

   input [14:9]        stb_rdata_ramc;
   output [14:9]       stb_rdata_ramc_buf;
   
//wire   [3:1]           lsu_byp_byte_zero_extend ; // zero-extend for bypass bytes 7-1
reg   [7:1]           lsu_byp_byte_sign_extend ; // sign-extend by 1 for byp bytes 7-1
   
wire	[7:0]		byte0,byte1,byte2,byte3;
wire	[7:0]		byte4,byte5,byte6,byte7;
//wire [3:1] zero_extend_g;
wire [7:1] sign_extend_g;

wire	[7:0]		align_byte3 ;
wire	[7:0]		align_byte2 ;
wire	[7:0]		align_byte1_1h,align_byte1_2h;
wire	[7:0]		align_byte0_1h,align_byte0_2h ;
wire	[63:0]	align_byte ;


wire                   merge7_sel_byte0;
wire                   merge7_sel_byte7;
   
wire                   merge6_sel_byte1;
wire                   merge6_sel_byte6;

wire                   merge5_sel_byte2;   
wire                   merge5_sel_byte5;

wire                   merge4_sel_byte3;
wire                   merge4_sel_byte4;

wire                   merge3_sel_byte0;
wire                   merge3_sel_byte3;
wire                   merge3_sel_byte4;
wire                   merge3_sel_byte7;
wire                   merge3_sel_byte ;

wire                   merge2_sel_byte1;
wire                   merge2_sel_byte2;
wire                   merge2_sel_byte5;
wire                   merge2_sel_byte6;
wire                   merge2_sel_byte ;

wire                   merge0_sel_byte0, merge0_sel_byte1;
wire                   merge0_sel_byte2, merge0_sel_byte3;
wire                   merge0_sel_byte4, merge0_sel_byte5;
wire                   merge0_sel_byte6, merge0_sel_byte7;
wire                   merge1_sel_byte0, merge1_sel_byte1;
wire                   merge1_sel_byte2, merge1_sel_byte3;
wire                   merge1_sel_byte4, merge1_sel_byte5;
wire                   merge1_sel_byte6, merge1_sel_byte7; 

wire			              merge0_sel_byte_1h ;
wire			              merge1_sel_byte_1h, merge1_sel_byte_2h ;

   wire       clk;
   assign     clk = rclk;

   assign     stb_rdata_ramc_buf[14:9] = stb_rdata_ramc[14:9];
   
//=========================================================================================
//	Alignment of Fill Data
//=========================================================================================

// Alignment needs to be done for following reasons :
// - Write of data to irf on ld hit in l1.
// - Write of data to irf on ld fill to l1 after miss in l1.
// - Store of irf data to memory.
//	- Data must be aligned before write to stb.
//	- If data is bypassed from stb by ld then it will
//	need realignment thru dfq i.e., it looks like a fill.
// This applies to data either read from the dcache (hit) or dfq(fill on miss). 


assign	byte7[7:0] = dcache_rdata_wb[63:56];
assign	byte6[7:0] = dcache_rdata_wb[55:48];
assign	byte5[7:0] = dcache_rdata_wb[47:40];
assign	byte4[7:0] = dcache_rdata_wb[39:32];
assign	byte3[7:0] = dcache_rdata_wb[31:24];
assign	byte2[7:0] = dcache_rdata_wb[23:16];
assign	byte1[7:0] = dcache_rdata_wb[15:8];
assign	byte0[7:0] = dcache_rdata_wb[7:0];

//assign	zero_extend_g[3:1] = lsu_byp_byte_zero_extend[3:1] ;
assign	sign_extend_g[7:1] = lsu_byp_byte_sign_extend[7:1] ;

//buffer
   assign     dcache_rdata_wb_buf[63:0] = dcache_rdata_wb[63:0];
   assign     mbist_dcache_data_in[71:0] = {dcache_rdata_wb_buf[63:0], dcache_rparity_wb[7:0]};

// Final endian/justified/sign-extend Byte 0.
//assign	align_byte0_1h[7:0]
//	= merge0_sel_byte0 ? byte0[7:0] :
//		  merge0_sel_byte1 ? byte1[7:0] :
//			  merge0_sel_byte2 ? byte2[7:0] :
//				  merge0_sel_byte3 ?  byte3[7:0] :
//					  8'hxx ;

   wire       merge0_sel_byte0_mxsel0, merge0_sel_byte1_mxsel1, merge0_sel_byte2_mxsel2, merge0_sel_byte3_mxsel3;
   assign     merge0_sel_byte0_mxsel0 = merge0_sel_byte0 & ~rst_tri_en;
   assign     merge0_sel_byte1_mxsel1 = merge0_sel_byte1 & ~rst_tri_en;
   assign     merge0_sel_byte2_mxsel2 = merge0_sel_byte2 & ~rst_tri_en;
   assign     merge0_sel_byte3_mxsel3 = merge0_sel_byte3 |  rst_tri_en;
   
mux4ds #(8) align_byte0_1h_mx (
      .in0 (byte0[7:0]),
      .in1 (byte1[7:0]), 
      .in2 (byte2[7:0]),
      .in3 (byte3[7:0]),
      .sel0(merge0_sel_byte0_mxsel0),
      .sel1(merge0_sel_byte1_mxsel1),
      .sel2(merge0_sel_byte2_mxsel2),
      .sel3(merge0_sel_byte3_mxsel3),
      .dout(align_byte0_1h[7:0])
);
                             
//assign	align_byte0_2h[7:0]
//	= merge0_sel_byte4 ? byte4[7:0] :
//		  merge0_sel_byte5 ? byte5[7:0] :
//			  merge0_sel_byte6 ? byte6[7:0] :
//				  merge0_sel_byte7 ? byte7[7:0] :
//					  8'hxx ;

   wire       merge0_sel_byte4_mxsel0, merge0_sel_byte5_mxsel1, merge0_sel_byte6_mxsel2, merge0_sel_byte7_mxsel3;
   assign     merge0_sel_byte4_mxsel0 = merge0_sel_byte4 & ~rst_tri_en;
   assign     merge0_sel_byte5_mxsel1 = merge0_sel_byte5 & ~rst_tri_en;
   assign     merge0_sel_byte6_mxsel2 = merge0_sel_byte6 & ~rst_tri_en;
   assign     merge0_sel_byte7_mxsel3 = merge0_sel_byte7 |  rst_tri_en;
   
mux4ds #(8) align_byte0_2h_mx (
      .in0 (byte4[7:0]),
      .in1 (byte5[7:0]), 
      .in2 (byte6[7:0]),
      .in3 (byte7[7:0]),
      .sel0(merge0_sel_byte4_mxsel0),
      .sel1(merge0_sel_byte5_mxsel1),
      .sel2(merge0_sel_byte6_mxsel2),
      .sel3(merge0_sel_byte7_mxsel3),
      .dout(align_byte0_2h[7:0])
);
   
// No sign-extension or zero-extension for byte0
//assign	align_byte[7:0]	
//	= merge0_sel_byte_1h ? align_byte0_1h[7:0] :
//					align_byte0_2h[7:0] ;
   
   assign align_byte[7:0] = merge0_sel_byte_1h ? align_byte0_1h[7:0] :
                                                 align_byte0_2h[7:0];
   

// Final endian/justified/sign-extend Byte 1.
// *** The path thru byte1 is the most critical ***
//assign	align_byte1_1h[7:0]
//	= merge1_sel_byte0 ? byte0[7:0] :
//		  merge1_sel_byte1 ? byte1[7:0] :
//			  merge1_sel_byte2 ? byte2[7:0] :
//				  merge1_sel_byte3 ? byte3[7:0] :
//						8'hxx ;

   wire       merge1_sel_byte0_mxsel0, merge1_sel_byte1_mxsel1, merge1_sel_byte2_mxsel2, merge1_sel_byte3_mxsel3;
   assign     merge1_sel_byte0_mxsel0 = merge1_sel_byte0 & ~rst_tri_en;
   assign     merge1_sel_byte1_mxsel1 = merge1_sel_byte1 & ~rst_tri_en;
   assign     merge1_sel_byte2_mxsel2 = merge1_sel_byte2 & ~rst_tri_en;
   assign     merge1_sel_byte3_mxsel3 = merge1_sel_byte3 |  rst_tri_en;
   
mux4ds #(8) align_byte1_1h_mx (
    .in0 (byte0[7:0]),
    .in1 (byte1[7:0]),
    .in2 (byte2[7:0]), 
    .in3 (byte3[7:0]),
    .sel0(merge1_sel_byte0_mxsel0),
    .sel1(merge1_sel_byte1_mxsel1),
    .sel2(merge1_sel_byte2_mxsel2),
    .sel3(merge1_sel_byte3_mxsel3),
    .dout(align_byte1_1h[7:0])
);
      
//assign	align_byte1_2h[7:0]
//	= merge1_sel_byte4 ? byte4[7:0] :
//		  merge1_sel_byte5 ? byte5[7:0] :
//			  merge1_sel_byte6 ? byte6[7:0] :
//					merge1_sel_byte7 ? byte7[7:0] :
//						8'hxx ; 

   wire       merge1_sel_byte4_mxsel0, merge1_sel_byte5_mxsel1, merge1_sel_byte6_mxsel2, merge1_sel_byte7_mxsel3;
   assign     merge1_sel_byte4_mxsel0 = merge1_sel_byte4 & ~rst_tri_en;
   assign     merge1_sel_byte5_mxsel1 = merge1_sel_byte5 & ~rst_tri_en;
   assign     merge1_sel_byte6_mxsel2 = merge1_sel_byte6 & ~rst_tri_en;
   assign     merge1_sel_byte7_mxsel3 = merge1_sel_byte7 |  rst_tri_en;

mux4ds #(8) align_byte1_2h_mx (
    .in0 (byte4[7:0]),
    .in1 (byte5[7:0]),
    .in2 (byte6[7:0]), 
    .in3 (byte7[7:0]),
    .sel0(merge1_sel_byte4_mxsel0),
    .sel1(merge1_sel_byte5_mxsel1),
    .sel2(merge1_sel_byte6_mxsel2),
    .sel3(merge1_sel_byte7_mxsel3),
    .dout(align_byte1_2h[7:0])
);
   
//assign	align_byte[15:8] = 	
//	zero_extend_g[1] ? 8'h00 :
//		sign_extend_g[1] ? 8'hff :
//			merge1_sel_byte_1h ? align_byte1_1h[7:0] :
//				merge1_sel_byte_2h ? align_byte1_2h[7:0] :
//						8'hxx ;

//mux4ds #(8) align_byte1_mx (
//    .in0 (8'h00),
//    .in1 (8'hff),
//    .in2 (align_byte1_1h[7:0]), 
//    .in3 (align_byte1_2h[7:0]),
//    .sel0(zero_extend_g[1]),
//    .sel1(sign_extend_g[1]),
//    .sel2(merge1_sel_byte_1h),
//    .sel3(merge1_sel_byte_2h),
//    .dout(align_byte[15:8])
//);

   //change to aoi from pass gate
   //don't need zero_extend
   
assign  align_byte[15:8] =
 (sign_extend_g[1] ? 8'hff : 8'h00) |
 (merge1_sel_byte_1h ? align_byte1_1h[7:0] : 8'h00) |
 (merge1_sel_byte_2h ? align_byte1_2h[7:0] : 8'h00);
 
// Final endian/justified/sign-extend Byte 2.
//assign	align_byte2[7:0]
//	= merge2_sel_byte1 ? byte1[7:0] :
//		  merge2_sel_byte2 ? byte2[7:0] :
//					merge2_sel_byte5 ? byte5[7:0] :
//           merge2_sel_byte6 ?  byte6[7:0] :
//							8'hxx ;

   wire       merge2_sel_byte1_mxsel0, merge2_sel_byte2_mxsel1, merge2_sel_byte5_mxsel2, merge2_sel_byte6_mxsel3;
   assign     merge2_sel_byte1_mxsel0 = merge2_sel_byte1 & ~rst_tri_en;
   assign     merge2_sel_byte2_mxsel1 = merge2_sel_byte2 & ~rst_tri_en;
   assign     merge2_sel_byte5_mxsel2 = merge2_sel_byte5 & ~rst_tri_en;
   assign     merge2_sel_byte6_mxsel3 = merge2_sel_byte6 |  rst_tri_en;
   
mux4ds #(8) align_byte2_1st_mx (
         .in0 (byte1[7:0]),
         .in1 (byte2[7:0]),
         .in2 (byte5[7:0]),
         .in3 (byte6[7:0]),
         .sel0(merge2_sel_byte1_mxsel0),
         .sel1(merge2_sel_byte2_mxsel1),
         .sel2(merge2_sel_byte5_mxsel2),
         .sel3(merge2_sel_byte6_mxsel3),
         .dout(align_byte2[7:0])                     
                                );
   
//assign	align_byte[23:16] = 	
//	zero_extend_g[2] ? 8'h00 :
//		sign_extend_g[2] ? 8'hff :
//				merge2_sel_byte ? align_byte2[7:0] :
//								8'hxx ;

//mux3ds #(8) align_byte2_2nd_mx  (
//         .in0 (8'h00),
//         .in1 (8'hff),
//         .in2 (align_byte2[7:0]),
//         .sel0(zero_extend_g[2]),
//         .sel1(sign_extend_g[2]),
//         .sel2(merge2_sel_byte),
//         .dout(align_byte[23:16])
//                                      );

assign    align_byte[23:16] =
( sign_extend_g[2] ? 8'hff : 8'h00) |
(  merge2_sel_byte ? align_byte2[7:0] : 8'h00);
                                 
// Final endian/justified/sign-extend Byte 3.
//assign	align_byte3[7:0]
//	= merge3_sel_byte0 ? byte0[7:0] :
//			merge3_sel_byte3 ? byte3[7:0] :
//				merge3_sel_byte4 ? byte4[7:0] :
// 				merge3_sel_byte7 ? byte7[7:0] :
//					  8'hxx ;

   wire       merge3_sel_byte0_mxsel0, merge3_sel_byte3_mxsel1, merge3_sel_byte4_mxsel2, merge3_sel_byte7_mxsel3;
   assign     merge3_sel_byte0_mxsel0 = merge3_sel_byte0 & ~rst_tri_en;
   assign     merge3_sel_byte3_mxsel1 = merge3_sel_byte3 & ~rst_tri_en;
   assign     merge3_sel_byte4_mxsel2 = merge3_sel_byte4 & ~rst_tri_en;
   assign     merge3_sel_byte7_mxsel3 = merge3_sel_byte7 |  rst_tri_en;
   
mux4ds #(8) align_byte3_1st_mx (
         .in0 (byte0[7:0]),
         .in1 (byte3[7:0]),
         .in2 (byte4[7:0]),
         .in3 (byte7[7:0]),
         .sel0(merge3_sel_byte0_mxsel0),
         .sel1(merge3_sel_byte3_mxsel1),
         .sel2(merge3_sel_byte4_mxsel2),
         .sel3(merge3_sel_byte7_mxsel3),
         .dout(align_byte3[7:0])
                                     );
   
//assign	align_byte[31:24] =	
//	zero_extend_g[3] ? 8'h00 :
//		sign_extend_g[3] ? 8'hff :
//			merge3_sel_byte ? align_byte3[7:0] :
//				8'hxx ;

//mux3ds #(8) align_byte3_2nd_mx (
//         .in0 (8'h00),
//         .in1 (8'hff), 
//         .in2 (align_byte3[7:0]),
//         .sel0(zero_extend_g[3]),
//         .sel1(sign_extend_g[3]),
//         .sel2(merge3_sel_byte),
//         .dout(align_byte[31:24])
//                                     );

assign    align_byte[31:24] =
  (sign_extend_g[3] ? 8'hff : 8'h00 ) |
  (merge3_sel_byte  ?  align_byte3[7:0] : 8'h00);
        
// Final endian/justified/sign-extend Byte 4.
//assign	align_byte[39:32]
//	= zero_extend_g[4] ? 8'h00 :
//		 sign_extend_g[4] ? 8'hff :
//       merge4_sel_byte3 ? byte3[7:0] : 
//         merge4_sel_byte4 ? byte4[7:0] : 
//           8'hxx;

//mux4ds #(8) align_byte4_mx (
//        .in0 (8'h00),
//        .in1 (8'hff),
//        .in2 (byte3[7:0]),
//        .in3 (byte4[7:0]),
//        .sel0(zero_extend_g[4]),
//        .sel1(sign_extend_g[4]),
//        .sel2(merge4_sel_byte3),
//        .sel3(merge4_sel_byte4),
//        .dout(align_byte[39:32])
//                                 );

assign align_byte[39:32] = 
  (sign_extend_g[4] ? 8'hff : 8'h00) |
  (merge4_sel_byte3 ? byte3[7:0] : 8'h00) |
  (merge4_sel_byte4 ? byte4[7:0] : 8'h00);
   
// Final endian/justified/sign-extend Byte 5.
//assign	align_byte[47:40]
//  = zero_extend_g[5] ? 8'h00 :
//		  sign_extend_g[5] ? 8'hff :
//	      merge5_sel_byte2 ? byte2[7:0] : 
//          merge5_sel_byte5 ? byte5[7:0] :
//            8'hxx ;

//mux4ds #(8) align_byte5_mx (
//        .in0 (8'h00),
//        .in1 (8'hff),
//        .in2 (byte2[7:0]),
//        .in3 (byte5[7:0]),
//        .sel0(zero_extend_g[5]),
//        .sel1(sign_extend_g[5]),
//        .sel2(merge5_sel_byte2),
//        .sel3(merge5_sel_byte5),
//        .dout(align_byte[47:40])
//                                 );
 
assign align_byte[47:40] =
 (sign_extend_g[5] ? 8'hff : 8'h00) |
 (merge5_sel_byte2 ? byte2[7:0] : 8'h00) |
 (merge5_sel_byte5 ? byte5[7:0] : 8'h00);
   
 
// Final endian/justified/sign-extend Byte 6.
//assign	align_byte[55:48]
//  = zero_extend_g[6] ? 8'h00 :
//		  sign_extend_g[6] ? 8'hff :     
//	      merge6_sel_byte1 ? byte1[7:0] : 
//         merge6_sel_byte6 ? byte6[7:0] :
//            8'hxx ;

//mux4ds #(8) align_byte6_mx (
//        .in0 (8'h00),
//        .in1 (8'hff),
//        .in2 (byte1[7:0]),
//        .in3 (byte6[7:0]),
//        .sel0(zero_extend_g[6]),
//        .sel1(sign_extend_g[6]),
//        .sel2(merge6_sel_byte1),
//        .sel3(merge6_sel_byte6),
//        .dout(align_byte[55:48])
//                                 );

assign  align_byte[55:48] = 
 (sign_extend_g[6] ? 8'hff : 8'h00) |
 (merge6_sel_byte1 ? byte1[7:0] : 8'h00) |
 (merge6_sel_byte6 ? byte6[7:0] : 8'h00);
       
 
// Final endian/justified/sign-extend Byte 7.
//assign	align_byte[63:56] =	
//	zero_extend_g[7] ? 8'h00 :
//		sign_extend_g[7] ? 8'hff :
//			merge7_sel_byte0 ? byte0[7:0] :
//  			merge7_sel_byte7 ? byte7[7:0] :
//					8'hxx ;

//mux4ds #(8) align_byte7_mx (
//        .in0 (8'h00),
//        .in1 (8'hff),
//        .in2 (byte0[7:0]),
//        .in3 (byte7[7:0]),
//        .sel0(zero_extend_g[7]),
//        .sel1(sign_extend_g[7]),
//        .sel2(merge7_sel_byte0),
//        .sel3(merge7_sel_byte7),
//        .dout(align_byte[63:56])
//                                 );

assign align_byte[63:56] =
  (sign_extend_g[7] ?  8'hff : 8'h00 ) |
  (merge7_sel_byte0 ?  byte0[7:0] : 8'h00) |
  (merge7_sel_byte7 ?  byte7[7:0] : 8'h00);
   
//====================================================
//dc_fill CP sign/zero control signals
//====================================================
   // wire [7:0] ld_data_msb_w0_m;
   // wire [7:0] ld_data_msb_w1_m;
   // wire [7:0] ld_data_msb_w2_m;
   // wire [7:0] ld_data_msb_w3_m;

   // wire [7:0] ld_data_msb_w0_g;
   // wire [7:0] ld_data_msb_w1_g;
   // wire [7:0] ld_data_msb_w2_g;
   // wire [7:0] ld_data_msb_w3_g;
   
// assign ld_data_msb_w0_m[7:0] = dcache_rdata_msb_w0_m[7:0];
// assign ld_data_msb_w1_m[7:0] = dcache_rdata_msb_w1_m[7:0];
// assign ld_data_msb_w2_m[7:0] = dcache_rdata_msb_w2_m[7:0];
// assign ld_data_msb_w3_m[7:0] = dcache_rdata_msb_w3_m[7:0];

  wire [7:0] ld_data_msb_w0_m;
  reg [7:0] ld_data_msb_w0_g;
  assign ld_data_msb_w0_m[7:0] = dcache_rdata_msb_w0_m[7:0];


  wire [7:0] ld_data_msb_w1_m;
  reg [7:0] ld_data_msb_w1_g;
  assign ld_data_msb_w1_m[7:0] = dcache_rdata_msb_w1_m[7:0];


  wire [7:0] ld_data_msb_w2_m;
  reg [7:0] ld_data_msb_w2_g;
  assign ld_data_msb_w2_m[7:0] = dcache_rdata_msb_w2_m[7:0];


  wire [7:0] ld_data_msb_w3_m;
  reg [7:0] ld_data_msb_w3_g;
  assign ld_data_msb_w3_m[7:0] = dcache_rdata_msb_w3_m[7:0];


   
// dff_s #(32) ld_data_msb_stgg (
//         .din    ({ld_data_msb_w0_m[7:0], ld_data_msb_w1_m[7:0], ld_data_msb_w2_m[7:0], ld_data_msb_w3_m[7:0]}),
//         .q      ({ld_data_msb_w0_g[7:0], ld_data_msb_w1_g[7:0], ld_data_msb_w2_g[7:0], ld_data_msb_w3_g[7:0]}),
//         .clk    (clk),
//         .se     (se),       .si (),          .so ()
//         );

always @ (posedge clk)
begin

  ld_data_msb_w0_g[7:0] <= ld_data_msb_w0_m[7:0];


  ld_data_msb_w1_g[7:0] <= ld_data_msb_w1_m[7:0];


  ld_data_msb_w2_g[7:0] <= ld_data_msb_w2_m[7:0];


  ld_data_msb_w3_g[7:0] <= ld_data_msb_w3_m[7:0];


end

   wire [`L1D_WAY_COUNT-1:0] dcache_alt_rsel_way_m;
   wire       dcache_alt_mx_sel_m;
   
dff_s #(`L1D_WAY_COUNT+1) dcache_alt_stgm  (
        .din    ({lsu_bist_rsel_way_e[`L1D_WAY_COUNT-1:0],  dcache_alt_mx_sel_e}),
        .q      ({dcache_alt_rsel_way_m[`L1D_WAY_COUNT-1:0], dcache_alt_mx_sel_m}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

   wire [`L1D_WAY_COUNT-1:0] dcache_alt_rsel_way_g;
   wire       dcache_alt_mx_sel_g;
   
dff_s #(`L1D_WAY_COUNT+1) dcache_alt_stgg  (
        .din    ({dcache_alt_rsel_way_m[`L1D_WAY_COUNT-1:0],  dcache_alt_mx_sel_m}),
        .q      ({dcache_alt_rsel_way_g[`L1D_WAY_COUNT-1:0],  dcache_alt_mx_sel_g}),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );
   wire [`L1D_WAY_COUNT-1:0] cache_way_mx_sel;
   
   assign     cache_way_mx_sel [`L1D_WAY_COUNT-1:0] = dcache_alt_mx_sel_g ? dcache_alt_rsel_way_g[`L1D_WAY_COUNT-1:0] : cache_way_hit_buf2[`L1D_WAY_COUNT-1:0];

//   wire [7:0] align_bytes_msb;
   
//mux4ds  #(8) align_bytes_msb_mux (
//        .in0    (ld_data_msb_w0_g[7:0]),
//        .in1    (ld_data_msb_w1_g[7:0]),
//        .in2    (ld_data_msb_w2_g[7:0]),
//        .in3    (ld_data_msb_w3_g[7:0]),
//        .sel0   (cache_way_mx_sel[0]),  
//        .sel1   (cache_way_mx_sel[1]),
//        .sel2   (cache_way_mx_sel[2]),  
//        .sel3   (cache_way_mx_sel[3]),
//        .dout   (align_bytes_msb[7:0])
//);

   wire       signed_ldst_byte_g;
   wire       signed_ldst_hw_g;
   wire       signed_ldst_w_g;
   
dff_s #(3) ldst_size_stgg(
 .din    ({signed_ldst_byte_m, signed_ldst_hw_m, signed_ldst_w_m}),
 .q      ({signed_ldst_byte_g, signed_ldst_hw_g, signed_ldst_w_g}),
 .clk    (clk),
 .se     (se),       .si (),          .so ()
);

wire [7:0] morphed_addr_g;
   
dff_s #(8) stgg_morphadd(
        .din    (morphed_addr_m[7:0]),
        .q      (morphed_addr_g[7:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

   // wire       sign_bit_w0_g, sign_bit_w1_g, sign_bit_w2_g, sign_bit_w3_g;

// assign  sign_bit_w0_g =
//   (morphed_addr_g[0] & ld_data_msb_w0_g[7]) |
//   (morphed_addr_g[1] & ld_data_msb_w0_g[6]) |
//   (morphed_addr_g[2] & ld_data_msb_w0_g[5]) |
//   (morphed_addr_g[3] & ld_data_msb_w0_g[4]) |
//   (morphed_addr_g[4] & ld_data_msb_w0_g[3]) |
//   (morphed_addr_g[5] & ld_data_msb_w0_g[2]) |
//   (morphed_addr_g[6] & ld_data_msb_w0_g[1]) |
//   (morphed_addr_g[7] & ld_data_msb_w0_g[0]) ;

// assign  sign_bit_w1_g =
//   (morphed_addr_g[0] & ld_data_msb_w1_g[7]) |
//   (morphed_addr_g[1] & ld_data_msb_w1_g[6]) |
//   (morphed_addr_g[2] & ld_data_msb_w1_g[5]) |
//   (morphed_addr_g[3] & ld_data_msb_w1_g[4]) |
//   (morphed_addr_g[4] & ld_data_msb_w1_g[3]) |
//   (morphed_addr_g[5] & ld_data_msb_w1_g[2]) |
//   (morphed_addr_g[6] & ld_data_msb_w1_g[1]) |
//   (morphed_addr_g[7] & ld_data_msb_w1_g[0]) ;

// assign  sign_bit_w2_g =
//   (morphed_addr_g[0] & ld_data_msb_w2_g[7]) |
//   (morphed_addr_g[1] & ld_data_msb_w2_g[6]) |
//   (morphed_addr_g[2] & ld_data_msb_w2_g[5]) |
//   (morphed_addr_g[3] & ld_data_msb_w2_g[4]) |
//   (morphed_addr_g[4] & ld_data_msb_w2_g[3]) |
//   (morphed_addr_g[5] & ld_data_msb_w2_g[2]) |
//   (morphed_addr_g[6] & ld_data_msb_w2_g[1]) |
//   (morphed_addr_g[7] & ld_data_msb_w2_g[0]) ;

// assign  sign_bit_w3_g =
//   (morphed_addr_g[0] & ld_data_msb_w3_g[7]) |
//   (morphed_addr_g[1] & ld_data_msb_w3_g[6]) |
//   (morphed_addr_g[2] & ld_data_msb_w3_g[5]) |
//   (morphed_addr_g[3] & ld_data_msb_w3_g[4]) |
//   (morphed_addr_g[4] & ld_data_msb_w3_g[3]) |
//   (morphed_addr_g[5] & ld_data_msb_w3_g[2]) |
//   (morphed_addr_g[6] & ld_data_msb_w3_g[1]) |
//   (morphed_addr_g[7] & ld_data_msb_w3_g[0]) ;


  wire  sign_bit_w0_g =
    (morphed_addr_g[0] & ld_data_msb_w0_g[7]) |
    (morphed_addr_g[1] & ld_data_msb_w0_g[6]) |
    (morphed_addr_g[2] & ld_data_msb_w0_g[5]) |
    (morphed_addr_g[3] & ld_data_msb_w0_g[4]) |
    (morphed_addr_g[4] & ld_data_msb_w0_g[3]) |
    (morphed_addr_g[5] & ld_data_msb_w0_g[2]) |
    (morphed_addr_g[6] & ld_data_msb_w0_g[1]) |
    (morphed_addr_g[7] & ld_data_msb_w0_g[0]) ;


  wire  sign_bit_w1_g =
    (morphed_addr_g[0] & ld_data_msb_w1_g[7]) |
    (morphed_addr_g[1] & ld_data_msb_w1_g[6]) |
    (morphed_addr_g[2] & ld_data_msb_w1_g[5]) |
    (morphed_addr_g[3] & ld_data_msb_w1_g[4]) |
    (morphed_addr_g[4] & ld_data_msb_w1_g[3]) |
    (morphed_addr_g[5] & ld_data_msb_w1_g[2]) |
    (morphed_addr_g[6] & ld_data_msb_w1_g[1]) |
    (morphed_addr_g[7] & ld_data_msb_w1_g[0]) ;


  wire  sign_bit_w2_g =
    (morphed_addr_g[0] & ld_data_msb_w2_g[7]) |
    (morphed_addr_g[1] & ld_data_msb_w2_g[6]) |
    (morphed_addr_g[2] & ld_data_msb_w2_g[5]) |
    (morphed_addr_g[3] & ld_data_msb_w2_g[4]) |
    (morphed_addr_g[4] & ld_data_msb_w2_g[3]) |
    (morphed_addr_g[5] & ld_data_msb_w2_g[2]) |
    (morphed_addr_g[6] & ld_data_msb_w2_g[1]) |
    (morphed_addr_g[7] & ld_data_msb_w2_g[0]) ;


  wire  sign_bit_w3_g =
    (morphed_addr_g[0] & ld_data_msb_w3_g[7]) |
    (morphed_addr_g[1] & ld_data_msb_w3_g[6]) |
    (morphed_addr_g[2] & ld_data_msb_w3_g[5]) |
    (morphed_addr_g[3] & ld_data_msb_w3_g[4]) |
    (morphed_addr_g[4] & ld_data_msb_w3_g[3]) |
    (morphed_addr_g[5] & ld_data_msb_w3_g[2]) |
    (morphed_addr_g[6] & ld_data_msb_w3_g[1]) |
    (morphed_addr_g[7] & ld_data_msb_w3_g[0]) ;


   
//assign  sign_bit_g =
//  (morphed_addr_g[0] & align_bytes_msb[7]) |
//  (morphed_addr_g[1] & align_bytes_msb[6]) |
//  (morphed_addr_g[2] & align_bytes_msb[5]) |
//  (morphed_addr_g[3] & align_bytes_msb[4]) |
//  (morphed_addr_g[4] & align_bytes_msb[3]) |
//  (morphed_addr_g[5] & align_bytes_msb[2]) |
//  (morphed_addr_g[6] & align_bytes_msb[1]) |
//  (morphed_addr_g[7] & align_bytes_msb[0]) ;


//dff #(4) ssign_bit_stgg (
//        .din    ({sign_bit_w0_m, sign_bit_w1_m, sign_bit_w2_m, sign_bit_w3_m}),
//        .q      ({sign_bit_w0_g, sign_bit_w1_g, sign_bit_w2_g, sign_bit_w3_g}),
//        .clk    (clk),
//        .se     (se),       .si (),          .so ()
//        );
   
//    wire [7:1] lsu_byp_byte_sign_extend_w0;
// assign  lsu_byp_byte_sign_extend_w0[1] =
//         signed_ldst_byte_g & sign_bit_w0_g;
// assign  lsu_byp_byte_sign_extend_w0[2] =
//         signed_ldst_hw_g & sign_bit_w0_g;
// assign  lsu_byp_byte_sign_extend_w0[3] =
//         lsu_byp_byte_sign_extend_w0[2] ;
// assign  lsu_byp_byte_sign_extend_w0[4] =
//         signed_ldst_w_g & sign_bit_w0_g;
// assign  lsu_byp_byte_sign_extend_w0[5] =
//     lsu_byp_byte_sign_extend_w0[4] ;
// assign  lsu_byp_byte_sign_extend_w0[6] =
//     lsu_byp_byte_sign_extend_w0[4] ;
// assign  lsu_byp_byte_sign_extend_w0[7] =
//     lsu_byp_byte_sign_extend_w0[4] ;

//    wire [7:1] lsu_byp_byte_sign_extend_w1;
// assign  lsu_byp_byte_sign_extend_w1[1] =
//         signed_ldst_byte_g & sign_bit_w1_g;
// assign  lsu_byp_byte_sign_extend_w1[2] =
//         signed_ldst_hw_g & sign_bit_w1_g;
// assign  lsu_byp_byte_sign_extend_w1[3] =
//         lsu_byp_byte_sign_extend_w1[2] ;
// assign  lsu_byp_byte_sign_extend_w1[4] =
//         signed_ldst_w_g & sign_bit_w1_g;
// assign  lsu_byp_byte_sign_extend_w1[5] =
//     lsu_byp_byte_sign_extend_w1[4] ;
// assign  lsu_byp_byte_sign_extend_w1[6] =
//     lsu_byp_byte_sign_extend_w1[4] ;
// assign  lsu_byp_byte_sign_extend_w1[7] =
//     lsu_byp_byte_sign_extend_w1[4] ;

// //w2
// //   wire [3:1] lsu_byp_byte_zero_extend_w2;
//    wire [7:1] lsu_byp_byte_sign_extend_w2;
   
// //assign  lsu_byp_byte_zero_extend_w2[1] =
// //        unsigned_ldst_byte_g | (signed_ldst_byte_g & ~sign_bit_w2_g);
   
// assign  lsu_byp_byte_sign_extend_w2[1] =
//         signed_ldst_byte_g & sign_bit_w2_g;
 
// //assign  lsu_byp_byte_zero_extend_w2[2] =
// //        unsigned_ldst_hw_g | (signed_ldst_hw_g & ~sign_bit_w2_g);

// assign  lsu_byp_byte_sign_extend_w2[2] =
//         signed_ldst_hw_g & sign_bit_w2_g;
   
// //assign  lsu_byp_byte_zero_extend_w2[3] =
// //        lsu_byp_byte_zero_extend_w2[2] ;

// assign  lsu_byp_byte_sign_extend_w2[3] =
//         lsu_byp_byte_sign_extend_w2[2] ;

// //assign  lsu_byp_byte_zero_extend_w2[4] =
// //        unsigned_ldst_w_g | (signed_ldst_w_g & ~sign_bit_w2_g);
   
// assign  lsu_byp_byte_sign_extend_w2[4] =
//         signed_ldst_w_g & sign_bit_w2_g;
        
// //assign  lsu_byp_byte_zero_extend_w2[5] =
// //    lsu_byp_byte_zero_extend_w2[4] ;
// assign  lsu_byp_byte_sign_extend_w2[5] =
//     lsu_byp_byte_sign_extend_w2[4] ;
// //assign  lsu_byp_byte_zero_extend_w2[6] =
// //    lsu_byp_byte_zero_extend_w2[4] ;
// assign  lsu_byp_byte_sign_extend_w2[6] =
//     lsu_byp_byte_sign_extend_w2[4] ;
// //assign  lsu_byp_byte_zero_extend_w2[7] =
// //    lsu_byp_byte_zero_extend_w2[4] ;
// assign  lsu_byp_byte_sign_extend_w2[7] =
//     lsu_byp_byte_sign_extend_w2[4] ;

// //w3
// //   wire [3:1] lsu_byp_byte_zero_extend_w3;
//    wire [7:1] lsu_byp_byte_sign_extend_w3;
   
// //assign  lsu_byp_byte_zero_extend_w3[1] =
// //        unsigned_ldst_byte_g | (signed_ldst_byte_g & ~sign_bit_w3_g);
   
// assign  lsu_byp_byte_sign_extend_w3[1] =
//         signed_ldst_byte_g & sign_bit_w3_g;
 
// //assign  lsu_byp_byte_zero_extend_w3[2] =
// //        unsigned_ldst_hw_g | (signed_ldst_hw_g & ~sign_bit_w3_g);

// assign  lsu_byp_byte_sign_extend_w3[2] =
//         signed_ldst_hw_g & sign_bit_w3_g;
   
// //assign  lsu_byp_byte_zero_extend_w3[3] =
// //        lsu_byp_byte_zero_extend_w3[2] ;

// assign  lsu_byp_byte_sign_extend_w3[3] =
//         lsu_byp_byte_sign_extend_w3[2] ;

// //assign  lsu_byp_byte_zero_extend_w3[4] =
// //        unsigned_ldst_w_g | (signed_ldst_w_g & ~sign_bit_w3_g);
   
// assign  lsu_byp_byte_sign_extend_w3[4] =
//         signed_ldst_w_g & sign_bit_w3_g;
        
// //assign  lsu_byp_byte_zero_extend_w3[5] =
// //    lsu_byp_byte_zero_extend_w3[4] ;
// assign  lsu_byp_byte_sign_extend_w3[5] =
//     lsu_byp_byte_sign_extend_w3[4] ;
// //assign  lsu_byp_byte_zero_extend_w3[6] =
// //    lsu_byp_byte_zero_extend_w3[4] ;
// assign  lsu_byp_byte_sign_extend_w3[6] =
//     lsu_byp_byte_sign_extend_w3[4] ;
// //assign  lsu_byp_byte_zero_extend_w3[7] =
// //    lsu_byp_byte_zero_extend_w3[4] ;
// assign  lsu_byp_byte_sign_extend_w3[7] =
//     lsu_byp_byte_sign_extend_w3[4] ;



  wire [7:1] lsu_byp_byte_sign_extend_w0;
  assign  lsu_byp_byte_sign_extend_w0[1] =
          signed_ldst_byte_g & sign_bit_w0_g;
  assign  lsu_byp_byte_sign_extend_w0[2] =
          signed_ldst_hw_g & sign_bit_w0_g;
  assign  lsu_byp_byte_sign_extend_w0[3] =
          lsu_byp_byte_sign_extend_w0[2] ;
  assign  lsu_byp_byte_sign_extend_w0[4] =
          signed_ldst_w_g & sign_bit_w0_g;
  assign  lsu_byp_byte_sign_extend_w0[5] =
          lsu_byp_byte_sign_extend_w0[4] ;
  assign  lsu_byp_byte_sign_extend_w0[6] =
          lsu_byp_byte_sign_extend_w0[4] ;
  assign  lsu_byp_byte_sign_extend_w0[7] =
          lsu_byp_byte_sign_extend_w0[4] ;


  wire [7:1] lsu_byp_byte_sign_extend_w1;
  assign  lsu_byp_byte_sign_extend_w1[1] =
          signed_ldst_byte_g & sign_bit_w1_g;
  assign  lsu_byp_byte_sign_extend_w1[2] =
          signed_ldst_hw_g & sign_bit_w1_g;
  assign  lsu_byp_byte_sign_extend_w1[3] =
          lsu_byp_byte_sign_extend_w1[2] ;
  assign  lsu_byp_byte_sign_extend_w1[4] =
          signed_ldst_w_g & sign_bit_w1_g;
  assign  lsu_byp_byte_sign_extend_w1[5] =
          lsu_byp_byte_sign_extend_w1[4] ;
  assign  lsu_byp_byte_sign_extend_w1[6] =
          lsu_byp_byte_sign_extend_w1[4] ;
  assign  lsu_byp_byte_sign_extend_w1[7] =
          lsu_byp_byte_sign_extend_w1[4] ;


  wire [7:1] lsu_byp_byte_sign_extend_w2;
  assign  lsu_byp_byte_sign_extend_w2[1] =
          signed_ldst_byte_g & sign_bit_w2_g;
  assign  lsu_byp_byte_sign_extend_w2[2] =
          signed_ldst_hw_g & sign_bit_w2_g;
  assign  lsu_byp_byte_sign_extend_w2[3] =
          lsu_byp_byte_sign_extend_w2[2] ;
  assign  lsu_byp_byte_sign_extend_w2[4] =
          signed_ldst_w_g & sign_bit_w2_g;
  assign  lsu_byp_byte_sign_extend_w2[5] =
          lsu_byp_byte_sign_extend_w2[4] ;
  assign  lsu_byp_byte_sign_extend_w2[6] =
          lsu_byp_byte_sign_extend_w2[4] ;
  assign  lsu_byp_byte_sign_extend_w2[7] =
          lsu_byp_byte_sign_extend_w2[4] ;


  wire [7:1] lsu_byp_byte_sign_extend_w3;
  assign  lsu_byp_byte_sign_extend_w3[1] =
          signed_ldst_byte_g & sign_bit_w3_g;
  assign  lsu_byp_byte_sign_extend_w3[2] =
          signed_ldst_hw_g & sign_bit_w3_g;
  assign  lsu_byp_byte_sign_extend_w3[3] =
          lsu_byp_byte_sign_extend_w3[2] ;
  assign  lsu_byp_byte_sign_extend_w3[4] =
          signed_ldst_w_g & sign_bit_w3_g;
  assign  lsu_byp_byte_sign_extend_w3[5] =
          lsu_byp_byte_sign_extend_w3[4] ;
  assign  lsu_byp_byte_sign_extend_w3[6] =
          lsu_byp_byte_sign_extend_w3[4] ;
  assign  lsu_byp_byte_sign_extend_w3[7] =
          lsu_byp_byte_sign_extend_w3[4] ;



//mux4ds  #(14) zero_sign_sel_mux (
//        .in0    ({lsu_byp_byte_zero_extend_w0[7:1],lsu_byp_byte_sign_extend_w0[7:1]}),
//        .in1    ({lsu_byp_byte_zero_extend_w1[7:1],lsu_byp_byte_sign_extend_w1[7:1]}),
//        .in2    ({lsu_byp_byte_zero_extend_w2[7:1],lsu_byp_byte_sign_extend_w2[7:1]}),
//        .in3    ({lsu_byp_byte_zero_extend_w3[7:1],lsu_byp_byte_sign_extend_w3[7:1]}),
//        .sel0   (cache_way_mx_sel[0]),  
//        .sel1   (cache_way_mx_sel[1]),
//        .sel2   (cache_way_mx_sel[2]),  
//        .sel3   (cache_way_mx_sel[3]),
//        .dout   ({lsu_byp_byte_zero_extend[7:1],lsu_byp_byte_sign_extend[7:1]})
//);

//assign lsu_byp_byte_zero_extend[3:1] =
//   (cache_way_mx_sel[0] ?  lsu_byp_byte_zero_extend_w0[3:1] : 3'b0 ) |   
//   (cache_way_mx_sel[1] ?  lsu_byp_byte_zero_extend_w1[3:1] : 3'b0 ) |   
//   (cache_way_mx_sel[2] ?  lsu_byp_byte_zero_extend_w2[3:1] : 3'b0 ) |   
//   (cache_way_mx_sel[3] ?  lsu_byp_byte_zero_extend_w3[3:1] : 3'b0 ) ;

// assign lsu_byp_byte_sign_extend[7:1] = 
//    (cache_way_mx_sel[0] ?  lsu_byp_byte_sign_extend_w0[7:1] : 7'b0) |
//    (cache_way_mx_sel[1] ?  lsu_byp_byte_sign_extend_w1[7:1] : 7'b0) |
//    (cache_way_mx_sel[2] ?  lsu_byp_byte_sign_extend_w2[7:1] : 7'b0) |
//    (cache_way_mx_sel[3] ?  lsu_byp_byte_sign_extend_w3[7:1] : 7'b0) ;

always @ *
begin

  lsu_byp_byte_sign_extend[7:1]
 = 0;
if (
  cache_way_mx_sel[0]
)
   
  lsu_byp_byte_sign_extend[7:1]
 = 
  lsu_byp_byte_sign_extend[7:1]
 | 
  lsu_byp_byte_sign_extend_w0[7:1]
;
if (
  cache_way_mx_sel[1]
)
   
  lsu_byp_byte_sign_extend[7:1]
 = 
  lsu_byp_byte_sign_extend[7:1]
 | 
  lsu_byp_byte_sign_extend_w1[7:1]
;
if (
  cache_way_mx_sel[2]
)
   
  lsu_byp_byte_sign_extend[7:1]
 = 
  lsu_byp_byte_sign_extend[7:1]
 | 
  lsu_byp_byte_sign_extend_w2[7:1]
;
if (
  cache_way_mx_sel[3]
)
   
  lsu_byp_byte_sign_extend[7:1]
 = 
  lsu_byp_byte_sign_extend[7:1]
 | 
  lsu_byp_byte_sign_extend_w3[7:1]
;
end


dff_s #(37) stgg_mergesel(
        .din    ({
         merge7_sel_byte0_m, merge7_sel_byte7_m,
         merge6_sel_byte1_m, merge6_sel_byte6_m,
         merge5_sel_byte2_m, merge5_sel_byte5_m,
         merge4_sel_byte3_m, merge4_sel_byte4_m,
         merge3_sel_byte0_m, merge3_sel_byte3_m,
         merge3_sel_byte4_m, merge3_sel_byte7_default_m, merge3_sel_byte_m,
         merge2_sel_byte1_m, merge2_sel_byte2_m,         merge2_sel_byte5_m,
         merge2_sel_byte6_default_m, merge2_sel_byte_m,
         merge0_sel_byte0_m, merge0_sel_byte1_m,
         merge0_sel_byte2_m, merge0_sel_byte3_default_m,
         merge0_sel_byte4_m, merge0_sel_byte5_m,
         merge0_sel_byte6_m, merge0_sel_byte7_default_m,
         merge1_sel_byte0_m, merge1_sel_byte1_m,
         merge1_sel_byte2_m, merge1_sel_byte3_default_m,
         merge1_sel_byte4_m, merge1_sel_byte5_m,
         merge1_sel_byte6_m, merge1_sel_byte7_default_m,
         merge0_sel_byte_1h_m,merge1_sel_byte_1h_m, merge1_sel_byte_2h_m
                }),
        .q      ({
         merge7_sel_byte0, merge7_sel_byte7,
         merge6_sel_byte1, merge6_sel_byte6,
         merge5_sel_byte2, merge5_sel_byte5,
         merge4_sel_byte3, merge4_sel_byte4,
         merge3_sel_byte0, merge3_sel_byte3,
         merge3_sel_byte4, merge3_sel_byte7,merge3_sel_byte,
         merge2_sel_byte1, merge2_sel_byte2, merge2_sel_byte5,
         merge2_sel_byte6, merge2_sel_byte,
         merge0_sel_byte0, merge0_sel_byte1,
         merge0_sel_byte2, merge0_sel_byte3,
         merge0_sel_byte4, merge0_sel_byte5,
         merge0_sel_byte6, merge0_sel_byte7,
         merge1_sel_byte0, merge1_sel_byte1,
         merge1_sel_byte2, merge1_sel_byte3,
         merge1_sel_byte4, merge1_sel_byte5,
         merge1_sel_byte6, merge1_sel_byte7,
         merge0_sel_byte_1h,merge1_sel_byte_1h, merge1_sel_byte_2h
                }),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );


assign 	lsu_exu_dfill_data_w2[63:0] = align_byte[63:0] ; 
assign	lsu_ffu_ld_data[63:0] = align_byte[63:0] ;

endmodule



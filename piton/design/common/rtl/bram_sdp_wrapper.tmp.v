// Copyright (c) 2015 Princeton University
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of Princeton University nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY PRINCETON UNIVERSITY "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL PRINCETON UNIVERSITY BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// Author:      Alexey Lavrov
// Description: A simple wrapper for double port Xilinx bram
//              which enables bit write mask
module bram_sdp_wrapper 
#(parameter NAME="", DEPTH=-1, ADDR_WIDTH=-1, BITMASK_WIDTH=-1, DATA_WIDTH=-1)
(
    input                         MEMCLK,
    input                         CE,
    input   [ADDR_WIDTH-1:0]      A,
    input                         RDWEN,
    input   [BITMASK_WIDTH-1:0]   BW,
    input   [DATA_WIDTH-1:0]      DIN,
    output  [DATA_WIDTH-1:0]      DOUT
);

wire                            write_en;
wire                            read_en;

// Temporary storage for write data
reg                             wen_r;
reg   [ADDR_WIDTH-1:0    ]      A_r;
reg   [BITMASK_WIDTH-1:0 ]      BW_r;
reg   [DATA_WIDTH-1:0    ]      DIN_r;
reg   [DATA_WIDTH-1:0    ]      DOUT_r;

reg                             ren_r;

reg   [DATA_WIDTH-1:0    ]      bram_data_in_r;

wire                            bram_wen;
wire                            bram_ren;
wire  [DATA_WIDTH-1:0    ]      bram_data_out;
wire  [DATA_WIDTH-1:0    ]      bram_data_in;
wire  [DATA_WIDTH-1:0    ]      up_to_date_data;
wire                            rw_conflict;
reg                             rw_conflict_r;


assign write_en   = CE & (RDWEN == 1'b0);
assign read_en    = CE & (RDWEN == 1'b1);


// Intermediate logic for write processing
always @(posedge MEMCLK) begin
   wen_r <= write_en;
   A_r   <= A;
   BW_r  <= BW;
   DIN_r <= DIN;
end

always @(posedge MEMCLK) begin
  ren_r  <= read_en;
end

always @(posedge MEMCLK)
   bram_data_in_r <= bram_data_in;

always @(posedge MEMCLK)
   rw_conflict_r  <= rw_conflict;

always @(posedge MEMCLK)
  DOUT_r  <= DOUT;

assign bram_data_in = (up_to_date_data & ~BW_r) | (DIN_r & BW_r);

// processing of read in case if it just in the next cycle after read to the same address
assign rw_conflict      = wen_r & CE & (A_r == A);                         // read or write to the same address
assign up_to_date_data  = rw_conflict_r ? bram_data_in_r : bram_data_out;  // delay of mem is 1 cycle
assign bram_ren         = (read_en | write_en) & ~rw_conflict;             // do not read in case of a conflict
                                                                        // to make behaviour of a memory robust
assign bram_wen      = wen_r;

assign DOUT          = ren_r ? up_to_date_data : DOUT_r;

generate begin: bram_generate
  if  (NAME == "l2_dir") begin
    bram_1024x64 mem (
     .clka    (MEMCLK        ),
     .ena     (bram_wen      ),
     .wea     (1'b1          ),
     .addra   (A_r           ),
     .dina    (bram_data_in  ),
     
     .clkb    (MEMCLK        ),
     .enb     (bram_ren      ),
     .addrb   (A             ),
     .doutb   (bram_data_out )
    );
  end
  else if  (NAME == "l1d_tag") begin
    bram_128x132 mem (
     .clka    (MEMCLK        ),
     .ena     (bram_wen      ),
     .wea     (1'b1          ),
     .addra   (A_r           ),
     .dina    (bram_data_in  ),
     
     .clkb    (MEMCLK        ),
     .enb     (bram_ren      ),
     .addrb   (A             ),
     .doutb   (bram_data_out )
    );
  end
  else if  (NAME == "bram_boot") begin
    bram_256x512 mem (
     .clka    (MEMCLK        ),
     .ena     (bram_wen      ),
     .wea     (1'b1          ),
     .addra   (A_r           ),
     .dina    (bram_data_in  ),
     
     .clkb    (MEMCLK        ),
     .enb     (bram_ren      ),
     .addrb   (A             ),
     .doutb   (bram_data_out )
    );
  end
  else if  (NAME == "l15_tag") begin
    bram_128x132 mem (
     .clka    (MEMCLK        ),
     .ena     (bram_wen      ),
     .wea     (1'b1          ),
     .addra   (A_r           ),
     .dina    (bram_data_in  ),
     
     .clkb    (MEMCLK        ),
     .enb     (bram_ren      ),
     .addrb   (A             ),
     .doutb   (bram_data_out )
    );
  end
  else if  (NAME == "l15_data") begin
    bram_512x128 mem (
     .clka    (MEMCLK        ),
     .ena     (bram_wen      ),
     .wea     (1'b1          ),
     .addra   (A_r           ),
     .dina    (bram_data_in  ),
     
     .clkb    (MEMCLK        ),
     .enb     (bram_ren      ),
     .addrb   (A             ),
     .doutb   (bram_data_out )
    );
  end
  else if  (NAME == "l2_data") begin
    bram_4096x144 mem (
     .clka    (MEMCLK        ),
     .ena     (bram_wen      ),
     .wea     (1'b1          ),
     .addra   (A_r           ),
     .dina    (bram_data_in  ),
     
     .clkb    (MEMCLK        ),
     .enb     (bram_ren      ),
     .addrb   (A             ),
     .doutb   (bram_data_out )
    );
  end
  else if  (NAME == "l1d_data") begin
    bram_128x576 mem (
     .clka    (MEMCLK        ),
     .ena     (bram_wen      ),
     .wea     (1'b1          ),
     .addra   (A_r           ),
     .dina    (bram_data_in  ),
     
     .clkb    (MEMCLK        ),
     .enb     (bram_ren      ),
     .addrb   (A             ),
     .doutb   (bram_data_out )
    );
  end
  else if  (NAME == "l15_hmt") begin
    bram_512x32 mem (
     .clka    (MEMCLK        ),
     .ena     (bram_wen      ),
     .wea     (1'b1          ),
     .addra   (A_r           ),
     .dina    (bram_data_in  ),
     
     .clkb    (MEMCLK        ),
     .enb     (bram_ren      ),
     .addrb   (A             ),
     .doutb   (bram_data_out )
    );
  end
  else if  (NAME == "l1i_tag") begin
    bram_128x132 mem (
     .clka    (MEMCLK        ),
     .ena     (bram_wen      ),
     .wea     (1'b1          ),
     .addra   (A_r           ),
     .dina    (bram_data_in  ),
     
     .clkb    (MEMCLK        ),
     .enb     (bram_ren      ),
     .addrb   (A             ),
     .doutb   (bram_data_out )
    );
  end
  else if  (NAME == "fp_regfile") begin
    bram_128x78 mem (
     .clka    (MEMCLK        ),
     .ena     (bram_wen      ),
     .wea     (1'b1          ),
     .addra   (A_r           ),
     .dina    (bram_data_in  ),
     
     .clkb    (MEMCLK        ),
     .enb     (bram_ren      ),
     .addrb   (A             ),
     .doutb   (bram_data_out )
    );
  end
  else if  (NAME == "l1i_data") begin
    bram_256x272 mem (
     .clka    (MEMCLK        ),
     .ena     (bram_wen      ),
     .wea     (1'b1          ),
     .addra   (A_r           ),
     .dina    (bram_data_in  ),
     
     .clkb    (MEMCLK        ),
     .enb     (bram_ren      ),
     .addrb   (A             ),
     .doutb   (bram_data_out )
    );
  end
  else if  (NAME == "l2_tag") begin
    bram_256x104 mem (
     .clka    (MEMCLK        ),
     .ena     (bram_wen      ),
     .wea     (1'b1          ),
     .addra   (A_r           ),
     .dina    (bram_data_in  ),
     
     .clkb    (MEMCLK        ),
     .enb     (bram_ren      ),
     .addrb   (A             ),
     .doutb   (bram_data_out )
    );
  end
end
endgenerate


endmodule

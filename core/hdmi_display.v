`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Module Name: TextGraphic  ( by Giacomazzi Riccardo 19-02-2015 )
//
// Description: 
// - Video Mode: 960x540@60Hz
// - Text Mode: 120x60 16 Color
// - Char Matrix: 8x9
// - 3 Blink Modes: Foreground / Background / Both
//
//////////////////////////////////////////////////////////////////////////////////

module HdmiDisplay
( input clk50,
  output [3:0] tmds_out_p,
  output [3:0] tmds_out_n,
  output PixClk, output PixClk_2,
  input [7:0] Red,
  input [7:0] Green,
  input [7:0] Blue,
  input HSync, input VSync, input VideoEnable
);


// ************************************************************************************************
// * TMDS Encoding & Serialization
// *************************/***********************************************************************

  wire PixClk_10;
  wire SerDesStrobe;
  wire [9:0] EncRed;
  wire [9:0] EncGreen;
  wire [9:0] EncBlue;
  wire SerOutRed;
  wire SerOutGreen;
  wire SerOutBlue;
  reg SerOutClock=0;

  Component_encoder CE_Red(.Data(Red), .C0(1'b0), .C1(1'b0), .DE(VideoEnable), .PixClk(PixClk), .OutEncoded(EncRed));
  Component_encoder CE_Green(.Data(Green), .C0(1'b0), .C1(1'b0), .DE(VideoEnable), .PixClk(PixClk), .OutEncoded(EncGreen));
  Component_encoder CE_Blue(.Data(Blue), .C0(HSync), .C1(VSync), .DE(VideoEnable), .PixClk(PixClk), .OutEncoded(EncBlue));

  Serializer_10_1 SER_Red(.Data(EncRed), .Clk_10(PixClk_10), .Clk_2(PixClk_2), .Strobe(SerDesStrobe), .Out(SerOutRed));
  Serializer_10_1 SER_Green(.Data(EncGreen), .Clk_10(PixClk_10), .Clk_2(PixClk_2), .Strobe(SerDesStrobe), .Out(SerOutGreen));
  Serializer_10_1 SER_Blue(.Data(EncBlue), .Clk_10(PixClk_10), .Clk_2(PixClk_2), .Strobe(SerDesStrobe), .Out(SerOutBlue));
  always @(posedge PixClk_2)
  begin
		SerOutClock = !SerOutClock;
  end
  
  OBUFDS OutBufDif_B(.I(SerOutBlue), .O(tmds_out_p[0]), .OB(tmds_out_n[0]));
  OBUFDS OutBufDif_G(.I(SerOutGreen), .O(tmds_out_p[1]), .OB(tmds_out_n[1]));
  OBUFDS OutBufDif_R(.I(SerOutRed), .O(tmds_out_p[2]), .OB(tmds_out_n[2]));
  OBUFDS OutBufDif_C(.I(SerOutClock), .O(tmds_out_p[3]), .OB(tmds_out_n[3]));


// ************************************************************************************************
// * PLL VCO:400MHz  PixClk:40MHz
// ************************************************************************************************

  wire pll_fbout;      // PLL Feedback
  wire pll_clk10x;     // From PLL to BUFPLL
  wire pll_clk2x;      // From PLL to BUFG
  wire pll_clk1x;      // From PLL to BUFG
  wire pll_locked;
  
  PLL_BASE #(.CLKOUT0_DIVIDE(1),  // IO clock 400MHz (VCO)
             .CLKOUT1_DIVIDE(5),  // Intermediate clock 80MHz (VCO / 5)
             .CLKOUT2_DIVIDE(10), // Pixle Clock 40MHz (VCO / 10)
             .CLKFBOUT_MULT(8),   // VCO = 50MHz * 8 = 400MHz ...
             .DIVCLK_DIVIDE(1),   // ... 400MHz / 1 = 400MHz
             .CLKIN_PERIOD(20.00) // 20ns = 50MHz
            ) ClockGenPLL(.CLKIN(clk50),
                          .CLKFBIN(pll_fbout),
                          .RST(1'b0),
                          .CLKOUT0(pll_clk10x),
                          .CLKOUT1(pll_clk2x),
                          .CLKOUT2(pll_clk1x),
                          .CLKOUT3(),
                          .CLKOUT4(),
                          .CLKOUT5(),
                          .CLKFBOUT(pll_fbout),
                          .LOCKED(pll_locked));

  BUFG Clk1x_buf(.I(pll_clk1x), .O(PixClk));
  BUFG Clk2x_buf(.I(pll_clk2x), .O(PixClk_2));
  
  BUFPLL #(.DIVIDE(5),
           .ENABLE_SYNC("TRUE")
          ) Clk10x_buf(.PLLIN(pll_clk10x),
                       .GCLK(PixClk_2),
                       .LOCKED(pll_locked),
                       .IOCLK(PixClk_10),
                       .SERDESSTROBE(SerDesStrobe),
                       .LOCK());

endmodule

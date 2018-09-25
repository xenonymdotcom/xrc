`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////////////

// ************************************************************************************************
// * TMDS Serializer 10/1
// ************************************************************************************************

//
// Module to output the hdmi encoded 10 pixel bits using  
//

module Serializer_10_1
( input [9:0] Data,
  input Clk_10,
  input Clk_2,
  input Strobe,
  output Out
);

  reg Status;
  reg [4:0] OutBuf;  // output buffer
  wire cascade_in;
  wire cascade_out;
  
  initial
    begin
      Status = 1'b0;
      OutBuf[4:0] = 5'h00;
    end

  always @(posedge Clk_2)
    begin
		OutBuf[4:0] = Status ? Data[9:5] : Data[4:0];
      Status = !Status;
    end

  OSERDES2 #(.DATA_RATE_OQ("SDR"),
             .DATA_RATE_OT("SDR"),
             .DATA_WIDTH(5),
             .SERDES_MODE("MASTER")
            ) MasterSerDes(.CLK0(Clk_10),
                           .CLK1(1'b0),
                           .CLKDIV(Clk_2),
                           .IOCE(Strobe),
                           .D4(1'b0),
                           .D3(1'b0),
                           .D2(1'b0),
                           .D1(OutBuf[4]),
                           .OCE(1'b1),
                           .RST(1'b0),
                           .T4(1'b0),
                           .T3(1'b0),
                           .T2(1'b0),
                           .T1(1'b0),
                           .TCE(1'b0),
                           .SHIFTIN1(1'b0),
                           .SHIFTIN2(1'b0),
                           .SHIFTIN3(cascade_in),
                           .SHIFTIN4(1'b0),
                           .TRAIN(1'b0),
                           .OQ(Out),
                           .TQ(),
                           .SHIFTOUT1(cascade_out),
                           .SHIFTOUT2(),
                           .SHIFTOUT3(),
                           .SHIFTOUT4());

  OSERDES2 #(.DATA_RATE_OQ("SDR"),
             .DATA_RATE_OT("SDR"),
             .DATA_WIDTH(5),
             .SERDES_MODE("SLAVE")
            ) SlaveSerDes(.CLK0(Clk_10),
                          .CLK1(1'b0),
                          .CLKDIV(Clk_2),
                          .IOCE(Strobe),
                          .D4(OutBuf[3]),
                          .D3(OutBuf[2]),
                          .D2(OutBuf[1]),
                          .D1(OutBuf[0]),
                          .OCE(1'b1),
                          .RST(1'b0),
                          .T4(1'b0),
                          .T3(1'b0),
                          .T2(1'b0),
                          .T1(1'b0),
                          .TCE(1'b0),
                          .SHIFTIN1(cascade_out),
                          .SHIFTIN2(1'b0),
                          .SHIFTIN3(1'b0),
                          .SHIFTIN4(1'b0),
                          .TRAIN(1'b0),
                          .OQ(),
                          .TQ(),
                          .SHIFTOUT1(),
                          .SHIFTOUT2(),
                          .SHIFTOUT3(cascade_in),
                          .SHIFTOUT4());

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Module Name: Core
//  Derived from Module Hello  ( by Giacomazzi Riccardo 19-02-2015 )
//
// Description: Initial wiring for the TextGraphic module
//
//////////////////////////////////////////////////////////////////////////////////

module XrcCore
( input clk50,
  output [3:0] tmds_out_p,
  output [3:0] tmds_out_n,
  output [7:0] LEDS
);

  reg [12:0] WAddr;
  reg [17:0] WData;
  reg Write;
  reg [3:0] Status;
  reg [3:0] Index;
  reg [3:0] BG;
  reg [3:0] FG;
  reg [1:0] BL;
  reg [7:0] Char = 8'd0;
  reg [15:0] Frame = 16'd0;
  integer Row;
  integer Col;
  reg [3:0] counter = 0;
  
  wire Clock;
  
  BUFG ClockBuf(.I(clk50), .O(Clock));

  TextGraphic TEXT(.clk50(Clock), .tmds_out_p(tmds_out_p), .tmds_out_n(tmds_out_n), 
                   .WAddr(WAddr), .WData(WData), .WClk(Clock), .Write(Write));
						 
  LedDriver LedDisplay(.clk50(Clock), .LEDS(LEDS));
						
  initial
    begin
		Status = 4'h0;
		Index = 4'h0;
		Write = 1'b0;
		WAddr = 13'h0000;
		WData = 18'h00000;
		Row = 0;
		Col = 0;
    end	 
	
  always @(negedge Clock)
    begin
	   case(Status)
		  4'h0: begin
		          Index = 4'h0;
					 WAddr = 0;
					 Row = 0;
					 Col = 0;
                Status = 4'h1;
				  end
		  4'h1: begin
					BG = Row[3:0]; // + Frame[15:12];
					FG = 4'hF - Row;
					BL = 2'b00;
					Char = Char + 1;
					Status = 4'h2;
				  end
        4'h2: begin
		          WData = {BL, BG, FG, Char[7:0]};
					 Status = 4'h3;
				  end
		  4'h3: begin
                Write = 1'b1;
					 Status = 4'h4;
				  end
		  4'h4: begin
                Write = 1'b0;
		          if (Col < 119)
					   begin
						  Col = Col + 1;
						  if (Index < 14) Index = Index + 1;
						  else Index = 0;
						  WAddr = WAddr + 1;
						  Status = 4'h1;
						end
					 else
					   begin
						  Col = 0;
						  Index = 0;
						  WAddr = WAddr + 1;
						  if (Row < 60)
						    begin
							   Row = Row + 1;
								Status = 4'h1;
							 end
						  else
						    begin
							 Char = Frame[15:8];
							 Frame = Frame + 1;
							   Status = 4'h0;
							 end
						end
				  end
	     4'h5: Status = 4'h5;
		  default: Status = 4'h5;
		endcase
	 end

endmodule

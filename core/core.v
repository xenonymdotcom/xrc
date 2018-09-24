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
  output [3:0] tmds_out_n
);

  reg [12:0] WAddr;
  reg [17:0] WData;
  reg Write;
  reg [7:0] String[14:0];
  reg [3:0] Status;
  reg [3:0] Index;
  reg [3:0] BG;
  reg [3:0] FG;
  reg [1:0] BL;
  reg [7:0] Char = 8'd0;
  reg [15:0] Frame = 16'd0;
  integer Row;
  integer Col;
  
  wire Clock;
  
  BUFG ClockBuf(.I(clk50), .O(Clock));

  TextGraphic TEXT(.clk50(Clock), .tmds_out_p(tmds_out_p), .tmds_out_n(tmds_out_n), 
                   .WAddr(WAddr), .WData(WData), .WClk(Clock), .Write(Write));
						
  initial
    begin
	   String[0] = 8'h20;  // 
	   String[1] = 8'h48;  // H
	   String[2] = 8'h65;  // e
	   String[3] = 8'h6C;  // l
	   String[4] = 8'h6C;  // l
	   String[5] = 8'h6F;  // o
	   String[6] = 8'h2C;  // ,
	   String[7] = 8'h20;  //
	   String[8] = 8'h57;  // W
	   String[9] = 8'h6F;  // o
	   String[10] = 8'h72; // r
	   String[11] = 8'h6C; // l
	   String[12] = 8'h64; // d
	   String[13] = 8'h21; // !
	   String[14] = 8'h20; // 
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
					BG = Row[3:0];
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

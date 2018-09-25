`timescale 1ns / 1ps
//
// LED driver 
//

module LedDriver
( input clk50,
  output [7:0] LEDS
);

	reg [31:0] counter = 0;
  
	assign LEDS[7:0]=8'b11111111&counter[31:24];

	always @(posedge clk50)
	begin
		counter <= counter + 1'b1; 
	end

endmodule

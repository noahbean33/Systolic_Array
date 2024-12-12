`timescale 1ns / 1ps

module mat_tb;

	// Inputs
	reg clk;
	reg reset;
	reg start;

	// Instantiate the Unit Under Test (UUT)
	matrix_mul3x3 uut (
		.clk(clk), 
		.reset(reset), 
		.start(start)
	);
always #5 clk = ~clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1'b1;
		start = 0;

		// Wait 100 ns for global reset to finish
		#104.9;
        start = 1'b1;
		  reset = 1'b0;
		  #10;
		   start = 1'b0;
		// Add stimulus here

	end
      
endmodule


//Cin_generation_logic
module cin_generation_logic(r,c0,cin);

	input	[1:0]	r;
	input		c0;
	output		cin;
	
	assign cin = (r[0] & c0) | r[1];
	
endmodule

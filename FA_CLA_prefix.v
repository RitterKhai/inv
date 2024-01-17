//FA_cell_CLA
module FA_CLA_prefix(a,b,cin,s,q);

	input 		a;
	input 		b;
	input 		cin;
	output 		s;
	output	[1:0]	q;
	
	assign q[0] = a ^ b;
	assign s = q[0] ^ cin;
	assign q[1] = a & b;

endmodule
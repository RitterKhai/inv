//basic_logic
module prefix_logic(ql,qh,r);
	
	input	[1:0]	ql;
	input	[1:0]	qh;
	output	[1:0]	r;
	
	assign r[0] = qh[0] & ql[0];
	assign r[1] = (qh[0] & ql[1]) | qh[1];
	
endmodule
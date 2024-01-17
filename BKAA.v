`define INPUTSIZE 256		//set the input size n
`define GROUPSIZE 8		  //set the group size = 1, 2, 4, 8 or 16

module BKAA(
	input wire                      clk,reset,
	input	wire  [`INPUTSIZE - 1:0]  A,
	input	wire  [`INPUTSIZE - 1:0]  B,
	input                           C_in,
	output wire [`INPUTSIZE - 1:0]  Sum,
	output wire                     Cout
	);
	
	
	wire  [`INPUTSIZE - 1:0]		   S;
	wire  [`INPUTSIZE - 1:0]		   S_tmp;
	wire	[`INPUTSIZE / `GROUPSIZE * 2 - 1:0]	r;
	//wire	[`INPUTSIZE / `GROUPSIZE * 2 - 1:0]	r_o; //test
	wire  [`INPUTSIZE / `GROUPSIZE * 2 - 1:0] r_out;	
	wire	[`INPUTSIZE / `GROUPSIZE * 2 - 1:0]	r_temp;
	wire	[`INPUTSIZE / `GROUPSIZE * 2 - 1:0]	r_temp_out;
	wire	[`INPUTSIZE / `GROUPSIZE:0]			cin;
	wire	[`INPUTSIZE / `GROUPSIZE:0]			cin_out;
	//wire                                      C_in_out;
	wire	[`INPUTSIZE / `GROUPSIZE * 2 - 1:0]	q;
	//wire	[`INPUTSIZE / `GROUPSIZE * 2 - 1:0]	q_temp; //test
	wire	[`INPUTSIZE / `GROUPSIZE * 2 - 1:0]	q_out;	
	//wire  [`INPUTSIZE - 1:0]  A_out, B_out; //original
	//wire  [`INPUTSIZE - 1:0]  A_o, B_o;
	//wire	[`INPUTSIZE / `GROUPSIZE:0] cin_o;
	
	assign cin[0] = C_in;
	//assign cin_out[0] = C_in_out;
	
	generate
	genvar i;
	
		register2 #(.Groupsize(`GROUPSIZE)) //orignal
		r0(.clk(clk),
		   .reset(reset),
		   .data_in(cin[0]),
		   .data_out(cin_out[0])
		  );
		  
		/*register2 #(.Groupsize(`GROUPSIZE)) //test
		r0c(.clk(clk),
		   .reset(reset),
		   .data_in(cin_out[0]),
		   .data_out(cin_o[0])
		  );*/

	/*for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: registerA
		register3 #(.Groupsize(`GROUPSIZE))
		r1(.clk(clk),
		  .reset(reset),
		  .data_in(A[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .data_out(A_out[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i])
		);
	end*/
	
	/*for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: registerA1 //test
		register3 #(.Groupsize(`GROUPSIZE))
		r1a(.clk(clk),
		  .reset(reset),
		  .data_in(A_out[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .data_out(A_o[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i])
		);
	end*/
	
	/*for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: registerB
		register3 #(.Groupsize(`GROUPSIZE))
		r2(.clk(clk),
		  .reset(reset),
		  .data_in(B[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .data_out(B_out[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i])
		);
	end*/
		
	/*for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: registerB1 //test
		register3 #(.Groupsize(`GROUPSIZE))
		r2b(.clk(clk),
		  .reset(reset),
		  .data_in(B_out[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .data_out(B_o[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i])
		);
	end*/	
	
	/*for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: parallel_FA_CLA_prefix //orginal
		group_q_generation #(.Groupsize(`GROUPSIZE))
		f(.a(A_out[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .b(B_out[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .cin(cin_out[i]),
		  .s(S_tmp[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .qg(q[i * 2 + 1:i * 2]));
	end*/
	
	for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: parallel_FA_CLA_prefix //test
		group_q_generation #(.Groupsize(`GROUPSIZE))
		f(.a(A[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .b(B[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .cin(cin_out[i]),
		  .s(S_tmp[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .qg(q[i * 2 + 1:i * 2]));
	end
	
	/*for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: parallel_FA_CLA_prefix //test
		group_q_generation #(.Groupsize(`GROUPSIZE))
		f(.a(A_o[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .b(B_o[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .cin(cin_o[i]),
		  .s(S_tmp[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		  .qg(q[i * 2 + 1:i * 2]));
	end*/
	
	for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: registerP0  //original
		register3 #(.Groupsize(`GROUPSIZE))
		r3(.clk(clk),
		   .reset(reset),
		   .data_in(S_tmp[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i]),
		   .data_out(S[`GROUPSIZE * (i + 1) - 1:`GROUPSIZE * i])
		  );
	end	
	
	for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: registerP
		register1 #(.Groupsize(`GROUPSIZE))
		r4(.clk(clk),
		   .reset(reset),
		   .data_in(q[i * 2 + 1:i * 2]),
		   .data_out(q_out[i * 2 + 1:i * 2])
		  );
	end
	
	parallel_prefix_tree_first_half #(.Treesize(`INPUTSIZE / `GROUPSIZE))
	t1(.q(q_out[`INPUTSIZE / `GROUPSIZE * 2 - 1:0]),
	   .r(r_temp[`INPUTSIZE / `GROUPSIZE * 2 - 1:0])
		);
		
	
	for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: registerP1 //original
		register1 #(.Groupsize(`GROUPSIZE))
		r5(.clk(clk),
		   .reset(reset),
		   .data_in(r_temp[2 * i + 1:2 * i]),
		   .data_out(r_temp_out[2 * i + 1:2 * i])
		  );
	end
	
	parallel_prefix_tree_second_half #(.Treesize(`INPUTSIZE / `GROUPSIZE)) //original
	t2(.q(r_temp_out[`INPUTSIZE / `GROUPSIZE * 2 - 1:0]),
	   .r(r[`INPUTSIZE / `GROUPSIZE * 2 - 1:0])
		); 
		
	/*parallel_prefix_tree_second_half #(.Treesize(`INPUTSIZE / `GROUPSIZE)) //test
	t2(.q(r_temp[`INPUTSIZE / `GROUPSIZE * 2 - 1:0]),
	   .r(r[`INPUTSIZE / `GROUPSIZE * 2 - 1:0])
		);*/

	for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: registerC
		register1 #(.Groupsize(`GROUPSIZE))
		r6(.clk(clk),
		   .reset(reset),
		   .data_in(r[2 * i + 1:2 * i]),
		   .data_out(r_out[2 * i + 1:2 * i])
		  );
	end
	
	for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: cin_generation
		cin_generation_logic f(	.r(r_out[2 * i + 1:2 * i]),
										.c0(C_in),
										.cin(cin[i + 1]));
	end
	
	for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: registerD
		register2 #(.Groupsize(`GROUPSIZE))
		r7(.clk(clk),
		   .reset(reset),
		   .data_in(cin[i + 1]),
		   .data_out(cin_out[i + 1])
		  );
	end

	/*for(i = 0;i < `INPUTSIZE / `GROUPSIZE;i = i + 1) begin: registerD1 //test
		register2 #(.Groupsize(`GROUPSIZE))
		r7c(.clk(clk),
		   .reset(reset),
		   .data_in(cin_out[i + 1]),
		   .data_out(cin_o[i + 1])
		  );
	end*/
		
	assign Sum    = S[`INPUTSIZE - 1:0]; //original
	//assign Sum    = S_tmp[`INPUTSIZE - 1:0];
	assign Cout = cin_out[32]; //original
	//assign Cout = cin_o[32]; //test
	endgenerate
endmodule
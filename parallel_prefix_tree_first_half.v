module parallel_prefix_tree_first_half #(parameter Treesize = 256 / 8)(q,r);

	//input clk, reset; //test pipeline
	input	[Treesize * 2 - 1:0]	q;
	output	[Treesize * 2 - 1:0]	r;
	
	//wire  [Treesize * 2 - 1:0]	r_temp_temp;
	
	generate
	genvar i;
	if(Treesize == 2) begin: trival_case
		assign r[1:0] = q[1:0];
		
		prefix_logic f(.ql(q[1:0]),
							.qh(q[3:2]),
							.r(r[3:2])
							);
	end
	else begin: recursive_case
		wire	[Treesize * 2 - 1:0]	r_temp;
		//reg   [Treesize * 2 - 1:0]	r_temp_temp;
		
		parallel_prefix_tree_first_half #(.Treesize(Treesize / 2))
		recursion_lsbh(.q(q[Treesize - 1:0]),
							.r(r_temp[Treesize - 1:0])
							);
							
		parallel_prefix_tree_first_half #(.Treesize(Treesize / 2))
		recursion_msbh(.q(q[Treesize * 2 - 1:Treesize]),
							.r(r_temp[Treesize * 2 - 1:Treesize])
							);
		
		for(i = 0;i < Treesize * 2;i = i + 2) begin: parallel_stitch_up
			if(i != Treesize * 2 - 2) begin: parallel_stitch_up_pass
				assign r[i + 1:i] = r_temp[i + 1:i];
			end
			else begin: parallel_stitch_up_produce
				prefix_logic f(.ql(r_temp[Treesize - 1:Treesize - 2]),
									.qh(r_temp[Treesize * 2 - 1:Treesize * 2 - 2]),
									.r(r[Treesize * 2 - 1:Treesize * 2 - 2])
									);
			end
		end
	end
	endgenerate
	
endmodule
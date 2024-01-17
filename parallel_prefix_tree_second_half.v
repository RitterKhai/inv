module parallel_prefix_tree_second_half #(parameter Treesize = 256 / 8)(q,r);

	input	[Treesize * 2 - 1:0]	q;
	output	[Treesize * 2 - 1:0]	r;
	
	wire	[Treesize * 2 * ($clog2(Treesize) - 1) - 1:0]	r_temp;
	
	assign r_temp[Treesize * 2 - 1:0] = q[Treesize * 2 - 1:0];
	
	generate
	genvar i, j;
	for(i = 0;i < $clog2(Treesize) - 2;i = i + 1) begin: second_half_level
		assign r_temp[Treesize * 2 * (i + 1) + ((Treesize / (2 ** i)) - 1 - 2 ** ($clog2(Treesize / 4) - i)) * 2 - 1:Treesize * 2 * (i + 1)] = r_temp[Treesize * 2 * i + ((Treesize / (2 ** i)) - 1 - 2 ** ($clog2(Treesize / 4) - i)) * 2 - 1:Treesize * 2 * i];
		for(j = (Treesize / (2 ** i)) - 1 - 2 ** ($clog2(Treesize / 4) - i);j < Treesize;j = j + 2 ** ($clog2(Treesize / 2) - i)) begin: second_half_level_logic
			prefix_logic f(.ql(r_temp[Treesize * 2 * i + (j - 2 ** ($clog2(Treesize / 4) - i)) * 2 + 1:Treesize * 2 * i + (j - 2 ** ($clog2(Treesize / 4) - i)) * 2]),
						   .qh(r_temp[Treesize * 2 * i + j * 2 + 1:Treesize * 2 * i + j * 2]),
						   .r(r_temp[Treesize * 2 * (i + 1) + j * 2 + 1:Treesize * 2 * (i + 1) + j * 2]));
			if(j != Treesize - 1 - 2 ** ($clog2(Treesize / 4) - i)) begin: second_half_level_direct_connect
				assign r_temp[Treesize * 2 * (i + 1) + (j + 2 ** ($clog2(Treesize / 2) - i)) * 2 - 1:Treesize * 2 * (i + 1) + j * 2 + 2] = r_temp[Treesize * 2 * i + (j + 2 ** ($clog2(Treesize / 2) - i)) * 2 - 1:Treesize * 2 * i + j * 2 + 2];
			end
		end
		assign r_temp[Treesize * 2 * (i + 2) - 1:Treesize * 2 * (i + 2) - (2 ** ($clog2(Treesize / 4) - i)) * 2] = r_temp[Treesize * 2 * (i + 1) - 1:Treesize * 2 * (i + 1) - (2 ** ($clog2(Treesize / 4) - i)) * 2];
	end
	assign r[1:0] = r_temp[Treesize * 2 * ($clog2(Treesize) - 2) + 1:Treesize * 2 * ($clog2(Treesize) - 2)];
	for(i = 1;i < Treesize;i = i + 2) begin: final_r_odd
		assign r[i * 2 + 1:i * 2] = r_temp[Treesize * 2 * ($clog2(Treesize) - 2) + i * 2 + 1:Treesize * 2 * ($clog2(Treesize) - 2) + i * 2];
	end
	for(i = 2;i < Treesize;i = i + 2) begin: final_r_even
		prefix_logic f(.ql(r_temp[Treesize * 2 * ($clog2(Treesize) - 2) + i * 2 - 1:Treesize * 2 * ($clog2(Treesize) - 2) + i * 2 - 2]),
					   .qh(r_temp[Treesize * 2 * ($clog2(Treesize) - 2) + i * 2 + 1:Treesize * 2 * ($clog2(Treesize) - 2) + i * 2]),
					   .r(r[i * 2 + 1:i * 2]));
	end
	endgenerate
	
endmodule
module compare_256bit (
   input  logic [W-1:0] a,
   input  logic [W-1:0] b,

   output logic         eq,
   output logic         gt,
   output logic         lt
);
parameter W = 256;
/* verilator lint_off UNUSED */

logic [7:0] eq_temp;
logic [7:0] gt_temp;
logic [7:0] lt_temp;

assign eq = eq_temp[0] & eq_temp[1] & eq_temp[2] & eq_temp[3] & eq_temp[4] & eq_temp[5] & eq_temp[6] & eq_temp[7];
assign gt = gt_temp[7] | (eq_temp[7] & gt_temp[6]) | (eq_temp[7] & eq_temp[6] & gt_temp[5]) |
            (eq_temp[7] & eq_temp[6] & eq_temp[5] & gt_temp[4]) |
            (eq_temp[7] & eq_temp[6] & eq_temp[5] & eq_temp[4] & gt_temp[3]) |
            (eq_temp[7] & eq_temp[6] & eq_temp[5] & eq_temp[4] & eq_temp[3] & gt_temp[2]) |
            (eq_temp[7] & eq_temp[6] & eq_temp[5] & eq_temp[4] & eq_temp[3] & eq_temp[2] & gt_temp[1]) |
            (eq_temp[7] & eq_temp[6] & eq_temp[5] & eq_temp[4] & eq_temp[3] & eq_temp[2] & eq_temp[1] & gt_temp[0]);
assign lt = (!eq&!gt);
				
compare_32bit compare_0 (.a(a[31:0]   ), .b(b[31:0]   ), .eq(eq_temp[0]), .gt(gt_temp[0]), .lt(lt_temp[0]));
compare_32bit compare_1 (.a(a[63:32]  ), .b(b[63:32]  ), .eq(eq_temp[1]), .gt(gt_temp[1]), .lt(lt_temp[1]));
compare_32bit compare_2 (.a(a[95:64]  ), .b(b[95:64]  ), .eq(eq_temp[2]), .gt(gt_temp[2]), .lt(lt_temp[2]));
compare_32bit compare_3 (.a(a[127:96] ), .b(b[128:96] ), .eq(eq_temp[3]), .gt(gt_temp[3]), .lt(lt_temp[3]));
compare_32bit compare_4 (.a(a[159:128]), .b(b[159:128]), .eq(eq_temp[4]), .gt(gt_temp[4]), .lt(lt_temp[4]));
compare_32bit compare_5 (.a(a[191:160]), .b(b[191:160]), .eq(eq_temp[5]), .gt(gt_temp[5]), .lt(lt_temp[5]));
compare_32bit compare_6 (.a(a[223:192]), .b(b[223:192]), .eq(eq_temp[6]), .gt(gt_temp[6]), .lt(lt_temp[6]));
compare_32bit compare_7 (.a(a[255:224]), .b(b[255:224]), .eq(eq_temp[7]), .gt(gt_temp[7]), .lt(lt_temp[7]));

endmodule

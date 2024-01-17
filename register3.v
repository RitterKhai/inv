module register3 #(parameter Groupsize = 8) (
    input wire clk,      // Clock input
    input wire reset,    // Reset input
    input wire  [7:0] data_in,  // Data input (8 bits)
    output wire [7:0] data_out  // Data output (8 bits)
);

    reg [7:0] reg_data;  // 8-bit register data
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            reg_data <= 8'b0;  // Reset the register to 0
        end else begin
            reg_data <= data_in;  // Load data on each clock edge
        end
    end

    assign data_out = reg_data;  // Output is the register data

endmodule
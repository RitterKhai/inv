module register1 #(parameter Groupsize = 8) (
    input wire clk,      // Clock input
    input wire reset,    // Reset input
    input wire  [1:0] data_in,  // Data input (1 bits)
    output wire [1:0] data_out  // Data output (1 bits)
);

    reg [1:0] reg_data;  // 4-bit register data
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            reg_data <= 2'b00;  // Reset the register to 0
        end else begin
            reg_data <= data_in;  // Load data on each clock edge
        end
    end

    assign data_out = reg_data;  // Output is the register data

endmodule
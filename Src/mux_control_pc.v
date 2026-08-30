`timescale 1ns / 1ps

module mux_control_pc(
    input branch, jump, jalr, zero,
    input [31:0] result_alu,
    input [31:0] adder_pc_four,
    input [31:0] immediate_pc,
    output reg [31:0] nextPC
);

wire branch_taken = branch & zero;
wire [31:0] jalr_target = {result_alu[31:1], 1'b0};

always @(*) begin
    if (jalr) begin
        nextPC = jalr_target;
    end
    else if (branch_taken | jump) begin
        nextPC = immediate_pc;
    end
    else
        nextPC = adder_pc_four;
    end
end

endmodule

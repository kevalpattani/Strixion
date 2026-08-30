`timescale 1ns / 1ps

module imm_gen(
    input [31:0] instruction,
    output reg [31:0] instruction_out
);

always @(*) begin
    case(instruction[6:0])
        7'b0010011: instruction_out = {{20{instruction[31]}}, instruction[31:20]}; // I - type -> ADDI and all
        7'b0000011: instruction_out = {{20{instruction[31]}}, instruction[31:20]}; // I - type -> all types of load
        7'b1100111: instruction_out = {{20{instruction[31]}}, instruction[31:20]}; // I - type -> JALR
        7'b0100011: instruction_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // S - type
        7'b1100011: instruction_out = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // B - type 
        7'b0110111: instruction_out = {instruction[31:12], 12'b0}; // U - type -> LUI
        7'b0010111: instruction_out = {instruction[31:12], 12'b0}; // U - type -> AUIPC
        7'b1101111: instruction_out = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0}; // UJ - type -> JAL
        default: instruction_out = {{20{instruction[31]}}, instruction[31:20]};
    endcase
end
endmodule

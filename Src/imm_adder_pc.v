`timescale 1ns / 1ps

module imm_adder_pc(
    input [31:0] PC, Imm,
    output [31:0] immPC
);

assign immPC = PC + $signed(Imm);

endmodule

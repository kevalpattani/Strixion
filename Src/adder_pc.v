`timescale 1ns / 1ps

module adder_pc( // this going to memtoreg for the direct save for JAL and JALR
    input [31:0] PC,
    output [31:0] incPC
);

assign incPC = PC + 4;
    
endmodule

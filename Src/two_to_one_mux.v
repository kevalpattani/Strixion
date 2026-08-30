`timescale 1ns / 1ps

module two_to_one_mux(
    input [31:0] A,
    input [31:0] B,
    input select_line,
    output [31:0] result
    );
    
assign result = select_line ? A : B;
    
endmodule

`timescale 1ns / 1ps

module three_to_one_mux(
    input [31:0] A,
    input [31:0] B,
    input [31:0] C,
    input [1:0] select_line,
    output [31:0] result
    );
    
assign result = select_line[1] ? C : (select_line[0] ? B : A);
    
endmodule

`timescale 1ns / 1ps

module adder_ALU(
    input [31:0] A,B,
    output reg [31:0] sum
    );

always @(*) 
begin
    sum = A + B;
end
    
endmodule

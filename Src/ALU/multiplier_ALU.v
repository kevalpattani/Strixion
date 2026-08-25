`timescale 1ns / 1ps

module multiplier_ALU(
    input [31:0] a, b,
    input [1:0] func3,
    output reg [31:0] result_sum
);

reg is_signed_a, is_signed_b;
reg signed [32:0] ext_a, ext_b;
reg signed [65:0] product;

always @(*) begin

/*
       Src_A    Src_B
MUL - signed x signed - Lower 32                                   
MULH - signed x signed - Upper 32
MULHSU - signed x unsigned - Upper 32      
MULHU - unsigned x unsigned - Upper 32

so this hardware cannot support Src_A as unsigned and Src_B as signed. (simple is faster principal is applied here)
*/

is_signed_a = (func3 == 2'b01) | (func3 == 2'b10); // 1 is for the signed and 0 for unsigned 
is_signed_b = (func3 == 2'b01); // same logic here

ext_a = {(is_signed_a & a[31]), a};
ext_b = {(is_signed_b & b[31]), b};

product = ext_a * ext_b;

if (func3 == 2'b00) begin
    result_sum = product[31:0];
end
else
begin
    result_sum = product[63:32];
end

end

endmodule

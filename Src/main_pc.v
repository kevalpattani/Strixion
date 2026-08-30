`timescale 1ns / 1ps

module main_pc(
    input clk, rst,
    input [31:0] nextPC,
    output reg [31:0] PC
);
    
always @(posedge clk) begin
    if (~rst)
        PC <= 0 ;
    else 
        PC <= nextPC;
end
    
endmodule

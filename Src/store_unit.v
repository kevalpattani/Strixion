`timescale 1ns / 1ps

module store_unit(
    input [1:0] alu_result_last_bits,
    input [1:0] instruction_type,
    output [3:0] data_bytewise_select
);

/*
|   Instruction   |   funct3 [14:12]   |
| --------------- | ------------------ |
| **SB**          | `00`               |
| **SH**          | `01`               |
| **SW**          | `10`               |
*/

assign data_bytewise_select = (instruction_type == 2'b00) ? 
                              ((alu_result_last_bits[0] == 1'b1) ?                                                                     
                               (/* X 1 */(alu_result_last_bits[1] == 1'b1) ? 4'b1000 /* 4th bit -> 11*/ : 4'b0010 /* 2nd bit -> 01*/) :
                               (/* X 0 */(alu_result_last_bits[1] == 1'b1) ? 4'b0100 /* 3rd bit -> 10*/ : 4'b0001 /* 1st bit -> 00*/)) :
                              ((instruction_type == 2'b01) ? ((alu_result_last_bits[1] == 1'b1) ? 4'b1100 : 4'b0011) : 4'b1111);

endmodule

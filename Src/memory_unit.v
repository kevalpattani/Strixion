`timescale 1ns / 1ps

module memory_unit( // Dual-Port hehe
    input clk, rst,
    // Port One 
    input [31:0] inst_addr,
    output [31:0] inst_read_data, // its wire cause its reads are combinational
    // Port Two
    input read_enable,
    input write_enable,
    input [31:0] data_addr,
    input [31:0] data_write_data, 
    input [3:0] data_bytewise_select, // all four bytes of these will help for writing a specific byte(s) or loading a specific byte(s)
    output [31:0] data_read_data
);

reg [31:0] main_memory [2047:0];

assign inst_read_data = main_memory[inst_addr >> 2]; // combinational read

/*

Purpose of >> 2:
-> The last two bits of any 32 bit address represents the specific byte (anyone from 4) of a word
-> By eliminating it we get straight ahead the word which is needed for the memory
-> But aren't memories are byte-addressable? Yes they do but writing reg [7:0] memory_unit [Width-1:0] is too many wires and connections,
so we create word sized only but then we add options to only change or get individual byte by input [3:0] data_bytewise_select

-> this is a example
CPU Byte Address,  Binary,   Shifted Right (>> 2),    Verilog RAM Index

0                  ...0000        ...00 (0)             main_memory[0]
1                  ...0001        ...00 (0)             main_memory[0]
2                  ...0010        ...00 (0)             main_memory[0]
3                  ...0011        ...00 (0)             main_memory[0]
4                  ...0100        ...01 (1)             main_memory[1]
5                  ...0101        ...01 (1)             main_memory[1]
6                  ...0110        ...01 (1)             main_memory[1]
7                  ...0111        ...01 (1)             main_memory[1]


*/

assign data_read_data = (read_enable) ? main_memory[data_addr >> 2] : 32'b0;

always @(posedge clk) begin
        if (write_enable) begin
            if (data_bytewise_select[0]) begin
                main_memory[data_addr >> 2][7:0] <= data_write_data[7:0];
            end
            if (data_bytewise_select[1]) begin
                main_memory[data_addr >> 2][15:8] <= data_write_data[15:8];
            end
            if (data_bytewise_select[2]) begin
                main_memory[data_addr >> 2][23:16] <= data_write_data[23:16];
            end
            if (data_bytewise_select[3]) begin
                main_memory[data_addr >> 2][31:24] <= data_write_data[31:24];
            end
        end
    end
    
end

endmodule

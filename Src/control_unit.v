`timescale 1ns / 1ps

module control_unit(
    input [31:0] instruction, 
    output reg ALUsrc_a, ALUsrc_b, // for the input lines for the ALU source A and B
    output reg [1:0] MemtoReg, // adding PC + 4 for JAL and JALR
    output reg ALUop, // for alu_control
    output reg RegWrite, memWrite, memRead, // for register and the memory
    output reg jal, jalr, branch, // for the mux_control_pc
    output reg [2:0] load_instruction_type, // for LSU unit
    output reg [1:0] store_instruction_type // for the standalone store_unit
);

/*

for any questions u can contact me via mail at kevalpattani 123 [at] gmail [dot] com

MemtoReg 0 -> ALU result
         1 -> Memory result
         2 -> PC + 4

ALUsrc_a 0 -> read_data_1
         1 -> PC

ALUsrc_b 0 -> read_data_2
         1 -> Immediate

*/

always @(*) begin
    ALUsrc_a = 1'b0;
    ALUsrc_b = 1'b0;
    MemtoReg = 2'b0;
    ALUop = 1'b0;
    RegWrite = 1'b0;
    memWrite = 1'b0;
    memRead = 1'b0;
    jal = 1'b0;
    jalr = 1'b0;
    branch = 1'b0;
    load_instruction_type = 3'b0;
    store_instruction_type = 2'b0;
    
    if (instruction[6:0] == 7'b0110011) begin // all the R-type
        ALUsrc_a = 1'b0;
        ALUsrc_b = 1'b0;
        MemtoReg = 2'b0;
        ALUop = 1'b1;
        RegWrite = 1'b1;
        memWrite = 1'b0;
        memRead = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;
        branch = 1'b0;
        load_instruction_type = 3'b0;
        store_instruction_type = 2'b0;
    end
    else if (instruction[6:0] == 7'b0010011) begin // all the I-type (R - type with immediate)
        ALUsrc_a = 1'b0;
        ALUsrc_b = 1'b1;
        MemtoReg = 2'b0;
        ALUop = 1'b1;
        RegWrite = 1'b1;
        memWrite = 1'b0;
        memRead = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;
        branch = 1'b0;
        load_instruction_type = 3'b0;
        store_instruction_type = 2'b0;
    end
    else if (instruction[6:0] == 7'b0000011) begin // all the I-type Load
        ALUsrc_a = 1'b0;
        ALUsrc_b = 1'b1;
        MemtoReg = 2'b01;
        ALUop = 1'b1;
        RegWrite = 1'b1;
        memWrite = 1'b0;
        memRead = 1'b1;
        jal = 1'b0;
        jalr = 1'b0;
        branch = 1'b0;
        store_instruction_type = 2'b0;
        load_instruction_type = {instruction[14],instruction[13],instruction[12]};
    end
    else if (instruction[6:0] == 7'b1100111) begin // JALR
        ALUsrc_a = 1'b0;
        ALUsrc_b = 1'b1;
        MemtoReg = 2'b10;
        ALUop = 1'b1;
        RegWrite = 1'b1;
        memWrite = 1'b0;
        memRead = 1'b0;
        jal = 1'b0;
        jalr = 1'b1;
        branch = 1'b0;
        store_instruction_type = 2'b0;
        load_instruction_type = 3'b0;
    end
    else if (instruction[6:0] == 7'b0100011) begin // Store
        ALUsrc_a = 1'b0;
        ALUsrc_b = 1'b1;
        MemtoReg = 2'b0;
        ALUop = 1'b1;
        RegWrite = 1'b0;
        memWrite = 1'b1;
        memRead = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;
        branch = 1'b0;
        store_instruction_type = {instruction[13],instruction[12]};
        load_instruction_type = 3'b0;
    end
    else if (instruction[6:0] == 7'b1100011) begin // Branch B-type
        ALUsrc_a = 1'b0;
        ALUsrc_b = 1'b0;
        MemtoReg = 2'b0;
        ALUop = 1'b1;
        RegWrite = 1'b0;
        memWrite = 1'b0;
        memRead = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;
        branch = 1'b1;
        store_instruction_type = 2'b0;
        load_instruction_type = 3'b0;
    end
    else if (instruction[6:0] == 7'b0110111) begin // LUI
        ALUsrc_a = 1'b0;
        ALUsrc_b = 1'b1;
        MemtoReg = 2'b0;
        ALUop = 1'b1;
        RegWrite = 1'b1;
        memWrite = 1'b0;
        memRead = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;
        branch = 1'b0;
        store_instruction_type = 2'b0;
        load_instruction_type = 3'b0;
    end
    else if (instruction[6:0] == 7'b0010111) begin // AUIPC
        ALUsrc_a = 1'b1;
        ALUsrc_b = 1'b1;
        MemtoReg = 2'b0;
        ALUop = 1'b1;
        RegWrite = 1'b1;
        memWrite = 1'b0;
        memRead = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;
        branch = 1'b0;
        store_instruction_type = 2'b0;
        load_instruction_type = 3'b0;
    end
    else if (instruction[6:0] == 7'b1101111) begin // JAL
        ALUsrc_a = 1'b0;
        ALUsrc_b = 1'b0;
        MemtoReg = 2'b10;
        ALUop = 1'b0;
        RegWrite = 1'b1;
        memWrite = 1'b0;
        memRead = 1'b0;
        jal = 1'b1;
        jalr = 1'b0;
        branch = 1'b0;
        store_instruction_type = 2'b0;
        load_instruction_type = 3'b0;
    end
    else begin
        ALUsrc_a = 1'b0;
        ALUsrc_b = 1'b0;
        MemtoReg = 2'b0;
        ALUop = 1'b1;
        RegWrite = 1'b1;
        memWrite = 1'b0;
        memRead = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;
        branch = 1'b0;
        load_instruction_type = 3'b0;
        store_instruction_type = 2'b0;
    end
end

endmodule

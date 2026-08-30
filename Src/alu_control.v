`timescale 1ns / 1ps

module alu_control(
    input [2:0] func3,
    input [6:0] opcode,
    input func7_30th_bit, func7_25th_bit,
    output reg [4:0] alucontrol,
    output reg branch_token
    );
    
/*
| **Instruction** | **Opcode [6:0]** | **funct3 [14:12]** | **funct7 [31:25]** |
| --------------- | ---------------- | ------------------ | ------------------ |
| **MUL**         | `0110011`        | `000`              | `0000001`          |
| **MULH**        | `0110011`        | `001`              | `0000001`          |
| **MULHSU**      | `0110011`        | `010`              | `0000001`          |
| **MULHU**       | `0110011`        | `011`              | `0000001`          |
| **DIV**         | `0110011`        | `100`              | `0000001`          |
| **DIVU**        | `0110011`        | `101`              | `0000001`          |
| **REM**         | `0110011`        | `110`              | `0000001`          |
| **REMU**        | `0110011`        | `111`              | `0000001`          |

10000,                  MUL,         mul (Multiply lower 32 bits)
10001,                  MULH,        mulh (Multiply high 32 bits - Signed)
10010,                  MULHSU,      mulhsu (Multiply high - Signed/Unsigned)
10011,                  MULHU,       mulhu (Multiply high 32 bits - Unsigned)
10100,                  DIV,         div (Divide - Signed)
10101,                  DIVU,        divu (Divide - Unsigned)
10110,                  REM,         rem (Remainder - Signed)
10111,                  REMU,        remu (Remainder - Unsigned)
*/
    
always @(*) begin
    alucontrol = 5'b00010;
    branch_token = 1'b0;
    
    if (opcode == 7'b0110011) begin // R - type
        branch_token = 1'b0;
        if (func7_25th_bit) begin
            case(func3)
                3'b000: alucontrol = 5'b10000; // MUL   
                3'b001: alucontrol = 5'b10001; // MULH  
                3'b010: alucontrol = 5'b10010; // MULHSU
                3'b011: alucontrol = 5'b10011; // MULHU 
                3'b100: alucontrol = 5'b10100; // DIV  
                3'b101: alucontrol = 5'b10101; // DIVU  
                3'b110: alucontrol = 5'b10110; // REM   
                3'b111: alucontrol = 5'b10111; // REMU  
            endcase
        end
        
        /*
        |   Instruction   |   Opcode [6:0]   |   funct3 [14:12]   |   funct7 [31:25]   |
        | --------------- | ---------------- | ------------------ | ------------------ |
        | **ADD**         | `0110011`        | `000`              | `0000000`          |
        | **SUB**         | `0110011`        | `000`              | `0100000`          |
        | **SLL**         | `0110011`        | `001`              | `0000000`          |
        | **SLT**         | `0110011`        | `010`              | `0000000`          |
        | **SLTU**        | `0110011`        | `011`              | `0000000`          |
        | **XOR**         | `0110011`        | `100`              | `0000000`          |
        | **SRL**         | `0110011`        | `101`              | `0000000`          |
        | **SRA**         | `0110011`        | `101`              | `0100000`          |
        | **OR**          | `0110011`        | `110`              | `0000000`          |
        | **AND**         | `0110011`        | `111`              | `0000000`          |
        
        ALU Control,         Operation,   Corresponding RISC-V Instructions
        00000,                  AND,         and, andi
        00001,                  OR,          or, ori
        00010,                  ADD,         add, addi, lw, sw, auipc, jal
        00011,                  XOR,         xor, xori
        00100,                  SLL,         sll, slli (Shift Left Logical)
        00101,                  SRL,         srl, srli (Shift Right Logical)
        00110,                  SUB,         sub, beq, bne (Subtraction / Compare)
        00111,                  SRA,         sra, srai (Shift Right Arithmetic)
        01000,                  SLT,         slt, slti, blt, bge (Set Less Than - Signed)
        01001,                  SLTU,        sltu, sltiu, bltu, bgeu (Set Less Than - Unsigned)
        */
        
        else begin
            case (func3)
                3'b000: alucontrol = (func7_30th_bit) ? 5'b00110 : 5'b00010; // SUB : ADD
                3'b001: alucontrol = 5'b00100; // SLL
                3'b010: alucontrol = 5'b01000; // SLT
                3'b011: alucontrol = 5'b01001; // SLTU
                3'b100: alucontrol = 5'b00011; // XOR
                3'b101: alucontrol = (func7_30th_bit) ? 5'b00111 : 5'b00101; // SRA : SRL
                3'b110: alucontrol = 5'b00001; // OR
                3'b111: alucontrol = 5'b00000; // AND
            endcase
        end
    end
    else if (opcode == 7'b0010011) begin // I - type -> ADDI and all
        branch_token = 1'b0;
        /*
        | **Instruction** | **Opcode [6:0]** | **funct3 [14:12]** | **funct7 [31:25] (if applicable)** |
        | --------------- | ---------------- | ------------------ | ---------------------------------- |
        | **ADDI**        | `0010011`        | `000`              | N/A                                |
        | **SLTI**        | `0010011`        | `010`              | N/A                                |
        | **SLTIU**       | `0010011`        | `011`              | N/A                                |
        | **XORI**        | `0010011`        | `100`              | N/A                                |
        | **ORI**         | `0010011`        | `110`              | N/A                                |
        | **ANDI**        | `0010011`        | `111`              | N/A                                |
        | **SLLI**        | `0010011`        | `001`              | `0000000` _(Immediate modifier)_   |
        | **SRLI**        | `0010011`        | `101`              | `0000000` _(Immediate modifier)_   |
        | **SRAI**        | `0010011`        | `101`              | `0100000` _(Immediate modifier)_   |
        */
        
        case (func3)
            3'b000: alucontrol = 5'b00010; // ADD
            3'b001: alucontrol = 5'b00100; // SLL
            3'b010: alucontrol = 5'b01000; // SLT
            3'b011: alucontrol = 5'b01001; // SLTU
            3'b100: alucontrol = 5'b00011; // XOR
            3'b101: alucontrol = (func7_30th_bit) ? 5'b00111 : 5'b00101; // SRA : SRL
            3'b110: alucontrol = 5'b00001; // OR
            3'b111: alucontrol = 5'b00000; // AND
        endcase
        
    end
    else if (opcode == 7'b0000011) begin // I - type -> load
        branch_token = 1'b0;
        alucontrol = 5'b00010; // ADD
    end
    else if (opcode == 7'b1100111) begin // I - type -> JALR
        branch_token = 1'b0;
        alucontrol = 5'b00010; // ADD
    end
    else if (opcode == 7'b0100011) begin // S - type
        branch_token = 1'b0;
        alucontrol = 5'b00010; // ADD
    end
    else if (opcode == 7'b1100011) begin // B - type
        /*
        | **Instruction** | **Opcode [6:0]** | **funct3 [14:12]** | **funct7** |
        | --------------- | ---------------- | ------------------ | ---------- |
        | **BEQ**         | `1100011`        | `000`              | N/A        |
        | **BNE**         | `1100011`        | `001`              | N/A        |
        | **BLT**         | `1100011`        | `100`              | N/A        |
        | **BGE**         | `1100011`        | `101`              | N/A        |
        | **BLTU**        | `1100011`        | `110`              | N/A        |
        | **BGEU**        | `1100011`        | `111`              | N/A        |
        
        00110,                  SUB,         sub, beq, bne (Subtraction / Compare)
        01000,                  SLT,         slt, slti, blt, bge (Set Less Than - Signed)
        01001,                  SLTU,        sltu, sltiu, bltu, bgeu (Set Less Than - Unsigned)
        */
        
        case(func3)
            3'b000: begin // BEQ
                alucontrol = 5'b00110;
                branch_token = 1'b0;
            end
            3'b001: begin // BNE
                alucontrol = 5'b00110;
                branch_token = 1'b1;
            end
            3'b100: begin // BLT
                alucontrol = 5'b01000;
                branch_token = 1'b0;
            end
            3'b101: begin // BGE
                alucontrol = 5'b01000;
                branch_token = 1'b1;
            end
            3'b110: begin // BLTU
                alucontrol = 5'b01001;
                branch_token = 1'b0;
            end
            3'b111: begin // BGEU
                alucontrol = 5'b01001;
                branch_token = 1'b1;
            end
        endcase 
    end
    else if (opcode == 7'b0110111) begin // LUI
        branch_token = 1'b0;
        alucontrol = 5'b00010; // ADD
    end
    else if (opcode == 7'b0010111) begin // AUIPC
        branch_token = 1'b0;
        alucontrol = 5'b00010; // ADD
    end
    else if (opcode == 7'b1101111) begin // JAL
        branch_token = 1'b0;
        alucontrol = 5'b00010; // ADD
    end
end
  
endmodule

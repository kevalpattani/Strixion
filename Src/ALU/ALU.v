`timescale 1ns / 1ps

/*

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
10000,                  MUL,         mul (Multiply lower 32 bits)
10001,                  MULH,        mulh (Multiply high 32 bits - Signed)
10010,                  MULHSU,      mulhsu (Multiply high - Signed/Unsigned)
10011,                  MULHU,       mulhu (Multiply high 32 bits - Unsigned)
10100,                  DIV,         div (Divide - Signed)
10101,                  DIVU,        divu (Divide - Unsigned)
10110,                  REM,         rem (Remainder - Signed)
10111,                  REMU,        remu (Remainder - Unsigned)

*/

module ALU(
    input [31:0] Src_A, Src_B,
    input [4:0] alucontrol,
    output reg [31:0] result_alu    
);

wire [31:0] result_add;
wire [31:0] result_sub;
wire [31:0] result_mul;
wire [31:0] result_div;

adder_ALU add(.A(Src_A),.B(Src_B),.sum(result_add));
sub_ALU sub(.A(Src_A),.B(Src_B),.sum(result_sub));
multiplier_ALU mul(.a(Src_A),.b(Src_B),.func3(alucontrol[1:0]),.result_sum(result_mul));
divider_ALU div(.a(Src_A),.b(Src_B),.func3(alucontrol[1:0]),.result_sum(result_div));

always @(*)
begin
    casex(alucontrol)
        5'b00000: begin
            result_alu = Src_A & Src_B; 
        end
        5'b00001: begin
            result_alu = Src_A | Src_B;
        end
        5'b00010: begin
            result_alu = result_add;
        end
        5'b00011: begin
            result_alu = Src_A ^ Src_B;
        end
        5'b00100: begin
            result_alu = Src_A << Src_B[4:0];
        end
        5'b00101: begin
            result_alu = Src_A >> Src_B[4:0];
        end
        5'b00110: begin
            result_alu = result_sub;
        end
        5'b00111: begin
            result_alu = $signed(Src_A) >>> Src_B[4:0]; // $signed is added cause otherwise the operation will not be the arithematic shift, it will be logical shift 
        end
        5'b01000: begin
            if ($signed(Src_A) < $signed(Src_B)) begin
                result_alu = 32'b1;
            end
            else begin
                result_alu = 32'b0;
            end
        end
        5'b01001: begin
            if (Src_A < Src_B) begin
                result_alu = 32'b1;
            end
            else begin
                result_alu = 32'b0;
            end
        end
        
        /*
                  Src_A     Src_B
            MUL - signed x signed - Lower 32                                   
            MULH - signed x signed - Upper 32
            MULHSU - signed x unsigned - Upper 32      
            MULHU - unsigned x unsigned - Upper 32 
        */
        
        5'b100xx: begin
            result_alu = result_mul;
        end
        
        5'b101xx: begin // division all
            result_alu = result_div;
        end
        
        default: begin
            result_alu = 32'b0;
        end
                
    endcase
end

endmodule

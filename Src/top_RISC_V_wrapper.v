`timescale 1ns / 1ps

module top_RISC_V_wrapper(
    input clk, rst
);

wire [31:0] pc_next;
wire [31:0] pc_current;


main_pc PC(.clk(clk),.rst(rst),.nextPC(pc_next),.PC(pc_current));

wire [31:0] instruction;
wire read_enable;
wire write_enable;
wire [31:0] data_addr;
wire [31:0] data_write_data;
wire [3:0] data_bytewise_select;
wire [31:0] data_read_data;
memory_unit memory(.clk(clk),.rst(rst),.inst_addr(pc_current),.inst_read_data(instruction),.read_enable(read_enable),.write_enable(write_enable),.data_addr(data_addr),.data_write_data(data_write_data),.data_bytewise_select(data_bytewise_select),.data_read_data(data_read_data));

wire regWrite;
wire [31:0] toSaveInRegister;
wire [31:0] read_data_1;
wire [31:0] read_data_2;
reg_file regFile(.clk(clk),.WE(regWrite),.rs1(instruction[19:15]),.rs2(instruction[24:20]),.rd(instruction[11:7]),.write_data(toSaveInRegister),.read_data1(read_data_1),.read_data2(read_data_2));

wire [31:0] immediate_out;
imm_gen immediateUnit(.instruction(instruction),.instruction_out(immediate_out));

wire ALUsrc_a_control_line, ALUsrc_b_control_line;
wire [31:0] Src_A, Src_B;
two_to_one_mux twoToOneSrcA(.A(pc_current),.B(read_data_1),.select_line(ALUsrc_a_control_line),.result(Src_A));
two_to_one_mux twoToOneSrcB(.A(immediate_out),.B(read_data_2),.select_line(ALUsrc_b_control_line),.result(Src_B));

wire [4:0] alucontrol;
wire branch_token;
alu_control aluControl(.func3(instruction[14:12]),.opcode(instruction[6:0]),.func7_30th_bit(instruction[30]),.func7_25th_bit(instruction[25]),.alucontrol(alucontrol),.branch_token(branch_token));

wire [31:0] result_alu;
wire zero_pin;
wire ALUop;
ALU ALU(.ALUop(ALUop),.Src_A(Src_A),.Src_B(Src_B),.alucontrol(alucontrol),.branch_token(branch_token),.result_alu(result_alu),.zero_pin(zero_pin));

wire [1:0] MemtoReg;
wire jal, jalr, branch;
wire [2:0] load_instruction_type;
wire [1:0] store_instruction_type;
control_unit controlUnit(.instruction(instruction),.ALUsrc_a(ALUsrc_a_control_line),.ALUsrc_b(ALUsrc_b_control_line),.MemtoReg(MemtoReg),.ALUop(ALUop),.RegWrite(regWrite),.memWrite(write_enable),.memRead(read_enable),.jal(jal),.jalr(jalr),.branch(branch),.load_instruction_type(load_instruction_type),.store_instruction_type(store_instruction_type));

wire [3:0] data_bytewise_select;
store_unit storeUnit(.alu_result_last_bits(result_alu[1:0]),.instruction_type(store_instruction_type),.data_bytewise_select(data_bytewise_select));

wire [31:0] data_out_from_memory;
lsu_unit lsuUnit(.data_in(data_read_data),.alu_result_last_bits(result_alu[1:0]),.instruction_type(load_instruction_type),.data_out(data_out_from_memory));

wire [31:0] pc_plus_four;
wire [31:0] pc_plus_immediate;
adder_pc pcPlusFour(.PC(pc_current),.incPC(pc_plus_four));
imm_adder_pc pcImm(.PC(pc_current),.Imm(immediate_out),.immPC(pc_plus_immediate));


mux_control_pc pcSelect(.branch(branch),.jump(jal),.jalr(jalr),.zero(zero_pin),.result_alu(result_alu),.adder_pc_four(pc_plus_four),.immediate_pc(pc_plus_immediate),.nextPC(pc_next));

three_to_one_mux memtoreg(.A(result_alu),.B(data_out_from_memory),.C(pc_plus_four),.select_line(MemtoReg),.result(pc_next));

endmodule

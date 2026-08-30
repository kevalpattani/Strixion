`timescale 1ns / 1ps

module lsu_unit(
    input [31:0] data_in,
    input [1:0] alu_result_last_bits,
    input [2:0] instruction_type,
    output reg [31:0] data_out
); 

/*
| LB  | 000 |
| LH  | 001 |
| LW  | 010 |
| LBU | 100 |
| LHU | 101 |

-> alu_result_last_bits determines which byte(s) depending on the result of the ALU for the address
*/

always @(*) begin

    data_out = 32'b0;
    
    case (instruction_type)
        3'b000: begin // Load - Byte Signed
            data_out = (alu_result_last_bits[0] == 1'b1) ? 
                       (/* X 1 */(alu_result_last_bits[1] == 1'b1) ? {{24{data_in[31]}},data_in[31:24]}/* 4th bit -> 11*/ : {{24{data_in[15]}},data_in[15:8]}/* 2nd bit -> 01*/) :
                       (/* X 0 */(alu_result_last_bits[1] == 1'b1) ? {{24{data_in[23]}},data_in[23:16]}/* 3rd bit -> 10*/ : {{24{data_in[7]}},data_in[7:0]}/* 1st bit -> 00*/);
        end
        3'b001: begin // Load - HalfWord Signed
            data_out = (alu_result_last_bits[1] == 1'b1) ? {{16{data_in[31]}},data_in[31:16]} : {{16{data_in[15]}},data_in[15:0]};
        end
        3'b010: begin
            data_out = data_in;
        end
        3'b100: begin
            data_out = (alu_result_last_bits[0] == 1'b1) ? 
                       (/* X 1 */(alu_result_last_bits[1] == 1'b1) ? {{24{1'b0}},data_in[31:24]}/* 4th bit -> 11*/ : {{24{1'b0}},data_in[15:8]}/* 2nd bit -> 01*/) :
                       (/* X 0 */(alu_result_last_bits[1] == 1'b1) ? {{24{1'b0}},data_in[23:16]}/* 3rd bit -> 10*/ : {{24{1'b0}},data_in[7:0]}/* 1st bit -> 00*/);
        end
        3'b101: begin
            data_out = (alu_result_last_bits[1] == 1'b1) ? {{16{1'b0}},data_in[31:16]} : {{16{1'b0}},data_in[15:0]};
        end
    endcase
    
end

endmodule

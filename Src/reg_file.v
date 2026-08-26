`timescale 1ns / 1ps

module reg_file(
    input clk, WE, // WE = Write Enable
    input [4:0] rs1, rs2, rd,
    input [31:0] write_data,
    output [31:0] read_data1, read_data2
);

reg [31:0] registers [0:31];

always @(posedge clk) begin
    
    if (WE & (rd != 5'b00000)) begin // 5'b0 is checking if the destination registers is x0 or not
        registers[rd] <= write_data;
    end
    
end

assign read_data1 = (rs1 == 5'b00000) ? 32'b0 : registers[rs1];
assign read_data2 = (rs2 == 5'b00000) ? 32'b0 : registers[rs2];

endmodule

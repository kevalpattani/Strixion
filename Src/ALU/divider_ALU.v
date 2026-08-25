`timescale 1ns / 1ps

module divider_ALU(
    input [31:0] a, b,
    input [1:0] func3,
    output reg [31:0] result_sum
);

reg [31:0] updated_a, updated_b;
reg [31:0] intm_quotient, intm_remainder, quotient, remainder; // intm = intermidiate

/*

For signed:
| dividend a | divisor b | quotient sign |
| ---------- | --------- | ------------- |
|  +         |  +        |  +            |
|  +         |  -        |  -            |
|  -         |  +        |  -            |
|  -         |  -        |  +            |

also remainder always takes the sign of the dividend

For unsigned: 
anything works!

*/

always @(*) begin

if(b == 32'b0) begin
    quotient = 32'hFFFFFFFF; // -1
    remainder = a;
end
else
begin
    if (func3[0] == 1'b0) begin
        if (a[31] == 1'b1) begin
            updated_a = ~a + 1;
        end
        else
        begin
            updated_a = a;
        end
        
        if (b[31] == 1'b1) begin
            updated_b = ~b + 1;
        end
        else
        begin
            updated_b = b;
        end
        
        intm_quotient = updated_a / updated_b;
        intm_remainder = updated_a % updated_b;
        
        if (a[31] == 1'b0 & b[31] == 1'b0) begin
            quotient = intm_quotient;
            remainder = intm_remainder;
        end
        
        if (a[31] == 1'b0 & b[31] == 1'b1) begin
            quotient = ~intm_quotient + 1;
            remainder = intm_remainder;
        end
        
        if (a[31] == 1'b1 & b[31] == 1'b0) begin
            quotient = ~intm_quotient + 1;
            remainder = ~intm_remainder + 1;
        end
        
        if (a[31] == 1'b1 & b[31] == 1'b1) begin
            quotient = intm_quotient;
            remainder = ~intm_remainder + 1;
        end
        
    end
    else
    begin    // unsigned part
        quotient = a / b;
        remainder = a % b;
    end

if (func3[1] == 1'b0) begin
        result_sum = quotient;
    end else begin
        result_sum = remainder;
    end
end

end

endmodule

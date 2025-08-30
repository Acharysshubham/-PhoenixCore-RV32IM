`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/27/2025 07:49:23 AM
// Design Name: 
// Module Name: mult_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module mult_unit (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,      // From control unit
    input  wire [31:0] op1, op2,    // Operands from register file
    output reg         done,       // To pipeline control
    output reg  [31:0] result      // To write-back stage
);
    reg [5:0] count;
    reg [63:0] product;

    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            done <= 1'b0;
        end else if (start) begin
            product <= {32'b0, op1};
            count <= 32;
            done <= 1'b0;
        end else if (count > 0) begin
            // Simple shift-and-add algorithm
            if (product[0]) begin
                product <= (product >> 1) + {op2, 32'b0};
            end else begin
                product <= product >> 1;
            end
            count <= count - 1;
            if (count == 1) begin
                done <= 1'b1;
                result <= product[31:0];
            end
        end
    end
endmodule
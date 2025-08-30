`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2025 08:10:43 PM
// Design Name: 
// Module Name: mem_wb_register
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
module mem_wb_register(
    input  wire        clk, 
    input  wire        rst,
    input  wire [31:0] mem_data_in,
    input  wire [31:0] alu_result_in,
    input  wire [4:0]  rd_in,
    input  wire        reg_write_in, 
    input  wire        mem_to_reg_in,
    input  wire        mult_start_in, // <<< ADDITION
    output reg  [31:0] mem_data_out,
    output reg  [31:0] alu_result_out,
    output reg  [4:0]  rd_out,
    output reg         reg_write_out, 
    output reg         mem_to_reg_out,
    output reg         mult_start_out // <<< ADDITION
);

    always @(posedge clk) begin
        if (rst) begin
            mem_data_out <= 0; 
            alu_result_out <= 0; 
            rd_out <= 0;
            reg_write_out <= 0; 
            mem_to_reg_out <= 0;
            mult_start_out <= 0; // <<< ADDITION
        end else begin
            mem_data_out <= mem_data_in; 
            alu_result_out <= alu_result_in; 
            rd_out <= rd_in;
            reg_write_out <= reg_write_in; 
            mem_to_reg_out <= mem_to_reg_in;
            mult_start_out <= mult_start_in; // <<< ADDITION
        end
    end
endmodule
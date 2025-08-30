`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2025 08:09:35 PM
// Design Name: 
// Module Name: ex_mem_register
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
module ex_mem_register(
    input  wire        clk, 
    input  wire        rst,
    input  wire [31:0] alu_result_in,
    input  wire [31:0] write_data_in,
    input  wire [4:0]  rd_in,
    input  wire        reg_write_in, 
    input  wire        mem_write_in, 
    input  wire        mem_to_reg_in,
    input  wire        mult_start_in, // <<< ADDITION
    output reg  [31:0] alu_result_out,
    output reg  [31:0] write_data_out,
    output reg  [4:0]  rd_out,
    output reg         reg_write_out, 
    output reg         mem_write_out, 
    output reg         mem_to_reg_out,
    output reg         mult_start_out // <<< ADDITION
);
    
    always @(posedge clk) begin
        if (rst) begin
            alu_result_out <= 0; 
            write_data_out <= 0; 
            rd_out <= 0;
            reg_write_out <= 0; 
            mem_write_out <= 0; 
            mem_to_reg_out <= 0;
            mult_start_out <= 0; // <<< ADDITION
        end else begin
            alu_result_out <= alu_result_in; 
            write_data_out <= write_data_in; 
            rd_out <= rd_in;
            reg_write_out <= reg_write_in; 
            mem_write_out <= mem_write_in; 
            mem_to_reg_out <= mem_to_reg_in;
            mult_start_out <= mult_start_in; // <<< ADDITION
        end
    end
endmodule
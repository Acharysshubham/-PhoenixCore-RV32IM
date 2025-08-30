`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2025 08:08:58 PM
// Design Name: 
// Module Name: id_ex_register
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
module id_ex_register (
    input  wire        clk,
    input  wire        rst,
    input  wire        flush,

    // Inputs from ID Stage
    input  wire [31:0] pc_in,
    input  wire [31:0] reg_data1_in,
    input  wire [31:0] reg_data2_in,
    input  wire [31:0] imm_out_in,
    input  wire [4:0]  rs1_in,
    input  wire [4:0]  rs2_in,
    input  wire [4:0]  rd_in,
    input  wire [2:0]  funct3_in,
    input  wire        is_branch_in,
    input  wire        alu_src_in,
    input  wire        a_sel_in,
    input  wire [3:0]  alu_op_in,
    input  wire        reg_write_in,
    input  wire        mem_write_in,
    input  wire        mem_to_reg_in,
    input  wire        branch_unsigned_in,
    input  wire        mult_start_in, // <<< ADDITION

    // Outputs to EX Stage
    output reg  [31:0] pc_out,
    output reg  [31:0] reg_data1_out,
    output reg  [31:0] reg_data2_out,
    output reg  [31:0] imm_out_out,
    output reg  [4:0]  rs1_out,
    output reg  [4:0]  rs2_out,
    output reg  [4:0]  rd_out,
    output reg  [2:0]  funct3_out,
    output reg         is_branch_out,
    output reg         alu_src_out,
    output reg         a_sel_out,
    output reg  [3:0]  alu_op_out,
    output reg         reg_write_out,
    output reg         mem_write_out,
    output reg         mem_to_reg_out,
    output reg         branch_unsigned_out,
    output reg         mult_start_out // <<< ADDITION
);
    
    always @(posedge clk) begin
        if (rst || flush) begin
            // Reset all outputs to a known safe state (NOP)
            pc_out              <= 32'b0;
            reg_data1_out       <= 32'b0;
            reg_data2_out       <= 32'b0;
            imm_out_out         <= 32'b0;
            rs1_out             <= 5'b0;
            rs2_out             <= 5'b0;
            rd_out              <= 5'b0;
            funct3_out          <= 3'b0;
            is_branch_out       <= 1'b0;
            alu_src_out         <= 1'b0;
            a_sel_out           <= 1'b0;
            alu_op_out          <= 4'b0;
            reg_write_out       <= 1'b0;
            mem_write_out       <= 1'b0;
            mem_to_reg_out      <= 1'b0;
            branch_unsigned_out <= 1'b0;
            mult_start_out      <= 1'b0; // <<< ADDITION
        end else begin
            // Pass inputs to outputs on clock edge
            pc_out              <= pc_in;
            reg_data1_out       <= reg_data1_in;
            reg_data2_out       <= reg_data2_in;
            imm_out_out         <= imm_out_in;
            rs1_out             <= rs1_in;
            rs2_out             <= rs2_in;
            rd_out              <= rd_in;
            funct3_out          <= funct3_in;
            is_branch_out       <= is_branch_in;
            alu_src_out         <= alu_src_in;
            a_sel_out           <= a_sel_in;
            alu_op_out          <= alu_op_in;
            reg_write_out       <= reg_write_in;
            mem_write_out       <= mem_write_in;
            mem_to_reg_out      <= mem_to_reg_in;
            branch_unsigned_out <= branch_unsigned_in;
            mult_start_out      <= mult_start_in; // <<< ADDITION
        end
    end
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2025 08:12:18 PM
// Design Name: 
// Module Name: forwarding_unit
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

module forwarding_unit (
    // Inputs: Destination registers from MEM and WB stages
    input wire [4:0]  rd_mem,
    input wire [4:0]  rd_wb,
    input wire        reg_write_mem, // Control signal from EX/MEM
    input wire        reg_write_wb,  // Control signal from MEM/WB

    // Inputs: Source registers for the ALU in EX stage
    input wire [4:0]  rs1_ex,
    input wire [4:0]  rs2_ex,

    // Outputs: Select signals for ALU input MUXes
    output wire [1:0] forward_a,
    output wire [1:0] forward_b
);

    // Logic to check for forwarding opportunities
    // Example for forward_a (ALU operand 1)
    assign forward_a = (reg_write_mem && (rd_mem != 5'b0) && (rd_mem == rs1_ex)) ? 2'b01 : // Forward from MEM stage
                       (reg_write_wb  && (rd_wb  != 5'b0) && (rd_wb  == rs1_ex)) ? 2'b10 : // Forward from WB stage
                                                                                    2'b00; // No forwarding

    // Similar logic for forward_b (ALU operand 2)
    assign forward_b = (reg_write_mem && (rd_mem != 5'b0) && (rd_mem == rs2_ex)) ? 2'b01 :
                       (reg_write_wb  && (rd_wb  != 5'b0) && (rd_wb  == rs2_ex)) ? 2'b10 :
                                                                                    2'b00;
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2025 08:11:34 PM
// Design Name: 
// Module Name: hazard_detection_unit
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

module hazard_detection_unit (
    // Inputs
    input wire [4:0]  rs1_id,
    input wire [4:0]  rd_ex,
    input wire        mem_read_ex, // This is mem_to_reg from the control unit in EX stage
    input wire        branch_cond_ex, // From branch_comp
    // Outputs
    output wire       pc_stall,
    output wire       if_id_stall,
    output wire       if_id_flush
);
    // Load-use hazard detection
    wire load_use_hazard = mem_read_ex && (rd_ex != 5'b0) &&
                          ((rd_ex == rs1_id));

    assign pc_stall    = load_use_hazard;
    assign if_id_stall = load_use_hazard;
    assign if_id_flush = branch_cond_ex;

endmodule
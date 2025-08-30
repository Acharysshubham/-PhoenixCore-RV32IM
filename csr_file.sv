`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/27/2025 07:50:29 AM
// Design Name: 
// Module Name: csr_file
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


module csr_file (
    input  wire        clk,
    input  wire        rst,

    // Interface for Exception Trap
    input  wire        trap_i,         // Signal that an exception has occurred
    input  wire [31:0] pc_i,           // Current PC to save to mepc
    input  wire [31:0] cause_i,        // The cause of the exception

    // Interface for CSR Read/Write instructions (future use)
    // input  wire        csr_wren_i,
    // input  wire [11:0] csr_addr_i,
    // input  wire [31:0] csr_wdata_i,
    // output wire [31:0] csr_rdata_o,

    // Direct read ports for debug/verification
    output wire [31:0] mepc_o,
    output wire [31:0] mcause_o
);

    // CSR Registers
    reg [31:0] mepc;   // Machine Exception Program Counter
    reg [31:0] mcause; // Machine Cause Register

    // Assign outputs
    assign mepc_o = mepc;
    assign mcause_o = mcause;

    // Sequential logic for writing to CSRs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mepc   <= 32'b0;
            mcause <= 32'b0;
        end else if (trap_i) begin
            // On an exception, latch the PC and the cause
            mepc   <= pc_i;
            mcause <= cause_i;
        end
        // Add logic for CSR read/write instructions here in the future
    end
    
endmodule

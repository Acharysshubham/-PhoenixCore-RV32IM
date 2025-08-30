`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2025 08:07:54 PM
// Design Name: 
// Module Name: if_id_register
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

module if_id_register (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,
    input  wire        flush,
    input  wire [31:0] pc_in,
    input  wire [31:0] inst_in,
    output reg  [31:0] pc_out,
    output reg  [31:0] inst_out
);
    // Synchronous Reset Logic
    always @(posedge clk) begin
        if (rst) begin
            pc_out   <= 32'b0;
            inst_out <= 32'b0;
        end else if (flush) begin      // <<< FIX: Changed { to begin
            pc_out   <= 32'b0;
            inst_out <= 32'b0;      // Flush to a NOP
        end                             // <<< FIX: Changed } to end
        else if (!stall) begin     // <<< FIX: Changed { to begin
            pc_out   <= pc_in;
            inst_out <= inst_in;
        end                             // <<< FIX: Changed } to end
    end
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2025 08:07:16 PM
// Design Name: 
// Module Name: program_counter
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

module program_counter (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc_out
);
    // Convert to Synchronous Reset
    always @(posedge clk) begin
        if (rst)
            pc_out <= 32'd0;
        else if (!stall)
            pc_out <= pc_next;
    end
endmodule
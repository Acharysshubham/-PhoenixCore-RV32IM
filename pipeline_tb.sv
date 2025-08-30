`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2025 08:16:09 PM
// Design Name: 
// Module Name: pipeline_tb
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

module pipeline_tb;

    reg clk;
    reg reset;

    pipeline_cpu uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
   // Test sequence
    initial begin
        reset = 1;
        #15;
        reset = 0;
        #500000; // Run simulation for 500 ns
        $finish;
    end

    // Optional: Monitor signals for debugging
    initial begin
        $monitor("Time=%0t | PC_IF=%h | Inst_ID=%h | ALU_Res_EX=%h | Data_Mem_Out=%h | WB_Data=%h, RegWrite=%b",
                 $time, uut.pc_if, uut.instruction_id, uut.alu_result_ex, uut.data_mem_out_mem, uut.write_data_wb, uut.reg_write_wb);
    end

endmodule
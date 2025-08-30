`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/27/2025 07:31:11 AM
// Design Name: 
// Module Name: advanced_tb
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

module advanced_tb;
    // Testbench signals
    reg clk;
    reg rst_n; // Active low reset

    // AXI Interface signals
    reg  [11:0] awaddr;
    reg         awvalid;
    wire        awready;
    reg  [31:0] wdata;
    reg  [3:0]  wstrb;
    reg         wvalid;
    wire        wready;
    wire [1:0]  bresp;
    wire        bvalid;
    reg         bready;
    reg  [11:0] araddr;
    reg         arvalid;
    wire        arready;
    wire [31:0] rdata;
    wire [1:0]  rresp;
    wire        rvalid;
    reg         rready;

    // Wires to monitor the CPU's write-back stage
    wire        cpu_reg_write;
    wire [4:0]  cpu_rd_addr;
    wire [31:0] cpu_write_data;

    // Instantiate the Design Under Test (DUT)
    phoenix_core_top dut (
        .S_AXI_ACLK(clk),
        .S_AXI_ARESETN(rst_n),
        .S_AXI_AWADDR(awaddr),
        .S_AXI_AWVALID(awvalid),
        .S_AXI_AWREADY(awready),
        .S_AXI_WDATA(wdata),
        .S_AXI_WSTRB(wstrb),
        .S_AXI_WVALID(wvalid),
        .S_AXI_WREADY(wready),
        .S_AXI_BRESP(bresp),
        .S_AXI_BVALID(bvalid),
        .S_AXI_BREADY(bready),
        .S_AXI_ARADDR(araddr),
        .S_AXI_ARVALID(arvalid),
        .S_AXI_ARREADY(arready),
        .S_AXI_RDATA(rdata),
        .S_AXI_RRESP(rresp),
        .S_AXI_RVALID(rvalid),
        .S_AXI_RREADY(rready),
        .cpu_reg_write_wb_o(cpu_reg_write),
        .cpu_rd_wb_o(cpu_rd_addr),
        .cpu_write_data_wb_o(cpu_write_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // AXI Bus Functional Model Task
    task axi_write(input [11:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            awaddr <= addr;
            awvalid <= 1'b1;
            wdata <= data;
            wvalid <= 1'b1;
            wstrb <= 4'b1111;
            @(posedge clk);
            while (!awready || !wready) begin
                @(posedge clk);
            end
            awvalid <= 1'b0;
            wvalid <= 1'b0;
        end
    endtask
    
    // Main Test Sequence with Scoreboard
    initial begin
        // --- Reference Model for Scoreboard ---
        logic [31:0] register_model [0:31];
        integer i;
        for (i=0; i<32; i=i+1) register_model[i] = 32'b0;

        // 1. Reset Sequence
        awvalid <= 0; wvalid <= 0; arvalid <= 0; bready <= 1; rready <= 1;
        awaddr <= 0; wdata <= 0; wstrb <= 0; araddr <= 0;
        rst_n = 1'b0;
        $display("[%0t] Reset Asserted.", $time);
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        $display("[%0t] Reset De-asserted.", $time);
        @(posedge clk);

        // 2. Load Program and Data via AXI
        $display("[%0t] Loading Program into Instruction Memory...", $time);
        axi_write(12'h000, 32'h00100113); // addi x2, x0, 1
        axi_write(12'h004, 32'h00200193); // addi x3, x0, 2
        axi_write(12'h008, 32'h03310233); // add  x4, x2, x3
        axi_write(12'h00C, 32'h00000293); // addi x5, x0, 0
        axi_write(12'h010, 32'h0002a303); // lw   x6, 0(x5)
        axi_write(12'h014, 32'h00130393); // addi x7, x6, 1
        axi_write(12'h018, 32'h03430433); // add  x8, x6, x4
        
        $display("[%0t] Loading Data into Data Memory...", $time);
        axi_write(12'h800, 32'hdeadbeef);

        $display("[%0t] Program Loaded. Running CPU and checking results...", $time);

        // --- 3. Scoreboard: Run and Check ---
        // For each instruction that writes a register, wait for the write-back
        // event and check if the data is correct.

        // Check for: addi x2, x0, 1
        @(posedge cpu_reg_write);
        if (cpu_rd_addr === 5'd2 && cpu_write_data === 32'd1) begin
            $display("PASS: addi x2, x0, 1");
            register_model[2] = cpu_write_data;
        end else $error("FAIL: addi x2, x0, 1. Got Addr: x%0d, Data: %h", cpu_rd_addr, cpu_write_data);

        // Check for: addi x3, x0, 2
        @(posedge cpu_reg_write);
        if (cpu_rd_addr === 5'd3 && cpu_write_data === 32'd2) begin
            $display("PASS: addi x3, x0, 2");
            register_model[3] = cpu_write_data;
        end else $error("FAIL: addi x3, x0, 2. Got Addr: x%0d, Data: %h", cpu_rd_addr, cpu_write_data);
        
        // Check for: add x4, x2, x3
        @(posedge cpu_reg_write);
        if (cpu_rd_addr === 5'd4 && cpu_write_data === (register_model[2] + register_model[3])) begin
            $display("PASS: add x4, x2, x3");
            register_model[4] = cpu_write_data;
        end else $error("FAIL: add x4, x2, x3. Got Addr: x%0d, Data: %h", cpu_rd_addr, cpu_write_data);

        // Check for: addi x5, x0, 0
        @(posedge cpu_reg_write);
        if (cpu_rd_addr === 5'd5 && cpu_write_data === 32'd0) begin
            $display("PASS: addi x5, x0, 0");
            register_model[5] = cpu_write_data;
        end else $error("FAIL: addi x5, x0, 0. Got Addr: x%0d, Data: %h", cpu_rd_addr, cpu_write_data);

        // Check for: lw x6, 0(x5)
        @(posedge cpu_reg_write);
        if (cpu_rd_addr === 5'd6 && cpu_write_data === 32'hdeadbeef) begin
            $display("PASS: lw x6, 0(x5)");
            register_model[6] = cpu_write_data;
        end else $error("FAIL: lw x6, 0(x5). Got Addr: x%0d, Data: %h", cpu_rd_addr, cpu_write_data);

        // Check for: addi x7, x6, 1
        @(posedge cpu_reg_write);
        if (cpu_rd_addr === 5'd7 && cpu_write_data === (register_model[6] + 1)) begin
            $display("PASS: addi x7, x6, 1");
            register_model[7] = cpu_write_data;
        end else $error("FAIL: addi x7, x6, 1. Got Addr: x%0d, Data: %h", cpu_rd_addr, cpu_write_data);

        // Check for: add x8, x6, x4
        @(posedge cpu_reg_write);
        if (cpu_rd_addr === 5'd8 && cpu_write_data === (register_model[6] + register_model[4])) begin
            $display("PASS: add x8, x6, x4");
            register_model[8] = cpu_write_data;
        end else $error("FAIL: add x8, x6, x4. Got Addr: x%0d, Data: %h", cpu_rd_addr, cpu_write_data);

        #200; // Wait for any final instructions to finish
        $display("----------------------------------------------------");
        $display("All checks complete. Test Finished.");
        $display("----------------------------------------------------");
        $finish;
    end
endmodule
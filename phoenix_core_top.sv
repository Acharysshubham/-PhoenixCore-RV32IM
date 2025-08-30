`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/27/2025 07:35:04 AM
// Design Name: 
// Module Name: phoenix_core_top
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


module phoenix_core_top #(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 12
)
(
    // AXI4-Lite Slave Interface
    input  wire                          S_AXI_ACLK,
    input  wire                          S_AXI_ARESETN,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input  wire                          S_AXI_AWVALID,
    output wire                          S_AXI_AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
    input  wire                          S_AXI_WVALID,
    output wire                          S_AXI_WREADY,
    output wire [1:0]                    S_AXI_BRESP,
    output wire                          S_AXI_BVALID,
    input  wire                          S_AXI_BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input  wire                          S_AXI_ARVALID,
    output wire                          S_AXI_ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output wire [1:0]                    S_AXI_RRESP,
    output wire                          S_AXI_RVALID,
    input  wire                          S_AXI_RREADY,
    
    // Outputs for verification
    output wire                          cpu_reg_write_wb_o,
    output wire [4:0]                    cpu_rd_wb_o,
    output wire [31:0]                   cpu_write_data_wb_o
);

    // Internal wires to connect CPU and AXI interface
    wire [31:0] inst_addr_w;
    wire [31:0] inst_data_w;
    wire [31:0] data_addr_w;
    wire [31:0] data_wdata_w;
    wire        data_mem_rw_w;
    wire [31:0] data_rdata_w;
    
    // Instantiate the CPU Core
    pipeline_cpu cpu_core (
        .clk(S_AXI_ACLK),
        .reset(~S_AXI_ARESETN),
        .inst_addr_o(inst_addr_w),
        .inst_data_i(inst_data_w),
        .data_addr_o(data_addr_w),
        .data_wdata_o(data_wdata_w),
        .data_mem_rw_o(data_mem_rw_w),
        .data_rdata_i(data_rdata_w),

        // <<< FIX: Connect to the new output ports from the CPU
        .reg_write_wb(cpu_reg_write_wb_o),
        .rd_wb(cpu_rd_wb_o),
        .write_data_wb(cpu_write_data_wb_o)
    );

    // Instantiate the AXI Interface and Memories
    axi_lite_interface axi_if (
        .S_AXI_ACLK(S_AXI_ACLK),
        .S_AXI_ARESETN(S_AXI_ARESETN),
        .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WDATA(S_AXI_WDATA),
        .S_AXI_WSTRB(S_AXI_WSTRB),
        .S_AXI_WVALID(S_AXI_WVALID),
        .S_AXI_WREADY(S_AXI_WREADY),
        .S_AXI_BRESP(S_AXI_BRESP),
        .S_AXI_BVALID(S_AXI_BVALID),
        .S_AXI_BREADY(S_AXI_BREADY),
        .S_AXI_ARADDR(S_AXI_ARADDR),
        .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_ARREADY(S_AXI_ARREADY),
        .S_AXI_RDATA(S_AXI_RDATA),
        .S_AXI_RRESP(S_AXI_RRESP),
        .S_AXI_RVALID(S_AXI_RVALID),
        .S_AXI_RREADY(S_AXI_RREADY),
        .inst_addr(inst_addr_w),
        .inst_data(inst_data_w),
        .data_addr(data_addr_w),
        .data_wdata(data_wdata_w),
        .data_mem_rw(data_mem_rw_w),
        .data_rdata(data_rdata_w)
    );

    // NOTE: The assign statements were removed from here because the
    // connections are now made directly in the cpu_core instantiation above.

endmodule

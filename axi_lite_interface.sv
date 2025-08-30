`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/27/2025 07:27:30 AM
// Design Name: 
// Module Name: axi_lite_interface
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


module axi_lite_interface #(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 12
)
(
    // AXI4-Lite Signals
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

    // Interface to CPU Core Memories
    input  wire [31:0]                   inst_addr,
    output wire [31:0]                   inst_data,
    input  wire [31:0]                   data_addr,
    input  wire [31:0]                   data_wdata,
    input  wire                          data_mem_rw,
    output wire [31:0]                   data_rdata
);

    // <<< FIX: Internal registers to drive the data memory for AXI writes
    reg [31:0] dmem_addr_from_axi;
    reg [31:0] dmem_wdata_from_axi;
    reg        dmem_rw_from_axi;

    // A MUX is needed to select between CPU access and AXI access
    wire [31:0] final_dmem_addr  = S_AXI_AWVALID ? dmem_addr_from_axi  : data_addr;
    wire [31:0] final_dmem_wdata = S_AXI_AWVALID ? dmem_wdata_from_axi : data_wdata;
    wire        final_dmem_rw    = S_AXI_AWVALID ? dmem_rw_from_axi    : data_mem_rw;

    // Instantiate Memories
    inst_mem imem (.addr(inst_addr), .inst(inst_data));
    data_mem dmem (
        .clk(S_AXI_ACLK),
        .addr(final_dmem_addr),     // <<< FIX: Connect to the MUXed signals
        .dataW(final_dmem_wdata),   // <<< FIX: Connect to the MUXed signals
        .funct3(3'b010),            // Assuming word access
        .MemRW(final_dmem_rw),      // <<< FIX: Connect to the MUXed signals
        .dataR(data_rdata)
    );

    // AXI internal signals
    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr;
    reg                          axi_awready;
    reg                          axi_wready;
    reg [1:0]                    axi_bresp;
    reg                          axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr;
    reg                          axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;
    reg [1:0]                    axi_rresp;
    reg                          axi_rvalid;

    // AXI Assignments
    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = axi_bresp;
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA   = axi_rdata;
    assign S_AXI_RRESP   = axi_rresp;
    assign S_AXI_RVALID  = axi_rvalid;

    // AXI Write Logic
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_awready <= 1'b0;
            axi_wready  <= 1'b0;
            axi_bvalid  <= 1'b0;
            axi_bresp   <= 2'b0;
            dmem_rw_from_axi <= 1'b0;
        end else begin
            // Default to not writing
            dmem_rw_from_axi <= 1'b0;

            if (~axi_awready && S_AXI_AWVALID) begin
                axi_awaddr  <= S_AXI_AWADDR;
                axi_awready <= 1'b1;
            end else begin
                axi_awready <= 1'b0;
            end
            
            if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID) begin
                axi_wready <= 1'b1;
            end else begin
                axi_wready <= 1'b0;
            end

            // <<< FIX: Procedural assignments now drive the internal registers
            if (axi_awready && S_AXI_AWVALID && S_AXI_WVALID) begin
                // Simple memory map: use an address bit to select data mem
                if (S_AXI_AWADDR[11]) begin // Data Memory Space
                    dmem_addr_from_axi  <= S_AXI_AWADDR;
                    dmem_wdata_from_axi <= S_AXI_WDATA;
                    dmem_rw_from_axi    <= 1'b1; // Write
                end
            end
            
            if (axi_bvalid && S_AXI_BREADY) begin
                axi_bvalid <= 1'b0;
            end else if (axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID && !axi_bvalid) begin
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b0; // OKAY response
            end
        end
    end

    // AXI Read Logic
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_arready <= 1'b0;
            axi_rvalid  <= 1'b0;
            axi_rresp   <= 2'b0;
            axi_rdata   <= 32'b0;
        end else begin
            if (~axi_arready && S_AXI_ARVALID) begin
                axi_araddr  <= S_AXI_ARADDR;
                axi_arready <= 1'b1;
            end else begin
                axi_arready <= 1'b0;
            end

            if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b0;
                // Read directly from the memory outputs based on address
                if (axi_araddr[11]) // Data Memory
                    axi_rdata <= data_rdata;
                else // Instruction Memory
                    axi_rdata <= inst_data;
            end else if (axi_rvalid && S_AXI_RREADY) begin
                axi_rvalid <= 1'b0;
            end
        end
    end
endmodule
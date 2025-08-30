`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2025 08:05:19 PM
// Design Name: 
// Module Name: pipeline_cpu
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

module pipeline_cpu (
    input  wire        clk,
    input  wire        reset,
    
    // Connections to an external interface (like AXI)
    output wire [31:0] inst_addr_o,
    input  wire [31:0] inst_data_i,
    output wire [31:0] data_addr_o,
    output wire [31:0] data_wdata_o,
    output wire        data_mem_rw_o,
    input  wire [31:0] data_rdata_i,

    // Outputs for verification
    output wire        reg_write_wb,
    output wire [4:0]  rd_wb,
    output wire [31:0] write_data_wb
);

    //----------------------------------------------------------------
    // Internal Signal Declarations
    //----------------------------------------------------------------

    // --- Pipeline Control Wires ---
    wire        pc_stall_d;
    wire        if_id_stall_d;
    wire        if_id_flush_d;
    wire [1:0]  forward_a_e, forward_b_e;
    reg         branch_taken_ex;

    // --- Exception Handling Wires ---
    wire        illegal_instruction_from_cu;
    wire        trap_id;
    wire [31:0] trap_pc_id;
    wire [31:0] trap_cause_id = 32'd2; // Cause 2: Illegal Instruction

    // <<< ADDITION: Wires for Multiplier Integration
    wire        mult_start_from_cu;
    wire        mult_start_ex;
    wire        mult_start_mem;
    wire        mult_start_wb;
    wire        mult_done_wb;
    wire [31:0] mult_result_wb;
    wire        mult_busy;

    // --- IF, ID, EX, MEM, WB Stage Wires ---
    // (These are unchanged)
    wire [31:0] pc_if;
    wire [31:0] pc_plus4_if = pc_if + 4;
    wire [31:0] next_pc_if;
    wire [31:0] instruction_if;
    wire [31:0] pc_id;
    wire [31:0] instruction_id;
    wire [6:0]  opcode_id = instruction_id[6:0];
    wire [4:0]  rs1_id = instruction_id[19:15];
    wire [4:0]  rs2_id = instruction_id[24:20];
    wire [4:0]  rd_id  = instruction_id[11:7];
    wire [2:0]  funct3_id = instruction_id[14:12];
    wire [6:0]  funct7_id = instruction_id[31:25];
    wire [31:0] reg_data1_id, reg_data2_id;
    wire [31:0] imm_out_id;
    wire        alu_src_from_cu, a_sel_from_cu, reg_write_from_cu;
    wire        mem_write_from_cu, mem_to_reg_from_cu, branch_unsigned_from_cu, is_branch_from_cu;
    wire [3:0]  alu_op_from_cu;
    wire [31:0] pc_ex;
    wire [31:0] reg_data1_ex, reg_data2_ex;
    wire [31:0] imm_out_ex;
    wire [4:0]  rs1_ex, rs2_ex, rd_ex;
    wire [2:0]  funct3_ex;
    wire        alu_src_ex, a_sel_ex, reg_write_ex, mem_write_ex, mem_to_reg_ex, branch_unsigned_ex, is_branch_instruction_ex;
    wire [3:0]  alu_op_ex;
    wire [31:0] alu_result_ex;
    wire [31:0] alu_in1_ex, alu_in2_ex;
    wire        br_eq_ex, br_lt_ex;
    wire [31:0] alu_result_mem;
    wire [31:0] mem_write_data_mem;
    wire [31:0] data_mem_out_mem;
    wire        reg_write_mem, mem_write_mem, mem_to_reg_mem;
    wire [4:0]  rd_mem;
    wire [31:0] write_data_wb_mem, write_data_wb_alu;
    wire        mem_to_reg_wb;


    //----------------------------------------------------------------
    // Exception and Pipeline Control Logic
    //----------------------------------------------------------------
    assign trap_id = illegal_instruction_from_cu;
    assign trap_pc_id = pc_id - 4;
    assign if_id_flush_d = branch_taken_ex || trap_id;
    assign next_pc_if = trap_id         ? 32'h0000_0040 :
                        branch_taken_ex ? alu_result_ex : 
                                          pc_plus4_if;

    // <<< MODIFICATION: Pipeline must also stall if multiplier is busy
    wire load_use_hazard = mem_to_reg_ex && (rd_ex != 0) && ((rd_ex == rs1_id) || (rd_ex == rs2_id));
    assign mult_busy = mult_start_ex && !mult_done_wb;
    assign pc_stall_d    = load_use_hazard || mult_busy;
    assign if_id_stall_d = load_use_hazard || mult_busy;

    //----------------------------------------------------------------
    // Stage 1: Instruction Fetch (IF)
    //----------------------------------------------------------------
    assign inst_addr_o = pc_if;
    assign instruction_if = inst_data_i;
    program_counter pc_unit (.clk(clk), .rst(reset), .stall(pc_stall_d), .pc_next(next_pc_if), .pc_out(pc_if));

    //----------------------------------------------------------------
    // IF/ID Pipeline Register
    //----------------------------------------------------------------
    if_id_register if_id_reg (.clk(clk), .rst(reset), .stall(if_id_stall_d), .flush(if_id_flush_d), .pc_in(pc_plus4_if), .inst_in(instruction_if), .pc_out(pc_id), .inst_out(instruction_id));

    //----------------------------------------------------------------
    // Stage 2: Instruction Decode (ID)
    //----------------------------------------------------------------
    reg_file rf (.clk(clk), .write_en(reg_write_wb), .rs1(rs1_id), .rs2(rs2_id), .rsW(rd_wb), .write_data(write_data_wb), .read_data1(reg_data1_id), .read_data2(reg_data2_id));
    imm_gen immgen (.instruction(instruction_id), .imm_out(imm_out_id));
    
    control_unit cu (
        .opcode(opcode_id), .funct3(funct3_id), .funct7(funct7_id), .rd(rd_id), .rs1(rs1_id),
        .alu_src(alu_src_from_cu), .a_sel(a_sel_from_cu), .alu_op(alu_op_from_cu),
        .reg_write_en(reg_write_from_cu), .mem_write(mem_write_from_cu), .mem_to_reg(mem_to_reg_from_cu),
        .branch_unsigned(branch_unsigned_from_cu), .is_branch_instruction(is_branch_from_cu),
        .illegal_instruction(illegal_instruction_from_cu),
        .mult_start_o(mult_start_from_cu) // <<< ADDITION
    );
    
    csr_file csr_unit (.clk(clk), .rst(reset), .trap_i(trap_id), .pc_i(trap_pc_id), .cause_i(trap_cause_id));

    //----------------------------------------------------------------
    // ID/EX Pipeline Register
    //----------------------------------------------------------------
    id_ex_register id_ex_reg (
        .clk(clk), .rst(reset), .flush(trap_id), .pc_in(pc_id),
        .reg_data1_in(reg_data1_id), .reg_data2_in(reg_data2_id), .imm_out_in(imm_out_id),
        .rs1_in(rs1_id), .rs2_in(rs2_id), .rd_in(rd_id), .funct3_in(funct3_id),
        .is_branch_in(is_branch_from_cu), .alu_src_in(alu_src_from_cu), .a_sel_in(a_sel_from_cu),
        .alu_op_in(alu_op_from_cu), .reg_write_in(reg_write_from_cu), .mem_write_in(mem_write_from_cu),
        .mem_to_reg_in(mem_to_reg_from_cu), .branch_unsigned_in(branch_unsigned_from_cu),
        .mult_start_in(mult_start_from_cu), // <<< ADDITION
        .pc_out(pc_ex), .reg_data1_out(reg_data1_ex), .reg_data2_out(reg_data2_ex),
        .imm_out_out(imm_out_ex), .rs1_out(rs1_ex), .rs2_out(rs2_ex), .rd_out(rd_ex),
        .funct3_out(funct3_ex), .is_branch_out(is_branch_instruction_ex), .alu_src_out(alu_src_ex),
        .a_sel_out(a_sel_ex), .alu_op_out(alu_op_ex), .reg_write_out(reg_write_ex),
        .mem_write_out(mem_write_ex), .mem_to_reg_out(mem_to_reg_ex), .branch_unsigned_out(branch_unsigned_ex),
        .mult_start_out(mult_start_ex)      // <<< ADDITION
    );

    //----------------------------------------------------------------
    // Stage 3: Execute (EX)
    //----------------------------------------------------------------
    assign alu_in1_ex = (forward_a_e == 2'b10) ? write_data_wb : (forward_a_e == 2'b01) ? alu_result_mem : (a_sel_ex) ? pc_ex : reg_data1_ex;
    assign alu_in2_ex = (forward_b_e == 2'b10) ? write_data_wb : (forward_b_e == 2'b01) ? alu_result_mem : (alu_src_ex) ? imm_out_ex : reg_data2_ex;

    alu_logic alu (.op1(alu_in1_ex), .op2(alu_in2_ex), .alu_op(alu_op_ex), .result(alu_result_ex));
    branch_comp bc (.a(reg_data1_ex), .b(reg_data2_ex), .BrUn(branch_unsigned_ex), .BrEq(br_eq_ex), .BrLt(br_lt_ex));
    
    // <<< ADDITION: Instantiate the multiplier
    mult_unit multiplier (.clk(clk), .rst(reset), .start(mult_start_ex), .op1(reg_data1_ex), .op2(reg_data2_ex), .done(mult_done_wb), .result(mult_result_wb));

    always @(*) begin
        branch_taken_ex = 1'b0;
        if (is_branch_instruction_ex) begin
            case (funct3_ex)
                3'b000: if (br_eq_ex)  branch_taken_ex = 1'b1;
                3'b001: if (!br_eq_ex) branch_taken_ex = 1'b1;
                3'b100: if (br_lt_ex)  branch_taken_ex = 1'b1;
                3'b101: if (!br_lt_ex) branch_taken_ex = 1'b1;
                3'b110: if (br_lt_ex)  branch_taken_ex = 1'b1;
                3'b111: if (!br_lt_ex) branch_taken_ex = 1'b1;
            endcase
        end
    end

    //----------------------------------------------------------------
    // EX/MEM Pipeline Register
    //----------------------------------------------------------------
    ex_mem_register ex_mem_reg (
        .clk(clk), .rst(reset), .alu_result_in(alu_result_ex), .write_data_in(reg_data2_ex), .rd_in(rd_ex),
        .reg_write_in(reg_write_ex), .mem_write_in(mem_write_ex), .mem_to_reg_in(mem_to_reg_ex),
        .mult_start_in(mult_start_ex), // <<< ADDITION
        .alu_result_out(alu_result_mem), .write_data_out(mem_write_data_mem), .rd_out(rd_mem),
        .reg_write_out(reg_write_mem), .mem_write_out(mem_write_mem), .mem_to_reg_out(mem_to_reg_mem),
        .mult_start_out(mult_start_mem) // <<< ADDITION
    );

    //----------------------------------------------------------------
    // Stage 4: Memory (MEM)
    //----------------------------------------------------------------
    assign data_addr_o = alu_result_mem;
    assign data_wdata_o = mem_write_data_mem;
    assign data_mem_rw_o = mem_write_mem;
    assign data_mem_out_mem = data_rdata_i;

    //----------------------------------------------------------------
    // MEM/WB Pipeline Register
    //----------------------------------------------------------------
    mem_wb_register mem_wb_reg (
        .clk(clk), .rst(reset), .mem_data_in(data_mem_out_mem), .alu_result_in(alu_result_mem), .rd_in(rd_mem),
        .reg_write_in(reg_write_mem), .mem_to_reg_in(mem_to_reg_mem),
        .mult_start_in(mult_start_mem), // <<< ADDITION
        .mem_data_out(write_data_wb_mem), .alu_result_out(write_data_wb_alu), .rd_out(rd_wb),
        .reg_write_out(reg_write_wb), .mem_to_reg_out(mem_to_reg_wb),
        .mult_start_out(mult_start_wb)  // <<< ADDITION
    );

    //----------------------------------------------------------------
    // Stage 5: Write Back (WB)
    //----------------------------------------------------------------
    // <<< MODIFICATION: MUX in the multiplier result for write-back
    assign write_data_wb = mult_start_wb   ? mult_result_wb :
                           mem_to_reg_wb   ? write_data_wb_mem :
                                             write_data_wb_alu;

    //----------------------------------------------------------------
    // Hazard and Forwarding Units
    //----------------------------------------------------------------
    hazard_detection_unit hazard_unit (.rs1_id(rs1_id), .rd_ex(rd_ex), .mem_read_ex(mem_to_reg_ex), .branch_cond_ex(branch_taken_ex), .pc_stall(pc_stall_d), .if_id_stall(if_id_stall_d), .if_id_flush(if_id_flush_d));
    forwarding_unit fwd_unit (.rd_mem(rd_mem), .rd_wb(rd_wb), .reg_write_mem(reg_write_mem), .reg_write_wb(reg_write_wb), .rs1_ex(rs1_ex), .rs2_ex(rs2_ex), .forward_a(forward_a_e), .forward_b(forward_b_e));

endmodule
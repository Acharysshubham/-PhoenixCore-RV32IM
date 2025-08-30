`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2025 08:06:13 PM
// Design Name: 
// Module Name: control_unit
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
module control_unit (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    input  [4:0] rd,
    input  [4:0] rs1,
    output reg   alu_src,
    output reg   a_sel,
    output reg [3:0] alu_op,
    output reg   reg_write_en,
    output reg   mem_write,
    output reg   mem_to_reg,
    output reg   branch_unsigned,
    output reg   is_branch_instruction,
    output reg   illegal_instruction,
    output reg   mult_start_o // <<< New output for multiplier
);

    always @(*) begin
        // Set safe default values
        alu_src               = 1'b0;
        a_sel                 = 1'b0;
        alu_op                = 4'b0000;
        reg_write_en          = 1'b0;
        mem_write             = 1'b0;
        mem_to_reg            = 1'b0;
        branch_unsigned       = 1'b0;
        is_branch_instruction = 1'b0;
        illegal_instruction   = 1'b0;
        mult_start_o          = 1'b0; // Default to not starting

        case (opcode)
            7'b0110011: begin // R-type or M-type
                // <<< MODIFICATION: Check for M-extension first
                if (funct7 == 7'b0000001) begin // M-extension instructions
                    reg_write_en = 1'b1;
                    mult_start_o = 1'b1; // Signal the multiplier to start
                    alu_op       = 4'b1111; // ALU is not used, set to a known safe state
                end else begin // Standard R-type instructions
                    reg_write_en = 1'b1;
                    alu_src      = 1'b0;
                    case ({funct7[5], funct3})
                        4'b0000: alu_op = 4'b0000; // ADD
                        4'b1000: alu_op = 4'b0001; // SUB
                        4'b0001: alu_op = 4'b0010; // SLL
                        4'b0010: alu_op = 4'b0011; // SLT
                        4'b0011: alu_op = 4'b0100; // SLTU
                        4'b0100: alu_op = 4'b0101; // XOR
                        4'b0101: alu_op = 4'b0110; // SRL
                        4'b1101: alu_op = 4'b0111; // SRA
                        4'b0110: alu_op = 4'b1000; // OR
                        4'b0111: alu_op = 4'b1001; // AND
                        default: illegal_instruction = 1'b1;
                    endcase
                end
            end
            
            7'b0010011: begin // I-type ALU (includes ADDI)
                reg_write_en = 1'b1;
                alu_src      = 1'b1;
                if (funct3 == 3'b000 && rd == 5'b0 && rs1 == 5'b0) begin // NOP
                    reg_write_en = 1'b0;
                end
                case (funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b010: alu_op = 4'b0011; // SLTI
                    3'b011: alu_op = 4'b0100; // SLTIU
                    3'b100: alu_op = 4'b0101; // XORI
                    3'b110: alu_op = 4'b1000; // ORI
                    3'b111: alu_op = 4'b1001; // ANDI
                    3'b001: alu_op = 4'b0010; // SLLI
                    3'b101: alu_op = (funct7[5]) ? 4'b0111 : 4'b0110; // SRAI/SRLI
                    default: illegal_instruction = 1'b1;
                endcase
            end
            
            // ... the rest of the file remains the same ...
            7'b0000011: begin // Load
                reg_write_en = 1'b1;
                alu_src      = 1'b1;
                mem_to_reg   = 1'b1;
                alu_op       = 4'b0000;
            end
            7'b0100011: begin // Store
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_op    = 4'b0000;
            end
            7'b1100011: begin // Branch
                is_branch_instruction = 1'b1;
                alu_src               = 1'b0;
                branch_unsigned       = (funct3[2] & funct3[1]);
                alu_op                = 4'b0001;
            end
            7'b0110111: begin // LUI
                reg_write_en = 1'b1;
                alu_src      = 1'b1;
                alu_op       = 4'b1010;
            end
             7'b0010111: begin // AUIPC
                reg_write_en = 1'b1;
                alu_src      = 1'b1;
                a_sel        = 1'b1;
                alu_op       = 4'b0000;
            end
            7'b1101111: begin // JAL
                reg_write_en = 1'b1;
                a_sel        = 1'b1;
                alu_src      = 1'b1;
                alu_op       = 4'b0000;
            end
            7'b1100111: begin // JALR
                reg_write_en = 1'b1;
                alu_src      = 1'b1;
                alu_op       = 4'b0000;
            end
            default: begin
                illegal_instruction = 1'b1;
            end
        endcase
    end
endmodule
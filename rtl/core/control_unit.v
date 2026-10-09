// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.


`timescale 1ns / 1ps


`include "minirisc_defs.vh"


module control_unit #(
    parameter integer INSTR_w = 32,
    parameter integer OPCODE_w = 6,
    parameter integer REGADDR_w = 4

) (
    input wire [INSTR_w-1:0] instr,

    output wire [OPCODE_w-1:0] opcode,
    output wire [REGADDR_w-1:0] rs1_addr,
    output wire [REGADDR_w-1:0] rs2_addr,
    output wire [REGADDR_w-1:0] rd_addr,

    output reg [3:0] alu_ctrl,
    output reg alu_src_b,    // 0: register, 1: immediate
    output reg [2:0] imm_sel,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg [1:0] wb_sel,
    output reg is_halt,
    output reg is_branch,
    output reg [1:0] br_type,
    output reg is_mul,   
    output reg illegal
);

    assign opcode   = instr[31:26];
    assign rs1_addr = instr[21:18];
    assign rs2_addr = instr[17:14];

    reg dst_is_rs1;
    assign rd_addr = dst_is_rs1 ? instr[21:18] : instr[25:22];

    always @(*) begin 
        alu_ctrl   = `ALU_add;
        alu_src_b  = 1'b0;
        imm_sel    = `IMM_none;
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        wb_sel     = `WB_alu;
        is_halt    = 1'b0;
        is_branch  = 1'b0;
        br_type    = `BRTYPE_eq;
        is_mul     = 1'b0;
        illegal    = 1'b0;
        dst_is_rs1 = 1'b0;

        case (opcode)
            // R - Type
            `OP_add : begin alu_ctrl = `ALU_add; reg_write = 1'b1; end
            `OP_sub : begin alu_ctrl = `ALU_sub; reg_write = 1'b1; end
            `OP_and : begin alu_ctrl = `ALU_and; reg_write = 1'b1; end
            `OP_or  : begin alu_ctrl = `ALU_or ; reg_write = 1'b1; end
            `OP_xor : begin alu_ctrl = `ALU_xor; reg_write = 1'b1; end
            `OP_nor : begin alu_ctrl = `ALU_nor; reg_write = 1'b1; end
            `OP_not : begin alu_ctrl = `ALU_not; reg_write = 1'b1; end
            `OP_sll : begin alu_ctrl = `ALU_sll; reg_write = 1'b1; end
            `OP_srl : begin alu_ctrl = `ALU_srl; reg_write = 1'b1; end
            `OP_sra : begin alu_ctrl = `ALU_sra; reg_write = 1'b1; end
            `OP_slt : begin alu_ctrl = `ALU_slt; reg_write = 1'b1; end
            `OP_sgt : begin alu_ctrl = `ALU_sgt; reg_write = 1'b1; end

            // I - Type
            `OP_addi: begin alu_ctrl = `ALU_add; alu_src_b = 1'b1; imm_sel = `IMM_I_sext; reg_write = 1'b1; end
            `OP_subi: begin alu_ctrl = `ALU_sub; alu_src_b = 1'b1; imm_sel = `IMM_I_sext; reg_write = 1'b1; end
            `OP_andi: begin alu_ctrl = `ALU_and; alu_src_b = 1'b1; imm_sel = `IMM_I_zext; reg_write = 1'b1; end
            `OP_ori : begin alu_ctrl = `ALU_or ; alu_src_b = 1'b1; imm_sel = `IMM_I_zext; reg_write = 1'b1; end
            `OP_xori: begin alu_ctrl = `ALU_xor; alu_src_b = 1'b1; imm_sel = `IMM_I_zext; reg_write = 1'b1; end
            `OP_slli: begin alu_ctrl = `ALU_sll; alu_src_b = 1'b1; imm_sel = `IMM_I_zext; reg_write = 1'b1; end
            `OP_srli: begin alu_ctrl = `ALU_srl; alu_src_b = 1'b1; imm_sel = `IMM_I_zext; reg_write = 1'b1; end
            `OP_srai: begin alu_ctrl = `ALU_sra; alu_src_b = 1'b1; imm_sel = `IMM_I_zext; reg_write = 1'b1; end
            `OP_inc : begin alu_ctrl = `ALU_add; alu_src_b = 1'b1; imm_sel = `IMM_one; reg_write = 1'b1; dst_is_rs1 = 1'b1; end
            `OP_dec : begin alu_ctrl = `ALU_sub; alu_src_b = 1'b1; imm_sel = `IMM_one; reg_write = 1'b1; dst_is_rs1 = 1'b1; end
            `OP_lui : begin alu_ctrl = `ALU_passb; alu_src_b = 1'b1; imm_sel = `IMM_lui; reg_write = 1'b1; end

            // Sign Extension
            `OP_ld  : begin alu_ctrl = `ALU_add; alu_src_b = 1'b1; imm_sel = `IMM_I_sext;
                            reg_write = 1'b1; mem_read = 1'b1; wb_sel = `WB_mem; end
            `OP_st  : begin alu_ctrl = `ALU_add; alu_src_b = 1'b1; imm_sel = `IMM_S_sext;
                            mem_write = 1'b1; end

            // PC Logic
            `OP_b   : begin is_branch = 1'b1; br_type = `BRTYPE_eq; imm_sel = `IMM_J_sext; end
            `OP_bz  : begin is_branch = 1'b1; br_type = `BRTYPE_eq; imm_sel = `IMM_S_sext; end
            `OP_bltz: begin is_branch = 1'b1; br_type = `BRTYPE_eq; imm_sel = `IMM_S_sext; end
            `OP_bgtz: begin is_branch = 1'b1; br_type = `BRTYPE_eq; imm_sel = `IMM_S_sext; end
            `OP_halt: is_halt = 1'b1;

            // Multiplier
            `OP_mull, `OP_mulh, `OP_mac: is_mul = 1'b1;

            default : illegal = 1'b1;
        endcase
    end 


endmodule 
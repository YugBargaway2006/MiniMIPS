// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.


`timescale 1ns / 1ps


`include "minirisc_defs.vh"


module soc_top #(
    parameter integer PC_w = 32,
    parameter integer CACHE_words = 256,
    parameter INIT_file = "",
    parameter DATA_INIT_file = ""
) (
    input wire clock,
    input wire reset,

    output wire halted,
    output wire [PC_w-1:0] IncrPC,
    output wire is_mul
);

    wire [PC_w-1:0] PC;
    wire [PC_w-1:0] NextPC;

    wire [31:0] instruction;
    wire [31:0] imm;
    wire [31:0] rs_data;
    wire [31:0] rt_data;
    wire [31:0] alu_input_b;
    wire [31:0] alu_out;
    wire [31:0] data_out;
    wire [31:0] reg_in;

    wire [3:0] rs_addr;
    wire [3:0] rt_addr;
    wire [3:0] rd_addr;
    wire [3:0] rw_addr;
    /* verilator lint_off UNUSEDSIGNAL */
    wire [5:0] opcode;
    /* verilator lint_on UNUSEDSIGNAL */

    wire [3:0] alu_ctrl;
    wire [2:0] imm_sel;
    wire [1:0] br_type;
    wire [1:0] wb_sel;
    wire [1:0] pc_src;
    wire [1:0] reg_dst;

    wire alu_src_b;
    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire is_halt;
    wire is_branch;
    /* verilator lint_off UNUSEDSIGNAL */
    wire illegal;
    wire alu_overflow;
    wire alu_zero;
    wire alu_negative;
    /* verilator lint_on UNUSEDSIGNAL */

    assign pc_src = is_branch ? `PCSRC_branch : `PCSRC_incr;
    assign reg_dst = (opcode[5:4] == 2'b00) ? 2'b01 : 2'b00;
    assign halted = is_halt;

    pc_unit #(
        .PC_w(PC_w),
        .RESET_PC({PC_w{1'b0}})
    ) pc_register (
        .clk   (clock),
        .reset (reset),
        .NextPC(NextPC),
        .PC    (PC)
    );

    instruction_cache #(
        .PC_w        (PC_w),
        .CACHE_words (CACHE_words),
        .INIT_file   (INIT_file)
    ) instruction_memory (
        .PC         (PC),
        .Instruction(instruction)
    );

    control_unit control (
        .instr    (instruction),
        .opcode   (opcode),
        .rs1_addr (rs_addr),
        .rs2_addr (rt_addr),
        .rd_addr  (rd_addr),
        .alu_ctrl (alu_ctrl),
        .alu_src_b(alu_src_b),
        .imm_sel  (imm_sel),
        .reg_write(reg_write),
        .mem_read (mem_read),
        .mem_write(mem_write),
        .wb_sel   (wb_sel),
        .is_halt  (is_halt),
        .is_branch(is_branch),
        .br_type  (br_type),
        .is_mul   (is_mul),
        .illegal  (illegal)
    );

    output_reg_mux #(
        .REG_w(4)
    ) register_destination (
        .rt    (rt_addr),
        .rd    (rd_addr),
        .RegDst(reg_dst),
        .rw    (rw_addr)
    );

    imm_sign_extension immediate_extension (
        .instr  (instruction),
        .imm_sel(imm_sel),
        .imm    (imm)
    );

    reg_file #(
        .WORD_w(32),
        .REG_w (4)
    ) registers (
        .clock   (clock),
        .RegWrite(reg_write),
        .reset   (reset),
        .rs_add  (rs_addr),
        .rt_add  (rt_addr),
        .rw_add  (rw_addr),
        .data    (reg_in),
        .rs_data (rs_data),
        .rt_data (rt_data)
    );

    alu_mux alu_input_select (
        .reg_data   (rt_data),
        .imm32      (imm),
        .ALUSrc     (alu_src_b),
        .alu_mux_out(alu_input_b)
    );

    alu arithmetic_logic_unit (
        .inputA  (rs_data),
        .inputB  (alu_input_b),
        .ALUctrl (alu_ctrl),
        .ALUout  (alu_out),
        .ALUovfl (alu_overflow),
        .zero    (alu_zero),
        .negative(alu_negative)
    );

    next_address #(
        .PC_w(PC_w)
    ) next_address_logic (
        .PC         (PC),
        .rs         (rs_data),
        .rt         (rt_data),
        .jta        (instruction[25:0]),
        .branch_imm (instruction[15:0]),
        .syscall_addr({PC_w{1'b0}}),
        .pc_src     (pc_src),
        .br_type    (br_type),
        .NextPC     (NextPC),
        .IncrPC     (IncrPC)
    );

    data_cache #(
        .ADDR_w     (PC_w),
        .CACHE_words(CACHE_words),
        .INIT_file  (DATA_INIT_file)
    ) data_memory (
        .clock    (clock),
        .reset    (reset),
        .DataAddr (alu_out),
        .DataIn   (rt_data),
        .DataRead (mem_read),
        .DataWrite(mem_write),
        .DataOut  (data_out)
    );

    data_out_mux writeback_mux (
        .ALUout       (alu_out),
        .DataOut      (data_out),
        .OtherEndpoint(32'd0),
        .RegInSrc     (wb_sel),
        .RegIn        (reg_in)
    );

endmodule

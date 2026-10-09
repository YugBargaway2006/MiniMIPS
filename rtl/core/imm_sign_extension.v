// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.


`timescale 1ns / 1ps


`include "minirisc_defs.vh" 


module imm_sign_extension (
    /* verilator lint_off UNUSEDSIGNAL */
    input wire [31:0] instr,
    /* verilator lint_on UNUSEDSIGNAL */
    input wire [2:0] imm_sel,

    output reg [31:0] imm
);

    wire [17:0] imm_i = instr[17:0];
    wire [17:0] imm_s = {instr[25:22], instr[13:0]};
    wire [21:0] imm_j = instr[21:0];

    always @(*) begin 
        case (imm_sel) 
            `IMM_I_sext: imm = {{14{imm_i[17]}}, imm_i};
            `IMM_I_zext: imm = {14'b0, imm_i};
            `IMM_one   : imm = 32'd1;
            `IMM_lui   : imm = {imm_i[13:0], 18'b0};
            `IMM_S_sext: imm = {{14{imm_s[17]}}, imm_s};
            `IMM_J_sext: imm = {{10{imm_j[21]}}, imm_j};
            default    : imm = 32'd0;
        endcase 
    end 

endmodule

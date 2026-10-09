// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.


`timescale 1ns / 1ps


`include "minirisc_defs.vh"


module alu #(
    parameter integer WORD_w = 32,
    parameter integer CTRL_w = 4
) (
    input wire [WORD_w-1:0] inputA,
    input wire [WORD_w-1:0] inputB,
    input wire [CTRL_w-1:0] ALUctrl,

    output reg [WORD_w-1:0] ALUout,
    output wire ALUovfl,
    output wire zero,
    output wire negative
);

    wire [4:0] shamt = inputB[4:0];
    wire signed [WORD_w-1:0] inputA_signed = inputA;
    wire signed [WORD_w-1:0] inputB_signed = inputB;
    wire signed [WORD_w-1:0] sra_res = inputA_signed >>> shamt;

    always @(*) begin 
        case (ALUctrl) 
            `ALU_add : ALUout = inputA + inputB;
            `ALU_sub : ALUout = inputA - inputB;
            `ALU_and : ALUout = inputA & inputB;
            `ALU_or : ALUout = inputA | inputB;
            `ALU_xor : ALUout = inputA ^ inputB;
            `ALU_nor : ALUout = ~(inputA | inputB);
            `ALU_not : ALUout = ~inputA;
            `ALU_sll : ALUout = inputA << shamt;
            `ALU_srl : ALUout = inputA >> shamt;
            `ALU_sra : ALUout = sra_res;
            `ALU_slt : ALUout = {{(WORD_w-1){1'b0}}, (inputA_signed < inputB_signed)};
            `ALU_sgt : ALUout = {{(WORD_w-1){1'b0}}, (inputA_signed > inputB_signed)};
            `ALU_passb : ALUout = inputB;
            default : ALUout = {WORD_w{1'b0}};
        endcase
    end 

    assign zero = (ALUout == {WORD_w{1'b0}});
    assign negative = ALUout[WORD_w-1];

    assign ALUovfl =
        (ALUctrl == `ALU_add) ?
            ((~(inputA[WORD_w-1] ^ inputB[WORD_w-1])) &
             (ALUout[WORD_w-1] ^ inputA[WORD_w-1])) :

        (ALUctrl == `ALU_sub) ?
            ((inputA[WORD_w-1] ^ inputB[WORD_w-1]) &
             (ALUout[WORD_w-1] ^ inputA[WORD_w-1])) :

        1'b0;

endmodule 
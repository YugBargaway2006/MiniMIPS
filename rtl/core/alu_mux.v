// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.


`timescale 1ns / 1ps


module alu_mux (
    input  wire [31:0] reg_data,
    input  wire [31:0] imm32,
    input  wire ALUSrc,

    output wire [31:0] alu_mux_out
);

    assign alu_mux_out = ALUSrc ? imm32 : reg_data;

endmodule

// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.


`timescale  1ns / 1ps


module output_reg_mux #(parameter integer REG_w = 5) (
    input wire [REG_w-1:0] rt,
    input wire [REG_w-1:0] rd,
    input wire [1:0] RegDst,

    output reg [REG_w-1:0] rw
);

    always @(*) begin
        case (RegDst)
            2'b00: rw = rt;
            2'b01: rw = rd;
            2'b10: rw = 5'b11111;
            default: rw = {REG_w{1'b0}};
        endcase
    end 

endmodule
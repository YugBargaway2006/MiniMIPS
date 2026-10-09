// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.


`timescale 1ns / 1ps


`include "minirisc_defs.vh"


module data_out_mux #(
    parameter integer DATA_w = 32
) (
    input wire [DATA_w-1:0] ALUout,
    input wire [DATA_w-1:0] DataOut,
    input wire [DATA_w-1:0] OtherEndpoint,
    
    input wire [1:0] RegInSrc,

    output reg [DATA_w-1:0] RegIn
);

    always @(*) begin
        case (RegInSrc)
            `WB_alu : RegIn = ALUout;
            `WB_mem : RegIn = DataOut;
            `WB_other : RegIn = OtherEndpoint;
            default : RegIn = ALUout;
        endcase
    end

endmodule
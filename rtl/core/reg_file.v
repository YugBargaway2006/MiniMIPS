// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.


`timescale  1ns / 1ps


module reg_file #(
    parameter integer WORD_w = 32,
    parameter integer REG_w = 5    
) (
    input wire clock,
    input wire RegWrite,

    input wire [REG_w-1:0] rs_add,
    input wire [REG_w-1:0] rt_add,
    input wire [REG_w-1:0] rd_add,

    input wire [WORD_w-1:0] data,

    output wire [WORD_w-1:0] rs_data,
    output wire [WORD_w-1:0] rt_data
);

    reg [31:0] regs [0:31];
    integer i;

    always @(posedge clock) begin 
        if(reset) begin 
            for (i = 0; i < 32; i = i+1) regs[i] <= 32'h0000_0000;
        end 
        else if (RegWrite) begin 
            regs[rd_add] <= data; 

        end 
    end 

    assign rs_data = regs[rs_add];
    assign rd_data = regs[rd_add];

endmodule
// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.


`timescale  1ns / 1ps


module reg_file #(
    parameter integer WORD_w = 32,
    parameter integer REG_w = 5    
) (
    input wire clock,
    input wire RegWrite,
    input wire reset,

    input wire [REG_w-1:0] rs_add,
    input wire [REG_w-1:0] rt_add,
    input wire [REG_w-1:0] rw_add,

    input wire [WORD_w-1:0] data,

    output wire [WORD_w-1:0] rs_data,
    output wire [WORD_w-1:0] rt_data
);

    localparam integer REG_count = (1 << REG_w);

    reg [WORD_w:0] regs [0:REG_count-1];
    integer i;

    always @(posedge clock) begin 
        if(reset) begin 
            for (i = 0; i < REG_count; i = i+1) regs[i] <= {WORD_w{1'b0}};
        end 
        else if (RegWrite) begin 
            regs[rw_add] <= data; 

        end 
    end 

    assign rs_data = regs[rs_add];
    assign rt_data = regs[rt_add];

endmodule

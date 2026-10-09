// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.


`timescale 1ns / 1ps 


module instruction_cache #(
    parameter integer PC_w = 32,
    parameter integer WORD_w = 32;
    parameter integer CACHE_words = 256,
    parameter INIT_file = ""
) (
    input wire [PC_w-1:0] PC,

    output wire [WORD_w-1:0] Instruction 
);

    localparam integer INDEX_w = $clog2(CACHE_words);
    reg [WORD_w-1:0] memory [0:CACHE_words-1];

    wire [INDEX_w-1:0] word_index; 

    assign word_index = PC[INDEX_w+1:2];
    assign Instruction = memory[word_index];

    initial begin 
        if (INIT_file != "") 
            $readmemh(INIT_file, memory);
    end 

endmodule 
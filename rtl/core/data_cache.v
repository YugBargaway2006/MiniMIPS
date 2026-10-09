// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.


`timescale 1ns / 1ps


module data_cache #(
    parameter integer ADDR_w = 32,
    parameter integer DATA_w = 32,
    parameter integer CACHE_words = 256,
    parameter INIT_file = ""
) (
    input wire clock,
    input wire reset,

    input wire [ADDR_w-1:0] DataAddr,
    input wire [DATA_w-1:0] DataIn,

    input wire DataRead,
    input wire DataWrite,

    output wire [DATA_w-1:0] DataOut 
);

    localparam integer INDEX_w = $clog2(CACHE_words);

    reg [DATA_w-1:0] memory [0:CACHE_words-1];
    wire [INDEX_w-1:0] word_index;

    integer i;


    assign word_index = DataAddr[INDEX_w+1:2];

    assign DataOut = DataRead ? memory[word_index] : {DATA_w{1'b0}};

    always @(posedge clock) begin 
        if(reset) begin 
            for(i = 0; i < CACHE_words; i = i+1) 
                memory[i] <= {DATA_w{1'b0}};
        end 
        else if (DataWrite) begin 
            memory[word_index] <= DataIn;
        end 
    end 

    initial begin 
        if (INIT_file != "") 
            $readmemh(INIT_file, memory);
    end 

endmodule
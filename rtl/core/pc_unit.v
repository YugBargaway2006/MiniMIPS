`timescale 1ns / 1ps 


module pc_unit #(
    parameter integer PC_w = 10,
    parameter [PC_w-1:0] RESET_PC = (PC_w{1'b0})
) (
    input wire clk, reset,
    input wire [PC_w-1:0] NextPC,

    output reg [PC_w-1:0] PC
);

    always @(posedge clk) begin 
        if(reset) 
            PC <= RESET_PC;
        else 
            PC <= NextPC;
    end 

endmodule
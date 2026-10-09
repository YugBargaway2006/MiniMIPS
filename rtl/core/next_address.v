`timescale  1ns / 1ps


`include "minirisc_defs.vh"


module next_address #(
    parameter integer PC_w = 10,
    parameter integer DATA_w = 32,
    parameter integer JTA_w = 26,
    parameter integer IMM_w = 16 
) (
    input wire [PC_w-1:0] PC,
    input wire [DATA_w-1:0] rs,
    input wire [DATA_w-1:0] rt,
    input wire [JTA_w-1:0] jta,
    input wire [IMM_w-1:0] branch_imm,
    input wire [PC_w-1:0] syscall_addr,

    input wire [1:0] pc_src,
    input wire br_type,

    output reg [PC_w-1:0] NextPC,
    output wire [PC_w-1:0] IncrPC 
);

    wire [29:0] branch_offset;
    wire [29:0] branch_target;
    wire [29:0] jump_target;

    wire branch_true;
    wire registers_equal;


    assign IncrPC = PC[31:2] + 30'd1;

    assign branch_offset = {14{branch_imm[15]}, branch_imm};     // Sign Extension
    assign branch_target = IncrPC + branch_offset;

    assign jump_target = {PC[31:28], jta};

    assign registers_equal = (rs == rt);

    assign branch_true = 
        (br_type == BRTYPE_eq) ? registers_equal :
            (br_type == BRTYPE_ne) ? ~registers_equal : 
                                     1'b0; 


    always @* begin 
        case (pc_src) 
            PCSRC_incr: begin 
                NextPC = IncrPC;
            end 

            PCSRC_branch: begin 
                if(branch_true) 
                    NextPC = branch_target;
                else 
                    NextPC = IncrPC;
            end 

            PCSRC_jump: begin 
                NextPC = jump_target;
            end 

            PCSRC_syscall: begin 
                NextPC = syscall_addr;
            end 

            default: begin 
                NextPC = IncrPC;
            end 

        endcase
    end 

endmodule

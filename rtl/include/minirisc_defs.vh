// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.

// This file is generated from claude as a starter template and was updated during the course of the implmentation


`ifndef MINIRISC_DEFS_VH
`define MINIRISC_DEFS_VH



// ----------------------------------------------------

// R-type Group (00xxxx)

`define OP_add 6'b00_0000   // also encodes NOP when the whole word is 0
`define OP_sub 6'b00_0001
`define OP_and 6'b00_0010
`define OP_or 6'b00_0011
`define OP_xor 6'b00_0100
`define OP_nor 6'b00_0101
`define OP_not 6'b00_0110
`define OP_sll 6'b00_0111
`define OP_srl 6'b00_1000
`define OP_sra 6'b00_1001
`define OP_slt 6'b00_1010
`define OP_sgt 6'b00_1011


// I-type group (01xxxx)

`define OP_addi 6'b01_0000
`define OP_subi 6'b01_0001
`define OP_andi 6'b01_0010
`define OP_ori 6'b01_0011
`define OP_xori 6'b01_0100
`define OP_slli 6'b01_0111
`define OP_srli 6'b01_1000
`define OP_srai 6'b01_1001
`define OP_inc 6'b01_1010   
`define OP_dec 6'b01_1011   
`define OP_lui 6'b01_1110  

// Memory / branch group (10xxxx)
`define OP_ld 6'b10_0000
`define OP_st 6'b10_0001
`define OP_b 6'b10_0010
`define OP_bz 6'b10_0011
`define OP_bltz 6'b10_0100
`define OP_bgtz 6'b10_0101

// Multiply group + HALT (11xxxx)
`define OP_mull 6'b11_0000
`define OP_mulh 6'b11_0001
`define OP_mac 6'b11_0010
`define OP_halt 6'b11_1111

// ----------------------------------------------------


// ----------------------------------------------------
// write-back select
`define WB_alu 2'd0
`define WB_mem 2'd1
`define WB_other 2'd2    // endpoint left to add more modules later

// -----------------------------------------------------



// ----------------------------------------------------

// Next Address Module Declarations
// PCSRC enocding
`define PCSRC_incr 2'd0 
`define PCSRC_branch 2'd1
`define PCSRC_jump 2'd2
`define PCSRC_syscall 2'd3

// BrType Encoding 
`define BRTYPE_eq 2'd0 
`define BRTYPE_ne 2'd1

// -----------------------------------------------------



// ----------------------------------------------------

// Immediate Sign Extension Logic
`define IMM_none 3'd0 
`define IMM_I_sext 3'd1
`define IMM_I_zext 3'd2 
`define IMM_one 3'd3 
`define IMM_lui 3'd4        // adding 0's to the lsb's 
`define IMM_S_sext 3'd5 
`define IMM_J_sext 3'd6 

// -----------------------------------------------------



// ----------------------------------------------------

// ALU Control Parameters
`define ALU_add 4'd0
`define ALU_sub 4'd1
`define ALU_and 4'd2
`define ALU_or 4'd3
`define ALU_xor 4'd4
`define ALU_nor 4'd5
`define ALU_not 4'd6
`define ALU_sll 4'd7
`define ALU_srl 4'd8
`define ALU_sra 4'd9
`define ALU_slt 4'd10
`define ALU_sgt 4'd11
`define ALU_passb 4'd12   // Y = B  (for LUI)

// -----------------------------------------------------

`endif

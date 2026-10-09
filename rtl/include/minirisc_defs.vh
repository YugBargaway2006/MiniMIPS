// ============================================================================
// minirisc_defs.vh  -  shared constants for the MiniRISC datapath
// Opcodes follow the "Proposed opcode allocation" page of Assignment 1A.
// ============================================================================
`ifndef MINIRISC_DEFS_VH
`define MINIRISC_DEFS_VH

// ---------------- 6-bit opcodes  [31:26] ----------------
// R-type group (00xxxx)
`define OP_ADD    6'b00_0000   // also encodes NOP when the whole word is 0
`define OP_SUB    6'b00_0001
`define OP_AND    6'b00_0010
`define OP_OR     6'b00_0011
`define OP_XOR    6'b00_0100
`define OP_NOR    6'b00_0101
`define OP_NOT    6'b00_0110
`define OP_SLL    6'b00_0111
`define OP_SRL    6'b00_1000
`define OP_SRA    6'b00_1001
`define OP_SLT    6'b00_1010
`define OP_SGT    6'b00_1011
// I-type group (01xxxx)
`define OP_ADDI   6'b01_0000
`define OP_SUBI   6'b01_0001
`define OP_ANDI   6'b01_0010
`define OP_ORI    6'b01_0011
`define OP_XORI   6'b01_0100
`define OP_SLLI   6'b01_0111
`define OP_SRLI   6'b01_1000
`define OP_SRAI   6'b01_1001
`define OP_INC    6'b01_1010   // moved: 1A had 01_1000 (clashes with SRLI)
`define OP_DEC    6'b01_1011   // moved: 1A had 01_1001 (clashes with SRAI)
`define OP_LUI    6'b01_1110   // as read from the 1A sheet - verify
// Memory / branch group (10xxxx)
`define OP_LD     6'b10_0000
`define OP_ST     6'b10_0001
`define OP_B      6'b10_0010
`define OP_BZ     6'b10_0011
`define OP_BLTZ   6'b10_0100
`define OP_BGTZ   6'b10_0101
// Multiply group + HALT (11xxxx)
`define OP_MULL   6'b11_0000
`define OP_MULH   6'b11_0001
`define OP_MAC    6'b11_0010
`define OP_HALT   6'b11_1111

// ---------------- ALU control (4 bit) ----------------
`define ALU_ADD   4'd0
`define ALU_SUB   4'd1
`define ALU_AND   4'd2
`define ALU_OR    4'd3
`define ALU_XOR   4'd4
`define ALU_NOR   4'd5
`define ALU_NOT   4'd6
`define ALU_SLL   4'd7
`define ALU_SRL   4'd8
`define ALU_SRA   4'd9
`define ALU_SLT   4'd10
`define ALU_SGT   4'd11
`define ALU_PASSB 4'd12   // Y = B  (used by LUI)

// ---------------- immediate select ----------------
`define IMM_NONE   3'd0
`define IMM_I_SEXT 3'd1   // instr[17:0], sign-extended   (ADDI, SUBI, LD)
`define IMM_I_ZEXT 3'd2   // instr[17:0], zero-extended   (ANDI, ORI, XORI, shifts)
`define IMM_ONE    3'd3   // constant 1                   (INC, DEC)
`define IMM_LUI    3'd4   // {instr[13:0], 18'b0}         (LUI)
`define IMM_S_SEXT 3'd5   // {instr[25:22], instr[13:0]}  (ST, BZ, ...)
`define IMM_J_SEXT 3'd6   // instr[21:0], sign-extended   (B)

// ---------------- branch type ----------------
`define BR_ALWAYS 2'd0   // B
`define BR_Z      2'd1   // BZ   : Rs1 == 0
`define BR_LTZ    2'd2   // BLTZ : Rs1 <  0 (signed)
`define BR_GTZ    2'd3   // BGTZ : Rs1 >  0 (signed)

// ---------------- write-back select ----------------
`define WB_ALU    2'd0
`define WB_MEM    2'd1
`define WB_OTHER  2'd2    // future: multiplier result


// ----------------------------------------------------

// Next Address Module Declarations
// PCSRC enocding
`define [1:0] PCSRC_incr 2'd0 
`define [1:0] PCSRC_branch 2'd1
`define [1:0] PCSRC_jump 2'd2
`define [1:0] PCSRC_syscall 2'd3

// BrType Encoding 
`define [1:0] BRTYPE_eq 2'd0 
`define [1:0] BRTYPE_ne 2'd1

// -----------------------------------------------------




`endif
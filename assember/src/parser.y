/* Copyright (c) Yug Bargaway under Apache License 2.0. */
/* See LICENSE.txt for details. */

/* This code file contains (not entirely, but some part), AI-generated code by Gemini 3.8 Flash */

%{
#include <stdio.h>
#include <stdlib.h>

#include "isa.h"
#include "utils.h"

extern int yylex(void);
extern FILE *yyin;
extern int yylineno;


static assembler_context *assembler;

static void parser_error(const char *message)
{
  fprintf(stderr, "line %d: %s\n", yylineno, message);
}

void yyerror(const char *message)
{
    parser_error(message);
}


%}

%code requires {
#include <stdint.h>
}

%union {
    int32_t integer;
    uint8_t reg;
    char *text;
}


%token <reg> REGISTER
%token <integer> INTEGER
%token <text> IDENTIFIER

%token ADD SUB AND OR XOR NOR NOT SLL SRL SRA SLT SGT
%token ADDI SUBI ANDI ORI XORI SLLI SRLI SRAI INC DEC LUI
%token LD ST B BZ BLTZ BGTZ
%token MULL MULH MAC HALT NOP

%start program

%%

program:
    lines
;

lines:
    %empty
  | lines line
;

line:
    '\n'
  | IDENTIFIER ':' statement '\n'
    {
        if (!assembler_label_previous(assembler, $1, yylineno)) YYABORT;
        free($1);
    }
  | IDENTIFIER ':' '\n'
    {
        if (!assembler_label(assembler, $1, yylineno)) YYABORT;
        free($1);
    }
  | statement '\n'
;

statement:
    ADD REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_ADD, $2, $4, $6, yylineno)) YYABORT; }
  | SUB REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_SUB, $2, $4, $6, yylineno)) YYABORT; }
  | AND REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_AND, $2, $4, $6, yylineno)) YYABORT; }
  | OR REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_OR, $2, $4, $6, yylineno)) YYABORT; }
  | XOR REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_XOR, $2, $4, $6, yylineno)) YYABORT; }
  | NOR REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_NOR, $2, $4, $6, yylineno)) YYABORT; }
  | NOT REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_NOT, $2, $4, $6, yylineno)) YYABORT; }
  | SLL REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_SLL, $2, $4, $6, yylineno)) YYABORT; }
  | SRL REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_SRL, $2, $4, $6, yylineno)) YYABORT; }
  | SRA REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_SRA, $2, $4, $6, yylineno)) YYABORT; }
  | SLT REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_SLT, $2, $4, $6, yylineno)) YYABORT; }
  | SGT REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_SGT, $2, $4, $6, yylineno)) YYABORT; }
  | MULL REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_MULL, $2, $4, $6, yylineno)) YYABORT; }
  | MULH REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_MULH, $2, $4, $6, yylineno)) YYABORT; }
  | MAC REGISTER ',' REGISTER ',' REGISTER
    { if (!assembler_emit2(assembler, OP_MAC, $2, $4, $6, yylineno)) YYABORT; }
  | ADDI REGISTER ',' REGISTER ',' INTEGER
    { if (!assembler_emit_i(assembler, OP_ADDI, $2, $4, $6, yylineno)) YYABORT; }
  | SUBI REGISTER ',' REGISTER ',' INTEGER
    { if (!assembler_emit_i(assembler, OP_SUBI, $2, $4, $6, yylineno)) YYABORT; }
  | ANDI REGISTER ',' REGISTER ',' INTEGER
    { if (!assembler_emit_i(assembler, OP_ANDI, $2, $4, $6, yylineno)) YYABORT; }
  | ORI REGISTER ',' REGISTER ',' INTEGER
    { if (!assembler_emit_i(assembler, OP_ORI, $2, $4, $6, yylineno)) YYABORT; }
  | XORI REGISTER ',' REGISTER ',' INTEGER
    { if (!assembler_emit_i(assembler, OP_XORI, $2, $4, $6, yylineno)) YYABORT; }
  | SLLI REGISTER ',' REGISTER ',' INTEGER
    { if (!assembler_emit_i(assembler, OP_SLLI, $2, $4, $6, yylineno)) YYABORT; }
  | SRLI REGISTER ',' REGISTER ',' INTEGER
    { if (!assembler_emit_i(assembler, OP_SRLI, $2, $4, $6, yylineno)) YYABORT; }
  | SRAI REGISTER ',' REGISTER ',' INTEGER
    { if (!assembler_emit_i(assembler, OP_SRAI, $2, $4, $6, yylineno)) YYABORT; }
  | LUI REGISTER ',' REGISTER ',' INTEGER
    { if (!assembler_emit_i(assembler, OP_LUI, $2, $4, $6, yylineno)) YYABORT; }
  | INC REGISTER
    { if (!assembler_emit_i(assembler, OP_INC, $2, $2, 0, yylineno)) YYABORT; }
  | DEC REGISTER
    { if (!assembler_emit_i(assembler, OP_DEC, $2, $2, 0, yylineno)) YYABORT; }
  | LD REGISTER ',' INTEGER '(' REGISTER ')'
    { if (!assembler_emit_mem(assembler, OP_LD, $2, $4, $6, yylineno)) YYABORT; }
  | ST REGISTER ',' INTEGER '(' REGISTER ')'
    { if (!assembler_emit_mem(assembler, OP_ST, $2, $4, $6, yylineno)) YYABORT; }
  | B INTEGER
    { if (!assembler_emit_jump_offset(assembler, OP_B, $2, yylineno)) YYABORT; }
  | B IDENTIFIER
    { if (!assembler_emit_jump(assembler, OP_B, $2, yylineno)) YYABORT; free($2); }
  | BZ REGISTER ',' INTEGER
    { if (!assembler_emit_branch_offset(assembler, OP_BZ, $2, $4, yylineno)) YYABORT; }
  | BZ REGISTER ',' IDENTIFIER
    { if (!assembler_emit_branch(assembler, OP_BZ, $2, $4, yylineno)) YYABORT; free($4); }
  | BLTZ REGISTER ',' INTEGER
    { if (!assembler_emit_branch_offset(assembler, OP_BLTZ, $2, $4, yylineno)) YYABORT; }
  | BLTZ REGISTER ',' IDENTIFIER
    { if (!assembler_emit_branch(assembler, OP_BLTZ, $2, $4, yylineno)) YYABORT; free($4); }
  | BGTZ REGISTER ',' INTEGER
    { if (!assembler_emit_branch_offset(assembler, OP_BGTZ, $2, $4, yylineno)) YYABORT; }
  | BGTZ REGISTER ',' IDENTIFIER
    { if (!assembler_emit_branch(assembler, OP_BGTZ, $2, $4, yylineno)) YYABORT; free($4); }
  | DIRECTIVE_WORD INTEGER
    { if (!assembler_emit_word(assembler, (uint32_t)$2, yylineno)) YYABORT; }
  | HALT
    { if (!assembler_emit0(assembler, OP_HALT, yylineno)) YYABORT; }
  | NOP
    { if (!assembler_emit_word(assembler, 0, yylineno)) YYABORT; }
;


%%

int main(int argc, char **argv)
{
    if (argc < 2 || argc > 4) {
        fprintf(stderr, "usage: %s input.s [-o output.hex]\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *output_name = "a.hex";
    if (argc == 4 && (argv[2][0] != '-' || argv[2][1] != 'o')) {
        fprintf(stderr, "usage: %s input.s [-o output.hex]\n", argv[0]);
        return EXIT_FAILURE;
    }
    if (argc == 4) output_name = argv[3];

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        perror(argv[1]);
        return EXIT_FAILURE;
    }

    FILE *output = fopen(output_name, "w");
    if (output == NULL) {
        perror(output_name);
        fclose(yyin);
        return EXIT_FAILURE;
    }

    assembler = assembler_create();
    const int parse_status = yyparse();
    int status = parse_status;
    if (status == 0 && !assembler_write_hex(assembler, output)) {
        fprintf(stderr, "%s\n", assembler_error(assembler));
        status = EXIT_FAILURE;
    }
    if (status != 0 && assembler_error(assembler)[0] != '\0') {
        fprintf(stderr, "%s\n", assembler_error(assembler));
    }

    assembler_destroy(assembler);
    fclose(output);
    fclose(yyin);
    return status == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}
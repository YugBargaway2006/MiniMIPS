/* Copyright (c) Yug Bargaway under Apache License 2.0. */
/* See LICENSE.txt for details. */



%{
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "parser.tab.h"

%}

%option noyywrap
%option case-insensitive
%option yylineno
%option nodefault
%option noinput
%option nounput

HEX         -?0[xX][0-9a-fA-F]+
BIN         -?0[bB][01]+
DEC         -?(0|[1-9][0-9]*)
REGISTER    [rR](1[0-5]|[0-9])
IDENTIFIER  [A-Za-z_][A-Za-z0-9_]*


%%


"add"       return ADD;
"sub"       return SUB;
"and"       return AND;
"or"        return OR;
"xor"       return XOR;
"nor"       return NOR;
"not"       return NOT;
"sll"       return SLL;
"srl"       return SRL;
"sra"       return SRA;
"slt"       return SLT;
"sgt"       return SGT;

"addi"      return ADDI;
"subi"      return SUBI;
"andi"      return ANDI;
"ori"       return ORI;
"xori"      return XORI;
"slli"      return SLLI;
"srli"      return SRLI;
"srai"      return SRAI;
"inc"       return INC;
"dec"       return DEC;
"lui"       return LUI;

"ld"        return LD;
"st"        return ST;
"b"         return B;
"bz"        return BZ;
"bltz"      return BLTZ;
"bgtz"      return BGTZ;

"mull"      return MULL;
"mulh"      return MULH;
"mac"       return MAC;
"halt"      return HALT;
"nop"       return NOP;
".word"     return DIRECTIVE_WORD;



{REGISTER}  {
				yylval.reg = (uint8_t)strtoul(yytext + 1, NULL, 10);
				return REGISTER;
			}

{HEX}       {
				yylval.integer = (int32_t)strtoll(yytext, NULL, 16);
				return INTEGER;
			}

{BIN}       {
				const char *digits = yytext;
				int sign = 1;
				if (*digits == '-') {
					sign = -1;
					++digits;
				}
				yylval.integer = (int32_t)(sign * strtoll(digits + 2, NULL, 2));
				return INTEGER;
			}

{DEC}       {
				yylval.integer = (int32_t)strtoll(yytext, NULL, 10);
				return INTEGER;
			}

{IDENTIFIER} {
				yylval.text = strdup(yytext);
				if (yylval.text == NULL) {
					yyterminate();
				}
				return IDENTIFIER;
			 }

";"[^\n]*   /* Semicolon comment. */
"#"[^\n]*   /* Hash comment. */
"//"[^\n]*  /* C++-style comment. */

":"         return ':';
","         return ',';
"("         return '(';
")"         return ')';

[ \t\r]+  
\n          return '\n';

.           return yytext[0];

%%

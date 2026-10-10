#ifndef MINIMIPS_ASSEMBLER_UTILS_H
#define MINIMIPS_ASSEMBLER_UTILS_H


#include <stdint.h>
#include <stdio.h>


#include "isa.h"


#ifdef __cplusplus
extern "C" {
#endif

typedef struct assembler_context assembler_context;

assembler_context *assembler_create(void);

void assembler_destroy(assembler_context *context);

int assembler_label(assembler_context *context, const char *name, unsigned line);
int assembler_label_previous(assembler_context *context, const char *name, unsigned line);
int assembler_emit_word(assembler_context *context, uint32_t word, unsigned line);
int assembler_emit0(assembler_context *context, uint8_t opcode, unsigned line);
int assembler_emit1(assembler_context *context, uint8_t opcode, uint8_t rd, int32_t immediate, unsigned line);
int assembler_emit_i(assembler_context *context, uint8_t opcode, uint8_t rd, uint8_t rs1, int32_t immediate, unsigned line);
int assembler_emit2(assembler_context *context, uint8_t opcode, uint8_t rd, uint8_t rs1, uint8_t rs2, unsigned line);
int assembler_emit_mem(assembler_context *context, uint8_t opcode, uint8_t rt, int32_t offset, uint8_t base, unsigned line);
int assembler_emit_branch(assembler_context *context, uint8_t opcode, uint8_t rs1, const char *target, unsigned line);
int assembler_emit_branch_offset(assembler_context *context, uint8_t opcode, uint8_t rs1, int32_t offset, unsigned line);
int assembler_emit_jump(assembler_context *context, uint8_t opcode, const char *target, unsigned line);
int assembler_emit_jump_offset(assembler_context *context, uint8_t opcode, int32_t offset, unsigned line);

int assembler_write_hex(assembler_context *context, FILE *output);

const char *assembler_error(const assembler_context *context);

#ifdef __cplusplus
}
#endif

#endif

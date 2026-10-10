/* Copyright (c) Yug Bargaway under Apache License 2.0. */
/* See LICENSE.txt for details. */

/* This code file contains (not entirely, but some part), AI-generated code by Gemini 3.8 Flash */

#include "utils.h"

#include <limits>
#include <string>
#include <unordered_map>
#include <vector>


namespace {
    struct PendingWord {
        uint32_t word;
        std::string target;
        unsigned line;
        bool has_target;
    };

    uint32_t encode_i(uint8_t opcode, uint8_t rd, uint8_t rs1, int32_t immediate)
    {
        return (static_cast<uint32_t>(opcode) << 26) |
            (static_cast<uint32_t>(rd) << 22) |
            (static_cast<uint32_t>(rs1) << 18) |
            (static_cast<uint32_t>(immediate) & 0x3ffffu);
    }

    uint32_t encode_s(uint8_t opcode, uint8_t rt, uint8_t rs1, int32_t immediate)
    {
        const uint32_t value = static_cast<uint32_t>(immediate) & 0x3ffffu;
        return (static_cast<uint32_t>(opcode) << 26) |
            ((value >> 14) << 22) |
            (static_cast<uint32_t>(rs1) << 18) |
            (static_cast<uint32_t>(rt) << 14) |
            (value & 0x3fffu);
    }

    bool fits_signed(int32_t value, unsigned bits)
    {
        const int64_t minimum = -(int64_t{1} << (bits - 1));
        const int64_t maximum = (int64_t{1} << (bits - 1)) - 1;
        return value >= minimum && value <= maximum;
    }
} // namespace


struct assembler_context {
    std::vector<PendingWord> words;
    std::unordered_map<std::string, size_t> labels;
    std::string error;
};

extern "C" assembler_context *assembler_create(void) {
    return new assembler_context{};
}

extern "C" void assembler_destroy(assembler_context *context) {
    delete context;
}

extern "C" int assembler_label(assembler_context *context, const char *name, unsigned line) {
    if (context->labels.find(name) != context->labels.end()) {
        context->error = "line " + std::to_string(line) +
                         ": duplicate label '" + name + "'";
        return 0;
    }
    context->labels.emplace(name, context->words.size());
    return 1;
}

extern "C" int assembler_label_previous(assembler_context *context, const char *name, unsigned line) {
    if (context->words.empty()) {
        context->error = "line " + std::to_string(line) +
                         ": label has no instruction";
        return 0;
    }
    if (!assembler_label(context, name, line)) return 0;
    context->labels[name] = context->words.size() - 1;
    return 1;
}

extern "C" int assembler_emit_word(assembler_context *context, uint32_t word, unsigned line) {
    (void)line;
    context->words.push_back({word, {}, line, false});
    return 1;
}

extern "C" int assembler_emit0(assembler_context *context, uint8_t opcode, unsigned line) {
    return assembler_emit_word(context, static_cast<uint32_t>(opcode) << 26, line);
}

extern "C" int assembler_emit1(assembler_context *context, uint8_t opcode, uint8_t rd, int32_t immediate, unsigned line) {
    return assembler_emit_i(context, opcode, rd, 0, immediate, line);
}

extern "C" int assembler_emit_i(assembler_context *context, uint8_t opcode, uint8_t rd, uint8_t rs1, int32_t immediate, unsigned line) {
    if (!fits_signed(immediate, 18)) {
        context->error = "line " + std::to_string(line) + ": immediate out of range";
        return 0;
    }
    return assembler_emit_word(context, encode_i(opcode, rd, rs1, immediate), line);
}

extern "C" int assembler_emit2(assembler_context *context, uint8_t opcode, uint8_t rd, uint8_t rs1, uint8_t rs2, unsigned line) {
    return assembler_emit_word(context,
                               (static_cast<uint32_t>(opcode) << 26) |
                               (static_cast<uint32_t>(rd) << 22) |
                               (static_cast<uint32_t>(rs1) << 18) |
                               (static_cast<uint32_t>(rs2) << 14), line);
}

extern "C" int assembler_emit_mem(assembler_context *context, uint8_t opcode, uint8_t rt, int32_t offset, uint8_t base, unsigned line) {
    if (!fits_signed(offset, 18)) {
        context->error = "line " + std::to_string(line) + ": offset out of range";
        return 0;
    }
    return assembler_emit_word(context, encode_s(opcode, rt, base, offset), line);
}

extern "C" int assembler_emit_branch(assembler_context *context, uint8_t opcode, uint8_t rs1, const char *target, unsigned line) {
    PendingWord word{encode_s(opcode, 0, rs1, 0), target, line, true};
    context->words.push_back(std::move(word));
    return 1;
}

extern "C" int assembler_emit_branch_offset(assembler_context *context, uint8_t opcode, uint8_t rs1, int32_t offset, unsigned line) {
    if (!fits_signed(offset, 18)) {
        context->error = "line " + std::to_string(line) + ": branch offset out of range";
        return 0;
    }
    return assembler_emit_word(context, encode_s(opcode, 0, rs1, offset), line);
}

extern "C" int assembler_emit_jump(assembler_context *context, uint8_t opcode, const char *target, unsigned line) {
    PendingWord word{static_cast<uint32_t>(opcode) << 26, target, line, true};
    context->words.push_back(std::move(word));
    return 1;
}

extern "C" int assembler_emit_jump_offset(assembler_context *context, uint8_t opcode, int32_t offset, unsigned line) {
    if (!fits_signed(offset, 22)) {
        context->error = "line " + std::to_string(line) + ": jump offset out of range";
        return 0;
    }
    return assembler_emit_word(context,
                               (static_cast<uint32_t>(opcode) << 26) |
                               (static_cast<uint32_t>(offset) & 0x3fffffu), line);
}

extern "C" int assembler_write_hex(assembler_context *context, FILE *output) {
    for (const PendingWord &pending : context->words) {
        uint32_t word = pending.word;
        if (pending.has_target) {
            const auto it = context->labels.find(pending.target);
            if (it == context->labels.end()) {
                context->error = "line " + std::to_string(pending.line) +
                                 ": undefined label '" + pending.target + "'";
                return 0;
            }
            const int64_t offset = static_cast<int64_t>(it->second) -
                                   static_cast<int64_t>(&pending - context->words.data());
            if (pending.word >> 26 == OP_B) {
                if (offset < -(1 << 21) || offset > (1 << 21) - 1) {
                    context->error = "line " + std::to_string(pending.line) +
                                     ": jump offset out of range";
                    return 0;
                }
                word |= static_cast<uint32_t>(offset) & 0x3fffffu;
            } else {
                if (offset < -(1 << 17) || offset > (1 << 17) - 1) {
                    context->error = "line " + std::to_string(pending.line) +
                                     ": branch offset out of range";
                    return 0;
                }
                word = encode_s(static_cast<uint8_t>(pending.word >> 26),
                                static_cast<uint8_t>((pending.word >> 14) & 0xf),
                                static_cast<uint8_t>((pending.word >> 18) & 0xf),
                                static_cast<int32_t>(offset));
            }
        }
        if (fprintf(output, "%08X\n", word) < 0) return 0;
    }
    return 1;
}

extern "C" const char *assembler_error(const assembler_context *context) {
    return context->error.c_str();
}

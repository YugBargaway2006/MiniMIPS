# MiniMIPS Memory Map

This describes the current simulation RTL. Instruction and data memory are
separate; no shared bus or MMIO peripheral is implemented yet.

## Address Space (32-bit word-aligned)

| Region | Base Address | End Address | Size | Description |
|---|---|---|---|---|
| Instruction Memory | `0x00000000` | `0x000003FC` | 1 KB (256 words) | Program code loaded via `$readmemh` |
| Data Memory | `0x00000000` | `0x000003FC` | 1 KB (256 words) | Read/write data cache |

> Note: Instruction and data memories are **separate** (Harvard architecture).
> Both are indexed by `word_index = addr[9:2]` (8-bit index, ignoring byte offset bits [1:0]).
> The same numeric address can therefore exist in both memories.

There is currently no console address, halt address, interrupt region, or
uncached MMIO region.

## Reset and Halt

| Item | Value | Notes |
|---|---|---|
| Reset PC | `0x00000000` | `RESET_PC` parameter in `pc_unit` |
| Halt mechanism | `OP_halt` opcode (`6'b11_1111`) | Sets `is_halt = 1` in control_unit; `soc_top` drives `halted` output high |
| Halt instruction word | `0xFC000000` | `{OP_halt, 26'd0}` = `6'b111111_00...0` |

## Instruction Encoding (custom 32-bit fixed-width)

```
Bits [31:26]  = opcode (6 bits)
Bits [25:22]  = rd     (4 bits)  — destination register
Bits [21:18]  = rs1    (4 bits)  — source register 1
Bits [17:14]  = rs2    (4 bits)  — source register 2 / rt
Bits [13:0]   = imm_lo (14 bits) — lower immediate / shift amount
```

For **I-type** (`imm_i = instr[17:0]` = rs2 ++ imm_lo, 18-bit total):
```
Bits [17:14]  = high 4-bit immediate part
Bits [13:0]   = low 14-bit immediate part
```

For **S-type store** (`imm_s = {instr[25:22], instr[13:0]}`, 18-bit):
```
Bits [25:22]  = imm[17:14]
Bits [13:0]   = imm[13:0]
```

For **J-type branch/jump** (`imm_j = instr[21:0]`, 22-bit):
```
Bits [21:0]   = jump offset / target
```

## Register File

- **16 registers** (`R0`–`R15`), each 32-bit wide (4-bit address)
- All registers reset to 0 on system reset
- No hardwired-zero register (R0 can be written and read normally)

## Hex File Format

One 32-bit instruction per line, written as 8 uppercase hex characters, loaded with `$readmemh`. Example:
```
40400001   // addi R1, R0, 1    — R1 = 0 + 1
40800002   // addi R2, R0, 2    — R2 = 0 + 2
FC000000   // halt
```

## PC Addressing

- PC is a **byte address** (32-bit), increments by 4 bytes (1 instruction word) each cycle.
- Internally, `next_address` increments `PC[31:2]` by one word and shifts the
	result left by two to produce the byte address.
- Branch immediates are instruction-word offsets and are converted to byte
	addresses by the same logic.
- Instruction fetch: `word_index = PC[9:2]` (8-bit, selecting from 256-word cache).

## Current Execution Model

The current `soc_top` is a single-cycle datapath. IF/ID/EX/MEM/WB pipeline
registers, forwarding, and hazard logic are not implemented yet.

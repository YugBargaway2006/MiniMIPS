# MiniMIPS Assembler

MiniMIPS uses a custom assembler written with Flex and Bison. It converts
MiniMIPS source code into 32-bit hexadecimal words for Verilog `$readmemh`.

## Quick Start

From the repository root:

```sh
make preset
assember/build/minimips-as sw/asm/smoke.s -o sw/hex/smoke.hex
make run-soc_tb HEX=sw/hex/smoke.hex
```

The assembler supports `R0`-`R15`, labels, `.word`, memory operands, comments,
decimal values, hexadecimal values, and binary values. The `halt` instruction
ends a program and is emitted as `FC000000`.

For the full build and syntax reference, see
[`assember/README.md`](../assember/README.md).

## Assembly Flow

![Assembler flow](../assember/assets/assembler_design.png)

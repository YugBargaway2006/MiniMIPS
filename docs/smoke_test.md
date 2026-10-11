# Smoke Test

[`sw/asm/smoke.s`](../sw/asm/smoke.s) checks immediate arithmetic, register
arithmetic, and the halt instruction.

| Register | Expected | Calculation |
|---|---:|---|
| `R1` | `3` | `0 + 3` |
| `R2` | `7` | `0 + 7` |
| `R3` | `10` | `R1 + R2` |
| `R4` | `8` | `R3 - 2` |
| `R5` | `0` | `R3 - R3` |

Run it from the repository root:

```sh
make run-soc_tb HEX=sw/hex/smoke.hex
```

The testbench reports `PASS`, writes `build/soc_tb.dump`, and writes
`waves/soc_tb.vcd`. To also generate the trace:

```sh
make build/soc_tb.vvp
vvp build/soc_tb.vvp +HEX=sw/hex/smoke.hex +TRACE
```

With the current single-cycle RTL, the trace is written to
`build/soc_tb.trace`. Pipeline-stage, stall, flush, and forwarding fields are
not available until those hardware blocks are implemented.
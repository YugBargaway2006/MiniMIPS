IVERILOG ?= iverilog
VVP      ?= vvp
TOP      ?= soc_top
HEX      ?=

BUILD    := build
RTL      := $(shell find rtl -name '*.v')
TB_FILES := $(wildcard tb/unit/*_tb.v) $(wildcard tb/system/*_tb.v)
TB_NAMES := $(basename $(notdir $(TB_FILES)))
IVFLAGS  := -g2012 -Wall -Irtl/include

vpath %_tb.v tb/unit tb/system

.PHONY: help test lint clean
.PRECIOUS: $(BUILD)/%.vvp

help:
	@echo "make test                  run all testbenches, PASS/FAIL summary"
	@echo "make run-<tb>              build and run one testbench (e.g. run-alu_tb)"
	@echo "make run-<tb> HEX=<file>   pass +HEX=<file> to the testbench"
	@echo "make wave-<tb>             run, then open waves/<tb>.vcd in GTKWave"
	@echo "make lint                  Verilator lint of rtl/ (TOP=$(TOP))"
	@echo "make clean                 remove build output and waveforms"

$(BUILD)/%.vvp: %.v $(RTL)
	@mkdir -p $(BUILD) waves
	$(IVERILOG) $(IVFLAGS) -s $* -o $@ $< $(RTL)

run-%: $(BUILD)/%.vvp
	$(VVP) $< $(if $(HEX),+HEX=$(HEX))

wave-%: run-%
	gtkwave waves/$*.vcd &

test:
	@fail=0; \
	for t in $(TB_NAMES); do \
	  $(MAKE) -s $(BUILD)/$$t.vvp || { echo "[BUILD FAIL] $$t"; fail=1; continue; }; \
	  out=$$($(VVP) $(BUILD)/$$t.vvp 2>&1); \
	  if echo "$$out" | grep -q "FAIL" || ! echo "$$out" | grep -q "PASS"; then \
	    echo "[FAIL] $$t"; echo "$$out" | grep "FAIL" | head -5; fail=1; \
	  else echo "[PASS] $$t"; fi; \
	done; exit $$fail

lint:
	verilator --lint-only -Wall -Irtl/include $(RTL) --top-module $(TOP)

clean:
	rm -rf $(BUILD) waves/*.vcd
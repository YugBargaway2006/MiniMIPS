// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.


`timescale 1ns / 1ps
`default_nettype none


module alu_mux_tb;

    integer WORD_w = 32;

    reg [WORD_w-1:0] reg_data;
    reg [WORD_w-1:0] imm32;
    wire [WORD_w-1:0] alu_mux_out;
    
    reg         ALUSrc;

    integer errors = 0;
    integer test_count = 0;

    // Device under test
    alu_mux dut (
        .reg_data(reg_data),
        .imm32(imm32),
        .ALUSrc(ALUSrc),
        .alu_mux_out(alu_mux_out)
    );


    initial begin #50000; $display("FAIL: timeout"); $finish; end

    initial begin
        $dumpfile("waves/alu_mux_tb.vcd");
        $dumpvars(0, alu_mux_tb);
    end

    task check(input [31:0] exp, input [160:0] name);
    begin
        #1; test_count = test_count + 1;
        if (alu_mux_out !== exp) begin
            $display("FAIL [%0s]: ALUSrc=%0b | Got: 0x%08h | Expected: 0x%08h", name, ALUSrc, alu_mux_out, exp);
            errors = errors + 1;
        end
    end
    endtask


    initial begin
        reg_data = 32'hAAAA0000;
        imm32    = 32'h0000BBBB;

        // ALUSrc = 0 -> pass reg_data
        ALUSrc = 1'b0;
        check(32'hAAAA0000, "ALUSrc=0: reg_data");

        ALUSrc = 1'b0; reg_data = 32'hDEADBEEF; imm32 = 32'h12345678;
        check(32'hDEADBEEF, "ALUSrc=0: reg_data DEADBEEF");

        ALUSrc = 1'b0; reg_data = 32'd0;
        check(32'd0, "ALUSrc=0: zero reg_data");

        // ALUSrc = 1 -> pass imm32
        ALUSrc = 1'b1; reg_data = 32'hAAAAAAAA; imm32 = 32'h0000BBBB;
        check(32'h0000BBBB, "ALUSrc=1: imm32");

        ALUSrc = 1'b1; imm32 = 32'hFFFFFFFF;
        check(32'hFFFFFFFF, "ALUSrc=1: imm32 -1");

        ALUSrc = 1'b1; imm32 = 32'd0;
        check(32'd0, "ALUSrc=1: zero imm32");

        #5;
        if (errors == 0) $display("[PASS] alu_mux_tb: all %0d tests passed successfully.", test_count);
        else $display("[FAIL] alu_mux_tb: %0d / %0d tests failed.", errors, test_count);
        $finish;
    end


endmodule
`default_nettype wire


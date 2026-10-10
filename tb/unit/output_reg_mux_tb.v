// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.

`timescale 1ns / 1ps
`default_nettype none

module output_reg_mux_tb;

    localparam integer REG_w = 4;

    reg  [REG_w-1:0] rt;
    reg  [REG_w-1:0] rd;
    reg  [1:0]       RegDst;
    wire [REG_w-1:0] rw;

    integer errors = 0;
    integer test_count = 0;

    output_reg_mux #(.REG_w(REG_w)) dut (
        .rt    (rt),
        .rd    (rd),
        .RegDst(RegDst),
        .rw    (rw)
    );

    initial begin #50000; $display("FAIL: timeout"); $finish; end

    initial begin
        $dumpfile("waves/output_reg_mux_tb.vcd");
        $dumpvars(0, output_reg_mux_tb);
    end

    task check(input [REG_w-1:0] exp, input [160:0] name);
    begin
        #1; test_count = test_count + 1;
        if (rw !== exp) begin
            $display("FAIL [%0s]: rt=%0d rd=%0d RegDst=%0b | Got: %0d | Expected: %0d", name, rt, rd, RegDst, rw, exp);
            errors = errors + 1;
        end
    end
    endtask

    initial begin
        rt = 4'd5; rd = 4'd7;

        // 2'b00 -> rt
        RegDst = 2'b00;
        check(4'd5, "RegDst=00: rw=rt");

        rt = 4'd3; rd = 4'd12;
        RegDst = 2'b00;
        check(4'd3, "RegDst=00: rt=3");

        // 2'b01 -> rd
        RegDst = 2'b01;
        check(4'd12, "RegDst=01: rw=rd");

        rt = 4'd0; rd = 4'd15;
        RegDst = 2'b01;
        check(4'd15, "RegDst=01: rd=15");

        // 2'b10 -> all ones (link register)
        RegDst = 2'b10;
        check({REG_w{1'b1}}, "RegDst=10: rw=all-ones");

        // default (2'b11) -> all zeros
        RegDst = 2'b11;
        check({REG_w{1'b0}}, "RegDst=11: rw=all-zeros (default)");

        #5;
        if (errors == 0) $display("[PASS] output_reg_mux_tb: all %0d tests passed successfully.", test_count);
        else             $display("[FAIL] output_reg_mux_tb: %0d / %0d tests failed.", errors, test_count);
        $finish;
    end

endmodule
`default_nettype wire

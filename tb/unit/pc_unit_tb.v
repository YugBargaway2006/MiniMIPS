// Copyright (c) Yug Bargaway under Apache License 2.0
// See LICENSE.txt for details.

`timescale 1ns / 1ps
`default_nettype none

module pc_unit_tb;

    localparam integer PC_w = 32;

    reg clk;
    reg reset;
    reg  [PC_w-1:0] NextPC;
    wire [PC_w-1:0] PC;

    integer errors = 0;
    integer test_count = 0;

    pc_unit #(
        .PC_w(PC_w),
        .RESET_PC(32'h00000000)
    ) dut (
        .clk   (clk),
        .reset (reset),
        .NextPC(NextPC),
        .PC    (PC)
    );

    always #5 clk = ~clk;

    initial begin
        #50000;
        $display("FAIL: timeout");
        $finish;
    end

    initial begin
        $dumpfile("waves/pc_unit_tb.vcd");
        $dumpvars(0, pc_unit_tb);
    end

    task check(
        input [PC_w-1:0] exp_pc,
        input [160:0]    test_name
    );
    begin
        #1;
        test_count = test_count + 1;
        if (PC !== exp_pc) begin
            $display("FAIL [%0s]: NextPC=0x%08h | Got PC=0x%08h | Expected PC=0x%08h",
                     test_name, NextPC, PC, exp_pc);
            errors = errors + 1;
        end
    end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        NextPC = 32'hFFFFFFFF;

        // Reset check
        @(posedge clk);
        check(32'd0, "RESET: PC is 0");

        // Sequential update
        @(negedge clk);
        reset = 0;
        NextPC = 32'h00000004;
        @(posedge clk);
        check(32'h00000004, "UPDATE: PC = 4");

        @(negedge clk);
        NextPC = 32'h00000008;
        @(posedge clk);
        check(32'h00000008, "UPDATE: PC = 8");

        @(negedge clk);
        NextPC = 32'h0000000C;
        @(posedge clk);
        check(32'h0000000C, "UPDATE: PC = 12");

        // Jump to arbitrary address
        @(negedge clk);
        NextPC = 32'h00400020;
        @(posedge clk);
        check(32'h00400020, "JUMP: PC = 0x00400020");

        // Assert reset again
        @(negedge clk);
        reset = 1;
        NextPC = 32'h12345678;
        @(posedge clk);
        check(32'd0, "RESET AGAIN: PC resets to 0");

        #10;
        if (errors == 0) begin
            $display("[PASS] pc_unit_tb: all %0d tests passed successfully.", test_count);
        end else begin
            $display("[FAIL] pc_unit_tb: %0d / %0d tests failed.", errors, test_count);
        end
        $finish;
    end

endmodule
`default_nettype wire

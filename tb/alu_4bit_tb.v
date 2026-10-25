// ============================================================================
// Module Name:   alu_4bit_tb
// Project:       Simple ALU Using Verilog HDL
// Course:        B.Tech CSE — Semester 3 (Digital Electronics)
// Course Outcome: CO5: Create simulation models of digital circuits using HDL
//                 and software tool that verify functionality and evaluate performance.
// Description:   Self-checking stimulus testbench for 4-bit ALU.
//                 Verifies all 6 functional opcodes, unused opcodes, and all
//                 status flags (Carry, Borrow, Zero) against golden references.
//                 Dumps simulation waveforms to sim/alu_wave.vcd for GTKWave analysis.
// ============================================================================

`timescale 1ns / 1ps

module alu_4bit_tb;

    // ------------------------------------------------------------------------
    // Signals to Drive Device Under Test (DUT)
    // ------------------------------------------------------------------------
    reg  [3:0] A;       // 4-bit input operand A
    reg  [3:0] B;       // 4-bit input operand B
    reg  [2:0] opcode;  // 3-bit operation code selector

    // ------------------------------------------------------------------------
    // Signals Monitored from DUT
    // ------------------------------------------------------------------------
    wire [3:0] result;  // 4-bit output result from DUT
    wire       carry;   // Carry flag from DUT
    wire       borrow;  // Borrow flag from DUT
    wire       zero;    // Zero flag from DUT

    // ------------------------------------------------------------------------
    // Expected Golden Reference Signals for Self-Checking
    // ------------------------------------------------------------------------
    reg  [3:0] exp_result;
    reg        exp_carry;
    reg        exp_borrow;
    reg        exp_zero;

    // ------------------------------------------------------------------------
    // Verification Tracking Counters
    // ------------------------------------------------------------------------
    integer pass_count;
    integer fail_count;
    integer test_num;

    // ------------------------------------------------------------------------
    // Instantiate the Device Under Test (DUT)
    // ------------------------------------------------------------------------
    alu_4bit uut (
        .A(A),
        .B(B),
        .opcode(opcode),
        .result(result),
        .carry(carry),
        .borrow(borrow),
        .zero(zero)
    );

    // ------------------------------------------------------------------------
    // Verification Task: apply_and_check
    // ------------------------------------------------------------------------
    // Applies inputs, waits 10ns for combinational propagation, and compares
    // all four outputs (result, carry, borrow, zero) with expected values.
    // ------------------------------------------------------------------------
    task apply_and_check;
        input [3:0] in_A;
        input [3:0] in_B;
        input [2:0] in_op;
        input [3:0] e_res;
        input       e_c;
        input       e_b;
        input       e_z;
        input [35*8:1] t_desc; // Test description string
        begin
            test_num   = test_num + 1;
            A          = in_A;
            B          = in_B;
            opcode     = in_op;
            exp_result = e_res;
            exp_carry  = e_c;
            exp_borrow = e_b;
            exp_zero   = e_z;

            #10; // Allow combinational logic settling time

            // Compare actual DUT outputs with golden expected values
            if (result === exp_result &&
                carry  === exp_carry  &&
                borrow === exp_borrow &&
                zero   === exp_zero) begin
                $display("[PASS] Test %2d: %-30s | A=%2d B=%2d op=%b | res=%2d C=%b B=%b Z=%b",
                         test_num, t_desc, A, B, opcode, result, carry, borrow, zero);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %2d: %-30s | A=%2d B=%2d op=%b | res=%2d (exp %2d) C=%b (exp %b) B=%b (exp %b) Z=%b (exp %b)",
                         test_num, t_desc, A, B, opcode, result, exp_result, carry, exp_carry, borrow, exp_borrow, zero, exp_zero);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ------------------------------------------------------------------------
    // Main Stimulus and Checking Process
    // ------------------------------------------------------------------------
    initial begin
        // Configure VCD Waveform generation for GTKWave
        $dumpfile("sim/alu_wave.vcd");
        $dumpvars(0, alu_4bit_tb);

        // Initialize counters
        pass_count = 0;
        fail_count = 0;
        test_num   = 0;

        $display("==========================================================================");
        $display("          4-BIT SIMPLE ALU SELF-CHECKING VERIFICATION SUITE              ");
        $display("==========================================================================");
        $display("Time Scale: 1ns / 1ps | Waveform Target: sim/alu_wave.vcd");
        $display("--------------------------------------------------------------------------");

        // ====================================================================
        // Group 1: Opcode 3'b000 - Addition Tests
        // ====================================================================
        // Test 1: Addition without carry (3 + 2 = 5)
        apply_and_check(4'd3, 4'd2, 3'b000, 4'd5, 1'b0, 1'b0, 1'b0, "Add without carry (3+2)");

        // Test 2: Addition with carry and zero result (15 + 1 = 16 -> res=0, C=1, Z=1)
        apply_and_check(4'd15, 4'd1, 3'b000, 4'd0, 1'b1, 1'b0, 1'b1, "Add with carry & zero (15+1)");

        // Test 3: Maximum addition (15 + 15 = 30 -> res=14, C=1, Z=0)
        apply_and_check(4'd15, 4'd15, 3'b000, 4'd14, 1'b1, 1'b0, 1'b0, "Maximum addition (15+15)");

        // Test 4: Addition with both zeros (0 + 0 = 0 -> res=0, C=0, Z=1)
        apply_and_check(4'd0, 4'd0, 3'b000, 4'd0, 1'b0, 1'b0, 1'b1, "Add zeros (0+0)");

        // Test 5: Addition boundary (8 + 8 = 16 -> res=0, C=1, Z=1)
        apply_and_check(4'd8, 4'd8, 3'b000, 4'd0, 1'b1, 1'b0, 1'b1, "Add boundary (8+8)");

        // ====================================================================
        // Group 2: Opcode 3'b001 - Subtraction Tests
        // ====================================================================
        // Test 6: Subtraction without borrow (7 - 3 = 4)
        apply_and_check(4'd7, 4'd3, 3'b001, 4'd4, 1'b0, 1'b0, 1'b0, "Sub without borrow (7-3)");

        // Test 7: Subtraction with borrow (3 - 7 = 12 mod 16, B=1)
        apply_and_check(4'd3, 4'd7, 3'b001, 4'd12, 1'b0, 1'b1, 1'b0, "Sub with borrow (3-7)");

        // Test 8: Equal subtraction (5 - 5 = 0 -> res=0, B=0, Z=1)
        apply_and_check(4'd5, 4'd5, 3'b001, 4'd0, 1'b0, 1'b0, 1'b1, "Equal subtraction (5-5)");

        // Test 9: Subtraction underflow boundary (0 - 1 = 15 mod 16, B=1)
        apply_and_check(4'd0, 4'd1, 3'b001, 4'd15, 1'b0, 1'b1, 1'b0, "Sub underflow boundary (0-1)");

        // Test 10: Subtraction with zeros (0 - 0 = 0 -> res=0, B=0, Z=1)
        apply_and_check(4'd0, 4'd0, 3'b001, 4'd0, 1'b0, 1'b0, 1'b1, "Sub zeros (0-0)");

        // ====================================================================
        // Group 3: Opcode 3'b010 - Bitwise AND Tests
        // ====================================================================
        // Test 11: Standard AND (1100 & 1010 = 1000 -> 8)
        apply_and_check(4'b1100, 4'b1010, 3'b010, 4'b1000, 1'b0, 1'b0, 1'b0, "Bitwise AND (1100 & 1010)");

        // Test 12: Bitwise AND yielding zero (1100 & 0011 = 0000 -> Z=1)
        apply_and_check(4'b1100, 4'b0011, 3'b010, 4'b0000, 1'b0, 1'b0, 1'b1, "Bitwise AND zero (1100 & 0011)");

        // Test 13: Bitwise AND with mask 1111 (1010 & 1111 = 1010)
        apply_and_check(4'b1010, 4'b1111, 3'b010, 4'b1010, 1'b0, 1'b0, 1'b0, "Bitwise AND with 1111 mask");

        // ====================================================================
        // Group 4: Opcode 3'b011 - Bitwise OR Tests
        // ====================================================================
        // Test 14: Standard OR (1100 | 1010 = 1110 -> 14)
        apply_and_check(4'b1100, 4'b1010, 3'b011, 4'b1110, 1'b0, 1'b0, 1'b0, "Bitwise OR (1100 | 1010)");

        // Test 15: Bitwise OR all ones (1010 | 0101 = 1111 -> 15)
        apply_and_check(4'b1010, 4'b0101, 3'b011, 4'b1111, 1'b0, 1'b0, 1'b0, "Bitwise OR all ones");

        // Test 16: Bitwise OR zeros (0000 | 0000 = 0000 -> Z=1)
        apply_and_check(4'b0000, 4'b0000, 3'b011, 4'b0000, 1'b0, 1'b0, 1'b1, "Bitwise OR zeros");

        // ====================================================================
        // Group 5: Opcode 3'b100 - Bitwise XOR Tests
        // ====================================================================
        // Test 17: Standard XOR (1100 ^ 1010 = 0110 -> 6)
        apply_and_check(4'b1100, 4'b1010, 3'b100, 4'b0110, 1'b0, 1'b0, 1'b0, "Bitwise XOR (1100 ^ 1010)");

        // Test 18: Bitwise XOR equal operands (1010 ^ 1010 = 0000 -> Z=1)
        apply_and_check(4'b1010, 4'b1010, 3'b100, 4'b0000, 1'b0, 1'b0, 1'b1, "Bitwise XOR equal (1010^1010)");

        // Test 19: Bitwise XOR with zero (1010 ^ 0000 = 1010)
        apply_and_check(4'b1010, 4'b0000, 3'b100, 4'b1010, 1'b0, 1'b0, 1'b0, "Bitwise XOR with zero");

        // ====================================================================
        // Group 6: Opcode 3'b101 - Bitwise NOT (A) Tests
        // ====================================================================
        // Test 20: Standard NOT A (~1010 = 0101 -> 5)
        apply_and_check(4'b1010, 4'b0000, 3'b101, 4'b0101, 1'b0, 1'b0, 1'b0, "Bitwise NOT A (~1010)");

        // Test 21: Bitwise NOT of 1111 (~1111 = 0000 -> Z=1)
        apply_and_check(4'b1111, 4'b0000, 3'b101, 4'b0000, 1'b0, 1'b0, 1'b1, "Bitwise NOT 1111 (~1111)");

        // Test 22: Bitwise NOT of 0000 (~0000 = 1111 -> 15)
        apply_and_check(4'b0000, 4'b0000, 3'b101, 4'b1111, 1'b0, 1'b0, 1'b0, "Bitwise NOT 0000 (~0000)");

        // ====================================================================
        // Group 7: Opcodes 3'b110 & 3'b111 - Reserved / Unused Opcodes
        // ====================================================================
        // Test 23: Unused Opcode 110 (result=0, C=0, B=0, Z=1)
        apply_and_check(4'd12, 4'd5, 3'b110, 4'd0, 1'b0, 1'b0, 1'b1, "Reserved Opcode 110 (Safe 0)");

        // Test 24: Unused Opcode 111 (result=0, C=0, B=0, Z=1)
        apply_and_check(4'd7, 4'd3, 3'b111, 4'd0, 1'b0, 1'b0, 1'b1, "Reserved Opcode 111 (Safe 0)");

        // --------------------------------------------------------------------
        // Print Summary Report
        // --------------------------------------------------------------------
        #10;
        $display("--------------------------------------------------------------------------");
        $display("VERIFICATION SUMMARY: TOTAL TESTS = %0d | PASSED = %0d | FAILED = %0d",
                 test_num, pass_count, fail_count);
        $display("--------------------------------------------------------------------------");

        if (fail_count == 0) begin
            $display(">>> ALL %0d VERIFICATION TESTS PASSED SUCCESSFULLY! <<<", pass_count);
        end else begin
            $display(">>> CRITICAL: %0d TESTS FAILED! REVIEW DUT RTL. <<<", fail_count);
        end
        $display("==========================================================================");

        $finish;
    end

endmodule

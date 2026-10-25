// ============================================================================
// Module Name:   alu_4bit
// Project:       Simple ALU Using Verilog HDL
// Course:        B.Tech CSE — Semester 3 (Digital Electronics)
// Course Outcome: CO5: Create simulation models of digital circuits using HDL
//                 and software tool that verify functionality and evaluate performance.
// Description:   A 4-bit Arithmetic Logic Unit (ALU) supporting 6 operations
//                 (Addition, Subtraction, AND, OR, XOR, NOT) with status flags:
//                 - carry  : Indicates unsigned overflow during addition
//                 - borrow : Indicates unsigned underflow during subtraction (A < B)
//                 - zero   : Asserted whenever the 4-bit result is 4'b0000
// ============================================================================

`timescale 1ns / 1ps

module alu_4bit (
    // ------------------------------------------------------------------------
    // Input Ports
    // ------------------------------------------------------------------------
    input  wire [3:0] A,        // 4-bit first data operand  (values 0 to 15)
    input  wire [3:0] B,        // 4-bit second data operand (values 0 to 15)
    input  wire [2:0] opcode,   // 3-bit operation code selector

    // ------------------------------------------------------------------------
    // Output Ports
    // ------------------------------------------------------------------------
    output reg  [3:0] result,   // 4-bit primary computation output
    output reg        carry,    // 1-bit Carry flag (valid for addition)
    output reg        borrow,   // 1-bit Borrow flag (valid for subtraction)
    output wire       zero      // 1-bit Zero flag (active-high when result == 0)
);

    // ------------------------------------------------------------------------
    // Internal Registers for Intermediate Arithmetic Calculations
    // ------------------------------------------------------------------------
    // Why 5 bits?
    // When adding two 4-bit numbers (e.g., 15 + 15 = 30), the sum can exceed
    // 4 bits (max 15). A 5th bit (bit index 4) is required to capture the
    // carry-out without losing data due to bit truncation.
    // Similarly, a 5-bit calculation for subtraction allows clean representation
    // of borrow and underflow conditions.
    // ------------------------------------------------------------------------
    reg [4:0] sum_ext;   // 5-bit temporary holder for addition: {carry, result}
    reg [4:0] diff_ext;  // 5-bit temporary holder for subtraction: {borrow, result}

    // ------------------------------------------------------------------------
    // Combinational Logic Block: always @(*)
    // ------------------------------------------------------------------------
    // The wildcard '@(*)' tells the synthesis and simulation tools to trigger
    // this block whenever ANY of the inputs (A, B, opcode) change.
    // ------------------------------------------------------------------------
    always @(*) begin
        // Safe Default Values:
        // In digital hardware modeling, assigning defaults at the top of the
        // combinational block guarantees that every output is driven in every
        // execution path. This strictly prevents the unintended synthesis of
        // hardware latches (memory elements that cause timing issues).
        result   = 4'b0000;
        carry    = 1'b0;
        borrow   = 1'b0;
        sum_ext  = 5'b00000;
        diff_ext = 5'b00000;

        case (opcode)
            // ----------------------------------------------------------------
            // Opcode 3'b000: Addition (A + B)
            // ----------------------------------------------------------------
            // We zero-extend operands A and B from 4 bits to 5 bits using {1'b0, ...}.
            // - sum_ext[3:0] becomes the 4-bit arithmetic result.
            // - sum_ext[4]   becomes the carry-out flag (1 if sum > 15).
            // - borrow flag  is not applicable for addition and is cleared to 0.
            // ----------------------------------------------------------------
            3'b000: begin
                sum_ext = {1'b0, A} + {1'b0, B};
                result  = sum_ext[3:0];
                carry   = sum_ext[4];
                borrow  = 1'b0;
            end

            // ----------------------------------------------------------------
            // Opcode 3'b001: Subtraction (A - B)
            // ----------------------------------------------------------------
            // In unsigned subtraction:
            // - If A >= B: difference is positive or zero, no borrow needed (borrow = 0).
            // - If A < B : unsigned underflow occurs; borrow is asserted (borrow = 1).
            // We use diff_ext to compute modular 4-bit difference.
            // - carry flag is not applicable for subtraction and is cleared to 0.
            // ----------------------------------------------------------------
            3'b001: begin
                diff_ext = {1'b0, A} - {1'b0, B};
                result   = diff_ext[3:0];
                carry    = 1'b0;
                borrow   = (A < B) ? 1'b1 : 1'b0;
            end

            // ----------------------------------------------------------------
            // Opcode 3'b010: Bitwise AND (A & B)
            // ----------------------------------------------------------------
            // Performs logical AND on each corresponding bit pair:
            // result[i] = A[i] AND B[i] for i = 0, 1, 2, 3.
            // Carry and borrow are cleared to 0 for all logical operations.
            // ----------------------------------------------------------------
            3'b010: begin
                result = A & B;
                carry  = 1'b0;
                borrow = 1'b0;
            end

            // ----------------------------------------------------------------
            // Opcode 3'b011: Bitwise OR (A | B)
            // ----------------------------------------------------------------
            // Performs logical OR on each corresponding bit pair:
            // result[i] = A[i] OR B[i] for i = 0, 1, 2, 3.
            // ----------------------------------------------------------------
            3'b011: begin
                result = A | B;
                carry  = 1'b0;
                borrow = 1'b0;
            end

            // ----------------------------------------------------------------
            // Opcode 3'b100: Bitwise XOR (A ^ B)
            // ----------------------------------------------------------------
            // Performs logical Exclusive-OR on each corresponding bit pair:
            // result[i] = A[i] XOR B[i] for i = 0, 1, 2, 3.
            // ----------------------------------------------------------------
            3'b100: begin
                result = A ^ B;
                carry  = 1'b0;
                borrow = 1'b0;
            end

            // ----------------------------------------------------------------
            // Opcode 3'b101: Bitwise NOT of A (~A)
            // ----------------------------------------------------------------
            // Inverts each bit of operand A (1's complement of A):
            // result[i] = NOT(A[i]) for i = 0, 1, 2, 3.
            // Operand B is ignored for this unary operation.
            // ----------------------------------------------------------------
            3'b101: begin
                result = ~A;
                carry  = 1'b0;
                borrow = 1'b0;
            end

            // ----------------------------------------------------------------
            // Opcodes 3'b110 & 3'b111: Reserved / Unused Opcodes
            // ----------------------------------------------------------------
            // The specification strictly requires:
            // - result must be forced to zero (4'b0000).
            // - carry and borrow flags must be cleared (1'b0).
            // - zero flag evaluates to 1 because the result is 4'b0000.
            // ----------------------------------------------------------------
            3'b110,
            3'b111: begin
                result = 4'b0000;
                carry  = 1'b0;
                borrow = 1'b0;
            end

            // ----------------------------------------------------------------
            // Default Case: Catch-All for Robust Hardware Design
            // ----------------------------------------------------------------
            default: begin
                result = 4'b0000;
                carry  = 1'b0;
                borrow = 1'b0;
            end
        endcase
    end

    // ------------------------------------------------------------------------
    // Continuous Assignment for Zero Flag (zero)
    // ------------------------------------------------------------------------
    // The zero flag is an active-high status signal.
    // It is driven using a continuous assignment (`assign`) so that it
    // immediately and automatically reflects whether the current `result` is
    // zero (4'b0000).
    //
    // Equivalent hardware representations:
    // 1) Equality comparison:  (result == 4'b0000)
    // 2) Unary NOR reduction:  ~(|result)
    // Both produce identical hardware (a 4-input NOR gate feeding the zero wire).
    // ------------------------------------------------------------------------
    assign zero = (result == 4'b0000);

endmodule

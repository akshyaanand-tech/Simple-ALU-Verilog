# Viva Voce Examination Questions & Answers

**Project:** Simple ALU Using Verilog HDL  
**Course:** B.Tech CSE — Semester 3 (Digital Electronics)  
**Target Outcome:** CO5: Create simulation models of digital circuits using HDL and software tool that verify functionality and evaluate performance.

---

### Q1. What is an Arithmetic Logic Unit (ALU), and where is it located in a computer?
**Answer:**  
An ALU is the primary combinational computational unit within the Central Processing Unit (CPU). It performs elementary mathematical operations (such as addition and subtraction) and bitwise logical operations (such as AND, OR, XOR, and NOT) on binary data provided by processor registers.

---

### Q2. Why did you choose a 4-bit ALU for this project instead of 32-bit or 64-bit?
**Answer:**  
A 4-bit word size ($0$ to $15$ in unsigned decimal) provides the ideal pedagogical scale for Semester 3 Digital Electronics. It is large enough to demonstrate full digital concepts—including multi-bit addition, carry propagation, subtraction borrow underflow, and gate-level multiplexing—while remaining small enough to permit exhaustive test vector analysis ($16 \times 16 = 256$ total input combinations) and clean visual inspection of individual bit traces in GTKWave.

---

### Q3. What is the fundamental difference between a Hardware Description Language (HDL) and a software programming language like C or Java?
**Answer:**  
Software languages (C, Python, Java) describe a sequential series of instructions executed step-by-step by a processor. An HDL (Verilog, VHDL) describes the **physical hardware architecture and parallel interconnection of digital components** (wires, logic gates, multiplexers, and flip-flops) that all operate concurrently in physical silicon.

---

### Q4. What does "Register-Transfer Level" (RTL) modeling mean in Verilog?
**Answer:**  
RTL is an intermediate level of hardware abstraction. It specifies how digital signals flow between hardware storage elements and how combinational logic transforms those signals during transfer, without requiring the engineer to draw individual transistors or primitive logic gates manually.

---

### Q5. What is a combinational circuit, and how does your ALU demonstrate combinational logic?
**Answer:**  
A combinational circuit is a digital circuit whose outputs depend **strictly and immediately on the current values of its inputs**, with no memory of past states. The 4-bit ALU is purely combinational: whenever `A`, `B`, or `opcode` changes, `result` and the flags update after the logic propagation delay without waiting for a clock edge.

---

### Q6. Why did you use `always @(*)` instead of listing individual signals in the sensitivity list?
**Answer:**  
The wildcard `@(*)` (introduced in Verilog-2001) automatically includes all signals read inside the block (`A`, `B`, and `opcode`) in the sensitivity list. This prevents human errors where an omitted input signal causes simulation to behave like a latch while synthesis synthesizes pure combinational logic—a dangerous simulation-synthesis mismatch.

---

### Q7. How does a `case (opcode)` statement synthesize into hardware?
**Answer:**  
In hardware, a `case` statement synthesizes into an **8-to-1 multiplexer** (data selector) or an address-decoded sum-of-products network. The 3-bit opcode acts as the select lines that route one of the 8 computation paths to the 4-bit `result` bus.

---

### Q8. What is an unintended hardware latch, and how did you prevent it in your ALU?
**Answer:**  
An unintended latch is a level-sensitive memory element accidentally inferred by synthesis tools when a signal in a combinational `always` block is not assigned a value in every possible execution branch. We prevented latches by:
1. Assigning safe default values (`result = 0`, `carry = 0`, `borrow = 0`) at the very top of `always @(*)`.
2. Fully specifying every output in all `case` branches.
3. Adding an explicit `default:` fallback clause.

---

### Q9. How is the Carry flag generated during addition, and why is an extended 5-bit register needed?
**Answer:**  
When adding two 4-bit numbers, the maximum sum is $15 + 15 = 30$ ($11110_2$), which requires 5 binary bits. In `alu_4bit.v`, we evaluate `{1'b0, A} + {1'b0, B}` into a 5-bit register `sum_ext`. The 5th bit (`sum_ext[4]`) represents the carry-out from the most significant bit (MSB, bit 3). If `sum_ext[4] == 1`, unsigned addition overflow has occurred, and `carry` is asserted.

---

### Q10. How does the Borrow flag work in unsigned subtraction?
**Answer:**  
In unsigned 4-bit subtraction $A - B$:
- If $A \ge B$, the result is non-negative, and no borrow is needed (`borrow = 0`).
- If $A < B$, an unsigned underflow occurs. The subtraction requires borrowing from a non-existent 5th bit (`borrow = 1`), and the 4-bit result wraps around modulo 16 as $(16 + A - B)$. For example, $3 - 7$ yields $12$ with `borrow = 1`.

---

### Q11. Why is the Zero flag computed using continuous assignment (`assign zero = (result == 4'b0000)`)?
**Answer:**  
Continuous assignment connects the zero flag directly to the output of a 4-input NOR gate monitoring `result[3:0]`. This ensures that the Zero flag updates automatically whenever `result` changes across all operations, avoiding redundant code inside the `case` statement and ensuring consistency even for unused opcodes.

---

### Q12. How do you handle unused opcodes `3'b110` and `3'b111`, and why is this important?
**Answer:**  
Both unused opcodes are explicitly driven to `result = 4'b0000`, `carry = 0`, `borrow = 0`, and `zero = 1`. In hardware engineering, leaving states undefined can cause floating buses, unpredictable synthesis results, and excessive dynamic power dissipation due to circuit oscillation.

---

### Q13. What is the role of a testbench, and why is it called "self-checking"?
**Answer:**  
A testbench is a separate Verilog module (`tb/alu_4bit_tb.v`) that provides virtual input stimuli and monitors outputs without itself being synthesized into hardware. It is "self-checking" because it compares actual DUT outputs against hardcoded expected golden values in software and automatically prints PASS or FAIL messages, eliminating the need for human inspection of thousands of numbers.

---

### Q14. What are Icarus Verilog (`iverilog`) and `vvp`?
**Answer:**  
- **`iverilog`:** An open-source IEEE-1364 Verilog compiler that parses RTL and testbench code, checks syntax, resolves signal connections, and translates the design into executable intermediate v-code.
- **`vvp`:** The runtime simulation engine that executes the compiled v-code and coordinates simulation events, delays (`#10`), and waveform dumps.

---

### Q15. What is a Value Change Dump (`.vcd`) file, and how is it used in GTKWave?
**Answer:**  
A `.vcd` file is an ASCII-based industry standard format generated during simulation by `$dumpfile` and `$dumpvars`. It logs the exact simulation time stamp whenever any digital signal changes its state ($0 \to 1$, $1 \to 0$, or multi-bit transitions). GTKWave reads this file to graphically display signal waveforms on a timeline for visual debugging.

---

### Q16. What is the difference between Functional Simulation and Logic Synthesis?
**Answer:**  
- **Functional Simulation (Phase 3):** Simulates the mathematical and behavioral correctness of Verilog code in software, assuming zero delay or idealized delays, to verify logical functionality.
- **Logic Synthesis (Phase 4):** A hardware compiler (like Yosys) translates the abstract Verilog description into an actual structural netlist composed of real physical logic gates (AND, OR, NOT, XOR) and optimizes the circuit for area and speed.

---

### Q17. What is Yosys, and what role did it play in this project?
**Answer:**  
Yosys is an open-source framework for Verilog RTL synthesis. In this project, Yosys parsed `src/alu_4bit.v`, performed behavioral elaboration, eliminated unused logic, technology-mapped the operations into standard cell gates, and generated an output gate netlist (`syn/alu_synth.v`) along with gate count statistics.

---

### Q18. How many total logic gates did your ALU synthesize into, and what are their types?
**Answer:**  
The ALU synthesized into **133 total basic logic gates**:
- **51 AND gates (`$_AND_`):** Used in multiplexer trees and carry lookahead chains.
- **50 OR gates (`$_OR_`):** Used for multiplexer output merging and adder sums.
- **24 Inverters (`$_NOT_`):** Used for bitwise NOT, subtractor inverters, and address decoding.
- **8 XOR gates (`$_XOR_`):** Used for bitwise XOR and adder half-adder circuits.

---

### Q19. Does functional simulation prove the maximum operating clock frequency or silicon area of a circuit?
**Answer:**  
**No.** Functional simulation only verifies logical truth table correctness. Real-world propagation delays, maximum clock frequency ($F_{\max}$), dynamic power, and physical silicon area can only be determined through Static Timing Analysis (STA) and physical Place-and-Route (P&R) tools targeting a specific semiconductor technology library (e.g., TSMC $65\,\text{nm}$) or FPGA device.

---

### Q20. How does this project directly satisfy Course Outcome CO5?
**Answer:**  
Course Outcome CO5 requires students to:
> *"Create simulation models of digital circuits using HDL and software tool that verify functionality and evaluate performance."*

Our project satisfies every part of this outcome:
1. **Simulation Model in HDL:** Modeled the 4-bit ALU in IEEE Verilog HDL (`alu_4bit.v`).
2. **Software Tool for Verification:** Used Icarus Verilog (`iverilog`/`vvp`) and GTKWave to execute 24 self-checking tests (100% pass rate) and analyze waveforms.
3. **Performance Evaluation:** Used Yosys 0.9 to synthesize the design into generic logic gates, evaluate gate counts (133 gates), evaluate cell complexity, and document physical timing analysis requirements in a comprehensive report.

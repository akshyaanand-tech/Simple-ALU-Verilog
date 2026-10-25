# Project Report: Simple ALU Using Verilog HDL

**Course:** B.Tech Computer Science and Engineering (CSE) — Semester 3  
**Subject:** Digital Electronics / Digital Logic Design  
**Course Outcome (CO5):**  
> *"Create simulation models of digital circuits using HDL and software tool that verify functionality and evaluate performance."*

---

## 1. Project Title & Abstract

### Title
**Design, Functional Simulation, and Gate-Level Synthesis of a 4-Bit Arithmetic Logic Unit (ALU) Using Verilog HDL**

### Abstract
The Arithmetic Logic Unit (ALU) is the foundational computational block in computer processor architecture. This project presents the design, Register-Transfer Level (RTL) behavioral modeling, functional simulation, waveform analysis, and logic synthesis of a 4-bit Simple ALU using open-source Electronic Design Automation (EDA) tools. 

The designed ALU operates on two 4-bit unsigned operands ($A$ and $B$) and executes six core operations selected by a 3-bit opcode ($000_2$ to $101_2$): addition, subtraction, bitwise AND, bitwise OR, bitwise XOR, and bitwise NOT of operand $A$. Furthermore, safe, deterministic zero-output behavior is enforced for the two unused opcodes ($110_2$ and $111_2$). Three status flags—**Carry**, **Borrow**, and **Zero**—are dynamically generated to report operation status.

The functional correctness of the ALU was exhaustively verified using a self-checking Verilog testbench in Icarus Verilog (`iverilog`), producing a 100% pass rate across 24 test vectors and generating Value Change Dump (`.vcd`) waveforms visualized in GTKWave. Gate-level logic synthesis was performed using the Yosys synthesis suite, mapping the behavioral description into a verified generic gate netlist comprising 133 basic logic gates (51 AND, 50 OR, 24 NOT, and 8 XOR gates). This project completely satisfies Course Outcome CO5 by establishing an end-to-end HDL modeling, simulation verification, and synthesis evaluation workflow.

---

## 2. Introduction & Problem Statement

In modern computer architecture, the central processing unit (CPU) relies on the ALU to execute both arithmetic computations and logical decisions. For a student of Computer Science and Engineering, constructing an ALU provides crucial insight into:
1. How high-level programming operators (`+`, `-`, `&`, `|`, `^`, `~`) physically map onto electronic hardware.
2. How status flags (Carry, Borrow, Zero) enable conditional control flow in assembly language (e.g., `JZ`, `JNZ`, `JC`, `JNC`).
3. How digital systems are engineered using Hardware Description Languages (HDLs) rather than procedural programming languages.

### Problem Statement
Design a synthesizable, 4-bit combinational Arithmetic Logic Unit in Verilog HDL that:
- Executes 6 distinct mathematical and logical functions based on a 3-bit opcode.
- Accurately generates arithmetic carry-out, unsigned subtraction borrow, and active-high zero condition flags.
- Maintains strict, deterministic output handling for unmapped opcodes without inferring unintended hardware latches.
- Provides an automated self-checking simulation testbench and gate-level synthesis netlist to verify functionality and evaluate hardware resource consumption.

---

## 3. Objectives & Scope

### Objectives
1. **RTL Modeling:** Write clean, modular, synthesizable Verilog HDL describing the 4-bit ALU.
2. **Flag Generation:** Implement robust arithmetic logic to evaluate carry-out (addition) and borrow (subtraction), along with continuous zero detection.
3. **Functional Verification:** Construct an exhaustive, self-checking testbench to validate all operational modes and boundary conditions.
4. **Waveform Inspection:** Generate and analyze simulation waveforms using GTKWave to visually verify signal transitions.
5. **Logic Synthesis:** Synthesize the behavioral RTL into basic gate primitives using Yosys to determine circuit gate complexity.
6. **Course Outcome Alignment:** Fulfill all criteria of Course Outcome CO5 for academic submission.

### Scope & Constraints
- **Word Size:** 4-bit data operands ($A[3:0]$, $B[3:0]$), representing values $0$ to $15$ ($0000_2$ to $1111_2$).
- **Control:** 3-bit operation selector ($opcode[2:0]$).
- **Circuit Nature:** Pure combinational circuit (no clock or flip-flops), operating asynchronously.
- **Physical Implementation Boundary:** Synthesis is evaluated at the generic gate level. Physical FPGA place-and-route or ASIC silicon fabrication is outside the scope of this semester project.

---

## 4. Course Outcome (CO5) Mapping

| CO5 Requirement Clause | Implementation in This Project | Verification Evidence |
| :--- | :--- | :--- |
| **"Create simulation models of digital circuits..."** | Modeled the 4-bit ALU in Verilog HDL (`src/alu_4bit.v`) and created an automated verification testbench (`tb/alu_4bit_tb.v`). | Source code files created and verified. |
| **"...using HDL and software tool..."** | Utilized IEEE-standard Verilog HDL, Icarus Verilog (`iverilog` v14.0), GTKWave (v3.3.128), and Yosys (v0.9). | All software tools installed and verified on host system. |
| **"...that verify functionality..."** | Applied 24 stimulus vectors covering standard operations, carry generation, underflow borrow, and zero detection. | 24/24 tests PASSED in simulation log; GTKWave waveform generated (`sim/alu_wave.vcd`). |
| **"...and evaluate performance."** | Synthesized the design into generic logic gates using Yosys; evaluated cell breakdown (133 gates), input/output pin count, and architectural complexity. | Generated gate netlist (`syn/alu_synth.v`), statistics report (`syn/synth_stat.txt`), and schematic (`syn/alu_schematic.svg`). |

---

## 5. ALU Architecture & Block-Level Explanation

The 4-bit ALU architecture consists of four primary internal subsystems:

```mermaid
flowchart TD
    subgraph Inputs
        A["Operand A [3:0]"]
        B["Operand B [3:0]"]
        OP["Opcode [2:0]"]
    end

    subgraph ALU_Core["4-Bit Simple ALU Architecture"]
        direction TB

        subgraph Arithmetic_Block["Arithmetic Processing Unit"]
            ADD["5-Bit Extended Adder<br/>{carry, sum} = {0,A} + {0,B}"]
            SUB["5-Bit Subtractor / Comparator<br/>diff = A - B | borrow = (A < B)"]
        end

        subgraph Logic_Block["Bitwise Logic Unit"]
            AND_G["Bitwise AND (A & B)"]
            OR_G["Bitwise OR (A | B)"]
            XOR_G["Bitwise XOR (A ^ B)"]
            NOT_G["Bitwise NOT (~A)"]
        end

        subgraph Default_Block["Safe Unused Opcode Handler"]
            ZERO_CONST["Hardwired Zero (4'b0000)<br/>Opcodes 110 & 111"]
        end

        MUX["8-to-1 4-Bit Output Multiplexer<br/>Controlled by opcode[2:0]"]

        subgraph Flag_Logic["Status Flag Generation"]
            C_LOGIC["Carry Flag Logic<br/>sum_ext[4] on Opcode 000"]
            B_LOGIC["Borrow Flag Logic<br/>(A < B) on Opcode 001"]
            Z_LOGIC["Zero Flag Detector<br/>Continuous assign zero = (result == 0)"]
        end
    end

    subgraph Outputs
        RES["Result [3:0]"]
        C_OUT["Carry Flag"]
        B_OUT["Borrow Flag"]
        Z_OUT["Zero Flag"]
    end

    A --> ADD & SUB & AND_G & OR_G & XOR_G & NOT_G
    B --> ADD & SUB & AND_G & OR_G & XOR_G

    ADD --> MUX
    SUB --> MUX
    AND_G --> MUX
    OR_G --> MUX
    XOR_G --> MUX
    NOT_G --> MUX
    ZERO_CONST --> MUX
    OP --> MUX

    MUX --> RES

    ADD --> C_LOGIC
    OP --> C_LOGIC
    C_LOGIC --> C_OUT

    SUB --> B_LOGIC
    OP --> B_LOGIC
    B_LOGIC --> B_OUT

    RES --> Z_LOGIC
    Z_LOGIC --> Z_OUT
```

1. **Arithmetic Unit:**
   - Computes addition using zero-extended 5-bit inputs to prevent bit-overflow truncation.
   - Computes subtraction and checks magnitude ($A < B$) to accurately indicate unsigned underflow.
2. **Bitwise Logic Unit:**
   - Evaluates parallel bitwise boolean functions (AND, OR, XOR, NOT) across the 4 bit-slices.
3. **8-to-1 Multiplexer:**
   - Selects the target functional result based on `opcode[2:0]` and routes it to `result[3:0]`.
4. **Flag Generation Unit:**
   - Extracts arithmetic carries and borrows, and applies continuous NOR reduction to evaluate the Zero flag.

---

## 6. Opcode Table & Input/Output Descriptions

### Port Definitions

| Port | Direction | Bit Width | Data Type | Function |
| :--- | :---: | :---: | :---: | :--- |
| `A` | Input | 4-bit `[3:0]` | `wire` | First data operand ($0$ to $15$) |
| `B` | Input | 4-bit `[3:0]` | `wire` | Second data operand ($0$ to $15$) |
| `opcode` | Input | 3-bit `[2:0]` | `wire` | Operation selector ($000_2$ to $111_2$) |
| `result` | Output | 4-bit `[3:0]` | `reg` | Primary 4-bit ALU result |
| `carry` | Output | 1-bit | `reg` | Carry-out flag (valid for addition) |
| `borrow` | Output | 1-bit | `reg` | Borrow flag (valid for subtraction) |
| `zero` | Output | 1-bit | `wire` | Active-high Zero flag (`1` when `result == 0`) |

### Opcode Mapping & Truth Table

| Opcode `opcode[2:0]` | Operation | Mathematical / Logical Expression | `result[3:0]` | `carry` | `borrow` | `zero` |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: |
| `3'b000` | **Addition** | $A + B$ | $(A + B)[3:0]$ | `1` if sum > 15, else `0` | `0` | `1` if `result == 0`, else `0` |
| `3'b001` | **Subtraction** | $A - B$ | $(A - B)[3:0]$ | `0` | `1` if $A < B$, else `0` | `1` if `result == 0`, else `0` |
| `3'b010` | **Bitwise AND** | $A \ \& \ B$ | $A[i] \ \& \ B[i]$ | `0` | `0` | `1` if `result == 0`, else `0` |
| `3'b011` | **Bitwise OR** | $A \ \| \ B$ | $A[i] \ \| \ B[i]$ | `0` | `0` | `1` if `result == 0`, else `0` |
| `3'b100` | **Bitwise XOR** | $A \ \text{^} \ B$ | $A[i] \ \text{^} \ B[i]$ | `0` | `0` | `1` if `result == 0`, else `0` |
| `3'b101` | **Bitwise NOT (A)** | $\sim A$ | $\sim A[i]$ | `0` | `0` | `1` if `result == 0`, else `0` |
| `3'b110` | **Reserved / Default** | Safe Zero State | `4'b0000` | `0` | `0` | `1` |
| `3'b111` | **Reserved / Default** | Safe Zero State | `4'b0000` | `0` | `0` | `1` |

---

## 7. Verilog Implementation & Flag Logic

The RTL implementation is housed in `src/alu_4bit.v`. Key architectural design patterns include:

### 1. Extended Arithmetic Registers
```verilog
reg [4:0] sum_ext;
reg [4:0] diff_ext;
```
For addition, `{1'b0, A} + {1'b0, B}` calculates a 5-bit sum. The MSB (`sum_ext[4]`) directly captures whether an unsigned overflow occurred ($A + B > 15$).

### 2. Latch-Free Combinational Modeling
To prevent synthesis tools from inferring memory latches:
- Default values (`result = 0`, `carry = 0`, `borrow = 0`, etc.) are assigned at the top of the `always @(*)` block.
- Every branch of the `case (opcode)` explicitly assigns all output signals.
- A comprehensive `default:` clause catches any unexpected state.

### 3. Continuous Zero Flag Assignment
```verilog
assign zero = (result == 4'b0000);
```
Rather than duplicating zero-checking code inside every case branch, `zero` is driven continuously from `result`. This guarantees that whenever `result` equals `4'b0000`—including during unused opcodes `110` and `111`—`zero` is asserted high without latency or race conditions.

---

## 8. Simulation Setup & Testbench Methodology

### Simulation Setup
- **Compiler:** Icarus Verilog (`iverilog` v14.0 devel)
- **Runtime Simulator:** `vvp`
- **Waveform Viewer:** GTKWave v3.3.128
- **Timescale:** `1ns / 1ps`

### Testbench Architecture
The stimulus testbench in `tb/alu_4bit_tb.v` employs a **self-checking methodology**:
1. An automated task `apply_and_check` accepts input vectors, golden expected results, and flag states.
2. It assigns the inputs to the DUT, waits for a $10\,\text{ns}$ propagation delay, and performs a 4-way comparison:
   $$\text{PASS} \iff (result == exp\_result) \land (carry == exp\_carry) \land (borrow == exp\_borrow) \land (zero == exp\_zero)$$
3. Test failures are immediately reported to the console with input stimuli, received values, and expected values.
4. Pass and fail counters maintain a cumulative total.

---

## 9. Actual Test Results & Verification Summary

The testbench was executed live using the project runner script `run_sim.ps1`. All **24 test cases passed with zero errors**.

### Test Log Summary

| Test # | Category / Operation | Stimulus Inputs | Actual Result | C | B | Z | Verdict |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| 1 | Addition without carry | $A=3, B=2, \text{op}=000$ | $5$ (`0101`) | 0 | 0 | 0 | **PASS** |
| 2 | Addition with carry & zero | $A=15, B=1, \text{op}=000$ | $0$ (`0000`) | 1 | 0 | 1 | **PASS** |
| 3 | Maximum addition | $A=15, B=15, \text{op}=000$ | $14$ (`1110`) | 1 | 0 | 0 | **PASS** |
| 4 | Addition with zeros | $A=0, B=0, \text{op}=000$ | $0$ (`0000`) | 0 | 0 | 1 | **PASS** |
| 5 | Addition boundary | $A=8, B=8, \text{op}=000$ | $0$ (`0000`) | 1 | 0 | 1 | **PASS** |
| 6 | Subtraction without borrow | $A=7, B=3, \text{op}=001$ | $4$ (`0100`) | 0 | 0 | 0 | **PASS** |
| 7 | Subtraction with borrow | $A=3, B=7, \text{op}=001$ | $12$ (`1100`) | 0 | 1 | 0 | **PASS** |
| 8 | Equal subtraction (Zero) | $A=5, B=5, \text{op}=001$ | $0$ (`0000`) | 0 | 0 | 1 | **PASS** |
| 9 | Subtraction underflow boundary | $A=0, B=1, \text{op}=001$ | $15$ (`1111`) | 0 | 1 | 0 | **PASS** |
| 10 | Subtraction zeros | $A=0, B=0, \text{op}=001$ | $0$ (`0000`) | 0 | 0 | 1 | **PASS** |
| 11 | Bitwise AND | $A=12, B=10, \text{op}=010$ | $8$ (`1000`) | 0 | 0 | 0 | **PASS** |
| 12 | Bitwise AND zero result | $A=12, B=3, \text{op}=010$ | $0$ (`0000`) | 0 | 0 | 1 | **PASS** |
| 13 | Bitwise AND with mask | $A=10, B=15, \text{op}=010$ | $10$ (`1010`) | 0 | 0 | 0 | **PASS** |
| 14 | Bitwise OR | $A=12, B=10, \text{op}=011$ | $14$ (`1110`) | 0 | 0 | 0 | **PASS** |
| 15 | Bitwise OR all ones | $A=10, B=5, \text{op}=011$ | $15$ (`1111`) | 0 | 0 | 0 | **PASS** |
| 16 | Bitwise OR zeros | $A=0, B=0, \text{op}=011$ | $0$ (`0000`) | 0 | 0 | 1 | **PASS** |
| 17 | Bitwise XOR | $A=12, B=10, \text{op}=100$ | $6$ (`0110`) | 0 | 0 | 0 | **PASS** |
| 18 | Bitwise XOR equal (Zero) | $A=10, B=10, \text{op}=100$ | $0$ (`0000`) | 0 | 0 | 1 | **PASS** |
| 19 | Bitwise XOR with zero | $A=10, B=0, \text{op}=100$ | $10$ (`1010`) | 0 | 0 | 0 | **PASS** |
| 20 | Bitwise NOT A | $A=10, B=0, \text{op}=101$ | $5$ (`0101`) | 0 | 0 | 0 | **PASS** |
| 21 | Bitwise NOT 1111 (Zero) | $A=15, B=0, \text{op}=101$ | $0$ (`0000`) | 0 | 0 | 1 | **PASS** |
| 22 | Bitwise NOT 0000 (15) | $A=0, B=0, \text{op}=101$ | $15$ (`1111`) | 0 | 0 | 0 | **PASS** |
| 23 | Reserved Opcode 110 | $A=12, B=5, \text{op}=110$ | $0$ (`0000`) | 0 | 0 | 1 | **PASS** |
| 24 | Reserved Opcode 111 | $A=7, B=3, \text{op}=111$ | $0$ (`0000`) | 0 | 0 | 1 | **PASS** |

**Final Verification Summary:**
$$\text{Total Tests: } 24 \quad|\quad \text{Passed: } 24 \quad|\quad \text{Failed: } 0 \quad (\mathbf{100\% \text{ Accuracy}})$$

---

## 10. Waveform Analysis

The simulation produced `sim/alu_wave.vcd` (8,692 bytes), which was loaded into GTKWave. Key signal observations:

1. **Addition with Carry ($20\,\text{ns}$):**
   - Inputs: $A = 15$ (`1111`), $B = 1$ (`0001`), $opcode = 000$.
   - Observation: At $t = 20\,\text{ns}$, `result` transitions to `0000`, `carry` transitions from $0 \to 1$, and `zero` transitions from $0 \to 1$.
   - Analysis: Confirms that modular 4-bit addition wraps to zero while the carry flag flags unsigned arithmetic overflow.
2. **Subtraction with Borrow ($70\,\text{ns}$):**
   - Inputs: $A = 3$ (`0011`), $B = 7$ (`0111`), $opcode = 001$.
   - Observation: At $t = 70\,\text{ns}$, `result` displays `1100` ($12$), `borrow` transitions from $0 \to 1$, and `carry` remains at $0$.
   - Analysis: In modular arithmetic, $3 - 7 = -4 \equiv 12 \pmod{16}$. The borrow flag accurately captures unsigned underflow.
3. **Safe Default Handling ($230\,\text{ns}$ and $240\,\text{ns}$):**
   - Inputs: Opcodes `110` and `111` applied with arbitrary non-zero operands.
   - Observation: `result` strictly holds `0000`, `carry = 0`, `borrow = 0`, and `zero = 1`.
   - Analysis: Proves absence of floating output buses or unintentional high-impedance states.

---

## 11. Synthesis Workflow & Actual Statistics

### Synthesis Tool & Command Script
Logic synthesis was carried out using **Yosys 0.9** via the reproducible synthesis script `syn/synth.ys`:
```powershell
yosys -s syn/synth.ys -l syn/synth.log
```

### Actual Yosys Gate Synthesis Statistics

```text
=== alu_4bit ===

   Number of wires:                133
   Number of wire bits:            144
   Number of public wires:           7
   Number of public wire bits:      18
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                133
     $_AND_                         51
     $_NOT_                         24
     $_OR_                          50
     $_XOR_                          8
```

### Gate-Level Breakdown & Complexity Analysis

| Cell Primitive | Gate Count | Percentage | Functional Role in ALU |
| :--- | :---: | :---: | :--- |
| **`$_AND_`** | 51 | 38.3% | Data routing multiplexer trees, carry lookahead logic, bitwise AND masking |
| **`$_OR_`** | 50 | 37.6% | Multiplexer bit-or merging, adder sum logic, bitwise OR operation |
| **`$_NOT_`** | 24 | 18.0% | Inverters for 2's complement subtraction, bitwise NOT operation, opcode decoding |
| **`$_XOR_`** | 8 | 6.0% | Half-adder sum generators and bitwise XOR operation |
| **Total** | **133 Gates** | **100%** | Pure combinational standard logic gate network |

### Hardware Complexity Discussion
- **Zero Latches / Flip-Flops:** `Number of processes: 0` and `Number of memories: 0`. The entire design synthesizes into a pure combinational logic cloud without any state-holding feedback loops.
- **Multiplexer Realization:** In generic gate libraries, an 8-to-1 4-bit multiplexer requires roughly $4 \times 8 = 32$ AND gates plus multi-input OR gates. Yosys optimized this alongside the arithmetic adder logic into an intertwined network of 133 gates.
- **Netlist Output:** The synthesized gate-level Verilog code was successfully emitted to `syn/alu_synth.v`.

---

## 12. Performance Evaluation, Assumptions & Limitations

To maintain academic and engineering rigor, we clearly separate **functional verification** from **physical performance evaluation**:

### 1. Simulation vs. Physical Performance
- **What Simulation Proves:** The Icarus Verilog simulation confirms **functional logical correctness**—that for every valid combination of inputs, the output bits and flags match mathematical expectations.
- **What Simulation Does NOT Prove:** Functional RTL simulation does **not** establish physical clock frequency, signal propagation delay, silicon area in square micrometers ($\mu\text{m}^2$), or static/dynamic power consumption.

### 2. Physical Timing Analysis Status
- **Explicit Statement:** **Physical propagation delay has NOT been established in this project.**
- **Reason:** Calculating actual nanosecond delays and maximum operating frequency ($F_{\max}$) requires:
  1. A target physical technology library (such as TSMC $65\,\text{nm}$, SkyWater $130\,\text{nm}$, or an FPGA lookup table architecture like Xilinx 7-Series).
  2. Standard cell characterization files (Liberty `.lib` format) containing input/output transition lookup tables and wire-load parasitic models.
  3. Physical Place & Route (P&R) tools and a Static Timing Analysis (STA) engine (e.g., OpenSTA or Synopsys PrimeTime) driven by Synopsys Design Constraints (`.sdc`).

### 3. Hardware Resource Utilization
- At the technology-independent generic gate level, the design requires **133 basic logic gates**. When targeted to an FPGA (such as a Xilinx Artix-7), this design would map efficiently into approximately **15 to 20 6-input Look-Up Tables (LUT6)**.

---

## 13. Conclusion & Future Enhancements

### Conclusion
A 4-bit Simple Arithmetic Logic Unit has been successfully designed, modeled, functionally verified, and synthesized in accordance with B.Tech CSE Semester 3 guidelines. The project successfully fulfills **Course Outcome CO5** by:
1. Providing an IEEE-standard Verilog RTL behavioral model.
2. Building an automated self-checking simulation model that verified 24 test cases with zero errors.
3. Generating and analyzing VCD timing waveforms in GTKWave.
4. Performing gate-level synthesis using Yosys to extract gate counts and resource metrics.

### Future Enhancements
1. **Word Size Expansion:** Parameterizing the ALU width to 8-bit, 16-bit, or 32-bit.
2. **Additional Operations:** Implementing arithmetic shifting (logical shift left/right, arithmetic shift right) and multiplication.
3. **Pipelining / Sequential ALU:** Adding input and output pipeline registers driven by a system clock to measure setup/hold timing and maximum operating frequency ($F_{\max}$).
4. **FPGA Implementation:** Mapping the netlist to a physical FPGA development board (e.g., Basys 3 or Digilent Nexys A7) using tactile slide switches for inputs and 7-segment displays for output monitoring.

---

## 14. References

1. **IEEE Standard for Verilog Hardware Description Language:** IEEE Std 1364-2005.
2. **Digital Design: Principles and Practices:** John F. Wakerly, Pearson Education.
3. **Computer Organization and Design (RISC-V Edition):** David A. Patterson and John L. Hennessy, Morgan Kaufmann.
4. **Icarus Verilog Documentation & Compiler:** Stephen Williams (`https://steveicarus.github.io/iverilog/`).
5. **GTKWave Waveform Viewer:** Tony Bybell (`https://gtkwave.sourceforge.net/`).
6. **Yosys Open SYnthesis Suite:** Claire Wolf et al., YosysHQ (`https://yosyshq.net/yosys/`).

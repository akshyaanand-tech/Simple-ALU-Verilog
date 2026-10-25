@echo off
rem ==============================================================================
rem 4-Bit ALU Simulation Batch Script (Windows CMD)
rem Project: Simple ALU Using Verilog HDL (B.Tech CSE Sem 3)
rem ==============================================================================

echo ==========================================================
echo   COMPILING 4-BIT ALU (alu_4bit.v + alu_4bit_tb.v)
echo ==========================================================

if not exist sim mkdir sim

echo [1/3] Compiling Verilog RTL and Testbench with iverilog...
iverilog -o sim/alu_sim.vvp src/alu_4bit.v tb/alu_4bit_tb.v
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Verilog compilation failed!
    exit /b %ERRORLEVEL%
)

echo [2/3] Running simulation with vvp...
vvp sim/alu_sim.vvp
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Simulation execution failed!
    exit /b %ERRORLEVEL%
)

echo [3/3] Simulation finished successfully.
echo Waveform dumped to: sim\alu_wave.vcd
echo To open in GTKWave: gtkwave sim\alu_wave.vcd
echo ==========================================================

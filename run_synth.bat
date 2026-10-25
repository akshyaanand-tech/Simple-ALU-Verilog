@echo off
rem ==============================================================================
rem 4-Bit ALU Yosys Synthesis Batch Script (Windows CMD)
rem Project: Simple ALU Using Verilog HDL (B.Tech CSE Sem 3)
rem ==============================================================================

echo ==========================================================
echo   SYNTHESIZING 4-BIT ALU WITH YOSYS
echo ==========================================================

echo [1/2] Running Yosys logic synthesis...
yosys -s syn\synth.ys -l syn\synth.log
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Yosys synthesis failed! Check syn\synth.log.
    exit /b %ERRORLEVEL%
)

echo [2/2] Rendering gate schematic if dot is installed...
where dot >nul 2>nul
if %ERRORLEVEL% equ 0 (
    dot -Tsvg syn\alu_schematic.dot -o syn\alu_schematic.svg
    dot -Tpng syn\alu_schematic.dot -o syn\alu_schematic.png
    echo Schematics rendered: syn\alu_schematic.svg and syn\alu_schematic.png
) else (
    echo DOT file saved to: syn\alu_schematic.dot
)

echo ==========================================================
echo Synthesis finished successfully! Netlist: syn\alu_synth.v
echo ==========================================================

# ==============================================================================
# 4-Bit ALU Simulation Script (PowerShell)
# Project: Simple ALU Using Verilog HDL (B.Tech CSE Sem 3)
# ==============================================================================

# Ensure User/Machine Scoop shims are on Path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + $env:Path

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  COMPILING 4-BIT ALU (alu_4bit.v + alu_4bit_tb.v)       " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

if (-not (Test-Path "sim")) {
    New-Item -ItemType Directory -Path "sim" | Out-Null
}

# Step 1: Compile Verilog sources with Icarus Verilog
Write-Host "[1/3] Compiling Verilog RTL and Testbench..." -ForegroundColor Yellow
iverilog -o sim/alu_sim.vvp src/alu_4bit.v tb/alu_4bit_tb.v
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Verilog compilation failed!" -ForegroundColor Red
    exit 1
}
Write-Host "Compilation successful -> sim/alu_sim.vvp generated." -ForegroundColor Green

# Step 2: Execute Simulation Runtime (vvp)
Write-Host "`n[2/3] Executing simulation runtime engine (vvp)..." -ForegroundColor Yellow
vvp sim/alu_sim.vvp
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Simulation execution failed!" -ForegroundColor Red
    exit 1
}

# Step 3: Check Waveform
Write-Host "`n[3/3] Checking simulation waveform..." -ForegroundColor Yellow
if (Test-Path "sim/alu_wave.vcd") {
    $vcdSize = (Get-Item "sim/alu_wave.vcd").Length
    Write-Host "Waveform generated successfully: sim/alu_wave.vcd ($vcdSize bytes)" -ForegroundColor Green
    Write-Host "`nTo view waveform in GTKWave, execute:" -ForegroundColor Cyan
    Write-Host "  gtkwave sim/alu_wave.vcd" -ForegroundColor White
} else {
    Write-Host "[WARNING] sim/alu_wave.vcd not found!" -ForegroundColor Red
}

Write-Host "==========================================================" -ForegroundColor Cyan

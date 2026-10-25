# ==============================================================================
# 4-Bit ALU Yosys Synthesis Script (PowerShell)
# Project: Simple ALU Using Verilog HDL (B.Tech CSE Sem 3)
# ==============================================================================

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + $env:Path

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  SYNTHESIZING 4-BIT ALU WITH YOSYS                       " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Step 1: Run Yosys with syn/synth.ys script
Write-Host "[1/2] Running Yosys logic synthesis..." -ForegroundColor Yellow
yosys -s syn/synth.ys -l syn/synth.log
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Yosys synthesis failed! Check syn/synth.log." -ForegroundColor Red
    exit 1
}
Write-Host "Synthesis successful -> syn/alu_synth.v generated." -ForegroundColor Green

# Step 2: Render Graphviz Schematic (if dot is available)
Write-Host "`n[2/2] Rendering gate-level schematic..." -ForegroundColor Yellow
if (Get-Command dot -ErrorAction SilentlyContinue) {
    dot -Tsvg syn/alu_schematic.dot -o syn/alu_schematic.svg
    dot -Tpng syn/alu_schematic.dot -o syn/alu_schematic.png
    Write-Host "Schematics rendered: syn/alu_schematic.svg and syn/alu_schematic.png" -ForegroundColor Green
} else {
    Write-Host "[NOTE] 'dot' tool not found. DOT graph available at syn/alu_schematic.dot" -ForegroundColor DarkGray
}

Write-Host "`nSynthesis finished! Statistics saved in syn/synth_stat.txt." -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

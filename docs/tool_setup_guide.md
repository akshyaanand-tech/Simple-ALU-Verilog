# EDA Tool Setup Guide for Windows 11

This guide explains how to install and verify the Electronic Design Automation (EDA) software tools required for **Phase 3 (Simulation)** and **Phase 4 (Synthesis)**.

---

## 1. Required Toolchain

| Tool | Component | Purpose | Phase |
| :--- | :--- | :--- | :---: |
| **Icarus Verilog** | `iverilog` & `vvp` | Verilog HDL compiler and simulation runtime engine | Phase 3 |
| **GTKWave** | `gtkwave` | Graphical viewer for Value Change Dump (`.vcd`) waveform files | Phase 3 |
| **Yosys** | `yosys` | Open-source RTL synthesis suite & gate-level netlist generator | Phase 4 |

---

## 2. Recommended Installation Methods (Windows 11)

### Method A: Using Chocolatey (`choco`) — Recommended & Verified Available
Since `choco.exe` is already installed on your system, you can open PowerShell **as Administrator** and install Icarus Verilog (which bundles GTKWave):

```powershell
# Install Icarus Verilog and GTKWave
choco install iverilog -y
```

### Method B: Using Windows Package Manager (`winget`)
You can install using `winget` in PowerShell:

```powershell
# Search for Icarus Verilog
winget search "Icarus Verilog"

# Install Icarus Verilog
winget install -e --id StephenWilliams.IcarusVerilog
```

### Method C: Direct Windows Installer (Bleeping Computer / Bleyer)
If you prefer a manual graphical installer:
1. Visit the official Windows build page: [http://bleyer.org/icarus/](http://bleyer.org/icarus/)
2. Download the latest installer (e.g. `iverilog-v12-20220611-x64_setup.exe`).
3. During installation, make sure to check:
   - ✅ **Install GTKWave**
   - ✅ **Add to system PATH** (so `iverilog` and `vvp` can be run from any terminal).

---

## 3. Installing Yosys (for Phase 4)

For open-source synthesis on Windows:
1. **Via OSS CAD Suite (Recommended):**
   - Download the precompiled Windows package from the official YosysHQ repository:  
     `https://github.com/YosysHQ/oss-cad-suite-build/releases`
   - Extract to `C:\oss-cad-suite` and add `C:\oss-cad-suite\bin` to your Windows Environment PATH.
2. **Via Scoop (Available on your system):**
   ```powershell
   scoop bucket add extras
   scoop install yosys
   ```

---

## 4. Verification Commands

After installing, open a new PowerShell window and execute:

```powershell
# Verify Icarus Verilog compiler
iverilog -v

# Verify simulation runtime engine
vvp -v

# Verify GTKWave viewer
gtkwave --version

# Verify Yosys synthesis engine
yosys -v
```

Once these commands print their respective version banners, your environment is ready for simulation and synthesis!

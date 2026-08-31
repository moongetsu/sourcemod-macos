<h1 align="center">
  <img src="https://camo.githubusercontent.com/ef4460ecda0af3558932f64df3b4c98b2db5249bee6c38a3391fb979e2dfe99f/68747470733a2f2f696d616765732e67616d6562616e616e612e636f6d2f696d672f69636f2f7370726179732f6e617275746f2e676966" width="64" alt="Icon"/>
  <br />
  SourceMod macOS Compiler
</h1>
<p align="center">
  <b>Multi-Version Native Universal (Apple Silicon ARM64 & Intel x86_64) SourcePawn Compiler Toolkit for macOS.</b><br>
  <i>Build, compile, and switch between SourceMod 1.10, 1.11, 1.12, and 1.13 on Mac effortlessly.</i>
</p>

<p align="center">
  <a href="#-quick-install">⚡ Quick Install</a> •
  <a href="#-supported-versions">🔢 Versions</a> •
  <a href="#-version-switcher">🔄 Switcher</a> •
  <a href="#-workspace-guide">🛠 Usage</a> •
  <a href="#-project-structure">📂 Structure</a>
</p>

<hr>

## 🎬 About

**SourceMod macOS Compiler** provides pre-built, native Mach-O universal binaries of the **SourcePawn Compiler (`spcomp`)** and standard headers for **SourceMod 1.10, 1.11, 1.12, and 1.13**.

It fixes upstream Apple Clang build errors, provides instant version switching with `./sm-switch.sh`, and integrates with VS Code.

> [!NOTE]
> **Compatibility:**
> - **Apple Silicon** — M1, M2, M3, M4 (Native ARM64, no Rosetta required).
> - **Intel Macs** — macOS 10.15 (Catalina) and newer (x86_64).
> - **Target Servers** — Output `.smx` plugins run on all Linux and Windows game servers.

---

## 🔢 Supported Versions

| Version | Status | Description |
| :--- | :--- | :--- |
| **SourceMod 1.12** | **Standard (Default)** | Current recommended version for CS:GO, TF2, etc. |
| **SourceMod 1.13** | **Next-Gen / Dev** | Latest SourceMod master branch builds. |
| **SourceMod 1.11** | **LTS / Stable** | Long-term support branch. |
| **SourceMod 1.10** | **Legacy** | For older servers and legacy environments. |

---

## ⚡ Quick Install

### Option 1: Via Homebrew (Recommended)
```bash
brew tap moongetsu/tap
brew install spcomp
```

### Option 2: Clone the Workspace
```bash
# Clone the workspace
git clone https://github.com/moongetsu/sourcemod-macos.git
cd sourcemod-macos

# Quick setup
./setup.sh
```

---

## 🔄 Version Switcher

Switch the active compiler and default includes on-the-fly:

```bash
./sm-switch.sh 1.10    # Switch to SourceMod 1.10
./sm-switch.sh 1.11    # Switch to SourceMod 1.11
./sm-switch.sh 1.12    # Switch to SourceMod 1.12
./sm-switch.sh 1.13    # Switch to SourceMod 1.13
```

## 📦 Package & Include Manager (`sm-pkg`)

Install top community libraries and stocks directly into `include/` with one command:

```bash
# Install popular libraries
./sm-pkg.sh install smlib            # 300+ helper stocks and utilities
./sm-pkg.sh install multicolors      # Chat coloring engine with drivers
./sm-pkg.sh install ripext           # REST in Pawn (HTTP & JSON)
./sm-pkg.sh install autoexecconfig   # Automatic config generator
./sm-pkg.sh install steamworks       # SteamWorks extension include
./sm-pkg.sh install sourcescramble   # Memory patcher & detour toolkit

# Search and manage packages
./sm-pkg.sh search [query]
./sm-pkg.sh list
./sm-pkg.sh remove <package>
```

### Directory Layout

- Put your `.sp` plugins in [`plugins/`](plugins/)
- Put custom `.inc` files in [`include/`](include/)
- Compiled `.smx` binaries are output to [`compiled/`](compiled/)

### Compiling Plugins

```bash
# Compile with active version
./compile.sh

# Compile a single file
./compile.sh plugins/sample.sp

# Override compiler version for a single build
./compile.sh -v 1.10 plugins/sample.sp
```

---

## 📂 Project Structure

```text
├── .github/workflows/
│   └── build-release.yml     # Multi-version CI Matrix Pipeline (1.10 - 1.13)
├── bin/                      # Universal Mach-O macOS binaries
│   ├── spcomp                # Active compiler symlink / binary
│   ├── spcomp-1.10           # SourceMod 1.10 compiler
│   ├── spcomp-1.11           # SourceMod 1.11 compiler
│   ├── spcomp-1.12           # SourceMod 1.12 compiler
│   └── spcomp-1.13           # SourceMod 1.13 compiler
├── include/                  # Standard Includes organized by version
│   ├── 1.10/
│   ├── 1.11/
│   ├── 1.12/
│   └── 1.13/
├── plugins/                  # SourcePawn plugin source files (.sp)
├── scripts/
│   └── build-spcomp-macos.sh # Multi-version builder script
├── sm-switch.sh              # Instant version switcher CLI
├── setup.sh                  # Setup script
└── compile.sh                # Fast build script with -v flag
```

---

<p align="center">
  <img src="https://badgen.net/badge/Platform/macOS%20Universal/black?icon=apple" alt="macOS" />
  <img src="https://badgen.net/badge/Versions/1.10%20%7C%201.11%20%7C%201.12%20%7C%201.13/green" alt="Versions" />
  <img src="https://badgen.net/badge/Language/SourcePawn%20%2F%20C%2B%2B/blue" alt="Language" />
  <img src="https://badgen.net/badge/License/GPL--3.0/yellow" alt="License" />
</p>

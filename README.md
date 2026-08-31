<h1 align="center">
  <img src="https://camo.githubusercontent.com/ef4460ecda0af3558932f64df3b4c98b2db5249bee6c38a3391fb979e2dfe99f/68747470733a2f2f696d616765732e67616d6562616e616e612e636f6d2f696d672f69636f2f7370726179732f6e617275746f2e676966" width="64" alt="Icon"/>
  <br />
  SourceMod macOS Compiler
</h1>
<p align="center">
  <b>Native Universal (Apple Silicon ARM64 & Intel x86_64) SourcePawn compiler toolkit for macOS.</b><br>
  <i>Build, compile, and develop SourceMod plugins on Mac with zero setup friction.</i>
</p>

<p align="center">
  <a href="#-quick-install">⚡ Quick Install</a> •
  <a href="#-features">✨ Features</a> •
  <a href="#-workspace-guide">🛠 Workspace Guide</a> •
  <a href="#-building-from-source">🏗 Building from Source</a> •
  <a href="#-project-structure">📂 Structure</a>
</p>

<hr>

## 🎬 About

**SourceMod macOS Compiler** provides a pre-built, native Mach-O universal binary of the **SourcePawn Compiler (`spcomp 1.12`)** and an automated build system tailored for macOS.

It fixes existing upstream build conflicts with modern Apple Clang (such as `zutil.h` macro redefinitions and C++17 deprecations), bundles all standard SourceMod `.inc` files, and includes VS Code task automation.

> [!NOTE]
> **Compatibility:**
> - **Apple Silicon** — M1, M2, M3, M4 (Native ARM64, no Rosetta required).
> - **Intel Macs** — macOS 10.15 (Catalina) and newer (x86_64).
> - **Target Servers** — Output `.smx` plugins are platform-independent bytecode and run on all Linux and Windows game servers (CS:S, CS:GO, TF2, L4D2, HL2:DM, DoD:S, etc.).

---

## 🚀 Features

- **Native Universal Binary:** Single fat Mach-O executable containing native 64-bit slices for both Apple Silicon and Intel x86_64.
- **Pre-Bundled Standard Includes:** Includes `sourcemod.inc`, `sdktools.inc`, `sdkhooks.inc`, `cstrike.inc`, `tf2.inc`, `dbi.inc`, etc.
- **IDE Build Task:** Pre-configured `.vscode/tasks.json` supporting <kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>B</kbd> with inline error & warning matching.
- **Automated CI/CD:** GitHub Actions release workflow that automatically compiles and packages `.tar.gz` and `.zip` distribution bundles.
- **Clean One-Line Installer:** Setup `spcomp` system-wide with a single terminal command.

---

## 📦 Installation

### Using the Installer (Recommended)

Run the one-line setup in your macOS terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/moongetsu/sourcemod-macos/main/install.sh | bash
```

This installs `spcomp` and headers to `~/.sourcemod-mac` and adds the binary path to your `~/.zshrc`.

---

### Manual Installation

<details>
<summary><b>Download Archive</b></summary>

1. Download the latest `sourcemod-compiler-macos-universal.tar.gz` from the [Releases](../../releases) page.
2. Extract the archive:
   ```bash
   tar -xzf sourcemod-compiler-macos-universal.tar.gz
   ```
3. Run the compiler:
   ```bash
   ./bin/spcomp your_plugin.sp -iinclude -o your_plugin.smx
   ```

</details>

---

## 🛠 Workspace Guide

### Directory Layout

- Put your `.sp` plugins inside [`plugins/`](plugins/)
- Put custom 3rd-party `.inc` headers inside [`include/`](include/)
- Compiled `.smx` files are generated in [`compiled/`](compiled/)

### Compiling Plugins

#### Using the Terminal:

```bash
# Compile all plugins in plugins/
./compile.sh

# Compile a single plugin
./compile.sh plugins/sample.sp
```

#### Using VS Code / Antigravity:

1. Open any `.sp` file (e.g. [`plugins/sample.sp`](plugins/sample.sp)).
2. Press <kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>B</kbd> (or select **Terminal > Run Build Task**).
3. Any syntax errors or compilation warnings will appear directly in the **Problems** tab.

---

## 🏗 Building from Source

To build the native compiler binary locally:

1. Ensure Xcode Command Line Tools are installed:
   ```bash
   xcode-select --install
   ```
2. Run the automated build script:
   ```bash
   chmod +x ./scripts/build-spcomp-macos.sh
   ./scripts/build-spcomp-macos.sh
   ```

The script automatically fetches AMBuild, pulls the latest SourceMod branch, applies modern macOS Clang patches, and produces the fat Mach-O binary in `bin/spcomp`.

---

## 📂 Project Structure

```text
├── .github/
│   └── workflows/
│       └── build-release.yml     # Automated CI/CD Release Pipeline
├── .vscode/
│   └── tasks.json                # VS Code Task (Cmd + Shift + B)
├── bin/
│   └── spcomp                    # Universal Mach-O macOS Binary
├── compiled/                     # Output directory for .smx plugins
├── include/                      # Standard SourceMod 1.12 Includes
├── plugins/                      # Plugin source files (.sp)
│   └── sample.sp                 # Sample test plugin
├── scripts/
│   └── build-spcomp-macos.sh     # Standalone Universal compiler builder
├── compile.sh                    # Local batch / single compiler script
├── install.sh                    # One-line global installer
└── README.md
```

---

<p align="center">
  <img src="https://badgen.net/badge/Platform/macOS%20Universal/black?icon=apple" alt="macOS" />
  <img src="https://badgen.net/badge/Architecture/ARM64%20%2B%20x86__64/green" alt="Architecture" />
  <img src="https://badgen.net/badge/Language/SourcePawn%20%2F%20C%2B%2B/blue" alt="Language" />
  <img src="https://badgen.net/badge/SourceMod/1.12/orange" alt="SourceMod" />
  <img src="https://badgen.net/badge/License/GPL--3.0/yellow" alt="License" />
</p>

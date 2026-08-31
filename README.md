# sourcemod-macos-compiler 🍏

Automated native **SourceMod / SourcePawn (`spcomp`)** compiler builds and developer starter kit for **macOS (Apple Silicon M1/M2/M3/M4 & Intel x86_64)**.

---

## ⚡ Quick Install for macOS Users

You don't need to manually configure build tools or compile anything from source. 

### Option 1: One-Line Installer
Run this command in your terminal:
```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/sourcemod-macos/main/install.sh | bash
```

### Option 2: Download Ready-to-use Package
1. Download `sourcemod-compiler-macos-universal.tar.gz` from the [Releases](https://github.com/YOUR_USERNAME/sourcemod-macos/releases) tab.
2. Extract the archive:
   ```bash
   tar -xzf sourcemod-compiler-macos-universal.tar.gz
   ```
3. Run compiler:
   ```bash
   ./bin/spcomp your_plugin.sp -iinclude -o your_plugin.smx
   ```

---

## 🚀 Workspace Features

- 🍏 **Universal Binary (`arm64` + `x86_64`)**: Runs natively with zero emulation overhead on all Macs.
- 📦 **Standard SourceMod 1.12 Includes Pre-bundled**: Includes `sourcemod.inc`, `sdktools.inc`, `sdkhooks.inc`, etc.
- ⚡ **VS Code Integration**: Press `Cmd + Shift + B` to compile the active `.sp` file instantly with inline error diagnostics.
- 🤖 **Automated CI/CD**: Automatic GitHub Actions workflow that builds the latest `spcomp` release.

---

## 🛠 Building the Compiler Yourself (Local)

If you want to build the compiler locally on your Mac:

```bash
chmod +x ./scripts/build-spcomp-macos.sh
./scripts/build-spcomp-macos.sh
```

---

## 📝 How to Compile Plugins

1. Place `.sp` files in `plugins/`.
2. Place custom `.inc` files in `include/`.
3. Run:
   ```bash
   ./compile.sh
   ```
   Compiled `.smx` files will appear in `compiled/`.

---

## License
SourceMod / SourcePawn is licensed under the [GNU General Public License (GPL)](https://www.gnu.org/licenses/gpl.html) by AlliedModders LLC.

#!/usr/bin/env bash
# ==============================================================================
# build-spcomp-macos.sh
# Automated SourcePawn / SourceMod Compiler (spcomp) Builder for macOS
# Supports: Apple Silicon (M1/M2/M3/M4, ARM64) & Intel (x86_64) -> Universal Binary
# ==============================================================================

set -e

SM_BRANCH="${1:-1.12-dev}"
WORK_DIR="${2:-./build-tmp}"
OUTPUT_DIR="${3:-./dist}"

echo "=================================================="
echo " SourcePawn / SourceMod macOS Compiler Builder"
echo " Branch: $SM_BRANCH"
echo " Output: $OUTPUT_DIR"
echo "=================================================="

# 1. Prerequisites check
if ! command -v git &>/dev/null; then
    echo "❌ Error: git is required."
    exit 1
fi

if ! command -v python3 &>/dev/null; then
    echo "❌ Error: python3 is required."
    exit 1
fi

if ! command -v clang++ &>/dev/null; then
    echo "❌ Error: Xcode Command Line Tools (clang++) required. Run: xcode-select --install"
    exit 1
fi

# 2. Setup folders
mkdir -p "$WORK_DIR" "$OUTPUT_DIR"
WORK_DIR="$(cd "$WORK_DIR" && pwd)"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

# 3. Install / update AMBuild
echo "📦 [1/5] Installing AMBuild..."
AMBUILD_DIR="$WORK_DIR/ambuild"
if [ ! -d "$AMBUILD_DIR" ]; then
    git clone https://github.com/alliedmodders/ambuild.git "$AMBUILD_DIR"
else
    git -C "$AMBUILD_DIR" pull
fi

cd "$AMBUILD_DIR"
python3 setup.py install --user
export PATH="$HOME/Library/Python/$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')/bin:$HOME/.local/bin:$PATH"

if ! command -v ambuild &>/dev/null; then
    echo "❌ Error: ambuild command not found in PATH."
    exit 1
fi

# 4. Clone SourceMod sourcepawn
echo "📥 [2/5] Cloning SourceMod ($SM_BRANCH)..."
SM_DIR="$WORK_DIR/sourcemod"
if [ ! -d "$SM_DIR" ]; then
    git clone --recursive --depth 1 -b "$SM_BRANCH" https://github.com/alliedmodders/sourcemod.git "$SM_DIR"
fi

SP_DIR="$SM_DIR/sourcepawn"

# 5. Apply macOS Compatibility Patches
echo "🩹 [3/5] Patching for modern macOS clang..."

# Patch zutil.h legacy macro conflicts
ZUTIL_H="$SP_DIR/third_party/zlib/zutil.h"
if [ -f "$ZUTIL_H" ]; then
    # Fix OS_CODE redefined
    perl -pi -e 's/#ifdef __APPLE__/#if defined(__APPLE__) && !defined(OS_CODE)/g' "$ZUTIL_H"
    # Fix legacy fdopen redefine
    perl -pi -e 's/#if defined\(MACOS\) \|\| defined\(TARGET_OS_MAC\)/#if defined(MACOS)/g' "$ZUTIL_H"
fi

# Patch AMBuildScript warnings-as-errors & deprecation warnings
AMBUILDSCRIPT="$SP_DIR/AMBuildScript"
if [ -f "$AMBUILDSCRIPT" ]; then
    perl -pi -e "s/'-Werror',/'-Wno-error',\n            '-Wno-deprecated-declarations',/g" "$AMBUILDSCRIPT"
    perl -pi -e "s/\['-std=c\+\+17'\]/\['-std=c\+\+17', '-Wno-deprecated-declarations'\]/g" "$AMBUILDSCRIPT"
fi

# 6. Configure & Build Universal Binary
echo "⚙️  [4/5] Configuring and building Universal (x86_64 + arm64) spcomp..."
BUILD_DIR="$SP_DIR/build-macos"
cd "$SP_DIR"
python3 configure.py --out build-macos --targets=x86_64,arm64
cd "$BUILD_DIR"
ambuild

# 7. Collect binaries and includes
echo "🚚 [5/5] Packaging compiler and include files to $OUTPUT_DIR..."

SPCOMP_UNIVERSAL="$BUILD_DIR/spcomp/mac-universal/spcomp"
if [ ! -f "$SPCOMP_UNIVERSAL" ]; then
    echo "❌ Error: Compiled spcomp not found at $SPCOMP_UNIVERSAL"
    exit 1
fi

mkdir -p "$OUTPUT_DIR/bin" "$OUTPUT_DIR/include"
cp "$SPCOMP_UNIVERSAL" "$OUTPUT_DIR/bin/spcomp"
chmod +x "$OUTPUT_DIR/bin/spcomp"

# Copy standard includes
if [ -d "$SM_DIR/plugins/include" ]; then
    cp -r "$SM_DIR/plugins/include/"* "$OUTPUT_DIR/include/" 2>/dev/null || true
fi

# Also grab latest release includes if available
echo "Fetching official standard include package..."
curl -sL "https://sm.alliedmods.net/smdrop/1.12/sourcemod-1.12.0-git7251-linux.tar.gz" -o "$WORK_DIR/sm-includes.tar.gz" || true
if [ -f "$WORK_DIR/sm-includes.tar.gz" ]; then
    tar -xzf "$WORK_DIR/sm-includes.tar.gz" -C "$WORK_DIR" addons/sourcemod/scripting/include 2>/dev/null || true
    if [ -d "$WORK_DIR/addons/sourcemod/scripting/include" ]; then
        cp -r "$WORK_DIR/addons/sourcemod/scripting/include/"* "$OUTPUT_DIR/include/"
    fi
fi

# Verify output
echo ""
echo "=================================================="
echo "✅ BUILD SUCCESSFUL!"
echo "=================================================="
file "$OUTPUT_DIR/bin/spcomp"
echo "Output files ready in: $OUTPUT_DIR"
echo "- $OUTPUT_DIR/bin/spcomp"
echo "- $OUTPUT_DIR/include/"

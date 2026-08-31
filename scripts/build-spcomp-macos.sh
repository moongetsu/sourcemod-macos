#!/usr/bin/env bash
# ==============================================================================
# build-spcomp-macos.sh
# Universal (ARM64 + x86_64) SourceMod / SourcePawn (spcomp) Builder for macOS
# Supports versions: 1.10, 1.11, 1.12, 1.13
# ==============================================================================

set -e

VERSION_INPUT="${1:-1.12}"
WORK_DIR="${2:-./build-tmp}"
OUTPUT_DIR="${3:-./dist}"

case "$VERSION_INPUT" in
    1.10|1.10-dev|1.10.0)
        SM_VER="1.10"
        SM_BRANCH="1.10-dev"
        SM_DROP="1.10"
        ;;
    1.11|1.11-dev|1.11.0)
        SM_VER="1.11"
        SM_BRANCH="1.11-dev"
        SM_DROP="1.11"
        ;;
    1.13|1.13-dev|1.13.0|master)
        SM_VER="1.13"
        SM_BRANCH="master"
        SM_DROP="1.13"
        ;;
    1.12|1.12-dev|1.12.0|*)
        SM_VER="1.12"
        SM_BRANCH="1.12-dev"
        SM_DROP="1.12"
        ;;
esac

echo "=================================================="
echo " SourcePawn / SourceMod macOS Compiler Builder"
echo " Target Version: $SM_VER (Branch: $SM_BRANCH)"
echo " Output Dir:     $OUTPUT_DIR"
echo "=================================================="

if ! command -v git &>/dev/null; then echo "❌ Error: git required"; exit 1; fi
if ! command -v python3 &>/dev/null; then echo "❌ Error: python3 required"; exit 1; fi
if ! command -v clang++ &>/dev/null; then echo "❌ Error: Xcode Command Line Tools required. Run: xcode-select --install"; exit 1; fi

mkdir -p "$WORK_DIR" "$OUTPUT_DIR"
WORK_DIR="$(cd "$WORK_DIR" && pwd)"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

# 1. Install AMBuild
echo "📦 [1/5] Setting up AMBuild..."
AMBUILD_DIR="$WORK_DIR/ambuild"
if [ ! -d "$AMBUILD_DIR" ]; then
    git clone https://github.com/alliedmodders/ambuild.git "$AMBUILD_DIR"
fi
cd "$AMBUILD_DIR"
python3 setup.py install --user
export PATH="$HOME/Library/Python/$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')/bin:$HOME/.local/bin:$PATH"

# 2. Clone SourceMod sourcepawn
echo "📥 [2/5] Cloning SourceMod ($SM_BRANCH)..."
SM_DIR="$WORK_DIR/sourcemod-$SM_VER"
if [ ! -d "$SM_DIR" ]; then
    git clone --recursive --depth 1 -b "$SM_BRANCH" https://github.com/alliedmodders/sourcemod.git "$SM_DIR"
fi

SP_DIR="$SM_DIR/sourcepawn"

# 3. Apply Clang / macOS patches
echo "🩹 [3/5] Applying macOS Clang compatibility patches..."

# Patch zutil.h legacy macro conflicts if zlib is present
ZUTIL_H="$SP_DIR/third_party/zlib/zutil.h"
if [ -f "$ZUTIL_H" ]; then
    perl -pi -e 's/#ifdef __APPLE__/#if defined(__APPLE__) && !defined(OS_CODE)/g' "$ZUTIL_H"
    perl -pi -e 's/#if defined\(MACOS\) \|\| defined\(TARGET_OS_MAC\)/#if defined(MACOS)/g' "$ZUTIL_H"
fi

# Patch AMTL am-string.h nullptr issue in older branches
AM_STRING_H="$SP_DIR/third_party/amtl/amtl/am-string.h"
if [ -f "$AM_STRING_H" ]; then
    perl -pi -e 's/return nullptr;/return (const CharType\*)0;/g' "$AM_STRING_H"
fi

# Patch AMBuildScript warnings-as-errors & deprecations
AMBUILDSCRIPT="$SP_DIR/AMBuildScript"
if [ -f "$AMBUILDSCRIPT" ]; then
    perl -pi -e "s/'-Werror',/'-Wno-error',\n            '-Wno-deprecated-declarations',\n            '-Wno-nonnull',/g" "$AMBUILDSCRIPT"
    perl -pi -e "s/\['-std=c\+\+17'\]/\['-std=c\+\+17', '-Wno-deprecated-declarations', '-Wno-nonnull'\]/g" "$AMBUILDSCRIPT"
    perl -pi -e "s/\['-std=c\+\+20'\]/\['-std=c\+\+20', '-Wno-deprecated-declarations', '-Wno-nonnull'\]/g" "$AMBUILDSCRIPT"
fi

# 4. Build Universal Binary
echo "⚙️  [4/5] Building Universal spcomp-$SM_VER..."
BUILD_DIR="$SP_DIR/build-macos"
mkdir -p "$BUILD_DIR"
cd "$SP_DIR"
python3 configure.py --out build-macos --targets=x86_64,arm64
cd "$BUILD_DIR"
ambuild

# 5. Collect outputs
echo "🚚 [5/5] Packaging binary and includes for $SM_VER..."
SPCOMP_UNIVERSAL="$BUILD_DIR/spcomp/mac-universal/spcomp"
if [ ! -f "$SPCOMP_UNIVERSAL" ]; then
    SPCOMP_UNIVERSAL="$BUILD_DIR/spcomp/spcomp"
fi

if [ ! -f "$SPCOMP_UNIVERSAL" ]; then
    echo "❌ Error: Compiled spcomp not found at $SPCOMP_UNIVERSAL"
    exit 1
fi

mkdir -p "$OUTPUT_DIR/bin" "$OUTPUT_DIR/include/$SM_VER"
cp "$SPCOMP_UNIVERSAL" "$OUTPUT_DIR/bin/spcomp-$SM_VER"
chmod +x "$OUTPUT_DIR/bin/spcomp-$SM_VER"

# Download matching standard includes
echo "Fetching official standard includes for SourceMod $SM_VER..."
LATEST_TARBALL=$(curl -s "https://sm.alliedmods.net/smdrop/$SM_DROP/" | grep -o "sourcemod-$SM_DROP\.[0-9]*-git[0-9]*-linux\.tar\.gz" | tail -n 1)

if [ -n "$LATEST_TARBALL" ]; then
    curl -sL "https://sm.alliedmods.net/smdrop/$SM_DROP/$LATEST_TARBALL" -o "$WORK_DIR/sm-$SM_VER.tar.gz"
    tar -xzf "$WORK_DIR/sm-$SM_VER.tar.gz" -C "$WORK_DIR" addons/sourcemod/scripting/include 2>/dev/null || true
    if [ -d "$WORK_DIR/addons/sourcemod/scripting/include" ]; then
        cp -r "$WORK_DIR/addons/sourcemod/scripting/include/"* "$OUTPUT_DIR/include/$SM_VER/"
        rm -rf "$WORK_DIR/addons" "$WORK_DIR/sm-$SM_VER.tar.gz"
    fi
fi

if [ "$SM_VER" = "1.12" ]; then
    cp "$OUTPUT_DIR/bin/spcomp-1.12" "$OUTPUT_DIR/bin/spcomp"
    mkdir -p "$OUTPUT_DIR/include"
    cp -r "$OUTPUT_DIR/include/1.12/"* "$OUTPUT_DIR/include/" 2>/dev/null || true
fi

echo ""
echo "=================================================="
echo "✅ Build Complete for SourceMod $SM_VER!"
echo "   Binary:  $OUTPUT_DIR/bin/spcomp-$SM_VER"
echo "   Headers: $OUTPUT_DIR/include/$SM_VER/"
echo "=================================================="

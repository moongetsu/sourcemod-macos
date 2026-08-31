#!/usr/bin/env bash
# ==============================================================================
# setup.sh - Instant SourceMod Dev Environment Setup for macOS
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
SPCOMP="$BIN_DIR/spcomp"
INCLUDE_DIR="$SCRIPT_DIR/include"
COMPILED_DIR="$SCRIPT_DIR/compiled"
PLUGINS_DIR="$SCRIPT_DIR/plugins"

echo ""
echo "🍏 ========================================================="
echo "    SourceMod macOS Quick Setup"
echo " ========================================================="
echo ""

# 1. Create workspace directories
mkdir -p "$BIN_DIR" "$INCLUDE_DIR" "$COMPILED_DIR" "$PLUGINS_DIR"

# 2. Check if native spcomp binary exists and is functional
NEED_BUILD=0
if [ -f "$SPCOMP" ]; then
    if "$SPCOMP" >/dev/null 2>&1 || [ $? -eq 1 ]; then
        echo "✅ Compiler (spcomp) is ready."
    else
        NEED_BUILD=1
    fi
else
    NEED_BUILD=1
fi

# 3. If missing or broken, build from source
if [ $NEED_BUILD -eq 1 ]; then
    echo "⚙️  Building native universal spcomp for macOS (this takes ~1-2 minutes)..."
    chmod +x "$SCRIPT_DIR/scripts/build-spcomp-macos.sh"
    "$SCRIPT_DIR/scripts/build-spcomp-macos.sh" "1.12-dev" "$SCRIPT_DIR/build-tmp" "$SCRIPT_DIR"
    rm -rf "$SCRIPT_DIR/build-tmp"
fi

# 4. Fetch official includes if missing
if [ ! -f "$INCLUDE_DIR/sourcemod.inc" ]; then
    echo "📦 Downloading standard SourceMod includes..."
    curl -sL "https://sm.alliedmods.net/smdrop/1.12/sourcemod-1.12.0-git7251-linux.tar.gz" -o "/tmp/sm-includes.tar.gz"
    tar -xzf "/tmp/sm-includes.tar.gz" -C "/tmp" addons/sourcemod/scripting/include
    cp -r /tmp/addons/sourcemod/scripting/include/* "$INCLUDE_DIR/"
    rm -rf /tmp/sm-includes.tar.gz /tmp/addons
    echo "✅ Includes installed."
else
    echo "✅ SourceMod standard includes found."
fi

# 5. Ensure scripts are executable
chmod +x "$SCRIPT_DIR/compile.sh" "$SPCOMP" 2>/dev/null || true

# 6. Test compilation with sample plugin
if [ -f "$PLUGINS_DIR/sample.sp" ]; then
    echo "🧪 Testing compilation..."
    "$SCRIPT_DIR/compile.sh" "$PLUGINS_DIR/sample.sp" >/dev/null
    echo "✅ Test successful! Output: compiled/sample.smx"
fi

echo ""
echo "🎉 Setup complete! You are ready to create SourceMod plugins on macOS."
echo ""
echo "👉 Quick start:"
echo "   1. Add your .sp files in 'plugins/'"
echo "   2. Run: ./compile.sh"
echo "   3. (Or in VS Code) Open any .sp file and press Cmd + Shift + B"
echo ""

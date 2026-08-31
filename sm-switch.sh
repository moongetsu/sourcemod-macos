#!/usr/bin/env bash
# ==============================================================================
# sm-switch.sh - Switch between SourceMod compiler versions (1.10, 1.11, 1.12, 1.13)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
INCLUDE_DIR="$SCRIPT_DIR/include"

TARGET_VER="$1"

show_help() {
    echo ""
    echo "🍏 SourceMod Version Switcher (macOS)"
    echo "Usage: ./sm-switch.sh <version>"
    echo ""
    echo "Available versions:"
    echo "  • 1.10  (SourceMod 1.10 Legacy)"
    echo "  • 1.11  (SourceMod 1.11 LTS)"
    echo "  • 1.12  (SourceMod 1.12 Standard / Default)"
    echo "  • 1.13  (SourceMod 1.13 Dev / Master)"
    echo ""
    echo "Examples:"
    echo "  ./sm-switch.sh 1.10"
    echo "  ./sm-switch.sh 1.11"
    echo "  ./sm-switch.sh 1.12"
    echo "  ./sm-switch.sh 1.13"
    echo ""
}

if [ -z "$TARGET_VER" ] || [ "$TARGET_VER" = "list" ] || [ "$TARGET_VER" = "--help" ] || [ "$TARGET_VER" = "-h" ]; then
    show_help
    exit 0
fi

case "$TARGET_VER" in
    1.10|1.10.0) VER="1.10" ;;
    1.11|1.11.0) VER="1.11" ;;
    1.12|1.12.0) VER="1.12" ;;
    1.13|1.13.0) VER="1.13" ;;
    *)
        echo "❌ Unsupported version: $TARGET_VER (Supported: 1.10, 1.11, 1.12, 1.13)"
        exit 1
        ;;
esac

TARGET_BIN="$BIN_DIR/spcomp-$VER"

if [ ! -f "$TARGET_BIN" ]; then
    echo "⚙️ Compiler for $VER is not installed locally. Building it now..."
    "$SCRIPT_DIR/scripts/build-spcomp-macos.sh" "$VER" "$SCRIPT_DIR/build-tmp" "$SCRIPT_DIR"
    rm -rf "$SCRIPT_DIR/build-tmp"
fi

if [ -f "$TARGET_BIN" ]; then
    cp "$TARGET_BIN" "$BIN_DIR/spcomp"
    chmod +x "$BIN_DIR/spcomp"

    if [ -d "$INCLUDE_DIR/$VER" ]; then
        cp -r "$INCLUDE_DIR/$VER/"* "$INCLUDE_DIR/" 2>/dev/null || true
    fi

    echo "✅ Successfully switched active SourceMod compiler to version $VER!"
    echo "   Active Compiler: $BIN_DIR/spcomp"
    "$BIN_DIR/spcomp" | head -n 1 2>/dev/null || true
else
    echo "❌ Failed to switch to version $VER."
    exit 1
fi

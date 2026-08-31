#!/usr/bin/env bash
# ==============================================================================
# compile.sh - Fast Plugin Compiler with Multi-Version Support
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPCOMP="$SCRIPT_DIR/bin/spcomp"
INCLUDE_DIR="$SCRIPT_DIR/include"
COMPILED_DIR="$SCRIPT_DIR/compiled"

# Optional version override via -v <ver>
if [ "$1" = "-v" ] && [ -n "$2" ]; then
    OVERRIDE_VER="$2"
    shift 2
    if [ -f "$SCRIPT_DIR/bin/spcomp-$OVERRIDE_VER" ]; then
        SPCOMP="$SCRIPT_DIR/bin/spcomp-$OVERRIDE_VER"
    fi
    if [ -d "$SCRIPT_DIR/include/$OVERRIDE_VER" ]; then
        INCLUDE_DIR="$SCRIPT_DIR/include/$OVERRIDE_VER"
    fi
fi

mkdir -p "$COMPILED_DIR"

if [ -z "$1" ]; then
    echo "Compiling all plugins in plugins/ using $($SPCOMP | head -n 1)..."
    for file in "$SCRIPT_DIR/plugins"/*.sp; do
        if [ -f "$file" ]; then
            filename=$(basename -- "$file")
            plugin_name="${filename%.*}"
            echo "-> Compiling $filename..."
            "$SPCOMP" "$file" -i"$INCLUDE_DIR" -o"$COMPILED_DIR/$plugin_name.smx"
        fi
    done
    echo "All plugins compiled to $COMPILED_DIR/"
else
    file="$1"
    filename=$(basename -- "$file")
    plugin_name="${filename%.*}"
    echo "-> Compiling $file using $($SPCOMP | head -n 1)..."
    "$SPCOMP" "$file" -i"$INCLUDE_DIR" -o"$COMPILED_DIR/$plugin_name.smx"
    echo "Compiled to $COMPILED_DIR/$plugin_name.smx"
fi

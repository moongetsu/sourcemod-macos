#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPCOMP="$SCRIPT_DIR/bin/spcomp"
INCLUDE_DIR="$SCRIPT_DIR/include"
COMPILED_DIR="$SCRIPT_DIR/compiled"

mkdir -p "$COMPILED_DIR"

if [ -z "$1" ]; then
    echo "Compiling all plugins in plugins/..."
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
    echo "-> Compiling $file..."
    "$SPCOMP" "$file" -i"$INCLUDE_DIR" -o"$COMPILED_DIR/$plugin_name.smx"
    echo "Compiled to $COMPILED_DIR/$plugin_name.smx"
fi

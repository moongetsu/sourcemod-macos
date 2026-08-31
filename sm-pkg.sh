#!/usr/bin/env bash
# ==============================================================================
# sm-pkg.sh - SourceMod Package & Include Manager for macOS
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INCLUDE_DIR="$SCRIPT_DIR/include"
TRACK_FILE="$SCRIPT_DIR/.installed-packages"

mkdir -p "$INCLUDE_DIR"
touch "$TRACK_FILE"

show_help() {
    echo ""
    echo "📦 SourceMod Package Manager (sm-pkg)"
    echo "Usage: ./sm-pkg.sh <command> [package_name / url]"
    echo ""
    echo "Commands:"
    echo "  install <pkg>   Install a popular include or direct URL"
    echo "  remove <pkg>    Remove an installed package"
    echo "  list            List currently installed packages"
    echo "  search [query]  Search curated package registry"
    echo ""
    echo "Curated Packages:"
    echo "  • multicolors      Multi-Colors chat formatting library"
    echo "  • morecolors       MoreColors chat library (Doctor McKay)"
    echo "  • autoexecconfig   Automatic config generator by Impact"
    echo "  • ripext           REST in Pawn (HTTP / JSON extension)"
    echo "  • steamworks       SteamWorks native include"
    echo "  • ptah             PTAH extension includes"
    echo "  • sourcecolors     SourceColors library"
    echo "  • discord          Discord Webhook integration"
    echo ""
    echo "Examples:"
    echo "  ./sm-pkg.sh install autoexecconfig"
    echo "  ./sm-pkg.sh install multicolors"
    echo "  ./sm-pkg.sh install https://example.com/myinclude.inc"
    echo ""
}

CMD="$1"
PKG="$2"

if [ -z "$CMD" ] || [ "$CMD" = "--help" ] || [ "$CMD" = "-h" ]; then
    show_help
    exit 0
fi

case "$CMD" in
    list)
        echo "📦 Installed Packages:"
        if [ -s "$TRACK_FILE" ]; then
            cat "$TRACK_FILE" | while read -r line; do
                echo "  • $line"
            done
        else
            echo "  (No packages installed yet. Run: ./sm-pkg.sh search)"
        fi
        echo ""
        ;;

    search)
        QUERY="${PKG:-}"
        echo "🔍 Available Curated Packages:"
        echo ""
        cat << 'EOF' | grep -i "${QUERY}" || echo "No packages matched '$QUERY'"
multicolors      - Multi-Colors chat formatting library (Bara20)
morecolors       - MoreColors chat library (Doctor McKay)
autoexecconfig   - Automatic config file generator (Impact)
ripext           - REST in Pawn (HTTP & JSON Client)
steamworks       - SteamWorks Extension Include
ptah             - PTAH CS:GO Extension Include
sourcecolors     - Lightweight color formatting library
discord          - Discord Webhook integration include
EOF
        echo ""
        ;;

    install)
        if [ -z "$PKG" ]; then
            echo "❌ Please specify a package name or URL."
            exit 1
        fi

        echo "📥 Installing '$PKG'..."

        # Direct URL installation
        if [[ "$PKG" =~ ^https?:// ]]; then
            FILENAME=$(basename "$PKG")
            curl -sL "$PKG" -o "$INCLUDE_DIR/$FILENAME"
            echo "$FILENAME (Custom URL)" >> "$TRACK_FILE"
            echo "✅ Installed: include/$FILENAME"
            exit 0
        fi

        case "$PKG" in
            multicolors)
                curl -sL "https://raw.githubusercontent.com/Bara/Multi-Colors/master/addons/sourcemod/scripting/include/multicolors.inc" -o "$INCLUDE_DIR/multicolors.inc"
                mkdir -p "$INCLUDE_DIR/multicolors"
                curl -sL "https://raw.githubusercontent.com/Bara/Multi-Colors/master/addons/sourcemod/scripting/include/multicolors/morecolors.inc" -o "$INCLUDE_DIR/multicolors/morecolors.inc"
                curl -sL "https://raw.githubusercontent.com/Bara/Multi-Colors/master/addons/sourcemod/scripting/include/multicolors/colors.inc" -o "$INCLUDE_DIR/multicolors/colors.inc"
                curl -sL "https://raw.githubusercontent.com/Bara/Multi-Colors/master/addons/sourcemod/scripting/include/multicolors/csgo_colors.inc" -o "$INCLUDE_DIR/multicolors/csgo_colors.inc"
                echo "multicolors" >> "$TRACK_FILE"
                echo "✅ Installed: multicolors.inc + multicolor drivers"
                ;;

            morecolors)
                curl -sL "https://raw.githubusercontent.com/DoctorMcKay/sourcemod-morecolors/master/scripting/include/morecolors.inc" -o "$INCLUDE_DIR/morecolors.inc"
                echo "morecolors" >> "$TRACK_FILE"
                echo "✅ Installed: include/morecolors.inc"
                ;;

            autoexecconfig)
                curl -sL "https://raw.githubusercontent.com/Impact123/AutoExecConfig/master/autoexecconfig.inc" -o "$INCLUDE_DIR/autoexecconfig.inc"
                echo "autoexecconfig" >> "$TRACK_FILE"
                echo "✅ Installed: include/autoexecconfig.inc"
                ;;

            ripext)
                curl -sL "https://raw.githubusercontent.com/ErikMinekus/sm-ripext/master/scripting/include/ripext.inc" -o "$INCLUDE_DIR/ripext.inc"
                echo "ripext" >> "$TRACK_FILE"
                echo "✅ Installed: include/ripext.inc"
                ;;

            steamworks)
                curl -sL "https://raw.githubusercontent.com/KyleSanderson/SteamWorks/master/Pawn/includes/SteamWorks.inc" -o "$INCLUDE_DIR/SteamWorks.inc"
                echo "steamworks" >> "$TRACK_FILE"
                echo "✅ Installed: include/SteamWorks.inc"
                ;;

            ptah)
                curl -sL "https://raw.githubusercontent.com/komashchenko/PTaH/master/scripting/include/ptah.inc" -o "$INCLUDE_DIR/ptah.inc"
                echo "ptah" >> "$TRACK_FILE"
                echo "✅ Installed: include/ptah.inc"
                ;;

            sourcecolors)
                curl -sL "https://raw.githubusercontent.com/Flyflo/SourceColors/master/addons/sourcemod/scripting/include/sourcecolors.inc" -o "$INCLUDE_DIR/sourcecolors.inc"
                echo "sourcecolors" >> "$TRACK_FILE"
                echo "✅ Installed: include/sourcecolors.inc"
                ;;

            discord)
                curl -sL "https://raw.githubusercontent.com/CrazyHackGMod/sourcemod-discord/master/addons/sourcemod/scripting/include/discord.inc" -o "$INCLUDE_DIR/discord.inc"
                echo "discord" >> "$TRACK_FILE"
                echo "✅ Installed: include/discord.inc"
                ;;

            *)
                echo "❌ Unknown package '$PKG'. Search available packages with: ./sm-pkg.sh search"
                exit 1
                ;;
        esac

        # Remove duplicates from track file
        sort -u "$TRACK_FILE" -o "$TRACK_FILE"
        ;;

    remove)
        if [ -z "$PKG" ]; then
            echo "❌ Please specify a package name to remove."
            exit 1
        fi

        case "$PKG" in
            multicolors)
                rm -rf "$INCLUDE_DIR/multicolors.inc" "$INCLUDE_DIR/multicolors"
                ;;
            morecolors)
                rm -f "$INCLUDE_DIR/morecolors.inc"
                ;;
            autoexecconfig)
                rm -f "$INCLUDE_DIR/autoexecconfig.inc"
                ;;
            ripext)
                rm -f "$INCLUDE_DIR/ripext.inc"
                ;;
            steamworks)
                rm -f "$INCLUDE_DIR/SteamWorks.inc"
                ;;
            ptah)
                rm -f "$INCLUDE_DIR/ptah.inc"
                ;;
            sourcecolors)
                rm -f "$INCLUDE_DIR/sourcecolors.inc"
                ;;
            discord)
                rm -f "$INCLUDE_DIR/discord.inc"
                ;;
            *)
                rm -f "$INCLUDE_DIR/$PKG" "$INCLUDE_DIR/$PKG.inc"
                ;;
        esac

        grep -v "^$PKG" "$TRACK_FILE" > "${TRACK_FILE}.tmp" || true
        mv "${TRACK_FILE}.tmp" "$TRACK_FILE"
        echo "🗑 Removed package '$PKG'."
        ;;

    *)
        echo "❌ Unknown command '$CMD'. Run ./sm-pkg.sh for help."
        exit 1
        ;;
esac

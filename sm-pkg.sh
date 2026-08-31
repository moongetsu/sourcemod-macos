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
    echo "  install <pkg>   Install a popular include library or direct URL"
    echo "  remove <pkg>    Remove an installed package"
    echo "  list            List currently installed packages"
    echo "  search [query]  Search curated package registry"
    echo ""
    echo "Categories of Curated Packages:"
    echo "  🎨 Chat & Colors:     multicolors, morecolors, sourcecolors, cstrike_colors"
    echo "  ⚙️ Utilities & Stocks: smlib, autoexecconfig, updater, smjansson, json, emit_sound_any"
    echo "  🌐 Web & Networking:  ripext, steamworks, socket, discord, geoip2"
    echo "  🧠 Memory & Detours:  sourcescramble, dhooks, collisionhook, sendproxy"
    echo "  🎮 Game Extensions:   ptah, left4dhooks, tf2items, store"
    echo ""
    echo "Examples:"
    echo "  ./sm-pkg.sh install smlib"
    echo "  ./sm-pkg.sh install multicolors"
    echo "  ./sm-pkg.sh install ripext"
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
        echo "📦 Installed Packages in $INCLUDE_DIR:"
        if [ -s "$TRACK_FILE" ]; then
            cat "$TRACK_FILE" | while read -r line; do
                echo "  • $line"
            done
        else
            echo "  (No packages tracked yet. Run: ./sm-pkg.sh search)"
        fi
        echo ""
        ;;

    search)
        QUERY="${PKG:-}"
        echo "🔍 Available Curated Packages:"
        echo ""
        cat << 'EOF' | grep -i "${QUERY}" || echo "No packages matched '$QUERY'"
multicolors      - Multi-Colors chat formatting library with CS:GO/MoreColors drivers (Bara20)
morecolors       - MoreColors chat formatting library (Doctor McKay)
sourcecolors     - Lightweight cross-game color formatting library (Flyflo)
smlib            - SourceMod Library with 300+ helper stocks and utilities (bcserv)
autoexecconfig   - Automatic config file generator and cvar synchronizer (Impact)
updater          - In-game automated plugin updater system (GoD-Tony/DoctorMcKay)
smjansson        - High-performance Jansson JSON parsing library for SourceMod
json             - Pure SourcePawn JSON encoder/decoder (clugg/sm-json)
ripext           - REST in Pawn: full HTTP client & JSON toolkit (ErikMinekus)
steamworks       - Native SteamWorks extension include (KyleSanderson)
socket           - Raw TCP/UDP Socket extension header (sfPlayer)
discord          - Discord Webhooks and Rich Embed integration library (CrazyHackGMod)
geoip2           - MaxMind GeoIP2 country/city lookup extension headers (komashchenko)
sourcescramble   - Dynamic memory patcher and detour manager (nosoop)
dhooks           - Dynamic Hooks extension header for detour and vtable hooks
collisionhook    - Entity collision override hook extension (nosoop/AlliedMods)
sendproxy        - SendProp and DataMap proxy manipulation extension include
emit_sound_any   - EmitSoundAny stock for cross-game custom sound playback
ptah             - PTAH CS:GO comprehensive engine extension includes (komashchenko)
left4dhooks      - Left 4 DHooks Direct extension & functions include for L4D/L4D2 (Silvers)
tf2items         - TF2Items native attribute management extension (Asherkin)
store            - Core store system include for Zephyrus Store / Sourcemod Store
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
            sort -u "$TRACK_FILE" -o "$TRACK_FILE"
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

            sourcecolors)
                curl -sL "https://raw.githubusercontent.com/Flyflo/SourceColors/master/addons/sourcemod/scripting/include/sourcecolors.inc" -o "$INCLUDE_DIR/sourcecolors.inc"
                echo "sourcecolors" >> "$TRACK_FILE"
                echo "✅ Installed: include/sourcecolors.inc"
                ;;

            smlib)
                echo "Fetching complete SMLib stock library..."
                mkdir -p "$INCLUDE_DIR/smlib"
                curl -sL "https://raw.githubusercontent.com/bcserv/smlib/master/scripting/include/smlib.inc" -o "$INCLUDE_DIR/smlib.inc"
                for sub in arrays clients colors debug entities effects files game general math objects menus server strings vehicles vhash weapons; do
                    curl -sL "https://raw.githubusercontent.com/bcserv/smlib/master/scripting/include/smlib/$sub.inc" -o "$INCLUDE_DIR/smlib/$sub.inc" 2>/dev/null || true
                done
                echo "smlib" >> "$TRACK_FILE"
                echo "✅ Installed: smlib.inc + smlib/ stock library modules"
                ;;

            autoexecconfig)
                curl -sL "https://raw.githubusercontent.com/Impact123/AutoExecConfig/master/autoexecconfig.inc" -o "$INCLUDE_DIR/autoexecconfig.inc"
                echo "autoexecconfig" >> "$TRACK_FILE"
                echo "✅ Installed: include/autoexecconfig.inc"
                ;;

            updater)
                curl -sL "https://raw.githubusercontent.com/DoctorMcKay/sourcemod-plugins/master/scripting/include/updater.inc" -o "$INCLUDE_DIR/updater.inc"
                echo "updater" >> "$TRACK_FILE"
                echo "✅ Installed: include/updater.inc"
                ;;

            ripext)
                curl -sL "https://raw.githubusercontent.com/ErikMinekus/sm-ripext/master/scripting/include/ripext.inc" -o "$INCLUDE_DIR/ripext.inc"
                echo "ripext" >> "$TRACK_FILE"
                echo "✅ Installed: include/ripext.inc"
                ;;

            json)
                curl -sL "https://raw.githubusercontent.com/clugg/sm-json/master/scripting/include/json.inc" -o "$INCLUDE_DIR/json.inc"
                echo "json" >> "$TRACK_FILE"
                echo "✅ Installed: include/json.inc"
                ;;

            smjansson)
                curl -sL "https://raw.githubusercontent.com/thraaawn/SMJansson/master/scripting/include/smjansson.inc" -o "$INCLUDE_DIR/smjansson.inc"
                echo "smjansson" >> "$TRACK_FILE"
                echo "✅ Installed: include/smjansson.inc"
                ;;

            steamworks)
                curl -sL "https://raw.githubusercontent.com/KyleSanderson/SteamWorks/master/Pawn/includes/SteamWorks.inc" -o "$INCLUDE_DIR/SteamWorks.inc"
                echo "steamworks" >> "$TRACK_FILE"
                echo "✅ Installed: include/SteamWorks.inc"
                ;;

            socket)
                curl -sL "https://raw.githubusercontent.com/sfPlayer/Socket/master/scripting/include/socket.inc" -o "$INCLUDE_DIR/socket.inc" 2>/dev/null || \
                curl -sL "https://raw.githubusercontent.com/alliedmodders/sourcemod/master/plugins/include/socket.inc" -o "$INCLUDE_DIR/socket.inc"
                echo "socket" >> "$TRACK_FILE"
                echo "✅ Installed: include/socket.inc"
                ;;

            discord)
                curl -sL "https://raw.githubusercontent.com/CrazyHackGMod/sourcemod-discord/master/addons/sourcemod/scripting/include/discord.inc" -o "$INCLUDE_DIR/discord.inc"
                echo "discord" >> "$TRACK_FILE"
                echo "✅ Installed: include/discord.inc"
                ;;

            geoip2)
                curl -sL "https://raw.githubusercontent.com/komashchenko/GeoIP2/master/scripting/include/geoip2.inc" -o "$INCLUDE_DIR/geoip2.inc"
                echo "geoip2" >> "$TRACK_FILE"
                echo "✅ Installed: include/geoip2.inc"
                ;;

            sourcescramble)
                curl -sL "https://raw.githubusercontent.com/nosoop/SMExt-SourceScramble/master/pawn/sourcescramble.inc" -o "$INCLUDE_DIR/sourcescramble.inc"
                echo "sourcescramble" >> "$TRACK_FILE"
                echo "✅ Installed: include/sourcescramble.inc"
                ;;

            dhooks)
                curl -sL "https://raw.githubusercontent.com/alliedmodders/sourcemod/master/plugins/include/dhooks.inc" -o "$INCLUDE_DIR/dhooks.inc" 2>/dev/null || \
                curl -sL "https://raw.githubusercontent.com/peace-maker/sourcemod/master/plugins/include/dhooks.inc" -o "$INCLUDE_DIR/dhooks.inc"
                echo "dhooks" >> "$TRACK_FILE"
                echo "✅ Installed: include/dhooks.inc"
                ;;

            collisionhook)
                curl -sL "https://raw.githubusercontent.com/nosoop/SM-CollisionHook/master/pawn/collisionhook.inc" -o "$INCLUDE_DIR/collisionhook.inc"
                echo "collisionhook" >> "$TRACK_FILE"
                echo "✅ Installed: include/collisionhook.inc"
                ;;

            sendproxy)
                curl -sL "https://raw.githubusercontent.com/komashchenko/SendProxy/master/pawn/sendproxy.inc" -o "$INCLUDE_DIR/sendproxy.inc"
                echo "sendproxy" >> "$TRACK_FILE"
                echo "✅ Installed: include/sendproxy.inc"
                ;;

            emit_sound_any)
                curl -sL "https://raw.githubusercontent.com/shanapu/MyJailbreak/master/addons/sourcemod/scripting/include/emitsoundany.inc" -o "$INCLUDE_DIR/emitsoundany.inc"
                echo "emit_sound_any" >> "$TRACK_FILE"
                echo "✅ Installed: include/emitsoundany.inc"
                ;;

            ptah)
                curl -sL "https://raw.githubusercontent.com/komashchenko/PTaH/master/scripting/include/ptah.inc" -o "$INCLUDE_DIR/ptah.inc"
                echo "ptah" >> "$TRACK_FILE"
                echo "✅ Installed: include/ptah.inc"
                ;;

            left4dhooks)
                curl -sL "https://raw.githubusercontent.com/Silvers1989/left4dhooks/main/scripting/include/left4dhooks.inc" -o "$INCLUDE_DIR/left4dhooks.inc"
                echo "left4dhooks" >> "$TRACK_FILE"
                echo "✅ Installed: include/left4dhooks.inc"
                ;;

            tf2items)
                curl -sL "https://raw.githubusercontent.com/nosoop/SM-TF2Items/master/pawn/tf2items.inc" -o "$INCLUDE_DIR/tf2items.inc" 2>/dev/null || \
                curl -sL "https://raw.githubusercontent.com/alliedmodders/sourcemod/master/plugins/include/tf2items.inc" -o "$INCLUDE_DIR/tf2items.inc"
                echo "tf2items" >> "$TRACK_FILE"
                echo "✅ Installed: include/tf2items.inc"
                ;;

            store)
                curl -sL "https://raw.githubusercontent.com/arrow244/store/master/scripting/include/store.inc" -o "$INCLUDE_DIR/store.inc" 2>/dev/null || \
                curl -sL "https://raw.githubusercontent.com/alongubkin/store/master/scripting/include/store.inc" -o "$INCLUDE_DIR/store.inc"
                echo "store" >> "$TRACK_FILE"
                echo "✅ Installed: include/store.inc"
                ;;

            *)
                echo "❌ Unknown package '$PKG'. Search available packages with: ./sm-pkg.sh search"
                exit 1
                ;;
        esac

        sort -u "$TRACK_FILE" -o "$TRACK_FILE"
        ;;

    remove)
        if [ -z "$PKG" ]; then
            echo "❌ Please specify a package name to remove."
            exit 1
        fi

        case "$PKG" in
            multicolors)    rm -rf "$INCLUDE_DIR/multicolors.inc" "$INCLUDE_DIR/multicolors" ;;
            morecolors)     rm -f "$INCLUDE_DIR/morecolors.inc" ;;
            sourcecolors)   rm -f "$INCLUDE_DIR/sourcecolors.inc" ;;
            smlib)          rm -rf "$INCLUDE_DIR/smlib.inc" "$INCLUDE_DIR/smlib" ;;
            autoexecconfig) rm -f "$INCLUDE_DIR/autoexecconfig.inc" ;;
            updater)        rm -f "$INCLUDE_DIR/updater.inc" ;;
            ripext)         rm -f "$INCLUDE_DIR/ripext.inc" ;;
            json)           rm -f "$INCLUDE_DIR/json.inc" ;;
            smjansson)      rm -f "$INCLUDE_DIR/smjansson.inc" ;;
            steamworks)     rm -f "$INCLUDE_DIR/SteamWorks.inc" ;;
            socket)         rm -f "$INCLUDE_DIR/socket.inc" ;;
            discord)        rm -f "$INCLUDE_DIR/discord.inc" ;;
            geoip2)         rm -f "$INCLUDE_DIR/geoip2.inc" ;;
            sourcescramble) rm -f "$INCLUDE_DIR/sourcescramble.inc" ;;
            dhooks)         rm -f "$INCLUDE_DIR/dhooks.inc" ;;
            collisionhook)  rm -f "$INCLUDE_DIR/collisionhook.inc" ;;
            sendproxy)      rm -f "$INCLUDE_DIR/sendproxy.inc" ;;
            emit_sound_any) rm -f "$INCLUDE_DIR/emitsoundany.inc" ;;
            ptah)           rm -f "$INCLUDE_DIR/ptah.inc" ;;
            left4dhooks)    rm -f "$INCLUDE_DIR/left4dhooks.inc" ;;
            tf2items)       rm -f "$INCLUDE_DIR/tf2items.inc" ;;
            store)          rm -f "$INCLUDE_DIR/store.inc" ;;
            *)              rm -f "$INCLUDE_DIR/$PKG" "$INCLUDE_DIR/$PKG.inc" ;;
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

#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# REAL-TIME PERMISSION MONITOR
# "Who's asking for what, and when"
# ═══════════════════════════════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'
BG_RED='\033[41m'
BG_YELLOW='\033[43m'

ADB="${HOME}/Downloads/platform-tools/adb"

# High-risk permission categories
declare -A PERM_CATEGORIES=(
    ["CAMERA"]="camera|CAMERA"
    ["MICROPHONE"]="audio|AUDIO|RECORD|microphone"
    ["LOCATION"]="location|LOCATION|gps|GPS"
    ["CONTACTS"]="contacts|CONTACTS"
    ["SMS"]="sms|SMS|mms|MMS"
    ["PHONE"]="phone|PHONE|call|CALL"
    ["STORAGE"]="storage|STORAGE|file|FILE|media|MEDIA"
    ["NETWORK"]="internet|INTERNET|network|NETWORK|wifi|WIFI"
)

banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║  ██████╗ ███████╗██████╗ ███╗   ███╗    ██╗    ██╗ █████╗ ████████╗ ██████╗║
    ║  ██╔══██╗██╔════╝██╔══██╗████╗ ████║    ██║    ██║██╔══██╗╚══██╔══╝██╔════╝║
    ║  ██████╔╝█████╗  ██████╔╝██╔████╔██║    ██║ █╗ ██║███████║   ██║   ██║     ║
    ║  ██╔═══╝ ██╔══╝  ██╔══██╗██║╚██╔╝██║    ██║███╗██║██╔══██║   ██║   ██║     ║
    ║  ██║     ███████╗██║  ██║██║ ╚═╝ ██║    ╚███╔███╔╝██║  ██║   ██║   ╚██████╗║
    ║  ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝    ╚═════╝║
    ║                                                                            ║
    ║              "Watching who's watching you"                                 ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

format_permission_event() {
    local line="$1"
    local timestamp=$(echo "$line" | awk '{print $1, $2}')
    local message=$(echo "$line" | cut -d':' -f2-)

    # Check each category
    for category in "${!PERM_CATEGORIES[@]}"; do
        if echo "$line" | grep -qiE "${PERM_CATEGORIES[$category]}"; then
            case "$category" in
                "CAMERA")
                    echo -e "${RED}📷 CAMERA${NC} ${DIM}$timestamp${NC}"
                    echo -e "    ${RED}$message${NC}"
                    ;;
                "MICROPHONE")
                    echo -e "${RED}🎤 MICROPHONE${NC} ${DIM}$timestamp${NC}"
                    echo -e "    ${RED}$message${NC}"
                    ;;
                "LOCATION")
                    echo -e "${YELLOW}📍 LOCATION${NC} ${DIM}$timestamp${NC}"
                    echo -e "    ${YELLOW}$message${NC}"
                    ;;
                "CONTACTS")
                    echo -e "${MAGENTA}👥 CONTACTS${NC} ${DIM}$timestamp${NC}"
                    echo -e "    ${MAGENTA}$message${NC}"
                    ;;
                "SMS")
                    echo -e "${RED}💬 SMS/MMS${NC} ${DIM}$timestamp${NC}"
                    echo -e "    ${RED}$message${NC}"
                    ;;
                "PHONE")
                    echo -e "${YELLOW}📞 PHONE${NC} ${DIM}$timestamp${NC}"
                    echo -e "    ${YELLOW}$message${NC}"
                    ;;
                "STORAGE")
                    echo -e "${BLUE}💾 STORAGE${NC} ${DIM}$timestamp${NC}"
                    echo -e "    ${BLUE}$message${NC}"
                    ;;
                "NETWORK")
                    echo -e "${CYAN}🌐 NETWORK${NC} ${DIM}$timestamp${NC}"
                    echo -e "    ${CYAN}$message${NC}"
                    ;;
            esac
            return
        fi
    done

    # Generic permission event
    if echo "$line" | grep -qiE "permission|grant|deny|request"; then
        echo -e "${WHITE}🔐 PERMISSION${NC} ${DIM}$timestamp${NC}"
        echo -e "    ${WHITE}$message${NC}"
    fi
}

show_current_usage() {
    echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}CURRENT PERMISSION USAGE${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    # Camera
    echo -e "  ${CYAN}Camera Access:${NC}"
    local cam_users=$($ADB shell dumpsys media.camera 2>/dev/null | grep -i "client" | head -5)
    if [ -n "$cam_users" ]; then
        echo "$cam_users" | while read -r line; do
            echo -e "    ${RED}●${NC} $line"
        done
    else
        echo -e "    ${GREEN}●${NC} No active camera usage"
    fi

    # Audio
    echo -e "\n  ${CYAN}Microphone Access:${NC}"
    local audio_users=$($ADB shell dumpsys audio 2>/dev/null | grep -i "recording" | head -5)
    if [ -n "$audio_users" ]; then
        echo "$audio_users" | while read -r line; do
            echo -e "    ${RED}●${NC} $line"
        done
    else
        echo -e "    ${GREEN}●${NC} No active recording"
    fi

    # Location
    echo -e "\n  ${CYAN}Location Access:${NC}"
    local loc_users=$($ADB shell dumpsys location 2>/dev/null | grep -i "active" | head -5)
    if [ -n "$loc_users" ]; then
        echo "$loc_users" | while read -r line; do
            echo -e "    ${YELLOW}●${NC} $line"
        done
    else
        echo -e "    ${GREEN}●${NC} No active location requests"
    fi

    echo ""
}

watch_permissions() {
    banner

    echo -e "  ${DIM}Watching for permission events...${NC}"
    echo -e "  ${DIM}Press Ctrl+C to exit${NC}\n"

    show_current_usage

    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}LIVE PERMISSION EVENTS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    # Clear and watch logcat for permission events
    $ADB logcat -c 2>/dev/null

    $ADB logcat -v time 2>/dev/null | grep -iE "permission|camera|microphone|location|contacts|sms|phone|storage" | while IFS= read -r line; do
        format_permission_event "$line"
        echo ""
    done
}

list_app_permissions() {
    banner

    echo -e "  ${CYAN}Enter package name (or 'all' for summary):${NC} "
    read -r pkg

    if [ "$pkg" == "all" ]; then
        echo -e "\n${BOLD}  Apps with Dangerous Permissions:${NC}\n"

        for p in $($ADB shell pm list packages -3 2>/dev/null | sed 's/package://'); do
            local perms=$($ADB shell dumpsys package "$p" 2>/dev/null | grep -E "CAMERA|RECORD_AUDIO|LOCATION|CONTACTS|SMS|CALL" | wc -l)
            if [ "$perms" -gt 0 ]; then
                echo -e "  ${YELLOW}$p${NC}: $perms dangerous permissions"
            fi
        done
    else
        echo -e "\n${BOLD}  Permissions for: ${CYAN}$pkg${NC}\n"

        $ADB shell dumpsys package "$pkg" 2>/dev/null | grep "permission" | sort -u | while read -r line; do
            if echo "$line" | grep -qiE "CAMERA|RECORD_AUDIO|LOCATION|CONTACTS|SMS|CALL"; then
                echo -e "    ${RED}●${NC} $line"
            else
                echo -e "    ${DIM}○${NC} $line"
            fi
        done
    fi

    echo -e "\n  ${DIM}Press any key to continue...${NC}"
    read -n 1 -s
}

main_menu() {
    banner

    echo -e "  ${BOLD}Select mode:${NC}\n"
    echo -e "    ${GREEN}1)${NC} Watch real-time permission events"
    echo -e "    ${GREEN}2)${NC} List app permissions"
    echo -e "    ${GREEN}3)${NC} Show current permission usage"
    echo -e "    ${RED}q)${NC} Quit\n"

    echo -ne "  ${CYAN}Choice:${NC} "
    read -r choice

    case $choice in
        1) watch_permissions ;;
        2) list_app_permissions; main_menu ;;
        3) show_current_usage; echo -e "\n  ${DIM}Press any key...${NC}"; read -n 1 -s; main_menu ;;
        q|Q) exit 0 ;;
        *) main_menu ;;
    esac
}

# Check ADB
if ! [ -x "$ADB" ]; then
    echo -e "${RED}ADB not found at $ADB${NC}"
    exit 1
fi

if ! $ADB devices | grep -q "device$"; then
    banner
    echo -e "  ${RED}No device connected!${NC}"
    exit 1
fi

trap 'echo -e "\n\n${GREEN}  Permission watch ended.${NC}\n"; exit 0' INT

main_menu

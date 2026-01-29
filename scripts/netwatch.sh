#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# NETWORK TRAFFIC MONITOR
# "Every packet tells a story"
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

ADB="${HOME}/Downloads/platform-tools/adb"

# Known suspicious ports
SUSPICIOUS_PORTS="4444|5555|6666|7777|8888|9999|31337|12345"

# Known ad/tracking domains patterns
AD_PATTERNS="doubleclick|googleads|facebook.*pixel|analytics|tracker|ad\.|ads\.|adservice|advertising"

banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║  ███╗   ██╗███████╗████████╗██╗    ██╗ █████╗ ████████╗ ██████╗██╗  ██╗   ║
    ║  ████╗  ██║██╔════╝╚══██╔══╝██║    ██║██╔══██╗╚══██╔══╝██╔════╝██║  ██║   ║
    ║  ██╔██╗ ██║█████╗     ██║   ██║ █╗ ██║███████║   ██║   ██║     ███████║   ║
    ║  ██║╚██╗██║██╔══╝     ██║   ██║███╗██║██╔══██║   ██║   ██║     ██╔══██║   ║
    ║  ██║ ╚████║███████╗   ██║   ╚███╔███╔╝██║  ██║   ██║   ╚██████╗██║  ██║   ║
    ║  ╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝   ║
    ║                                                                            ║
    ║              "Every packet tells a story"                                  ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_connection_stats() {
    echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}CONNECTION OVERVIEW${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    # Get connection counts
    local established=$($ADB shell netstat -an 2>/dev/null | grep -c "ESTABLISHED" || echo "0")
    local listening=$($ADB shell netstat -an 2>/dev/null | grep -c "LISTEN" || echo "0")
    local time_wait=$($ADB shell netstat -an 2>/dev/null | grep -c "TIME_WAIT" || echo "0")
    local close_wait=$($ADB shell netstat -an 2>/dev/null | grep -c "CLOSE_WAIT" || echo "0")

    echo -e "  ${GREEN}Established:${NC} $established"
    echo -e "  ${CYAN}Listening:${NC}   $listening"
    echo -e "  ${YELLOW}Time Wait:${NC}   $time_wait"
    echo -e "  ${RED}Close Wait:${NC}  $close_wait"
}

show_active_connections() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}ACTIVE CONNECTIONS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    local count=0
    $ADB shell netstat -an 2>/dev/null | grep "ESTABLISHED" | while read -r line; do
        ((count++))
        local local_addr=$(echo "$line" | awk '{print $4}')
        local remote_addr=$(echo "$line" | awk '{print $5}')
        local remote_port=$(echo "$remote_addr" | rev | cut -d':' -f1 | rev)

        # Check for suspicious ports
        if echo "$remote_port" | grep -qE "$SUSPICIOUS_PORTS"; then
            echo -e "  ${RED}⚠ SUSPICIOUS${NC} $local_addr → $remote_addr"
        # Common ports
        elif [ "$remote_port" == "443" ]; then
            echo -e "  ${GREEN}🔒${NC} $local_addr → $remote_addr ${DIM}(HTTPS)${NC}"
        elif [ "$remote_port" == "80" ]; then
            echo -e "  ${YELLOW}🌐${NC} $local_addr → $remote_addr ${DIM}(HTTP - unencrypted!)${NC}"
        elif [ "$remote_port" == "53" ]; then
            echo -e "  ${CYAN}📡${NC} $local_addr → $remote_addr ${DIM}(DNS)${NC}"
        else
            echo -e "  ${DIM}●${NC} $local_addr → $remote_addr"
        fi

        if [ $count -ge 30 ]; then
            echo -e "  ${DIM}... and more${NC}"
            break
        fi
    done
}

show_listening_ports() {
    echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}LISTENING PORTS${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    $ADB shell netstat -an 2>/dev/null | grep "LISTEN" | while read -r line; do
        local addr=$(echo "$line" | awk '{print $4}')
        local port=$(echo "$addr" | rev | cut -d':' -f1 | rev)

        # Check for suspicious listening ports
        if echo "$port" | grep -qE "$SUSPICIOUS_PORTS"; then
            echo -e "  ${RED}⚠ SUSPICIOUS${NC} $addr"
        elif [ "$port" == "5555" ]; then
            echo -e "  ${RED}⚠ ADB WIRELESS${NC} $addr ${RED}(Security risk!)${NC}"
        else
            echo -e "  ${GREEN}●${NC} $addr"
        fi
    done
}

show_dns_queries() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}RECENT DNS ACTIVITY${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    echo -e "  ${DIM}Watching DNS queries in logcat...${NC}\n"

    $ADB logcat -d 2>/dev/null | grep -iE "dns|resolve|lookup" | tail -20 | while read -r line; do
        # Check for ad/tracking domains
        if echo "$line" | grep -qiE "$AD_PATTERNS"; then
            echo -e "  ${YELLOW}📊${NC} ${YELLOW}$line${NC}"
        else
            echo -e "  ${DIM}$line${NC}"
        fi
    done
}

watch_traffic() {
    banner
    echo -e "  ${DIM}Real-time network monitoring...${NC}"
    echo -e "  ${DIM}Press Ctrl+C to stop${NC}\n"

    # Clear logcat
    $ADB logcat -c 2>/dev/null

    # Watch for network-related events
    $ADB logcat -v time 2>/dev/null | grep -iE "connect|socket|http|network|dns|wifi|cellular" | while read -r line; do
        local timestamp=$(echo "$line" | awk '{print $1, $2}')

        # Categorize
        if echo "$line" | grep -qiE "error|fail|refused|timeout"; then
            echo -e "${RED}✗${NC} ${DIM}$timestamp${NC} ${RED}$line${NC}"
        elif echo "$line" | grep -qiE "connect"; then
            echo -e "${GREEN}→${NC} ${DIM}$timestamp${NC} ${GREEN}$(echo "$line" | cut -d':' -f2-)${NC}"
        elif echo "$line" | grep -qiE "disconnect|close"; then
            echo -e "${YELLOW}←${NC} ${DIM}$timestamp${NC} ${YELLOW}$(echo "$line" | cut -d':' -f2-)${NC}"
        else
            echo -e "${DIM}●${NC} ${DIM}$timestamp${NC} $(echo "$line" | cut -d':' -f2-)"
        fi
    done
}

show_app_network_usage() {
    echo -e "\n${GREEN}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}APP NETWORK USAGE${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    echo -e "  ${DIM}Getting network stats per app...${NC}\n"

    # Get network stats (this may require root on some devices)
    $ADB shell cat /proc/net/xt_qtaguid/stats 2>/dev/null | head -30 | while read -r line; do
        # Parse and display (format varies by device)
        echo -e "  ${DIM}$line${NC}"
    done

    echo -e "\n  ${CYAN}Data usage by foreground apps:${NC}\n"
    $ADB shell dumpsys netstats 2>/dev/null | grep -A 5 "ident=" | head -30 | while read -r line; do
        echo -e "  $line"
    done
}

wifi_analysis() {
    echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}WIFI ANALYSIS${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    # Current connection
    local wifi_info=$($ADB shell dumpsys wifi 2>/dev/null | grep -A 10 "mWifiInfo")
    if [ -n "$wifi_info" ]; then
        echo -e "  ${CYAN}Current Connection:${NC}"
        echo "$wifi_info" | while read -r line; do
            echo -e "    $line"
        done
    fi

    # Saved networks
    echo -e "\n  ${CYAN}Saved Networks:${NC}"
    $ADB shell dumpsys wifi 2>/dev/null | grep -E "SSID|ConfigKey" | head -20 | while read -r line; do
        echo -e "    ${DIM}$line${NC}"
    done

    # Security check
    local security=$($ADB shell dumpsys wifi 2>/dev/null | grep -i "security" | head -5)
    if echo "$security" | grep -qi "OPEN\|NONE"; then
        echo -e "\n  ${RED}⚠ Warning: Connected to open/insecure network${NC}"
    fi
}

main_menu() {
    banner

    echo -e "  ${BOLD}Select view:${NC}\n"
    echo -e "    ${GREEN}1)${NC} Connection overview"
    echo -e "    ${GREEN}2)${NC} Active connections"
    echo -e "    ${GREEN}3)${NC} Listening ports"
    echo -e "    ${GREEN}4)${NC} DNS activity"
    echo -e "    ${GREEN}5)${NC} Watch traffic (live)"
    echo -e "    ${GREEN}6)${NC} App network usage"
    echo -e "    ${GREEN}7)${NC} WiFi analysis"
    echo -e "    ${GREEN}8)${NC} Full report"
    echo -e "    ${RED}q)${NC} Quit\n"

    echo -ne "  ${CYAN}Choice:${NC} "
    read -r choice

    case $choice in
        1)
            show_connection_stats
            echo -e "\n  ${DIM}Press any key...${NC}"; read -n 1 -s
            main_menu
            ;;
        2)
            show_active_connections
            echo -e "\n  ${DIM}Press any key...${NC}"; read -n 1 -s
            main_menu
            ;;
        3)
            show_listening_ports
            echo -e "\n  ${DIM}Press any key...${NC}"; read -n 1 -s
            main_menu
            ;;
        4)
            show_dns_queries
            echo -e "\n  ${DIM}Press any key...${NC}"; read -n 1 -s
            main_menu
            ;;
        5)
            watch_traffic
            ;;
        6)
            show_app_network_usage
            echo -e "\n  ${DIM}Press any key...${NC}"; read -n 1 -s
            main_menu
            ;;
        7)
            wifi_analysis
            echo -e "\n  ${DIM}Press any key...${NC}"; read -n 1 -s
            main_menu
            ;;
        8)
            banner
            show_connection_stats
            show_active_connections
            show_listening_ports
            wifi_analysis
            echo -e "\n  ${DIM}Press any key...${NC}"; read -n 1 -s
            main_menu
            ;;
        q|Q)
            echo -e "\n  ${GREEN}Stay connected. Stay secure.${NC}\n"
            exit 0
            ;;
        *)
            main_menu
            ;;
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

trap 'echo -e "\n\n${GREEN}  Network watch ended.${NC}\n"; exit 0' INT

main_menu

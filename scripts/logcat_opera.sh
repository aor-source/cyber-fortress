#!/bin/zsh
# ═══════════════════════════════════════════════════════════════════════════════
# LOGCAT HIP-HOP OPERA
# "Where every log entry drops bars"
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
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'

ADB="${HOME}/Downloads/platform-tools/adb"

# Hip-hop phrases for different log levels
declare -A VERBOSE_BARS=(
    [0]="Yo, just vibin' in the background"
    [1]="Smooth like butter, no stress"
    [2]="Keepin' it chill, just logs"
    [3]="Flow so smooth, no hiccups"
    [4]="Just another day in paradise"
)

declare -A DEBUG_BARS=(
    [0]="Debuggin' like a boss"
    [1]="Deep in the code, no sleep"
    [2]="Stack trace? Nah, stack GRACE"
    [3]="Breakpoint? More like BREAK THROUGH"
    [4]="Variables exposed, truth disclosed"
)

declare -A INFO_BARS=(
    [0]="System speaks, everybody listens"
    [1]="Knowledge dropped, wisdom unlocked"
    [2]="The app has spoken, the prophecy awoken"
    [3]="Info flow like water, clean and proper"
    [4]="Signal clear, the message here"
)

declare -A WARNING_BARS=(
    [0]="HOLD UP - something ain't right"
    [1]="Yellow light, proceed with might"
    [2]="Warning shot across the bow"
    [3]="The system's got concerns right now"
    [4]="Pay attention, there's tension"
    [5]="Not a drill, but stay chill"
)

declare -A ERROR_BARS=(
    [0]="OH SNAP! We got problems!"
    [1]="ERROR in the HOUSE - everybody out!"
    [2]="Red alert! Code needs work!"
    [3]="The stack is CRACKED, time to react!"
    [4]="Exception thrown, cover's blown!"
    [5]="Bug just dropped, but we won't be stopped!"
    [6]="Crash and burn, now we learn!"
)

declare -A FATAL_BARS=(
    [0]="GAME OVER but we respawn stronger!"
    [1]="CRITICAL HIT! App is lit... on fire!"
    [2]="FATALITY! But we ain't done!"
    [3]="SYSTEM DOWN but legends never die!"
    [4]="From the ashes, we rise with classes!"
)

# Security-related keywords
SECURITY_KEYWORDS="permission|denied|unauthorized|security|certificate|ssl|crypto|auth|login|password|token|key|root|su |exploit|inject|overflow|malware|virus|trojan"

# Performance keywords
PERF_KEYWORDS="ANR|slow|timeout|memory|leak|GC_|OutOfMemory|OOM|freeze|blocked|deadlock"

get_random_bar() {
    local -n arr=$1
    local keys=("${!arr[@]}")
    local random_key=${keys[$RANDOM % ${#keys[@]}]}
    echo "${arr[$random_key]}"
}

banner() {
    clear
    echo -e "${MAGENTA}"
    cat << 'EOF'
    ██╗      ██████╗  ██████╗  ██████╗ █████╗ ████████╗     ██████╗ ██████╗ ███████╗██████╗  █████╗
    ██║     ██╔═══██╗██╔════╝ ██╔════╝██╔══██╗╚══██╔══╝    ██╔═══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗
    ██║     ██║   ██║██║  ███╗██║     ███████║   ██║       ██║   ██║██████╔╝█████╗  ██████╔╝███████║
    ██║     ██║   ██║██║   ██║██║     ██╔══██║   ██║       ██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗██╔══██║
    ███████╗╚██████╔╝╚██████╔╝╚██████╗██║  ██║   ██║       ╚██████╔╝██║     ███████╗██║  ██║██║  ██║
    ╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝   ╚═╝        ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝

                          "Where every log entry drops bars"
EOF
    echo -e "${NC}"
}

status_bar() {
    local v_count=$1
    local d_count=$2
    local i_count=$3
    local w_count=$4
    local e_count=$5
    local f_count=$6
    local sec_count=$7

    echo -ne "\r${DIM}───${NC} "
    echo -ne "${WHITE}V:${NC}${v_count} "
    echo -ne "${BLUE}D:${NC}${d_count} "
    echo -ne "${GREEN}I:${NC}${i_count} "
    echo -ne "${YELLOW}W:${NC}${w_count} "
    echo -ne "${RED}E:${NC}${e_count} "
    echo -ne "${BG_RED}${WHITE}F:${NC}${f_count} "
    echo -ne "${MAGENTA}SEC:${NC}${sec_count} "
    echo -ne "${DIM}───${NC}"
}

format_log() {
    local line="$1"
    local timestamp=$(echo "$line" | cut -d' ' -f1-2)
    local level=$(echo "$line" | awk '{print $5}')
    local tag=$(echo "$line" | awk '{print $6}' | tr -d ':')
    local message=$(echo "$line" | cut -d':' -f2-)

    # Security check
    if echo "$line" | grep -qiE "$SECURITY_KEYWORDS"; then
        echo -e "${BG_MAGENTA}${WHITE} SECURITY ${NC} ${MAGENTA}$timestamp${NC} ${WHITE}[$tag]${NC}"
        echo -e "    ${MAGENTA}$message${NC}"
        echo -e "    ${DIM}${CYAN}>> Security event detected <<${NC}"
        return 7
    fi

    # Performance check
    if echo "$line" | grep -qiE "$PERF_KEYWORDS"; then
        echo -e "${BG_YELLOW}${WHITE} PERF ${NC} ${YELLOW}$timestamp${NC} ${WHITE}[$tag]${NC}"
        echo -e "    ${YELLOW}$message${NC}"
        echo -e "    ${DIM}${YELLOW}>> Performance concern <<${NC}"
        return 8
    fi

    case "$level" in
        V)
            echo -e "${DIM}$timestamp${NC} ${WHITE}[V]${NC} ${DIM}$tag: $message${NC}"
            return 1
            ;;
        D)
            local bar=$(get_random_bar DEBUG_BARS)
            echo -e "${BLUE}$timestamp${NC} ${BG_BLUE}${WHITE} D ${NC} ${CYAN}$tag${NC}"
            echo -e "    ${BLUE}$message${NC}"
            if [ $((RANDOM % 5)) -eq 0 ]; then
                echo -e "    ${DIM}${CYAN}>> $bar <<${NC}"
            fi
            return 2
            ;;
        I)
            local bar=$(get_random_bar INFO_BARS)
            echo -e "${GREEN}$timestamp${NC} ${BG_GREEN}${WHITE} I ${NC} ${WHITE}$tag${NC}"
            echo -e "    ${GREEN}$message${NC}"
            if [ $((RANDOM % 4)) -eq 0 ]; then
                echo -e "    ${DIM}${GREEN}>> $bar <<${NC}"
            fi
            return 3
            ;;
        W)
            local bar=$(get_random_bar WARNING_BARS)
            echo -e "${YELLOW}$timestamp${NC} ${BG_YELLOW}${WHITE} W ${NC} ${YELLOW}$tag${NC}"
            echo -e "    ${YELLOW}$message${NC}"
            echo -e "    ${BOLD}${YELLOW}>> $bar <<${NC}"
            return 4
            ;;
        E)
            local bar=$(get_random_bar ERROR_BARS)
            echo -e ""
            echo -e "${RED}════════════════════════════════════════════════════════════════════${NC}"
            echo -e "${RED}$timestamp${NC} ${BG_RED}${WHITE} ERROR ${NC} ${RED}$tag${NC}"
            echo -e "    ${RED}$message${NC}"
            echo -e "    ${BOLD}${RED}>> $bar <<${NC}"
            echo -e "${RED}════════════════════════════════════════════════════════════════════${NC}"
            return 5
            ;;
        F)
            local bar=$(get_random_bar FATAL_BARS)
            echo -e ""
            echo -e "${BG_RED}${WHITE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${BG_RED}${WHITE}║                              F A T A L                                   ║${NC}"
            echo -e "${BG_RED}${WHITE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
            echo -e "${RED}$timestamp${NC} ${WHITE}$tag${NC}"
            echo -e "    ${RED}$message${NC}"
            echo -e "    ${BOLD}${WHITE}>> $bar <<${NC}"
            echo -e ""
            return 6
            ;;
        *)
            echo -e "${DIM}$line${NC}"
            return 0
            ;;
    esac
}

select_mode() {
    echo -e "\n${BOLD}${WHITE}  Select your vibe:${NC}\n"
    echo -e "    ${GREEN}1)${NC} Full Opera - All logs, all bars"
    echo -e "    ${YELLOW}2)${NC} Warning & Up - Only the important stuff"
    echo -e "    ${RED}3)${NC} Errors Only - When things go wrong"
    echo -e "    ${MAGENTA}4)${NC} Security Focus - Privacy/security events"
    echo -e "    ${CYAN}5)${NC} Performance Watch - ANRs, memory, slowdowns"
    echo -e "    ${BLUE}6)${NC} Filter by package name"
    echo -e "    ${WHITE}7)${NC} Custom filter\n"

    echo -ne "  ${CYAN}Choice:${NC} "
    read -r choice

    case $choice in
        1) echo "*:V" ;;
        2) echo "*:W" ;;
        3) echo "*:E" ;;
        4) echo "security" ;;
        5) echo "performance" ;;
        6)
            echo -ne "  ${CYAN}Package name:${NC} "
            read -r pkg
            echo "$pkg:V"
            ;;
        7)
            echo -ne "  ${CYAN}Custom filter (logcat format):${NC} "
            read -r custom
            echo "$custom"
            ;;
        *)
            echo "*:I"
            ;;
    esac
}

run_opera() {
    local filter="$1"

    banner

    echo -e "  ${CYAN}Filter:${NC} $filter"
    echo -e "  ${DIM}Press Ctrl+C to exit${NC}\n"
    echo -e "${DIM}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    local v_count=0
    local d_count=0
    local i_count=0
    local w_count=0
    local e_count=0
    local f_count=0
    local sec_count=0
    local line_count=0

    if [[ "$filter" == "security" ]]; then
        $ADB logcat -v time 2>/dev/null | grep -iE "$SECURITY_KEYWORDS" | while IFS= read -r line; do
            format_log "$line"
            ((sec_count++))
            ((line_count++))
            if [ $((line_count % 10)) -eq 0 ]; then
                status_bar $v_count $d_count $i_count $w_count $e_count $f_count $sec_count
            fi
        done
    elif [[ "$filter" == "performance" ]]; then
        $ADB logcat -v time 2>/dev/null | grep -iE "$PERF_KEYWORDS" | while IFS= read -r line; do
            format_log "$line"
            ((line_count++))
        done
    else
        $ADB logcat -v time $filter 2>/dev/null | while IFS= read -r line; do
            format_log "$line"
            local ret=$?

            case $ret in
                1) ((v_count++)) ;;
                2) ((d_count++)) ;;
                3) ((i_count++)) ;;
                4) ((w_count++)) ;;
                5) ((e_count++)) ;;
                6) ((f_count++)) ;;
                7) ((sec_count++)) ;;
            esac

            ((line_count++))

            # Update status every 20 lines
            if [ $((line_count % 20)) -eq 0 ]; then
                status_bar $v_count $d_count $i_count $w_count $e_count $f_count $sec_count
            fi
        done
    fi
}

main() {
    # Check ADB
    if ! [ -x "$ADB" ]; then
        echo -e "${RED}ADB not found at $ADB${NC}"
        exit 1
    fi

    # Check device
    if ! $ADB devices | grep -q "device$"; then
        banner
        echo -e "  ${RED}No device connected!${NC}"
        echo -e "  ${DIM}Connect a device and enable USB debugging${NC}"
        echo -e "\n  Press any key to retry..."
        read -n 1 -s
        main
        return
    fi

    banner
    local filter=$(select_mode)

    # Clear logcat buffer first
    echo -e "\n  ${DIM}Clearing old logs...${NC}"
    $ADB logcat -c 2>/dev/null

    run_opera "$filter"
}

trap 'echo -e "\n\n${GREEN}  Opera concluded. Stay tuned for the next performance.${NC}\n"; exit 0' INT

main

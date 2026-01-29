#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# APK DEEP SCANNER - Security Analysis Suite
# "We don't just scan apps, we interrogate them"
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

ADB="${HOME}/Downloads/platform-tools/adb"

# Dangerous permissions that deserve scrutiny
DANGEROUS_PERMS=(
    "android.permission.READ_SMS"
    "android.permission.SEND_SMS"
    "android.permission.RECEIVE_SMS"
    "android.permission.READ_CONTACTS"
    "android.permission.WRITE_CONTACTS"
    "android.permission.READ_CALL_LOG"
    "android.permission.WRITE_CALL_LOG"
    "android.permission.CAMERA"
    "android.permission.RECORD_AUDIO"
    "android.permission.ACCESS_FINE_LOCATION"
    "android.permission.ACCESS_COARSE_LOCATION"
    "android.permission.ACCESS_BACKGROUND_LOCATION"
    "android.permission.READ_EXTERNAL_STORAGE"
    "android.permission.WRITE_EXTERNAL_STORAGE"
    "android.permission.READ_PHONE_STATE"
    "android.permission.CALL_PHONE"
    "android.permission.PROCESS_OUTGOING_CALLS"
    "android.permission.SYSTEM_ALERT_WINDOW"
    "android.permission.REQUEST_INSTALL_PACKAGES"
    "android.permission.BIND_ACCESSIBILITY_SERVICE"
    "android.permission.BIND_DEVICE_ADMIN"
    "android.permission.READ_CALENDAR"
    "android.permission.WRITE_CALENDAR"
    "android.permission.BODY_SENSORS"
    "android.permission.ACTIVITY_RECOGNITION"
    "android.permission.RECEIVE_BOOT_COMPLETED"
)

# Critical - often used by malware
CRITICAL_PERMS=(
    "android.permission.BIND_DEVICE_ADMIN"
    "android.permission.BIND_ACCESSIBILITY_SERVICE"
    "android.permission.SYSTEM_ALERT_WINDOW"
    "android.permission.REQUEST_INSTALL_PACKAGES"
    "android.permission.WRITE_SECURE_SETTINGS"
    "android.permission.READ_LOGS"
    "android.permission.DUMP"
    "android.permission.PACKAGE_USAGE_STATS"
    "android.permission.MANAGE_EXTERNAL_STORAGE"
)

banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║     █████╗ ██████╗ ██╗  ██╗    ███████╗ ██████╗ █████╗ ███╗   ██╗        ║
    ║    ██╔══██╗██╔══██╗██║ ██╔╝    ██╔════╝██╔════╝██╔══██╗████╗  ██║        ║
    ║    ███████║██████╔╝█████╔╝     ███████╗██║     ███████║██╔██╗ ██║        ║
    ║    ██╔══██║██╔═══╝ ██╔═██╗     ╚════██║██║     ██╔══██║██║╚██╗██║        ║
    ║    ██║  ██║██║     ██║  ██╗    ███████║╚██████╗██║  ██║██║ ╚████║        ║
    ║    ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝    ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝        ║
    ║                                                                           ║
    ║              "Every APK has a story. Let's read it."                      ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

risk_meter() {
    local score=$1
    local max=100
    local filled=$((score / 5))
    local empty=$((20 - filled))

    echo -ne "    Risk Level: ["

    if [ $score -lt 30 ]; then
        echo -ne "${GREEN}"
    elif [ $score -lt 60 ]; then
        echo -ne "${YELLOW}"
    else
        echo -ne "${RED}"
    fi

    for ((i=0; i<filled; i++)); do echo -ne "█"; done
    echo -ne "${DIM}"
    for ((i=0; i<empty; i++)); do echo -ne "░"; done
    echo -e "${NC}] ${score}/100"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " ${CYAN}%c${NC}  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

analyze_permissions() {
    local pkg="$1"
    local risk_score=0
    local dangerous_count=0
    local critical_count=0

    echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${WHITE}  PERMISSION ANALYSIS${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    # Get all permissions for the package
    local perms=$($ADB shell dumpsys package "$pkg" 2>/dev/null | grep -A 500 "requested permissions:" | grep -B 500 "install permissions:" | grep "android.permission" | sed 's/.*android.permission/android.permission/' | tr -d ' ')

    if [ -z "$perms" ]; then
        echo -e "    ${DIM}No permissions found or package not installed${NC}"
        return 0
    fi

    echo -e "  ${CYAN}CRITICAL PERMISSIONS (High Risk):${NC}"
    echo -e "  ${DIM}─────────────────────────────────${NC}"

    for perm in "${CRITICAL_PERMS[@]}"; do
        if echo "$perms" | grep -q "$perm"; then
            echo -e "    ${BG_RED}${WHITE} !! ${NC} ${RED}$perm${NC}"
            ((critical_count++))
            ((risk_score+=15))
        fi
    done

    if [ $critical_count -eq 0 ]; then
        echo -e "    ${GREEN}None detected${NC}"
    fi

    echo -e "\n  ${YELLOW}DANGEROUS PERMISSIONS:${NC}"
    echo -e "  ${DIM}─────────────────────────────────${NC}"

    for perm in "${DANGEROUS_PERMS[@]}"; do
        if echo "$perms" | grep -q "$perm"; then
            # Skip if already counted as critical
            is_critical=0
            for crit in "${CRITICAL_PERMS[@]}"; do
                if [ "$perm" == "$crit" ]; then
                    is_critical=1
                    break
                fi
            done

            if [ $is_critical -eq 0 ]; then
                echo -e "    ${YELLOW}⚠${NC}  $perm"
                ((dangerous_count++))
                ((risk_score+=5))
            fi
        fi
    done

    if [ $dangerous_count -eq 0 ]; then
        echo -e "    ${GREEN}None detected${NC}"
    fi

    echo -e "\n  ${BLUE}OTHER PERMISSIONS:${NC}"
    echo -e "  ${DIM}─────────────────────────────────${NC}"

    local other_count=0
    while IFS= read -r perm; do
        # Check if it's not in dangerous or critical
        is_flagged=0
        for check in "${DANGEROUS_PERMS[@]}" "${CRITICAL_PERMS[@]}"; do
            if [ "$perm" == "$check" ]; then
                is_flagged=1
                break
            fi
        done

        if [ $is_flagged -eq 0 ] && [ -n "$perm" ]; then
            echo -e "    ${DIM}○${NC}  $perm"
            ((other_count++))
        fi
    done <<< "$perms"

    if [ $other_count -eq 0 ]; then
        echo -e "    ${DIM}None${NC}"
    fi

    # Cap risk score
    [ $risk_score -gt 100 ] && risk_score=100

    echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}THREAT ASSESSMENT${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    risk_meter $risk_score

    echo -e "\n    ${WHITE}Critical permissions:${NC} ${RED}$critical_count${NC}"
    echo -e "    ${WHITE}Dangerous permissions:${NC} ${YELLOW}$dangerous_count${NC}"
    echo -e "    ${WHITE}Total permissions:${NC} $((critical_count + dangerous_count + other_count))"

    return $risk_score
}

analyze_components() {
    local pkg="$1"

    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${WHITE}  COMPONENT ANALYSIS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    echo -e "  ${CYAN}ACTIVITIES (Entry Points):${NC}"
    local activities=$($ADB shell dumpsys package "$pkg" 2>/dev/null | grep -A 1000 "Activity Resolver Table:" | grep -B 1000 "Service Resolver Table:" | grep "$pkg" | head -10)
    if [ -n "$activities" ]; then
        echo "$activities" | while read -r line; do
            echo -e "    ${DIM}→${NC} $line"
        done
    else
        echo -e "    ${DIM}None found${NC}"
    fi

    echo -e "\n  ${CYAN}SERVICES (Background Processes):${NC}"
    local services=$($ADB shell dumpsys package "$pkg" 2>/dev/null | grep -A 500 "Service Resolver Table:" | grep -B 500 "Receiver Resolver Table:" | grep "$pkg" | head -10)
    if [ -n "$services" ]; then
        echo "$services" | while read -r line; do
            echo -e "    ${DIM}→${NC} $line"
        done
    else
        echo -e "    ${DIM}None found${NC}"
    fi

    echo -e "\n  ${CYAN}RECEIVERS (Event Listeners):${NC}"
    local receivers=$($ADB shell dumpsys package "$pkg" 2>/dev/null | grep -A 500 "Receiver Resolver Table:" | grep "$pkg" | head -10)
    if [ -n "$receivers" ]; then
        echo "$receivers" | while read -r line; do
            # Highlight boot receivers
            if echo "$line" | grep -qi "boot"; then
                echo -e "    ${YELLOW}⚠${NC} $line ${YELLOW}(BOOT RECEIVER)${NC}"
            else
                echo -e "    ${DIM}→${NC} $line"
            fi
        done
    else
        echo -e "    ${DIM}None found${NC}"
    fi
}

analyze_network() {
    local pkg="$1"

    echo -e "\n${GREEN}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${WHITE}  NETWORK ACTIVITY${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    local uid=$($ADB shell dumpsys package "$pkg" 2>/dev/null | grep "userId=" | head -1 | sed 's/.*userId=//' | tr -d ' ')

    if [ -n "$uid" ]; then
        echo -e "  ${CYAN}App UID:${NC} $uid"
        echo -e "\n  ${CYAN}Network Stats:${NC}"
        $ADB shell cat /proc/net/xt_qtaguid/stats 2>/dev/null | grep "$uid" | head -5 | while read -r line; do
            echo -e "    ${DIM}→${NC} $line"
        done
    fi

    echo -e "\n  ${CYAN}Active Connections (if app running):${NC}"
    $ADB shell "netstat -anp 2>/dev/null | grep -i $pkg" | head -10 | while read -r line; do
        echo -e "    ${DIM}→${NC} $line"
    done
}

main_menu() {
    banner

    echo -e "  ${BOLD}Select scan mode:${NC}\n"
    echo -e "    ${GREEN}1)${NC} Scan installed package by name"
    echo -e "    ${GREEN}2)${NC} List all installed packages"
    echo -e "    ${GREEN}3)${NC} Scan all third-party apps"
    echo -e "    ${GREEN}4)${NC} Export full report"
    echo -e "    ${RED}q)${NC} Quit\n"

    echo -ne "  ${CYAN}Choice:${NC} "
    read -r choice

    case $choice in
        1)
            echo -ne "\n  ${CYAN}Enter package name:${NC} "
            read -r pkg
            if [ -n "$pkg" ]; then
                full_scan "$pkg"
            fi
            ;;
        2)
            list_packages
            ;;
        3)
            scan_all_third_party
            ;;
        4)
            export_report
            ;;
        q|Q)
            echo -e "\n  ${GREEN}Stay vigilant.${NC}\n"
            exit 0
            ;;
        *)
            echo -e "\n  ${RED}Invalid choice${NC}"
            ;;
    esac

    echo -e "\n  ${DIM}Press any key to continue...${NC}"
    read -n 1 -s
    main_menu
}

full_scan() {
    local pkg="$1"

    clear
    echo -e "\n${BOLD}${WHITE}  Scanning: ${CYAN}$pkg${NC}\n"

    # Check if device connected
    if ! $ADB devices | grep -q "device$"; then
        echo -e "  ${RED}No device connected!${NC}"
        echo -e "  ${DIM}Connect a device and enable USB debugging${NC}"
        return
    fi

    # Check if package exists
    if ! $ADB shell pm list packages | grep -q "$pkg"; then
        echo -e "  ${RED}Package not found on device${NC}"
        return
    fi

    # Get basic info
    echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${WHITE}  PACKAGE INFO${NC}"
    echo -e "${WHITE}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    local version=$($ADB shell dumpsys package "$pkg" | grep "versionName=" | head -1 | sed 's/.*versionName=//')
    local install_time=$($ADB shell dumpsys package "$pkg" | grep "firstInstallTime=" | head -1 | sed 's/.*firstInstallTime=//')
    local update_time=$($ADB shell dumpsys package "$pkg" | grep "lastUpdateTime=" | head -1 | sed 's/.*lastUpdateTime=//')
    local installer=$($ADB shell pm get-install-location "$pkg" 2>/dev/null)

    echo -e "  ${CYAN}Package:${NC}     $pkg"
    echo -e "  ${CYAN}Version:${NC}     $version"
    echo -e "  ${CYAN}Installed:${NC}   $install_time"
    echo -e "  ${CYAN}Updated:${NC}     $update_time"

    # Run analyses
    analyze_permissions "$pkg"
    analyze_components "$pkg"
    analyze_network "$pkg"

    echo -e "\n${GREEN}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}Scan complete for: ${CYAN}$pkg${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════${NC}\n"
}

list_packages() {
    clear
    echo -e "\n${BOLD}${WHITE}  All Third-Party Packages:${NC}\n"

    $ADB shell pm list packages -3 2>/dev/null | sed 's/package://' | sort | while read -r pkg; do
        echo -e "    ${DIM}→${NC} $pkg"
    done
}

scan_all_third_party() {
    clear
    echo -e "\n${BOLD}${WHITE}  Scanning all third-party apps...${NC}\n"

    local count=0
    local high_risk=0

    for pkg in $($ADB shell pm list packages -3 2>/dev/null | sed 's/package://'); do
        ((count++))
        echo -e "\n  ${CYAN}[$count]${NC} Analyzing: $pkg"

        # Quick permission check
        local crit=0
        for perm in "${CRITICAL_PERMS[@]}"; do
            if $ADB shell dumpsys package "$pkg" 2>/dev/null | grep -q "$perm"; then
                ((crit++))
            fi
        done

        if [ $crit -gt 0 ]; then
            echo -e "      ${RED}⚠ HIGH RISK: $crit critical permission(s)${NC}"
            ((high_risk++))
        else
            echo -e "      ${GREEN}✓ Low risk${NC}"
        fi
    done

    echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}SUMMARY${NC}"
    echo -e "  Total apps scanned: $count"
    echo -e "  High risk apps: ${RED}$high_risk${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}"
}

export_report() {
    local report_dir="$HOME/apk_reports"
    mkdir -p "$report_dir"
    local report_file="$report_dir/security_report_$(date +%Y%m%d_%H%M%S).txt"

    echo -e "\n${BOLD}${WHITE}  Generating comprehensive report...${NC}\n"

    {
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo "  APK SECURITY REPORT"
        echo "  Generated: $(date)"
        echo "  Device: $($ADB shell getprop ro.product.model 2>/dev/null)"
        echo "  Android: $($ADB shell getprop ro.build.version.release 2>/dev/null)"
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo ""

        for pkg in $($ADB shell pm list packages -3 2>/dev/null | sed 's/package://'); do
            echo "───────────────────────────────────────────────────────────────────────────"
            echo "Package: $pkg"
            echo ""
            echo "Permissions:"
            $ADB shell dumpsys package "$pkg" 2>/dev/null | grep "android.permission" | sort -u
            echo ""
        done
    } > "$report_file"

    echo -e "  ${GREEN}Report saved to:${NC} $report_file"
}

# Check ADB
if ! [ -x "$ADB" ]; then
    echo -e "${RED}ADB not found at $ADB${NC}"
    echo -e "${YELLOW}Please install Android platform-tools${NC}"
    exit 1
fi

main_menu

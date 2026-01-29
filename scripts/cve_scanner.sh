#!/bin/zsh
# ═══════════════════════════════════════════════════════════════════════════════
# ANDROID CVE VULNERABILITY SCANNER
# "Know what they know about your device"
#
# Cross-references device info against known CVEs and security bulletins
# Sources: Android Security Bulletins, CISA KEV, NVD, Qualcomm/MediaTek advisories
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
LOG_DIR="$HOME/.config/kitty/cyber-fortress/logs"
CVE_DB="$HOME/.config/kitty/cyber-fortress/cve-db"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/cve_scan_$TIMESTAMP.json"

mkdir -p "$LOG_DIR" "$CVE_DB"

# ═══════════════════════════════════════════════════════════════════════════════
# CRITICAL CVEs BY SECURITY PATCH LEVEL
# These are actively exploited or high-severity vulnerabilities
# Last updated: 2025-05 (Update regularly from Android Security Bulletins)
# ═══════════════════════════════════════════════════════════════════════════════

declare -A CRITICAL_CVES

# 2024 Critical CVEs (add more as discovered)
CRITICAL_CVES["2024-01"]="CVE-2023-40088:RCE in System:Critical|CVE-2023-40077:EoP in Framework:High|CVE-2023-45866:Bluetooth RCE:Critical"
CRITICAL_CVES["2024-02"]="CVE-2024-0031:RCE in System:Critical|CVE-2024-0014:EoP in Framework:High"
CRITICAL_CVES["2024-03"]="CVE-2024-0039:RCE in System:Critical|CVE-2024-23717:EoP Pixel:High"
CRITICAL_CVES["2024-04"]="CVE-2024-23704:EoP in System:High|CVE-2024-23705:ID in Framework:High"
CRITICAL_CVES["2024-05"]="CVE-2024-23706:EoP in System:High|CVE-2024-0024:RCE in System:Critical"
CRITICAL_CVES["2024-06"]="CVE-2024-29745:ID Pixel Bootloader:High|CVE-2024-29748:EoP Pixel:High"
CRITICAL_CVES["2024-07"]="CVE-2024-31320:EoP in Framework:Critical|CVE-2024-0044:EoP in System:High"
CRITICAL_CVES["2024-08"]="CVE-2024-32896:EoP Pixel:High (IN THE WILD)|CVE-2024-36971:Kernel Use-After-Free:High (IN THE WILD)"
CRITICAL_CVES["2024-09"]="CVE-2024-32896:EoP Pixel (continued):High|CVE-2024-40658:ID in Framework:High"
CRITICAL_CVES["2024-10"]="CVE-2024-40676:EoP in Framework:High|CVE-2024-43047:Qualcomm DSP:High"
CRITICAL_CVES["2024-11"]="CVE-2024-43093:EoP Framework (IN THE WILD):High|CVE-2024-43047:Qualcomm (IN THE WILD):High"
CRITICAL_CVES["2024-12"]="CVE-2024-43767:RCE in System:Critical|CVE-2024-43097:Imagination GPU:High"

# 2025 Critical CVEs
CRITICAL_CVES["2025-01"]="CVE-2024-49415:Samsung RCS Vuln:Critical|CVE-2024-53104:USB Video Class:High"
CRITICAL_CVES["2025-02"]="CVE-2024-53104:Linux Kernel (IN THE WILD):High|CVE-2025-0097:EoP Framework:High"
CRITICAL_CVES["2025-03"]="CVE-2024-50302:Kernel HID:High|CVE-2024-43093:Framework (continued):High"
CRITICAL_CVES["2025-04"]="CVE-2024-53197:ALSA USB Driver:High|CVE-2024-53150:ALSA USB:High"
CRITICAL_CVES["2025-05"]="CVE-2025-27363:FreeType (IN THE WILD):High|CVE-2025-22457:Kernel RCE:Critical"

# Actively exploited (CISA KEV) - These are in the wild
ACTIVELY_EXPLOITED=(
    "CVE-2024-32896"    # Pixel EoP
    "CVE-2024-36971"    # Kernel UAF
    "CVE-2024-43093"    # Framework EoP
    "CVE-2024-43047"    # Qualcomm DSP
    "CVE-2024-53104"    # Linux Kernel USB
    "CVE-2025-27363"    # FreeType
    "CVE-2023-45866"    # Bluetooth
    "CVE-2023-4863"     # libwebp (Chrome/Android)
    "CVE-2024-4671"     # Chrome V8
)

# Qualcomm-specific CVEs by chipset
declare -A QUALCOMM_CVES
QUALCOMM_CVES["snapdragon"]="CVE-2024-43047:DSP Service:High|CVE-2024-21473:WLAN:High|CVE-2024-33042:DSP:High"

# MediaTek-specific CVEs
declare -A MEDIATEK_CVES
MEDIATEK_CVES["mediatek"]="CVE-2024-20069:Modem:High|CVE-2024-20017:WLAN:Critical|CVE-2024-20104:Audio HAL:High"

# Samsung-specific CVEs
declare -A SAMSUNG_CVES
SAMSUNG_CVES["samsung"]="CVE-2024-49415:RCS Messaging:Critical|CVE-2024-34641:Theft Protection:High|CVE-2024-34610:Contacts:Medium"

banner() {
    clear
    echo -e "${RED}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════════════════════╗
    ║   ██████╗██╗   ██╗███████╗    ███████╗ ██████╗ █████╗ ███╗   ██╗             ║
    ║  ██╔════╝██║   ██║██╔════╝    ██╔════╝██╔════╝██╔══██╗████╗  ██║             ║
    ║  ██║     ██║   ██║█████╗      ███████╗██║     ███████║██╔██╗ ██║             ║
    ║  ██║     ╚██╗ ██╔╝██╔══╝      ╚════██║██║     ██╔══██║██║╚██╗██║             ║
    ║  ╚██████╗ ╚████╔╝ ███████╗    ███████║╚██████╗██║  ██║██║ ╚████║             ║
    ║   ╚═════╝  ╚═══╝  ╚══════╝    ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝             ║
    ║                                                                               ║
    ║              "Know what they know about your device"                          ║
    ║                                                                               ║
    ║  Sources: Android Security Bulletins | CISA KEV | NVD | Vendor Advisories    ║
    ╚═══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

section() {
    echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}${WHITE}$1${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}\n"
}

alert_critical() {
    echo -e "    ${BG_RED}${WHITE} CRITICAL ${NC} ${RED}$1${NC}"
}

alert_high() {
    echo -e "    ${YELLOW}[HIGH]${NC} ${YELLOW}$1${NC}"
}

alert_medium() {
    echo -e "    ${BLUE}[MEDIUM]${NC} $1"
}

alert_info() {
    echo -e "    ${CYAN}[INFO]${NC} $1"
}

alert_clean() {
    echo -e "    ${GREEN}[PATCHED]${NC} $1"
}

compare_dates() {
    # Returns 1 if date1 < date2, 0 otherwise
    local date1=$1  # Device patch
    local date2=$2  # CVE patch requirement

    local year1=${date1:0:4}
    local month1=${date1:5:2}
    local year2=${date2:0:4}
    local month2=${date2:5:2}

    if [ "$year1" -lt "$year2" ]; then
        return 1
    elif [ "$year1" -eq "$year2" ] && [ "$month1" -lt "$month2" ]; then
        return 1
    fi
    return 0
}

get_device_info() {
    section "DEVICE INFORMATION"

    DEVICE_MODEL=$($ADB shell getprop ro.product.model 2>/dev/null | tr -d '\r')
    DEVICE_BRAND=$($ADB shell getprop ro.product.brand 2>/dev/null | tr -d '\r')
    ANDROID_VERSION=$($ADB shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
    SDK_VERSION=$($ADB shell getprop ro.build.version.sdk 2>/dev/null | tr -d '\r')
    SECURITY_PATCH=$($ADB shell getprop ro.build.version.security_patch 2>/dev/null | tr -d '\r')
    KERNEL_VERSION=$($ADB shell uname -r 2>/dev/null | tr -d '\r')
    BUILD_ID=$($ADB shell getprop ro.build.id 2>/dev/null | tr -d '\r')

    # Chipset info
    HARDWARE=$($ADB shell getprop ro.hardware 2>/dev/null | tr -d '\r')
    SOC=$($ADB shell getprop ro.board.platform 2>/dev/null | tr -d '\r')

    echo -e "  ${CYAN}Device:${NC}          $DEVICE_BRAND $DEVICE_MODEL"
    echo -e "  ${CYAN}Android:${NC}         $ANDROID_VERSION (SDK $SDK_VERSION)"
    echo -e "  ${CYAN}Security Patch:${NC}  $SECURITY_PATCH"
    echo -e "  ${CYAN}Kernel:${NC}          $KERNEL_VERSION"
    echo -e "  ${CYAN}Build ID:${NC}        $BUILD_ID"
    echo -e "  ${CYAN}Hardware:${NC}        $HARDWARE"
    echo -e "  ${CYAN}SoC Platform:${NC}    $SOC"

    # Calculate patch age
    CURRENT_DATE=$(date +%Y-%m)
    PATCH_YEAR=${SECURITY_PATCH:0:4}
    PATCH_MONTH=${SECURITY_PATCH:5:2}
    CURRENT_YEAR=$(date +%Y)
    CURRENT_MONTH=$(date +%m)

    MONTHS_BEHIND=$(( (CURRENT_YEAR - PATCH_YEAR) * 12 + (10#$CURRENT_MONTH - 10#$PATCH_MONTH) ))

    echo ""
    if [ $MONTHS_BEHIND -le 1 ]; then
        echo -e "  ${GREEN}Patch Status: CURRENT (${MONTHS_BEHIND} month(s) old)${NC}"
    elif [ $MONTHS_BEHIND -le 3 ]; then
        echo -e "  ${YELLOW}Patch Status: SLIGHTLY OUTDATED (${MONTHS_BEHIND} months old)${NC}"
    elif [ $MONTHS_BEHIND -le 6 ]; then
        echo -e "  ${YELLOW}Patch Status: OUTDATED (${MONTHS_BEHIND} months old)${NC}"
    else
        echo -e "  ${RED}Patch Status: CRITICALLY OUTDATED (${MONTHS_BEHIND} months old)${NC}"
    fi

    # JSON logging
    echo "{" > "$LOG_FILE"
    echo "  \"scan_type\": \"cve_vulnerability\"," >> "$LOG_FILE"
    echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"," >> "$LOG_FILE"
    echo "  \"device\": {" >> "$LOG_FILE"
    echo "    \"model\": \"$DEVICE_MODEL\"," >> "$LOG_FILE"
    echo "    \"brand\": \"$DEVICE_BRAND\"," >> "$LOG_FILE"
    echo "    \"android_version\": \"$ANDROID_VERSION\"," >> "$LOG_FILE"
    echo "    \"sdk\": \"$SDK_VERSION\"," >> "$LOG_FILE"
    echo "    \"security_patch\": \"$SECURITY_PATCH\"," >> "$LOG_FILE"
    echo "    \"kernel\": \"$KERNEL_VERSION\"," >> "$LOG_FILE"
    echo "    \"soc\": \"$SOC\"," >> "$LOG_FILE"
    echo "    \"months_behind_patch\": $MONTHS_BEHIND" >> "$LOG_FILE"
    echo "  }," >> "$LOG_FILE"
    echo "  \"vulnerabilities\": [" >> "$LOG_FILE"
}

scan_actively_exploited() {
    section "ACTIVELY EXPLOITED VULNERABILITIES (IN THE WILD)"

    echo -e "  ${DIM}These CVEs have confirmed active exploitation${NC}\n"

    local found=0

    for cve in "${ACTIVELY_EXPLOITED[@]}"; do
        # Check which month this CVE was patched
        for patch_date in "${!CRITICAL_CVES[@]}"; do
            if echo "${CRITICAL_CVES[$patch_date]}" | grep -q "$cve"; then
                # Compare device patch to required patch
                if ! compare_dates "$SECURITY_PATCH" "$patch_date-01"; then
                    alert_critical "$cve - ACTIVELY EXPLOITED - Requires patch: $patch_date"

                    # Get description
                    local desc=$(echo "${CRITICAL_CVES[$patch_date]}" | grep -oP "$cve:[^|]+" | cut -d: -f2)
                    echo -e "      ${DIM}Description: $desc${NC}"
                    echo -e "      ${RED}This vulnerability is being actively exploited in the wild!${NC}"

                    echo "    {\"cve\": \"$cve\", \"status\": \"vulnerable\", \"actively_exploited\": true, \"required_patch\": \"$patch_date\", \"description\": \"$desc\"}," >> "$LOG_FILE"
                    ((found++))
                fi
                break
            fi
        done
    done

    if [ $found -eq 0 ]; then
        alert_clean "Device is patched against all known actively exploited vulnerabilities"
    else
        echo -e "\n    ${BG_RED}${WHITE} URGENT: $found actively exploited CVE(s) affect this device ${NC}"
    fi
}

scan_monthly_cves() {
    section "SECURITY BULLETIN CVE ANALYSIS"

    echo -e "  ${DIM}Checking CVEs from monthly Android Security Bulletins${NC}\n"

    local total_vulnerable=0
    local critical_count=0
    local high_count=0

    # Check all months from current backwards
    for patch_date in $(echo "${!CRITICAL_CVES[@]}" | tr ' ' '\n' | sort -r); do
        if ! compare_dates "$SECURITY_PATCH" "$patch_date-01"; then
            # Device is vulnerable to this month's CVEs
            echo -e "  ${YELLOW}Vulnerable to $patch_date bulletin:${NC}"

            IFS='|' read -ra CVES <<< "${CRITICAL_CVES[$patch_date]}"
            for cve_entry in "${CVES[@]}"; do
                local cve=$(echo "$cve_entry" | cut -d: -f1)
                local desc=$(echo "$cve_entry" | cut -d: -f2)
                local severity=$(echo "$cve_entry" | cut -d: -f3)

                if [ "$severity" == "Critical" ]; then
                    alert_critical "$cve: $desc"
                    ((critical_count++))
                else
                    alert_high "$cve: $desc"
                    ((high_count++))
                fi

                echo "    {\"cve\": \"$cve\", \"status\": \"vulnerable\", \"severity\": \"$severity\", \"description\": \"$desc\", \"bulletin\": \"$patch_date\"}," >> "$LOG_FILE"
                ((total_vulnerable++))
            done
            echo ""
        fi
    done

    if [ $total_vulnerable -eq 0 ]; then
        alert_clean "Device is current on monthly security bulletins"
    else
        echo -e "  ${WHITE}Summary:${NC}"
        echo -e "    ${RED}Critical: $critical_count${NC}"
        echo -e "    ${YELLOW}High: $high_count${NC}"
        echo -e "    ${WHITE}Total unpatched: $total_vulnerable${NC}"
    fi
}

scan_vendor_cves() {
    section "VENDOR-SPECIFIC VULNERABILITIES"

    local brand_lower=$(echo "$DEVICE_BRAND" | tr '[:upper:]' '[:lower:]')
    local soc_lower=$(echo "$SOC" | tr '[:upper:]' '[:lower:]')

    # Samsung
    if echo "$brand_lower" | grep -qi "samsung"; then
        echo -e "  ${CYAN}Samsung-specific CVEs:${NC}\n"

        IFS='|' read -ra CVES <<< "${SAMSUNG_CVES[samsung]}"
        for cve_entry in "${CVES[@]}"; do
            local cve=$(echo "$cve_entry" | cut -d: -f1)
            local desc=$(echo "$cve_entry" | cut -d: -f2)
            local severity=$(echo "$cve_entry" | cut -d: -f3)

            alert_high "$cve: $desc ($severity)"
            echo "    {\"cve\": \"$cve\", \"vendor\": \"samsung\", \"description\": \"$desc\", \"severity\": \"$severity\"}," >> "$LOG_FILE"
        done
    fi

    # Qualcomm
    if echo "$soc_lower $HARDWARE" | grep -qiE "qualcomm|qcom|sdm|sm[0-9]|msm"; then
        echo -e "\n  ${CYAN}Qualcomm chipset CVEs:${NC}\n"

        IFS='|' read -ra CVES <<< "${QUALCOMM_CVES[snapdragon]}"
        for cve_entry in "${CVES[@]}"; do
            local cve=$(echo "$cve_entry" | cut -d: -f1)
            local desc=$(echo "$cve_entry" | cut -d: -f2)
            local severity=$(echo "$cve_entry" | cut -d: -f3)

            alert_high "$cve: $desc ($severity)"
            echo "    {\"cve\": \"$cve\", \"vendor\": \"qualcomm\", \"description\": \"$desc\", \"severity\": \"$severity\"}," >> "$LOG_FILE"
        done
    fi

    # MediaTek
    if echo "$soc_lower $HARDWARE" | grep -qiE "mediatek|mtk|mt[0-9]"; then
        echo -e "\n  ${CYAN}MediaTek chipset CVEs:${NC}\n"

        IFS='|' read -ra CVES <<< "${MEDIATEK_CVES[mediatek]}"
        for cve_entry in "${CVES[@]}"; do
            local cve=$(echo "$cve_entry" | cut -d: -f1)
            local desc=$(echo "$cve_entry" | cut -d: -f2)
            local severity=$(echo "$cve_entry" | cut -d: -f3)

            alert_high "$cve: $desc ($severity)"
            echo "    {\"cve\": \"$cve\", \"vendor\": \"mediatek\", \"description\": \"$desc\", \"severity\": \"$severity\"}," >> "$LOG_FILE"
        done
    fi
}

scan_kernel_cves() {
    section "KERNEL VULNERABILITY ANALYSIS"

    echo -e "  ${CYAN}Kernel Version:${NC} $KERNEL_VERSION\n"

    # Common kernel vulnerabilities by version
    local kernel_major=$(echo "$KERNEL_VERSION" | cut -d. -f1)
    local kernel_minor=$(echo "$KERNEL_VERSION" | cut -d. -f2)

    echo -e "  ${DIM}Checking for known kernel vulnerabilities...${NC}\n"

    # Check for specific kernel CVEs
    if [ "$kernel_major" -lt 5 ]; then
        alert_critical "Kernel $kernel_major.x is end-of-life - many unpatched CVEs"
        echo "    {\"cve\": \"KERNEL-EOL\", \"description\": \"Kernel version end of life\", \"severity\": \"critical\"}," >> "$LOG_FILE"
    elif [ "$kernel_major" -eq 5 ] && [ "$kernel_minor" -lt 10 ]; then
        alert_high "Kernel 5.$kernel_minor may be missing recent security patches"
    fi

    # Dirty Pipe check (CVE-2022-0847) - affects 5.8+
    if [ "$kernel_major" -eq 5 ] && [ "$kernel_minor" -ge 8 ]; then
        # Check if patched (rough heuristic based on build date)
        if [ "$MONTHS_BEHIND" -gt 24 ]; then
            alert_critical "CVE-2022-0847 (Dirty Pipe) - Kernel privilege escalation"
        fi
    fi

    # Recent kernel CVEs (2024-2025)
    if [ "$MONTHS_BEHIND" -gt 3 ]; then
        alert_high "CVE-2024-53104 - Linux Kernel USB Video Class vulnerability"
        alert_high "CVE-2024-36971 - Kernel Use-After-Free (actively exploited)"
        echo "    {\"cve\": \"CVE-2024-53104\", \"type\": \"kernel\", \"severity\": \"high\"}," >> "$LOG_FILE"
        echo "    {\"cve\": \"CVE-2024-36971\", \"type\": \"kernel\", \"severity\": \"high\", \"actively_exploited\": true}," >> "$LOG_FILE"
    fi
}

check_component_versions() {
    section "COMPONENT VERSION ANALYSIS"

    echo -e "  ${DIM}Checking versions of security-critical components...${NC}\n"

    # WebView version (critical for browser-based attacks)
    local webview=$($ADB shell dumpsys webviewupdate 2>/dev/null | grep "Current WebView package")
    if [ -n "$webview" ]; then
        echo -e "  ${CYAN}WebView:${NC} $webview"
    fi

    # Chrome version
    local chrome_ver=$($ADB shell dumpsys package com.android.chrome 2>/dev/null | grep "versionName" | head -1)
    if [ -n "$chrome_ver" ]; then
        echo -e "  ${CYAN}Chrome:${NC} $chrome_ver"
    fi

    # Play Services version
    local gms=$($ADB shell dumpsys package com.google.android.gms 2>/dev/null | grep "versionName" | head -1)
    if [ -n "$gms" ]; then
        echo -e "  ${CYAN}Play Services:${NC} $gms"
    fi

    # Bluetooth version/state
    local bt=$($ADB shell dumpsys bluetooth_manager 2>/dev/null | grep "version" | head -1)
    if [ -n "$bt" ]; then
        echo -e "  ${CYAN}Bluetooth:${NC} $bt"
    fi

    # Check for Bluetooth vulnerabilities (BLUFFS, etc.)
    if [ "$MONTHS_BEHIND" -gt 2 ]; then
        echo ""
        alert_high "CVE-2023-45866 - Bluetooth keystroke injection (requires patch 2024-01+)"
    fi
}

generate_summary() {
    section "VULNERABILITY SUMMARY"

    # Close JSON array
    echo "    {\"type\": \"scan_complete\"}" >> "$LOG_FILE"
    echo "  ]," >> "$LOG_FILE"

    # Add summary
    local total=$(grep -c '"cve":' "$LOG_FILE")
    local critical=$(grep -c '"severity": "critical"\|"severity": "Critical"' "$LOG_FILE")
    local actively_exploited=$(grep -c '"actively_exploited": true' "$LOG_FILE")

    echo "  \"summary\": {" >> "$LOG_FILE"
    echo "    \"total_vulnerabilities\": $total," >> "$LOG_FILE"
    echo "    \"critical\": $critical," >> "$LOG_FILE"
    echo "    \"actively_exploited\": $actively_exploited," >> "$LOG_FILE"
    echo "    \"months_behind_patches\": $MONTHS_BEHIND," >> "$LOG_FILE"
    echo "    \"recommendation\": \"$([ $MONTHS_BEHIND -gt 3 ] && echo "URGENT UPDATE REQUIRED" || echo "Keep device updated")\"" >> "$LOG_FILE"
    echo "  }" >> "$LOG_FILE"
    echo "}" >> "$LOG_FILE"

    echo -e "  ${WHITE}Total Potential Vulnerabilities:${NC} $total"
    echo -e "  ${RED}Critical:${NC} $critical"
    echo -e "  ${RED}Actively Exploited:${NC} $actively_exploited"
    echo -e "  ${YELLOW}Months Behind Patches:${NC} $MONTHS_BEHIND"

    echo -e "\n  ${CYAN}Report saved to:${NC}"
    echo -e "    $LOG_FILE"

    if [ $actively_exploited -gt 0 ]; then
        echo -e "\n  ${BG_RED}${WHITE} URGENT: Device vulnerable to actively exploited CVEs ${NC}"
        echo -e "  ${RED}These vulnerabilities are being used in real attacks.${NC}"
        echo -e "  ${RED}Update immediately or limit device exposure.${NC}"
    fi

    if [ $MONTHS_BEHIND -gt 6 ]; then
        echo -e "\n  ${YELLOW}RECOMMENDATION:${NC}"
        echo -e "  ${YELLOW}Device is significantly behind on security patches.${NC}"
        echo -e "  ${YELLOW}Consider: 1) System update 2) Custom ROM 3) Device replacement${NC}"
    fi
}

main() {
    banner

    if ! [ -x "$ADB" ]; then
        echo -e "  ${RED}ADB not found at $ADB${NC}"
        exit 1
    fi

    if ! $ADB devices | grep -q "device$"; then
        echo -e "  ${RED}No device connected!${NC}"
        exit 1
    fi

    echo -e "  ${GREEN}Starting CVE vulnerability scan...${NC}\n"

    get_device_info
    scan_actively_exploited
    scan_monthly_cves
    scan_vendor_cves
    scan_kernel_cves
    check_component_versions
    generate_summary

    echo -e "\n  ${DIM}Press any key to exit...${NC}"
    read -n 1 -s
}

main "$@"

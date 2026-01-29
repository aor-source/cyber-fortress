#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# ANDROID DEVICE SECURITY AUDIT
# "Trust, but verify. Then verify again."
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
REPORT_DIR="$HOME/device_audits"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║  ██████╗ ███████╗██╗   ██╗██╗ ██████╗███████╗     █████╗ ██╗   ██╗██████╗ ║
    ║  ██╔══██╗██╔════╝██║   ██║██║██╔════╝██╔════╝    ██╔══██╗██║   ██║██╔══██╗║
    ║  ██║  ██║█████╗  ██║   ██║██║██║     █████╗      ███████║██║   ██║██║  ██║║
    ║  ██║  ██║██╔══╝  ╚██╗ ██╔╝██║██║     ██╔══╝      ██╔══██║██║   ██║██║  ██║║
    ║  ██████╔╝███████╗ ╚████╔╝ ██║╚██████╗███████╗    ██║  ██║╚██████╔╝██████╔╝║
    ║  ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ║
    ║                                                                            ║
    ║              "Trust, but verify. Then verify again."                       ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

check_pass() {
    echo -e "    ${GREEN}[PASS]${NC} $1"
}

check_warn() {
    echo -e "    ${YELLOW}[WARN]${NC} $1"
}

check_fail() {
    echo -e "    ${RED}[FAIL]${NC} $1"
}

check_info() {
    echo -e "    ${BLUE}[INFO]${NC} $1"
}

section() {
    echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}${WHITE}$1${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}\n"
}

progress() {
    echo -ne "  ${DIM}Checking: $1...${NC}\r"
}

audit_device_info() {
    section "DEVICE INFORMATION"

    local model=$($ADB shell getprop ro.product.model 2>/dev/null)
    local brand=$($ADB shell getprop ro.product.brand 2>/dev/null)
    local android=$($ADB shell getprop ro.build.version.release 2>/dev/null)
    local sdk=$($ADB shell getprop ro.build.version.sdk 2>/dev/null)
    local security_patch=$($ADB shell getprop ro.build.version.security_patch 2>/dev/null)
    local build=$($ADB shell getprop ro.build.display.id 2>/dev/null)
    local serial=$($ADB shell getprop ro.serialno 2>/dev/null)
    local encryption=$($ADB shell getprop ro.crypto.state 2>/dev/null)

    check_info "Model: $brand $model"
    check_info "Android Version: $android (SDK $sdk)"
    check_info "Build: $build"
    check_info "Serial: $serial"

    # Security patch assessment
    if [ -n "$security_patch" ]; then
        local patch_year=$(echo "$security_patch" | cut -d'-' -f1)
        local patch_month=$(echo "$security_patch" | cut -d'-' -f2)
        local current_year=$(date +%Y)
        local current_month=$(date +%m)

        local months_old=$(( (current_year - patch_year) * 12 + (10#$current_month - 10#$patch_month) ))

        if [ $months_old -le 1 ]; then
            check_pass "Security Patch: $security_patch (Current)"
        elif [ $months_old -le 3 ]; then
            check_warn "Security Patch: $security_patch ($months_old months old)"
        else
            check_fail "Security Patch: $security_patch ($months_old months old - OUTDATED)"
        fi
    fi

    # Encryption check
    if [ "$encryption" == "encrypted" ]; then
        check_pass "Device Encryption: Enabled"
    else
        check_fail "Device Encryption: NOT ENABLED"
    fi
}

audit_root_status() {
    section "ROOT/BOOTLOADER STATUS"

    # Check for su binary
    progress "su binary"
    if $ADB shell "which su" 2>/dev/null | grep -q "su"; then
        check_fail "su binary found - Device may be rooted"
    else
        check_pass "No su binary found"
    fi

    # Check for common root apps
    progress "root apps"
    local root_apps=("com.topjohnwu.magisk" "eu.chainfire.supersu" "com.koushikdutta.superuser" "com.noshufou.android.su" "com.thirdparty.superuser")

    for app in "${root_apps[@]}"; do
        if $ADB shell pm list packages 2>/dev/null | grep -q "$app"; then
            check_fail "Root app found: $app"
        fi
    done

    # Check build type
    local build_type=$($ADB shell getprop ro.build.type 2>/dev/null)
    if [ "$build_type" == "user" ]; then
        check_pass "Build type: user (production)"
    else
        check_warn "Build type: $build_type (non-production)"
    fi

    # Check secure boot
    local secure_boot=$($ADB shell getprop ro.boot.verifiedbootstate 2>/dev/null)
    case "$secure_boot" in
        "green")
            check_pass "Verified Boot: Green (Locked, verified)"
            ;;
        "yellow")
            check_warn "Verified Boot: Yellow (Custom key)"
            ;;
        "orange")
            check_fail "Verified Boot: Orange (Unlocked bootloader)"
            ;;
        "red")
            check_fail "Verified Boot: Red (Verification failed)"
            ;;
        *)
            check_info "Verified Boot: Unknown ($secure_boot)"
            ;;
    esac
}

audit_debug_settings() {
    section "DEBUG & DEVELOPER SETTINGS"

    # USB debugging (obviously on if we're connected, but note it)
    check_warn "USB Debugging: Enabled (you're connected via ADB)"

    # ADB over network
    progress "ADB over network"
    local adb_wifi=$($ADB shell getprop service.adb.tcp.port 2>/dev/null)
    if [ -n "$adb_wifi" ] && [ "$adb_wifi" != "-1" ]; then
        check_fail "ADB over WiFi: Enabled on port $adb_wifi"
    else
        check_pass "ADB over WiFi: Disabled"
    fi

    # Mock locations
    progress "mock locations"
    local mock=$($ADB shell settings get secure mock_location 2>/dev/null)
    if [ "$mock" == "1" ]; then
        check_warn "Mock Locations: Enabled"
    else
        check_pass "Mock Locations: Disabled"
    fi

    # Stay awake while charging
    progress "stay awake"
    local stay_awake=$($ADB shell settings get global stay_on_while_plugged_in 2>/dev/null)
    if [ "$stay_awake" != "0" ]; then
        check_info "Stay Awake: Enabled (dev setting)"
    fi
}

audit_security_settings() {
    section "SECURITY SETTINGS"

    # Screen lock
    progress "screen lock"
    local lock_type=$($ADB shell settings get secure lockscreen.password_type 2>/dev/null)
    case "$lock_type" in
        "0"|"65536")
            check_fail "Screen Lock: None or Swipe only"
            ;;
        "131072")
            check_warn "Screen Lock: Pattern"
            ;;
        "196608"|"262144"|"327680")
            check_pass "Screen Lock: PIN or Password"
            ;;
        "393216"|"458752"|"524288")
            check_pass "Screen Lock: Strong (Password/Biometric)"
            ;;
        *)
            check_info "Screen Lock: Type $lock_type"
            ;;
    esac

    # Unknown sources
    progress "unknown sources"
    local unknown=$($ADB shell settings get secure install_non_market_apps 2>/dev/null)
    local unknown_global=$($ADB shell settings get global install_non_market_apps 2>/dev/null)
    if [ "$unknown" == "1" ] || [ "$unknown_global" == "1" ]; then
        check_fail "Unknown Sources: Enabled globally"
    else
        check_pass "Unknown Sources: Disabled globally"
    fi

    # Verify apps
    progress "verify apps"
    local verify=$($ADB shell settings get global package_verifier_enable 2>/dev/null)
    if [ "$verify" == "1" ]; then
        check_pass "App Verification: Enabled"
    else
        check_warn "App Verification: Disabled"
    fi

    # Location services
    progress "location"
    local location=$($ADB shell settings get secure location_mode 2>/dev/null)
    case "$location" in
        "0")
            check_info "Location Mode: Off"
            ;;
        "1")
            check_info "Location Mode: Sensors only"
            ;;
        "2")
            check_warn "Location Mode: Battery saving (network-based)"
            ;;
        "3")
            check_info "Location Mode: High accuracy"
            ;;
    esac
}

audit_installed_apps() {
    section "INSTALLED APPLICATIONS ANALYSIS"

    # Count apps
    local system_apps=$($ADB shell pm list packages -s 2>/dev/null | wc -l)
    local third_party=$($ADB shell pm list packages -3 2>/dev/null | wc -l)
    local disabled=$($ADB shell pm list packages -d 2>/dev/null | wc -l)

    check_info "System apps: $system_apps"
    check_info "Third-party apps: $third_party"
    check_info "Disabled apps: $disabled"

    # Check for potentially dangerous apps
    echo -e "\n  ${CYAN}Checking for potentially concerning apps...${NC}\n"

    # VPN apps (not necessarily bad, but noteworthy)
    local vpn_apps=$($ADB shell pm list packages 2>/dev/null | grep -iE "vpn|tunnel|proxy" | sed 's/package://')
    if [ -n "$vpn_apps" ]; then
        echo "$vpn_apps" | while read -r app; do
            check_info "VPN/Proxy app: $app"
        done
    fi

    # Remote access apps
    local remote_apps=$($ADB shell pm list packages 2>/dev/null | grep -iE "teamviewer|anydesk|remote|vnc|rdp" | sed 's/package://')
    if [ -n "$remote_apps" ]; then
        echo "$remote_apps" | while read -r app; do
            check_warn "Remote access app: $app"
        done
    fi

    # Sideloaded apps (installed from unknown sources)
    echo -e "\n  ${CYAN}Apps with install permission (can sideload):${NC}\n"
    $ADB shell pm list packages -i 2>/dev/null | grep -v "com.android.vending" | grep -v "com.google.android" | head -10 | while read -r line; do
        local pkg=$(echo "$line" | sed 's/package://' | cut -d'=' -f1)
        local installer=$(echo "$line" | cut -d'=' -f2)
        if [ "$installer" != "null" ] && [ "$installer" != "com.android.vending" ]; then
            check_info "$pkg (installer: $installer)"
        fi
    done
}

audit_network() {
    section "NETWORK CONFIGURATION"

    # WiFi state
    progress "wifi"
    local wifi=$($ADB shell settings get global wifi_on 2>/dev/null)
    if [ "$wifi" == "1" ]; then
        check_info "WiFi: Enabled"
        local ssid=$($ADB shell dumpsys wifi 2>/dev/null | grep "mWifiInfo" | grep -oP 'SSID: "[^"]*"' | head -1)
        if [ -n "$ssid" ]; then
            check_info "Connected to: $ssid"
        fi
    else
        check_info "WiFi: Disabled"
    fi

    # Bluetooth
    progress "bluetooth"
    local bt=$($ADB shell settings get global bluetooth_on 2>/dev/null)
    if [ "$bt" == "1" ]; then
        check_info "Bluetooth: Enabled"
    else
        check_info "Bluetooth: Disabled"
    fi

    # Airplane mode
    local airplane=$($ADB shell settings get global airplane_mode_on 2>/dev/null)
    if [ "$airplane" == "1" ]; then
        check_info "Airplane Mode: Enabled"
    fi

    # NFC
    progress "nfc"
    local nfc=$($ADB shell settings get global nfc_on 2>/dev/null)
    if [ "$nfc" == "1" ]; then
        check_info "NFC: Enabled"
    fi

    # Active connections
    echo -e "\n  ${CYAN}Active Network Connections:${NC}\n"
    $ADB shell netstat -an 2>/dev/null | grep "ESTABLISHED" | head -10 | while read -r line; do
        check_info "$line"
    done
}

audit_accessibility() {
    section "ACCESSIBILITY SERVICES"

    local enabled=$($ADB shell settings get secure enabled_accessibility_services 2>/dev/null)

    if [ -n "$enabled" ] && [ "$enabled" != "null" ]; then
        check_warn "Accessibility services are enabled:"
        echo "$enabled" | tr ':' '\n' | while read -r service; do
            if [ -n "$service" ]; then
                check_warn "  - $service"
            fi
        done
        echo ""
        echo -e "    ${DIM}Note: Accessibility services can read screen content,${NC}"
        echo -e "    ${DIM}intercept input, and perform actions. Verify these are trusted.${NC}"
    else
        check_pass "No accessibility services enabled"
    fi
}

audit_device_admin() {
    section "DEVICE ADMINISTRATORS"

    local admins=$($ADB shell dumpsys device_policy 2>/dev/null | grep "Admin" | head -10)

    if [ -n "$admins" ]; then
        echo -e "  ${CYAN}Registered Device Admins:${NC}\n"
        echo "$admins" | while read -r line; do
            check_info "$line"
        done
    else
        check_pass "No device administrators registered"
    fi
}

generate_report() {
    mkdir -p "$REPORT_DIR"
    local report="$REPORT_DIR/audit_$TIMESTAMP.txt"

    echo -e "\n${CYAN}Generating report...${NC}"

    {
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo "  ANDROID DEVICE SECURITY AUDIT REPORT"
        echo "  Generated: $(date)"
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo ""
        audit_device_info 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
        audit_root_status 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
        audit_debug_settings 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
        audit_security_settings 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
        audit_installed_apps 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
        audit_network 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
        audit_accessibility 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
        audit_device_admin 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
    } > "$report"

    echo -e "${GREEN}Report saved to:${NC} $report"
}

main() {
    clear
    banner

    # Check ADB
    if ! [ -x "$ADB" ]; then
        echo -e "  ${RED}ADB not found at $ADB${NC}"
        exit 1
    fi

    # Check device
    if ! $ADB devices | grep -q "device$"; then
        echo -e "  ${RED}No device connected!${NC}"
        echo -e "  ${DIM}Connect a device and enable USB debugging${NC}"
        exit 1
    fi

    echo -e "  ${GREEN}Device connected. Starting audit...${NC}\n"
    sleep 1

    audit_device_info
    audit_root_status
    audit_debug_settings
    audit_security_settings
    audit_installed_apps
    audit_network
    audit_accessibility
    audit_device_admin

    section "AUDIT COMPLETE"

    echo -e "  ${CYAN}Would you like to save this report? (y/n)${NC} "
    read -r save
    if [ "$save" == "y" ] || [ "$save" == "Y" ]; then
        generate_report
    fi

    echo -e "\n  ${DIM}Press any key to exit...${NC}"
    read -n 1 -s
}

main

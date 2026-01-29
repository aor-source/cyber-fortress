#!/bin/zsh
# ═══════════════════════════════════════════════════════════════════════════════
# MDM & SHADOW MDM SCANNER
# "Finding the watchers who watch you"
#
# Detects: Corporate MDM, Shadow MDM, Stalkerware, Spouseware,
#          Unauthorized Device Admins, Rogue Certificates
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
BG_GREEN='\033[42m'

ADB="${HOME}/Downloads/platform-tools/adb"
LOG_DIR="$HOME/.config/kitty/cyber-fortress/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/mdm_scan_$TIMESTAMP.json"

mkdir -p "$LOG_DIR"

# ═══════════════════════════════════════════════════════════════════════════════
# KNOWN STALKERWARE/SPOUSEWARE SIGNATURES
# Sources: Coalition Against Stalkerware, EFF, Lookout, Kaspersky research
# ═══════════════════════════════════════════════════════════════════════════════
STALKERWARE_PACKAGES=(
    # Commercial Stalkerware
    "com.mspy"
    "com.flexispy"
    "com.mobile.spy"
    "com.spyzie"
    "com.cocospy"
    "com.hoverwatch"
    "com.eyezy"
    "com.pctattetool"
    "com.xnspy"
    "com.spyera"
    "com.highstermobile"
    "com.phonesheriff"
    "com.teensafe"
    "com.mobiletracker"
    "com.cerberusapp"
    "com.thetruthspy"
    "com.spyfone"
    "com.copy9"
    "com.iKeyMonitor"
    "com.spymaster"
    "com.mobistealth"
    "com.spyic"
    "com.minspy"
    "com.spyine"
    "com.neatspy"
    "com.clickfree"
    "org.torproject.android"  # Note: Tor itself isn't malware but often bundled

    # Parental Control that can be abused
    "com.qustodio"
    "com.bark"
    "net.mydlink.lite"

    # Generic suspicious names
    "com.android.system.service"
    "com.android.system.manager"
    "com.android.system.update"
    "com.android.systemservice"
    "com.system.service"
    "com.google.android.gms.update"  # Fake Google
    "com.android.provider.settings"  # Fake system
    "com.android.settings.system"    # Fake system

    # Known RATs (Remote Access Trojans)
    "com.droidjack"
    "com.omnirat"
    "com.androrat"
    "com.spynote"
    "com.ahmyth"
)

# Known MDM Packages (Legitimate but noteworthy)
MDM_PACKAGES=(
    # Enterprise MDM
    "com.airwatch"
    "com.mobileiron"
    "com.good.gd"
    "com.microsoft.intune"
    "com.jamf"
    "com.vmware.hub"
    "com.citrix.Receiver"
    "com.citrix.mvpn"
    "com.soti.mobicontrol"
    "com.maas360"
    "com.blackberry.uem"
    "com.cisco.anyconnect"
    "com.cisco.meraki"
    "com.hexnode"
    "com.manageengine"
    "com.google.android.apps.work"
    "com.samsung.android.knox"
    "com.samsung.klmsagent"
    "com.samsung.android.mdm"

    # Apple-style Profiles (via 3rd party)
    "com.apple.configurator"
)

# Dangerous permission combinations that indicate surveillance
SURVEILLANCE_PERMS=(
    "android.permission.READ_SMS"
    "android.permission.RECEIVE_SMS"
    "android.permission.READ_CALL_LOG"
    "android.permission.PROCESS_OUTGOING_CALLS"
    "android.permission.RECORD_AUDIO"
    "android.permission.CAMERA"
    "android.permission.ACCESS_FINE_LOCATION"
    "android.permission.ACCESS_BACKGROUND_LOCATION"
    "android.permission.READ_CONTACTS"
    "android.permission.BIND_ACCESSIBILITY_SERVICE"
    "android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
    "android.permission.PACKAGE_USAGE_STATS"
    "android.permission.SYSTEM_ALERT_WINDOW"
)

banner() {
    clear
    echo -e "${RED}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════════════════════╗
    ║  ███╗   ███╗██████╗ ███╗   ███╗    ███████╗ ██████╗ █████╗ ███╗   ██╗        ║
    ║  ████╗ ████║██╔══██╗████╗ ████║    ██╔════╝██╔════╝██╔══██╗████╗  ██║        ║
    ║  ██╔████╔██║██║  ██║██╔████╔██║    ███████╗██║     ███████║██╔██╗ ██║        ║
    ║  ██║╚██╔╝██║██║  ██║██║╚██╔╝██║    ╚════██║██║     ██╔══██║██║╚██╗██║        ║
    ║  ██║ ╚═╝ ██║██████╔╝██║ ╚═╝ ██║    ███████║╚██████╗██║  ██║██║ ╚████║        ║
    ║  ╚═╝     ╚═╝╚═════╝ ╚═╝     ╚═╝    ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝        ║
    ║                                                                               ║
    ║           "Finding the watchers who watch you"                                ║
    ║                                                                               ║
    ║  Detects: MDM | Shadow MDM | Stalkerware | Spouseware | RATs                 ║
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

alert_warning() {
    echo -e "    ${BG_YELLOW}${WHITE} WARNING ${NC} ${YELLOW}$1${NC}"
}

alert_info() {
    echo -e "    ${BLUE}[INFO]${NC} $1"
}

alert_clean() {
    echo -e "    ${GREEN}[CLEAN]${NC} $1"
}

log_json() {
    echo "$1" >> "$LOG_FILE"
}

init_log() {
    echo "{" > "$LOG_FILE"
    echo "  \"scan_type\": \"mdm_shadow_mdm\"," >> "$LOG_FILE"
    echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"," >> "$LOG_FILE"
    echo "  \"device\": {" >> "$LOG_FILE"
    echo "    \"model\": \"$($ADB shell getprop ro.product.model 2>/dev/null | tr -d '\r')\"," >> "$LOG_FILE"
    echo "    \"android_version\": \"$($ADB shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')\"," >> "$LOG_FILE"
    echo "    \"security_patch\": \"$($ADB shell getprop ro.build.version.security_patch 2>/dev/null | tr -d '\r')\"" >> "$LOG_FILE"
    echo "  }," >> "$LOG_FILE"
    echo "  \"findings\": [" >> "$LOG_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SCAN FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

scan_device_admins() {
    section "DEVICE ADMINISTRATORS"

    local admins=$($ADB shell dumpsys device_policy 2>/dev/null)
    local admin_count=$(echo "$admins" | grep -c "Admin PackageInfo" || echo "0")

    echo -e "  ${CYAN}Registered Device Administrators: $admin_count${NC}\n"

    if [ "$admin_count" -gt 0 ]; then
        echo "$admins" | grep -A 5 "Admin PackageInfo" | while read -r line; do
            if echo "$line" | grep -q "name="; then
                local pkg=$(echo "$line" | grep -oP 'name=\K[^}]+' | cut -d'/' -f1)

                # Check if known stalkerware
                for stalker in "${STALKERWARE_PACKAGES[@]}"; do
                    if echo "$pkg" | grep -qi "$stalker"; then
                        alert_critical "STALKERWARE DEVICE ADMIN: $pkg"
                        log_json "    {\"type\": \"stalkerware_admin\", \"package\": \"$pkg\", \"severity\": \"critical\"},"
                        continue 2
                    fi
                done

                # Check if known MDM
                for mdm in "${MDM_PACKAGES[@]}"; do
                    if echo "$pkg" | grep -qi "$mdm"; then
                        alert_warning "MDM Device Admin: $pkg"
                        log_json "    {\"type\": \"mdm_admin\", \"package\": \"$pkg\", \"severity\": \"medium\"},"
                        continue 2
                    fi
                done

                # Unknown admin
                alert_info "Device Admin: $pkg"
            fi
        done
    else
        alert_clean "No device administrators found"
    fi

    # Check for Device Owner (strongest MDM control)
    local device_owner=$(echo "$admins" | grep "Device Owner")
    if [ -n "$device_owner" ]; then
        alert_critical "DEVICE OWNER DETECTED - Full device control enabled"
        echo -e "    ${DIM}$device_owner${NC}"
        log_json "    {\"type\": \"device_owner\", \"severity\": \"critical\"},"
    fi

    # Check for Profile Owner
    local profile_owner=$(echo "$admins" | grep "Profile Owner")
    if [ -n "$profile_owner" ]; then
        alert_warning "Work Profile Owner detected"
        echo -e "    ${DIM}$profile_owner${NC}"
    fi
}

scan_stalkerware() {
    section "STALKERWARE / SPYWARE SCAN"

    local installed=$($ADB shell pm list packages 2>/dev/null | sed 's/package://')
    local found_stalkerware=0

    echo -e "  ${CYAN}Scanning against ${#STALKERWARE_PACKAGES[@]} known stalkerware signatures...${NC}\n"

    for pkg in "${STALKERWARE_PACKAGES[@]}"; do
        if echo "$installed" | grep -qi "$pkg"; then
            alert_critical "STALKERWARE DETECTED: $pkg"

            # Get more info
            local installer=$($ADB shell pm get-install-location "$pkg" 2>/dev/null)
            local perms=$($ADB shell dumpsys package "$pkg" 2>/dev/null | grep "permission" | wc -l)

            echo -e "      ${DIM}Permissions: $perms${NC}"
            log_json "    {\"type\": \"stalkerware\", \"package\": \"$pkg\", \"permissions\": $perms, \"severity\": \"critical\"},"
            ((found_stalkerware++))
        fi
    done

    if [ $found_stalkerware -eq 0 ]; then
        alert_clean "No known stalkerware packages found"
    else
        echo -e "\n    ${RED}Found $found_stalkerware stalkerware package(s)!${NC}"
    fi

    # Check for hidden/system-disguised apps
    echo -e "\n  ${CYAN}Checking for hidden/disguised apps...${NC}\n"

    # Apps with no launcher icon but surveillance permissions
    for pkg in $installed; do
        local has_launcher=$($ADB shell pm dump "$pkg" 2>/dev/null | grep -c "android.intent.category.LAUNCHER")

        if [ "$has_launcher" -eq 0 ]; then
            # Check if it has surveillance permissions
            local perms=$($ADB shell dumpsys package "$pkg" 2>/dev/null)
            local surveillance_score=0

            for perm in "${SURVEILLANCE_PERMS[@]}"; do
                if echo "$perms" | grep -q "$perm"; then
                    ((surveillance_score++))
                fi
            done

            # High surveillance score + no launcher = suspicious
            if [ $surveillance_score -ge 5 ]; then
                alert_warning "Hidden app with $surveillance_score surveillance permissions: $pkg"
                log_json "    {\"type\": \"hidden_surveillance_app\", \"package\": \"$pkg\", \"surveillance_score\": $surveillance_score, \"severity\": \"high\"},"
            fi
        fi
    done
}

scan_mdm_profiles() {
    section "MDM PROFILES & CONFIGURATIONS"

    echo -e "  ${CYAN}Checking for MDM enrollment...${NC}\n"

    # Check managed accounts
    local managed=$($ADB shell dumpsys account 2>/dev/null | grep -i "managed\|work\|enterprise")
    if [ -n "$managed" ]; then
        alert_warning "Managed accounts detected:"
        echo "$managed" | head -5 | while read -r line; do
            echo -e "      ${DIM}$line${NC}"
        done
    fi

    # Check for work profile
    local work_profile=$($ADB shell pm list users 2>/dev/null | grep -i "work")
    if [ -n "$work_profile" ]; then
        alert_warning "Work Profile detected (MDM managed)"
        echo -e "      ${DIM}$work_profile${NC}"
    fi

    # Check restrictions
    echo -e "\n  ${CYAN}Checking device restrictions...${NC}\n"

    local restrictions=$($ADB shell dumpsys user 2>/dev/null | grep -A 20 "Restrictions:")
    if echo "$restrictions" | grep -q "true"; then
        alert_warning "Device restrictions are active:"
        echo "$restrictions" | grep "true" | while read -r line; do
            echo -e "      ${YELLOW}$line${NC}"
        done
    else
        alert_clean "No device restrictions detected"
    fi

    # Check for VPN always-on (MDM can force this)
    local vpn_always=$($ADB shell settings get secure always_on_vpn_app 2>/dev/null)
    if [ -n "$vpn_always" ] && [ "$vpn_always" != "null" ]; then
        alert_warning "Always-on VPN enforced: $vpn_always"
        log_json "    {\"type\": \"forced_vpn\", \"package\": \"$vpn_always\", \"severity\": \"medium\"},"
    fi
}

scan_certificates() {
    section "CERTIFICATE ANALYSIS"

    echo -e "  ${CYAN}Checking for injected CA certificates...${NC}\n"
    echo -e "  ${DIM}(Rogue CAs can intercept all HTTPS traffic)${NC}\n"

    # User-installed certificates
    local user_certs=$($ADB shell ls /data/misc/user/0/cacerts-added/ 2>/dev/null | wc -l)

    if [ "$user_certs" -gt 0 ]; then
        alert_critical "USER-INSTALLED CA CERTIFICATES FOUND: $user_certs"
        echo -e "      ${RED}These can intercept ALL encrypted traffic!${NC}"

        $ADB shell ls /data/misc/user/0/cacerts-added/ 2>/dev/null | while read -r cert; do
            echo -e "      ${DIM}Certificate: $cert${NC}"
        done

        log_json "    {\"type\": \"injected_ca_cert\", \"count\": $user_certs, \"severity\": \"critical\"},"
    else
        alert_clean "No user-installed CA certificates"
    fi

    # Check for certificate pinning bypass indicators
    local frida=$($ADB shell pm list packages 2>/dev/null | grep -i "frida\|xposed\|magisk")
    if [ -n "$frida" ]; then
        alert_warning "Certificate pinning bypass tools detected:"
        echo -e "      ${YELLOW}$frida${NC}"
    fi
}

scan_accessibility_services() {
    section "ACCESSIBILITY SERVICES (High-Risk)"

    echo -e "  ${DIM}Accessibility services can read all screen content,${NC}"
    echo -e "  ${DIM}intercept input, and perform actions as the user.${NC}\n"

    local enabled=$($ADB shell settings get secure enabled_accessibility_services 2>/dev/null)

    if [ -n "$enabled" ] && [ "$enabled" != "null" ]; then
        alert_warning "Accessibility services are ENABLED:"

        echo "$enabled" | tr ':' '\n' | while read -r service; do
            if [ -n "$service" ]; then
                local pkg=$(echo "$service" | cut -d'/' -f1)

                # Check if known stalkerware
                for stalker in "${STALKERWARE_PACKAGES[@]}"; do
                    if echo "$pkg" | grep -qi "$stalker"; then
                        alert_critical "STALKERWARE ACCESSIBILITY SERVICE: $pkg"
                        log_json "    {\"type\": \"stalkerware_accessibility\", \"package\": \"$pkg\", \"severity\": \"critical\"},"
                        continue 2
                    fi
                done

                alert_warning "  - $service"
            fi
        done
    else
        alert_clean "No accessibility services enabled"
    fi
}

scan_notification_listeners() {
    section "NOTIFICATION LISTENERS"

    echo -e "  ${DIM}Can read ALL notifications including messages, 2FA codes, etc.${NC}\n"

    local listeners=$($ADB shell settings get secure enabled_notification_listeners 2>/dev/null)

    if [ -n "$listeners" ] && [ "$listeners" != "null" ]; then
        alert_warning "Notification listeners are active:"

        echo "$listeners" | tr ':' '\n' | while read -r service; do
            if [ -n "$service" ]; then
                local pkg=$(echo "$service" | cut -d'/' -f1)

                for stalker in "${STALKERWARE_PACKAGES[@]}"; do
                    if echo "$pkg" | grep -qi "$stalker"; then
                        alert_critical "STALKERWARE NOTIFICATION ACCESS: $pkg"
                        log_json "    {\"type\": \"stalkerware_notification\", \"package\": \"$pkg\", \"severity\": \"critical\"},"
                        continue 2
                    fi
                done

                echo -e "      ${YELLOW}- $service${NC}"
            fi
        done
    else
        alert_clean "No notification listeners enabled"
    fi
}

scan_usage_stats_access() {
    section "USAGE STATS ACCESS"

    echo -e "  ${DIM}Can monitor which apps you use and when${NC}\n"

    local usage_apps=$($ADB shell appops query --mode allow --op USAGE_STATS 2>/dev/null)

    if [ -n "$usage_apps" ]; then
        alert_info "Apps with usage stats access:"
        echo "$usage_apps" | while read -r pkg; do
            if [ -n "$pkg" ]; then
                for stalker in "${STALKERWARE_PACKAGES[@]}"; do
                    if echo "$pkg" | grep -qi "$stalker"; then
                        alert_critical "STALKERWARE USAGE MONITORING: $pkg"
                        log_json "    {\"type\": \"stalkerware_usage\", \"package\": \"$pkg\", \"severity\": \"critical\"},"
                        continue 2
                    fi
                done
                echo -e "      ${DIM}- $pkg${NC}"
            fi
        done
    else
        alert_clean "No unusual usage stats access"
    fi
}

generate_summary() {
    section "SCAN SUMMARY"

    # Close JSON
    echo "    {\"type\": \"scan_complete\", \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}" >> "$LOG_FILE"
    echo "  ]" >> "$LOG_FILE"
    echo "}" >> "$LOG_FILE"

    local critical=$(grep -c '"severity": "critical"' "$LOG_FILE")
    local high=$(grep -c '"severity": "high"' "$LOG_FILE")
    local medium=$(grep -c '"severity": "medium"' "$LOG_FILE")

    echo -e "  ${WHITE}Findings:${NC}"
    echo -e "    ${RED}Critical: $critical${NC}"
    echo -e "    ${YELLOW}High: $high${NC}"
    echo -e "    ${BLUE}Medium: $medium${NC}"

    echo -e "\n  ${CYAN}Full report saved to:${NC}"
    echo -e "    $LOG_FILE"

    if [ "$critical" -gt 0 ]; then
        echo -e "\n  ${BG_RED}${WHITE} ACTION REQUIRED ${NC}"
        echo -e "  ${RED}Critical threats detected. Recommend immediate investigation.${NC}"
        echo -e "  ${RED}Consider factory reset if stalkerware confirmed.${NC}"
    fi
}

main() {
    banner

    # Check ADB
    if ! [ -x "$ADB" ]; then
        echo -e "  ${RED}ADB not found at $ADB${NC}"
        exit 1
    fi

    if ! $ADB devices | grep -q "device$"; then
        echo -e "  ${RED}No device connected!${NC}"
        exit 1
    fi

    echo -e "  ${GREEN}Device connected. Starting MDM/Stalkerware scan...${NC}\n"

    init_log

    scan_device_admins
    scan_stalkerware
    scan_mdm_profiles
    scan_certificates
    scan_accessibility_services
    scan_notification_listeners
    scan_usage_stats_access

    generate_summary

    echo -e "\n  ${DIM}Press any key to exit...${NC}"
    read -n 1 -s
}

main "$@"

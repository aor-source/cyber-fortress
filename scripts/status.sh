#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# SYSTEM STATUS DASHBOARD
# "Know your system, know yourself"
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

clear

echo -e "${CYAN}"
cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║   ███████╗████████╗ █████╗ ████████╗██╗   ██╗███████╗                      ║
    ║   ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██║   ██║██╔════╝                      ║
    ║   ███████╗   ██║   ███████║   ██║   ██║   ██║███████╗                      ║
    ║   ╚════██║   ██║   ██╔══██║   ██║   ██║   ██║╚════██║                      ║
    ║   ███████║   ██║   ██║  ██║   ██║   ╚██████╔╝███████║                      ║
    ║   ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚══════╝                      ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Local Mac Status
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "  ${BOLD}${WHITE}LOCAL SYSTEM (macOS)${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════${NC}\n"

# CPU
cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | tr -d '%')
echo -ne "  ${CYAN}CPU:${NC} "
if (( $(echo "$cpu_usage > 80" | bc -l 2>/dev/null || echo "0") )); then
    echo -e "${RED}$cpu_usage%${NC}"
elif (( $(echo "$cpu_usage > 50" | bc -l 2>/dev/null || echo "0") )); then
    echo -e "${YELLOW}$cpu_usage%${NC}"
else
    echo -e "${GREEN}${cpu_usage:-N/A}%${NC}"
fi

# Memory
mem_info=$(vm_stat | head -5)
pages_free=$(echo "$mem_info" | grep "Pages free" | awk '{print $3}' | tr -d '.')
pages_active=$(echo "$mem_info" | grep "Pages active" | awk '{print $3}' | tr -d '.')
# Rough calculation (page size 4096)
if [ -n "$pages_free" ] && [ -n "$pages_active" ]; then
    free_gb=$(echo "scale=1; $pages_free * 4096 / 1073741824" | bc 2>/dev/null || echo "N/A")
    echo -e "  ${CYAN}Free Memory:${NC} ${GREEN}${free_gb}GB${NC}"
else
    echo -e "  ${CYAN}Free Memory:${NC} ${DIM}N/A${NC}"
fi

# Disk
disk_usage=$(df -h / | tail -1 | awk '{print $5}')
disk_avail=$(df -h / | tail -1 | awk '{print $4}')
echo -e "  ${CYAN}Disk:${NC} $disk_usage used, ${GREEN}$disk_avail available${NC}"

# Network
active_interface=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
if [ -n "$active_interface" ]; then
    ip_addr=$(ipconfig getifaddr "$active_interface" 2>/dev/null)
    echo -e "  ${CYAN}Network:${NC} $active_interface - ${GREEN}$ip_addr${NC}"
fi

# Uptime
uptime_str=$(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
echo -e "  ${CYAN}Uptime:${NC} $uptime_str"

# ADB Status
echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "  ${BOLD}${WHITE}ADB STATUS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}\n"

if [ -x "$ADB" ]; then
    adb_version=$($ADB version | head -1)
    echo -e "  ${CYAN}ADB:${NC} ${GREEN}$adb_version${NC}"

    devices=$($ADB devices | grep -v "List" | grep "device$")
    if [ -n "$devices" ]; then
        echo -e "  ${CYAN}Devices:${NC}"
        echo "$devices" | while read -r line; do
            serial=$(echo "$line" | awk '{print $1}')
            model=$($ADB -s "$serial" shell getprop ro.product.model 2>/dev/null)
            echo -e "    ${GREEN}●${NC} $serial ($model)"
        done
    else
        echo -e "  ${CYAN}Devices:${NC} ${YELLOW}None connected${NC}"
    fi
else
    echo -e "  ${RED}ADB not found at $ADB${NC}"
fi

# Connected Android Device (if any)
if $ADB devices 2>/dev/null | grep -q "device$"; then
    echo -e "\n${GREEN}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}${WHITE}ANDROID DEVICE${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════${NC}\n"

    model=$($ADB shell getprop ro.product.model 2>/dev/null)
    android=$($ADB shell getprop ro.build.version.release 2>/dev/null)
    battery=$($ADB shell dumpsys battery 2>/dev/null | grep "level" | head -1 | awk '{print $2}')
    charging=$($ADB shell dumpsys battery 2>/dev/null | grep "AC powered" | awk '{print $3}')

    echo -e "  ${CYAN}Model:${NC} $model"
    echo -e "  ${CYAN}Android:${NC} $android"

    # Battery with color
    if [ -n "$battery" ]; then
        if [ "$battery" -gt 50 ]; then
            echo -ne "  ${CYAN}Battery:${NC} ${GREEN}$battery%${NC}"
        elif [ "$battery" -gt 20 ]; then
            echo -ne "  ${CYAN}Battery:${NC} ${YELLOW}$battery%${NC}"
        else
            echo -ne "  ${CYAN}Battery:${NC} ${RED}$battery%${NC}"
        fi

        if [ "$charging" == "true" ]; then
            echo -e " ${GREEN}⚡ Charging${NC}"
        else
            echo ""
        fi
    fi

    # Screen state
    screen=$($ADB shell dumpsys display 2>/dev/null | grep "mScreenState" | awk -F'=' '{print $2}')
    echo -e "  ${CYAN}Screen:${NC} $screen"

    # WiFi
    wifi_ssid=$($ADB shell dumpsys wifi 2>/dev/null | grep -oP 'SSID: "[^"]*"' | head -1)
    if [ -n "$wifi_ssid" ]; then
        echo -e "  ${CYAN}WiFi:${NC} $wifi_ssid"
    fi
fi

# Quick Actions
echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "  ${BOLD}${WHITE}QUICK REFERENCE${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════${NC}\n"

echo -e "  ${DIM}F1${NC}  Help        ${DIM}F4${NC}  Security Audit    ${DIM}F9${NC}  ADB Shell"
echo -e "  ${DIM}F2${NC}  APK Scan    ${DIM}F5${NC}  Permission Watch  ${DIM}F10${NC} This Status"
echo -e "  ${DIM}F3${NC}  Logcat      ${DIM}F6${NC}  Network Watch     ${DIM}F12${NC} Restart ADB"

echo -e "\n${DIM}  Press any key to close...${NC}"
read -n 1 -s

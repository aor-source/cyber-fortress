#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# CYBER FORTRESS COMMAND CENTER - Quick Reference
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

clear
echo -e "${RED}"
cat << 'EOF'
   ██████╗██╗   ██╗██████╗ ███████╗██████╗     ███████╗ ██████╗ ██████╗ ████████╗██████╗ ███████╗███████╗███████╗
  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗    ██╔════╝██╔═══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔════╝██╔════╝██╔════╝
  ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝    █████╗  ██║   ██║██████╔╝   ██║   ██████╔╝█████╗  ███████╗███████╗
  ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗    ██╔══╝  ██║   ██║██╔══██╗   ██║   ██╔══██╗██╔══╝  ╚════██║╚════██║
  ╚██████╗   ██║   ██████╔╝███████╗██║  ██║    ██║     ╚██████╔╝██║  ██║   ██║   ██║  ██║███████╗███████║███████║
   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
EOF
echo -e "${NC}"
echo ""

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}${WHITE}FUNCTION KEYS - ONE TOUCH POWER${NC}                                                           ${CYAN}║${NC}"
echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}F1${NC}   This help screen                    ${GREEN}F7${NC}   MDM/Shadow MDM/Stalkerware scan       ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}F2${NC}   APK Deep Security Scanner           ${GREEN}F8${NC}   CVE Vulnerability Scanner             ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}F3${NC}   Logcat Hip-Hop Opera (live)         ${GREEN}F9${NC}   Quick ADB shell to device             ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}F4${NC}   Full device security audit          ${GREEN}F10${NC}  System status dashboard               ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}F5${NC}   Real-time permission monitor        ${GREEN}F12${NC}  Emergency: Kill/restart ADB           ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}F6${NC}   Network traffic monitor                                                        ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║${NC}  ${BOLD}${WHITE}WINDOW MANAGEMENT${NC}                                                                          ${MAGENTA}║${NC}"
echo -e "${MAGENTA}╠═══════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${MAGENTA}║${NC}  ${YELLOW}Ctrl+Shift+\\${NC}    Vertical split             ${YELLOW}Ctrl+Shift+Z${NC}    Toggle fullscreen pane    ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║${NC}  ${YELLOW}Ctrl+Shift+-${NC}    Horizontal split           ${YELLOW}Ctrl+Shift+R${NC}    Resize window mode        ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║${NC}  ${YELLOW}Alt+Arrows${NC}      Navigate between panes     ${YELLOW}Ctrl+Shift+L${NC}    Cycle layouts             ${MAGENTA}║${NC}"
echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${BOLD}${WHITE}TABS${NC}                                                                                        ${BLUE}║${NC}"
echo -e "${BLUE}╠═══════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║${NC}  ${YELLOW}Ctrl+Shift+T${NC}    New tab                     ${YELLOW}Ctrl+Shift+,${NC}    Previous tab              ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}  ${YELLOW}Ctrl+Shift+Q${NC}    Close tab                   ${YELLOW}Ctrl+Shift+.${NC}    Next tab                  ${BLUE}║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║${NC}  ${BOLD}${WHITE}QUICK COMMANDS (type in terminal)${NC}                                                          ${RED}║${NC}"
echo -e "${RED}╠═══════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${RED}║${NC}  ${CYAN}apkscan${NC}       Full APK security analysis    ${CYAN}mdmscan${NC}    MDM/Stalkerware detection    ${RED}║${NC}"
echo -e "${RED}║${NC}  ${CYAN}logopera${NC}      Hip-hop logcat viewer         ${CYAN}cvescan${NC}    CVE vulnerability scan       ${RED}║${NC}"
echo -e "${RED}║${NC}  ${CYAN}devaudit${NC}      Full device security audit    ${CYAN}permwatch${NC}  Real-time permissions        ${RED}║${NC}"
echo -e "${RED}║${NC}  ${CYAN}netwatch${NC}      Network traffic monitor       ${CYAN}sysstatus${NC}  System dashboard             ${RED}║${NC}"
echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${DIM}Reload config: Ctrl+Shift+F5    |    Debug config: Ctrl+Shift+F6${NC}"
echo ""
echo -e "${WHITE}Press any key to close...${NC}"
read -n 1 -s

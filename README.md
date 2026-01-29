# Cyber Fortress - Android Security Audit Terminal Suite

> "The command line is mightier than the sword"

A comprehensive terminal-based Android security auditing toolkit built on Kitty terminal. Designed for security researchers, penetration testers, and privacy-conscious users who want deep visibility into Android device security posture.

## Research Context

This toolkit was developed to address the growing need for accessible, open-source Android security auditing tools that can:

1. **Detect unauthorized device management** - Including shadow MDM profiles that may be installed without user knowledge
2. **Analyze application permissions** - Identifying over-privileged apps and potential privacy violations
3. **Monitor real-time system behavior** - Through enhanced logcat analysis with threat categorization
4. **Scan for known vulnerabilities** - Cross-referencing device state against published CVEs
5. **Network traffic analysis** - Identifying suspicious connections and data exfiltration attempts

## Threat Model

This toolkit is designed to detect:

- **Corporate MDM Overreach**: Legitimate MDM with excessive permissions
- **Shadow MDM/Stalkerware**: Unauthorized device management profiles
- **Malicious Applications**: Apps with dangerous permission combinations
- **Persistence Mechanisms**: Boot receivers, accessibility services, device admins
- **Network-based Attacks**: Suspicious connections, unencrypted traffic, DNS hijacking
- **Unpatched Vulnerabilities**: Known CVEs affecting the device's Android version

## Installation

### Prerequisites

- macOS (tested on macOS 14+)
- [Kitty Terminal](https://sw.kovidgoyal.net/kitty/)
- [Homebrew](https://brew.sh/)
- Android Debug Bridge (ADB)

### Quick Install

```bash
# Install Kitty
brew install --cask kitty

# Install Nerd Fonts
brew install --cask font-jetbrains-mono-nerd-font

# Clone this repository
git clone https://github.com/YOUR_USERNAME/cyber-fortress.git ~/.config/kitty

# Make scripts executable
chmod +x ~/.config/kitty/scripts/*.sh

# Add aliases to your shell
cat >> ~/.zshrc << 'EOF'
export PATH="$HOME/.local/bin:$HOME/.config/kitty/scripts:$PATH"
export ADB="$HOME/Downloads/platform-tools/adb"
alias apkscan='~/.config/kitty/scripts/apk_scanner.sh'
alias logopera='~/.config/kitty/scripts/logcat_opera.sh'
alias devaudit='~/.config/kitty/scripts/device_audit.sh'
alias permwatch='~/.config/kitty/scripts/permission_watch.sh'
alias netwatch='~/.config/kitty/scripts/netwatch.sh'
alias mdmscan='~/.config/kitty/scripts/mdm_scanner.sh'
alias cvescan='~/.config/kitty/scripts/cve_scanner.sh'
EOF

source ~/.zshrc
```

## Features

### Function Key Quick Access

| Key | Function | Description |
|-----|----------|-------------|
| F1 | Help | Command center quick reference |
| F2 | APK Scanner | Deep APK security analysis |
| F3 | Logcat Opera | Hip-hop styled real-time log analysis |
| F4 | Device Audit | Comprehensive security audit |
| F5 | Permission Watch | Real-time permission monitoring |
| F6 | Network Watch | Traffic analysis and monitoring |
| F7 | MDM Scanner | MDM and Shadow MDM detection |
| F8 | CVE Scanner | Known vulnerability detection |
| F9 | ADB Shell | Quick shell access |
| F10 | Status | System dashboard |

### MDM/Shadow MDM Detection

The MDM scanner checks for:

- **Legitimate MDM Profiles**: Corporate device management
- **Shadow MDM Indicators**: Unauthorized management profiles
- **Stalkerware Signatures**: Known surveillance applications
- **Device Administrator Abuse**: Excessive admin privileges
- **Certificate Injection**: Unauthorized CA certificates
- **Configuration Profiles**: Hidden management configurations

### CVE Scanning

Cross-references device information against:

- Android Security Bulletins
- Known exploited vulnerabilities (CISA KEV)
- Vendor-specific patches (Samsung, Google, etc.)
- Kernel vulnerabilities
- Component-specific CVEs (Qualcomm, MediaTek, etc.)

## Usage

### Basic Workflow

1. Connect Android device via USB
2. Enable USB Debugging on device
3. Press `F4` for initial security audit
4. Press `F7` for MDM/stalkerware scan
5. Press `F8` for CVE vulnerability check
6. Press `F3` for real-time monitoring

### Command Line

```bash
# Quick device check
ad                    # List connected devices

# Security scans
devaudit              # Full security audit
mdmscan               # MDM/Shadow MDM detection
cvescan               # CVE vulnerability scan
apkscan               # APK permission analysis

# Real-time monitoring
logopera              # Enhanced logcat viewer
permwatch             # Permission usage monitor
netwatch              # Network traffic monitor
```

## Research Applications

### Data Collection

All scripts can output to structured formats for research:

```bash
# Export audit to JSON
devaudit --json > audit_$(date +%Y%m%d).json

# Export CVE findings
cvescan --export > cve_findings_$(date +%Y%m%d).json
```

### Metrics Collected

- Device security patch level vs. current date
- Permission distribution across installed apps
- Network connection patterns
- MDM profile prevalence
- Vulnerability exposure duration

## Security Considerations

This tool is designed for **defensive security research only**.

- Only use on devices you own or have explicit authorization to test
- Some scans may trigger security alerts on managed devices
- Network monitoring should comply with local laws
- CVE information is provided for defensive purposes

## Contributing

Contributions welcome, especially:

- New stalkerware signatures
- CVE database updates
- Additional MDM detection heuristics
- Platform support (Linux, Windows WSL)

## License

MIT License - See LICENSE file

## Acknowledgments

- Android Security Team for CVE documentation
- Kitty Terminal developers
- The security research community

## Disclaimer

This tool is provided for educational and authorized security testing purposes only. Users are responsible for ensuring compliance with applicable laws and regulations. The authors assume no liability for misuse.

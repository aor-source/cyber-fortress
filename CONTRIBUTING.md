# Contributing to Cyber Fortress

Thank you for your interest in making Android security more accessible!

## How to Contribute

### 1. Stalkerware Signatures

If you've identified new stalkerware packages:

```bash
# Format for submission
Package Name: com.example.stalker
Known Display Names: "System Service", "Phone Manager"
Indicators: no_launcher, accessibility_abuse
Evidence: [Link to analysis or VirusTotal]
```

Submit via GitHub Issue with the `stalkerware-signature` label.

### 2. CVE Database Updates

Monthly Android Security Bulletins should be incorporated:

```bash
# Format
CVE-YYYY-XXXXX
Component: [Framework/System/Kernel/Vendor]
Severity: [Critical/High/Medium]
Patch Level: YYYY-MM
Actively Exploited: [Yes/No]
Description: Brief description
```

### 3. New Detection Heuristics

For behavioral detection improvements:

1. Describe the threat behavior
2. Provide detection logic (bash/pseudocode)
3. Include false positive considerations
4. Test on at least 3 devices

### 4. Bug Fixes

1. Fork the repository
2. Create a feature branch
3. Test on macOS + Linux if possible
4. Submit PR with clear description

## Code Style

- Bash scripts should use shellcheck-clean syntax
- Include comments for non-obvious logic
- Use consistent color/formatting with existing scripts
- Keep functions focused and under 50 lines

## Testing

Before submitting:

```bash
# Shellcheck validation
shellcheck scripts/*.sh

# Test on connected device
./scripts/device_audit.sh
./scripts/mdm_scanner.sh
./scripts/cve_scanner.sh
```

## Security Considerations

- NEVER include actual exploitation code
- NEVER include credential harvesting
- Focus on DETECTION, not exploitation
- All submissions reviewed for safety

## Recognition

Contributors will be credited in:
- README.md acknowledgments
- Release notes
- Research publications (with permission)

## Code of Conduct

- Be respectful and professional
- Focus on defensive security
- Help newcomers learn
- Disclose responsibly

## Questions?

Open an issue with the `question` label.

---

*Together we make security accessible to everyone.*

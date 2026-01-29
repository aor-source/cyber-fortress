# Coordinated Security Disclosure: Factory Reset Restriction on Financed Android Devices

**Disclosure ID:** CF-2025-001-DISCLOSURE
**Date:** 2025-01-29
**Disclosure Type:** Coordinated Responsible Disclosure
**Response Deadline:** 2025-02-12 (14 days)
**Public Tracker:** https://github.com/aor-source/cyber-fortress

---

## To: Android Security Team, Device Manufacturers, and Carrier Partners

**Primary Contacts:**
- Google Android Security: security@android.com
- Samsung Mobile Security: mobile.security@samsung.com
- AT&T Security: [via support escalation]
- Verizon Security: [via support escalation]
- T-Mobile Security: [via support escalation]

---

## Executive Summary

We are disclosing a **security architecture concern** affecting Android users with financed devices. The Device Lock Controller component enforces a `no_factory_reset` restriction that directly contradicts official malware remediation guidance from Google, Samsung, AT&T, and other vendors.

This creates a situation where users **cannot perform the recommended remediation step** (factory reset) when their devices are compromised by malware, stalkerware, or RATs.

We are requesting:
1. **Acknowledgment within 72 hours** that this disclosure has been received
2. **Coordination on remediation timeline** within 14 days
3. **Public statement** addressing the security implications

---

## The Vulnerability

### Technical Description

The `com.google.android.devicelockcontroller` component enforces:

```
userRestriction_no_factory_reset = ACTIVE
```

This policy is applied to devices enrolled in carrier financing programs. The restriction **blocks factory reset capability** until the device financing obligation is cleared.

### Security Impact

Factory reset is the **primary recommended remediation** for malware infections according to:

| Vendor | Official Guidance | Source |
|--------|------------------|--------|
| **Google** | "If you find signs of malware, you might need to reset your Android device" | [Google Support](https://support.google.com/accounts/answer/9924802) |
| **Samsung** | "Most malware can be removed by performing a factory reset on your phone" | [Samsung Support](https://www.samsung.com/us/support/answer/ANS00078568/) |
| **AT&T** | "If all else fails, you can perform a factory reset on your device" | [AT&T Cyber Aware](https://about.att.com/pages/cyberaware/ni/blog/how-to-remove-phone-virus) |

### What This Means

Users with financed devices who are infected with:
- Stalkerware / Spouseware
- Remote Access Trojans (RATs)
- Banking malware
- Spyware

**Cannot remediate using the officially recommended method.**

---

## Affected Population Analysis

### Who Finances Devices?

Device financing programs are disproportionately used by:
- Lower-income households
- Young adults / students
- First-time smartphone buyers
- Users in economically disadvantaged communities

### Who Is Targeted by Stalkerware?

According to the Coalition Against Stalkerware and academic research:
- Domestic abuse victims
- Economically dependent individuals
- Users with limited technical resources

### The Intersection

The population **most likely to finance devices** significantly overlaps with the population **most likely to be targeted by stalkerware and malware**. This policy creates maximum harm for maximum vulnerability.

---

## Why This Is Not Theft Protection

### Factory Reset Protection (FRP) Already Exists

Since Android 5.1 (2015), Factory Reset Protection has required:
- Original Google account credentials after any reset
- 72-hour waiting period after password changes
- Device cannot be activated without original owner verification

### What Blocking Factory Reset Adds

**Nothing.**

A thief cannot use a factory-reset device without the original Google credentials. FRP ensures this. The `no_factory_reset` restriction provides **zero additional theft protection** while **completely blocking malware remediation**.

---

## Proposed Remediation

### Immediate (P0/P1)

1. **Decouple factory reset from device financing restrictions**
   - Allow factory reset while maintaining FRP
   - FRP already prevents unauthorized device use
   - Users can remediate malware while device remains locked to their account

### Short-term

2. **Provide alternative remediation path for financed devices**
   - Remote-triggered deep clean option via carrier/Google
   - Expedited support path for malware-infected financed devices

### Long-term

3. **Review all Device Lock Controller restrictions for security impact**
   - Audit which restrictions create security vulnerabilities
   - Apply principle of least restriction

---

## Disclosure Timeline

| Date | Action |
|------|--------|
| 2025-01-29 | Initial disclosure sent to all parties |
| 2025-01-29 | Public disclosure posted to GitHub (transparency) |
| 2025-02-01 | **Deadline: Acknowledgment of receipt** |
| 2025-02-12 | **Deadline: Coordination response / remediation timeline** |
| 2025-02-13+ | If no response or inadequate priority: Escalation |

### Escalation Path (if needed)

If this disclosure is not acknowledged, not prioritized as P0/P1, or not addressed:

1. **Security Research Community**
   - DEF CON / Black Hat submission
   - Security researcher network distribution

2. **Consumer Protection**
   - Consumer Financial Protection Bureau (CFPB)
   - Federal Trade Commission (FTC)
   - State Attorneys General

3. **Advocacy Organizations**
   - Electronic Frontier Foundation (EFF)
   - National Network to End Domestic Violence
   - Coalition Against Stalkerware

4. **Legislative**
   - State legislature consumer protection committees
   - Congressional technology oversight committees

5. **Press**
   - Technology journalists (Ars Technica, The Verge, Wired)
   - Consumer advocacy journalists
   - Domestic violence / stalkerware beat reporters

---

## What We Are Asking

### From Google
1. Acknowledge this disclosure within 72 hours
2. Assign appropriate priority (we believe P0/P1 is warranted)
3. Provide remediation timeline within 14 days
4. Issue public statement addressing the security impact
5. Coordinate with carrier partners on policy change

### From Samsung and Other Manufacturers
1. Acknowledge receipt
2. Review your own device financing restrictions
3. Coordinate with Google on Android-wide solution
4. Provide data on affected device populations

### From Carriers (AT&T, Verizon, T-Mobile)
1. Acknowledge receipt
2. Review financing program security implications
3. Coordinate with Google/manufacturers on remediation
4. Consider interim support path for affected users

---

## Research Data Request

To better understand the scope of this issue, we request:

1. **Number of devices** currently under Device Lock Controller restrictions
2. **Malware infection rates** on financed vs. non-financed devices (if tracked)
3. **Support ticket volume** related to malware on financed devices
4. **Any internal analysis** of security implications of financing restrictions

This data will help quantify the impact and prioritize remediation.

---

## Contact

**Researcher:** aor-source
**GitHub:** https://github.com/aor-source/cyber-fortress
**Disclosure Tracking:** https://github.com/aor-source/cyber-fortress/docs/DISCLOSURE_001_FACTORY_RESET.md

We are committed to responsible disclosure and coordination. We want to see this fixed, not to cause harm. Please engage with us in good faith.

---

## Appendix: Technical Evidence

### Device Policy Dump (Affected Device)

```
userRestriction_no_factory_reset
  Resolved Policy (MostRestrictive):

Effective restrictions:
  no_cellular_2g
  no_install_unknown_sources_globally
  no_oem_unlock
```

### Verified Boot State (Confirming Device Integrity)

```
ro.boot.verifiedbootstate = green
ro.boot.flash.locked = 1
ro.boot.veritymode = enforcing
SELinux = Enforcing
```

Device has never been rooted. Bootloader locked. All security measures intact. User simply cannot perform factory reset.

---

*This disclosure is made in good faith to improve security for all Android users. We hope for prompt acknowledgment and collaborative remediation.*

**Power to the people.**

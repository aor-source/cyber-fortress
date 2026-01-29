# SECURITY FINDING: Factory Reset Block on Financed Devices

**Finding ID:** CF-2025-001
**Severity:** HIGH (Security/Human Rights Impact)
**Date:** 2025-01-29
**Affected:** All Android devices with Google Device Lock Controller (financed devices)

---

## Executive Summary

Google's Device Lock Controller, deployed on financed Android devices, blocks factory reset capability. This directly contradicts official malware remediation guidance from Google, Samsung, AT&T, and virtually every security authority, which unanimously recommend factory reset as the primary method to remove malware infections.

This creates a **security underclass** where users who finance devices (disproportionately lower-income) cannot remediate malware infections that users who purchase devices outright can easily clean.

---

## Evidence

### Official Vendor Recommendations

#### Samsung (Official Support)
> "Most malware can be removed by performing a factory reset on your phone."
>
> Source: https://www.samsung.com/us/support/answer/ANS00078568/

#### Google (Official Support)
> "If you find signs of malware, you might need to reset your Android device or ask the company that made your device for help."
>
> Source: https://support.google.com/accounts/answer/9924802

#### AT&T (Carrier Support)
> "If all else fails, you can perform a factory reset on your device after backing up your data."
>
> Source: https://about.att.com/pages/cyberaware/ni/blog/how-to-remove-phone-virus

#### AT&T Device Support (All Devices)
> "Factory reset: If all of the previous steps fail to correct the problem, you can perform a master reset."
>
> Source: https://www.att.com/device-support/article/wireless/KM1329558/

### The Contradiction

Despite these official recommendations, Google's Device Lock Controller enforces:

```
userRestriction_no_factory_reset = ACTIVE
```

This policy **blocks** the exact remediation step that all parties (including Google itself) recommend for malware removal.

---

## Technical Analysis

### What Factory Reset Does
- Wipes `/data` partition (user data, installed apps)
- Removes all third-party applications including malware
- Returns device to clean state
- **Does NOT affect:**
  - Bootloader lock state
  - Factory Reset Protection (FRP)
  - Google account verification requirement
  - Device ownership verification

### What Factory Reset Does NOT Do
- Does not unlock bootloader
- Does not bypass theft protection
- Does not allow device resale without original credentials
- Does not remove device financing obligation

### Security Implications

**Threat Model: Stalkerware/RAT Infection**

| User Type | Can Factory Reset? | Can Remediate? |
|-----------|-------------------|----------------|
| Purchased device outright | YES | YES |
| Financed device | NO | **NO** |

The user with a financed device must either:
1. Continue using a compromised device
2. Pay off the device entirely
3. Seek manufacturer intervention (lengthy, uncertain)

---

## Affected Populations

### Demographics of Device Financing
- Lower-income households
- Young adults / students
- Users in developing markets
- First-time smartphone buyers

### Threat Exposure of Same Demographics
- Higher stalkerware/spouseware targeting (domestic abuse scenarios)
- Higher exposure to predatory apps and scams
- Less access to technical support resources
- Less likely to have backup devices

### Intersection = Maximum Harm
The population least able to afford device replacement is simultaneously:
- Most likely to be targeted by malware
- Least able to remediate infections
- Most vulnerable to ongoing exploitation

---

## Logical Inconsistency

### Google's Stated Purpose
Device Lock Controller exists to:
> "Protect carrier/financing company investment until device is paid off"

### Actual Theft Protection
Factory Reset Protection (FRP) already:
- Requires original Google account after any reset
- Prevents device activation without credentials
- Makes stolen devices worthless for resale
- Has existed since Android 5.1 (2015)

### The Question
**Why block factory reset when FRP already prevents unauthorized use?**

The device cannot be:
- Resold without original account
- Activated by a thief
- Used without Google verification

Blocking factory reset provides **zero additional theft protection** while **completely blocking malware remediation**.

---

## Recommended Actions

### For Google
1. **Immediately** decouple factory reset from device financing restrictions
2. Allow factory reset while maintaining FRP (already sufficient theft protection)
3. Issue public statement acknowledging security impact
4. Audit Device Lock Controller for other security-harmful restrictions

### For Regulators
1. Investigate whether blocking malware remediation violates consumer protection laws
2. Assess disparate impact on protected classes (income-based discrimination)
3. Consider requiring malware remediation capability on all consumer devices

### For Security Researchers
1. Document prevalence of this restriction across carriers/regions
2. Study infection rates on financed vs. purchased devices
3. Develop alternative remediation methods that work within restrictions

### For Affected Users
1. Document any malware infections thoroughly
2. Contact Google support demanding remediation assistance
3. File complaints with consumer protection agencies
4. Consider this restriction when choosing financing vs. purchase

---

## References

1. Samsung Malware Support: https://www.samsung.com/us/support/answer/ANS00078568/
2. Google Account Security: https://support.google.com/accounts/answer/9924802
3. AT&T Cyber Aware: https://about.att.com/pages/cyberaware/ni/blog/how-to-remove-phone-virus
4. AT&T Device Support: https://www.att.com/device-support/article/wireless/KM1329558/
5. Google FRP Documentation: https://support.google.com/android/answer/9459346

---

## Conclusion

Google has created a policy that:
- Contradicts their own security guidance
- Provides no additional theft protection (FRP exists)
- Blocks the primary malware remediation method
- Disproportionately harms vulnerable populations
- Effectively weaponizes consumer debt as a security liability

This is not a technical limitation. This is a policy choice. And it is harming users.

---

*"Damn the man, save the empire, and power to the people."*

---

**Classification:** Public Interest Security Research
**Distribution:** Unrestricted
**Contact:** [To be added for responsible disclosure coordination]

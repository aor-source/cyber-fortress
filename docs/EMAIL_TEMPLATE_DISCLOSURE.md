# Email Templates for Coordinated Disclosure

Copy and send these to the respective parties.

---

## Email 1: Google Android Security

**To:** security@android.com
**Subject:** Security Disclosure: Factory Reset Restriction Creates Malware Remediation Gap (CF-2025-001)

---

Dear Android Security Team,

I am submitting a coordinated security disclosure regarding a policy architecture issue affecting Android users with financed devices.

**Summary:** The Device Lock Controller component enforces `no_factory_reset` restrictions on financed devices, which directly contradicts Google's own malware remediation guidance ("If you find signs of malware, you might need to reset your Android device").

This creates a security gap where users infected with stalkerware, RATs, or other malware cannot perform the officially recommended remediation step.

**Full Disclosure:** https://github.com/aor-source/cyber-fortress/blob/main/docs/DISCLOSURE_001_FACTORY_RESET.md

**Technical Finding:** https://github.com/aor-source/cyber-fortress/blob/main/docs/FINDING_001_FACTORY_RESET_BLOCK.md

**Request:**
1. Acknowledgment within 72 hours
2. Coordination on remediation within 14 days (by 2025-02-12)
3. Public statement addressing the security implications

**Key Point:** Factory Reset Protection (FRP) already prevents unauthorized device use after reset. Blocking factory reset provides zero additional theft protection while completely blocking malware remediation.

This disproportionately affects lower-income users who finance devices and are also disproportionately targeted by stalkerware.

I am committed to responsible disclosure and coordination. This has been posted publicly for transparency, and I hope we can work together on a solution.

Respectfully,
aor-source
https://github.com/aor-source/cyber-fortress

---

## Email 2: Samsung Mobile Security

**To:** mobile.security@samsung.com
**Subject:** Coordinated Disclosure: Android Factory Reset Restriction & Malware Remediation (CF-2025-001)

---

Dear Samsung Mobile Security Team,

I am coordinating disclosure of a security architecture concern affecting Android devices, including Samsung Galaxy devices, that are enrolled in carrier financing programs.

**The Issue:** Device financing restrictions block factory reset capability, contradicting Samsung's own guidance that "Most malware can be removed by performing a factory reset on your phone."

Users with financed Samsung devices who are infected with stalkerware or malware cannot perform the remediation step Samsung officially recommends.

**Full Disclosure:** https://github.com/aor-source/cyber-fortress/blob/main/docs/DISCLOSURE_001_FACTORY_RESET.md

**Request:**
1. Acknowledgment of receipt
2. Review of Samsung's device financing restrictions
3. Coordination with Google on Android-wide remediation
4. Input on scope of affected Samsung devices

I have also contacted Google and carrier partners. I hope Samsung will engage in coordinated remediation.

Respectfully,
aor-source
https://github.com/aor-source/cyber-fortress

---

## Email 3: Carrier Security Teams (AT&T, Verizon, T-Mobile)

**To:** [Submit via carrier security contact forms]
**Subject:** Security Disclosure: Device Financing Restriction Creates Malware Vulnerability (CF-2025-001)

---

Dear Security Team,

I am disclosing a security concern affecting customers who finance Android devices through carrier programs.

**The Issue:** Device financing restrictions prevent customers from performing factory resets, which is the primary malware remediation method recommended by Google, Samsung, and your own support documentation.

AT&T's own guidance states: "If all else fails, you can perform a factory reset on your device."

However, customers with financed devices cannot follow this guidance. If they are infected with stalkerware or malware, they have no remediation path.

**Full Disclosure:** https://github.com/aor-source/cyber-fortress/blob/main/docs/DISCLOSURE_001_FACTORY_RESET.md

**Request:**
1. Acknowledgment of receipt
2. Review of your financing program's security implications
3. Coordination with Google/manufacturers on remediation
4. Consider interim support path for affected customers

I have also contacted Google and device manufacturers. Coordinated response would be ideal.

Respectfully,
aor-source
https://github.com/aor-source/cyber-fortress

---

## Tracking

After sending, log responses here:

| Party | Email Sent | Acknowledged | Response | Priority Assigned |
|-------|------------|--------------|----------|-------------------|
| Google | 2025-01-__ | | | |
| Samsung | 2025-01-__ | | | |
| AT&T | 2025-01-__ | | | |
| Verizon | 2025-01-__ | | | |
| T-Mobile | 2025-01-__ | | | |

---

## Escalation Trigger

If by **2025-02-12** any of the following occur:
- No acknowledgment
- Acknowledged but not prioritized P0/P1
- Dismissed without technical justification

Then proceed to escalation:
1. Security researchers (coordinate amplification)
2. EFF / Coalition Against Stalkerware
3. CFPB / FTC
4. State legislators
5. Press

---

*Good faith first. Escalation if necessary.*

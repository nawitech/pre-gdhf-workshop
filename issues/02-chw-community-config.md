---
title: "NE-2: CHW community configuration, end to end (J2)"
labels: nawi-engineering, player, config, TECH-05
---
## The story this app has to tell
A family from Lao PDR comes home from Thailand with a newborn and two paper vaccination cards (Hepatitis B and BCG, each with its own signed QR). The community health worker visits the household. Her phone has been offline for weeks. She sees the mother on the household roster but no baby, registers the newborn, scans both cards, sees what was given and when, and refers the child to the clinic because the record came from abroad and cannot be verified at the household. Nothing here needs connectivity. Verification is the clinic's job (J3), not hers.

## Build
One OHS Player community configuration (new client directory, say `vaxlink/`, community role) with:
1. **Household roster** using the existing Group and RelatedPerson household model: the Souvannalath household seeded with the mother; add the newborn as a member linked to her.
2. **Newborn registration** questionnaire: name, sex, date of birth, guardian; no national ID.
3. **Scan certificate** action on the child's profile: camera scan, `readUnverified` from the library (NE-1), show the product name (from the bundled PreQual CodeSystem), date of vaccination, lot, issuing country (iss) and the words "not verified". Repeat for the second card.
4. **Record** each scan as an `Immunization` with the PreQual coding exactly as issued, `primarySource` false, `reportOrigin` = family-provided document, status completed. The app has no mapping from the product to a Lao schedule dose, so it does not try: this is the narrative point.
5. **Refer**: a `ServiceRequest` to the seeded clinic with reason "foreign immunization record to verify", and a visible "needs verification" flag on the child.
6. **Sync** when back online: Patient, Group, RelatedPerson, Immunization, ServiceRequest in the role's allow-list, scoped to the CHW's catchment.

## Data
Resources: Group, RelatedPerson, Patient, Immunization x2, ServiceRequest, Location (clinic). Seed: the household, the CHW practitioner and role, the clinic Location. Terminology from NE-5. Dates are placeholders until final certificates are generated.

## Out of scope
Signature verification, schedule logic, any mapping of codes, SMS. The device may be offline for the whole journey.

## Acceptance
- With the device offline and the trust list never synced, both cards scan and both Immunizations are recorded as unverified with the PreQual product coding unchanged.
- The product name shows for both; nothing claims a Lao schedule dose.
- A referral exists for the clinic and the child shows as needing verification.
- After reconnecting, the clinic configuration (NE-3) sees the child, the two Immunizations and the referral.

Owner: Nawi engineering. Parent: TECH-05. Due: 28 Oct (demo-able), hardened by 4 Nov. Depends on NE-1 (readUnverified, QR scan) and NE-5 (PreQual CodeSystem).

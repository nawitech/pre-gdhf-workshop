---
title: "NE-3: Clinic facility configuration, end to end (J3)"
labels: nawi-engineering, player, config, TECH-06
---
## The story this app has to tell
The referral arrives at a Lao clinic. The nurse opens the child's record on a tablet, sees two immunizations marked unverified, and scans the same two cards. This time the signatures are checked against the GDHCN trust list: both are real, issued by a recognised authority in Thailand. The immunizations become verified and part of the domestic record, with the codes exactly as Thailand issued them. The app then runs the Lao schedule. The Hepatitis B product in the certificate has no entry in the Lao product-to-schedule map (it is a Thai product Laos does not procure), so the app shows the product name, derives its vaccine type, proposes "Hepatitis B birth dose" and asks the nurse to confirm. She does; the Lao coding is added as a second coding, her confirmation is recorded, and the schedule shows what is due next. A follow-up is booked. This confirmation step is the moment the policy track builds its governance discussion on, so it has to be visible, not automatic.

## Build
One OHS Player facility (EHR) configuration, web build on a tablet (or Android on tablet so the camera works), with:
1. **Referral inbox** and child record showing the unverified immunizations from J2.
2. **Verify** action: scan, `verify` via the library (NE-1) against the cached DEV trust list, show the outcome, the issuing country and the DSC kid before showing any content. A failed verification shows the typed reason and imports nothing.
3. **Import**: update the two Immunizations to `primarySource` true and attach a `Provenance` (agent: Thai issuing authority; entity: the certificate). Detect a certificate already imported.
4. **Type and dose mapping**: derive the PreQual vaccine type from the product (ConceptMap from NE-5 if published, local table if not); look up the Lao type-to-dose ConceptMap; where there is no match, present the product name, the proposed dose and a confirm/choose control; on confirmation add the Lao coding as a second `vaccineCode.coding` and record who confirmed and when (an Observation or Provenance; pick one and document it).
5. **Schedule**: PlanDefinition with FHIRPath conditions over the Immunization history against Lao schedule content (NE-5); show due and overdue; create a Task or Appointment for the next visit.
6. **Audit**: an AuditEvent for every verification attempt through the Info Gateway.

## Data
Immunization (updated), Provenance, ImmunizationRecommendation (derived), Task or Appointment, AuditEvent. PlanDefinition, ValueSets and ConceptMap from NE-5.

## Out of scope
Issuance, the family app, VHL. The clinic may be online or offline; verification must work offline with cached keys.

## Acceptance
- Both worked-example cards verify offline on the tablet; a tampered card fails and imports nothing.
- After import the Immunizations carry the PreQual coding unchanged plus a Provenance.
- The Hepatitis B product maps automatically to HB0-24H, recorded as automatic; the BCG product triggers the confirm step, and after confirmation the chosen Lao coding is present as a second coding and the confirmation is recorded. Full current text: issue #3.
- The schedule lists the next due doses and a follow-up exists.
- An AuditEvent exists for each verification.

Owner: Nawi engineering (Jing Tang reviewing schedule content). Parent: TECH-06. Due: 4 Nov. Depends on NE-1, NE-2 (incoming data), NE-5.

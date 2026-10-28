---
title: "NE-4: Family app configuration, end to end (J4.0)"
labels: nawi-engineering, player, config, TECH-07
---
## The story this app has to tell
A year later the family is going back to Thailand for the baby's first birthday. On the father's phone, one app holds a profile for each of the three of them. For each person he requests portable records from the Lao national portal and gets back a Verifiable Health Link: a QR he can show, protected by a passcode he sets. The records themselves stay in Laos; the phone carries links and keys. Nothing is emailed or messaged for the demo.

How a VHL actually works, so the screens make sense: the QR is itself a signed HCERT (same format as the vaccination card) whose payload is a SMART Health Links record: a manifest URL, a 32-byte key, an expiry and flag P (passcode). The issuer (NE-6) hosts an ITI-YY5 manifest (a FHIR List search returning DocumentReferences) and each document's content is JWE-encrypted with that key. There is no separate signed manifest; the signature is on the link. See https://litlfred.github.io/smart-trust-tools/journeys.html (J4.0 row) and the VHL section of the API contract.

## Build
One OHS Player configuration (family role) on Android with:
1. **Household on one device**: Group and RelatedPerson, one profile per member, one sign-in (simplified for the demo).
2. **Request records** per member: call the mock issuer (NE-6) with the member identifier and the passcode the holder chooses; receive the HC1 string of the signed VHL.
3. **Show** one QR per member, rendered from the HC1 string (NE-1 rendering), with the member's name and the link's expiry; passcode is entered by the holder at the clinic, not shown.
4. **Record** that the holder chose to share (nice-to-have: a Consent resource aligned to IHE PCF; at minimum a local note).
5. The app keeps no copy of the IPS; it keeps the HC1 strings.

## Data
Group, RelatedPerson, three Patients, three VHL HC1 strings, optional Consent. Seeded in Laos: the father's IPS with medications, the mother's, the child's with the full immunization history including the Thai doses with their Lao coding and Provenance from J3.

## Out of scope
SMS or WhatsApp delivery, the viewer (NE-5), hosting (NE-6). Production authentication to the portal.

## Acceptance
- Three members, three VHL QRs, each produced by the mock issuer and renderable.
- Scanning any of them with the viewer (NE-5) verifies and, with the right passcode, shows that member's IPS.
- With a wrong passcode the fetch is refused and nothing is shown.

Owner: Nawi engineering, with Jing Tang on prior SHL work. Parent: TECH-07. Due: 10 Nov. Depends on NE-1 (rendering, library), NE-6.

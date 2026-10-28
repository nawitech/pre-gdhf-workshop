---
title: "NE-4: Cross-border travel end to end: VHL issuance, WhatsApp delivery and the foreign clinic viewer (J4.0, J4.1)"
labels: nawi-engineering, backend, whatsapp, player, TECH-07, TECH-08
---
## The story this has to tell
A year after the birth, the family is going back to Thailand for the baby's first birthday. On the father's phone, in WhatsApp, he messages the Lao national health number and asks for travel records for the three of them. For each person he gets back a QR image and a link, and a passcode he either chose or was given. The records stay in Laos; what travels is a signed link.

At a clinic in Thailand the doctor scans the child's QR on a tablet, or taps the link the father forwards, enters the passcode the father gives, and sees the child's record fetched live from Laos: the immunization history including the two doses Thailand gave a year ago, now with Lao verification provenance. Laos logs who fetched what. This is the only step in the vignette that needs the internet, by design.

## How a Verifiable Health Link works (read before building)
A VHL QR is itself a signed HCERT, the same format as the vaccination card, whose payload at hcert key 5 is a SMART Health Links record: a manifest URL, a 32-byte key, an expiry, flag P (passcode) and a label. The host serves an ITI-YY5 manifest (a FHIR List search that takes the passcode and returns a searchset Bundle of DocumentReferences) and each document's content is JWE-encrypted (dir / A256GCM) with the link key. There is no separate signed manifest; the signature is on the link. Carl's library does the format work on both ends: see the J4.0 and J4.1 rows and the VHL section of https://litlfred.github.io/smart-trust-tools/journeys.html and the `vhl` and `issuer` interfaces in https://litlfred.github.io/smart-trust-tools/viewers/api.html.

## Part A: VHL issuer and host (Nawi GCP)
1. Hold three IPS documents on a FHIR server as DocumentReferences: father with medications, mother, child with the full immunization history (the Thai doses with their PreQual coding, the Lao coding added at J3 and the Provenance).
2. On an issuance request for a member: generate the link key (`HcertVhl.newKey`), encrypt that member's document with it, create the manifest List, build the VHL payload (url, key, exp, flag P, label) and sign it as an HCERT with the DEV DSC using the library's two-phase `HcertIssuer.prepare` / `finish`. Return the HC1 string, a rendered QR image (version 16, error correction Q) and a web link that opens the viewer with the HC1 embedded.
3. Serve the manifest: `<base>/List/_search`, form-encoded, with passcode and recipient; wrong passcode refused; three failures lock the link for a period; refuse after expiry.
4. Serve the documents (ITI-68 GET of the attachment URL).
5. Write an AuditEvent per manifest or document fetch (subject, time, requester where known, outcome) through the Info Gateway.
6. The DEV DSC must be on the GDHCN DEV trust list so the viewer verifies it (keys from Ritika, TECH-03).
Where the specs are silent (requester authentication), do the simplest thing and write it down. OpenFn is an option for assembling the IPS bundles, not a requirement. The WHO ITB prototype, when it lands, is the reference; pre-packaged QRs are the fallback if Part A slips.

## Part B: WhatsApp workflow (the family's client)
1. Use the WhatsApp Business number on Matt's subscription; a webhook receives messages.
2. A simple conversation: the sender's number is seeded as the father's and maps to the household; the bot lists the three members; the father picks one (or all) and sets a passcode, or the bot generates one and sends it in a separate message; the bot calls Part A and replies with the QR image, the link and the expiry.
3. Record that the holder chose to share (a Consent resource aligned to IHE PCF is the nice-to-have; a logged message is the minimum).
4. Keep the bot stateless beyond the conversation; nothing clinical is stored on the WhatsApp side.
5. Policy note for the talk, not the build: sharing a health link over a commercial messaging service is acceptable here because the link alone yields nothing without the passcode, and the key never leaves the QR.

## Part C: Foreign clinic viewer (OHS Player, Thailand clinician role)
A Player configuration, which can be the clinic configuration from NE-3 under a different role, with a web build so a tapped link works too:
1. Scan the QR, or open from the link: `verify` the HCERT (NE-1), show the issuing country (Lao PDR) and the outcome before anything else.
2. Prompt for the passcode; build the manifest request with the library; POST it over HTTPS to the Lao host.
3. GET each DocumentReference's content, `decrypt` with the link key, render the IPS with the immunization section first.
4. Wrong passcode, expired link and host unreachable each give a clear message and show nothing partial.
5. Audit is Part A's; the viewer shows nothing about it.

## Out of scope
A custom family app in the Player (replaced by WhatsApp, decision 28 Oct). SMS. Production identity proofing, OAuth, production key management.

## Acceptance
- From WhatsApp, each of the three members gets a signed VHL that verifies against the DEV trust list; the QR and the link both open the viewer.
- With the right passcode the viewer shows the right person's IPS; the child's shows the Thai doses with Lao provenance. With a wrong passcode nothing is shown and the attempt is logged; after expiry the link is refused.
- AuditEvents exist in Laos for every fetch.
- Works on a tablet over venue Wi-Fi and over a phone hotspot; Part A runs on Nawi's GCP environment behind HTTPS.

## Dependencies
NE-1 (library packaging, verify, decrypt), NE-3 (the child's record as it stands after J3), NE-5 (terminology for the IPS), DEV keys (TECH-03), Matt's WhatsApp Business number.

Owner: Nawi engineering with Jose Costa Teixeira (Part A), Jing Tang on prior SHL work. Parent: TECH-07, TECH-08. Due: Part A 6 Nov, Parts B and C 10 Nov.

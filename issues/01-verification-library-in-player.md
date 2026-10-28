---
title: "NE-1: HCERT verification library in the OHS Player (J2, J3, J4.1)"
labels: nawi-engineering, player, verification, TECH-04, TECH-06
---
## Why this exists
Every scan in the vignette goes through one library: the CHW reads a certificate offline (J2), the clinic verifies it against the GDHCN trust list (J3), and the clinic abroad verifies a Verifiable Health Link and fetches the records (J4.1). Carl Leitner and Jose Costa Teixeira are building that library as Kotlin Multiplatform from a published specification. Our job is not to write crypto; it is to host the library inside the Player and do the parts the library deliberately leaves to the app.

Read first, in this order:
1. https://litlfred.github.io/smart-trust-tools/journeys.html (what the library does per journey step, and what is ours)
2. https://litlfred.github.io/smart-trust-tools/viewers/api.html (the WIT contract; the Kotlin API follows it)
3. https://github.com/WorldHealthOrganization/smart-trust/blob/main/input/pagecontent/qr_code_generation.md (worked example, test vectors, verification steps)
4. Kotlin code: https://github.com/litlfred/smart-trust-tools/tree/main/tools/hcert-kotlin

## What the library gives us (do not reimplement)
- `HcertVerifier.readUnverified(hc1)` for J2: decodes without trust lookup; result is typed as unverified.
- `HcertVerifier.verify(hc1, trustStore, registry, now, options)` for J3 and J4.1: the full step order (prefix, base45, inflate, COSE, header, trust lookup, signature, key usage, CWT, time, hcert, payload) with typed failure reasons.
- `TrustStore` with `addDidDocument` / `addPem` and `candidates(kid)`: it holds whatever we load; it never does network.
- DVCMin typed payload (n, dob, s, nt, id, dt, gn, vx{vp, dv, cn, is, bo}, v) and VHL payload (url, key, exp, flag, label, v).
- For VHL: `buildManifestRequest` (ITI-YY5 List search with passcode), `parseManifest` (searchset Bundle of DocumentReferences), `decrypt` (JWE dir/A256GCM with the link key).

## What is ours (the scope of this ticket)
1. **Package the library** as a dependency of the Player for Android and the web target. Confirm it builds for both; report gaps to Carl.
2. **Trust material.** On sync, fetch the GDHCN DEV trust list (DID trustlist v2, https://smart.who.int/trust/endpoints.html#trustlist-distribution-endpoints), load it into a `TrustStore`, persist it so `verify` works with no network, and expose the cache age in the UI. Pre-provision the DEV list on demo devices.
3. **Clock.** `verify` takes `now`; pass the device time and a sensible skew.
4. **QR in and out.** Camera scanning that returns the HC1 string (Android and web on tablet) and QR rendering of an HC1 string at error correction Q, 35 to 60 mm, square modules (the family app shows one per traveller).
5. **DVCMin to FHIR.** The library does not map to FHIR. Map a verified or unverified DVCMin to `Patient` (no national ID; guardian name on a RelatedPerson or `Patient.contact`), one `Immunization` per certificate with `vaccineCode` = PreQual product coding exactly as issued, `occurrenceDateTime` = dv, `lotNumber` = bo, `primarySource` false until verified, and a `Provenance` on verification naming the DSC's country and kid. Keep it in one place so J2, J3 and J4.1 share it.
6. **Display of PreQual products.** Bundle the PreQualProductIds and PreQualVaccineType CodeSystems (https://worldhealthorganization.github.io/smart-pcmt-vaxprequal/) so a scanned `vp` shows a name and, once the product-to-type ConceptMap exists, a type. Until Ritika adds display names, carry a local display table for the demo products.
7. **VHL fetch.** For J4.1: after `verify` returns a VHL payload, the app does the HTTPS: POST the manifest request the library builds, GET each DocumentReference's content, `decrypt` with the link key, hand the IPS to the viewer, and write an AuditEvent through the Info Gateway.
8. **Test vectors.** The two HC1 strings in the worked example (HepB and BCG, DEV participant XXR, kid 916ffa567c0f44a2) must verify on Android and web; a tampered copy must fail at `signature`.

## Out of scope
Issuance (WHO tooling and the mock VHL issuer, NE-6), the Player screens themselves (NE-2 to NE-5), terminology content (NE-7).

## Acceptance
- Both worked-example certificates verify on an Android tablet and in the web build with the device offline after one trust-list sync.
- `readUnverified` returns both certificates on a phone that has never synced the trust list.
- A tampered certificate fails with a typed reason and no payload is shown.
- A VHL QR from the mock issuer (NE-6) verifies, the manifest fetch with passcode succeeds, and the decrypted IPS renders.
- One shared DVCMin-to-FHIR mapper used by all three journeys, with unit tests on the worked example.

## Dependencies
Carl's library test target (TECH-04, 23 Oct); DEV keys from Ritika (TECH-03); mock issuer (NE-6) for the VHL path.

Owner: Nawi engineering, with Roy Munge reviewing the library. Parent: TECH-04, TECH-06. Due: 4 Nov for J3; 10 Nov for the VHL path.

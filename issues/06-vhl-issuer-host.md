---
title: "NE-6: Mock VHL issuer and host on Nawi GCP (J4.0, J4.1)"
labels: nawi-engineering, backend, TECH-08
---
## Why this exists
Nothing exists today that issues Verifiable Health Links; the IHE profile has an OperationDefinition and little else. We agreed on 21 October to build a small mock on Nawi's GCP servers, with WHO's ITB prototype as the reference when it arrives and pre-packaged QRs as the fallback. The requirements are production-level even though the implementation is a mock (spec tab, section 6.7).

## What it has to do
1. **Hold three IPS documents** (father with medications, mother, child with the full immunization history) as DocumentReferences on a FHIR server, with the content JWE-encrypted (dir / A256GCM) using a per-link key.
2. **Issue a VHL** on request from the family app (NE-4): generate the key (`HcertVhl.newKey`), encrypt the documents, create the manifest List, build the VHL payload (url, key, exp, flag P, label) and sign it as an HCERT with the DEV key using the library's two-phase `HcertIssuer.prepare` / `finish`; return the HC1 string.
3. **Serve the manifest**: ITI-YY5, a FHIR List search (`<base>/List/_search`, form-encoded, with the passcode and recipient) returning a searchset Bundle of DocumentReferences; refuse on wrong passcode, rate-limit attempts, refuse after expiry.
4. **Serve the documents** (ITI-68 GET of the attachment URL).
5. **Audit**: an AuditEvent per manifest or document fetch: subject, time, requester where known, outcome, written through the Info Gateway.
6. **Trust**: the DEV DSC used for signing must be on the GDHCN DEV trust list so the viewer (NE-5) verifies it.

Use the library's VHL functions for the format details; the library's authors have already reconciled the WHO and IHE differences (see the VHL section of https://litlfred.github.io/smart-trust-tools/journeys.html). Where the spec is silent (requester authentication), do the simplest thing and write it down.

## Out of scope
Real identity proofing, OAuth, production key management. OpenFn packaging is an option for building the IPS bundles, not a requirement.

## Acceptance
- A request for each of the three members returns a signed VHL HC1 that verifies against the DEV trust list.
- The manifest search succeeds with the right passcode and fails with the wrong one; after three failures it locks for a period.
- Each document decrypts with the link key and is a valid IPS bundle.
- AuditEvents exist for every fetch.
- Runs on Nawi's GCP environment behind HTTPS and is reachable from a phone hotspot.

Owner: Nawi engineering with Jose Costa Teixeira. Parent: TECH-08. Due: 6 Nov. Depends on DEV keys (TECH-03), library issuer functions (TECH-04).

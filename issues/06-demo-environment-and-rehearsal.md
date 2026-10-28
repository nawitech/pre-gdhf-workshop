---
title: "NE-6: Demo environment, seed data, fallbacks and rehearsal"
labels: nawi-engineering, infra, TECH-12, TECH-13
---
## Why this exists
Five apps, two countries, one trust list and a venue with unreliable Wi-Fi. Everything the other tickets build has to run end to end on 30 November with a fallback for every network dependency.

## Build
1. **Servers** on Nawi GCP: HAPI FHIR for Lao PDR and for Thailand, Keycloak, OHS Info Gateway (audit), the VHL issuer and host (NE-4). Seeded users, facilities, the household, practitioners and roles.
2. **Devices**: CHW phone (Android), clinic tablet (web or Android), family phone (Android), viewer tablet or phone. DEV trust list pre-loaded; configurations installed; a laptop with local copies of the servers for the no-network case.
3. **Cards**: the two worked-example cards printed to the QR spec (version 16, EC Q, 35 to 60 mm, square modules, 300 dpi), plus a spare with a broken signature for the failure path.
4. **Fallbacks**: cached keys, pre-packaged VHL QRs, local server images, a phone hotspot.
5. **Alpha by 31 October**: the full flow once, Postman where an app is not ready, to find the traps early.
6. **Rehearsal 25 November**: full run with the run-of-show, timings, handoffs and recovery from each failure.
7. **Repo**: configurations, seed data, test vectors and this environment description versioned under this repository so a country team can stand the demo up afterwards.

## Acceptance
- The alpha runs end to end by 31 October and its findings are filed as issues.
- The rehearsal runs end to end with every fallback exercised once.
- A new engineer can stand up the environment from the repository in an afternoon.

Owner: Nawi engineering, Roy Munge. Parent: TECH-12, TECH-13. Due: alpha 31 Oct, environment 18 Nov, rehearsal 25 Nov.

---
title: "NE-5: Foreign clinic viewer, end to end (J4.1)"
labels: nawi-engineering, player, config, TECH-07
---
## The story this app has to tell
At a clinic in Thailand the doctor scans the child's VHL QR on a tablet, asks the father for the passcode, and sees the child's record fetched live from Laos: the immunization history, including the two doses Thailand gave a year ago, now with Lao verification provenance. The access is logged in Laos. This is the only step that needs the internet, by design.

## Build
A Player configuration for the Country A clinician (it can be the facility configuration from NE-3 with a different role; decide and document) with:
1. **Scan** the VHL QR, `verify` the HCERT (NE-1): show the issuing country (Lao PDR) and outcome before anything else.
2. **Passcode** prompt; build the ITI-YY5 manifest request with the library; POST it over HTTPS to the Lao host (NE-6).
3. **Fetch** each DocumentReference's content, `decrypt` with the link key, render the IPS with the immunization section first.
4. **Errors**: wrong passcode, expired link, host unreachable each give a clear message and no partial data.
5. **Audit** is written by the host (NE-6); the viewer shows nothing about it.
6. **Variant** for the talk only, not built: a clinician with no app opens the link in a browser.

## Acceptance
- The three VHLs from NE-4 each verify and, with the right passcode, show the right person's IPS; the child's shows the Thai doses with Lao provenance.
- Wrong passcode and expired link paths behave as above.
- Works on a tablet over venue Wi-Fi and over a phone hotspot.

Owner: Nawi engineering. Parent: TECH-07. Due: 10 Nov. Depends on NE-1, NE-4, NE-6.

# VaxLink: Pre-GDHF workshop, technical workstream

Start here. This file is the context a new session or a new person needs before touching anything in this repository.

## What this is
A two-day WHO Pre-GDHF workshop (Bangkok, 30 November to 1 December 2026) built around one clinical vignette, VaxLink: a Lao PDR family's baby is born in Thailand, gets Hepatitis B and BCG birth doses and two signed paper vaccination certificates (DVCs), comes home, is found by a community health worker, verified at a clinic, and a year later travels back to Thailand carrying Verifiable Health Links on one family phone. Engineers and policy makers work from the same story. Nawi (Nawitech Limited) builds the demo applications as configurations of the OHS Player; WHO (Carl Leitner, Ritika Rawlani, Jose Costa Teixeira) supplies the certificates, keys, verification library and test bed; Fred Hersch (OHS Foundation) runs the programme.

## Where things live
- The master tracker is this repository: `tracker_seed.csv` / `tracker_seed.json`, rendered by `index.html` on GitHub Pages. TECH-nn / POL-nn / JOINT-nn are the programme-level items; TECH-nn.m are technical sub-tasks.
- Engineering tickets for Nawi are GitHub Issues NE-1 to NE-8 (source drafts in `issues/`). One issue per application or component, end to end, so each carries its full context.
- The single shared document is the Google doc "WHO Pre-GDHF Workshop User Journeys & Technical Requirements": tab 1 journeys, decisions and notes; tab 2 the VaxLink requirements and technical specification. Exports are in `docs/`.
- Agenda planning (Carl's workbook and the ODHS deck) is in `docs/`.

## Decisions that shape the build
- OHS Player is the platform; the CHW app, clinic app, family app and foreign clinic viewer are configurations, not separate apps. Call it "OHS Player", not OpenSRP, in this context.
- Country A is Thailand, Country B is Lao PDR. DEV participant XXR signs for Thailand on the GDHCN DEV trust list.
- One DVC per immunization event: two certificates, two cards. Worked example and test vectors: WHO smart-trust `input/pagecontent/qr_code_generation.md`.
- The DVC identifies the vaccine by WHO PreQual product ID (`vp`, required binding). The vaccine type is derived locally from the vaxprequal IG; only the type-to-schedule-dose map is national and it is deliberately partial. No Thai code system. Codes are stored as issued; a Lao coding is added at the clinic only after a clinician confirms.
- The CHW stage reads the certificate (unverified) and refers; signature verification happens at the clinic.
- One Kotlin Multiplatform verification library, built by WHO from https://litlfred.github.io/smart-trust-tools (WIT API, CDDL, requirements, per-journey coverage). The Player hosts it; QR scanning, rendering, trust-list fetching, HTTP, storage and FHIR mapping are the Player's.
- A VHL QR is itself a signed HCERT carrying a SMART Health Links payload (manifest URL, key, expiry, passcode flag). The host serves an ITI-YY5 manifest and JWE-encrypted documents. There is no separate signed manifest.
- The mock VHL issuer runs on Nawi's GCP servers; ITB prototype as reference; pre-packaged QRs as fallback.
- Schedule and clinical content are IG-aligned FHIR artefacts (SMART Guidelines L3 style), not code.
- Dates in test data are placeholders; certificates are regenerated closer to the workshop.
- End-to-end alpha by 31 October; rehearsal 25 November.

## People (initials used in the tracker)
RM Roy Munge (Nawi), CL Carl Leitner (WHO), RR Ritika Rawlani (WHO), JCT Jose Costa Teixeira, FH Fred Hersch (OHS Foundation), JT Jing Tang, GM Garrett Mehl, DW Diana Wijayanti, AM Alvin Marcelo, Mark Landry.

## Links
- Library spec and Kotlin code: https://litlfred.github.io/smart-trust-tools and https://github.com/litlfred/smart-trust-tools
- Worked example and verification steps: https://github.com/WorldHealthOrganization/smart-trust/blob/main/input/pagecontent/qr_code_generation.md
- PreQual CodeSystems: https://worldhealthorganization.github.io/smart-pcmt-vaxprequal/
- GDHCN DEV trust list endpoints: https://smart.who.int/trust/endpoints.html
- DVC logical models: https://smart.who.int/trust-phw/artifacts.html
- IHE ITI VHL: https://build.fhir.org/ig/IHE/ITI.VHL/
- ITB helper tooling: https://github.com/WorldHealthOrganization/WHO-ITB and https://github.com/WorldHealthOrganization/gdhcn-validator
- Storyboard template: https://diegokaminker.github.io/APAC27/teweia-ips-connectathon/teweia-ips-year1.html

## Conventions for working here
- Keep the tracker as the only list of actions; the Google doc holds journeys, decisions and the spec.
- One issue per application or component; do not split an app into many small tickets.
- Never commit private keys, DSC key files or anything from WHO that is not already public. This repository is public.
- Write plainly; no em dashes.

---
title: "NE-5: Terminology and schedule content package (J1 to J3)"
labels: nawi-engineering, content, ig, TECH-09
---
## Why this exists
The vignette's governance story is a terminology gap, so the terminology has to be precise. The DVC identifies a vaccine by WHO PreQual product ID (required binding). Schedules run on vaccine types and doses. Three layers, two of them WHO's, one national:
1. WHO PreQualProductIds (what the certificate carries), https://worldhealthorganization.github.io/smart-pcmt-vaxprequal/CodeSystem-PreQualProductIds.html
2. WHO PreQualVaccineType (HepB, BCG, bOPV and so on), https://worldhealthorganization.github.io/smart-pcmt-vaxprequal/CodeSystem-PreQualVaccineType.html
3. The Lao PDR schedule-dose ValueSet and the national ConceptMap from vaccine type to schedule dose, which is deliberately partial: HepB maps to HB0-24H, BCG has no target.

No Thai code system is needed.

## Build (as IG artefacts, pulled into the Player configuration)
1. Import the two WHO CodeSystems. Until Ritika adds display names to PreQualProductIds, add a local display table for the demo products (HepB paediatric `a3K3X000006MiiXUAS`, the BCG product used in the worked example).
2. Product-to-type ConceptMap: use WHO's if published by then (requested from Ritika), otherwise a local one covering the demo products.
3. Lao PDR schedule-dose CodeSystem and ValueSet (from the real Lao list if Alvin Marcelo supplies it, otherwise a credible placeholder: HepB birth dose, BCG, OPV1 to 3, Penta1 to 3, PCV, MR and so on).
4. Type-to-dose ConceptMap for Laos, partial on purpose.
5. Lao schedule PlanDefinition with FHIRPath conditions over Immunization history, covering at least the doses between birth and the first birthday, in the SMART Guidelines L3 style so the schedule is content, not code.
6. Seed data that uses all of the above, dated with placeholders (final dates once certificates are regenerated).

## Acceptance
- The Player build passes its config gates with these artefacts in place.
- Scanning the worked-example certificates in NE-2 shows product names.
- In NE-3 the HepB product resolves to type HepB and maps to HB0-24H without a prompt; BCG resolves to type BCG, finds no Lao target, and the confirm step appears (so the two cards show both paths). Full current text: issue #7.
- The PlanDefinition produces the expected due list for the demo child.

Owner: Nawi engineering (Jing Tang reviewing), Roy Munge for the WHO requests. Parent: TECH-09. Due: 30 Oct for a first cut, 6 Nov final.

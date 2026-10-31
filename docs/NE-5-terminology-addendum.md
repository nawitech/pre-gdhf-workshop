# Addendum: terminology for NE-5 (and the NE-1 mapper)

Read with NE-1-handover.md. This updates the terminology plan after the Lao list arrived.

## What changed

- Lao PDR vaccine list received from Dr Theppouthone via Alvin Marcelo (`docs/Vacination_list_2026.xlsx` in the
  pre-gdhf-workshop repo). It is a list of schedule doses, not a terminology: there is no Lao CodeSystem, so we author one.
- The Lao list has no BCG and no OPV birth dose. Polio is OPV 1 to 3 and IPV 1 to 3.
- Agreed with Carl and Ritika: WHO will provide a ConceptMap from PreQual ProductId (as code) to commercial product name.
  That solves display names. It does not give the vaccine type, so our product-to-type map stays local until WHO publishes one.
- Terminology server: Ontoserver at tx.fhirlab.net (Alvin's endpoint), write access requested. It is the source of truth;
  the Player configurations bundle terminology generated from it for offline use. Apps never call it during the demo.
- Thailand's list is not needed for the certificate-to-schedule path (Thai certificates carry PreQual IDs, not Thai codes).
  Add a Thai schedule CodeSystem and map later if it arrives.

## Artefacts to build now (IG, then load to Ontoserver)

1. `CodeSystem/lao-epi-schedule-dose`: one concept per row of the Lao list, keeping its granularity
   (HB0 within 24 hours and within 7 days; MR1, MR2 and JE by age band; Penta, OPV, IPV, PCV, Rota by dose number).
   Codes stable and ASCII (for example `HB0-24H`, `HB0-7D`, `PENTA-1`, `MR1-9-11M`); display = the Lao row text.
2. `ValueSet/lao-epi-schedule-dose`: all of the above.
3. `ConceptMap/prequal-type-to-lao-dose` (source PreQualVaccineType, target the Lao CodeSystem), deliberately partial:
   HepB to HB0-24H for a dose at birth; BCG unmapped. Other types map to their first dose where relevant.
4. `ConceptMap/prequal-product-to-type-local`: the two demo products only (HepB paediatric `a3K3X000006MiiXUAS`,
   the BCG product in the worked example). Mark it as local and provisional; replace with WHO's if published.
5. When WHO's ProductId to commercial name ConceptMap lands, use it for display; until then a local display table.
6. Lao schedule PlanDefinition over the Lao CodeSystem, birth to first birthday at minimum.

## Effect on the demo flow (update NE-3 and NE-5 acceptance)

- The HepB card maps cleanly to HB0-24H: no clinician prompt.
- The BCG card has no Lao target: this is now the card that triggers the clinician-confirm step and the governance story.
- The NE-1 mapper is unchanged: it stores the PreQual coding as issued; the Lao coding is added only at J3 after confirmation
  (or automatically when the ConceptMap has a target, recorded as such).

## Open questions for Alvin

- Is BCG genuinely absent from the Lao schedule or only from this sheet?
- Three IPV doses is unusual; confirm.
- Thailand list when available.

# Photon LAB-08 — Data Ingestion Feasibility Discovery

## 1. Purpose, authority and immutable limits

This document resolves the **documentary discovery** portion of `LAB-08`: how
Peru-relevant geographic data could become a Photon 1.3.0-compatible input for
a future isolated proof of concept. It refines the data-ingestion uncertainty
identified by the merged Photon isolated-lab contract; it neither replaces that
contract nor selects a provider, dataset, execution environment or pipeline.

```ini
DOCUMENT_DATE = 2026-10-08
REPOSITORY_BASELINE = 62ded92c0cc34053cca6ae6e1e769e1a77a1b486
PR_73 = MERGED
LAB_08 = OPEN
PHOTON_CANDIDATE = 1.3.0
PHOTON_MODE_CANDIDATE = EMBEDDED_PRIVATE_LOOPBACK
DOCUMENTARY_DISCOVERY = COMPLETED
LAB_EXECUTION = NOT_AUTHORIZED
VM_CREATION = NOT_AUTHORIZED
OSM_DOWNLOAD = NOT_AUTHORIZED
PHOTON_INSTALLATION = NOT_AUTHORIZED
NOMINATIM_INSTALLATION = NOT_AUTHORIZED
DATA_PIPELINE_IMPLEMENTATION = NOT_AUTHORIZED
PROVIDER_SELECTION = NOT_AUTHORIZED
SEARCHPLACES_IMPLEMENTATION = NOT_AUTHORIZED
P12_CONTRACT = UNCHANGED
P12_5 = NOT_AUTHORIZED
P12_CLOSURE = NOT_AUTHORIZED
```

No software, source data, index, VM, service, endpoint or pipeline was created,
downloaded, installed or executed for this discovery. Any values below labelled
**DISCOVERY FACT** are documentary observations as of the date above. Values
labelled **HYPOTHESIS** or **NOT MEASURED** must never be treated as lab results.

## 2. Confirmed Photon input boundary

Photon 1.3.0 documents two import paths:

1. a Nominatim database; or
2. a Photon JSON dump supplied through `-import-file`.

It does **not** document direct import of an `.osm.pbf` file. A Peru PBF can be
the provenance source for a preparation path, but it is not itself an executable
Photon input. Photon also documents `dump-nominatim-db` for producing a JSON
dump from a Nominatim database. For an import from either a database or file,
`-country-codes` restricts the imported records to a comma-separated list of
two-letter country codes. This is a documented import-filter capability, not a
claim that a `PE` import is complete, POI-preserving, correctly ranked or within
a given resource envelope. Whether a given dump, its country-code data and
Photon 1.3.0 produce a sufficiently complete Peru index remains a lab hypothesis
until measured.

| Item | Documentary finding | Classification | Consequence |
|---|---|---|---|
| Photon version | Release `1.3.0` is the lab candidate. | Confirmed candidate | Match data dumps to the Photon `1.x` major series and verify exact compatibility in preflight. |
| Embedded mode | Photon documents embedded OpenSearch as its default for small/medium use; its listener defaults to loopback. | DISCOVERY FACT | Remains the proposed private-lab query mode. |
| External OpenSearch | Documented for scalable/distributed use. | DISCOVERY FACT | `EXTERNAL_OPENSEARCH = NOT_SELECTED`. |
| Raw OSM PBF | Not a documented Photon import input. | DISCOVERY FACT | Never treat a Geofabrik PBF as a direct import command. |
| Nominatim database | A documented Photon import source. | DISCOVERY FACT | Requires a separate preparation environment and approval. |
| Photon JSON dump | A documented Photon import source. | DISCOVERY FACT | Requires a compatible dump, source pinning and an authorized import. |

Official sources: [Photon 1.3.0 usage documentation](https://github.com/komoot/photon/blob/1.3.0/docs/usage.md) and [Photon 1.3.0 release](https://github.com/komoot/photon/releases/tag/1.3.0).

## 3. Available documented source candidates

The official GraphHopper Photon download listing observed on 2026-10-08 offers
South America `1.x` ready database and JSON-dump artifacts. Its country listing
includes Peru (`PE`) but reports no dedicated Peru ready database. This makes a
South America artifact a coverage candidate, not proof of Peru search quality or
an approval to use regional data beyond Peru.

The listing showed a South America ready database near 7.3 GB and a South
America JSON dump near 2.3 GB at discovery time. These are mutable publication
facts, **not** storage, memory, import-time or cost estimates. A future
execution must pin the actual URL, timestamp, upstream published checksum and
licence record immediately before download; no artifact is pinned here.

Geofabrik publishes a Peru `.osm.pbf` extract. It is a plausible provenance
source for Nominatim preparation, not a direct Photon input. Its published size
at discovery must not be used to predict Nominatim database size, temporary
space, Photon index size or import duration.

| Source | Geographic disposition | Photon usability | Provenance/checksum disposition |
|---|---|---|---|
| Photon South America ready database (`1.x`) | Includes Peru within South America; no Peru-only ready database observed. | Query-ready candidate after a compatible, authorized acquisition. | Upstream listing provides companion MD5 references; actual artifact verification is `NOT_EXECUTED`. |
| Photon South America JSON dump (`1.x`) | Includes Peru within South America. | Documented `-import-file` candidate; may support an import restriction, unmeasured. | Pin URL, publication time, upstream checksum and licence before authorized use. |
| Geofabrik Peru PBF | Peru regional source. | Requires a Nominatim preparation stage before Photon import. | Pin extract URL, timestamp and published checksum before authorized use. |

Sources: [Photon South America downloads](https://download1.graphhopper.com/public/south-america/index.html) and [Geofabrik Peru](https://download.geofabrik.de/south-america/peru.html).

## 4. Ingestion alternatives

### A. Existing compatible Photon ready database — South America `1.x`

A prebuilt South America Photon ready database is the lowest-complexity
candidate for an initial isolated query PoC. It avoids building Nominatim and
avoids a local data-conversion pipeline. It is still an import/acquisition
operation, therefore it remains prohibited until an execution gate grants it.

- **Data preparation:** Upstream has already built the index; this discovery did
  not verify its method, freshness, country composition or recoverability.
- **Photon query environment:** A dedicated private/loopback Photon runtime with
  its `photon_data` directory and bounded logs is still required.
- **Peru fit:** Coverage is regional rather than Peru-only. The fixed Peru and
  tourism corpus remains `NOT_EXECUTED`; inclusion of `PE` does not prove result
  quality, Spanish labels, tourist POIs or homonym treatment.
- **Recovery:** Reacquire only the same pinned artifact and checksum, then
  recreate the dedicated data directory. This is a proposed procedure, not a
  tested recovery result.
- **Update:** The upstream publication cadence and compatibility must be checked
  at the future execution gate; no update cadence is selected.

### B. Peru PBF -> Nominatim regional preparation -> Photon

Nominatim can import an OSM file and Photon can import from a Nominatim
database. This is the documented route to a Peru-specific preparation path. It
is technically plausible but operationally the heaviest option: it introduces
PostgreSQL, PostGIS, osm2pgsql, Python and Nominatim import administration
before Photon consumes the resulting database or JSON dump.

- **Data preparation:** Nominatim documents PostgreSQL 12+ (13 strongly
  recommended), PostGIS 3.0+ (3.2 strongly recommended), osm2pgsql 1.8+ and
  Python 3.9+ as prerequisites. Its documentation notes that country extracts
  reduce database size and import time, but it publishes no Peru-specific
  capacity guarantee suitable for this lab.
- **Photon query environment:** Separate from preparation resources; final
  Photon query requirements must be measured after the data is imported.
- **Data completeness:** A full Nominatim import style is needed to assess
  place/POI search. Reverse-only optimisation is not a substitute for this
  search-quality purpose without a future compatibility validation.
- **Recovery/update:** Potentially supports a controlled Nominatim maintenance
  path, but Photon 1.3.0 update compatibility and the operational procedure are
  unmeasured. No update design is approved.
- **Status:** `PIPELINE = NOT_AUTHORIZED`; no Nominatim component, PBF or
  database has been obtained.

Sources: [Nominatim installation](https://nominatim.org/release-docs/latest/admin/Installation/) and [Nominatim import](https://nominatim.org/release-docs/latest/admin/Import/).

### C. Existing compatible Photon JSON dump — South America `1.x`

Photon documents importing a JSON dump through `-import-file`. The official
South America `1.x` dump is a candidate that avoids Nominatim preparation but
still requires an authorized Photon import to create the final index. Photon
also documents `-country-codes`; using it to build a Peru-restricted index is a
**HYPOTHESIS**, not an evaluated outcome, because quality and completeness have
not been measured against the fixed corpus.

- **Data preparation:** No Nominatim database is necessary if the compatible
  upstream JSON dump is selected.
- **Photon query environment:** Requires an isolated import/runtime host, input
  handling, temporary decompression space, index creation and a private query
  process.
- **Peru fit:** `-country-codes PE` is documented to restrict imported records
  by two-letter country code. It could reduce scope, but it does not establish
  country-code completeness, POI retention, ranking quality or resource use.
  The corpus must test those outcomes; do not assume that every desired Peru
  POI carries the expected country code.
- **Recovery/update:** A controlled reimport from the same pinned dump is a
  candidate recovery path. It has not been exercised.
- **Status:** `IMPORT = NOT_AUTHORIZED`; no JSON dump was downloaded or tested.

## 5. Comparative feasibility matrix

| Dimension | A. South America ready DB | B. Peru PBF -> Nominatim -> Photon | C. South America JSON -> Photon import |
|---|---|---|---|
| Photon compatibility basis | `1.x` upstream ready DB; exact 1.3.0 verification pending. | Photon documented Nominatim database import. | Photon documented JSON `-import-file`; exact dump/1.3.0 verification pending. |
| Peru regionality | South America only. | Peru-specific candidate. | South America source; possible Peru restriction is unmeasured. |
| New preparation systems | None locally beyond Photon runtime. | PostgreSQL/PostGIS, osm2pgsql, Python and Nominatim. | Photon import only. |
| Pipeline complexity | Lowest. | Highest. | Medium. |
| Resource measurement needed | Runtime disk/RAM/CPU and decompression/recovery headroom. | Preparation plus runtime: DB, import intermediates, Photon index and recovery. | Import plus runtime: decompression, temporary space, index, CPU/RAM and recovery. |
| Import duration | `NOT_MEASURED`. | `NOT_MEASURED`. | `NOT_MEASURED`. |
| Update path | Artifact replacement/recreation candidate; cadence not selected. | Potential Nominatim maintenance path; unmeasured. | Reimport candidate; incremental update not established. |
| Reproducibility | Pin upstream artifact, checksum, version and configuration. | Pin PBF, Nominatim/Photon versions, import configuration and every intermediate. | Pin dump, Photon version, import options and output configuration. |
| Spanish labels and variants | Ready artifact language configuration and included translations are unknown until pinned and inspected. | Depends on Nominatim source data plus Photon `-languages`; both configuration and outputs must be measured. | Photon `-languages` can be fixed at authorized import, but source tags/translations and actual returned variants remain unmeasured. |
| Evidence needed for Spanish decision | Pinned artifact metadata, request-language configuration and corpus outputs in Spanish/variants. | Pinned source/configuration, Photon import options and corpus outputs in Spanish/variants. | Pinned dump, explicit `-languages` configuration and corpus outputs in Spanish/variants. |
| Primary risk | Regional scope, unknown language configuration and artifact/runtime capacity. | Operational complexity and unmeasured data pipeline. | Import capacity, language/configuration variation and unmeasured effect of any country restriction. |
| Discovery disposition | **Preferred conditional first PoC candidate.** | Contingency only if a Peru-specific index is materially required. | Secondary controlled experiment if a regional ready DB is unsuitable. |

## 6. Resource, maintenance and recovery separation

The following deliberately separates preparation resources from query-serving
resources. The documented 4 vCPU / 16 GiB / 100 GiB minimum candidate and 8
vCPU / 32 GiB / 200 GiB recommended candidate in the lab contract remain
**HYPOTHESES**. They are not validated by download sizes or by this discovery.

| Alternative | Preparation CPU/RAM/disk/temp/time | Photon query CPU/RAM/disk | Maintenance and recovery | Evidence status |
|---|---|---|---|---|
| A | No local index build identified; artifact acquisition and decompression headroom still require measurement. | Dedicated Photon data, OS headroom and bounded logs require measurement. | Replace/recreate from pinned artifact; untested. | `NOT_MEASURED` |
| B | Separate Nominatim DB import, OSM processing, PostgreSQL/PostGIS and intermediates; all resource values require measurement. | Must be measured independently after Photon import. | Nominatim update/rebuild plus Photon regeneration; untested. | `NOT_MEASURED` |
| C | Input stream/decompression, Photon import and output-index creation; all values require measurement. | Must be measured independently after import. | Reimport from pinned JSON artifact; untested. | `NOT_MEASURED` |

No infrastructure price, staff time, resource consumption, import duration or
recovery objective is calculated by this document. Those remain inputs to the
approved feasibility TCO model after a bounded and separately authorized lab.

## 7. Quality, corpus and coverage controls

All alternatives must be evaluated only against the previously designed Peru and
tourism corpus: Lima, Canta, Obrajillo, Santa Rosa de Quives, Ica, Huacachina,
Nazca, Paracas, Pachacámac, Plaza de Armas de Canta, the approved homonyms, and
the broader tourism set. The future evaluation retains Top-1, Top-3, Top-5,
Hit@10 and MRR@10, Spanish-variation checks, geographic context, duplicates,
POI types and the A/B Peru-bias comparison.

```ini
PROVIDER_RANKING = NOT_EXECUTED
GEOGUIDE_COMBINED_RANKING = NOT_EXECUTED
PERU_COVERAGE = NOT_MEASURED
TOURISM_POI_COVERAGE = NOT_MEASURED
SPANISH_LOCALISATION = NOT_MEASURED
HOMONYM_HANDLING = NOT_MEASURED
POSTAL_ADDRESS_SCOPE = OUT_OF_SCOPE
```

Photon imports local names and only the translations selected by `-languages`.
Photon 1.3.0 defaults to English, German, French and Italian translations where
available; Spanish must therefore be explicitly included in a future authorized
import configuration. Ready database artifacts may have been built with a
configuration different from a JSON import controlled by GeoGuide. In every
path, Spanish labels, spelling variants and fallback behavior depend on the
source data and must be measured through the fixed corpus.

The selection of a regional artifact does not establish quality. The corpus and
metrics assess a standalone external provider only; they do not validate the
future curated-catalogue-plus-external SearchPlaces ranking.

## 8. Security, privacy, licensing and provenance

- OSM data is made available under the ODbL. A future use must give the required
  OpenStreetMap attribution and evaluate derived-database/share-alike duties for
  the exact distribution and lab outputs. This document is not legal approval.
- Preserve source URL, publication timestamp, source licence, artifact version,
  upstream published checksum and a local post-download SHA-256 in a future
  evidence record. The local SHA-256 is an integrity observation, not a
  replacement for the upstream checksum.
- Treat third-party artifact delivery as an external-source risk: use the
  official publisher endpoint selected at the execution gate; reject a missing
  or mismatched checksum/provenance record.
- Keep the lab isolated, private/loopback-only and free of GeoGuide credentials,
  production data, user queries, precise GPS coordinates and personal search
  history.
- Keep only aggregate test metrics and redacted operational evidence for the
  already-proposed maximum seven-day retention. Validate deletion during an
  authorized run; no deletion result exists now.
- A source refresh must repeat provenance and checksum capture. No refresh
  schedule is chosen in this discovery.

Source: [OpenStreetMap copyright and licence](https://www.openstreetmap.org/copyright).

## 9. Conditional recommendation and human decisions

```ini
RECOMMENDATION = CONDITIONAL_READY_DB_FIRST
FIRST_LAB_CANDIDATE = OFFICIAL_PHOTON_SOUTH_AMERICA_1_X_READY_DATABASE
FALLBACK_CANDIDATE = OFFICIAL_PHOTON_SOUTH_AMERICA_1_X_JSON_IMPORT
PERU_SPECIFIC_CONTINGENCY = NOMINATIM_PREPARATION_PIPELINE
PHOTON_MODE_CANDIDATE = EMBEDDED_PRIVATE_LOOPBACK
EXTERNAL_OPENSEARCH = NOT_SELECTED
PROVIDER_SELECTED = NO
LAB_EXECUTION = NOT_AUTHORIZED
```

For the first isolated query PoC, Alternative A is conditionally recommended
because it removes the unapproved Nominatim preparation stack and does not
require developing a pipeline. It must not proceed until a human accepts that a
South America dataset is permissible for the non-production lab, approves the
isolated resource envelope, and authorizes the exact artifact acquisition. If a
Peru-only index is mandatory, that is a material choice: Alternative C requires
an experimentally verified restriction, while Alternative B introduces a new
Nominatim preparation operation. Neither is selected here.

| Decision | Question | Why human approval is required |
|---|---|---|
| `D-LAB08-01` | Is a South America artifact acceptable for the isolated PoC, or is Peru-only data mandatory? | Determines the selected ingestion path and data scope. |
| `D-LAB08-02` | Which exact artifact, release compatibility rule and published checksum capture procedure are approved? | Pins external provenance and reproducibility. |
| `D-LAB08-03` | Is the proposed isolated VM allocation and eight-hour bounded window approved after capacity/cost review? | The resource envelope remains a hypothesis. |
| `D-LAB08-04` | Is the ODbL attribution/derived-data treatment approved for the selected lab use and retained evidence? | Legal/compliance disposition is not implied by technical discovery. |
| `D-LAB08-05` | Should the first lab measure only a one-time import/query PoC, or also evaluate a refresh/recovery procedure? | Changes duration, risk and expected evidence. |
| `D-LAB08-06` | If Peru-only is required, is a Nominatim preparation pipeline authorized after its own execution contract? | It adds systems and a data-processing operation outside this discovery. |

## 10. Exit conditions for LAB-08

`LAB-08` remains open until an approved execution plan supplies all of the
following without changing the P12 or SearchPlaces contracts:

1. a human-approved ingestion alternative and exact pinned data artifact;
2. an isolated VM/environment approval with explicit resource and cost limits;
3. a reproducible preflight that checks version, checksum, licence, isolation,
   private listener and storage headroom before any import;
4. an approved fixed corpus, metrics and pass/fail rules;
5. an evidence, retention, deletion, suspension and recovery procedure; and
6. a bounded laboratory authorization distinct from provider selection and
   SearchPlaces implementation.

Until then, all data quality, capacity, cost, import-duration, update and
recovery results are `NOT_EXECUTED`.

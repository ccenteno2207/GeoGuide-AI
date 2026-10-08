# Route Input Search Provider — Feasibility Evidence

## 1. State, purpose and boundaries

This document records a limited, reproducible feasibility evaluation for the future **places-and-POIs-only** route-input capability. It complements, but does not change, [the approved Route Input design](Route-Input-and-Destination-Search-Discovery.md).

```ini
EVALUATION_DATE = 2026-10-08
REPOSITORY_BASELINE = ba886be388d3cee8f7db8f00cd82e0d85df5f6c3
ROUTE_INPUT_DESIGN = APPROVED
ROUTE_INPUT_PROVIDER = NOT_SELECTED
ROUTE_INPUT_IMPLEMENTATION = NOT_AUTHORIZED
ROUTE_INPUT_INFRASTRUCTURE = NOT_AUTHORIZED
P12_CONTRACT = UNCHANGED
P12_5 = NOT_AUTHORIZED
PROVIDER_FEASIBILITY = DOCUMENTARY_AND_POLICY_COMPLIANT_QUERY_EVIDENCE
PERU_COVERAGE = PARTIAL_PUBLIC_SAMPLE_ONLY
PHOTON_PREFERRED_CANDIDATE = CONDITIONAL
```

No service was installed, no dataset was downloaded, and no endpoint, code, database, infrastructure, permission or P12 contract was changed. The public queries below are exploratory evidence only. They do not establish production availability, self-hosted coverage, performance, or a selected provider.

## 2. Scope and reproducible Peru corpus

The future product scope remains localities, geographic places, tourism attractions and POIs. Postal-address search is excluded. A future acceptance evaluation must use the following corpus with a pinned data extract, provider release and execution timestamp:

| Group | Queries / cases | Expected assessment |
|---|---|---|
| Core corridor | Lima; Canta; Obrajillo; Santa Rosa de Quives; Plaza de Armas de Canta | Correct Peruvian candidate, usable geographic context and no silent substitution. |
| Tourism places | Ica; Huacachina; Nazca; Paracas; Pachacámac | Place/POI candidates with enough locality or regional context to disambiguate. |
| Writing variants | Pachacamac/Pachacámac; Obrajillo; plaza de armas canta | Accent, casing and token-order tolerance must be measured. |
| Homonyms | Huacachina; Canta; Lima | The UI must show context and require confirmation; ranking alone is not identity. |
| Negative cases | A deliberately nonexistent place; empty/too-short input | A controlled empty/validation result, preserving any confirmed route point. |
| Postal negative control | Avenida Perú 2469 | A provider can return it, but the GeoGuide AI boundary must reject it as out of scope. |

The corpus is a test specification, not an assertion that every entry is already covered by every provider.

## 3. Limited public-query evidence

### 3.1 Method and policy controls

On 2026-10-08, five human-scale, serial queries were sent to each public demo. Nominatim calls used an identifying User-Agent, `countrycodes=pe`, a result limit of three, and more than one second between requests. This follows the [Nominatim public-service policy](https://operations.osmfoundation.org/policies/nominatim/): the public endpoint is rate-limited, forbids client autocomplete and bulk use, and must not become an operational dependency. Photon calls used its public demo with a limit of three. Its demo is likewise not an availability-guaranteed runtime service ([Photon project documentation](https://github.com/komoot/photon)).

The observed data below deliberately omits coordinates. The inputs are public place names, not a user location or a travel history.

| Query | Nominatim public observation | Photon public observation | Evaluation implication |
|---|---|---|---|
| Lima | Peruvian city/administrative candidates returned. | Lima, Peru was first; same-name non-Peru candidates also appeared. | Country/context handling and explicit confirmation are required. |
| Canta | Peruvian administrative/town candidates returned. | A Peru Canta candidate appeared behind a similarly named French candidate. | A ranking result cannot be treated as an unambiguous `RoutePoint`. |
| Huacachina | Ica oasis/village candidates and a Loreto homonym returned. | Ica candidates and a Loreto homonym returned. | Geographic context is mandatory for homonyms. |
| Plaza de Armas de Canta | Peruvian park candidate returned. | Canta park candidate and a nearby similarly named park returned. | Tourism/POI queries can resolve, but duplicate/nearby presentation remains required. |
| Avenida Perú 2469 | A house/address result returned. | Address-like candidates returned. | The planned product boundary must reject postal-address intent/results. |

The first Photon attempts specified `lang=es` and received HTTP 400 stating that its public demo currently supports only `default`, `de`, `en` and `fr`. The table uses the subsequent `lang=en` observations. This is a real localization compatibility risk, not a reason to infer Spanish coverage or localization quality.

No Pelias public endpoint was used. Its upstream repository describes a self-hosted modular project rather than an official shared production endpoint; testing an arbitrary third-party deployment would not evidence Pelias itself.

## 4. Provider matrix

| Criterion | Photon self-hosted | Nominatim self-hosted | Pelias self-hosted |
|---|---|---|---|
| Fit for place/POI input | Strong candidate: prefix-style, multilingual and place/POI-oriented search features are documented. | Suitable geocoding/search baseline; product must constrain its results to places/POIs. | Capable composition of OSM/open-data sources, but broader than the minimum. |
| Limited Peru evidence | Public-demo sample resolves Lima, Canta, Huacachina and Plaza de Armas de Canta; full corpus untested. | Public sample resolves the same five queried cases; full corpus untested. | No controlled Peru evidence collected. |
| Runtime components | Java 21+; optional external OpenSearch 3.x for current documented mode. | PostgreSQL/PostGIS and an import/update workflow. | Elasticsearch 7/8 plus multiple data importers/services. |
| Operational complexity | Moderate, but regional extraction, index refresh, rollback and capacity are unmeasured. | Moderate/high due to database import/update operations. | Highest of the three due to component/data-source composition. |
| Privacy fit | Strong only when self-hosted with application log redaction, no implicit GPS and retention controls. | Same when self-hosted; public endpoint is not eligible as a runtime provider. | Strong only when self-hosted with the same controls. |
| Software/data licence work | Photon software is Apache-2.0; OSM data attribution/licensing remains separate. | Must review Nominatim/OSM terms and attribution for chosen release/data. | Must review every imported source and component licence. |
| Cost state | No per-request vendor fee implied; compute, SSD, update and operator costs unmeasured. | Same. | Same, with likely greater operational cost; no measured quote. |
| Current disposition | **Conditional preferred candidate.** | Controlled fallback/comparator, not public runtime. | Deferred unless coverage evidence justifies its complexity. |

Sources: [Photon](https://github.com/komoot/photon), [Nominatim installation](https://nominatim.org/release-docs/latest/admin/Installation/), [Nominatim public-service policy](https://operations.osmfoundation.org/policies/nominatim/), and [Pelias](https://github.com/pelias/pelias).

## 5. Infrastructure, security and operation

### 5.1 Official requirements versus unmeasured estimates

| Item | Official/documented fact | Not yet measured or approved |
|---|---|---|
| Photon | Java 21+; current docs describe OpenSearch 3.x for an external index. The documented global/planet reference is approximately 95 GB disk and at least 64 GB RAM. | A Peru-only extract's availability, checksum, licence, final index size, import duration, peak RAM/CPU, and update/rollback headroom. Planet numbers must not be used as a Peru estimate. |
| Nominatim | Official installation documentation describes a PostgreSQL/PostGIS-based import and maintenance process. | Peru-extract sizing, index/import time, update operations, resource peak and recovery time. |
| Pelias | Upstream documents Elasticsearch 7/8 support and a modular importer/API stack. | Exact enabled components, Peru data sources, capacity, recovery, and any operational owner/cost. |

No existing production PostgreSQL/PostGIS instance may be reused for this evaluation without an approved isolation and recovery plan. A later controlled evaluation must also verify TLS termination, service isolation, authentication where applicable, rate limits, request-size/time limits, abuse protection, health checks, backups/rebuild instructions and a tested rollback.

### 5.2 Privacy and retention compatibility

All candidates are compatible only with the approved application policy:

- no persisted search history;
- no implicit external transmission of current GPS coordinates;
- no query text or precise coordinates in application, proxy or provider logs;
- no shared cache in the initial release; and
- aggregate, non-identifying operational metrics retained for **at most seven days**.

These are future implementation controls. This evaluation did not deploy a service or validate log configuration, deletion, access controls or retention.

## 6. Cost, risks and evidence gaps

| Area | Current evidence | Risk / gap | Required later evidence |
|---|---|---|---|
| Coverage | Five limited public queries per candidate demo for Photon/Nominatim. | Not reproducible against a pinned self-hosted data extract; variants and most corpus entries untested. | Full corpus results, data provenance/checksum, version and timestamp. |
| Photon localization | Demo rejected `lang=es`; English query output worked. | Spanish UI/data localisation may require a different parameter, data configuration or fallback presentation. | Exact Photon release/configuration tests with Spanish labels. |
| Resources | Planet-scale Photon values are documented. | Peru scope cannot be inferred; capacity and cost unknown. | Isolated import measurements and a resource/cost proposal. |
| Availability and abuse | Public services publish restrictions; self-hosting is possible. | No SLA, owner, monitoring, quota or incident process approved. | Operational ownership and protection plan. |
| Licence/attribution | Upstream software references are available. | Data-extract and component licence obligations remain unpinned. | Release/data licence review and attribution copy. |
| Privacy | Design policy is approved. | No deployed log/retention configuration has been verified. | Configuration inspection and deletion/retention evidence. |
| Recovery | Rebuild concept is known. | No index update, rollback or recovery drill exists. | Rebuild/update/rollback runbook and isolated drill. |

## 7. Conditional recommendation and human decisions

```ini
RECOMMENDATION = PHOTON_SELF_HOSTED_FOR_CONTROLLED_ISOLATED_EVALUATION
RECOMMENDATION_CONDITION = NOT_A_PROVIDER_SELECTION
PROVIDER_SELECTED = NO
INFRA_DEPLOYMENT = NOT_AUTHORIZED
IMPLEMENTATION = NOT_AUTHORIZED
```

Photon remains the conditional first candidate because its documented place-oriented features align with the minimum scope and its operating shape is materially simpler than a Pelias composition. This is not a final selection: the public sample is too small, it found ranking/localization limitations, and self-hosted Peru data and resource requirements have not been evidenced. Nominatim remains the comparator and a potential later self-hosted fallback; the public endpoint must never be adopted as the production backend. Pelias is deferred unless a controlled coverage evaluation proves a benefit that justifies its additional operating burden.

The following require a human gate before any installation, import, deployment or implementation:

1. Approve or reject an **isolated**, non-production provider evaluation environment and its resource/budget ceiling.
2. Select the candidate release, data extract source, licensing/attribution obligations, operational owner and update cadence.
3. Approve the full Peru corpus, ranking thresholds and the treatment of Spanish/localization quality.
4. Approve the privacy/logging/metric implementation design and seven-day retention verification method.
5. Select a provider only after the controlled evaluation records coverage, capacity, security and recovery evidence.

Until those decisions exist, the Route Input design remains approved but its provider, infrastructure, contract freeze and implementation remain pending.

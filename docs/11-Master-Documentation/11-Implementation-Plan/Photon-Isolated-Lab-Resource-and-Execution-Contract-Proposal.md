# Photon Isolated Lab — Resource and Execution Contract Proposal

## 1. Purpose, authority and hard limits

This is a proposed technical contract for an **isolated, non-production Photon
laboratory** using Peru OSM data. It follows the approved SearchPlaces provider
feasibility documentation and does not select a provider or authorize a lab.

```ini
DOCUMENT_DATE = 2026-10-08
REPOSITORY_BASELINE = 41f18b2c3efd443dd91daeb0c85417c9663134dd
PR_72 = MERGED
PROVIDER_FEASIBILITY_DOCUMENTATION = APPROVED
PHOTON = PREFERRED_FOR_ISOLATED_POC
PROVIDER_SELECTED = NO
LAB_DISCOVERY = COMPLETED_DOCUMENTARY_ONLY
LAB_CONTRACT = PROPOSED_NOT_APPROVED
LAB_EXECUTION = NOT_AUTHORIZED
IMPLEMENTATION = NOT_AUTHORIZED
INFRA_DEPLOYMENT = NOT_AUTHORIZED
P12_CONTRACT = UNCHANGED
P12_5 = NOT_AUTHORIZED
```

This proposal authorizes neither installation nor download, data import, Docker
or VM changes, service exposure, load testing, `SearchPlaces` implementation,
provider selection, production deployment or P12.5. All capacity statements
labelled **HYPOTHESIS** are planning caps only, never measurements.

## 2. Read-only capacity inventory

### 2.1 Windows laptop / WSL2 / Docker

| Item | Observation on 2026-10-08 | Classification | Lab suitability |
|---|---|---|---|
| CPU | Intel Core i5-4210M; 2 physical cores / 4 logical processors | Measured locally | Insufficient margin for a controlled local import. |
| RAM | 7.92 GiB total; 1.10 GiB free at inspection | Measured locally | Not suitable. |
| Storage | C: 43.89 GiB free; D: 163.07 GiB free; media type not measured | Measured free capacity; disk type not measured | RAM remains the limiting factor. |
| WSL | WSL 2 default; no Linux distribution installed | Measured locally | Not available without an unauthorized install. |
| Docker | Docker CLI/engine unavailable on PATH | Measured locally | Not available without an unauthorized install/configuration. |
| Hypervisor | No active Windows hypervisor reported | Measured locally | No local VM assumption is allowed. |

**Disposition:** `LAPTOP_LAB = REJECTED_FOR_CURRENT_CAPACITY`. This is an
objective suitability finding, not a request to change the laptop.

### 2.2 Existing GeoGuide AI integration VM — reference only

Read-only SSH inspection observed a Linux VM with 4 logical CPUs, 15 GiB RAM
(13 GiB available at observation), 132 GiB free on a 156 GiB root filesystem,
and a rotational 160 GiB virtual disk. Docker 29.7.2 and Docker Compose v5.4.0
are present. The active GeoGuide stack includes Nginx, backend, GraphHopper,
Redis, MinIO and PostGIS; GraphHopper alone carries a 5 GiB memory limit.

```ini
INTEGRATION_VM = IN_USE_BY_GEOGUIDE_AI
INTEGRATION_VM_LAB_ELIGIBILITY = REJECTED
REASON = NO_SHARED_RESOURCES_OR_INTERFERENCE_AUTHORIZED
```

These observations are capacity reference points only. They do not authorize
Docker inspection beyond the recorded read-only inventory, deployment,
configuration changes, data import or a Photon container on that VM.

### 2.3 Independent VM

```ini
INDEPENDENT_VM = NOT_MEASURED
INDEPENDENT_VM_AVAILABLE = UNKNOWN
```

No independent VM was discovered or provisioned. Its capacity, disk type,
network isolation and cost must be verified only after a human authorizes an
isolated lab environment.

## 3. Photon and data candidate

| Topic | Candidate / documented fact | Status |
|---|---|---|
| Photon release | `1.3.0`, Git tag `4c28c7c132694d72673a2475ddab854bd32dac71` | Candidate, not installed. |
| Java | Java 21 minimum requirement in Photon upstream release notes | Official requirement. |
| Index mode | Embedded is Photon’s documented default for small/medium deployments; external OpenSearch 3.x is documented for scalable/distributed configurations. | Official capability; mode not selected. |
| OSM source | Geofabrik Peru `peru-latest.osm.pbf` | Candidate source only; not downloaded. |
| Dataset version/checksum | Must pin timestamp, URL, checksum and licence immediately before an authorized import. | Not measured / not pinned. |
| Source file scale | Geofabrik published a current Peru PBF size of 244 MB at research time. | Source fact, not an index-size estimate. |
| Data licence | OSM data is under ODbL; attribution and any derived-database obligations require review before use beyond a lab. | Legal review pending. |
| Photon software licence | Apache-2.0, according to upstream repository. | Must be reconfirmed on selected release. |

Official sources: [Photon releases](https://github.com/komoot/photon/releases),
[Photon usage](https://github.com/komoot/photon/blob/master/docs/usage.md),
[Geofabrik Peru](https://download.geofabrik.de/south-america/peru.html), and
[OpenStreetMap licensing](https://www.openstreetmap.org/copyright).

Photon’s planet-scale reference must not be extrapolated to Peru. The isolated
lab exists precisely to measure Peru import size, peak CPU/RAM, query resource
usage, update/recovery behavior and coverage.

## 4. Candidate isolation design

```text
Isolated private VM/network
  ├─ Photon only, bound to loopback or a private lab network
  ├─ Dedicated volume: source, temporary import area and Photon data
  ├─ Dedicated non-production log location with redaction and seven-day cap
  ├─ Read-only client/evaluator path from an approved test workstation
  └─ No route to GeoGuide production/integration database, GraphHopper,
     Docker daemon, DNS/TLS configuration or application runtime
```

The lab must use a separately provisioned VM and volume. It must not reuse
GeoGuide PostgreSQL/PostGIS, Redis, MinIO, GraphHopper, Docker network, public
ports, DNS records, TLS certificates, credentials, production images or user
data. The planned default listener is private/loopback; public exposure is
forbidden. Destruction requires removal of the dedicated lab VM/volume only,
not a shared system resource.

## 5. Resource budget — hypotheses awaiting approval and measurement

| Dimension | Minimum candidate | Recommended candidate | Maximum laboratory cap | Evidence status |
|---|---:|---:|---:|---|
| vCPU | 4 | 8 | 8 | **HYPOTHESIS** |
| RAM | 16 GiB | 32 GiB | 32 GiB | **HYPOTHESIS** |
| SSD-backed storage | 100 GiB | 200 GiB | 200 GiB | **HYPOTHESIS** |
| Dedicated temporary import space | 40 GiB | 80 GiB | Included in storage cap | **HYPOTHESIS** |
| Test window | 8 hours | 8 hours | 8 hours per authorized run | **HYPOTHESIS** |
| Network exposure | none | none | private/loopback only | Contractual requirement |

The sizing has no measured basis yet. It is deliberately a bounded proposal for
an isolated first import, not a production recommendation. It must be refined
from actual measurements before any recurring update or operating commitment.

### 5.1 Suspension conditions

Immediately stop the lab and preserve only non-sensitive evidence if any of the
following occurs:

- measured CPU, RAM or storage would exceed its approved maximum;
- import/update threatens the lab host’s stability or its separation boundary;
- the data source checksum, provenance or licence cannot be recorded;
- a sensitive query, precise coordinate or user-identifying record appears in
  a log;
- a public listener, production/integration route, credential dependency or
  unapproved external service is required;
- Photon/version/data incompatibility prevents a controlled test; or
- an import, update or recovery action would exceed the approved test window.

These conditions do not authorize remediation on shared infrastructure. They
require evidence and a human decision.

## 6. Proposed evaluation contract

```ini
PROVIDER_RANKING = PLANNED_ISOLATED_LAB_ONLY
GEOGUIDE_COMBINED_RANKING = NOT_EXECUTED
```

The lab measures only **PROVIDER_RANKING** with the fixed corpus and the A/B
Peru-bias configurations defined in the merged provider-feasibility document.
It does not evaluate the future curated-catalogue-plus-external-ranking flow,
which remains `GEOGUIDE_COMBINED_RANKING = NOT_EXECUTED` until implementation
is separately authorized.

| Test area | Method | Required evidence | Result vocabulary |
|---|---|---|---|
| Ranking | Run fixed Peru and tourism corpus against pinned release/data/config. | Candidate identities, order, context, type and score sheet. | PASS / FAIL / NO_RESULT / NOT_EXECUTED |
| Ranking metrics | Compute Top-1/3/5, Hit@10 and MRR@10 from the reviewed sheet. | Formula inputs and aggregate calculation. | MEASURED / NOT_EXECUTED |
| Peru bias | Compare no-bias and documented Peru-preference requests. | Exact control type: `BIAS`, `BBOX_FILTER`, `COUNTRY_FILTER` or `UNSUPPORTED`. | MEASURED / NOT_EXECUTED |
| Spanish localisation | Record request-language support, labels and fallback behavior. | Version/configuration and non-personal outputs. | PASS / FAIL / NOT_EXECUTED |
| Postal exclusion | Query the defined postal negative control; review engine output separately from product policy. | Response classification; no claim that engine enforces product scope. | OBSERVED / NOT_EXECUTED |
| Latency/errors | Low-rate serial requests only; no load test. | Aggregate latency/error summaries without query text or coordinates. | MEASURED / NOT_EXECUTED |
| Resource use | Sample CPU, RAM, disk and import duration in the isolated VM. | Timestamped aggregate host metrics and data size. | MEASURED / NOT_EXECUTED |
| Update/recovery | Only after explicit execution approval; exercise documented update/rebuild/rollback. | Runbook, result, duration and integrity evidence. | PASS / FAIL / NOT_EXECUTED |
| Privacy/retention | Inspect lab configuration/log samples and expiry/deletion process. | Redacted configuration and seven-day retention/deletion evidence. | PASS / FAIL / NOT_EXECUTED |
| TCO | Populate the existing 12/36-month model with measured capacity and approved prices/labour. | Input provenance and calculation. | ESTIMATE / NOT_EXECUTED |

No numerical acceptance threshold is approved by this proposal. The corpus,
thresholds and pass rules require approval before execution.

## 7. Privacy, security, recovery and deletion design

- Do not store personal search history, current GPS data or precise coordinates
  in application, proxy, Photon or operating-system logs.
- Use synthetic/public corpus queries only. The evaluator must not submit a
  person’s current location or travel data.
- Store only aggregate metrics required for the approved test; cap retention at
  seven days and validate deletion.
- Restrict access to the named lab operators through the private environment;
  no anonymous/public endpoint and no shared credentials.
- Keep dataset provenance/checksum and test reports separate from service logs.
- Before lab destruction, retain only the approved redacted evidence; remove
  the dedicated lab volume according to the approved recovery/deletion plan.
- Recovery testing is a later authorized action, not a result of this proposal.

## 8. Preliminary 12/36-month TCO treatment

The merged feasibility framework remains authoritative. This contract adds no
prices. Before selection, a controller must populate the following using a
quoted or measured source and label every amount:

| TCO input | 12 months | 36 months | Current status |
|---|---:|---:|---|
| Isolated VM compute and SSD | unknown | unknown | Requires provider quote and measured sizing. |
| Import/update temporary capacity | unknown | unknown | Requires execution measurement. |
| Backup/recovery storage and drills | unknown | unknown | Requires approved recovery plan. |
| Monitoring, security and operational labor | unknown | unknown | Requires named owner and rate. |
| Attribution/licence compliance | unknown | unknown | Requires legal/compliance review. |
| Contingency | unknown | unknown | Human budget decision. |

```ini
TCO_12 = NOT_CALCULATED
TCO_36 = NOT_CALCULATED
```

## 9. Risks and required human decisions

| ID | Risk / decision | Required disposition before execution |
|---|---|---|
| LAB-01 | No independent VM has been measured or approved. | Select/provision an isolated non-production environment within an approved budget. |
| LAB-02 | Candidate resource caps are hypotheses. | Approve the 4/16/100 minimum, 8/32/200 recommendation and 8-hour cap, or amend them. |
| LAB-03 | Photon release/data compatibility is untested. | Approve Photon 1.3.0 candidate and the exact source/checksum capture procedure. |
| LAB-04 | Full corpus, scoring thresholds and Spanish acceptance conditions are pending. | Freeze the lab test matrix before execution. |
| LAB-05 | Licence/attribution and derived-data interpretation require review. | Approve attribution/compliance handling for the chosen dataset/use. |
| LAB-06 | Update, recovery and deletion procedures are untested. | Approve the later exercise scope and evidence-retention/deletion plan. |
| LAB-07 | Existing integration VM is in use. | Confirm it remains excluded from Photon lab execution. |

## 10. Recommendation

```ini
RECOMMENDED_LAB_ENVIRONMENT = NEW_ISOLATED_NON_PRODUCTION_VM
LAPTOP_LAB = REJECTED_FOR_CURRENT_CAPACITY
INTEGRATION_VM_LAB = REJECTED_SHARED_RESOURCE
CANDIDATE_PHOTON_RELEASE = 1.3.0
LAB_CONTRACT = PROPOSED_NOT_APPROVED
LAB_EXECUTION = NOT_AUTHORIZED
PROVIDER_SELECTION = NOT_AUTHORIZED
IMPLEMENTATION = NOT_AUTHORIZED
```

Proceed only to a human infrastructure-and-execution gate. That gate must
select an isolated VM, approve the resource cap and cost ceiling, freeze the
corpus and thresholds, accept the privacy/deletion plan, and authorize a
strictly bounded lab run. The output of that run informs provider selection; it
does not by itself authorize `SearchPlaces` implementation or P12.5.

# P12 Phase Contract v1 — Real Road Pilot

**STATUS = APPROVED_FROZEN**  
**P12_CONTRACT_FROZEN = YES**  
**P12_IMPLEMENTATION = AUTHORIZED_WITHIN_FROZEN_CONTRACT**  
**P12_CONTRACT_BASELINE_PREVIOUS = 9594ada1a9dd712e7b07d76def76a08ac7f309f1**

## 1. Objective and authority

P12 validates existing GeoGuide capabilities in a controlled real-road pilot. It does not add product capabilities. Approved decisions are D12_01–D12_05: existing capabilities only, Lima–Canta–Obrajillo as candidate route, existing Android physical device subject to fresh verification, minimal technical evidence without tracking/audio, and reconstructible non-production data only.

The candidate route is not executable until GraphHopper feasibility, geometry and curated POI coverage pass. Field execution always requires a separate explicit human authorization after preparation and stationary validation.

## 2. In scope

Route planning, GraphHopper routing, POI discovery along route, existing POI detail/filter/preview, existing offline cache, reduced-interaction Driving UI, one-shot location, HTTPS/API connectivity, stationary physical-device validation, controlled road execution after field authorization, objective evidence and closure.

## 3. Out of scope

Search/geocoding, CEFI implementation, STT/TTS/microphone/voice, continuous GPS/tracking/follow camera, turn-by-turn, live ETA, rerouting, proximity alerts, offline maps/tiles/routing, new APIs, DB schema changes, material architecture changes, new providers, paid services, telemetry and production data.

## 4. Privacy and safety

Evidence is minimal technical data: pass/fail, correlation timestamps, anonymized build/device identifiers, non-sensitive error codes, technical measurements and manual observations. No audio, continuous location history, background telemetry or personal travel history is collected. Transient evidence retention is proposed as 30 days after closure, then deletion, subject to project-owner confirmation if personal data appears.

A driver never manipulates the device. A passenger/test observer operates the app and records evidence. Stationary checks precede any field activity. Stop immediately if safety, weather, connectivity or device conditions deteriorate. Driving UI is not certified navigation.

## 5. Dependencies and known debt

The pilot depends on the existing Flutter/backend/routing/data stack, HTTPS, physical device, candidate route/dataset and permissions. Repository `origin/main` and the operational checkout/image are distinct; compatibility must be verified before testing. `P11-BACKUP-01` remains MEDIUM/OPEN_DEFERRED: only reconstructible test data is permitted, and Production Readiness remains blocked.

## 6. Checkpoints

- **P12.1 CONTRACT_AND_TEST_MATRIX:** this frozen contract and matrix are present.
- **P12.2 ROUTE_AND_DATASET_VALIDATION:** GraphHopper route, geometry and curated POI coverage.
- **P12.3 BUILD_AND_DEVICE_STATIONARY_VALIDATION:** reproducible APK, device compatibility, HTTPS, permissions and stationary flows.
- **P12.4 FIELD_PILOT_PROTOCOL_AND_READINESS:** protocol, roles, abort rules, privacy and explicit field authorization request.
- **P12.5 CONTROLLED_REAL_ROAD_EXECUTION:** only after separate human field authorization.
- **P12.6 EVIDENCE_AND_REGRESSION:** consolidate evidence and rerun applicable regression/security checks.
- **P12.7 CLOSURE:** close only with field evidence or an explicitly documented blocked disposition; never claim field PASS without physical evidence.

## 7. Acceptance criteria

| ID | Method and expected result | Evidence / disposition |
|---|---|---|
| P12-AC-01 | Contract and scope are frozen; excluded capabilities absent. | Contract hash/PR; PASS or BLOCKED |
| P12-AC-02 | Reproducible build completes and APK SHA-256 is recorded. | Build log/hash; PASS/FAIL |
| P12-AC-03 | HONOR LLY-NX3/API 36 accepts APK and launches. | Fresh device observation; PASS/BLOCKED_DEVICE_UNAVAILABLE |
| P12-AC-04 | Approved HTTPS endpoint and certificate verification succeed. | Endpoint/status/cert evidence; PASS/FAIL |
| P12-AC-05 | GraphHopper calculates a feasible candidate route. | Request/response/geometry evidence; PASS/FAIL |
| P12-AC-06 | Existing curated POIs are returned along the route. | Dataset/query/result evidence; PASS/FAIL or BLOCKED_COVERAGE |
| P12-AC-07 | Existing filters/detail/preview operate without new capability. | Stationary test evidence; PASS/FAIL |
| P12-AC-08 | Existing cache honors its frozen TTL/size/consent behavior. | Existing automated evidence and focused checks; PASS/FAIL |
| P12-AC-09 | Driving UI is evaluated stationary with reduced interaction and no navigation certification. | Observer checklist; PASS/FAIL |
| P12-AC-10 | One-shot location permission behavior is verified on the device. | Fresh permission observation; PASS/FAIL |
| P12-AC-11 | No tracking, audio, telemetry or unauthorized collection occurs. | Scope/code/evidence audit; PASS/FAIL |
| P12-AC-12 | Test data reconstructs from migrations, seeds and documented sources. | Rebuild/source evidence; PASS/FAIL |
| P12-AC-13 | Field protocol and explicit authorization are recorded before moving test. | Signed human gate evidence; PASS/BLOCKED |
| P12-AC-14 | Controlled road execution produces objective observer evidence. | Field report; PASS/BLOCKED, never inferred |
| P12-AC-15 | Regression, security and documentation checks pass. | Test/analyze/diff/evidence; PASS/FAIL |
| P12-AC-16 | P11-BACKUP-01 remains open and Production Readiness remains blocked. | Governance evidence; PASS |

No numerical latency, distance, battery, connectivity or accuracy threshold is invented; only documented behavior and reproducible evidence are assessed.

## 8. Rollback and abort

Abort a test on unsafe conditions, unexpected permission/data exposure, non-reconstructible data, incompatible deployment, route coverage failure requiring a new route decision, secret, Critical/High finding or material scope change. Revert only test artifacts and do not alter production services, schemas, credentials or infrastructure.

## 9. Governance state

```ini
P12_SCOPE = VALIDATION_OF_EXISTING_CAPABILITIES_ONLY
P12_ROUTE_CANDIDATE = LIMA_CANTA_OBRAJILLO
P12_DEVICE = EXISTING_ANDROID_PHYSICAL_DEVICE
P12_EVIDENCE = MINIMAL_TECHNICAL_NO_TRACKING_NO_AUDIO
P12_BACKUP_GATE = NON_PRODUCTION_RECONSTRUCTIBLE_DATA_ONLY
FIELD_EXECUTION_AUTHORIZATION = REQUIRED_SEPARATELY
P11-BACKUP-01 = OPEN_DEFERRED
P12 = IN_PROGRESS_PREPARATION
```


# GeoGuide AI — P8 Phase Contract v1 — POI Experience

**Status:** `APPROVED_FROZEN`  
**Approval:** `APPROVED`  
**Phase status:** `AUTHORIZED_NOT_STARTED`  
**Autonomous execution:** `PAUSED_BEFORE_P8_1`

## 1. Identity and entry baseline

P8 — **POI Experience** converts the P7 route → discovery → markers → basic detail
vertical slice into an understandable, accessible and context-preserving Discovery
experience. Entry commit is `180c6d7f42d168605cfd2e3620e35d8cb3e3af3c` with P0–P7
complete, P7 closed, global progress 78%, Product UX Baseline established, CEFI-ready
architecture required, CEFI implementation not started, `flutter_map 8.3.2` accepted,
and tile-provider governance pending.

The frozen P7 contract remains unchanged (Git blob
`17d3c3366a051263af49a246fd67823133a584bd`).

## 2. Product purpose and boundaries

P8 answers “¿Qué puedo conocer en esta ruta?” for the **DISCOVERY** intent. It keeps
**RECREATION** and **TRAVEL_SERVICE** semantically separate and does not build their
engines. `FUEL`, `HEALTH`, `FOOD` and `LODGING` may exist in source data, but P8 does
not present them as places pending discovery or add them to Discovery progress.

The governing principle is: **Explorar nunca debe destruir el contexto del viaje.**
`distanceToRouteMeters` is displayed as “Distancia al trazado”; it is not a detour.
`routeProgress` is route context, never driver progress.

## 3. In scope

1. POI preview with friendly category, route context, distance to route, a supported
   reason, View detail, close and return.
2. POI detail with the approved factual fields and an explicit reduced presentation
   for provenance/freshness.
3. Discovery category filters backed by the existing P3 codes.
4. Synchronized Map + List alternatives, including marker/list selection.
5. Loading, empty, failure, retry and unusable-data states.
6. Route/origin/destination/discovery/filter/selection continuity.
7. TalkBack, focus, labels, target size, text scaling, contrast and non-map access.
8. A minimal API response extension described in Section 7, implemented only in the
   later checkpoint assigned to it.

## 4. Explicit non-scope

Saved/frequent routes, history persistence, visited/want-to-visit state, accounts,
authentication, synchronization, search, geocoding, reverse geocoding, real detour
calculation, Recreation, Travel Service UX, CEFI/chat/textual CEFI, LLM, STT, TTS,
voice, microphone, Driving Mode, continuous/background location, geofencing, advanced
offline, favorites, media, turn-by-turn, traffic, alternative routes, RoutingProvider
redesign, GraphHopper replacement and production tile-provider selection.

## 5. Current implementation audit

### Mobile

The mobile domain model currently carries `id`, `name`, `category`, `location`,
`distanceToRouteMeters`, `routeProgress` and `reasonCodes`. The mapper rejects malformed
results. The current sheet exposes raw reason codes and decimal-derived route progress;
P8 replaces those with supported human language. The existing controller/repository
separates application calls from presentation, so no architecture refactor is required.
Map markers and the route context already exist; a real list and preview/detail states
remain to be implemented in P8.1–P8.5.

### Backend/API

`POST /api/v1/routes/discover` accepts origin, destination, category codes,
corridorMeters and limit. The use case owns corridor selection and ranking. The response
currently exposes id, name, category, location, distanceToRouteMeters, routeProgress,
score and reasonCodes. Valid reason codes produced by the current ranking are
`NEAR_ROUTE` and `CATEGORY_MATCH`.

### Database/domain

P3 migrations already provide stable UUID POI identity, name, description, location,
active, createdAt, updatedAt and a provenance table with source system, record, URL,
retrievedAt, license, attribution, incorporation method and logical key. No migration
is authorized by this contract.

## 6. POI field availability matrix

| Field | Domain | DB | Current API | Mobile | UX required | P8 decision |
|---|---|---|---|---|---|---|
| stable POI identifier | yes | yes | yes | yes | yes | expose unchanged UUID |
| name | yes | yes | yes | yes | yes | required |
| category code | yes | yes | yes | yes | yes | P3 code plus presentation mapping |
| description | yes | yes | no | no | yes for Detail | controlled API extension |
| location/context | yes | yes | yes | yes | yes | route context, no raw IDs |
| distanceToRouteMeters | discovery result | derived | yes | yes | yes | “Distancia al trazado” |
| routeProgress | discovery result | derived | yes | yes | contextual only | never driver progress |
| reasonCodes | ranking | derived | yes | yes | translated only | never raw display |
| provenance/source | yes | yes | no | no | reduced trust cue | controlled API extension, reduced presentation |
| retrievedAt | yes | yes | no | no | no | defer freshness semantics |
| updatedAt | yes | yes | no | no | no | not called verified/current |
| score | ranking | derived | yes | no | no | never user-facing |

## 7. Contractual decisions

`POI_DETAIL_API_DECISION = CONTROLLED_API_EXTENSION_REQUIRED`. The existing discovery
endpoint remains backward compatible. Before Detail UI, checkpoint P8.1b may extend the
existing `Result` response with nullable `description` and a user-safe provenance
summary (`sourceLabel`, optional `sourceUrl`, optional `attribution`). It must not expose
license internals, raw score or database fields. Request shape and endpoint remain
unchanged; errors remain the existing typed discovery errors. OpenAPI, backend tests,
mapper tests and compatibility tests are required in that checkpoint. No new endpoint,
routing change or migration is authorized.

`PROVENANCE_P8_DECISION = REDUCED_PRESENTATION`. Show a source label/attribution only
when present and meaningful; otherwise omit the cue. `FRESHNESS_P8_DECISION = DEFERRED`:
`updatedAt` is editorial data and `retrievedAt` is ingestion time, neither proves current
validity. Do not display “Información actualizada”.

`CATEGORY_FILTER_SEMANTICS = BACKEND_REQUERY`. Categories are the existing P3 codes;
the backend remains discovery/ranking authority. The request sends selected codes,
multi-select is allowed, “Todas” clears the set, Apply re-queries, Reset restores all,
and the same selection survives Map/List and Detail return. Empty means no matching
Discovery result for that route/filter, not global absence of places.

`MAP_LIST_DECISION = IN_SCOPE`. Marker → corresponding list item → preview; list item →
marker/preview; Detail return restores route, viewport when feasible, filter and selected
POI. List is a real accessible alternative, not a decorative duplicate.

`CEFI_READY_P8_ARCHITECTURE_DECISION = CURRENT_ARCHITECTURE_SUFFICIENT`. New behavior
must remain in application/domain/repository boundaries; no speculative CEFI abstraction
and no business rules exclusive to widgets.

`P8_BACKEND_SCOPE = CONTROLLED_EXTENSION`; `P8_DATABASE_SCOPE = NONE`;
`DATABASE_CHANGE_REQUIRES_HUMAN_GATE = NO` for this contract. `SEARCH_GEOCODING =
OUT_OF_P8`, `RECREATION_ENGINE = OUT_OF_P8`, `TRAVEL_SERVICE_EXPERIENCE = OUT_OF_P8`.

## 8. Preview, detail and reason semantics

Preview must show name, friendly category, “a X m del trazado” where supported, and a
reason sentence only for known mappings. `NEAR_ROUTE` → “Cerca del trazado”; 
`CATEGORY_MATCH` → “Coincide con la categoría seleccionada”. Unknown codes are hidden.
Detail may show description only when supplied by the API; it must never show UUID,
score, raw codes or decimal route progress.

## 9. States, continuity and security

Discovery and Detail each require loading, empty, failure and retry states. Backend,
provider, connectivity and malformed-data failures remain visible and actionable; route
context remains on screen. No fake data, HTTP fallback, TLS bypass, secret, precise GPS
coordinate or full device serial may be added to evidence. HTTPS remains
`https://geoguide.getcom.pe:5443`. DNS, Nginx, Certbot, Compose, systemd and firewall
are outside P8.0.

## 10. Accessibility and non-functional requirements

All controls have meaningful TalkBack labels, deterministic focus order, touch targets
meeting the platform guidance, text that survives user scaling, sufficient contrast,
non-color-only states, announced loading/errors and an equivalent list alternative for
map content. P8 does not introduce a new performance target; tests must demonstrate no
unbounded request loop and preserve the existing limit/corridor behavior. API extension
is backward compatible and all state transitions preserve context.

## 11. Checkpoints

| Checkpoint | Scope | Gate evidence |
|---|---|---|
| P8.1 | Preview and continuity shell | widget tests, screenshots, state matrix |
| P8.1b | Controlled API detail/provenance extension | OpenAPI diff, backend/API/mapper tests, compatibility evidence |
| P8.2 | Detail | widget tests and field matrix evidence |
| P8.3 | Backend-backed category filters | request traces, empty/reset/re-entry tests |
| P8.4 | Map + List | widget/accessibility tests and context evidence |
| P8.5 | Loading/empty/error/accessibility hardening | automated tests, TalkBack evidence, failure matrix |
| P8.6 | Physical Android validation | only required for final interaction and accessibility validation |
| P8.7 | Audit and closure | acceptance matrix, security scan, contract evidence |

P8.1 is not authorized by this document; execution remains paused before it.

## 12. Acceptance criteria

### Functional

- **P8-AC-01:** Selecting a marker or list item opens Preview with only approved fields.
- **P8-AC-02:** View detail opens Detail and back returns to the same route/filter context.
- **P8-AC-03:** Apply/Reset multi-category filters sends P3 codes to backend and reflects the response.
- **P8-AC-04:** Map and List selections remain synchronized and support the same POI.
- **P8-AC-05:** Loading, empty, failure and retry are distinct observable states.
- **P8-AC-06:** No raw score, reason code, UUID or routeProgress decimal is rendered.

### UX/accessibility

- **P8-AC-07:** Every interactive control has a meaningful TalkBack label and focus order.
- **P8-AC-08:** List provides equivalent POI discovery without relying on map color or gestures.
- **P8-AC-09:** Text scaling and contrast checks pass on the supported Android baseline.
- **P8-AC-10:** Error announcements identify recovery and preserve route context.

### Architecture/API

- **P8-AC-11:** API extension is additive, OpenAPI documented, backward compatible and tested.
- **P8-AC-12:** Domain/application boundaries hold filter/detail rules; widgets do not own ranking or provenance policy.
- **P8-AC-13:** No database migration, search provider, tile-provider decision or CEFI implementation is present.

### Security/E2E

- **P8-AC-14:** HTTPS is preserved with no secret, token, precise GPS or device serial in evidence.
- **P8-AC-15:** Final physical Android validation demonstrates preview/detail/filter/map-list continuity and retry behavior.

## 13. Required evidence and exit criteria

Each checkpoint must attach changed-file scope, tests, screenshots or traces appropriate
to the checkpoint, and a PASS/FAIL acceptance matrix. P8 exits only when all applicable
criteria pass, API/OpenAPI compatibility is demonstrated, security scan is clean,
P7 remains byte-identical, and no explicit non-scope has entered the implementation.

## 14. Governance

This contract freezes scope and authorizes future P8 work only. It does not authorize
P8.1 execution. Any database change, security/infra change, identity redesign, tile
provider decision, Search dependency or CEFI implementation requires a new human gate.
Excel remains unchanged; administrative tracking may record P8 as `AUTHORIZED_NOT_STARTED`
at 0% without altering global progress 78%.

```text
P8_PHASE_CONTRACT = APPROVED_FROZEN
P8_PHASE_APPROVAL = APPROVED
P8_STATUS = AUTHORIZED_NOT_STARTED
P8_PROGRESS = 0%
GLOBAL_PROGRESS = 78%
NEXT_RECOMMENDED_GATE = P8.1
AUTONOMOUS_EXECUTION = PAUSED_BEFORE_P8_1
```

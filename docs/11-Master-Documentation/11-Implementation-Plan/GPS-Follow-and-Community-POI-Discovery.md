# GPS Follow Mode + Community POI Discovery — Product and Architecture Proposal

STATUS = DISCOVERY_ONLY
P12_CONTRACT = UNCHANGED
NEW_FUNCTIONAL_IMPLEMENTATION = NOT_AUTHORIZED
P12_FIELD_EXECUTION = NOT_AUTHORIZED
BASELINE = 9ad12dac1365b056c8b3b875ce681924b910e35e

## Findings

P12 is frozen for validation of existing capabilities. GPS Follow Mode and Community POI Contributions are new capabilities and are not silently added to P12.

The current Flutter app has a one-shot `LocationRepository` backed by geolocator, `getCurrentPosition`, explicit permission handling and a map controller that moves once to the current point. It has no stream-based foreground follow mode, lifecycle-aware subscription, accuracy filter, camera-follow state machine or battery policy. The current backend exposes route planning and Route Discovery with origin/destination only. The POI model has official catalog records and provenance; there is no contribution/moderation entity or API.

## GPS Follow Mode proposal

A future package should add a foreground-only location stream behind a domain/application port. The infrastructure adapter would own subscription, lifecycle pause/resume, accuracy and stale-sample filtering, while Presentation would render the current marker and camera-follow state. Activation/deactivation must be explicit. No background service, route history, coordinate upload, turn-by-turn, rerouting or live ETA is proposed.

Suggested state machine: INACTIVE, REQUESTING_PERMISSION, ACTIVE, PAUSED_LIFECYCLE, SIGNAL_DEGRADED and STOPPED. Camera follow should be user-toggleable and stop following after manual map movement until explicitly re-enabled. Sampling policy must be measured during implementation; no frequency, battery or accuracy threshold is asserted here.

Reuse candidates: existing LocationRepository, geolocator dependency, permission state mapping, MapController, current marker semantics and Driving UI restrictions. New Android permission or background capability is not authorized. Foreground-only location still requires a contract and device validation.

## Community POI Contributions proposal

Contributions should be a separate PENDING_REVIEW record, never the official POI table. A minimum future model would include a server-generated id, one-shot coordinate, name, category, description, source reference, submitter pseudonymous id if authentication is approved, timestamps, status, reviewer decision and audit history. States: PENDING_REVIEW, NEEDS_CORRECTION, REJECTED, APPROVED, PUBLISHED.

Validation should enforce field lengths, category allow-list, coordinate bounds/SRID, source requirements, duplicate candidate search by spatial distance plus normalized name/category, rate limits, abuse controls and moderation. Publication must be an explicit reviewer action. No anonymous automatic publication, image/audio upload or driver interaction is proposed.

This capability would require new API endpoints, DB entities/tables, authentication or abuse identity, moderation workflow and retention/privacy rules. Those are architecture and product decisions, not implementation details that can be inferred from this discovery.

## Los Balcones de Yaso case study

The supplied 2016 article describes Yaso as a village associated with historic balconies. Independent public references place Yaso in Santa Rosa de Quives, Canta, at approximately `-11.579006,-76.738819`; a current public travel reference describes Yaso as lying on the Lima–Canta–Obrajillo corridor. These sources establish a candidate locality and historical description, not a currently verified official POI or present-day condition. The supplied article itself is historical and does not prove current access, conservation or public availability.

No matching Yaso POI was present in the curated P3 seed or the current official PostGIS/Route Discovery results used for P12. The candidate is therefore:

CANDIDATE_POI = LOS_BALCONES_DE_YASO
CANDIDATE_STATUS = UNVERIFIED
OFFICIAL_POI_CREATED = NO
DATASET_MODIFIED = NO

Potential category is `VIEWPOINT` or another compatible category only after verification; no category assignment is made now. Public access, road access, exact feature coordinates, duplication against OSM and current condition require a dedicated verification activity.

## Privacy and security boundaries

```ini
GPS_FOREGROUND_ONLY = YES
BACKGROUND_TRACKING = NO
LOCATION_HISTORY = NO
CONTINUOUS_LOCATION_UPLOAD = NO
POI_SUBMISSION = USER_INITIATED
POI_LOCATION_CAPTURE = ONE_SHOT_WITH_CONSENT
POI_PUBLICATION = MODERATED
DRIVER_INTERACTION_WHILE_MOVING = PROHIBITED
```

No audio, microphone, camera, home location, personal travel history or unnecessary identifiers are collected. Any future evidence retention period requires a product/privacy decision; no personal-data collection is authorized by this document.

## Governance alternatives and recommendation

Alternative A is to amend P12. This would expand a frozen validation phase with new permissions, behavior and possibly API/DB scope; it is not recommended.

Alternative B is a separate future capability package after P12, with independent contracts for GPS Follow Mode and Community POI Contributions. This preserves P12 traceability and allows separate product, privacy, API/DB and physical-device gates. **Recommendation: Alternative B.**

Proposed future packages are discovery labels only: GPS-01 discovery/architecture, GPS-02 contract, GPS-03 implementation, GPS-04 automated tests, GPS-05 stationary Android validation; POI-C01 discovery, POI-C02 data/moderation model, POI-C03 API/security contract, POI-C04 implementation and POI-C05 moderation validation.

## Human decisions required

1. Whether GPS Follow Mode should become a future phase and whether foreground location-stream behavior is acceptable.
2. Whether Community POI Contributions should become a future phase, including authentication/abuse identity and moderation ownership.
3. Whether new API/DB entities, permissions or data retention are acceptable.
4. Whether Los Balcones de Yaso merits a separate factual/access verification before any candidate record.

Until those decisions are resolved, P12 remains unchanged and no functional implementation starts.

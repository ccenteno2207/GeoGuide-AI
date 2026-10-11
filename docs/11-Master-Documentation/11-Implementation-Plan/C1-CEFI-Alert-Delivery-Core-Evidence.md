# C1 — CEFI Alert Delivery Core Evidence

Date: 2026-10-10. Scope: local implementation authorized by the user; no push, PR, merge or physical installation.

## Entry and provenance

- Branch: feature/gps-camera-tracking-proximity-core.
- Verified entry HEAD: e17d8513406eef5315c7fdae2ad8353d0fc18b9b.
- Verified origin/main: e19e17212c48ecf1b9604c512cac4f5b9fb64686.
- Entry worktree: clean.
- Functional commit: c1a56929225833708939f26bce77b1a235f5631f.
- B1.1 input: [UX hardening and alert readiness](B1.1-UX-Hardening-and-CEFI-Alert-Readiness.md).

## Implementation

POIProximityEvaluator now detects an ordered candidate list without consuming candidates or starting cooldown. It preserves existing geometry, accuracy, direction, category and hysteresis rules. The compatibility evaluate method returns the first candidate without consumption.

ActiveRouteCoordinator owns CEFIAlertDeliveryCoordinator alongside the existing TrackingSessionManager. Route start creates a fresh delivery generation and an opaque snapshot revision; route stop/revocation, failed start and expiry invalidate delivery state. A duplicate start is rejected before it can replace the context. Existing native worker wiring resolves SilentAlertSink through the coordinator export; no second location producer was added.

The neutral CEFIAlertDeliveryPort exposes asynchronous deliver and cancel. Event state is ACCEPTED, DELIVERED, FAILED, SUPPRESSED, EXPIRED or CANCELLED. A terminal delivery ack must mean output ownership has been released. DELIVERED must represent completion, not merely provider queue acceptance. Acks must match event ID, generation and revision.

IDs use an in-memory generation plus sequence. Deduplication is scoped to generation, revision and POI ID. Revision is an opaque local context token, not a content hash or personal coordinates; a new route/snapshot context must use open/start. No state survives process restart.

Only one event can be in flight and one pending. Chosen POIs take priority; the evaluator order is retained within equal priority. A chosen pending candidate replaces a suggested one. Overflow, lost eligibility and replacement are SUPPRESSED, not delivered. Only the last terminal outcome is retained, without an event history.

DELIVERED starts cooldown and consumes the POI for that context. FAILED/SUPPRESSED allow reconsideration only on a later fresh valid sample, after max(existing cooldown, validity). Hysteresis remains in the evaluator. Duplicate, stale and future samples cannot trigger reconsideration. No retry timer, ack-triggered pending drain or batch replay exists.

Event validity reuses proximity maxAge and is capped by snapshot expiry. The deadline timer expires/cancels output, never dispatches it. Cancellation has a barrier: no new output before cancel completes. A cancel failure blocks output for the coordinator lifetime rather than risking overlap.

The production worker retains its existing maxAge=10 seconds and cooldown=30 seconds; no new distance/battery/product threshold was introduced. Chosen IDs are an immutable optional start input; existing worker callers still supply none. User selection UI and preference wiring are outside C1.

## Delivery and privacy limits

SilentAlertSink returns a simulated technical DELIVERED ack without sound, speech, POI notification, storage or network. This is not proof of audible delivery or user acknowledgment. FakeDelivery in tests permits controlled completion, failure and cancellation.

The new delivery core stores POI identifiers/names and context tokens in memory; it does not store coordinates, write logs, serialize events, add telemetry or upload samples. Existing location transport to the app is unchanged. No TTS, audio focus, microphone, new permissions/dependencies, continuous no-route tracking or Driving changes were added.

## Validation

- Format: 62 Dart files inspected, 0 changes required.
- Flutter analyze --no-pub: no issues.
- Flutter tests: 111/111 PASS (95 baseline + 16 C1).
- C1 cases: priority and bounded queue; dedup and cooldown after ack; FAILED and SUPPRESSED reconsideration; replacement; expiry; stop; snapshot generation; wrong/late ack; loss of corridor eligibility; adapter exception; simulated silent ack; Dart integration/revocation and late GPS callbacks; cancellation barrier; cancellation failure; duplicate/future/stale samples; snapshot TTL.
- Existing candidate tests were adjusted to verify non-consuming detection rather than equating detection with delivery.
- The first C1 context test failed because it inspected the new event before cancellation completed. Corrected the test to await the barrier; subsequent full suite passed.
- Full suite initially exposed an existing startup harness failure: native path_provider map-cache lookup in flutter_tester. The startup test now supplies an isolated temporary map-cache directory without initializing any Flutter binding before the real entrypoint. The binding-order regression remains intact. Test-only temporary files are cleaned up.
- gradlew.bat :app:b1PolicyChecks: B1_NATIVE_POLICY_ASSERTIONS_PASS=50; BUILD SUCCESSFUL. These are JVM policy checks, not physical Android service validation.
- git diff --check: PASS.
- APK debug HTTPS build: PASS; command uses --no-pub and BACKEND_BASE_URL=https://geoguide.getcom.pe:5443.
- APK path: mobile/build/app/outputs/flutter-apk/app-debug.apk.
- APK SHA-256: 46F5487DDA2316852F34CB9A83B1BB93836D692FC1E3D9FD8519D4022E79086E.
- Source manifest SHA-256 unchanged: 1E6900B8EBEAB9C61955B64402907C486522E20896006138A4264E70DD6BED1F.
- Merged debug manifest SHA-256 unchanged: 749E42369A79959DFB68E05C106D0C94DD71A006EEF1CADFA30784DA993FF8F4.
- Physical C1 validation: NOT_EXECUTED. APK not installed. Historical B1 stationary results do not establish physical C1 PASS.

## Files

- mobile/lib/features/tracking/application/cefi_alert_delivery_coordinator.dart (new).
- mobile/lib/features/tracking/application/poi_proximity_evaluator.dart.
- mobile/lib/features/tracking/application/active_route_coordinator.dart.
- mobile/test/features/tracking/cefi_delivery_test.dart (new).
- mobile/test/features/tracking/accelerated_core_test.dart.
- mobile/test/b1_startup_test.dart (test harness isolation).
- This evidence document.

No backend/API/DB/infra/Android source/manifest, Driving, P12, Photon, frozen contracts or external workbook changes.

## Residual risks and next gate

A real adapter must honor cancellation and release ownership on terminal ack. Cancel failure intentionally requires recovery before further output; there is no automatic retry. Process termination loses delivery state by design. Physical delivery, battery impact, audible alerts and Android audio coexistence remain unvalidated.

Proposed next package: implement a TTS adapter behind CEFIAlertDeliveryPort with explicit voice consent, generation/event/revision callback correlation, and DELIVERED only on speech completion. Audio-focus denial/loss maps to SUPPRESSED or FAILED and cancels output; focus is released on all terminal paths. No adapter queue or proximity/dedup logic duplication. Stop, interruption, revocation and late callbacks must use the existing cancellation barrier. This requires separate authorization for TTS/audio focus and subsequent supervised physical installation.

READY_FOR_CEFI_TTS_GATE.
P12.5 = NOT_AUTHORIZED.
P11-BACKUP-01 = OPEN_DEFERRED.

# GPS Follow Mode Contract Proposal v0.1

STATUS = APPROVED_FROZEN
GPS_CONTRACT = APPROVED_FROZEN
P12_CONTRACT = UNCHANGED
BASELINE = 7f6ee6045cc42d5d6a0275c8e1d4f33b27267df3

## Objective and boundaries

Add an independent foreground-only GPS Follow Mode before any authorized P12.5 field execution. The capability updates the current position marker and optionally follows it with the map camera. It does not add background services, trajectory history, coordinate upload, turn-by-turn navigation, ETA, rerouting, proximity alerts or new backend APIs.

Activation and deactivation are explicit. Manual map interaction pauses camera following; reactivation is explicit. Position samples are transient and are not persisted.

## Reusable architecture

- Existing `LocationRepository` remains the domain boundary; add a separate stream-oriented port only if the approved contract confirms it.
- `geolocator` remains the infrastructure adapter; no new provider is proposed.
- `BaseMapPage` and `MapController` remain presentation integration points.
- A controller/application service owns follow state, lifecycle pause/resume, permission outcomes and sample filtering.
- Presentation owns marker/camera rendering and user controls; it does not own platform permission or persistence logic.
- Existing Driving UI remains a reduced-interaction mode. Follow Mode must be unavailable or frozen during active Driving Follow Mode may continue as a passive display when activated before Driving; no controls are presented in active Driving.

Proposed state machine: INACTIVE, REQUESTING_PERMISSION, ACTIVE, CAMERA_PAUSED_BY_USER, PAUSED_LIFECYCLE, SIGNAL_DEGRADED and STOPPED.

## Proposed sample policy

The implementation should accept only valid coordinates, reject impossible accuracy/timestamp values, ignore stale or clearly regressive samples, and expose degraded signal without pretending precision. Sampling frequency, accuracy and battery thresholds must be measured during implementation; this proposal invents no numerical limits.

## Privacy and permissions

```ini
GPS_FOREGROUND_ONLY = YES
BACKGROUND_TRACKING = NO
LOCATION_HISTORY = NO
CONTINUOUS_LOCATION_UPLOAD = NO
NEW_SENSITIVE_PERMISSION = NO
```

Use the existing one-shot permission contract as the entry point. If a stream requires a new Android permission or background capability, stop and require a new human decision. No location data is logged or included in evidence beyond transient technical observations.

## Acceptance criteria proposal

| ID | Criterion | Evidence | Result rules |
|---|---|---|---|
| GPS-AC-01 | Contract approved and P12 unchanged | Contract hashes and diff | PASS only after human approval |
| GPS-AC-02 | Foreground permission states handled | Automated tests + Android observation | PASS/FAIL/BLOCKED_DEVICE |
| GPS-AC-03 | Valid samples update marker | Unit/widget test | PASS/FAIL |
| GPS-AC-04 | Invalid/stale/degraded samples do not create false position | Unit tests with controlled fixtures | PASS/FAIL |
| GPS-AC-05 | Follow camera moves while active | Widget/fake stream test and stationary Android | PASS/FAIL |
| GPS-AC-06 | Manual map gesture pauses following and explicit control resumes it | Widget/stationary Android evidence | PASS/FAIL |
| GPS-AC-07 | Lifecycle pause/resume stops and safely restores the stream | Lifecycle tests | PASS/FAIL |
| GPS-AC-08 | No history, background service, upload or new API | code/config audit and network inspection | PASS/FAIL |
| GPS-AC-09 | Driving UI remains safe and no driver interaction is required | widget/accessibility and stationary review | PASS/FAIL |
| GPS-AC-10 | Battery and sampling behavior are measured without asserting invented limits | controlled measurement report | PASS/FAIL/NOT_APPLICABLE with rationale |
| GPS-AC-11 | Rollback removes the feature without schema/API migration | diff and build validation | PASS/FAIL |

No acceptance criterion declares field or road PASS. Physical moving validation remains behind P12.5 field authorization.

## Test matrix

Automated: permission denied/deniedForever, service disabled, valid sample, invalid coordinate, stale sample, degraded accuracy, manual camera pause/resume, lifecycle pause/resume, disposal/close, no persistence and no network side effect. Android stationary: permission dialog, marker, follow toggle, gesture pause/resume, lifecycle/background transition and Driving UI interaction restrictions. Field: only after explicit authorization, passenger-operated, no driver manipulation, abort on unsafe conditions.

## Rollback

Rollback is removal of the GPS feature branch and release artifact. No DB migration, API rollback or production restart is required by this proposal. If a permission or architecture change becomes necessary, stop before implementation and create a new decision record.

## Dependencies and gates

Depends on the existing Flutter map/location stack, Android physical device, P12.3 stationary gate and P12.5 field gate. P11-BACKUP-01 remains open and Production Readiness remains blocked. This proposal does not authorize field execution, deployment or new data collection.

## Decisions required

1. Human approval of this independent GPS contract.
2. Confirmation that foreground location streaming is acceptable with no background capability.
3. Confirmation of Driving UI behavior while Follow Mode is active.
4. Confirmation of any battery/accuracy evidence thresholds after technical measurement.

Frozen governance state:`r`n`r`n```ini`r`nGPS_CONTRACT = APPROVED_FROZEN`r`nGPS_IMPLEMENTATION = AUTHORIZED_WITHIN_FROZEN_CONTRACT`r`nP12_CONTRACT = UNCHANGED`r`nP12_3 = DEVICE_STATIONARY_VALIDATION_PENDING`r`nP12_5 = FIELD_EXECUTION_NOT_AUTHORIZED`r`n```


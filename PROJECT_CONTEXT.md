# Project Context

## Status

First Operational Pilot. P0–P5 están cerradas. El baseline oficial resultante de P5 es
`d50fb8e2d807dc97a16c81f4ffaa6fcfa89fbaca`; el PR funcional #14 fue integrado y la
validación post-merge de P5 terminó correctamente. P5.1–P5.7 están completados y sus
23 criterios de Definition of Done están satisfechos. El privilegio elevado actual de
`geoguide_app` permanece registrado como deuda de hardening posterior.

P4 implementó routing puro sin persistencia: el backend depende de `RoutingProvider`,
GraphHopper 11 se integra mediante un adaptador sustituible y
`POST /api/v1/routes/plan` devuelve distancia y duración normalizadas junto con una
geometría GeoJSON `LineString`. La URL, el perfil y el timeout backend → proveedor son
configurables; timeout, indisponibilidad, ausencia de ruta, respuesta inválida y errores
del proveedor se normalizan sin filtrar detalles internos. Las pruebas de aceptación y
la validación real en VM están completadas.

P5 — Route Discovery está **CERRADA**. P5.0-A–P5.0-D y P5.1–P5.7 están cerrados;
corredor PostGIS, selección de candidatos POI, ranking `DISCOVERY_V1`, progreso de ruta
y `POST /api/v1/routes/discover` fueron implementados y validados localmente y en VM.
P6 — Mobile Bootstrap está **CERRADA**. El bootstrap Flutter, `flutter_map 8.3.2`,
mapa base, interacción, permiso de ubicación aproximada y ubicación puntual fueron
validados en Android; la evidencia está en `P6-Validation-Evidence.md`.
`TILE_PROVIDER_GOVERNANCE` permanece pendiente. P7 — First Vertical Slice está
**CERRADA**: P7.1–P7.5 fueron integrados y P7.6 completó la auditoría y el cierre
formal. TLS productivo, renovación y E2E Android exclusivamente HTTPS están validados.
El incidente histórico de delegación del parent fue verificado nuevamente el
5-oct-2026: ambos parent autoritativos devolvieron exactamente `ns1.desec.io` y
`ns2.desec.org`. Estado actual: `PARENT_DELEGATION_INCIDENT = RESOLVED_WITH_EVIDENCE`,
`PARENT_DELEGATION_RISK = CLOSED`, `PARENT_DELEGATION_P8_IMPACT = NONE`.
Los comandos y resultados están en la [reconciliación post-P7](docs/11-Master-Documentation/11-Implementation-Plan/Post-P7-Documentation-Reconciliation.md).
P8 — POI Experience está **CERRADA** en
`7dfb0293507dcfa1eef90533c4dc9dbdd4d2a229` (PR #43), conforme a
[P8.7 Final Audit and Closure](docs/11-Master-Documentation/11-Implementation-Plan/P8.7-Final-Audit-and-Closure.md).
El [contrato P8](docs/11-Master-Documentation/11-Implementation-Plan/P8-Phase-Contract-v1.md)
permanece congelado; sus estados de apertura son históricos. P8.6 y P8.7 están
COMPLETED; Android físico, ubicación precisa puntual y accesibilidad están en PASS.
La evidencia de cierre registra Testcontainers 6/6, backend 59/59, Flutter 27 tests,
Flutter analyze y APK HTTPS en PASS; son resultados del cierre P8.
P0–P8 están completadas. P9.0 COMPLETED: contrato y anexo aprobados por decisión humana e integrados mediante PR #45 en `c6f774c7121632c46c412ffc6faca83e715b1d10`. Los estados pendientes dentro del contrato congelado reflejan su preparación anterior a esa aprobación y se preservan como evidencia histórica.
P9.1 implementó exclusivamente Offline Data / Local Cache y fue integrado mediante PR #46 en
`80cb217b0c2818a4a13861ba4a6457e21c5b9043`. Véase [evidencia P9.1](docs/11-Master-Documentation/11-Implementation-Plan/P9.1-Validation-Evidence.md).
La validación post-merge pasó y P9.1 está CLOSED; el cierre formal de P9 completo no se
declara. P9.2 está CLOSED en `756c0f33cabb1558c22d353ecaf6793194b93dd6`; véase
[evidencia P9.2](docs/11-Master-Documentation/11-Implementation-Plan/P9.2-Validation-Evidence.md).
D06 DEFERRED, dispositivo físico no utilizado y TalkBack físico no ejecutado.
P10 está cerrada; P11 está cerrada con la deuda P11-BACKUP-01 abierta que bloquea Production Readiness. P12 está en curso bajo contrato congelado: P12.2 PASS, P12.3 CLOSED_PASS_STATIONARY y P12.4 pendiente de revisión humana. El 45% es crédito del modelo administrativo aprobado por entregables; no constituye validación dinámica ni cierre funcional.

```ini
P12_STATUS = IN_PROGRESS
P12_PROGRESS = 45_PERCENT
GLOBAL_PROGRESS_MATHEMATICAL = 98.35_PERCENT
GLOBAL_PROGRESS_VISUAL = 98.4_PERCENT
P12_3 = CLOSED_PASS_STATIONARY
P12_4 = PENDING_HUMAN_READINESS_REVIEW
P12_5 = NOT_AUTHORIZED
DYNAMIC_ROAD_VALIDATION = NOT_EXECUTED
```
El roadmap indica progresión, no autorización de ejecución.

El baseline de cierre P7 es `ada26c8881cdefb2d8f0ede679a8ebb3996ab61c` (PR #31).
El contrato P7 es un snapshot normativo congelado e inmutable: sus estados históricos
no sustituyen el cierre posterior registrado en `P7-Validation-Evidence.md`, este
contexto, `ROADMAP.md` y `CHANGELOG.md`.

## Product definition

GeoGuide AI is a mobile platform for intelligent geographic discovery built with an
Open Source First technology strategy. This strategy does not determine the product
license, whose current legal status is governed by `LICENSE`. The product helps people
understand what is worth discovering around their current location and along a planned
or active route. It is neither a replacement for Google Maps/Waze nor a generic chatbot.

The product covers cultural, historical, archaeological, natural, gastronomic, and other useful POIs. Enriched place cards distinguish reliable sourced facts from generated summaries. Route Discovery analyzes POIs near a route corridor; detour distance and additional time may be introduced incrementally.

### Conversational identity

- **Product:** GeoGuide AI.
- **Conversational identity:** CEFI.
- **Role:** CEFI is GeoGuide AI's voice-oriented conversational copilot for the rutero. It uses shared GeoGuide capabilities to communicate information, context, and recommendations while preserving user control.
- **Boundary:** CEFI does not replace Routing, Route Discovery, POI Data, or other technical and factual sources.
- **Status:** Product concept and future experience capability. Implementation is **NOT AUTHORIZED** unless an approved phase contract explicitly includes it. CEFI remained outside the closed P5 scope and was not implemented.

## Approved MVP architecture

- Mobile: Flutter / Dart.
- Backend: Java 21, Spring Boot 3, Modular Monolith, Clean Architecture.
- Data: PostgreSQL + PostGIS, Redis, and MinIO.
- Maps/data: OpenStreetMap.
- Routing: `RoutingProvider`; GraphHopper 11.0 is the initial implementation selected
  by ADR-028. OSRM and Valhalla remain replaceable alternatives.
- Infrastructure: Linux, Docker, Docker Compose, and Nginx.
- CI/CD: GitHub Actions.
- AI: contextual to location, route, POIs, preferences, and travel state; advanced generative capabilities remain optional and decoupled through `LanguageModelProvider`.

## Interaction architecture

- Flutter UI, voice, and future clients reuse channel-independent application services.
- Strategic hands-free flow: STT -> intent and context interpretation -> GeoGuide services -> TTS.
- Driving/Travel Mode prioritizes short spoken answers, minimal visual distraction, and no required phone manipulation while driving.
- Voice must not make an LLM, complex personalization, CarPlay, or Android Auto mandatory for the core MVP.

## Principles

- Route Discovery Engine is the core differentiator.
- Facts First, AI Second.
- Do not permanently store user GPS history by default.
- Architecture changes require an accepted ADR.

Kubernetes, microservices, mandatory public cloud, complex ML personalization,
advanced generated itineraries, CarPlay/Android Auto integrations, and real-time traffic are outside the MVP. See
`DOCUMENTATION_INDEX.md` for the current authority model and navigation. Authority
is scoped by domain: accepted ADRs govern architecture, approved phase contracts govern
authorized phase scope, `PROJECT_CONTEXT.md` records current state, and `ROADMAP.md`
defines progression without authorizing implementation.

## P9 final closure — documentary reconciliation

El cierre humano final de P9.3 y P9.4 fue aprobado. La evidencia consolidada establece:

```ini
P9_1 = CLOSED
P9_2 = CLOSED
P9_3 = CLOSED
P9_4_AUDIT = PASS_WITH_NON_BLOCKING_ITEMS
P9_4_HUMAN_CLOSURE = APPROVED
P9_4 = CLOSED
P9 = CLOSED
P9_IMPLEMENTATION = COMPLETED
P10 = NOT_STARTED
AUTONOMOUS_P10 = NOT_AUTHORIZED
```

P9.3 conserva `P9_3_28_NO_BACKUP = LIMITED_BY_NON_INVASIVE_VALIDATION`, la observación `TALKBACK_MIXED_LANGUAGE_OBSERVATION = NON_BLOCKING` y la deuda `TECH_DEBT_P9_1_001 = LOW / OPEN_NON_BLOCKING`. No existen criterios FAIL o BLOCKED.

Baselines históricos preservados:

```ini
P9_CONTRACT_BASELINE = c6f774c7121632c46c412ffc6faca83e715b1d10
P9_1_FINAL_CLOSURE_BASELINE = c659ed9ae4d31cbb58174c180bfcd9762f9d441f
P9_2_APPROVED_HEAD = 6be2ed059aede2a8a369a3128507c00c9f7b134e
P9_2_MERGE_COMMIT = 756c0f33cabb1558c22d353ecaf6793194b93dd6
P9_2_FINAL_BASELINE = 756c0f33cabb1558c22d353ecaf6793194b93dd6
P9_3_INITIAL_EVIDENCE_BASELINE = 0f05515a83130b6ee89cca1a0bbeb5928e141bad
P9_3_FINAL_EVIDENCE_COMMIT = eeb154aba054b347eea9f350f9b8aedbe00b16d5
P9_IMPLEMENTATION_BASELINE = 756c0f33cabb1558c22d353ecaf6793194b93dd6
P9_PHYSICAL_VALIDATION_BASELINE = eeb154aba054b347eea9f350f9b8aedbe00b16d5
```

El cierre documental no inicia P10 ni modifica contratos, código, dependencias, infraestructura o dispositivo físico.

## GPS + CEFI integrado — 2026-10-11

PR #76 MERGED mediante merge commit normal `8a2e6cad14f2ae88111c0ba17dd89241894a5ee6`. Padres: `e19e17212c48ecf1b9604c512cac4f5b9fb64686` y `c65ac7b4885d514dbc86a237d688a22dba49b085`. La rama funcional se conserva.

IMPLEMENTED_AND_AUTOMATED_PASS: cámara GPS del mapa normal, sesión Active Route Session B1/B1.1 con productor exclusivo, entrega limitada C1, consentimiento revocable y voz local C2, diagnóstico C2.1 únicamente debug y fuera de Driving. La arquitectura Kotlin + servicio location + FlutterEngine dedicado sigue provisional; el contrato unificado permanece propuesto, sin congelarse por este merge.

PHYSICALLY_VALIDATED_STATIONARY: evidencia histórica HONOR LLY-NX3/API 36 de inicio/Home/bloqueo/Stop, iconos, cierre de lista y diagnóstico de voz fijo con finalización/cancelación/revocación. Corresponde a APK anteriores. La corrección final de exclusividad no tiene retest físico.

NOT_VALIDATED: proximidad POI audible real (ensayos previos BLOCKED_NO_ELIGIBLE_POI), convivencia con navegación/llamadas/música, liberación física independiente de audio focus, seguimiento prolongado, Doze, batería, revocación Android real, proceso/reinicio y conducción. DEFERRED: continuo sin ruta y cámara pasiva Driving. I01 implementa la conexión de POIs explícitamente elegidos al worker, con validación automatizada PASS y validación física NOT_EXECUTED; véase [evidencia I01](docs/11-Master-Documentation/11-Implementation-Plan/I01-Selected-POI-Session-Integration-Evidence.md). No se extrapola PASS del diagnóstico a proximidad.

P12 permanece IN_PROGRESS al 45%; global matemático 98.35%, visual 98.4%. P12.4 pendiente de revisión humana; P12.5 NOT_AUTHORIZED. P11-BACKUP-01 sigue bloqueando Production Readiness. Este merge no acredita entregables P12 ni autoriza distribución, conducción o pruebas físicas. Photon y LAB-08 sin cambios.

Evidencia post-merge: [GPS-CEFI-Post-Merge-Governance-Evidence.md](docs/11-Master-Documentation/11-Implementation-Plan/GPS-CEFI-Post-Merge-Governance-Evidence.md).

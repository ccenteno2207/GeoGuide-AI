# UI-2.3.2 — Búsqueda local y accesibilidad

Fecha: 2026-10-18. Ejecución local autorizada; no representa integración, cierre
maestro UI-2 ni validación física.

## Baseline y alcance

- Baseline de `origin/main` tras `git fetch origin`: `2f84123536ddd2da62a1bcbf53fc415a1cd1f4a5`.
- Rama: `codex/ui2-3-2-local-search-accessibility-corrective`.
- Worktree: `D:\Codex\worktrees\GeoGuide-AI\ui2-3-2-local-search-accessibility-corrective`.
- Se preservó el checkout principal, worktrees concurrentes, stashes y borradores UI-0.
- El antecedente físico UI-2.3.1 reportó S01 `FAIL` (teclado que se oculta) y A01 `PARTIAL` (texto español pronunciado en inglés). Se consultó el registro privado solo en lectura; no se copiaron datos privados aquí.
- Fuentes rectoras: contrato UI-2 congelado y matriz de compatibilidad, evidencia UI-2.3/UI-2.3.1 y protocolos físicos UI-2.2/UI-2.3.1. No se modificaron contratos congelados.

## UI232-S01 — Causa y corrección

La reproducción automatizada antes del cambio falló tras aplicar `viewInsets`
con el campo enfocado. El `TextField` seguía encontrándose en el árbol, pero su
estado pasaba a `defunct` y el canal de texto emitía `TextInput.clearClient` y
`TextInput.hide`. El fallo automatizado se reprodujo en 360×640; el propietario
había corroborado el síntoma en el HONOR. La causa técnica se demuestra en el
harness Flutter y su correspondencia física queda pendiente de revalidación.

El `Stack` de exploración elimina condicionalmente el grupo flotante al aparecer
el teclado. Sus ramas dinámicas compartían posición sin identidad estable; al
reconciliar ese cambio, Flutter sustituía el subárbol de la lista y desconectaba
el campo. Se asignaron claves estables a la posición de acciones flotantes y al
overlay de lista. El buscador también quedó como encabezado fijo del panel, fuera
del `ListView`, y recibió un `FocusNode` propiedad de la pantalla con ciclo de
vida explícito. Esto mantiene el campo montado, visible y enfocado mientras el
Scaffold acomoda el teclado; no usa esperas ni solicitudes repetidas de foco.

La prueba de regresión que fallaba antes pasa después con `TextInput.show`
vigente, la misma instancia de estado del `TextField`, foco conservado, escritura,
filtrado, borrado, cierre y reapertura del panel. Se verificó con insets inferiores
de 180 dp en 360×640, 360×800, 640×360 y 800×360. Los filtros siguen siendo
locales; no se agregó tráfico de red ni se alteraron snapshot, selección I01,
GPS, Driving o CEFI. No se ejecutó ADB ni se instaló APK; la revalidación física
en el HONOR sigue pendiente.

## UI232-A01 — Idioma y TalkBack

**Causa de pronunciación: `UNCONFIRMED`. Remediación: `DEFERRED` / decisión
requerida para cualquier política global de idioma.**

`GeoGuideApp` usa `MaterialApp` sin `locale`, `supportedLocales` explícitos ni
delegates; el locale resuelto actual en Flutter es `en_US`. Con locales de
plataforma simulados `es_PE` y `en_US`, la aplicación continúa resolviendo
`en_US`. Las pruebas inspeccionan la semántica de lista, Preview y Detail:
preservan `Museo Ámbar`, acentos y la descripción española, y el nodo de texto no
declara `Semantics.locale`. La prueba del mapper también conserva el nombre y la
descripción inglesa legítima (`Amber Museum`) sin traducir.

Esto describe `APP_LOCALE`, `TEXT_LANGUAGE` y `SEMANTICS_LOCALE`; no determina
`TALKBACK_SPEECH_LOCALE`. Un widget test no reproduce el motor de voz ni su
selección de idioma. Por tanto, no se atribuye causalidad al locale `en_US`, no se
fuerza español sobre contenido multilingüe y no se modifica configuración del
HONOR. Una solución que exija localización general de Flutter, traducciones de
Material o política de idioma por país requiere una decisión humana adicional:
`UI232_A01_DECISION_REQUIRED`.

## Archivos y pruebas

- Producción: `mobile/lib/features/map/presentation/base_map_page.dart` — clave
  estable de ramas del Stack, campo de búsqueda persistente y ciclo de vida del
  foco.
- Regresión teclado/búsqueda: `mobile/test/features/discovery/ui2_experience_test.dart`.
- Comparación de locale y semántica: `mobile/test/features/discovery/ui231_poi_language_test.dart`.
- Este documento y fila de índice: `DOCUMENTATION_INDEX.md`.

Validación final:

| Comprobación | Resultado |
| --- | --- |
| `dart format --output=none --set-exit-if-changed .` | PASS, 85 archivos, 0 cambios |
| `flutter analyze --no-pub` | PASS, 0 issues |
| `flutter test --no-pub --reporter expanded` | PASS, 232 pruebas |
| Regresión S01 | PASS, 4 tamaños con insets de 180 dp; prueba previa falló como se esperaba |
| Localización y semántica | PASS, lista/Preview/Detail con locales de plataforma `es_PE` y `en_US` |
| `git diff --check` | PASS |
| Build debug | PASS, 386,8 s; 167 843 109 bytes; SHA-256 `32F2D62A4B7E6A007E92CB89F2DB6990F8D9E4E2AE6E0983BAEA045E1FDB70B5` |
| Build release | PASS, 545,3 s; 60 472 029 bytes; SHA-256 `A9F4F4237174CCD8D9C3C86D73066D6A0AE12E55DCBF1C2652C3BE1DCC8AFB0E` |

Ambos APK se construyeron con `--dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443` y declaran `com.geoguideai.geoguide_ai` (versión `1.0.0`, SDK objetivo 36). Se encontró la URL compilada en el APK release. El manifiesto mantiene únicamente los permisos ya declarados por el proyecto; no se modificó configuración Android.

La inspección de los assets raster del APK release encontró el logo de `flutter_map`
y siete recursos raster empaquetados de Android; no hay fotografías ni recursos
multimedia piloto. `pubspec.yaml` no declara una sección activa de assets. Gradle
reportó el uso restringido de `System.load`, desfase XML entre SDK tools, opciones
Java source/target 8 obsoletas y tree-shaking de Material Icons (1 645 184 a
4 112 bytes); los dos builds finalizaron correctamente. Las capturas renderer,
si se generan, no representan un teléfono ni TalkBack.

## Riesgos, estado y revalidación

- Riesgo residual: el harness Flutter modela foco e insets, pero no el IME real
  del HONOR. Confirmar físicamente que se puede abrir, escribir, corregir,
  borrar y cerrar el teclado después de instalar un APK en una sesión futura
  autorizada.
- A01 requiere una comprobación física futura con texto real y lectura española;
  conservar las preferencias del dispositivo y no atribuir el resultado a una
  causa sin inspeccionar la voz elegida por TalkBack.
- No se cambió idioma, TTS, permisos, backend, API, DTO, base de datos,
  dependencias, fotos, Driving, GPS, CEFI ni los contratos congelados.

El bloque siguiente conserva el estado al terminar la ejecución local original.
La autorización posterior y su integración se registran al final, sin convertir
la evidencia automatizada en validación física.

```ini
UI_2_3_2_S01_ROOT_CAUSE = CONFIRMED
UI_2_3_2_S01_REMEDIATION = PASS
UI_2_3_2_A01_ROOT_CAUSE = UNCONFIRMED
UI_2_3_2_A01_REMEDIATION = DEFERRED
UI_2_3_2_AUTOMATED_VALIDATION = PASS
UI_2_3_2_LOCAL_COMMIT = PASS

UI_2_3_2_PUSH = NOT_AUTHORIZED
UI_2_3_2_PR = NOT_AUTHORIZED
UI_2_3_2_MERGE = NOT_AUTHORIZED
UI_2_3_2_PHYSICAL_INSTALLATION = NOT_AUTHORIZED

UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```

## Integración controlada y verificación post-merge

Registro: 2026-10-18 (UTC-05). El propietario autorizó posteriormente push, PR,
auditoría y merge normal, además de trazabilidad y preparación documental de la
revalidación. Esta autorización no incluye dispositivo, ADB ni instalación.

| Evidencia Git/PR | Resultado verificado |
| --- | --- |
| Baseline remoto antes de integrar | `2f84123536ddd2da62a1bcbf53fc415a1cd1f4a5`, sin avance al hacer fetch |
| Commit funcional | `3b4ee6f985edd5f7f7af7621a98be6d7ccce9358` |
| Precisión documental pre-PR | `c1be6c0c2cbd8f5290a628f23dae60a7478f37c9`; distingue síntoma físico de causa demostrada en harness, sin cambios móviles |
| Pull Request | [PR #92](https://github.com/ccenteno2207/GeoGuide-AI/pull/92), `MERGED` |
| Momento del merge | `2026-10-19T04:19:32Z` |
| Merge normal / baseline funcional integrado | `853a9d7d115259ecc3d8b0db06b2ee7240b9a119` |
| Primer padre | `2f84123536ddd2da62a1bcbf53fc415a1cd1f4a5` |
| Segundo padre | `c1be6c0c2cbd8f5290a628f23dae60a7478f37c9` |
| Árbol auditado e integrado | `2dbc311161440ff32c5bcb5d378ca958dc35bf94`; igualdad completa del árbol entre head del PR y merge |
| Ascendencia del commit funcional | PASS, `git merge-base --is-ancestor` devuelve 0 |
| GitHub checks | `NOT_CONFIGURED`: cero check-runs, cero commit statuses y rollup vacío; no se declara CI_PASS |
| Revisiones externas | Ninguna registrada, solicitudes y comentarios vacíos al auditar; no se afirma aprobación externa |

La auditoría pre-PR revisó el diff completo de cinco archivos y ambos commits,
la compatibilidad con UI-2 y la protección de insets/atribución de UI-2.3.1. Solo
se modificaron la pantalla de exploración, dos pruebas y la evidencia/índice.
El `FocusNode` tiene creación y dispose explícitos; no se añadieron timers ni
solicitudes repetitivas de foco. Backend, DTO, API, DB, permisos, dependencias,
contratos congelados, GPS, Driving, CEFI y medios permanecen fuera del diff.

Se reutilizan los resultados locales anteriores: 232 pruebas, analyze, formato,
regresión S01 y ambos builds. El commit posterior a la validación fue solamente
documental. El merge tiene el mismo árbol que el head auditado y el mismo
contenido móvil validado, por lo que no se repitieron tests ni builds sin causa
técnica adicional. Las comprobaciones post-merge fueron Git/PR, ascendencia,
árbol, alcance, hashes y preservación; no se inventa una nueva ejecución CI.

Se recalcularon los hashes debug/release y coinciden exactamente con los de la
tabla local. La inspección de ambos ZIP APK no encontró paths de assets de test
o fixtures ni fotografías piloto. Los assets Flutter contienen manifiestos,
fuente Material Icons, shaders y el logo de flutter_map; debug incorpora los
artefactos kernel/snapshot esperados. El endpoint esperado también está presente
en el kernel debug. No se recompiló, instaló ni accedió al teléfono.

El nuevo [protocolo focalizado S01](UI-2.3.2-Focused-Physical-Validation-Protocol.md)
queda `PREPARED`, con cada resultado físico en `NOT_EXECUTED`. Los casos UI-2.2
no ejecutados, aspectos parciales de accesibilidad, deuda visual CEFI y demás
pendientes aceptados conservan sus estados; este merge no les concede PASS.
No se repiten automáticamente los 36 casos ni el layout UI-2.3.1 ya observado.

El registro post-merge se prepara en rama/worktree documental independiente,
partiendo de `853a9d7d115259ecc3d8b0db06b2ee7240b9a119`, para un PR documental
separado. Su integración no cambia el baseline de código descrito arriba.
El checkout principal permanece en `e443c0aa10987e04367dd15a1df259438426c3bc`
con los tres borradores UI-0. La comparación de worktrees, archivos pendientes,
stashes y hash del registro privado se conserva fuera del repositorio; no se
copió evidencia privada al PR.

```ini
UI_2_3_2_PRE_PR_AUDIT = PASS
UI_2_3_2_PR = MERGED
UI_2_3_2_INTEGRATION = PASS
UI_2_3_2_S01_AUTOMATED = PASS
UI_2_3_2_S01_PHYSICAL = NOT_EXECUTED
UI_2_3_2_A01_ROOT_CAUSE = UNCONFIRMED
UI_2_3_2_A01_REMEDIATION = DEFERRED
UI_2_3_2_PHYSICAL_SESSION = PREPARED
UI_2_3_2_PHYSICAL_INSTALLATION = NOT_AUTHORIZED
GITHUB_CHECKS = NOT_CONFIGURED
EXTERNAL_REVIEW = NONE_RECORDED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```

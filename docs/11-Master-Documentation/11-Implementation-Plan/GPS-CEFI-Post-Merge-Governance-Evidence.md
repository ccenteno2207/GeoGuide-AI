# GPS + CEFI — evidencia post-merge y conciliación

## GPS + CEFI integrado — 2026-10-11

PR #76 MERGED mediante merge commit normal `8a2e6cad14f2ae88111c0ba17dd89241894a5ee6`. Padres: `e19e17212c48ecf1b9604c512cac4f5b9fb64686` y `c65ac7b4885d514dbc86a237d688a22dba49b085`. La rama funcional se conserva.

IMPLEMENTED_AND_AUTOMATED_PASS: cámara GPS del mapa normal, sesión Active Route Session B1/B1.1 con productor exclusivo, entrega limitada C1, consentimiento revocable y voz local C2, diagnóstico C2.1 únicamente debug y fuera de Driving. La arquitectura Kotlin + servicio location + FlutterEngine dedicado sigue provisional; el contrato unificado permanece propuesto, sin congelarse por este merge.

PHYSICALLY_VALIDATED_STATIONARY: evidencia histórica HONOR LLY-NX3/API 36 de inicio/Home/bloqueo/Stop, iconos, cierre de lista y diagnóstico de voz fijo con finalización/cancelación/revocación. Corresponde a APK anteriores. La corrección final de exclusividad no tiene retest físico.

NOT_VALIDATED: proximidad POI audible real (ensayos previos BLOCKED_NO_ELIGIBLE_POI), convivencia con navegación/llamadas/música, liberación física independiente de audio focus, seguimiento prolongado, Doze, batería, revocación Android real, proceso/reinicio y conducción. DEFERRED: continuo sin ruta, cámara pasiva Driving y conexión de POIs elegidos al worker. No se extrapola PASS del diagnóstico a proximidad.

P12 permanece IN_PROGRESS al 45%; global matemático 98.35%, visual 98.4%. P12.4 pendiente de revisión humana; P12.5 NOT_AUTHORIZED. P11-BACKUP-01 sigue bloqueando Production Readiness. Este merge no acredita entregables P12 ni autoriza distribución, conducción o pruebas físicas. Photon y LAB-08 sin cambios.

## Validación post-merge

| Control | Resultado post-merge |
| --- | --- |
| main sincronizado / merge | PASS; merge normal con los dos padres aprobados; rama funcional preservada |
| Format | PASS, 67 archivos sin cambios |
| Analyze | PASS, sin incidencias |
| Flutter | PASS, 132/132 |
| JVM B1 / C2 / C2.1 | PASS, 50 / 80 / 43 aserciones |
| Tests verificador assets | PASS, 5/5 |
| Build debug HTTPS | PASS; BACKEND_BASE_URL=https://geoguide.getcom.pe:5443 |
| Assets debug / release | PASS, MaterialIcons 1.645.184 / 3.792 bytes |
| Exclusión diagnóstico release | PASS estático: AOT de tres ABI sin texto/canal del diagnóstico, marcador positivo GeoGuide AI presente; aapt2 sin application-debuggable; gate nativo FLAG_DEBUGGABLE preservado |
| Driving | Métodos enter/exit/build idénticos al baseline aprobado; guard de diagnóstico fuera de Driving preservado |
| Contratos / backend | Sin cambios en el merge; código móvil idéntico al HEAD aprobado |

Comandos ejecutados: `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze --no-pub`, `flutter test --no-pub`; `gradlew :app:b1PolicyChecks :app:c2VoiceChecks :app:c21DiagnosticChecks --max-workers=2` con JDK 21; unittest Python del verificador y verificación de ambos APK; `flutter build apk --debug --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`. No instalaciones ni pruebas físicas.

APK debug post-merge SHA-256: `17E70841FCEF069E2250DE8CA8014CE77928713B5A2DD5CA6F2FF428624ACF16`. El hash difiere de la compilación previa: no se afirma identidad binaria, y este APK no tiene validación física.

Release reutilizado de la auditoría reciente, sin recompilar: `F83926926346B5E1DA6EE273E8A29EA902B66EB5E97832EAD15905207CBF0AE8`. Git confirma igualdad exacta del código móvil entre HEAD aprobado y merge. Se reinspeccionó el APK, AOT y assets; la firma debug preexistente impide tratarlo como distribución productiva. Warnings preexistentes AGP/Kotlin/SDK/deprecaciones y tiles no son regresiones funcionales.

GitHub permitió el merge normal sin bypass, admin override, squash ni rebase. No había checks o reviews reportados; las APIs de protección/rules devolvieron 403 por limitación del plan, por lo que no se afirma una auditoría exhaustiva de configuración de protección.


## Conciliación

La rama documental se crea desde el merge definitivo. Se actualizan contexto, índice, changelog, seguimiento del ADR candidato y esta evidencia común para GPS/B1/B1.1/C1/C2/C2.1. Las evidencias previas permanecen históricas; no se reescriben resultados ni contratos congelados. No existe copia versionada del Libro de Operaciones. PR documental preparado localmente; push y creación pendientes de autorización.

## Documentación externa y control

Se añadieron cortes vigentes al Libro de Operaciones y a la bitácora P12, preservando íntegramente su contenido histórico. Respaldo verificado: `D:/Proyectos/Desarrollo/Ruteo/Documentacion Ruteo/backup-gps-cefi-postmerge-20261011-111603`. SHA-256 finales:

- `GeoGuide-AI_Libro_de_Operaciones.md`: `4F15EB8803907EC6EA0F0A24C08D9372910AECBD1CA43ABCE32BF7F81C56F99B`.
- `GeoGuide-AI_P12_Procedimientos_y_Evidencias.md`: `B05D2BA0C86E211CC018F06663F1F12A4B39B3E6CA5C89515047182F41DE9AC6`.

Excel: cinco hojas revisadas (Resumen, Cronograma, Hitos, Riesgos, Actualización); archivo ZIP íntegro, fórmula SUMPRODUCT preservada, D17=0.45 y ponderaciones intactas. Sin cambios: este paquete independiente carece de crédito aprobado en el modelo P0–P12. No se añaden hitos inventados ni se reescribe una actualización histórica. Hash antes/después idéntico: `872CB619CBBBAA6F89FA8020FF970D31820BC0FB1BDF132D0D10632202EE9199`. Se verificó estructura OOXML, no apertura física de Excel.

## PR documental preparado

Título: `docs: reconcile GPS and CEFI integration after PR 76`. Base: main `8a2e6cad14f2ae88111c0ba17dd89241894a5ee6`. Rama: `docs/gps-cefi-postmerge-governance-20261011`.

Descripción propuesta: Registra la integración GPS/CEFI de PR #76 y su validación post-merge; actualiza contexto, índice, changelog y seguimiento del ADR provisional. Distingue pruebas automatizadas, evidencia estacionaria histórica y escenarios pendientes, sin otorgar nuevo avance P12. Incluye trazabilidad de conciliación externa y revisión del Excel sin cambios. UTF-8, enlaces y diff check verificados. No cambia código, permisos, contratos congelados ni infraestructura. Publicación y creación del PR requieren nueva autorización.

Veredictos: GPS_CEFI_MERGED_POSTMERGE_PASS y DOCUMENTATION_RECONCILIATION_READY_FOR_PR. P12.5 NOT_AUTHORIZED.

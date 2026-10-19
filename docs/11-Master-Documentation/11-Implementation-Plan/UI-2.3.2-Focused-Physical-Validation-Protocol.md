# UI-2.3.2 — Protocolo físico focalizado S01

Estado: `PREPARED`. Preparación documental autorizada el 2026-10-18; ejecución,
ADB, instalación, capturas y TalkBack `NOT_AUTHORIZED` en esta ejecución.
Dispositivo futuro previsto: HONOR LLY-NX3, estacionario, con el propietario.

## Objetivo y evidencia de partida

Comprobar el teclado real y la búsqueda local después de la integración S01 del
[PR #92](https://github.com/ccenteno2207/GeoGuide-AI/pull/92), merge
`853a9d7d115259ecc3d8b0db06b2ee7240b9a119`. La
[evidencia técnica UI-2.3.2](UI-2.3.2-Local-Search-and-Accessibility-Corrective-Evidence.md)
registra 232 tests y regresión de foco/insets PASS; no representa una prueba del
IME Android. A01 mantiene causa `UNCONFIRMED` y remediación `DEFERRED`.

No repetir automáticamente el protocolo completo UI-2.2 ni el layout UI-2.3.1
ya validado por el propietario. Conservar los pendientes de la
[matriz física UI-2.2](UI-2.2-Physical-Validation-Traceability-Matrix.md).
Si se observa una regresión nueva, detener ese caso y registrar el hallazgo;
no corregir código ni ampliar la sesión sobre la marcha.

## G0 — Autorización y artefacto, antes de cualquier acceso

Requiere nueva autorización expresa para la sesión física y sus operaciones.
Confirmar presencia del propietario, dispositivo exclusivo y estacionario,
estado Rutea/GPS/voz que deba preservarse y disponibilidad de la ruta de prueba.
No detener una sesión existente, activar GPS/voz ni cambiar permisos o ajustes
sin autorización. TalkBack queda fuera de esta sesión salvo aprobación específica.

APK debug candidato original:

```text
D:\Codex\worktrees\GeoGuide-AI\ui2-3-2-local-search-accessibility-corrective\mobile\build\app\outputs\flutter-apk\app-debug.apk
SHA-256: 32F2D62A4B7E6A007E92CB89F2DB6990F8D9E4E2AE6E0983BAEA045E1FDB70B5
Package: com.geoguideai.geoguide_ai
Versión: 1.0.0 / versionCode 1
Endpoint compilado: https://geoguide.getcom.pe:5443
```

El hash identifica el archivo ya construido, no cualquier APK futuro. Antes de
instalar, volver a comprobar existencia, SHA-256, firma y certificado del archivo,
compatibilidad con la instalación presente, identidad de package y procedencia
del código. Esta preparación no afirma haber comparado la firma con el teléfono.
Si falta el APK o difiere el hash, detener la instalación y auditar el artefacto
nuevo; una recompilación exige nuevos resultados y hash. La actualización futura
solo puede realizarse con autorización específica, conservando datos; no
desinstalar, borrar datos ni usar opciones para saltar incompatibilidades.

## G1 — Ruta y POIs existentes

Con TalkBack apagado y sin activar ubicación/seguimiento/avisos, seleccionar por
mapa los extremos de una ruta acordada (Lima–Canta si sigue disponible), calcular
y anotar el resumen y conteo reales. No exigir los 97,9 km/104 min/5 POIs de una
sesión anterior. El snapshot debe estar vigente y contener un nombre apto para
filtrar. Si el backend o la ruta fallan, registrar el bloqueo, sin imputarlo al
teclado ni modificar infraestructura.

## G2 — Casos mínimos

Usar nombres reales del snapshot visible; las cadenas de búsqueda son entradas
de usuario, no contenido nuevo de POI. Evitar capturas o logs generales del móvil.

| Caso | Acción futura | Criterio esperado | Resultado actual |
| --- | --- | --- | --- |
| S01-P01 Apertura | Abrir «Ver lista» y tocar «Buscar en estos resultados». | Campo y teclado permanecen visibles/operativos; no parpadeo ni cierre inmediato. | NOT_EXECUTED |
| S01-P02 Escritura y edición | Escribir fragmento de un nombre visible, editar caracteres, probar mayúsculas y un acento omitido cuando corresponda. | Texto editable; subconjunto correcto de nombres según normalización local. Anotar query y conteo observados. | NOT_EXECUTED |
| S01-P03 Vacío y borrado | Escribir cadena sin coincidencias y borrar el texto. | «No hay coincidencias en estos resultados»; al borrar reaparecen los resultados actuales sin recalcular. | NOT_EXECUTED |
| S01-P04 Teclado/panel | Cerrar el teclado con Back, cerrar la lista y reabrir en el mismo snapshot; volver a enfocar. | El teclado se cierra al pedirlo y se abre estable; la query se conserva mientras no cambie/venca el snapshot. No exigir una navegación Android nueva. | NOT_EXECUTED |
| S01-P05 Fichas | Con filtro no vacío, abrir Preview, Detail y regresar. | La query y el contexto válido de lista se conservan; no se inicia GPS ni voz. | NOT_EXECUTED |
| S01-P06 Categorías | Aplicar una categoría con resultados; luego Restablecer y Aplicar. | Resultados coherentes con el snapshot actual. La query anterior se limpia si se reemplaza el snapshot; no exigir preservarla a través del reemplazo. | NOT_EXECUTED |
| S01-P07 Red al escribir | Separar solicitudes legítimas de cálculo/categorías de la escritura del filtro. | Cero solicitudes de búsqueda/planificación/discovery al escribir, editar o borrar. Ver tratamiento de evidencia siguiente. | NOT_EXECUTED |

Para S01-P07, el spy de las pruebas automatizadas ya aporta evidencia de filtro
local sin llamadas al source. La observación visual del teléfono no demuestra
ausencia de tráfico. Solo si la futura autorización permite observación de red
acotada a Rutea/los endpoints relevantes, correlacionar los cambios de query con
esa evidencia, minimizando datos y sin capturar tráfico general o credenciales.
Sin ese mecanismo, dejar la parte física `NOT_VERIFIED_PHYSICALLY` y citar la
evidencia automatizada; no fabricar un PASS físico. No cambiar redes, usar proxies
ni desplegar instrumentación sin autorización independiente.

Durante estos casos observar únicamente si aparece una regresión evidente de
panel, controles o atribución OpenStreetMap. La ausencia de un hallazgo nuevo no
equivale a repetir la matriz de layout ni a acreditar otros casos UI-2.2.

## G3 — Restauración y decisión

Dejar el teclado cerrado y la query vacía; cerrar las fichas abiertas. Conservar
la ruta/contexto válido según lo acordado con el propietario. Confirmar que la
prueba no inició seguimiento GPS ni avisos de voz. No cambiar idioma, motor TTS,
permisos ni configuración global. Si TalkBack se autorizara separadamente,
registrar su estado inicial y restauración, sin atribuir su voz a APP_LOCALE.

Para cada caso registrar `PASS`, `FAIL`, `BLOCKED`, `NOT_EXECUTED` o
`NOT_VERIFIED_PHYSICALLY`, texto/conteo realmente observados y tipo de evidencia
(`OWNER_OBSERVED` u otra comprobación efectivamente autorizada). No elevar toda la
sesión a PASS si hay partes sin verificar. Los registros privados permanecen
fuera del repositorio; solo integrar conclusiones sanitizadas mediante el flujo
documental autorizado.

El cierre físico S01 dependerá de sus casos aplicables y de sus limitaciones
explícitas. A01, UI-2.2 pendiente, deuda visual CEFI, cierre maestro UI-2 y
Production Readiness no se cierran con este protocolo ni con el merge.

```ini
UI_2_3_2_PHYSICAL_SESSION = PREPARED
UI_2_3_2_S01_PHYSICAL = NOT_EXECUTED
UI_2_3_2_A01_ROOT_CAUSE = UNCONFIRMED
UI_2_3_2_A01_REMEDIATION = DEFERRED
UI_2_3_2_PHYSICAL_INSTALLATION = NOT_AUTHORIZED
TALKBACK_EXECUTION = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```

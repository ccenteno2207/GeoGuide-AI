# UI-2.3.1 — Segunda validación física focalizada

Estado: `PREPARED / EXECUTION_NOT_AUTHORIZED`. Fecha: 2026-10-18.
Dispositivo objetivo: HONOR LLY-NX3. Sesión estacionaria, propietario presente.
Este documento prepara la sesión; no autoriza conexión, ADB, instalación ni TalkBack.

## Baseline y artefacto

Implementación integrada por [PR #90](https://github.com/ccenteno2207/GeoGuide-AI/pull/90),
merge `37d5ef23136610e896ad1ac000fdda2f1774c1e5`.
Commit funcional `e1a9eb9ef12f36279a8f9e058c92098d94b5c976`.
El árbol del merge coincide con ese commit. Los cambios documentales posteriores
no recompilan ni sustituyen los APK.

| Artefacto | Identidad esperada |
| --- | --- |
| Debug propuesto para la futura instalación | `D:\Codex\worktrees\GeoGuide-AI\ui2-3-1-physical-findings-remediation\mobile\build\app\outputs\flutter-apk\app-debug.apk` |
| SHA-256 debug | `751b0e647d837f651b932e85299c25a7ffc5a67a077744327b713c8301ffded6` |
| Release, solo referencia local | SHA-256 `5402633afd7c24628b700648d16333f2334208bb4cf7b41557f89abad12e29d3` |
| Aplicación | `com.geoguideai.geoguide_ai`, versión 1.0.0, código 1 |
| Endpoint de compilación | `https://geoguide.getcom.pe:5443` |

Recomprobar archivo real, hash, package, versión, SDK, certificado y compatibilidad
de firma con la aplicación instalada antes de actualizar. No considerar válidos
estos hashes para una recompilación. No distribuir release como producción.
No desinstalar, borrar datos, degradar ni cambiar firma/package.

## Gates de la futura sesión

1. Obtener autorización humana separada para ejecutar esta sesión y comprobar
   presencia del propietario, dispositivo exclusivo y estado Rutea/GPS/CEFI a preservar.
2. Autorizar ADB de alcance mínimo para Rutea, si se necesita. Consultar únicamente
   metadatos necesarios y el paquete propio. Ningún inventario global de paquetes,
   servicios o accesibilidad; tampoco `dumpsys accessibility`, logcat global o bugreport.
3. Tras verificar el APK y la firma, obtener confirmación inmediata de instalación
   antes de una actualización `adb install -r`; detenerse ante incompatibilidad.
4. Para TalkBack, registrar el estado previo mediante el propietario y obtener
   confirmación específica antes de activarlo. Preferir intervención manual del
   propietario para encendido/restauración; no consultar servicios de otras apps.
5. Capturas solo con confirmación, limitadas a Rutea y sin notificaciones ni
   contenido personal. Si no puede garantizarse, usar observación del propietario
   y no capturar. No incorporar capturas privadas al repositorio.
6. Cambios de permisos, preferencias persistentes o tamaño de texto requieren
   autorización específica y un plan de restauración. No modificar idioma global,
   voces TTS, accesibilidad ajena a TalkBack ni ajustes para forzar el resultado.

## Procedimiento breve y trazabilidad

Aplican el [protocolo UI-2.2](UI-2.2-Physical-Validation-Protocol-Proposal.md) y su
[matriz](UI-2.2-Physical-Validation-Traceability-Matrix.md). Se registran únicamente
los subcasos efectivamente ejecutados; esta selección no convierte los 36 en PASS.

| Paso | Acción futura | Casos UI-2.2 | Criterio observable |
| --- | --- | --- | --- |
| Preparación | Verificar identidad/APK y actualizar solo tras los gates | 01–04 | Hash/firma compatibles, arranque estable y datos conservados |
| L01 mapa | Seleccionar por mapa Lima–Canta y calcular; registrar resumen y conjunto real | 05/06/09 | Panel fuera de navegación Android, atribución OSM visible, mapa/ruta/POI legibles |
| L01 lista | Abrir/cerrar lista, comprobar acciones y orientar el teléfono cuando sea seguro | 06/07/30/31, aspectos afectados | Footer visible en mapa/lista; controles alcanzables; sin superposición nueva |
| A01 | Elegir un POI público concreto, abrir Preview/Detail y recorrerlo con TalkBack | 11/27/28 | Texto visible y frase pronunciada registrados por separado; foco y acciones utilizables |
| Regresión breve | Categorías, búsqueda local y elección/quita explícita I01 | 08/13/14/19 | Misma semántica, orden/subconjunto coherentes, abrir una ficha no selecciona y elegir no inicia GPS |
| Cierre | Volver a exploración estable y restaurar ajustes temporales autorizados | 33/34/36 | TalkBack en estado previo confirmado; sin GPS/voz iniciados por la prueba; preferencias conservadas |

Los cinco POI se esperan solo si el backend devuelve el conjunto piloto. Registrar
la cantidad efectiva; una respuesta externa diferente requiere diagnóstico antes
de atribuirla a UI-2.3.1. No fabricar resultados ni modificar datos/backend.
Usar origen/destino en mapa; no activar ubicación puntual, seguimiento continuo,
recorrido B1 ni avisos CEFI para estas comprobaciones.

Para L01 observar borde completo del panel, cuatro botones, resumen y atribución
respecto de la navegación Android real. Un árbol de accesibilidad acredita
geometría/etiquetas, pero no acredita por sí solo ausencia de oclusión visual.
El modo de navegación Android se registra tal como esté; no cambiarlo para probar.

## A01 — Registro preciso de idioma

Usar, si está disponible, Plaza de Armas de Canta; en otro caso un POI público
existente. No inventar descripción cuando no llegue. Comparar los siguientes campos:

| Campo | Texto visible literal | Idioma del texto | Frase o pronunciación observada | Fuente de evidencia |
| --- | --- | --- | --- | --- |
| Nombre | Pendiente | Pendiente | Pendiente | Pendiente |
| Descripción, o ausente | Pendiente | Pendiente | Pendiente | Pendiente |
| Categoría y distancia | Pendiente | Pendiente | Pendiente | Pendiente |
| Fuente/URL | Pendiente | Pendiente | Pendiente | Pendiente |
| Atribución | Pendiente | Pendiente | Pendiente | Pendiente |
| Controles y frases del sistema | Pendiente | Pendiente | Pendiente | Pendiente |

Precisar si se trata de palabras inglesas, pronunciación inglesa de texto español
o frases del lector. `OpenStreetMap contributors`, nombres propios y URLs pueden
conservar su texto original. No traducir ni asumir fallo por esas cadenas.
Identificar exactamente la frase y el campo antes de atribuir una causa.

La revisión previa encontró datos curatoriales españoles, respuesta pública con
descripción no disponible, localización Flutter predeterminada `en_US` y ausencia
de locale explícito por texto en el nodo inspeccionado. Ninguno demuestra por sí
solo la causa física. A01 mantiene `UNCONFIRMED / DEFERRED` hasta nueva evidencia.

## Pendientes y límites

- Completar los aspectos afectados de 05/06, 11, 19, 27/28 y 36 con el nuevo APK,
  y las regresiones 08/13/14/33/34 durante el recorrido anterior.
- 29–32 siguen pendientes en sus aspectos no observados: teclado con TalkBack,
  texto grande/orientación, targets/contraste y recuperación. Ejecutar solo lo
  viable dentro de la autorización futura y registrar la cobertura parcial.
- 12/15/20/24 pueden comprobarse si los datos/estados aparecen naturalmente.
  No forzar contenido, expiración, errores o sustitución de snapshots.
- 16/18/21–26 y 35 no forman parte del recorrido mínimo. B1, manipulación offline,
  borrado, redes, preferencias y Driving reducido requieren su gate específico;
  no iniciar GPS ni modificar reloj/datos para completar casillas.

Cada caso conserva `PASS`, `FAIL`, `BLOCKED`, `NOT_EXECUTED` o `NOT_APPLICABLE`
justificado. Separar `OWNER_OBSERVED`, `CODEX_VERIFIED` y `AUTOMATED`. No convertir
lectura de árbol o renderer en prueba de la voz real de TalkBack.

Al terminar, confirmar Rutea estable, restauración de TalkBack y de cambios
temporales autorizados con el propietario, y ausencia de GPS/voz de prueba activos.
Conservar datos; no limpiar la aplicación. Finalizar con reporte de resultados,
defectos y pendientes. No cerrar UI-2 ni declarar preparación para producción.

```ini
UI_2_3_1_SECOND_PHYSICAL_SESSION = PREPARED
UI_2_3_1_SECOND_PHYSICAL_EXECUTION = NOT_AUTHORIZED
UI_2_3_1_PHYSICAL_INSTALLATION = NOT_AUTHORIZED
PERSONAL_DEVICE_MINIMUM_ACCESS = ENFORCED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```

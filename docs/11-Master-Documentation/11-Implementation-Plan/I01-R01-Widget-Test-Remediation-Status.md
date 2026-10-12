# I01-R01 — diagnóstico y estado de validación

Este documento conserva el punto de detención histórico de I01-R01. La remediación
y validación posterior se registra en la [evidencia vigente I01](I01-Selected-POI-Session-Integration-Evidence.md).

Baseline: `805cb17502583561f42eb4907e5a6bc6ac1a111c`.
Rama/worktree: `feature/i01-selected-poi-session`, trabajo local preservado.
Estado de integración: STOP_AND_REPORT; sin commit, push, PR ni merge.

## Fallo original de selector

La reproducción aislada con el código UTF-8 corregido pasó antes de cambiar
producción. El árbol y Semantics muestran «Categorías: 0 categorías», FilledButton
normal y deshabilitado durante B1. El baseline anterior a I01 confirmó el mismo
texto, botón habilitado antes de B1, apertura del filtro y casillas desmarcadas.

La ejecución anterior había compilado un archivo temporalmente mal decodificado
por un script local. La corrupción UTF-8 fue detectada y restaurada antes del STOP
anterior. Se reconstruyó el síntoma con un widget de prueba cuyo rótulo se obtiene
mediante decodificación incorrecta: el finder localizado no encuentra elementos
y widget() produce StateError; no hay evidencia de regresión funcional del filtro.

Se agregó ValueKey('route-category-filter') en la UI normal. La prueba conserva
la aserción del texto exacto y del bloqueo; verifica apertura y cero casillas,
selección explícita independiente, lectura de fichas, inmutabilidad y Stop.
Se eliminó la espera arbitraria de 10 ms de la prueba nueva.

## Resultados

- Prueba comparativa del baseline: 1/1 PASS.
- Pruebas específicas I01: 17/17 PASS antes de agregar el caso diagnóstico.
- Analyze: PASS, sin incidencias; format: 73 archivos.
- Suite Flutter completa con el caso diagnóstico adicional: 166 PASS / 3 FAIL.
- Driving y archivos Android/codec offline/evaluador excluidos: comparación exacta PASS.
- UTF-8 de archivos cambiados y git diff --check: PASS.

## Nuevo bloqueo confirmado

Las pruebas nativas B1 platform denial/status y R01 late start usan
fixtures.snapshot(), capturado en 1800000000000 ms, con el reloj de ejecución real.
SelectedPoiSession ahora verifica elegibilidad antes del canal nativo. El fixture
no es vigente frente a ese reloj; se obtiene ArgumentError: Invalid session selection.
Dos pruebas no alcanzan el comportamiento nativo esperado. La prueba de inicio
tardío espera un completer de llamada start que nunca ocurre y termina por timeout.
No se ha demostrado un defecto real de exclusividad GPS.

Propuesta mínima pendiente: alinear los fixtures de esas tres pruebas nativas
con un reloj controlado o snapshot vigente, conservando los escenarios y aserciones
originales. No relajar la validación de caducidad ni cambiar el servicio Android.
No se aplicó esta remediación tras el nuevo fallo obligatorio de STOP.

JVM iniciado y cancelado al detener el paquete: sin resultado PASS reclamado.
Assets, build APK y validaciones finales pendientes; ningún APK instalado.
Main permanece intacto en el baseline. La configuración local de infraestructura
continúa preservada en stash y respaldo verificable.

P12 IN_PROGRESS / 45%; P12.5 NOT_AUTHORIZED; P11-BACKUP-01 OPEN_DEFERRED;
V01 STATIONARY_PARTIAL. Sin Production Readiness.

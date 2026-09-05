# Release Gates

## R0 – Build
Todo compila.

## R1 – Automated Quality
Tests/analyzers pasan.

## R2 – Security
Sin secretos y vulnerabilidades críticas no aceptadas.

## R3 – Data
R3 — Data: POIs piloto validados es el release gate para aceptar el dataset producido
por P3. R3 permanece pendiente y solo cumple cuando todos los criterios aplicables
siguientes cumplen:

El contrato integral y prevalente de P3/R3 está en
[P3 Definition of Done](P3-Definition-of-Done.md).

- integridad de identidad, nombre, categoría, ubicación y estado;
- ubicación Point con SRID 4326;
- pertenencia y distribución en Lima → Obrajillo conforme a reglas binarias aprobadas;
- al menos una provenance auditable por POI, con fuente, licencia o condición de uso y
  atribución cuando corresponda;
- calidad factual: ningún dato factual obligatorio carece de evidencia verificable;
- ausencia de duplicados abiertos;
- taxonomía y dataset versionados, con carga reproducible e idempotente;
- aprobación humana de la versión exacta del dataset.

Antes de evaluar R3 deben aprobarse las reglas de pertenencia al corredor, distribución,
calidad suficiente y modalidad de revisión humana. R3 no impone cantidades ni scores no
aprobados y no requiere API, routing, Route Discovery o UX. La Definition of Done
técnica/backend aplicable de P3 se evalúa por separado y constituye un prerrequisito
técnico de R3. La satisfacción de R3 completa la aceptación del dataset y forma parte
del cierre total de P3.

## R4 – Integration
Vertical slice funciona.

## R5 – Device
Probado en teléfono real.

## R6 – Server
Despliegue reproducible.

## R7 – Road
Prueba controlada.

## R8 – Closed Beta
Solo después de corregir problemas críticos del road pilot.

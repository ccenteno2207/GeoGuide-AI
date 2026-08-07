# ADR-012 – PostGIS como núcleo espacial

**Estado:** Aceptado

## Decisión
Centralizar consultas de proximidad, corredor e intersección en PostgreSQL/PostGIS.

## Motivo
Evita desarrollar algoritmos GIS básicos desde cero y mantiene una plataforma
open source, portable y operable en servidor Linux propio.

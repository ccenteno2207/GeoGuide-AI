# Evolución Cloud

El piloto no depende de una nube pública.

## Etapa 1
Servidor Linux + Docker Compose.

## Etapa 2
VM cloud:
- compute;
- block storage;
- object backup;
- DNS;
- firewall/security groups.

## Etapa 3
Servicios administrados selectivos cuando exista beneficio operativo.

## Etapa 4
Orquestador/Kubernetes solo si escala, disponibilidad o múltiples servicios lo justifican.

## Portabilidad
Mantener:
- OCI containers;
- PostgreSQL/PostGIS;
- S3-compatible object abstraction;
- configuración externa;
- OpenTelemetry/Prometheus-compatible observability cuando evolucione.

Esto reduce lock-in.

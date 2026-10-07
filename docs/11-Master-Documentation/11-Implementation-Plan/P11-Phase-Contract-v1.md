# P11 Phase Contract v1 — Linux Server Deployment

**STATUS = APPROVED_SCOPE_PROPOSAL**  
**P11_IMPLEMENTATION = NOT_STARTED**  
**P11_CONTRACT_FROZEN = NO**  
**P10_FINAL_BASELINE = 932cdc5369cb1abde4f2181eee2e2b072f04f4c5**

## 1. Purpose and authority

P11 convierte el deployment Linux existente de GeoGuide AI en un estado reproducible, verificable, seguro y operable. El target es exclusivamente la VM de integración existente `manager@192.168.1.106`; no se crea otra VM ni se adopta un proveedor nuevo. Este documento requiere revisión y aprobación antes de ejecutar cambios de infraestructura.

Decisiones aplicables: D11_01–D11_16, incluyendo `POSTGRES_POSTGIS_RPO=24_HOURS`, `MINIO_RPO=24_HOURS`, `CONFIGURATION_RPO=24_HOURS`, `P11_RTO=4_HOURS`, `PUBLIC_HTTPS_EXTERNAL_VALIDATION=AUTHORIZED_NON_DESTRUCTIVE`, `OBSERVABILITY_MODEL=LOCAL_MINIMUM_OPERATIONAL`, `OBSERVABILITY_SAAS=NOT_AUTHORIZED` e `INFRA_CHANGE_POLICY=MINIMUM_CHANGE_TO_EXISTING_DEPLOYMENT`.

## 2. In scope

- Baseline y gap analysis de Ubuntu, Docker Engine, Compose, redes, volúmenes, servicios y exposición.
- Reproducibilidad y endurecimiento mínimo de Docker Compose/Nginx sin cambiar arquitectura.
- HTTPS para `geoguide.getcom.pe`, validez del certificado, redirección HTTP y estrategia de renovación existente.
- Backup 3-2-1 de PostgreSQL/PostGIS, MinIO y configuración requerida; clasificación explícita de Redis.
- Restore aislado, no destructivo y medible, incluyendo comparación con RTO de cuatro horas.
- Observabilidad local mínima: salud, logs, disco, reinicios, TLS y backups.
- Validación end-to-end, documentación, rollback y cierre.

## 3. Out of scope and stop conditions

Quedan fuera: nueva VM/provider/DNS provider, servicios pagos, cuentas externas, Kubernetes, microservicios, cambios API o esquema de DB no requeridos, migración de datos destructiva, rotación de credenciales por defecto, nuevos puertos públicos sensibles, P12, CEFI/voz, cambios de producto y cualquier modificación no explicada por este contrato.

Detener y reportar ante secreto real, Critical/High, corrupción o pérdida de datos, contradicción de baseline, nueva exposición sensible, cambio de proveedor/CA/DNS, operación irreversible, arquitectura material o decisión empresarial fuera de RPO/RTO aprobado.

## 4. Baseline descubierto

La VM reportó Ubuntu 26.04 LTS, 4 vCPU, 15 GiB RAM, 156 GiB de disco raíz con 132 GiB libres, Docker 29.7.2 y Compose v5.4.0. Servicios activos: Nginx 1.28-alpine, backend `geoguide-ai/backend:p3`, GraphHopper 11.0, Redis 7.4-alpine, MinIO RELEASE.2025-09-07T16-13-09Z y PostgreSQL/PostGIS 16-3.4. Todos usan `unless-stopped`; los cinco servicios de datos/backend/routing observados tienen healthcheck healthy. Nginx publica 80/443; los servicios de datos no publican puertos host.

DNS actual observado: A `200.121.20.120`, sin AAAA observado, delegación `ns1.desec.io`/`ns2.desec.org`. La validación pública TLS queda como evidencia de P11.2, no se presume PASS por la prueba local. El endpoint local HTTPS de Actuator respondió `200 {"status":"UP"}` y HTTP redirigió con 308.

## 5. Data and backup policy

```ini
POSTGRES_POSTGIS = AUTHORITATIVE
MINIO = PERSISTENT_DATA
GRAPHHOPPER = REPRODUCIBLE_DERIVED_DATA
REDIS_BACKUP = BASED_ON_ACTUAL_DATA_ROLE
BACKUP_MODEL = 3-2-1
POSTGRES_POSTGIS_RPO = 24_HOURS
MINIO_RPO = 24_HOURS
CONFIGURATION_RPO = 24_HOURS
P11_RTO = 4_HOURS
```

Cada backup aplicable debe registrar exit code, checksum/integrity, espacio disponible y copia fuera del host fuente. PostgreSQL/PostGIS, objetos MinIO y configuración requerida deben cubrirse. Redis se excluye solo si la inspección demuestra que contiene únicamente cache/estado reconstruible; de lo contrario se incorpora al RPO. GraphHopper se respalda solo cuando la evidencia demuestre que el insumo derivado no es reproducible.

Restore se ejecuta únicamente sobre target aislado, preservando los volúmenes operativos. Debe validar esquema/Flyway, POIs, consultas PostGIS, objetos MinIO, reconstrucción de configuración y recuperación de aplicación cuando aplique, midiendo tiempo real contra cuatro horas.

## 6. Observability policy

`LOCAL_MINIMUM_OPERATIONAL` usando Docker status/health, Actuator, Nginx availability, salud PostgreSQL/Redis/MinIO/GraphHopper, uso de disco, reinicios, logs de contenedor, expiración TLS y éxito/fallo de backup. No se agrega SaaS ni stack externo. Los umbrales operativos se documentarán como controles técnicos, no como SLA empresarial.

## 7. Checkpoints

- **P11.1 — DEPLOYMENT_BASELINE_AND_GAP_ANALYSIS:** baseline reproducible, exposición clasificada y rollback documentado.
- **P11.2 — HTTPS_TLS_AND_REVERSE_PROXY:** DNS, TCP/443, handshake, cadena, SAN, fechas, hostname, HTTPS y redirect HTTP PASS.
- **P11.3 — DEPLOYMENT_REPRODUCIBILITY_AND_SERVICE_HARDENING:** Compose reproducible, redes/volúmenes preservados, restart/health checks y mínimo cambio PASS.
- **P11.4 — BACKUP_AND_RESTORE_VALIDATION:** backups 3-2-1 verificables y restore aislado medido con RPO/RTO.
- **P11.5 — OPERATIONAL_OBSERVABILITY:** señales mínimas y procedimientos documentados.
- **P11.6 — END_TO_END_DEPLOYMENT_VALIDATION:** smoke, regresión, exposición, persistencia, recuperación y documentación PASS.
- **P11.7 — CLOSURE:** evidencias, baselines, findings y rollback cerrados.

## 8. Acceptance criteria

| ID | Criterio objetivo |
|---|---|
| P11-AC-01 | `docker compose config`, imágenes/versiones y procedimiento reproducen el deployment sin secretos en Git. |
| P11-AC-02 | Nginx, backend, PostgreSQL, Redis, MinIO y GraphHopper están healthy/operables según sus controles. |
| P11-AC-03 | Actuator responde UP y smoke tests de API pasan sin exponer puertos internos. |
| P11-AC-04 | `geoguide.getcom.pe` resuelve al endpoint autorizado, TCP/443 y handshake TLS funcionan, cadena/SAN/hostname/fechas son válidos y HTTPS responde. |
| P11-AC-05 | HTTP redirige a HTTPS y la renovación documentada es verificable sin cambiar CA/provider ni credenciales. |
| P11-AC-06 | La exposición queda clasificada: solo 80/443 públicos; datos/routing internos; SSH administrativo. |
| P11-AC-07 | PostgreSQL/PostGIS, MinIO, Redis y GraphHopper están clasificados y sus volúmenes/configuración preservan el estado requerido. |
| P11-AC-08 | Backups aplicables cumplen exit code, checksum, espacio, copia off-host y RPO máximo de 24 h. |
| P11-AC-09 | Restore aislado no destructivo valida datos/servicios y mide recuperación ≤ 4 h. |
| P11-AC-10 | Salud, logs, disco, reinicios, TLS y backup success/failure son visibles localmente y tienen runbook. |
| P11-AC-11 | No hay secretos en Git/logs/evidencias; credenciales no se rotan automáticamente. |
| P11-AC-12 | Reinicio controlado y rollback recuperan servicios sin pérdida de datos operativos. |
| P11-AC-13 | Evidencia documental, regresión y baselines permiten reconstruir el estado y no alteran P12. |

## 9. Evidence and governance

Cada checkpoint debe conservar comandos, resultados, timestamps, hashes, límites y archivos afectados. No se declara PASS sin evidencia ejecutada. Los cambios de VM requieren captura previa, backup/rollback y validación posterior. El workbook externo oficial solo se actualizará al cierre significativo de P11.

```ini
P11_SCOPE = LINUX_SERVER_DEPLOYMENT
P11_DEPLOYMENT_TARGET = EXISTING_GEOGUIDE_INTEGRATION_VM
P11_IMPLEMENTATION = NOT_STARTED
P12 = NOT_STARTED
```


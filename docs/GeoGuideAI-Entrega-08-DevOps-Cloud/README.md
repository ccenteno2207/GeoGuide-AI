# GeoGuide AI – Entrega 08 – DevOps & Cloud

Baseline DevOps, infraestructura y evolución Cloud para el MVP.

## Estrategia
El piloto se ejecutará inicialmente sobre el servidor Linux disponible, usando software
open source y contenedores. La arquitectura evitará dependencias innecesarias de un
cloud específico y quedará preparada para migrar posteriormente a AWS, Azure, GCP u
otra infraestructura compatible.

## Plataforma MVP
- Linux
- Docker Engine
- Docker Compose
- Nginx
- Java 21 / Spring Boot
- PostgreSQL + PostGIS
- Redis
- MinIO
- motor de routing open source
- GitHub + GitHub Actions
- Prometheus/Grafana como evolución de observabilidad
- backups automatizados

## Principios
- Infrastructure as Code cuando aporte valor.
- Immutable builds.
- Configuration externalizada.
- Secrets fuera de Git.
- Least privilege.
- Reproducibilidad.
- Observabilidad.
- Backups verificados.
- Automatización incremental.
- Cloud agnostic en el núcleo.

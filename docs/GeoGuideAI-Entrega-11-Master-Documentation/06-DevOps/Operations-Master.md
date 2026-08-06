# Operations Master

## Piloto
Un servidor Linux.

## Exposición
Internet → 443/Nginx → Backend.
DB/cache/storage/routing permanecen internos.

## Pipeline
PR → build → tests → scans → image → deploy → smoke.

## Backups
PostgreSQL + MinIO.
Restore probado.

## Observabilidad
Primero logs/health; luego Prometheus/Grafana/Loki.

## Cloud
La migración a cloud es una evolución, no un prerrequisito.

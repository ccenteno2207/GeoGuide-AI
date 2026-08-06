# Security Master

## API
- HTTPS;
- JWT cuando se requiera identidad;
- RBAC;
- validación;
- Problem Details;
- rate limiting básico.

## Mobile
- secure storage;
- no secretos;
- permisos mínimos;
- no historial GPS permanente por defecto.

## Infra
- servicios internos no públicos;
- SSH con claves;
- firewall;
- least privilege.

## Supply Chain
- dependency scan;
- container scan;
- secret scan;
- SAST.

## Data/AI
- provenance;
- source validation;
- prompt injection controls cuando exista RAG.

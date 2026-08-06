# Estrategia DevOps

## Flujo
Code → Pull Request → CI → Tests → Security Scan → Container Build → Registry →
Deployment → Smoke Test → Observability.

## MVP
No introducir Kubernetes inicialmente. Docker Compose es suficiente para validar el
producto en un único servidor.

## Repositorio
La infraestructura debe vivir versionada junto al proyecto o en un directorio
`infrastructure/`.

## Reglas
- main protegida.
- PR antes de cambios relevantes.
- imágenes versionadas.
- nunca usar `latest` como único mecanismo de trazabilidad.
- despliegues reproducibles.
- rollback documentado.

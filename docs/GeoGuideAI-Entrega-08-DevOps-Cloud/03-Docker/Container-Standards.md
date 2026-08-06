# Estándares de Contenedores

- imágenes mínimas y mantenidas;
- multi-stage build;
- proceso no-root cuando sea posible;
- HEALTHCHECK donde aporte valor;
- versiones fijadas;
- `.dockerignore`;
- sin secretos en layers;
- logs a stdout/stderr;
- filesystem read-only cuando sea viable;
- límites de recursos en operación.

## Backend
Build Maven → runtime Java 21.

## Seguridad
Escanear imágenes con Trivy.

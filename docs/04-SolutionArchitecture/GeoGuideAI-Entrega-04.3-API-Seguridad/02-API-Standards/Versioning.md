# Versionado de API

Estrategia: `/api/v1`.

- Cambios compatibles: misma versión.
- Cambios incompatibles: nueva versión mayor.
- Deprecaciones documentadas.
- Mantener coexistencia temporal cuando sea posible.

Evitar cambios incompatibles como renombrar campos publicados, cambiar tipos o
alterar la semántica de códigos HTTP.

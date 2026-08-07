# Estrategia de Pruebas

## Pirámide

### Unitarias
Dominio y Application.
Rápidas y sin Spring cuando sea posible.

### Slice tests
- @WebMvcTest
- @DataJpaTest cuando tenga sentido.

### Integración
Testcontainers:
- PostgreSQL/PostGIS.

### API
Verificar contratos OpenAPI y status codes.

### End-to-End
Solo flujos críticos del MVP.

## Cobertura
No establecer un porcentaje como objetivo aislado.
Priorizar reglas de negocio, seguridad y Route Discovery.

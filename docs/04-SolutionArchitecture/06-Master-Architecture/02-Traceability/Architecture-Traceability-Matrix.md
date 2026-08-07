# Matriz de Trazabilidad

| Necesidad | Componente | Decisión |
|---|---|---|
| Mostrar mapa | Flutter + OSM | Open Source First |
| Calcular ruta | RoutingProvider | motor desacoplado |
| Descubrir lugares | Route Discovery Engine | dominio independiente |
| Consultas geográficas | PostGIS | núcleo espacial |
| Persistir POIs | PostgreSQL | datos relacionales + GIS |
| Proteger API | Nginx + Spring Security | defensa en profundidad |
| Autenticación | JWT/RBAC | backend stateless |
| Multimedia | MinIO | objeto autohospedado |
| Rendimiento | Redis + GiST | caché + índices |
| Operación Linux | Docker Compose | simplicidad para piloto |

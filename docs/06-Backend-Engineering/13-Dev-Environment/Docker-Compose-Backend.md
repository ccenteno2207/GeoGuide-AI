# Entorno de Desarrollo

Servicios recomendados en Docker Compose:
- PostgreSQL/PostGIS
- Redis
- MinIO
- Routing Engine

El backend puede ejecutarse desde IDE o contenedor.

## Variables
- SPRING_DATASOURCE_URL
- SPRING_DATASOURCE_USERNAME
- SPRING_DATASOURCE_PASSWORD
- REDIS_HOST
- MINIO_ENDPOINT
- MINIO_ACCESS_KEY
- MINIO_SECRET_KEY
- ROUTING_BASE_URL
- JWT_SECRET o claves asimétricas según implementación

Nunca versionar valores reales de secretos.

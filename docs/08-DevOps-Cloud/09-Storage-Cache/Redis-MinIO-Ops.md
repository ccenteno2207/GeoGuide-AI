# Redis y MinIO

## Redis
- uso como caché, no fuente única de datos críticos;
- TTL;
- memoria limitada;
- política de eviction definida.

## MinIO
- volumen persistente;
- buckets privados;
- backup de objetos importantes;
- credenciales fuera de Git.

El backend controla el acceso a objetos.

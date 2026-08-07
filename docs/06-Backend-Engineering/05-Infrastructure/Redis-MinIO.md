# Redis y MinIO

## Redis
No es obligatorio utilizar caché desde el primer commit.

Casos válidos:
- rutas repetidas;
- discovery repetido;
- datos externos de baja frecuencia de cambio.

Siempre definir TTL.

## MinIO
Uso:
- fotografías;
- multimedia;
- objetos de contenido.

La base de datos almacena metadatos y object key, no archivos binarios grandes.

## Seguridad
Buckets privados por defecto.
Acceso mediante backend o URLs temporales cuando se implemente.

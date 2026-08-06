# JWT y RBAC

Roles iniciales:
- ANONYMOUS
- USER
- CONTENT_EDITOR
- ADMIN

| Recurso | ANON | USER | EDITOR | ADMIN |
|---|---:|---:|---:|---:|
| Consultar POIs | Sí | Sí | Sí | Sí |
| Calcular rutas | Sí | Sí | Sí | Sí |
| Favoritos | No | Sí | Sí | Sí |
| Crear reseña | No | Sí | Sí | Sí |
| Crear/editar POI | No | No | Sí | Sí |
| Usuarios/roles | No | No | No | Sí |

Claims mínimos:
- sub
- roles
- iat
- exp
- jti

No incluir datos sensibles dentro del token.

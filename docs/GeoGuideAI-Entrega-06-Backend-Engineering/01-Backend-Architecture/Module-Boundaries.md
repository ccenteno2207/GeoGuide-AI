# Límites de Módulos

## Módulos MVP

### identity
Autenticación, refresh token y seguridad de identidad.

### users
Perfil y preferencias.

### places
POIs, categorías, información descriptiva, horarios, precios y metadatos.

### routes
Planificación de rutas y abstracción del proveedor de routing.

### discovery
Route Discovery Engine.

### favorites
Favoritos del usuario.

### reviews
Reseñas futuras o básicas.

### media
Metadatos de objetos almacenados en MinIO.

### admin
Casos de uso administrativos.

### shared
Elementos transversales mínimos:
- errores;
- identificadores;
- clock;
- pagination;
- correlation IDs.

## Restricción
`shared` no debe convertirse en un cajón de utilidades sin dueño.

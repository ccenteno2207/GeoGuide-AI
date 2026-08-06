# Catálogo Inicial de APIs

| Dominio | Método | Endpoint | Descripción | Auth |
|---|---|---|---|---|
| Auth | POST | /api/v1/auth/login | Autenticación | No |
| Auth | POST | /api/v1/auth/refresh | Renovación de token | Sí |
| User | GET | /api/v1/users/me | Perfil actual | Sí |
| Places | GET | /api/v1/places/{id} | Detalle de POI | Opcional |
| Places | GET | /api/v1/places/nearby | POIs por proximidad | Opcional |
| Places | GET | /api/v1/places/search | Búsqueda de POIs | Opcional |
| Routes | POST | /api/v1/routes/plan | Calcula ruta | Opcional |
| Discovery | POST | /api/v1/routes/discover | POIs dentro del corredor | Opcional |
| Favorites | GET | /api/v1/favorites | Favoritos | Sí |
| Favorites | POST | /api/v1/favorites | Agregar favorito | Sí |
| Favorites | DELETE | /api/v1/favorites/{placeId} | Eliminar favorito | Sí |
| Reviews | POST | /api/v1/places/{id}/reviews | Crear reseña | Sí |
| Admin | POST | /api/v1/admin/places | Crear POI | ADMIN |
| Admin | PUT | /api/v1/admin/places/{id} | Actualizar POI | ADMIN |
| Admin | DELETE | /api/v1/admin/places/{id} | Deshabilitar POI | ADMIN |
| Health | GET | /actuator/health | Estado técnico | Restringido |

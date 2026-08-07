# Modelo Local Conceptual

Tablas:
- cached_routes
- cached_route_pois
- cached_places
- favorites
- settings
- sync_metadata

Campos comunes:
- id
- payload/versioned columns
- cached_at
- expires_at opcional
- sync_state

No almacenar credenciales en SQLite.

# Matriz de Trazabilidad

| Necesidad | Producto | Arquitectura | Implementación |
|---|---|---|---|
| Ver ubicación | MVP/UX | Mobile/Location | Flutter GPS |
| Mostrar mapa | MVP/UX | OSM/Map client | Map feature |
| Origen/destino | MVP | Routing | route_planning |
| Calcular ruta | MVP | RoutingProvider | backend routes |
| Descubrir POIs | Core | Route Discovery | discovery module |
| Corredor | Core | PostGIS | spatial query |
| Ficha POI | UX/Data | Places | places module |
| Historia | Data | Content/RAG future | factual content |
| Horarios/precios | Data | Provenance | verified fields |
| Offline | UX | local cache | Drift/SQLite |
| Conducción | UX | mobile driving | driving feature |
| AI | Future | provider abstraction | optional service |

# Matriz de Trazabilidad

| Necesidad | Producto | Arquitectura | Implementación |
|---|---|---|---|
| Ver ubicación | MVP/UX | Mobile/Location | Flutter GPS |
| Descubrir cerca | MVP/Core | Places/PostGIS | nearby use case |
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
| Voz manos libres | Estratégico/incremental | ADR-027, servicios compartidos | STT/TTS adapters |
| Consistencia de canales | Arquitectura | application use cases | UI/voice consumers |
| IA contextual | Enriquecimiento opcional | provider abstraction | optional service |

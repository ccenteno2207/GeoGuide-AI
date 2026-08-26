# GeoGuide AI – Documento Maestro de Arquitectura
## Entrega 04.6

**Estado:** Baseline de arquitectura del MVP  
**Propósito:** consolidar las decisiones de las Entregas 04.1 a 04.5 y convertirlas en
la fuente de verdad técnica para desarrollo, pruebas y despliegue.

---

## 1. Visión

GeoGuide AI es una plataforma móvil de descubrimiento geográfico construida con una
estrategia tecnológica Open Source First. Esta estrategia no determina la licencia del
producto, cuyo estado legal vigente se rige por `LICENSE`. Permite descubrir puntos de
interés alrededor de la ubicación actual y a lo largo de una ruta: patrimonio cultural
e histórico, sitios arqueológicos, naturaleza, gastronomía, miradores, museos y otros
lugares relevantes.

No pretende replicar las capacidades de tráfico de Waze o Google Maps en el MVP.
El diferencial es el descubrimiento contextual del territorio durante un viaje.
No es un chatbot genérico. La IA contextual enriquece una base factual y los canales
visual y de voz reutilizan los mismos servicios de aplicación.

---

## 2. Principios de arquitectura

1. Open Source First.
2. API First.
3. Mobile First.
4. Security by Design.
5. Privacy by Default.
6. Clean Architecture y separación de responsabilidades.
7. Dependencias externas desacopladas mediante puertos/adaptadores.
8. PostGIS como núcleo geoespacial.
9. Contenedores reproducibles.
10. Observabilidad desde el inicio.
11. Evolución incremental antes que microservicios prematuros.
12. Documentación y ADR como parte del producto.
13. Servicios de aplicación independientes del canal.
14. Facts First, AI Second; el núcleo funciona sin LLM.

---

## 3. Arquitectura objetivo del MVP

### Cliente
- Flutter / Dart.
- Mapa basado en OpenStreetMap mediante librerías open source.
- GPS del dispositivo.
- Consumo de APIs REST.
- Caché local futura para modo offline.
- Adaptadores sustituibles de STT/TTS cuando se habilite voz.

### Edge
- Nginx.
- HTTPS/TLS.
- Reverse proxy.
- Rate limiting básico.
- Security headers.

### Backend
- Java 21.
- Spring Boot 3.
- Spring Security.
- Spring Data.
- OpenAPI 3.1.
- Arquitectura modular preparada para extraer servicios cuando exista una razón real.

### Datos
- PostgreSQL.
- PostGIS.
- Redis para caché cuando sea necesario.
- MinIO para objetos multimedia.

### Routing
- Interfaz `RoutingProvider`.
- Motor open source autohospedado.
- Implementación inicial del piloto: GraphHopper 11.0, seleccionada por ADR-028 y
  sustituible por Valhalla u OSRM mediante `RoutingProvider`.

### Mapas/datos abiertos
- OpenStreetMap.
- Integraciones de enriquecimiento deben respetar licencias y atribución.

---

## 4. C4 resumido

### Nivel 1
El viajero interactúa con GeoGuide AI. GeoGuide AI consume datos cartográficos y un
motor de rutas.

La interacción puede ser visual o por voz. En ambos casos se invocan los mismos casos
de uso; STT/TTS son adaptadores y no contienen reglas de dominio.

### Nivel 2
Contenedores principales:
- Flutter App.
- Nginx.
- Spring Boot API.
- PostgreSQL/PostGIS.
- Redis.
- MinIO.
- Routing Engine.

### Nivel 3
Módulos backend:
- Identity.
- Users.
- Places.
- Routes.
- Route Discovery.
- Favorites.
- Reviews.
- Administration.
- Observability.
- Interaction/Context application services, sin acoplarlos a UI, STT, TTS o LLM.

---

## 5. Arquitectura de datos

Entidades esenciales:
- User
- Route
- RouteSegment
- Waypoint
- PointOfInterest
- Category
- Media
- Review
- Favorite
- Event

Tipos espaciales:
- Point para POI.
- LineString para rutas.
- Polygon/MultiPolygon para áreas cuando sea necesario.

Índice espacial:
- GiST.

SRID canónico:
- EPSG:4326 para almacenamiento/intercambio.
- Transformaciones o geography para cálculos métricos.

---

## 6. APIs

Base:
`/api/v1`

Dominios:
- `/auth`
- `/users`
- `/places`
- `/routes`
- `/favorites`
- `/admin`

Endpoints clave:
- `GET /places/{id}`
- `GET /places/nearby`
- `POST /routes/plan`
- `POST /routes/discover`

Convenciones:
- JSON.
- UUID.
- ISO-8601.
- Problem Details para errores.
- Correlation ID.
- versionado por URL.

---

## 7. Seguridad

- HTTPS obligatorio.
- Spring Security.
- JWT de corta duración.
- Refresh token rotado.
- RBAC.
- Roles: ANONYMOUS, USER, CONTENT_EDITOR, ADMIN.
- Secretos fuera del repositorio.
- Validación de entradas.
- Rate limiting.
- Logging seguro.
- Auditoría administrativa.
- controles OWASP API Security.

Privacidad:
La ubicación continua del viajero no se almacenará por defecto.

---

## 8. Route Discovery Engine

El Route Discovery Engine es el corazón funcional.

Flujo:
1. calcular ruta;
2. normalizar LineString;
3. construir corredor;
4. ejecutar consulta espacial;
5. obtener candidatos;
6. rankear con señales disponibles en el MVP;
7. ordenar según progreso;
8. devolver resultados.

En una evolución posterior, el flujo incorpora la estimación de distancia de desvío y
tiempo adicional como señales opcionales. Esta evolución no bloquea la entrega inicial
del corredor, búsqueda espacial, ranking básico y orden por progreso.

El algoritmo de ranking debe permanecer explicable y versionado.

La misma capacidad geoespacial soporta descubrimiento por proximidad a una ubicación
autorizada, sin requerir que exista una ruta activa.

## 8.1 Interacción contextual y voz

Flujo estratégico: STT → interpretación de intención y contexto → casos de uso
GeoGuide → TTS. El contexto autorizado puede incluir ubicación, ruta activa, POIs
cercanos, preferencias y estado del viaje. Driving/Travel Mode limita la longitud de
las respuestas y la interacción visual. Un LLM es opcional y se accede únicamente por
`LanguageModelProvider`; consultar rutas, proximidad, ranking y fichas factuales no
depende de él. Véase ADR-027.

---

## 9. Despliegue MVP

Servidor Linux propio con Docker Compose.

Contenedores:
- nginx
- backend
- postgres-postgis
- redis
- minio
- routing-engine

No se requiere Kubernetes para el piloto.

---

## 10. Observabilidad

Mínimos:
- health checks;
- logs estructurados;
- correlationId;
- métricas de API;
- métricas del Route Discovery Engine;
- auditoría.

Métricas del dominio:
- duración de cálculo de ruta;
- duración de consulta espacial;
- candidatos encontrados;
- resultados entregados;
- errores del proveedor de routing;
- uso de caché.

---

## 11. ADR consolidados

- ADR-001: Open Source First.
- ADR-002: OpenStreetMap como base.
- ADR-003: Flutter.
- ADR-004: PostgreSQL/PostGIS.
- ADR-005: motor de rutas desacoplado.
- ADR-006: Docker.
- ADR-007: REST para MVP.
- ADR-008: JWT + RBAC.
- ADR-009: Nginx como reverse proxy.
- ADR-010: Route Discovery como dominio independiente.
- ADR-011: RoutingProvider.
- ADR-012: PostGIS como núcleo espacial.
- ADR-013: Modular Monolith para el MVP.
- ADR-014: Flyway para migraciones.
- ADR-015: Testcontainers para integración.
- ADR-016: Flutter para Mobile.
- ADR-017: Riverpod recomendado, sujeto a validación en bootstrap.
- ADR-018: almacenamiento local aceptado para baseline.
- ADR-019: librería de mapas pendiente de validación técnica final.
- ADR-020: Docker Compose para el MVP.
- ADR-021: núcleo cloud agnostic.
- ADR-022: GitHub Actions para CI/CD.
- ADR-023: Facts First, AI Second.
- ADR-024: pgvector para futura búsqueda semántica.
- ADR-025: abstracción `LanguageModelProvider`.
- ADR-026: el LLM no es requisito del núcleo MVP.
- ADR-027: interacción independiente del canal y voz contextual.
- ADR-028: GraphHopper 11.0 como motor inicial de routing.

El estado formal y la ruta vigente de cada decisión se consultan en
`docs/02-Architecture/ADR-REGISTRY.md`; esta lista no sustituye al registro.

---

## 12. Criterio de arquitectura para comenzar desarrollo

Se autoriza iniciar implementación cuando:
- repositorio tiene estructura estable;
- stack está disponible localmente;
- base PostGIS levanta;
- contrato OpenAPI está versionado;
- modelo mínimo POI existe;
- RoutingProvider tiene contrato;
- pipeline de build ejecuta pruebas;
- secretos no están en Git;
- README de desarrollo explica cómo levantar el entorno.

---

## 13. Roadmap técnico

### Incremento A
Infraestructura local + backend esqueleto + PostGIS.

### Incremento B
CRUD de POIs y categorías.

### Incremento C
Mapa y GPS en Flutter.

### Incremento D
Origen/destino + routing.

### Incremento E
Route Discovery.

### Incremento F
Ficha de POI, favoritos y contenido enriquecido.

### Incremento G
Piloto sobre una ruta real y conjunto controlado de POIs.

---

## 14. Fuera de alcance del primer piloto

- tráfico en tiempo real;
- optimización predictiva por congestión;
- navegación turn-by-turn avanzada;
- crowdsourcing masivo;
- IA generativa como fuente única de información factual;
- arquitectura de microservicios distribuida;
- Kubernetes.
- IA avanzada, personalización compleja e itinerarios generados;
- CarPlay y Android Auto;
- usar voz o IA como sustituto de los servicios geoespaciales y datos confiables.

---

## 15. Regla para Codex

Codex debe tratar este documento y las Entregas 01–04 como arquitectura de referencia.
Si una implementación requiere desviarse de una decisión aceptada, debe:
1. detectar el conflicto;
2. explicar el motivo;
3. proponer un ADR;
4. esperar aprobación antes de cambiar la arquitectura.

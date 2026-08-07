# Technology Portability

PostgreSQL/PostGIS is the approved MVP database. The MVP uses approved technologies fully while keeping replaceable infrastructure behind explicit boundaries. Portability does not mean a lowest-common-denominator architecture: GeoGuide AI should use PostGIS capabilities where they add value. A future replacement requires technical justification, migration impact and cost analysis, licensing analysis, data migration and rollback strategies, and an approved ADR.

| Current technology | Capability | Abstraction boundary | Vendor-specific dependencies | Complexity | Migration considerations |
| --- | --- | --- | --- | --- | --- |
| PostgreSQL/PostGIS | Canonical relational/geospatial data, GiST, spatial queries, geometry/geography, SRID transforms | Repositories and persistence adapters | PostGIS SQL, types, indexes, functions, migrations | HIGH | Inventory spatial SQL, validate precision and query equivalence, migrate indexes/data, benchmark Route Discovery, and prepare rollback. |
| Redis | Cache and ephemeral coordination | Cache ports/adapters | Keys, TTL, Redis commands | MEDIUM | Preserve invalidation and TTL semantics; cache is not source of truth. |
| MinIO | Media object storage | `ObjectStorageProvider` | S3-compatible API, buckets, metadata | MEDIUM | Verify keys, metadata, lifecycle, policy, and bulk copy. |
| Routing Engine | Route computation and geometry | `RoutingProvider` | GraphHopper, Valhalla, OSRM semantics and profiles | MEDIUM | Compare geometry, duration, distance, errors, and corridor results. |
| OpenStreetMap/map provider | Basemap and geographic data | Map adapter and ingestion boundaries | OSM model, tiles, attribution, licensing | MEDIUM | Preserve attribution and validate coverage, styling, and lineage. |
| AI provider | Optional enrichment and generation | `LanguageModelProvider` | Model API, prompts, embeddings, safety behavior | MEDIUM | Core works without AI; evaluate factuality, privacy, cost, and rollback. |
| Linux/Docker | Host execution and packaging | Container/deployment configuration | Images, volumes, Linux operations | MEDIUM | Validate networks, secrets, backups, observability, and runbooks. |
| Nginx | TLS termination and reverse proxy | Edge configuration | Directives, headers, rate limits, TLS | LOW | Reproduce routes, TLS, logging, health checks, and rollback. |

PostGIS is intentionally used for route geometry, spatial indexing, corridor queries, proximity searches, transformations, and geographic calculations. Record each PostGIS-specific type or function in the relevant migration, adapter, or technical design for future evaluation.

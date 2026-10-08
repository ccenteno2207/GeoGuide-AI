# Route Input and Destination Search — Discovery Proposal

## Status and boundaries

```ini
DISCOVERY_ONLY = YES
IMPLEMENTATION = NOT_AUTHORIZED
P12_CONTRACT = UNCHANGED
P12_FIELD_EXECUTION = NOT_AUTHORIZED
```

This is an independent proposal. It does not add search or geocoding to P12, GPS Follow Mode, or the frozen Driving contract.

## Product scope decision

```ini
SEARCH_SCOPE = PLACES_AND_POIS_ONLY
POSTAL_ADDRESS_SEARCH = OUT_OF_SCOPE
ORIGIN = CURRENT_GPS_OR_SEARCHED_PLACE_OR_POI
DESTINATION = SEARCHED_PLACE_OR_POI
MAP_SELECTION_FALLBACK = REQUIRED
WAYPOINTS = OUT_OF_SCOPE
DRIVING_CHANGES = NONE
CONTRACT_STATUS = PROPOSED_NOT_APPROVED
```

Valid examples include Canta, Plaza de Armas de Canta, Ica, Huacachina, Nazca and Paracas. Street names with house numbers, such as Avenida Perú 2469, are rejected as out of scope.

## A. Current architecture

The Flutter map currently accepts two map taps through `RoutePlanningController.selectPoint`. The first tap becomes origin, the second destination; a third selection starts a new pair. `PlanRoute` sends the pair to the existing route-planning port. `OfflineDiscovery` then composes the same query with Route Discovery and stores the existing one-snapshot cache. There is no text input, autocomplete, geocoding, reverse geocoding or waypoint model. The backend route API accepts only origin and destination.

## B. UX proposal

Add a route-input surface outside Driving with two editable fields:

1. **Origen**: actions `Usar mi ubicación`, `Buscar lugar o POI` and `Elegir en el mapa`.
2. **Destino**: actions `Buscar lugar o POI` and `Elegir en el mapa`.

Each result must represent a locality, geographic place, tourism attraction or POI, and show name, locality/region context and provider attribution. Curated GeoGuide AI catalog results take priority when a matching stable POI exists. The user confirms one result before it becomes a coordinate. Ambiguous or empty results remain unresolved and cannot be sent to routing. A map preview shows both confirmed points before `Planificar ruta`. Driving receives only the resulting route snapshot and exposes no search controls.

## C. Geocoding alternatives

| Alternative | Fit | Cost/privacy/licence | Disposition |
|---|---|---|---|
| Curated GeoGuide catalog first | Stable known POIs and tourism places already used by Route Discovery | Best provenance and privacy; coverage is finite and requires governance | Required first source |
| Self-hosted Nominatim | OSM localities, named places and POIs; postal-address mode is excluded | Open data/software; operational compute is ours; public instance has strict usage policy | Candidate for locality/place fallback |
| Self-hosted Photon | OSM place/POI search with Apache-2.0 software and Elasticsearch | No per-request vendor fee; requires JVM/Elasticsearch/data operations | Candidate for bounded place search |
| Self-hosted Pelias | Modular OSM/open-data place search with provider composition | No per-request vendor fee; highest operational/data complexity | Candidate only if place coverage justifies it |
| Hosted commercial geocoder | Usually strong coverage and SLA | Provider account, quotas, terms, possible recurring cost and location-data transfer | Not authorized; requires human product/security/cost decision |

The public Nominatim endpoint must not be treated as an unbounded production dependency: its policy requires attribution, a valid identifying User-Agent, caching and rate discipline. Photon and Pelias are technically self-hostable, but their operational resources and data refresh strategy must be approved first.

## D. Reusable components

- Existing `RoutePoint`, `PlanRoute`, route response mapper and error normalization.
- Existing Route Discovery query, category filters, POI presentation and snapshot identity.
- Existing map controller and manual tap selection as the fallback.
- New provider-neutral application port `SearchLocations` returning candidates with source attribution and confidence/context; no provider type should leak into widgets.

## E. Proposed functional contract

The capability accepts a place/POI query and optional map bias, returns zero or more attributed candidates, requires explicit candidate confirmation, and converts only a confirmed candidate to `RoutePoint`. Current GPS is allowed only as the origin. It must support manual map selection without search. It must reject postal-address patterns and must not persist search history, upload personal history, or infer a route from an unconfirmed ambiguous result. A future waypoint list is a separate extension and is not included here.

## F. Errors and ambiguity

Represent empty, timeout, rate-limited, unauthorized, provider-unavailable and malformed responses separately. Display a recoverable message, preserve already confirmed fields, and never silently substitute a nearby place. Duplicate candidates should be grouped only when provider identity and coordinates are equivalent within a documented tolerance.

## G. Dependencies and risks

- Provider choice and operational ownership.
- API boundary and TLS/security policy.
- Attribution and OSM licence compliance.
- Privacy review for query text and precise location bias.
- CEFI integration is future work; conversational intent must not bypass explicit confirmation.
- Waypoints, multi-stop routing and route alternatives require a separate contract.

## H. Acceptance criteria proposal

1. Existing two-tap route planning remains available.
2. Origin and destination fields validate independently and preserve confirmed state.
3. Search results are attributed, selectable and never auto-applied when ambiguous.
4. Confirmed points reuse the existing route and Route Discovery ports.
5. Search failure categories are distinguishable and recoverable.
6. No query history, continuous location upload or background permission is introduced.
7. Driving exposes no search or secondary controls.
8. Provider policy, licence, rate limits, retention and cost are documented before implementation.
9. P12 contracts and evidence remain byte-equivalent.

## I. Decisions required

- Select self-hosted Nominatim, Photon, Pelias or a separately approved hosted provider.
- Approve operational resources and data refresh/licence policy.
- Confirm that place/POI search is sufficient and postal-address search remains excluded.
- Decide whether route waypoints are a later capability.
- Approve retention and privacy treatment for submitted query text.

Until these decisions are resolved, this proposal remains `PROPOSED_ONLY` and no implementation is authorized.

# Modelo de Dominio

## Route
- id
- origin
- destination
- geometry
- distanceMeters
- durationSeconds
- provider

## RouteDiscoveryRequest
- route
- corridorMeters
- categories
- limit
- userPreferences

Evolución posterior, opcional:
- maxDetourMeters

## PointOfInterest
- id
- name
- category
- location
- description
- openingHours
- priceInfo
- source
- qualityScore

## RoutePoiCandidate
- poi
- distanceToRouteMeters
- routeProgress
- score
- reasonCodes

Evolución posterior, opcional:
- estimatedDetourMeters
- estimatedAdditionalTimeSeconds

La ausencia de estos campos de evolución no invalida un candidato ni bloquea Route
Discovery en el núcleo MVP.

## DiscoveryResult
- route
- candidates
- generatedAt
- algorithmVersion

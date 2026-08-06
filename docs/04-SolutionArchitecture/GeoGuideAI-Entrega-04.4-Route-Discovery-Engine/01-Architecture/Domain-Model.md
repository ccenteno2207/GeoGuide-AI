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
- maxDetourMeters
- limit
- userPreferences

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
- estimatedDetourMeters
- score
- reasonCodes

## DiscoveryResult
- route
- candidates
- generatedAt
- algorithmVersion

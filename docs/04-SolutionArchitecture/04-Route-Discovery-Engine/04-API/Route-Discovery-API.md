# API del Route Discovery Engine

## POST /api/v1/routes/discover

### Request
```json
{
  "origin": {"lat": -12.0464, "lon": -77.0428},
  "destination": {"lat": -13.5319, "lon": -71.9675},
  "corridorMeters": 5000,
  "maxDetourMeters": 15000,
  "categories": ["WATERFALL", "LAGOON", "ARCHAEOLOGICAL_SITE", "VIEWPOINT"]
}
```

### Response
```json
{
  "route": {
    "distanceMeters": 0,
    "durationSeconds": 0,
    "geometry": {}
  },
  "pointsOfInterest": [
    {
      "id": "uuid",
      "name": "POI",
      "category": "VIEWPOINT",
      "distanceToRouteMeters": 850,
      "routeProgress": 0.42,
      "estimatedDetourMeters": 2200,
      "score": 81.5,
      "reasonCodes": ["NEAR_ROUTE", "USER_CATEGORY"]
    }
  ]
}
```

Los valores numéricos del ejemplo son ilustrativos.

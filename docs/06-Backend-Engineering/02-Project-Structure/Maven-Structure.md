# Estructura Maven Recomendada

```text
backend/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/com/geoguideai/
│   │   │   ├── GeoGuideApplication.java
│   │   │   ├── shared/
│   │   │   ├── identity/
│   │   │   ├── users/
│   │   │   ├── places/
│   │   │   ├── routes/
│   │   │   ├── discovery/
│   │   │   ├── favorites/
│   │   │   ├── reviews/
│   │   │   ├── media/
│   │   │   └── admin/
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-local.yml
│   │       └── db/migration/
│   └── test/
│       └── java/com/geoguideai/
└── Dockerfile
```

## Estructura interna por módulo

```text
places/
├── domain/
│   ├── model/
│   ├── service/
│   └── port/
├── application/
│   ├── usecase/
│   ├── command/
│   └── query/
├── infrastructure/
│   ├── persistence/
│   └── mapper/
└── api/
    ├── controller/
    ├── dto/
    └── mapper/
```

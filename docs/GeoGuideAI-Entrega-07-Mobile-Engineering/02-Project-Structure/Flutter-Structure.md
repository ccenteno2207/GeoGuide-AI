# Estructura Flutter Recomendada

```text
mobile/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router.dart
│   │   └── theme/
│   ├── core/
│   │   ├── network/
│   │   ├── storage/
│   │   ├── errors/
│   │   ├── location/
│   │   └── config/
│   └── features/
│       ├── map/
│       ├── location/
│       ├── route_planning/
│       ├── discovery/
│       ├── places/
│       ├── favorites/
│       ├── driving/
│       ├── settings/
│       └── auth/
├── test/
├── integration_test/
├── android/
└── ios/
```

## Estructura interna de feature

```text
places/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   ├── dto/
│   ├── mappers/
│   └── repositories/
└── presentation/
    ├── controllers/
    ├── screens/
    ├── widgets/
    └── state/
```

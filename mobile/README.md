# GeoGuide AI — Mobile

Bootstrap Flutter de GeoGuide AI creado en P6.1. P7 — First Vertical Slice está
cerrada: incluye la integración móvil mínima con planificación de ruta, geometría,
discovery, marcadores y ficha básica de POI.

La URL de backend se suministra externamente mediante `--dart-define`; no se hardcodea
en el código fuente. P7.5 validó en Android físico el endpoint productivo
`https://geoguide.getcom.pe:5443`, sin fallback HTTP ni bypass TLS. HTTP `:1980`
redirige a HTTPS y no representa configuración móvil productiva.

No incluye CEFI, voz, autenticación, tracking continuo, offline avanzado ni
capacidades de fases posteriores. P8 no ha iniciado.

## Validación local

```text
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

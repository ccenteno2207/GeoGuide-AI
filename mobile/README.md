# GeoGuide AI — Mobile

Bootstrap Flutter de GeoGuide AI creado en P6.1. P7 — First Vertical Slice está en
progreso: incluye la integración móvil mínima con planificación de ruta, geometría,
discovery, marcadores y ficha básica de POI.

La URL de backend se suministra externamente mediante `--dart-define`; no se hardcodea
en el código fuente. La arquitectura objetivo de P7 usa HTTPS. Mientras persista el
bloqueo externo de DNS/TLS, se autoriza exclusivamente para E2E funcional controlado
una URL HTTP temporal mediante el mismo mecanismo. HTTP no satisface el gate de
conectividad segura ni representa configuración productiva.

No incluye CEFI, voz, autenticación, tracking continuo, offline avanzado ni
capacidades de fases posteriores.

## Validación local

```text
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

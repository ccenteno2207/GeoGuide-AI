# GeoGuide AI — Mobile

Bootstrap Flutter de GeoGuide AI creado en P6.1 y vertical slice P7 en progreso.

Incluye exclusivamente el shell de aplicación, el tema base, la configuración de
análisis y una prueba de widget. Incluye mapa, ubicación puntual, selección explícita
de puntos, rutas, discovery y ficha mínima.

La integración HTTP sólo se activa cuando se suministra una URL HTTPS externa:

```text
flutter run --dart-define=BACKEND_BASE_URL=https://<dominio-aprobado>:<puerto-https-aprobado>
```

No incluir la URL real del piloto, direcciones privadas ni secretos en código o Git.

## Validación local

```text
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

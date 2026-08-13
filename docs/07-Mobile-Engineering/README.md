# GeoGuide AI – Entrega 07 – Mobile Engineering

## Objetivo
Definir la arquitectura e implementación de la aplicación móvil del MVP de GeoGuide AI
antes de iniciar el desarrollo Flutter productivo.

La aplicación móvil permitirá:
- visualizar OpenStreetMap;
- obtener ubicación actual;
- seleccionar origen y destino;
- solicitar una ruta al backend;
- visualizar la geometría de la ruta;
- descubrir POIs a lo largo del trayecto;
- consultar el detalle de un lugar;
- trabajar con conectividad limitada;
- operar en un modo de conducción con interacción reducida.

La voz manos libres es un canal estratégico e incremental: STT → intención con
contexto autorizado → casos de uso GeoGuide → TTS. La interfaz Flutter y los
adaptadores de voz comparten servicios de aplicación; el núcleo móvil no depende de un
LLM, CarPlay ni Android Auto.

## Stack de referencia
- Flutter
- Dart
- flutter_map / MapLibre como capa cartográfica, sujeto a ADR final
- OpenStreetMap
- Geolocator o equivalente open source para GPS
- Riverpod como gestión de estado recomendada
- go_router para navegación
- Dio o cliente HTTP equivalente
- Drift/SQLite para almacenamiento local
- flutter_secure_storage para tokens
- Freezed/json_serializable opcionalmente
- Mocktail/Mockito
- integration_test

## Principios
- Mobile First.
- Map First.
- Offline-ready.
- Privacy by Default.
- Driving-safe UX.
- Arquitectura modular.
- UI separada de dominio e infraestructura.
- Servicios de aplicación independientes del canal.
- APIs desacopladas mediante repositories/data sources.
- No lógica GIS compleja dentro de widgets.

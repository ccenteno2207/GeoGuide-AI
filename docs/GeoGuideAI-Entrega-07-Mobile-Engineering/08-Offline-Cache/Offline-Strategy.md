# Estrategia Offline

## Objetivo MVP
La aplicación debe degradarse de forma controlada cuando no exista conexión.

## Caché inicial
- última ruta consultada;
- POIs de la ruta;
- detalles ya abiertos;
- favoritos;
- preferencias.

## Persistencia
Drift/SQLite.

## Futuro
- paquetes de mapas offline;
- descarga de regiones;
- sincronización de contenido.

## Regla
Distinguir:
- datos frescos;
- datos cacheados;
- datos no disponibles.

La UI debe comunicar cuando la información puede estar desactualizada.

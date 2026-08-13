# Arquitectura Mobile

## Patrón recomendado
Arquitectura por features con separación de capas:

Presentation → Application → Domain ← Data/Infrastructure

## Presentation
- Screens
- Widgets
- Controllers/Notifiers
- UI states

## Application
- Use cases
- Orquestación
- Coordinación entre repositories

## Domain
- Entidades
- Value Objects
- Repository contracts
- Reglas simples de cliente

## Data / Infrastructure
- API clients
- DTO
- Mappers
- GPS
- almacenamiento local
- secure storage
- map adapters
- STT/TTS adapters

## Regla
La UI no debe depender directamente de Dio, SQLite, GPS plugin o JSON.

La UI y los adaptadores de voz tampoco contienen reglas de negocio. Ambos invocan los
mismos casos de uso de Application. STT transforma audio en texto; la capa de
aplicación interpreta una intención con contexto autorizado; TTS verbaliza una
respuesta ya preparada para el canal. Véase ADR-027.

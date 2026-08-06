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

## Regla
La UI no debe depender directamente de Dio, SQLite, GPS plugin o JSON.

# Architecture Overview

## Componentes
- Aplicación Web
- Aplicación Móvil
- API Gateway
- Servicios Backend
- Motor de Recomendaciones
- Base de datos geoespacial
- Motor de rutas

```mermaid
flowchart LR
A[Web]-->B(API)
C[Mobile]-->B
B-->D[Servicios]
D-->E[(PostGIS)]
D-->F[Motor IA]
D-->G[OSRM/GraphHopper]
```

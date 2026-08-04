# Arquitectura MVP

```mermaid
flowchart LR
A[Frontend Web]-->B(API)
C[Mobile]-->B
B-->D[Servicio de Rutas]
B-->E[Servicio POI]
B-->F[Motor IA]
D-->G[(PostGIS)]
E-->G
```

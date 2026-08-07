# Arquitectura del Backend

## Decisión principal
El MVP se implementará como **Modular Monolith**.

No se adoptarán microservicios en el piloto porque:
- incrementan la complejidad operacional;
- requieren observabilidad distribuida;
- aumentan el costo de despliegue;
- dificultan transacciones;
- no existe todavía evidencia de escala que lo justifique.

La separación por módulos permitirá extraer servicios posteriormente si surge una
necesidad real.

## Capas

### Domain
Contiene:
- entidades;
- value objects;
- reglas de negocio;
- servicios de dominio;
- puertos.

No debe depender de Spring, JPA, HTTP o proveedores externos.

### Application
Contiene:
- casos de uso;
- comandos;
- queries;
- DTO internos;
- orquestación;
- interfaces de entrada/salida.

### Infrastructure
Contiene:
- persistencia JPA/PostGIS;
- clientes HTTP;
- adaptadores de routing;
- Redis;
- MinIO;
- configuraciones técnicas.

### API
Contiene:
- REST controllers;
- request/response DTO;
- validaciones de entrada;
- mapeos;
- manejo global de errores.

## Regla de dependencias
API → Application → Domain

Infrastructure implementa puertos definidos hacia dentro y nunca al revés.

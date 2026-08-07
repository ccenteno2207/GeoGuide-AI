# Estándares de Controllers

## Responsabilidades
- validar request;
- convertir a command/query;
- ejecutar caso de uso;
- mapear response;
- devolver HTTP status adecuado.

## No deben
- ejecutar SQL;
- contener algoritmos GIS;
- consumir directamente servicios externos;
- manejar manualmente tokens;
- implementar reglas de negocio.

## Convención
Controllers versionados bajo `/api/v1`.

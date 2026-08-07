# Capa de Red

## Cliente HTTP
Dio o equivalente.

## Responsabilidades
- base URL;
- timeout;
- JSON;
- correlation ID;
- Authorization;
- retry controlado;
- logging seguro;
- traducción de errores.

## Interceptors
- CorrelationIdInterceptor
- AuthInterceptor
- ErrorMappingInterceptor
- LoggingInterceptor sanitizado

## Prohibido
- loggear access tokens;
- loggear refresh tokens;
- loggear contraseñas;
- retry infinito;
- hardcodear URL de producción.

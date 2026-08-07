# Spring Security

## Estrategia MVP
- Stateless REST API.
- Bearer JWT.
- JWT de acceso corto.
- Refresh token controlado en servidor.
- RBAC.

## Roles
- USER
- CONTENT_EDITOR
- ADMIN

## Endpoints públicos iniciales
- health limitado;
- consulta pública de POIs si así lo define producto;
- plan/discovery si se habilita uso anónimo.

## Passwords
Argon2id o BCrypt mediante PasswordEncoder.

## Reglas
- deny by default para endpoints administrativos;
- method security para casos sensibles;
- CORS explícito;
- secretos vía entorno;
- nunca loggear tokens.

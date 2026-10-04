# Runbook – Deployment

## Contexto operativo de la VM de integración

- Usuario SSH: `manager`.
- Host privado: `192.168.1.106`.
- Target SSH: `manager@192.168.1.106`.

Este contexto no incluye credenciales, claves privadas, tokens ni contraseñas.

1. confirmar pipeline verde;
2. confirmar backup si hay migración riesgosa;
3. obtener versión/tag;
4. actualizar imagen;
5. validar `docker compose config`;
6. pull;
7. `docker compose up -d`;
8. revisar estado;
9. ejecutar health check;
10. smoke test de places/routes/discovery;
11. revisar logs y métricas.

## Rollback
- restaurar tag anterior;
- `docker compose up -d`;
- verificar health;
- si existe migración incompatible, aplicar procedimiento de DB documentado.

## TLS DNS-01 deSEC: secuencia controlada

1. Mantener el compose base en HTTP hasta que exista un certificado público válido.
2. Crear externamente el token de deSEC con mínimo privilegio para el RRset TXT de
   `_acme-challenge`; guardarlo sólo en el archivo root-owned configurado por
   `DESEC_CREDENTIALS_FILE`.
3. Construir y validar la imagen Certbot versionada; no instalar plugins dentro de un
   contenedor en ejecución.
4. Emitir con `dns-desec`, validar el certificado y recién entonces levantar Nginx con
   `compose.tls.yaml`.
5. Verificar Nginx antes de recargar y comprobar HTTPS por el endpoint público NAT.
6. Instalar el servicio/timer de renovación sólo después de una emisión y activación
   exitosas. La renovación no reinicia backend ni servicios de datos.

El rollback de TLS retira sólo el override TLS y devuelve Nginx al compose HTTP base;
conserva el volumen de certificados y no modifica NAT, firewall ni la red `data`.

# Ingress HTTP y HTTPS del piloto

Nginx es el único ingress autorizado para el piloto. Pertenece a dos redes Docker:
`ingress`, un bridge orientado al exterior (`internal: false`) que permite materializar
sus puertos de host, y `data`, el bridge interno (`internal: true`) desde el que realiza
proxy únicamente a `backend:8080`. PostgreSQL, Redis, MinIO, GraphHopper y el backend
permanecen solamente en `data` y no publican puertos de host.

La red `ingress` no concede acceso directo a servicios internos: Nginx es el único
componente GeoGuide conectado a ella y el único autorizado a publicar puertos de host.

## Topología de puertos

Nginx escucha únicamente dentro de la VM en los puertos estándar:

```text
Nginx :80 / :443
```

La redirección NAT externa asigna los puertos públicos aprobados al listener
equivalente de la VM. Los puertos NAT no son listeners Docker ni deben sustituir
los puertos internos de Nginx:

```text
Público TCP 1980 -> VM TCP 80
Público TCP 5443 -> VM TCP 443
```

El tráfico HTTP se redirige a HTTPS usando el puerto público HTTPS configurado por
`GEOGUIDE_PUBLIC_HTTPS_PORT` (por defecto `5443`). Android sólo usa HTTPS.

## Bootstrap HTTP

El compose base publica únicamente `80:80` y usa
`nginx/http.conf.template`. Así Nginx puede iniciar y hacer proxy hacia el backend
sin depender de archivos de certificado inexistentes. Este estado sólo sirve para el
ingress HTTP temporal aprobado; no satisface el gate de conectividad segura.

## TLS mediante ACME DNS-01 automatizado con deSEC

La topología NAT no permite asumir que el puerto público `80` llegue a GeoGuide;
por ello HTTP-01 no es una estrategia válida. La emisión y renovación usan DNS-01
mediante la imagen reproducible `geoguide-ai/certbot-dns-desec:4.0.0-1.3.2` y el
plugin `certbot-dns-desec 1.3.2`.

El token de deSEC no pertenece al repositorio ni a `.env`. El operador lo guarda fuera
de Git, por ejemplo en `/etc/geoguide/secrets/desec.ini`, con propietario `root:root`
y modo `0600`. El archivo contiene el formato requerido por el plugin y se suministra
al compose sólo como ruta mediante `DESEC_CREDENTIALS_FILE`; el secreto se monta como
`/run/secrets/desec.ini`, de sólo lectura, exclusivamente en Certbot.

El token futuro debe usar la política de mínimo privilegio de deSEC: denegar por
defecto y permitir únicamente escritura de RRset `TXT` para el subnombre
`_acme-challenge` de la zona aprobada. No debe permitir crear/borrar dominios ni
administrar tokens.

La emisión inicial se realiza después de activar el perfil `tls`, con configuración
externa y sin copiar el token a la terminal:

```text
export DESEC_CREDENTIALS_FILE=/etc/geoguide/secrets/desec.ini
export GEOGUIDE_API_DOMAIN=<dominio-aprobado>
docker compose --profile tls run --rm certbot certonly \
  --authenticator dns-desec \
  --dns-desec-credentials /run/secrets/desec.ini \
  -d "$GEOGUIDE_API_DOMAIN"
```

El certificado y la clave quedan en el volumen `letsencrypt`, montado como sólo
lectura por Nginx. Certbot está sólo en `ingress`, no publica puertos y nunca recibe
el socket Docker.

## Activación TLS y renovación

Después de emitir el certificado, se activa el override explícito:

```text
docker compose -f compose.yaml -f compose.tls.yaml up -d nginx
```

El override publica `443:443`, monta el certificado de forma sólo lectura y cambia
Nginx a `https.conf.template`; HTTP redirige a HTTPS por el puerto público configurado
`5443`. Antes de cualquier recarga se ejecuta `nginx -t`.

`scripts/renew-certificates.sh` está diseñado para ejecutarse por el timer systemd
incluido. Certbot coloca un marcador de deploy sólo tras una renovación efectiva; el
script entonces valida Nginx y lo recarga. Un fallo de renovación deja intacto el
certificado actual y no reinicia backend ni servicios de datos.

No se aceptan certificados autofirmados para R4/R5. No guardar certificados,
claves privadas, dominios reales ni secretos en Git.

## Configuración Mobile

La aplicación recibe su endpoint sólo durante build o ejecución:

```text
--dart-define=BACKEND_BASE_URL=https://<dominio-aprobado>:5443
```

No incluir IP pública, IP privada, credenciales ni endpoint real en Dart.

## Rollback

Para revertir una activación TLS, retirar sólo el override TLS y recrear Nginx con el
compose base HTTP. Conservar `data`, `ingress`, el volumen `letsencrypt` y los
contenedores/volúmenes de aplicación. No usar `docker compose down -v` ni pruning.

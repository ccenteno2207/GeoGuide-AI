# Ingress HTTPS del piloto

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

## TLS mediante ACME DNS-01 manual

La topología NAT no permite asumir que el puerto público `80` llegue a GeoGuide;
por ello HTTP-01 no es una estrategia válida. La emisión inicial debe usar
DNS-01 manual con Certbot y sin almacenar credenciales DNS en la VM.

El operador inicia Certbot mediante el perfil `tls` y selecciona el desafío DNS.
Certbot mostrará el valor TXT temporal que debe crear el propietario del dominio:

```text
_acme-challenge.<dominio-aprobado>  TXT  <valor-entregado-por-certbot>
```

Después de que el DNS público resuelva el TXT, el operador continúa la emisión.
El certificado y la clave quedan en el volumen `letsencrypt`, montado como sólo
lectura por Nginx. El email de ACME se suministra fuera del repositorio.

No se aceptan certificados autofirmados para R4/R5. No guardar certificados,
claves privadas, dominios reales ni secretos en Git.

## Configuración Mobile

La aplicación recibe su endpoint sólo durante build o ejecución:

```text
--dart-define=BACKEND_BASE_URL=https://<dominio-aprobado>:5443
```

No incluir IP pública, IP privada, credenciales ni endpoint real en Dart.

## Rollback

Retirar Nginx y sus bindings `80/443`; conservar `data`, volúmenes de servicios y
contenedores existentes. El volumen de certificados puede preservarse para una
reanudación controlada.

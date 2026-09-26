# Ingress HTTPS del piloto

Nginx es el único ingress autorizado para el piloto. Se conecta a la red Docker
interna `data` y realiza proxy únicamente a `backend:8080`. PostgreSQL, Redis,
MinIO, GraphHopper y el backend no publican puertos de host.

## Fase A: preparación HTTP para ACME

Antes de iniciar Nginx, el operador debe definir externamente:

```text
GEOGUIDE_API_DOMAIN=api-geoguide.<dominio-controlado-por-el-propietario>
```

La plantilla `http.conf.template` publica exclusivamente `80` para responder al
desafío HTTP-01 de ACME y redirige el resto de tráfico a HTTPS. No debe usarse
como ingress funcional para Mobile antes de activar TLS.

## Fase B: certificado y HTTPS

Cuando DNS resuelva y los puertos externos `80` y `443` estén disponibles, el
operador autorizado puede emitir un certificado confiable con el perfil `tls` de
Certbot. El email de ACME se suministra fuera del repositorio. Tras la emisión,
la configuración de Nginx debe pasar de `http.conf.template` a
`https.conf.template` y publicar `443:443` además de `80:80`.

No se aceptan certificados autofirmados para R4/R5. No guardar certificados,
claves privadas, dominios reales ni secretos en Git.

## Rollback

Retirar Nginx y sus bindings `80/443`; conservar `data`, volúmenes de servicios y
contenedores existentes. El volumen de certificados puede preservarse para una
reanudación controlada.

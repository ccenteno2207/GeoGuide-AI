# Hardening del Servidor Linux

- sistema soportado y actualizado;
- usuario administrativo separado;
- SSH con claves;
- deshabilitar login remoto root;
- firewall;
- exponer únicamente puertos necesarios;
- Docker actualizado;
- sincronización horaria;
- almacenamiento y espacio monitoreados;
- backups fuera del host;
- rotación de logs;
- fail2ban opcional;
- principio de mínimo privilegio.

## Puertos públicos esperados
- 22/TCP restringido administrativamente.
- 80/TCP para redirect/challenge cuando sea necesario.
- 443/TCP aplicación.

No publicar 5432, 6379, 9000/9001 o puertos internos de routing a Internet.

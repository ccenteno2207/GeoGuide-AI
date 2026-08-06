# Flujos de Autenticación

Login:
1. Cliente envía credenciales sobre HTTPS.
2. Backend valida identidad.
3. Se genera access token de corta duración.
4. Se entrega refresh token seguro.
5. Cliente usa Bearer token.
6. Renovación rota el refresh token.

Logout:
- Invalidar refresh token en servidor.

Futuro:
- Preparar OAuth 2.1 / OpenID Connect sin forzarlo en el MVP.

# Pruebas de Seguridad Backend

Casos mínimos:
- endpoint protegido sin token → 401;
- rol incorrecto → 403;
- ADMIN permitido;
- JWT expirado rechazado;
- JWT inválido rechazado;
- inputs malformados → 400;
- no se exponen stack traces;
- validación de object-level authorization donde aplique;
- refresh token inválido/reutilizado rechazado según política.

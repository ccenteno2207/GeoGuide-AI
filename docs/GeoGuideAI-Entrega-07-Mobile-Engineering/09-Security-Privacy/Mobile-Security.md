# Seguridad Mobile

## Tokens
Guardar tokens sensibles mediante almacenamiento seguro del sistema.

## API
HTTPS obligatorio.

## Configuración
- URLs mediante flavors/env;
- no secrets en Dart;
- no claves privadas embebidas;
- no credenciales en assets.

## Logs
No registrar:
- tokens;
- contraseñas;
- ubicación histórica precisa innecesaria;
- PII.

## Release
- deshabilitar logs de depuración sensibles;
- revisar backup behavior;
- revisar permisos Android/iOS;
- validar configuración de network security.

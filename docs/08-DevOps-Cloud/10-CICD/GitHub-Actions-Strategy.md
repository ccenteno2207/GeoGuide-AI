# CI/CD con GitHub Actions

## Pull Request
1. checkout;
2. backend build;
3. unit/integration tests;
4. Flutter format/analyze/test;
5. dependency/security checks;
6. Docker build validation.

## Main
1. repetir validaciones;
2. construir imágenes;
3. generar tags inmutables;
4. publicar registry;
5. desplegar a DEV/piloto mediante mecanismo controlado;
6. smoke tests.

## Producción futura
Agregar environments, approvals y estrategia formal de promoción.

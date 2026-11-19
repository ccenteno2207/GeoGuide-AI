# ADMIN-POI-01 — evidencia de implementación local

**Baseline:** `fa59eddd76b3ed5887d82c1434c3c800fba19633`

**Rama:** `codex/admin-poi-01`

**Entorno:** local; no se usaron bases compartidas ni servicios desplegados.

## Capacidades verificadas y reutilizadas

- Portal React/Vite y cliente OIDC Authorization Code + PKCE existentes.
- API `/api/v1/admin/**` protegida por Spring Security, OIDC/JWT y roles `ADMINISTRATOR`, `EDITOR`, `REVIEWER`; permanece denegada por defecto si no se configura issuer/audience.
- Staging MINCETUR raw de solo lectura, con coordenadas originales, normalizadas, regla, evidencia, clasificación temática y cuarentena.
- Borradores editoriales, control optimista de versión, revisión geográfica e identidad, aprobación explícita, auditoría por actor y rechazo/archivo existentes.
- Creación de borrador desde MINCETUR limitada en servidor a filas normalizadas, elegibles según `MINCETUR-TAXONOMY-FILTER-v1` y no asignadas previamente.
- Publicación crea un POI activo solo después de las revisiones requeridas; archivar desactiva el POI publicado.

## Cambios de este incremento

- Filtros administrativos de nombre/código, localidad y categoría exacta en borradores editoriales; los registros MINCETUR permiten además filtrar por estado raw del staging. Localidad se consulta sobre contexto administrativo y categoría MINCETUR sobre el campo raw `CATEGORÍA`; no se normalizan ni escriben los datos fuente.
- El portal puede crear un POI manual como borrador privado con nombre, contexto/localidad, descripción y categoría. No se suministran coordenadas de forma implícita; el endpoint exige nombre no vacío. Editar nombre/contexto/categoría/datos reinicia las revisiones mediante el flujo existente.
- La aprobación bloquea borradores manuales cuyo nombre, tras la normalización existente de nombres, coincide exactamente con un registro de staging excluido de navegación. No hay coincidencia parcial ni fuzzy.
- El contrato OpenAPI administrativo documenta los filtros y el contexto opcional de creación/edición. No se modificó la API pública ni se creó migración.

## Límite contractual / brechas

1. El flujo congelado actual vincula `APPROVE` con publicación y `active=true`; `ARCHIVE` desactiva. No existe estado/acción independiente de activación. Separar aprobación de activación requiere reconciliar el modelo editorial y la API administrativa antes de implementarlo.
2. La protección contra material MINCETUR excluido cubre coincidencia exacta tras la normalización de nombre existente. El modelo manual no incorpora una identidad externa estable ni una conciliación de alias; no puede probarse automáticamente la identidad de un recurso que se carga con otro nombre. Mantener revisión de identidad y no interpretar el guard exacto como deduplicación completa.
3. El panel lista staging y registros editoriales; no ofrece inventario/edición directa de POIs públicos curados P3. No se añadió ese flujo para evitar una API/workflow administrativo no cubierto por el contrato congelado ni sobrescribir registros existentes.
4. `mvnw verify` compiló correctamente y reportó 113 tests, 0 fallos y 22 omitidos. La suite `PostgisIntegrationTests` (18 casos, incluidos los nuevos filtros/guardas) no se ejecutó porque Testcontainers no encontró Docker; no se accedió a la VM ni a bases compartidas.
5. `npm ci` reportó dos vulnerabilidades moderadas en el árbol existente. No se actualizaron dependencias.

## Validación local de este incremento

- Portal: 7/7 pruebas Vitest PASS; `npm run build` PASS.
- Backend: `mvnw verify` BUILD SUCCESS; 113 descubiertos, 0 fallos, 22 omitidos por falta de Docker/Testcontainers.
- `git diff --check`: PASS.
- No se añadieron dependencias ni migraciones. No se ejecutó PostGIS en entorno real ni se usaron bases compartidas.

## Plan mínimo restante

1. Reconciliar contractualmente si aprobación y activación deben ser acciones independientes.
2. Definir cómo se resuelve identidad entre una entrada manual y registros MINCETUR excluidos/alias antes de prometer bloqueo exhaustivo.
3. Ejecutar pruebas PostGIS aisladas con Docker autorizado; no aplicar datos a entornos compartidos.
4. Configurar el OIDC real en un entorno autorizado antes de habilitar el portal. La implementación local no incluye issuer, usuarios ni credenciales.

## Estados

```ini
ADMIN_POI_01_EXISTING_CAPABILITIES = VERIFIED
ADMIN_POI_01_CONTRACT_GAPS = IDENTIFIED
ADMIN_POI_01_IMPLEMENTATION = PARTIAL
ADMIN_POI_01_DEPLOYMENT = NOT_AUTHORIZED
```

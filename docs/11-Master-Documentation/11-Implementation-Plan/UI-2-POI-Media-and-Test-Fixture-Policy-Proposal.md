# UI-2 — Política congelada de medios POI y fixtures de prueba

**Estado:** `APPROVED_FROZEN` como política aplicable al alcance UI-2 · U2-D02/D03 `APPROVED_FROZEN`. No define esquema, licencia nueva, API, almacenamiento o autorización de publicación. Los estados siguientes son etiquetas de gobierno, no columnas existentes.

## 1. Estado comprobado

El dominio, migraciones, fixture P3, `RouteDiscoveryResponse.Result`, `DiscoveryPoi` y snapshot móvil no incluyen imagen, URI, asset key ni metadata visual. P3 sí conserva provenance textual. La documentación de infraestructura dice que MinIO podría almacenar fotografías y metadata de object keys, con buckets privados y acceso por backend/URLs temporales cuando se implemente; no se verificó una integración de imagen de POI. ADMIN-0 es propuesta y no una dependencia aprobada.

El fixture `p3-lima-obrajillo-v1.json` registra cinco candidatos P3 con nombre/categoría/latitud/longitud/descripción/procedencia. La evidencia P3 reportó 5 POIs en el entorno de validación, pero no certifica el estado de una base de datos actual. Ninguno contiene imagen.

| Candidato | Categoría | Coordenadas según fixture (lat, lon) | Descripción en fixture |
|---|---|---|---|
| Santuario de Santa Rosa de Quives | HISTORIC_CHURCH | -11.6687314, -76.7899852 | Sí |
| Petroglifos de Checta | ARCHAEOLOGICAL_SITE | -11.6929182, -76.8150337 | Sí |
| Plaza de Armas de Canta | MONUMENT | -11.4669625, -76.6247746 | Sí |
| Plaza de Armas de Obrajillo | MONUMENT | -11.4538209, -76.6201906 | Sí |
| Iglesia San Juan Bautista de Obrajillo | HISTORIC_CHURCH | -11.454071, -76.6196202 | Sí |

Categoría/procedencia de texto no concede derechos sobre fotografía de una obra o lugar.

## 2. Clasificación propuesta

| Estado conceptual | Significado operativo | Uso permitido bajo esta política | Evidencia requerida |
|---|---|---|---|
| `TEST_ONLY` | Recurso aislado para pruebas internas, incluyendo fixture sintético con procedencia adecuada, nunca distribuido en APK release. | Pruebas automatizadas y uso interno controlado previsto. Foto real solo si rights permiten expresamente ese uso concreto. | Origen/generación, autor, términos aplicables, uso permitido y límite de entorno. |
| `RIGHTS_NOT_VERIFIED` | Origen conocido o candidato, derechos/atribución no confirmados. | No renderizar. Guardar solo en registro de investigación si se autoriza. | Responsable y evidencia pendiente; nunca equivale a autorización. |
| `RIGHTS_VERIFIED` | La licencia/consentimiento permite el uso específico evaluado. | Solo el uso, audiencia, transformación y distribución cubiertos por el expediente. | Licencia/consentimiento, autor, atribución, URL/origen, fecha, restricciones y comprobación legal/producto indicada por owner. |
| `PUBLICATION_APPROVED` | Aprobación de publicación para producto y canal explícitos, posterior a derechos verificados. | Distribución del activo publicable conforme a términos/atribución/licencia archivados. | Aprobación humana identificable, scope/canal, versión y expiración/revisión si aplican. |

No ascender automáticamente estado por importar archivo, generar una ilustración, tener licencia OpenStreetMap para datos, recibir permiso del lugar, o haber sido aprobado para una prueba. Foto TEST_ONLY jamás debe caer en bundle/build de release ni en snapshot compartido.

## 3. Alternativas visuales

| Alternativa | Ventaja | Riesgo/condición | Recomendación |
|---|---|---|---|
| Placeholder del proyecto | Determinista, liviano, no implica que exista una foto del POI. | Debe ser accesible y distinguirse del contenido real. | Fallback obligatorio y baseline de UI2. Usar icono/campo neutro existente o forma vectorial de código, sin agregar dependencia. |
| Fixture de imagen sintético generado para tests | Asegura ratio/color/layout reproducibles sin representar un lugar real. | Debe quedar en test resources; revisar licencia/procedencia de generador/artefacto y no copiar a producción. | Preferido para tests de thumbnail y estados; sin inclusión en APK release. |
| Fotografía real para prueba controlada | Relevancia y layout con contenido real. | Un resultado de Internet no prueba derechos; se requiere evidencia verificable de fuente, autor, licencia o autorización y atribución aplicable para el uso controlado previsto. | Permitida como recurso de prueba solo tras registrar esa evidencia; la aprobación no concede publicación en producto. Esta reconciliación no descarga ni incorpora fotos. |
| Imagen servida desde ADMIN/MinIO | Pipeline editorial, metadata/privacidad centralizada y URLs controladas. | ADMIN-0, media DTO, autorización, retención, cache/auth/offline no están aprobados ni implementados según fuentes actuales. | Evolución futura independiente; no requerir para placeholder/UI2. |

## 4. Especificación de presentación sugerida

Zona de miniatura de tamaño estable aprobada; valores iniciales candidatos: tarjeta 96×72 dp, detalle ratio 16:9 con altura acotada, `BoxFit.cover` con foco central seguro. Pueden ajustarse durante implementación futura si pruebas de layout/accesibilidad lo requieren. Mantener dimensiones fijas para evitar saltos. Estados: placeholder inmediato, carga con semantics informativas no redundantes, error con mismo placeholder; no bloquear nombre o acciones por imagen. Nunca indicar «foto del lugar» si es ilustración. Mostrar nombre y demás datos incluso sin imagen.

Para imagen informativa, alt/semantics descriptiva solo cuando contenido y texto alternativo estén revisados. Decoración lleva semantics excluida. Contraste/superposiciones se evalúan en tema claro, oscuro si aplicable y escalado. No comunicar calidad, apertura o validez del POI a partir de imagen.

La procedencia/atribución se presenta junto al activo cuando licencia la requiere, en la superficie y para el idioma/forma legalmente correctos. No reutilizar automáticamente attribution de POI/osm como atribución de foto.

## 5. Separación test/publicación

- Colocar fixtures solo en paths de test y nombrarlos con prefijo/README `test-only`; no compartir el mismo directorio que assets Flutter release ni empaquetarlos en APK release.
- Cada fixture debe tener registro: id de activo, estado, origen o indicación «generado», autor, fecha, licencia/permiso, uso permitido, atribución, hash y casos de prueba que lo referencian.
- Validación automatizada futura debe demostrar ausencia de `TEST_ONLY` y `RIGHTS_NOT_VERIFIED` en manifest de assets publicables y en respuesta/runtime configuration de release.
- Capturas de evidencia deben usar placeholder/fixture sintético sin geolocalización personal; rotular renderer. No descargar assets ni capturar páginas con imagen para dar apariencia de aprobación.
- `PUBLICATION_APPROVED` se concede por activo y superficie/canal; no por sitio completo o colección sin manifest.

## 6. Snapshot, caché y privacidad

P9 guarda un único snapshot offline hasta 5 MiB y 24 h con consentimiento contextual, borrado y acceso privado; URLs firmadas temporales no tienen garantía de validez durante TTL y pueden introducir identidad/credenciales o transferencia. UI2 no debe insertar URL, bytes ni metadata de media al snapshot o a su codec. La presentación en P9 offline usa placeholder salvo que un futuro contrato de media establezca explícitamente descarga/retención, tamaño, hash, licencia, purga y backup, con gate de privacidad y P9. No activar MinIO/Redis como atajo de cache de medios.

## 7. Evolución posible hacia administración de medios

Una fase futura requeriría contrato de asset y estados, autorizador, carga/cuarentena/virus scan si aplica, normalización/miniaturas, bucket privado, metadata y rights registry, API pública de consulta, CDN o acceso autenticado, caché/offline y política de borrado/revocación, OpenAPI, tests de seguridad, atribución y continuidad. La existencia del módulo `media` o MinIO en arquitectura no prueba que estos flujos estén implementados. ADMIN-0 por sí solo tampoco autoriza API ni publicación.

```ini
UI_2_MEDIA_POLICY = APPROVED_FROZEN
UI_2_CONTRACT = APPROVED_FROZEN
UI_2_CONTRACT_FREEZE = RECORDED
UI_2_IMPLEMENTATION = NOT_AUTHORIZED
POI_IMAGE_DTO_EXISTS = NO
POI_IMAGE_DB_SCHEMA_EXISTS = NO
POI_MEDIA_INTEGRATION_VERIFIED = NO
UI_2_IMAGE_BASELINE = RESERVED_STABLE_THUMBNAIL_WITH_ACCESSIBLE_PLACEHOLDER
CONTROLLED_TEST_PHOTOS = RIGHTS_EVIDENCE_REQUIRED
PRODUCTION_PHOTOS_UI_2 = OUT_OF_SCOPE_WITH_SEPARATE_APPROVAL_REQUIRED
TEST_ONLY_RELEASE_ASSET = PROHIBITED
```

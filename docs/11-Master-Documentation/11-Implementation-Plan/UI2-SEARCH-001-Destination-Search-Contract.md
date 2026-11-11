# UI2-SEARCH-001 — Búsqueda de destinos por nombre

**Estado:** `APPROVED` para alternativa B por autorización humana expresa; cobertura del catálogo `PILOT_LIMITED`.
**Baseline de preparación:** `4003508f0e355de8fa003a7ce1898c5a8269fd4a` (`origin/main`).

## 1. Propósito y límite

Permitir que una persona encuentre destinos turísticos y localidades escribiendo su nombre, sin conocer coordenadas. Esta capacidad complementa la selección manual de extremos del mapa; no la reemplaza. Es independiente del filtro efímero «Buscar en estos resultados», que sigue limitado a POIs del snapshot vigente conforme a UI-2 U2-D01 y UI2-AC-08.

La decisión del propietario del 11-nov-2026 aprueba la alternativa B, el modelo/persistencia, una API versionada y la integración Flutter para desarrollo y pruebas locales/aisladas. No autoriza despliegue, migración compartida, instalación física, push, PR ni merge. UI-2 congelado y U2-D04 permanecen intactos: este contrato complementario gobierna únicamente la búsqueda de destinos.

## 2. Experiencia aprobada

- Texto del campo: **«¿Qué conoceremos hoy?»**.
- Tipos previstos: localidades; plazas y lugares emblemáticos; atractivos naturales; sitios arqueológicos; POIs turísticos.
- Ejemplos de consultas de producto: Plaza de Armas de Lima, Plaza de Armas de Ica, Plaza de Armas de Arequipa, Oasis de Huacachina, Santa Rosa de Quives, Canta, Obrajillo y Líneas de Nazca. La disponibilidad efectiva se limita a los registros y alias verificados en el [catálogo piloto y sus límites](UI2-SEARCH-001-Catalog-Source.md); no equivale a cobertura de localidades ni cobertura nacional.
- Normalizar tildes y mayúsculas para comparar; admitir alias únicamente cuando estén verificados por la fuente aprobada.
- Mostrar contexto suficiente para desambiguar resultados homónimos. Nunca seleccionar automáticamente: la persona elige explícitamente un resultado.
- Solo un resultado con coordenadas verificadas puede completar el destino de `PlanRoute`. La selección manual en mapa permanece disponible.
- Cubrir estados inicial, carga, resultados, vacío, error y reintento. No invocar autocompletado remoto mientras se escribe; la consulta se inicia explícitamente.

## 3. Datos, privacidad y procedencia

Cada resultado utilizable para ruta necesita identificador estable, nombre canónico, tipo, contexto geográfico para desambiguación, coordenadas verificadas y procedencia identificable. El catálogo piloto declara fuente, licencia ODC-BY, atribución, fecha de corte, cobertura y límites en su [registro de datos](UI2-SEARCH-001-Catalog-Source.md). No fabricar resultados, alias ni coordenadas. No guardar historial de consultas por defecto; la consulta se mantiene solo en memoria durante la superficie de búsqueda y no se añade telemetría.

La atribución y licencia de cada resultado se devuelven a la aplicación para mostrarlas junto con el contexto. La frecuencia de actualización y responsabilidad de curación siguen siendo operación local pendiente de definir antes de cualquier despliegue; esta implementación no supone disponibilidad, costo ni servicio compartido.

## 4. Alternativas técnicas consideradas

| Alternativa | Ajuste y límite | Disposición |
|---|---|---|
| A. Reutilizar POIs actuales | Discovery consulta POIs dentro del corredor de una ruta; el snapshot y su filtro local no son un catálogo global de destinos. El fixture inspeccionado contiene cinco POIs de un corredor. Reutilizarlo sin contexto induciría cobertura falsa. | No suficiente como búsqueda por nombre general. Puede ser una fuente parcial futura si la cobertura se declara y distingue. |
| B. Catálogo geográfico curado de primera parte | Permite nombres canónicos, alias verificados, tipo, contexto, coordenadas y procedencia con cobertura declarada; desacopla el cliente de la fuente. Tiene costo operativo de curación y revisión, sin tarifa de proveedor externo asumida. | **Aprobado** por el propietario para desarrollo local/aislado. |
| C. Proveedor externo | Puede ampliar cobertura, pero introduce costo y cuotas potenciales, términos/licencias, disponibilidad externa, privacidad de consultas y dependencia operativa. | No seleccionado ni autorizado. Requiere decisión expresa independiente. Google Places no forma parte de esta propuesta. |

## 5. Diseño mínimo aprobado para integración local

El código base solo expone planificación de ruta y descubrimiento de POIs del corredor. La implementación aprobada incorpora:

1. Modelo de dominio de destino con ID estable, nombre, tipo, contexto, coordenada y procedencia.
2. Caso de uso `SearchDestinations`, puerto de repositorio y adaptador PostGIS separados.
3. `POST /api/v1/destinations/search`, consulta explícita, límite máximo de resultados, respuesta estable para desambiguación y `ProblemDetail` para entrada inválida.
4. Catálogo persistente aislado de las tablas POI, migración Flyway y carga versionada opt-in.
5. Adaptador Flutter a la API, presentación de resultados y selección explícita que conserva el origen y requiere pulsar «Calcular ruta».

La carga inicial usa exclusivamente el Inventario Nacional de Recursos Turísticos publicado por MINCETUR en la Plataforma Nacional de Datos Abiertos, licencia ODC-BY. El artefacto, su hash, fecha de corte, atribución, inversión corregida de columnas de coordenadas y cobertura limitada se documentan junto al JSON del catálogo. Solo hay destinos con ficha y coordenadas presentes en el corte; no se crean localidades independientes ni alias sin evidencia. Se incluyen alias cuando la ficha fuente los declara expresamente. No se incluyen fotografías. La selección no inicia GPS, Driving ni CEFI.

## 6. Implementación Flutter autorizada

La pantalla principal ofrece el campo «¿Qué conoceremos hoy?» solo cuando hay configuración del servicio. Consultar requiere envío explícito; no hay autocomplete. La selección devuelve coordenadas verificadas al controlador de rutas, conserva el origen y espera una acción separada para calcular. Si el servicio no está configurado, se conserva selección manual y no aparece un control que finja funcionar. Si la solicitud falla, la UI presenta error y reintento sin persistir consulta.

## 7. Criterios de aceptación de extremo a extremo

| ID | Criterio | Evidencia futura |
|---|---|---|
| SEARCH-AC-01 | El campo muestra «¿Qué conoceremos hoy?» y conserva búsqueda por mapa. | Widget y prueba física visual. |
| SEARCH-AC-02 | Normalización de tildes/caso y alias solo verificados por fuente. | Unit tests y datos con procedencia. |
| SEARCH-AC-03 | Resultados separados por tipo/contexto; homónimos requieren elección explícita. | Tests unit/widget con resultados ambiguos. |
| SEARCH-AC-04 | Sin coincidencias/error/reintento expresan estado real, sin resultados simulados. | Tests de estados y respuesta API real. |
| SEARCH-AC-05 | Resultado elegido aporta coordenadas verificadas a `PlanRoute`; la selección manual sigue operativa. | Integración Flutter/API y regresión de planificación. |
| SEARCH-AC-06 | Consultas no se persisten ni se añaden a telemetría; no hay geocoder externo no aprobado. | Revisión de código, almacenamiento, red y configuración. |
| SEARCH-AC-07 | La fuente declara cobertura, procedencia, atribución, licencia y límites; no se afirma cobertura global sin evidencia. | Contrato de datos, registro de fuentes y revisión legal/producto aplicable. |
| SEARCH-AC-08 | Sin regresión de UI2-AC-01–AC-14, snapshot local, Route Discovery, Driving reducido, privacidad ni controles existentes. | Suites de regresión autorizadas. |

## 8. Trazabilidad y estados

- UI-2 U2-D04 continúa intacta como exclusión del contrato congelado; este documento es el mecanismo complementario independiente, no una modificación retroactiva.
- UI-2 U2-D01/UI2-AC-08 conserva su semántica exclusivamente local al snapshot.
- MAP-002 mantiene su estado contractual independiente.
- No se amplía GPS/permisos, Driving, CEFI, P12 ni los contratos congelados.

```ini
UI2_SEARCH_001_PRODUCT_DIRECTION = OWNER_APPROVED
UI2_SEARCH_001_COMPLEMENTARY_CONTRACT = APPROVED
UI2_SEARCH_001_DATA_SOURCE = FIRST_PARTY_CURATED_CATALOG
UI2_SEARCH_001_BACKEND_IMPLEMENTATION = LOCAL
UI2_SEARCH_001_FLUTTER_IMPLEMENTATION = LOCAL
UI2_SEARCH_001_PHYSICAL_VALIDATION = NOT_AUTHORIZED
UI2_SEARCH_001_DEPLOYMENT = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

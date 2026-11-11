# UI2-SEARCH-001 — Búsqueda de destinos por nombre

**Estado:** dirección de producto `OWNER_APPROVED`; contrato complementario `PREPARED_FOR_REVIEW`; integración de fuente real `PENDING_BACKEND_DECISION`.
**Baseline de preparación:** `4003508f0e355de8fa003a7ce1898c5a8269fd4a` (`origin/main`).

## 1. Propósito y límite

Permitir que una persona encuentre destinos turísticos y localidades escribiendo su nombre, sin conocer coordenadas. Esta capacidad complementa la selección manual de extremos del mapa; no la reemplaza. Es independiente del filtro efímero «Buscar en estos resultados», que sigue limitado a POIs del snapshot vigente conforme a UI-2 U2-D01 y UI2-AC-08.

La decisión del propietario aprueba esta dirección y la preparación de componentes Flutter desacoplados. Este documento no congela una fuente, cobertura, contrato HTTP, esquema ni política operativa, y no autoriza su implementación backend o publicación. La búsqueda no se presenta como operativa en la aplicación hasta conectarla a un origen real aprobado.

## 2. Experiencia aprobada

- Texto del campo: **«¿Qué conoceremos hoy?»**.
- Tipos previstos: localidades; plazas y lugares emblemáticos; atractivos naturales; sitios arqueológicos; POIs turísticos.
- Ejemplos de consultas de producto: Plaza de Armas de Lima, Plaza de Armas de Ica, Plaza de Armas de Arequipa, Oasis de Huacachina, Santa Rosa de Quives, Canta, Obrajillo y Líneas de Nazca. Son ejemplos de consultas, no datos ni coordenadas declarados disponibles.
- Normalizar tildes y mayúsculas para comparar; admitir alias únicamente cuando estén verificados por la fuente aprobada.
- Mostrar contexto suficiente para desambiguar resultados homónimos. Nunca seleccionar automáticamente: la persona elige explícitamente un resultado.
- Solo un resultado con coordenadas verificadas puede completar el destino de `PlanRoute`. La selección manual en mapa permanece disponible.
- Cubrir estados inicial, carga, resultados, vacío, error y reintento. No invocar autocompletado remoto mientras se escribe; la consulta se inicia explícitamente.

## 3. Datos, privacidad y procedencia

Cada resultado utilizable para ruta necesita identificador estable, nombre canónico, tipo, contexto geográfico para desambiguación, coordenadas verificadas y procedencia identificable. La fuente debe declarar cobertura y límites. No fabricar resultados, alias ni coordenadas. No guardar historial de consultas por defecto; la consulta se mantiene solo en memoria durante la superficie de búsqueda y no se añade telemetría.

La atribución que requiera la fuente se mostrará conforme a sus condiciones una vez aprobada. Licencia, atribución, retención operativa, límites de consulta, disponibilidad, costo y responsabilidad de curación deben evaluarse para la fuente seleccionada antes de su integración.

## 4. Alternativas técnicas consideradas

| Alternativa | Ajuste y límite | Disposición |
|---|---|---|
| A. Reutilizar POIs actuales | Discovery consulta POIs dentro del corredor de una ruta; el snapshot y su filtro local no son un catálogo global de destinos. El fixture inspeccionado contiene cinco POIs de un corredor. Reutilizarlo sin contexto induciría cobertura falsa. | No suficiente como búsqueda por nombre general. Puede ser una fuente parcial futura si la cobertura se declara y distingue. |
| B. Catálogo geográfico curado de primera parte | Permite nombres canónicos, alias verificados, tipo, contexto, coordenadas y procedencia con cobertura declarada; desacopla el cliente de la fuente. Tiene costo operativo de curación y revisión, sin tarifa de proveedor externo asumida. | **Recomendado**, sujeto a aprobar alcance del catálogo, fuentes/licencias y operación. |
| C. Proveedor externo | Puede ampliar cobertura, pero introduce costo y cuotas potenciales, términos/licencias, disponibilidad externa, privacidad de consultas y dependencia operativa. | No seleccionado ni autorizado. Requiere decisión expresa independiente. Google Places no forma parte de esta propuesta. |

## 5. Diseño mínimo para integración real — pendiente de aprobación

El código actual solo expone planificación de ruta y descubrimiento de POIs del corredor; no hay endpoint general para destinos/localidades ni repositorio de catálogo en el cliente. La opción B probablemente requiere:

1. Modelo de dominio de destino con ID estable, nombre, tipo, contexto, coordenada verificada y procedencia.
2. Caso de uso `SearchDestinations` y puerto de repositorio, desacoplados de HTTP y del catálogo concreto.
3. Operación API documentada en OpenAPI para consulta explícita por nombre; el diseño debe decidir método/ruta, límites de consulta, orden y respuesta de desambiguación. Evitar query en URL es una opción de privacidad/logging, no una decisión congelada.
4. Catálogo persistente y migración Flyway únicamente si se aprueba el catálogo como fuente; definir alias, fuente, licencia/atribución, vigencia, índices de texto/geografía y cobertura.
5. Adaptador Flutter para esa API y selección explícita del destino en el flujo existente de planificación.

No se implementan aquí API, OpenAPI, base de datos, migración, proveedor, catálogo, carga de datos ni conexión productiva. Antes de esos cambios se requiere aprobación del diseño mínimo, de la fuente/procedencia y de las condiciones de operación. La selección de un resultado no debe iniciar GPS, Driving ni CEFI.

## 6. Preparación Flutter autorizada

Se permite una base técnica no conectada a producción: tipos internos, puerto/caso de uso, componente visual inyectable y pruebas con fixtures exclusivamente de test. El componente no se monta en el mapa ni muestra resultados de ejemplo en la APK. No modifica UI-2 congelado, su filtro local, endpoints, DTOs, persistencia, permisos ni dependencias.

## 7. Criterios para la futura integración de extremo a extremo

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
UI2_SEARCH_001_COMPLEMENTARY_CONTRACT = PREPARED_FOR_REVIEW
UI2_SEARCH_001_FLUTTER_SCAFFOLD = PREPARED_UNCONNECTED
UI2_SEARCH_001_REAL_DATA_SOURCE = PENDING_APPROVAL
UI2_SEARCH_001_PUBLIC_API_SCHEMA = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

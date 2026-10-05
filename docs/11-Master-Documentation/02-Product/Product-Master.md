# Producto Maestro

## Problema
Los navegadores ayudan a llegar al destino, pero no están optimizados para descubrir
el patrimonio, naturaleza, gastronomía y lugares relevantes alrededor de la ubicación
o a lo largo de la ruta. GeoGuide AI no busca reemplazarlos ni operar como chatbot
genérico.

## Job to be Done
“Cuando viajo por carretera, quiero saber qué lugares interesantes existen cerca de
mi trayecto y cuánto debo desviarme, para decidir si vale la pena visitarlos.”

## Flujo principal
Destino → confirmar/elegir origen → ruta → comprender recorrido → descubrir → POIs →
preview → detalle → regresar al mismo contexto del recorrido.

La experiencia final no se limita a dos toques sobre el mapa. El destino evolucionará
hacia búsqueda por lugar, búsqueda por dirección y selección en mapa; el origen podrá
usar Mi ubicación, búsqueda o mapa y siempre será editable. La búsqueda/geocoding es
importante para el MVP final, pero no está implementada ni se incluye silenciosamente
en P8; requiere una decisión arquitectónica posterior.

## Baseline UX aprobado por producto

GeoGuide AI no es simplemente un navegador GPS. Su propósito es ayudar al rutero a
planificar, comprender el trayecto, descubrir lugares relacionados, decidir qué
conocer y construir progresivamente conocimiento reutilizable en rutas futuras. Las
preguntas guía son “¿Qué puedo conocer sin desviarme demasiado?” y “¿Qué me falta
conocer en esta ruta?”. Son orientación de producto, no contratos técnicos.

Principios consolidados: explorar nunca destruye el contexto del viaje; la distancia
al trazado no es desvío; `routeProgress` no es progreso del conductor; la proximidad
geométrica no garantiza acceso inmediato; Discovery, Recreation y Travel Service son
intenciones distintas; mapa y lista/tarjetas deben coexistir conceptualmente; el
ranking sigue siendo autoritativo en backend; y los servicios comerciales no se tratan
automáticamente como descubrimiento cultural/turístico. La taxonomía final debe
auditar y reutilizar P3, sin crear una taxonomía mobile paralela.

## Historia futura y dirección CEFI-ready

La visión futura distingue `NO VISITADO`, `QUIERO CONOCER` y `VISITADO`. Visitado se
confirma explícitamente, puede revertirse y pertenece conceptualmente a la relación
usuario ↔ lugar, con identidad estable entre rutas. No se crea persistencia, cuenta ni
schema en este gate.

`CEFI_READY_ARCHITECTURE = REQUIRED_DIRECTION`. GeoGuide AI sigue siendo el producto y
CEFI su futuro copiloto/canal conversacional. CEFI no se implementa en P8 ni se
seleccionan proveedores. Las capacidades futuras deben ser reutilizables por UI y
CEFI mediante casos de uso compartidos, resultados estructurados, provenance y errores
interpretables, respetando Clean Architecture y Modular Monolith.

Flujo cercano: ubicación autorizada → POIs cercanos → ficha confiable.

Flujo de voz estratégico: STT → intención y contexto → servicios GeoGuide → TTS. UI y
voz comparten casos de uso; Driving/Travel Mode reduce distracción.

## Identidad conversacional CEFI

GeoGuide AI es el nombre oficial del producto y la aplicación. CEFI no es un producto
separado.

CEFI es la identidad conversacional y el copiloto inteligente de GeoGuide AI.
Interactúa de forma natural con el rutero, prioritariamente mediante voz y con mínima
distracción durante la conducción. CEFI utiliza las capacidades y los datos de GeoGuide
AI para comunicar información, contexto y recomendaciones, pero no sustituye los
motores técnicos que los producen ni decide por el usuario.

### Responsabilidades

- presentar información y recomendaciones producidas por capacidades compartidas de
  GeoGuide AI;
- comunicar lugares de interés, contexto resumido e información útil disponible;
- presentar desvío aproximado o tiempo adicional cuando esas capacidades existan;
- ofrecer opciones para que el rutero decida;
- mantener mensajes breves y accionables, mínima distracción visual y control del
  usuario, evitando incentivar la manipulación del teléfono durante la conducción;
- aplicar privacidad y minimización a ubicación, audio y transcripciones, y diferir
  interacciones complejas hasta que sea apropiado realizarlas con el vehículo detenido.

### Límites

Routing determina el recorrido. Route Discovery descubre, evalúa, clasifica y ordena
POIs u oportunidades alrededor de la ruta. CEFI comunica y contextualiza esos resultados
conversacionalmente para que el rutero pueda decidir.

CEFI no calcula rutas, construye corredores, busca o rankea POIs por sí mismo, sustituye
Routing, Route Discovery o POI Data, actúa como fuente factual independiente ni decide
por el usuario. Esta identidad no implica actualmente un LLM, STT/TTS, proveedor,
pipeline de audio, persistencia, API, módulo, servicio, agente o microservicio.

CEFI es un concepto de producto y una capacidad de experiencia futura. Su documentación
no autoriza implementación, no modifica el alcance vigente y no incorpora CEFI a una
fase sin un contrato aprobado que lo establezca explícitamente.

## Categorías iniciales
- naturaleza;
- cultura;
- arqueología;
- museos;
- miradores;
- servicios seleccionados.

## Fuera del MVP
- tráfico en tiempo real;
- navegación turn-by-turn avanzada propia;
- red social;
- marketplace completo;
- personalización ML compleja.
- itinerarios generados, CarPlay y Android Auto;
- voz o IA avanzada como dependencia obligatoria del núcleo MVP.

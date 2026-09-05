# Diccionario de Datos

Este diccionario describe la semántica del baseline P3 y no sustituye el DDL Flyway. Los
nombres físicos no aprobados se fijan durante la implementación.

## Category

- identidad interna: UUID, clave primaria;
- código: obligatorio y único;
- nombre: obligatorio;
- estado activo: booleano.

## PointOfInterest

- `id`: UUID, clave primaria;
- `name`: obligatorio;
- `category_id`: UUID obligatorio, FK `PointOfInterest.category_id → Category.id`;
- `location`: `geometry(Point,4326) NOT NULL`;
- `description`: texto factual opcional;
- `active`: `BOOLEAN`;
- `created_at`: `TIMESTAMPTZ`, representa un instante;
- `updated_at`: `TIMESTAMPTZ`, representa un instante.

La ubicación se almacena exclusivamente en la geometría; el baseline no incluye
columnas escalares duplicadas de latitud o longitud.

## Provenance

Estructura separada con relación `Provenance.poi_id → PointOfInterest.id`. Debe poder
representar:

- fuente o sistema identificable;
- identificador externo cuando la fuente lo proporcione;
- referencia verificable cuando corresponda;
- fecha de recuperación cuando corresponda;
- licencia o condición de uso aplicable;
- atribución cuando sea obligatoria;
- origen o método de incorporación;
- identidad estable para idempotencia, incluidos registros manuales sin ID externo.

La nulabilidad y los nombres físicos de propiedades condicionadas por la fuente se
deciden durante la implementación y deben admitir un `no aplica` justificado. No se debe
exigir ID externo a una fuente que no lo proporcione.

## Atributos futuros

Horarios, precios, website, teléfono, rating, multimedia y otros enriquecimientos no son
requisitos del baseline P3.

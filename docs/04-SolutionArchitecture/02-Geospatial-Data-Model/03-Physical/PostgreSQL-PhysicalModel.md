# Modelo Físico PostgreSQL

## Baseline P3

El baseline POI utiliza el schema `geo` y mantiene estructuras separadas para Category,
PointOfInterest y Provenance. La identidad interna de Category y PointOfInterest es
UUID.

### Category

- UUID interno;
- código obligatorio y único;
- nombre obligatorio;
- estado activo.

La inclusión de timestamps de Category y sus detalles de nulabilidad o defaults se
deciden durante la implementación.

### PointOfInterest

- UUID interno;
- nombre obligatorio;
- descripción factual opcional;
- referencia obligatoria a Category;
- ubicación `geometry(Point,4326) NOT NULL`;
- estado físico `active BOOLEAN`;
- `created_at` y `updated_at` como `TIMESTAMPTZ` para representar instantes.

La relación es `PointOfInterest.category_id → Category.id`. La ubicación dispone de un
índice GiST y no se duplica mediante columnas escalares de latitud y longitud.

### Provenance

Provenance es una estructura separada cuya relación es
`Provenance.poi_id → PointOfInterest.id`. Debe soportar conceptualmente fuente, ID
externo opcional, referencia verificable, fecha de recuperación, licencia o condición
de uso, atribución aplicable, origen de incorporación e identidad lógica para una carga
idempotente.

Los nombres físicos, nulabilidad y constraints no aprobados, incluida la clave estable
de registros manuales y la clave lógica exacta de provenance, se deciden durante la
implementación. La existencia de al menos una provenance para un POI publicable se
valida en dominio o aplicación, no mediante una constraint SQL compleja.

## Evolución

Los schemas `core`, `media`, `security` y `audit`, así como LineString, Polygon y los
índices secundarios, se incorporan cuando una fase o necesidad de consulta documentada
lo requiera. Consultas `nearby`, routing y Route Discovery no pertenecen al baseline P3.

# Definition of Done Backend

Una historia backend está terminada cuando:
- [ ] compila en Java 21;
- [ ] sigue los límites de módulos;
- [ ] tiene pruebas relevantes;
- [ ] `mvn verify` pasa;
- [ ] no introduce secretos;
- [ ] errores siguen Problem Details;
- [ ] OpenAPI está actualizado;
- [ ] DB change tiene Flyway;
- [ ] seguridad revisada;
- [ ] logs no exponen datos sensibles;
- [ ] documentación afectada actualizada;
- [ ] no contradice ADR sin aprobación.

## Cierre técnico P3

El contrato integral y prevalente está en
[P3 Definition of Done](../../11-Master-Documentation/11-Implementation-Plan/P3-Definition-of-Done.md).

Para cerrar P3, además:

- [ ] el dominio POI y sus invariantes tienen pruebas unitarias sin dependencia HTTP;
- [ ] existen el puerto de persistencia y su adaptador dentro de los límites modulares;
- [ ] la persistencia usa PostgreSQL/PostGIS real y coincide con el modelo P3 aprobado;
- [ ] los cambios estructurales usan migraciones Flyway posteriores a V001;
- [ ] V001 permanece inmutable con checksum `-1627021776` y `baseline-on-migrate` no
  queda habilitado permanentemente;
- [ ] una base limpia migra y pasa `flyway validate` mediante Testcontainers;
- [ ] el baseline heredado se valida separadamente en la VM y preserva P1/P2;
- [ ] `mvnw verify` finaliza correctamente;
- [ ] el diff y la documentación respetan el alcance P3;
- [ ] el cierre final dispone de revisión Git y Pull Request.

La validación del dataset corresponde a la
[Definition of Done Data & AI](../../09-Data-AI/16-Codex-Handoff/Definition-of-Done.md)
y a [R3](../../11-Master-Documentation/11-Implementation-Plan/Release-Gates.md).
API HTTP, OpenAPI Places, search, `nearby`, routing y Route Discovery no bloquean P3.
No se exige un porcentaje genérico de cobertura.

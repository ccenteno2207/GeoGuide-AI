# Reconciliación documental post-P7 — pre-P8

## Alcance y baseline

Fecha: 5-oct-2026. Baseline de entrada y cierre P7:
`ada26c8881cdefb2d8f0ede679a8ebb3996ab61c` (PR #31).

Este gate reconcilia estados documentales y evidencia DNS posterior. No inicia P8,
no crea su contrato ni implementa preview, detail o filter. No cambia código,
OpenAPI, base de datos ni infraestructura.

```text
P0_TO_P7 = COMPLETED
P7_STATUS = CLOSED
P7_PROGRESS = 100%
P7_5_STATUS = CLOSED
P7_6_STATUS = COMPLETED
P7_AC_01_TO_11 = PASS
GLOBAL_PROGRESS = 78%
P8_NAME = POI Experience
P8_SCOPE_SOURCE = preview/detail/filter
P8_STATUS = NOT STARTED
P8_CONTRACT_EXISTS = NO
```

## Contrato congelado y estado posterior

`P7-Phase-Contract-v1.md` es el snapshot normativo congelado, no un registro de
estado operativo actualizado. Se preserva byte a byte. Su hash de objeto Git es
`17d3c3366a051263af49a246fd67823133a584bd`.

Sus referencias a TLS bloqueado, P7.5 en progreso y P7.6 no iniciado son
`VALID_HISTORICAL_REFERENCE`. Los resultados posteriores están en
[P7-Validation-Evidence.md](P7-Validation-Evidence.md), `PROJECT_CONTEXT.md`,
`ROADMAP.md`, `CHANGELOG.md` y el cierre PR #31. No se alteran retrospectivamente
criterios de aceptación ni alcance P7.

Los resúmenes vigentes de AGENTS, README, Documentation Index y handoffs backend y
maestro se alinean con ese cierre. Decision Register se alinea con ADR-019:

```text
MAP_LIBRARY_DECISION = RESOLVED
flutter_map = ACCEPTED (8.3.2)
TILE_PROVIDER_GOVERNANCE = PENDING
```

La aceptación de biblioteca no autoriza un proveedor productivo de tiles.

## Verificación actual del parent DNS

Verificado el **5-oct-2026, aproximadamente 10:37 America/Bogota (UTC-05:00)**,
mediante consultas DNS directas sin recursión. `dig` no estaba disponible en este
entorno Windows; se usó `nslookup` para inspeccionar la sección AUTHORITY de la
respuesta. Los nombres parent resolvieron a estas direcciones:

| Parent | IP consultada | RCODE | ANSWER | AUTHORITY |
|---|---|---|---|---|
| ns9.hostmar.com | 200.58.97.2 | NOERROR | 0 | 2 registros NS |
| ns10.hostmar.com | 200.58.96.2 | NOERROR | 0 | 2 registros NS |

Comandos sanitizados ejecutados:

```powershell
Resolve-DnsName ns9.hostmar.com -Type A -DnsOnly
Resolve-DnsName ns10.hostmar.com -Type A -DnsOnly
nslookup -debug -norecurse -type=NS geoguide.getcom.pe 200.58.97.2
nslookup -debug -norecurse -type=NS geoguide.getcom.pe 200.58.96.2
```

Ambas consultas NS devolvieron exactamente el mismo conjunto en AUTHORITY:

```text
geoguide.getcom.pe. 14400 IN NS ns1.desec.io.
geoguide.getcom.pe. 14400 IN NS ns2.desec.org.
```

La consulta inicial con `Resolve-DnsName -Type NS -NoRecursion -DnsOnly` informó
error de servidor en ambos parent. No se tomó ese mensaje como evidencia de cierre:
la consulta directa posterior con `nslookup -debug` permitió verificar la respuesta
NOERROR y los registros de delegación en AUTHORITY. El NOERROR de la consulta PTR
auxiliar de nslookup no se utiliza como prueba de la delegación; la evidencia es la
consulta NS de `geoguide.getcom.pe`.

```text
HISTORICAL_INCIDENT = YES
CURRENT_STATUS = RESOLVED_WITH_EVIDENCE
PARENT_DELEGATION_NS9 = PASS
PARENT_DELEGATION_NS10 = PASS
PARENT_DELEGATION_INCIDENT = RESOLVED_WITH_EVIDENCE
PARENT_DELEGATION_RISK = CLOSED
PARENT_DELEGATION_P8_IMPACT = NONE
```

La decisión sigue el criterio explícito del gate: ambos parent entregan exactamente
los dos NS esperados. No certifica la salud de todos los servicios ni sustituye
validaciones futuras del runtime. No se modificaron DNS/NS ni se ejecutaron ACME,
renewal, NAT o firewall. La evidencia histórica de P7 conserva el incidente abierto
en su momento; esta sección define el estado posterior.

## Frontera del siguiente gate

El siguiente gate de gobierno, tras validar e integrar esta reconciliación, es
**P8.0 Scope / Contract / Entry Governance**. Allí deberán decidirse alcance y campos
POI, necesidad de API/backend, filtros locales/remotos, estados vacío/error, entorno
development/validation, impacto de tiles, criterios P8-AC, validaciones, Android
físico si corresponde y exclusiones. No se resuelven esas decisiones aquí.

```text
AUTONOMOUS_EXECUTION = PAUSED_BEFORE_P8_0_SCOPE_CONTRACT_ENTRY
```

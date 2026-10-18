# UI-2.2 — Checklist de sesión física futura

**PROPUESTA. NO EJECUTAR AHORA.** Fecha de preparación: 2026-10-18.
[Protocolo](UI-2.2-Physical-Validation-Protocol-Proposal.md) · [Matriz](UI-2.2-Physical-Validation-Traceability-Matrix.md) · [Registro de resultados](UI-2.2-Physical-Validation-Results-Template.md).

Todos los cuadros están sin marcar intencionadamente. Este documento no acredita pasos ejecutados.
Los comandos ADB siguientes son instrucciones futuras, supeditadas a G2–G4, y no se ejecutaron al redactarlos.
No ejecutar bloques completos por copiar/pegar: cada bloque corresponde a un gate y operación distinta.

## 0. Aprobación y preparación local — G1 / PHY-01

- [ ] Responsable aprueba revisión exacta del protocolo y lista de casos/subcasos; registrar fecha, alcance y referencia.
- [ ] Confirmar que UI-2.1 merge 083239649c86dd9efd9e0050dd3c955ae574b12a sigue integrado; reconciliar avances compatibles antes de elegir APK.
- [ ] Identificar APK candidato, fuente, perfil, hash y endpoint; no recompilar ni actualizar SDK por conveniencia.
- [ ] Identificar copia local existente y necesidad de conservarla; ninguna instalación/borrado se asume inocua.
- [ ] Reservar entorno estacionario, operador y ventana; segunda sesión si se desea TTL natural de 24 h.
- [ ] Aprobar datos públicos/ruta/categorías; no usar domicilios ni ubicación personal.
- [ ] Designar carpeta privada fuera del repositorio para evidencia física; ninguna subida automática.
- [ ] Abrir plantilla: ningún resultado iniciado en PASS; fecha/hora de ejecución vacías hasta realizarlo.

Lectura estática futura sin dispositivo; comprobar rutas existentes y sustituir solo candidato aprobado:

```powershell
$apk = 'D:\Codex\worktrees\GeoGuide-AI\ui2-implementation\mobile\build\app\outputs\flutter-apk\app-debug.apk'
Get-Item -LiteralPath $apk | Select-Object Length
Get-FileHash -LiteralPath $apk -Algorithm SHA256
$aapt = 'C:\Users\CC_Laptop\AppData\Local\Android\Sdk\build-tools\36.0.0\aapt.exe'
& $aapt dump badging $apk
```

Debug esperado: 635ab1225fe54b3a079196df5b87dd5cf1431966130f81195b386c9cffd92055.
Release alternativo, solo aprobado explícitamente: 88b4ae4da816ee2650f6e9b88d32a52511f8e4ce7d72af44e8e85a3af111fa3a.
Ambos package com.geoguideai.geoguide_ai, versionName 1.0.0, versionCode 1, minSdk24/target36.
Verificar firma con apksigner existente si se dispone; no buscar/instalar herramienta nueva durante sesión.
Si falta procedencia verificable o difiere hash, parar antes de conexión/instalación.

## 1. Conexión e identificación — G2 / PHY-02

- [ ] G2 concedido específicamente; no inferirlo de G1.
- [ ] Anotar ajustes originales antes de USB: depuración, fuente, TalkBack, orientación, red, permisos, ubicación, estado de sesiones.
- [ ] Operador conecta y habilita/autoriza depuración solo dentro del alcance aprobado.
- [ ] El operador identifica físicamente el HONOR autorizado y entrega su serial al ejecutor solo de forma privada; usar alias en reportes. No enumerar ni inspeccionar otros dispositivos.
- [ ] No ejecutar comandos exploratorios ni abrir shell interactiva. Usar únicamente las consultas específicas de compatibilidad enumeradas aquí.

**Solo en la futura sesión autorizada:**

```powershell
$adb = 'C:\Users\CC_Laptop\AppData\Local\Android\Sdk\platform-tools\adb.exe'
$serial = '<serial privado proporcionado por el operador para el alias autorizado>'
& $adb -s $serial get-state
& $adb -s $serial shell getprop ro.product.manufacturer
& $adb -s $serial shell getprop ro.product.model
& $adb -s $serial shell getprop ro.build.version.release
& $adb -s $serial shell getprop ro.build.version.sdk
& $adb -s $serial shell getprop ro.product.cpu.abilist
& $adb -s $serial shell wm size
& $adb -s $serial shell wm density
```

wm size/density sin argumento son lecturas; no usar argumentos para cambiar tamaño/densidad.
Registrar valores físicos y overrides si ya existían, sin alterarlos.
HONOR/LLY-NX3/Android16/API36 son antecedentes, no lectura actual; arm64/1080×2412/408dpi pendientes.
No ejecutar flutter devices como paso alternativo.

## 2. Instalación y arranque — G3 / PHY-03–04

- [ ] No hay GPS/B1/voz activo ni operación pendiente; si lo hay, el responsable resuelve el entorno antes de probar.
- [ ] G3 identifica hash, perfil y método de actualización; registrar autorización y política de datos.
- [ ] Comparar firma/versionCode con instalación existente, por herramienta local y datos autorizados.
- [ ] Firma incompatible/downgrade: STOP; no desinstalar, pm clear ni borrar caché para resolverlo.
- [ ] Ejecutar solo actualización compatible aprobada, sin flags de downgrade ni concesión automática de permisos.

**Únicamente tras G3:**

```powershell
& $adb -s $serial install -r $apk
```

- [ ] Registrar salida real y hora; no asumir conservación de datos por -r.
- [ ] Operador abre GeoGuide AI manualmente; verificar shell, iconos, ausencia de DEBUG y estabilidad observada.
- [ ] Un permiso inesperado no se acepta: detener y registrar.
- [ ] Confirmar estado local autorizado; no exportar DB ni probar respaldos del usuario.

## 3. Operaciones y capturas — G4

- [ ] G4 enumera cambios permitidos: red, texto, orientación, TalkBack, capturas/logs y copia offline.
- [ ] Permisos/ubicación no necesarios para extremos por mapa: mantener estado previo.
- [ ] Si un subcaso exige un cambio no aprobado, dejarlo bloqueado; no pedir aprobación por cada toque ordinario ya autorizado.
- [ ] Borrado de copia requiere consentimiento adicional específico y datos desechables.
- [ ] Audio/vídeo no se autorizan por aprobar una captura estática. Acordar cada medio.
- [ ] No capturar notificaciones, ubicaciones sensibles, tokens o seriales; revisar la captura mientras Rutea está en primer plano. Si aparece contenido ajeno, no conservarla.
- [ ] Para fallos, recoger solo trazas acotadas al proceso GeoGuide AI/Rutea y saneadas si se autorizó; no volcar logcat completo, bugreport ni borrar logs existentes.
- [ ] Identificar cada evidencia por tipo, caso, alias de sesión, fecha/hora y paso; guardar privadamente.

## 4. Orden operativo de casos

| Bloque | Casos | Control de salida |
| --- | --- | --- |
| Mapa | PHY-05–08 | Tiles/ruta/atribución reales y categoría/estado observados; lo ausente queda pendiente |
| POIs | PHY-09–12 | IDs y campos cotejados con mismo snapshot real; no datos fabricados |
| Filtro local | PHY-13–18 | Variantes, orden, continuidad y limpieza anotados; red observada con límites explícitos |
| I01 | PHY-19–21 | Elección explícita; B1 activo no se inicia y queda complementado por tests |
| Offline | PHY-22–26 | Solo copia desechable consentida; cambios de red/restauración registrados |
| Accesibilidad | PHY-27–32 | TalkBack real, texto/orientación/estados y límites de medición registrados |
| Regresión | PHY-33–36 | Contexto, efectos no solicitados, Driving opcional y restauración |

- [ ] Usar pasos y resultados del catálogo, no esta tabla como sustituto.
- [ ] Distinguir vacío local de backend y copia cached de online.
- [ ] Registrar orden/IDs mediante ficha privada; no exponer UUID en UI/capturas públicas.
- [ ] No crear corredor/foto/POI sintético en backend para suplir variante ausente.
- [ ] Para PHY-16/25 esperar tiempo natural desde recepción original; no cambiar hora, DB ni recapturar.
- [ ] Para PHY-18 el responsable de logs autoriza solo lectura de ventana existente y datos redactados.
- [ ] Establecer control positivo de request y ventanas de escritura. Ausencia de solicitudes recibidas no demuestra cero intentos cliente.
- [ ] Sin observabilidad suficiente, dejar componente físico de red bloqueado y citar spy test como COVERED_AUTOMATED.
- [ ] No introducir proxy, certificados, monitorización nueva ni cambios de logging.
- [ ] Si se desea PHY-35, verificar autorización explícita para Driving reducido manual y ausencia de GPS/voz antes de entrar.
- [ ] No arrancar B1, diagnóstico CEFI, seguimiento, micrófono o conducción real para ampliar la cobertura.

## 5. TalkBack, fuente y orientación — PHY-27–32

- [ ] Antes de activar, el operador identifica Ajustes → Accesibilidad → TalkBack según menú real del HONOR.
- [ ] Confirmar procedimiento de salida accesible en ese teléfono; no asumir atajo de volumen configurado.
- [ ] Activar por el operador bajo G4, recorrer foco con deslizamiento, activar con doble toque y desplazar con dos dedos.
- [ ] Leer tarjetas, distancia, placeholder, Preview/Detail, filtro, vacío/error/retry y cierre de lista.
- [ ] Transcribir anuncios reales y orden; mezcla de idioma de P9.3 es antecedente, no resultado actual.
- [ ] Si navegación resulta inaccesible, detener y restaurar mediante método acordado; no cambiar settings por ADB.
- [ ] Cambiar fuente solo al valor autorizado y anotar valor/preset real; no afirmar TextScaler2.0 sin equivalencia comprobada.
- [ ] Comprobar ambas orientaciones y teclado sin modificar densidad ni tamaño de pantalla.
- [ ] No declarar medidos los targets por tamaño del icono; límites de medición van al reporte.
- [ ] Restaurar TalkBack/fuente/orientación originales al acabar.

## 6. Restauración y revisión — G5 / PHY-36

- [ ] Salir de Driving explícitamente si fue autorizado; cerrar modales/teclado.
- [ ] Comprobar ausencia de sesiones iniciadas por prueba; no detener servicios ajenos.
- [ ] Restituir red, fuente, orientación, lector, permisos y ubicación solo donde hubo cambios aprobados.
- [ ] Copia de prueba borrada solo si se aprobó; datos borrados no tienen restauración garantizada.
- [ ] No hacer rollback/desinstalación automática como limpieza.
- [ ] Restituir depuración al estado original y desconectar USB de forma acordada.
- [ ] Completar resultado observado por subcaso, links privados/hashes, incidencias, pendientes y responsable.
- [ ] Revisar redacción de PII y permisos de acceso a evidencia; no publicar ni push/PR.
- [ ] No explorar almacenamiento, fotos, vídeos, documentos, descargas, contactos, mensajes, llamadas, correo, cuentas, portapapeles, notificaciones o datos de otras apps.
- [ ] No inspeccionar bases de datos ni datos privados ajenos a Rutea; no crear backups completos, extraer datos, instalar monitores/certificados/apps auxiliares, borrar datos, desinstalar o restablecer el dispositivo.
- [ ] Responsable confirma restauración o deja discrepancia con propietario y siguiente acción.
- [ ] Mantener UI-2 maestro NOT_AUTHORIZED y Production Readiness NOT_DECLARED.

## Detención

STOP_AND_REPORT ante artefacto incompatible, pérdida de datos posible, ampliación funcional,
permiso sensible no concedido, fallo material, necesidad de cambiar servicios/código o restauración insegura.
Un subcaso sin dato/tiempo/log queda pendiente/bloqueado y no detiene otros casos independientes aprobados.

**Estado actual:** protocolo pendiente de aprobación; ejecución física NOT_AUTHORIZED.
No se realizaron conexiones, instalaciones, ADB, ajustes del teléfono ni capturas durante la preparación.

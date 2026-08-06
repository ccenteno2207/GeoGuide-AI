# Límites Transaccionales

## Escrituras
Los casos de uso que modifican estado definen la transacción.

## Lecturas
Utilizar transacciones read-only cuando sea útil.

## Integraciones externas
Evitar mantener transacciones de base de datos abiertas mientras se espera una llamada
HTTP a un motor de routing u otro sistema externo.

## Discovery
El cálculo de ruta y la consulta espacial deben orquestarse sin una transacción larga.

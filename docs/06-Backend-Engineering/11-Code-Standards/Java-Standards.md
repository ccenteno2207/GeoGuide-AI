# Estándares Java

## Java
Java 21.

## Reglas
- constructor injection.
- `final` donde aporte claridad.
- evitar field injection.
- evitar métodos gigantes.
- nombres descriptivos.
- no usar Optional como campo de entidad.
- no retornar null en colecciones.
- records para DTO/value objects cuando resulte apropiado.
- enums para estados acotados.
- evitar utilidades estáticas con lógica de dominio.

## Lombok
No es obligatorio.
Si se utiliza, debe evitar ocultar comportamiento importante en entidades de dominio.

# Gestión de Estado

## Decisión recomendada
Riverpod.

## Razones
- composición y testabilidad;
- buen soporte de async state;
- no depende de BuildContext para acceder a estado;
- adecuado para separación por features.

## Estados típicos
- initial
- loading
- data
- empty
- error
- offline

## Regla
Evitar un único estado global gigantesco.

Cada feature debe poseer su estado y exponer únicamente lo necesario.

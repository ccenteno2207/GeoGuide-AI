# Handoff para Flutter / Codex

## Reglas
- Widgets reutilizables.
- ThemeData centralizado.
- Tokens, no valores visuales dispersos.
- Estados loading/empty/error en todas las pantallas con datos.
- Separar UI, estado y dominio.
- No incrustar lógica GIS en widgets.
- No incrustar URLs/secretos.
- Accesibilidad desde el primer componente.

## Orden de implementación
1. Theme/design tokens.
2. App shell/navigation.
3. Map screen.
4. Route inputs.
5. Route summary.
6. POI markers.
7. POI preview.
8. POI detail.
9. Driving mode.
10. Error/offline states.

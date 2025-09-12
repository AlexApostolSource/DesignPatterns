# Kata 2 — Pricing con switch (Frankfurter)

## Qué debes corregir

### OCP (Open/Closed)
- Eliminar el `switch` por tipo de promoción; nuevas reglas no deben modificar el calculador.

### Acoplamientos
- Extraer la conversión de divisa a un **puerto** (`ExchangeRateAPI`) asíncrono y cacheable.
- Evitar el bloqueo con semáforos → usar **async/await**.

### Determinismo y precisión
- Definir políticas de **redondeo** (banco/arriba/abajo) y aplicarlas de forma consistente.
- Manejar fallos de red (usar último tipo cacheado, degradar con mensaje).

### Testabilidad
- Inyectar reglas y tipo de cambio; tests con **dobles** que simulan FX.

---

## Patrones a aplicar

### Obligatorios
- **Decorator / Composite**: para componer `PricingRules` (pipeline de reglas).  
- **Adapter**: para Frankfurter (`ExchangeRateAPI`).

### Opcionales
- **Builder**: del pipeline (configuraciones por canal/país).  
- **Abstract Factory**: para entornos (prod/test) que suministran FX + redondeo.


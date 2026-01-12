# Kata 5 — DIP + Builder (Open-Meteo)

## Qué debes corregir

### DIP (Inversión de dependencias)
- Inyectar `HTTPClient`, `Clock`, `Logger` en el VM (nada de `URLSession`/`Date()` directos). check!

### Construcción segura de URL
- Usar un **Builder** para la query (valida lat/lon, hourly, zona horaria). check!

### Resiliencia
- Reintentos **exponenciales** ante 5xx y cancelables (no bloquear main thread).  
- Estados explícitos (`loading` / `success` / `error`) y errores tipados. check!

### Determinismo temporal
- Inyectar `TimeZone`/`Clock` para tests consistentes (ej. `Europe/Madrid`).

---

## Patrones a aplicar

### Obligatorios
- **Abstract Factory**: crear dependencias del VM (prod/test).  
- **Builder**: para la petición de pronóstico.  
- **Adapter**: para Open-Meteo (DTO → Dominio).

### Opcionales
- **Proxy**: cache corta para respuestas idénticas (misma query).


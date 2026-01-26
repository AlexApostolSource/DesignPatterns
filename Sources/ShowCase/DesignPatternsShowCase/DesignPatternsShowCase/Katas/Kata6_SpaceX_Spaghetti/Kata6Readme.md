# Kata 6 — SRP/DIP + Facade + Circuit Breaker (SpaceX)

## Qué debes corregir

### Unificación de acceso (SRP)
- Crear una sola fachada `SpaceXService` que oculte **v4/v5** y sus rutas.   Done
- Prohibir DTOs en la UI; exponer entidades de dominio homogéneas.


### Tolerancia a fallos
- Implementar **circuit breaker** (abre tras N fallos, half-open con prueba).  
- Manejar **rate-limit (429)** con backoff y cache de respuestas recientes.

### DIP / Testabilidad
- Inyectar `HTTPClient`, política de backoff, reloj y almacenamiento.

### Consistencia
- Mapeos únicos y testeados (v4/v5 → `Launch` de dominio).

---

## Patrones a aplicar

### Obligatorios
- **Facade**: punto único para la UI.  
- **Adapter**: normalizar diferencias v4/v5.   Done
- **Proxy**: circuit breaker + cache antitromba.

### Opcionales
- **Factory**: construir estrategias (fallback, backoff).  
- **Mapper**: (no GoF formal, pero útil) aislado y reutilizable.


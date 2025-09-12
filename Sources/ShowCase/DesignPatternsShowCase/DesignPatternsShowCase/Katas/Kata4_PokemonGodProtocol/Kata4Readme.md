# Kata 4 — ISP + Bridge (PokéAPI)

## Qué debes corregir

### ISP (Segregar interfaces)
- Dividir el protocolo “Dios” en capacidades finas: listado, detalle, sprites, analítica, cache.

### Desacoplar UI de datos
- La vista debe depender de **abstracciones mínimas** (no ver DTOs ni red).  
- Añadir **cancelación** y **backpressure** para prefetch de sprites.

### Estructura
- Mapeo **DTO → Dominio** con adaptadores dedicados.  
- Eliminar `print` para analítica; modelo de **puerto**.

---

## Patrones a aplicar

### Obligatorios
- **Bridge**: separar abstracción de UI (lista/grid/tarjeta) de implementación de datos (remoto/cache).  
- **Adapter**: normalizar respuestas (listado/detalle/sprites).

### Opcionales
- **Facade**: exponer un punto único a la UI.  
- **Flyweight**: cache de sprites (compartir bitmaps).


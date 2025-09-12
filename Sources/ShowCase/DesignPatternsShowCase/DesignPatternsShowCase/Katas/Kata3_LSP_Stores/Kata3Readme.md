
# Kata 3 — LSP en Stores (Open Library)

## Qué debes corregir

### LSP (Sustituibilidad)
- Eliminar la herencia `CachedBookStore : RemoteBookStore` que usa `fatalError`.
- Todo `BookStore` debe lanzar **errores tipados**, nunca crashear.

### Composición sobre herencia
- Implementar un **CacheProxy** que compone un fallback: `BookStore`.

### Robustez de caché
- Definir política de **expiración**, invalidación ante corrupción y modo offline.

### Rendimiento / UX
- Cargas perezosas de portadas (no bloquear búsqueda).

---

## Patrones a aplicar

### Obligatorios
- **Proxy**: caché en memoria/disco con fallback.  
- **Adapter**: para la API de Open Library (normaliza respuesta).

### Opcionales
- **Repository**: aislar dominio de almacenamiento.  
- **Factory Method**: para estrategias de expiración.

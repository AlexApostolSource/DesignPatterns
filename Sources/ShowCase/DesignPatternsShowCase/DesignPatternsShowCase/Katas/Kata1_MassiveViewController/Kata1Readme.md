# Kata 1 — MassiveViewController (JSONPlaceholder)

## Qué debes corregir

### Separación de responsabilidades (SRP)
- Eliminar del `UIViewController` toda la lógica de:
  - Red
  - Parseo
  - Persistencia
  - Analítica

### Arquitectura y acoplamientos
- Introducir un **ViewModel** que exponga estado observable (sin conocer `URLSession`/disco).
- Crear mapeos **DTO → Dominio** fuera de la UI.
- Implementar **persistencia atómica** y lectura segura (manejo de archivos corruptos).
- Soportar **paginación**, estado de carga y errores tipados.
- Asegurar mutaciones de UI en **main thread**.

### Testabilidad
- Inyección de dependencias para **API / Store / Analytics** usando **protocolos**.

---

## Patrones a aplicar

### Obligatorios
- **Facade**: `PostsServiceFacade` orquesta **API + Store + Analytics**.
- **Adapter**:  
  - `PostsAPI` (encapsula `URLSession`).  
  - `PostsStore` (encapsula FileSystem).

### Opcionales (recomendados)
- **Repository**: encapsula acceso a datos.
- **Factory Method / Abstract Factory**: para crear dependencias del `ViewModel`.
- **Observer**: (`Combine` / `@Published`).  
  > *Nota: no es GoF, pero encaja bien en este caso*.


# Kata: Iterator Pattern (GoF) — File System (árbol de carpetas/archivos)

Contexto
Gestionas un sistema de archivos en memoria (carpetas y ficheros). Los clientes necesitan recorrer el árbol en distintos órdenes:
- Depth-First (preorden)
- Breadth-First (anchura)
- Filtrado (por predicado: extensión, carpetas, etc.)

Código actual (malo)
- Duplica bucles de recorrido (DFS, BFS, filtros).
- Expone la representación interna (children).
- Mezcla algoritmo y presentación (print* dentro de la colección).
- Un “nextDepthFirst()” manual con snapshot e índice que se queda obsoleto si cambian los datos.

Objetivo
Refactoriza aplicando Iterator para:
- Encapsular el recorrido (no exponer children ni índices).
- Permitir múltiples estrategias: DFS, BFS y filtrado por predicado.
- Permitir múltiples iteradores independientes coexistiendo (snapshot o fail‑fast, tu elección).
- Mantener el mismo output observable del Playground.

Criterios de aceptación
- Interfaz clara de iteración (GoF o Sequence/IteratorProtocol):
  - Opción A (GoF): protocolos propios para iterador y colección con fábricas.
  - Opción B (Swift): conformidad a Sequence y IteratorProtocol.
  - Opción C: ambas.
- Implementa al menos:
  - DepthFirstIterator (preorden)
  - BreadthFirstIterator
  - FilteredIterator (acepta (FSNode) -> Bool)
- Cliente (ExplorerBad) migrado para no depender de print* ni arrays internos.

Restricciones
- No expongas la representación interna (children).
- No permitas que los clientes gestionen índices manualmente.
- Complejidad O(n) por recorrido.
- Mantén el mismo output del #Playground tras el refactor.

Sugerencias
1) Define tus protocolos (GoF) y/o adopta Sequence.
2) Implementa iteradores concretos (structs que capturen snapshot).
3) Haz que FileSystem produzca instancias de esos iteradores.
4) Refactoriza ExplorerBad para consumir iteradores y encargarse solo de imprimir.

Retos opcionales
- Fail‑Fast vs Snapshot.
- Iterador por niveles (devuelve grupos por nivel).
- Iterador por páginas (pageSize N).
- Componer filtros (and/or/not) con funciones.

Qué entregar
- Código refactorizado (en el mismo archivo o nuevos).
- (Opcional) Tests con Swift Testing para verificar órdenes de recorrido.

Cómo ejecutar
- Compila y ejecuta el #Playground de IteratorKata2_FileSystem.swift.
- Asegúrate de que el output antes y después del refactor es equivalente.

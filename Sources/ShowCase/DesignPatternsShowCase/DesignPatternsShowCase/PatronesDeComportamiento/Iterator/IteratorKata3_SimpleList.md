# Kata: Iterator Pattern (GoF) — To‑Do List (lista plana)

Contexto
Gestionas una lista de tareas (to‑do). Los clientes necesitan recorrer la colección en distintos órdenes:
- Normal (forward)
- Inverso (reverse)
- Filtrado (por predicado: prioridad, pendientes, etc.)

Código actual (malo)
- Duplica bucles de recorrido (forward, reverse, filtros).
- Mezcla algoritmo y presentación (print* dentro de la colección).
- Un método next() manual con índice que obliga al cliente a conocer detalles internos.

Objetivo
Refactoriza aplicando Iterator para:
- Encapsular el recorrido (no exponer el array ni índices).
- Permitir múltiples estrategias: forward, reverse y filtrado por predicado.
- Permitir múltiples iteradores independientes coexistiendo (snapshot o fail‑fast, tu elección).
- Mantener el mismo output observable del Playground.

Criterios de aceptación
- Interfaz clara de iteración (GoF o Sequence/IteratorProtocol):
  - Opción A (GoF): protocolos propios para iterador y colección con fábricas.
  - Opción B (Swift): conformidad a Sequence y IteratorProtocol.
  - Opción C: ambas.
- Implementa al menos:
  - ForwardIterator
  - ReverseIterator
  - FilteredIterator (acepta (Task) -> Bool)
- Cliente (TodoConsoleBad) migrado para no depender de print* ni arrays internos.

Restricciones
- No expongas la representación interna (array).
- No permitas que los clientes gestionen índices manualmente.
- Complejidad O(n) por recorrido.
- Mantén el mismo output del #Playground tras el refactor.

Sugerencias
1) Define tus protocolos (GoF) y/o adopta Sequence.
2) Implementa iteradores concretos (structs que capturen snapshot).
3) Haz que TodoList produzca instancias de esos iteradores.
4) Refactoriza TodoConsoleBad para consumir iteradores y encargarse solo de imprimir.

Retos opcionales
- Fail‑Fast vs Snapshot.
- Iterador por páginas (pageSize N).
- Componer filtros (and/or/not) con funciones.

Qué entregar
- Código refactorizado (en el mismo archivo o nuevos).
- (Opcional) Tests con Swift Testing para verificar órdenes de recorrido y filtrado.

Cómo ejecutar
- Compila y ejecuta el #Playground de IteratorKata3_SimpleList.swift.
- Asegúrate de que el output antes y después del refactor es equivalente.

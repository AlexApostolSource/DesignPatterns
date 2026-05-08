# Kata: Iterator Pattern (GoF) — Problema para refactorizar

Contexto
Tienes una biblioteca musical con canciones. Distintos clientes necesitan recorrer la colección en varios órdenes (normal, inverso) y con filtros. El código actual duplica lógica de recorrido, expone la representación interna y obliga a los clientes a gestionar índices manualmente.

Tu objetivo
Refactoriza el código de IteratorKata1.swift aplicando el patrón Iterator para:
- Encapsular el recorrido de la colección (no exponer el array ni índices).
- Permitir múltiples estrategias de iteración: forward, reverse y filtrado por predicado.
- Permitir múltiples iteradores independientes coexistiendo sobre la misma colección.
- Mantener el mismo comportamiento observable (mismo output del #Playground).

Punto de partida
- Archivo: IteratorKata1.swift (código “malo”).
- Dominio: Song y PlaylistBad.
- Cliente: DJConsoleBad, que usa métodos con bucles ad‑hoc.

Restricciones
- No expongas la representación interna de la colección a los clientes.
- No permitas que los clientes gestionen índices manuales.
- Complejidad de recorrer: O(n). Para el iterador filtrado, puedes prefiltrar o filtrar al vuelo, pero el cliente no debe saberlo.
- La salida del #Playground no debe cambiar tras la refactorización.

Criterios de aceptación
- Debe existir una interfaz de iteración clara (GoF):
  - Opción A (GoF puro): define tus propios protocolos Iterator y Aggregate/IterableCollection.
  - Opción B (idiomático Swift): haz que la colección adopte Sequence y define un IteratorProtocol concreto.
  - Opción C: ambas (GoF + Sequence) para comparar.
- Implementa al menos:
  - ForwardIterator
  - ReverseIterator
  - FilteredIterator (acepta un predicado (Song) -> Bool)
- DJConsoleBad debe migrar para no depender de índices ni del array interno.
- La colección no debe exponer el almacenamiento interno ni métodos de recorrido “ad‑hoc”.

Pasos sugeridos
1) Define tus protocolos:
   - Iterator (next(), hasNext/reset si usas GoF).
   - Aggregate/IterableCollection (fábricas de iteradores).
2) Implementa ForwardIterator, ReverseIterator y FilteredIterator.
3) Haz que PlaylistBad (renómbrala a Playlist) produzca instancias de esos iteradores.
4) Refactoriza DJConsoleBad para que use los iteradores y no los bucles internos de Playlist.
5) Mantén el #Playground y verifica que el output sea el mismo.

Retos opcionales (Nice-to-have)
- SnapshotIterator vs Fail-Fast: decide si tus iteradores capturan una instantánea o detectan modificaciones concurrentes.
- ZigZagIterator: si tuvieras múltiples listas, alterna elementos de cada una.
- Conformidad a Sequence y uso de for-in idiomático.
- Iterador por páginas (pageSize N).

Hints
- Si usas GoF, evita colisionar con IteratorProtocol de Swift usando nombres como GofIterator.
- Si usas Sequence, recuerda que makeIterator() debe devolver un IteratorProtocol por valor.
- Para FilteredIterator, puedes construir un array filtrado en el init (simple) o aplicar el predicado al vuelo (lazy).

Qué entregar
- Código refactorizado (puede ser en el mismo archivo o en nuevos).
- No subas la solución al .md (este archivo solo describe el problema y los criterios).
- (Opcional) Pruebas con Swift Testing que verifiquen los recorridos.

Cómo ejecutar
- Compila y ejecuta el #Playground del archivo IteratorKata1.swift.
- Asegúrate de que el output antes y después del refactor es equivalente.


Resumen corto: con el código pegado estás todavía en el punto de partida “malo”. Apenas cumples requisitos del kata. Detalle por puntos:

Objetivo del refactor
• Encapsular el recorrido (no array ni índices)
   • Parcial. No expones el array al cliente, y DJConsoleBad no maneja índices; pero la colección expone métodos de recorrido ad‑hoc que mezclan algoritmo y presentación (printAll/printReverse/printByGenre/printShuffled) y no hay una interfaz de iteración clara.
• Múltiples estrategias de iteración (forward, reverse, filtrado por predicado)
   • No. Tienes métodos y clases con esos nombres, pero no son iteradores reales ni comparten una interfaz común. FilteredIterator no itera (devuelve arrays/mezcla shuffle+limit) y Reverse no existe (PreviousIterator está roto).
• Múltiples iteradores independientes coexistiendo
   • No. PlaylistBad crea un único ForwardIterator y un único PreviousIterator en el init, capturando una instantánea del array. Si haces add(), esos iteradores no ven los cambios.
• Mantener el mismo output del #Playground tras el refactor
   • N/A aún (todavía no hay refactor). El output actual es el del punto de partida.

Criterios de aceptación
• Interfaz de iteración clara (GoF o Sequence/IteratorProtocol)
   • No. Tu protocolo Iterator no es GoF ni idiomático Swift; mezcla operaciones de impresión con next/previous.
• Implementaciones mínimas
   • ForwardIterator: existe pero no conforma a ningún protocolo de iteración y es snapshot.
   • ReverseIterator: no existe; PreviousIterator no recorre hacia atrás (empieza en 0, devuelve solo el primer elemento y luego nil).
   • FilteredIterator: no itera; filtra devolviendo [Song] o baraja+limita+devuelve [Song].
• DJConsoleBad migrada a iteradores
   • No. Sigue llamando a métodos ad‑hoc de PlaylistBad (printAll/printReverse/printByGenre/printShuffled) y a next() sin contrato claro.
• La colección no expone almacenamiento interno ni métodos de recorrido ad‑hoc
   • Parcial. No expones el array, pero sí expones métodos de recorrido/impresión ad‑hoc, justo lo que hay que eliminar.

Restricciones
• “No permitas que los clientes gestionen índices manualmente”
   • Cumplido en el uso actual (DJConsoleBad no maneja índices), pero la API next/previous no está definida dentro de una interfaz de iterador correcta y PreviousIterator está mal.
• Complejidad O(n)
   • Lo actual es O(n), pero este punto aplica al diseño final.

Problemas concretos a corregir
• PreviousIterator empieza en 0; solo devuelve el primer elemento y luego nil.
• Forward/Previous se construyen con el array del init; si añades canciones, next/previous no reflejan cambios.
• FilteredIterator no es un iterador y mezcla responsabilidades (algoritmo + presentación).
• El protocolo Iterator colisiona conceptualmente con IteratorProtocol de Swift y no sigue GoF.

Qué faltaría para cumplir
• Definir una interfaz de iterador clara:
   • Opción A (GoF): p.ej. GofIterator { mutating func next() -> Song? } y una Aggregate/IterableCollection con fábricas de iteradores.
   • Opción B (Swift): Playlist adopta Sequence y define un IteratorProtocol concreto; además secuencias/iteradores para reverse y filtered (por predicado).
• Implementar ForwardSongIterator, ReverseSongIterator y FilteredSongIterator (con (Song) -> Bool).
• Renombrar PlaylistBad a Playlist, ocultar storage, eliminar métodos print*/filter ad‑hoc y exponer fábricas de iteradores/secuencias.
• Refactorizar DJConsoleBad para consumir esos iteradores/secuencias y encargarse solo de imprimir.

Si quieres, te preparo el refactor completo siguiendo Opción A, B o ambas y manteniendo el mismo output.

# Kata: State Pattern (GoF) — Problema para refactorizar

Contexto
Tienes un reproductor multimedia con una lista de pistas. El reproductor puede estar en distintos estados (stopped, playing, paused, locked) y el usuario puede ejecutar acciones (play, pause, stop, next, previous, lock, unlock).

Código actual (malo)
- Mezcla algoritmo y presentación: los métodos del reproductor imprimen directamente.
- Duplicación de lógica: en cada acción se comprueba si está locked, si la lista está vacía, etc.
- Transiciones de estado dispersas: cada método hace if/switch sobre el estado y decide qué hacer.
- Acoplamiento fuerte al estado interno; el cliente conoce demasiado.

Objetivo
Refactoriza aplicando el patrón State para:
- Encapsular el comportamiento de cada estado en tipos concretos.
- Eliminar los if/switch por estado en el contexto.
- Centralizar las transiciones de estado dentro de los estados concretos.
- Mantener el mismo comportamiento observable (mismo output del #Playground).

Criterios de aceptación
- Interfaz clara de estado:
  - Protocol PlayerState con operaciones: play(), pause(), stop(), next(), previous(), lock(), unlock() (firma sugerida).
  - Estados concretos: StoppedState, PlayingState, PausedState, LockedState.
- Contexto (MediaPlayer) que:
  - Mantiene la lista y el índice, pero delega la lógica a PlayerState.
  - No hace if/switch por estado; solo invoca al estado actual.
- Múltiples estados deben poder coexistir en memoria (no singletons globales con estado mutable compartido).
- Mantén el mismo output del #Playground tras el refactor.

Restricciones
- No expongas el estado interno al cliente (ni enum ni flags).
- Complejidad por acción: O(1) (no reproceses la lista completa).
- La lista puede estar vacía; maneja los casos sin crashear.
- No metas lógica de UI en el reproductor; si decides mover los prints al “cliente” (RemoteControl), respeta el mismo texto del Playground.

Pasos sugeridos
1) Crea el protocolo PlayerState con las operaciones necesarias.
2) Implementa los estados concretos con referencias débiles/seguras al contexto para cambiar de estado.
3) Refactoriza MediaPlayer para delegar todo en PlayerState.
4) Opcional: mueve la responsabilidad de imprimir al “cliente” RemoteControl (si lo haces, mantén el mismo output).
5) Verifica que el #Playground imprime lo mismo que antes.

Retos opcionales
- Añade “Repeat All” o “Shuffle” como estrategia separada (Strategy) combinable con State.
- Añade “Seek” (adelantar/retroceder) y decide qué estados lo permiten.
- Añade Memento para “volver” a la pista anterior tras un error.

Qué entregar
- Código refactorizado (puede ser en el mismo archivo o en nuevos).
- (Opcional) Pruebas con Swift Testing que verifiquen las transiciones.

Cómo ejecutar
- Compila y ejecuta el #Playground del archivo StateKata1.swift.
- Asegúrate de que el output antes y después del refactor es equivalente.

Objetivos de la Kata
Para refactorizar este código utilizando el patrón Command, debes cumplir con los siguientes requisitos:

Definir un protocolo Command: Debe contener, como mínimo, los métodos execute() y undo().

Crear comandos concretos: Implementa clases o estructuras (por ejemplo, AppendTextCommand y DeleteTextCommand) que conformen el protocolo Command. Estos comandos deben encapsular el receptor (TextEditor) y los parámetros necesarios para ejecutar y revertir la acción.

Refactorizar el EditorInterface (Invoker): Modifica la clase para que, en lugar de llamar directamente a los métodos del TextEditor, instancie el comando correspondiente, lo ejecute y lo guarde en una pila (stack) o historial.

Implementar la función undo(): El invoker debe poder extraer el último comando del historial y ejecutar su método undo().

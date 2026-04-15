//
//  CommnadoKata1.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 11/3/26.
//


import Foundation
import Playgrounds

protocol Command {
	func execute()
	func undo()
}

class DeleteTextCommand: Command {
	private let editor: TextEditor
	private let count: Int
	private var deletedText: String = ""

	init(editor: TextEditor, count: Int) {
		self.editor = editor
		self.count = count
	}

	func execute() {
		let safeCount = min(count, editor.content.count)
		deletedText = String(editor.content.suffix(safeCount))
		editor.deleteLast(charactersCount: count)
	}

	func undo() {
		editor.content.append(deletedText)
	}
}

class AppendTextCommando: Command {
	private let editor: TextEditor
	private let toAppend: String
	
	init(editor: TextEditor, toAppend: String) {
		self.editor = editor
		self.toAppend = toAppend
	}
	
	func execute() {
		editor.append(text: toAppend)
	}

	func undo() {
		editor.deleteLast(charactersCount: toAppend.count)
	}
}

// The receiver object containing the core logic
class TextEditor {
	var content: String = ""

	func append(text toAppend: String) {
		content += toAppend
		print("Current text: \(content)")
	}

	func deleteLast(charactersCount count: Int) {
		let safeCount = min(count, content.count)
		let index = content.index(content.endIndex, offsetBy: -safeCount)
		content.removeSubrange(index..<content.endIndex)
		print("Current text: \(content)")
	}
}

final class CommandHistory {
	private var history: [Command] = []

	func add(_ command: Command) {
		history.append(command)
	}
	
	func undoLast() {
		guard let command = history.popLast() else { return }
		command.undo()
	}
}

// The invoker object directly coupled to the receiver
class EditorInterface {
	private let commandHistory: CommandHistory = CommandHistory()
	private let editor = TextEditor()

	func userTyped(text: String) {
		// Direct execution, no record kept for undo functionality
		let command = AppendTextCommando(editor: editor, toAppend: text)
		command.execute()
		commandHistory.add(command)
	}

	func userPressedBackspace(count: Int) {
		// Direct execution
		let command = DeleteTextCommand(editor: editor, count: count)
		command.execute()
		commandHistory.add(command)
	}

	func undo() {
		commandHistory.undoLast()
	}

	// TODO: Implement an 'undo' functionality here
}

#Playground {
	// Execution example
	let interface = EditorInterface()
	interface.userTyped(text: "Hello ")
	interface.userTyped(text: "World!")
	interface.userPressedBackspace(count: 6)
	// Undo last deletion -> restores "World!"
	interface.undo()
}

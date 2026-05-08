//
//  IteratorKata2_FileSystem.swift
//  DesignPatternsShowCase
//
//  Kata de Iterator (punto de partida "malo") — File System.
//  Objetivo: eliminar duplicación, ocultar representación interna y permitir
//  DFS, BFS y filtrado con iteradores reales.
//
//  Instrucciones en IteratorKata2_FileSystem.md
//

import Foundation
import Playgrounds

// MARK: - Dominio

/// Nodo del árbol: carpeta (children) o fichero (ext)
final class FileNode: CustomStringConvertible {
	let name: String
	let ext: String?            // nil => carpeta; no nil => fichero
	var children: [FileNode]    // BAD: expuesto públicamente

	var isFolder: Bool { ext == nil }

	init(folder name: String, children: [FileNode] = []) {
		self.name = name
		self.ext = nil
		self.children = children
	}

	init(file name: String, ext: String) {
		self.name = name
		self.ext = ext
		self.children = []
	}

	var description: String {
		if let ext {
			return "📄 \(name).\(ext)"
		} else {
			return "📁 \(name)"
		}
	}
}

// MARK: - Código "malo" (sin Iterator)

/// Problemas intencionados:
/// - Expone representación interna (children).
/// - Duplica bucles (DFS, BFS, filtro).
/// - Mezcla algoritmo y presentación (print*).
/// - nextDepthFirst() snapshot + índice que queda obsoleto.
final class FileSystemBad {

	let root: FileNode                    // BAD: expuesto
	private var dfsIndex: Int = 0         // BAD: índice manual
	private let dfsSnapshot: [FileNode]   // BAD: snapshot obsoleto si cambian datos

	init(root: FileNode) {
		self.root = root
		self.dfsSnapshot = FileSystemBad.flattenDFS(root)
	}

	// BAD: bucle de impresión DFS ad‑hoc (preorden + indentación)
	func printDepthFirst() {
		func dfs(_ node: FileNode, indent: String) {
			print("\(indent)\(node)")
			if node.isFolder {
				for child in node.children {
					dfs(child, indent: indent + "  ")
				}
			}
		}
		dfs(root, indent: "")
	}

	// BAD: bucle de impresión BFS ad‑hoc
	func printBreadthFirst() {
		var queue: [FileNode] = [root]
		while !queue.isEmpty {
			let node = queue.removeFirst()
			print(node.description)
			if node.isFolder {
				queue.append(contentsOf: node.children)
			}
		}
	}

	// BAD: otro bucle con filtro específico (por extensión)
	func printByExtension(_ ext: String) {
		let all = FileSystemBad.flattenDFS(root)
		for n in all where !n.isFolder && n.ext == ext {
			print(n.description)
		}
	}

	// BAD: navegación manual con snapshot
	func nextDepthFirst() -> FileNode? {
		guard dfsIndex < dfsSnapshot.count else { return nil }
		defer { dfsIndex += 1 }
		return dfsSnapshot[dfsIndex]
	}

	// Utilidad interna (también duplicada en printByExtension)
	private static func flattenDFS(_ node: FileNode) -> [FileNode] {
		var out: [FileNode] = [node]
		if node.isFolder {
			for c in node.children {
				out.append(contentsOf: flattenDFS(c))
			}
		}
		return out
	}
}

// Cliente “malo”: usa métodos ad‑hoc y representación interna
final class ExplorerBad {

	func listDepthFirst(fs: FileSystemBad) {
		print("— DFS (preorder) —")
		fs.printDepthFirst()
	}

	func listBreadthFirst(fs: FileSystemBad) {
		print("\n— BFS (breadth-first) —")
		fs.printBreadthFirst()
	}

	func listByExtension(_ ext: String, fs: FileSystemBad) {
		print("\n— Filter: .\(ext) —")
		fs.printByExtension(ext)
	}

	func browseNextDFS(fs: FileSystemBad) {
		print("\n— Manual next() over DFS snapshot —")
		let node = fs.nextDepthFirst()
		print("next: \(node?.description ?? "nil")")
	}
}

// MARK: - Demo (debe seguir funcionando tras el refactor)

#Playground {
	// Árbol de ejemplo:
	// Projects
	// ├─ DesignPatterns
	// │  ├─ IteratorKata.swift
	// │  └─ README.md
	// ├─ Images
	// │  ├─ logo.png
	// │  └─ diagram.pdf
	// └─ Notes.txt

	let tree = FileNode(
		folder: "Projects",
		children: [
			FileNode(
				folder: "DesignPatterns",
				children: [
					FileNode(file: "IteratorKata", ext: "swift"),
					FileNode(file: "README", ext: "md")
				]
			),
			FileNode(
				folder: "Images",
				children: [
					FileNode(file: "logo", ext: "png"),
					FileNode(file: "diagram", ext: "pdf")
				]
			),
			FileNode(file: "Notes", ext: "txt")
		]
	)

	let fs = FileSystemBad(root: tree)
	let explorer = ExplorerBad()

	explorer.listDepthFirst(fs: fs)
	explorer.listBreadthFirst(fs: fs)
	explorer.listByExtension("swift", fs: fs)
	explorer.browseNextDFS(fs: fs)
}

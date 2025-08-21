//
//  Prototype.swift
//  DesignPatterns
//
//  Created by Alex.personal on 21/8/25.
//

import Foundation

/* Creas copias instancias nuevas a partir de una instancia, con estados diferentes esto lo hace mucho swiftUI
Solo util en objetos de tipo de referencia porque re aseguras de que modificas la copia y no la referencia.
 */

class NetworkRequestConfigClass {
    private let timeout: Int
    private let headers: [String: String]
    private var path: String

    required init(timeout: Int, headers: [String: String], path: String = "") {
        self.timeout = timeout
        self.headers = headers
        self.path = path
    }

    func clone() -> Self {
        return .init(timeout: timeout, headers: headers, path: path)
    }

    func with(path: String) -> Self {
        return .init(timeout: timeout, headers: headers, path: path)
    }
}

struct NetworkRequestConfigStruct {
    private let timeout: Int
    private let headers: [String: String]
    private var path: String

    init(timeout: Int, headers: [String: String], path: String = "") {
        self.timeout = timeout
        self.headers = headers
        self.path = path
    }
    func with(path: String) -> NetworkRequestConfigStruct {
        return Self(timeout: timeout, headers: headers, path: path)
    }
}

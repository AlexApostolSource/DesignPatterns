//
//  PrototypeTests.swift
//  DesignPatterns
//
//  Created by Alex.personal on 21/8/25.
//
import XCTest
@testable import DesignPatterns

class PrototypeRealWorld: XCTestCase {

    func testPrototypeRealWorld() {

        let config = NetworkRequestConfigClass(timeout: 30, headers: ["Content-Type": "application/json"])
        let config1 = config.with(path: "/api/v1/resource")
        let config2 = config.with(path: "/api/v2/resource")

        let configStruct = NetworkRequestConfigStruct(timeout: 30, headers: ["Content-Type": "application/json"])
        let configStruct1 = configStruct.with(path: "/api/v1/resource")
        let configStruct2 = configStruct.with(path: "/api/v2/resource")
    }
}

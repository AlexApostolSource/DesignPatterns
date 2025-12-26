//
//  Kata4_logger.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 26/12/25.
//

protocol Kata4LoggerUseCaseProtocol {
	func logEvent(_ name: Kata4Events, params: [String : Any])
}

struct Kata4LoggerUseCase: Kata4LoggerUseCaseProtocol {
	func logEvent(_ name: Kata4Events, params: [String : Any]) {
		print("LOG \(name.rawValue) \(params)")
	}
}

enum Kata4Events: String {
 case getDetail
 case getPokemonList
}

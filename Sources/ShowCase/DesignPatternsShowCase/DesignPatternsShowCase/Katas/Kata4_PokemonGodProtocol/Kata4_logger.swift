//
//  Kata4_logger.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 26/12/25.
//

import Foundation

struct Kata4LoggerUseCase: Kata4LoggerUseCaseProtocol {
	func logEvent(_ name: Kata4Events, params: [String : Any]) {
		print("LOG \(name.rawValue) \(params)")
	}
}

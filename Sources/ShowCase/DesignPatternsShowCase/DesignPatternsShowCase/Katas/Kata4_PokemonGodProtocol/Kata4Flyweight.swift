//
//  Kata4Flyweight.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 31/12/25.
//

import Foundation
import SwiftUI

final class FlywieghtImage {
	let image: Data

	init(image: Data) {
		self.image = image
	}
}

final class Kata4FlyweightUseCase {
	static let shared = Kata4FlyweightUseCase()
	private let cache: NSCache<NSString, FlywieghtImage> = .init()

	private init() {
		cache.totalCostLimit = 1024 * 1024 * 50
	}

	func add(image: FlywieghtImage, for key: NSString) {
		cache.setObject(image, forKey: key)
	}

	func get(for key: NSString) -> FlywieghtImage? {
		cache.object(forKey: key)
	}
}

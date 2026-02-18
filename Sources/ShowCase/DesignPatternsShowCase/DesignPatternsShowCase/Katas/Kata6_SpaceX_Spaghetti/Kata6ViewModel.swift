//
//  Kata6ViewModel.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 22/1/26.
//

import SwiftUI
import Combine

@Observable
final class Kata6ViewModel {
	private let launchDataProvider: Kata6LaunchDataProviderProtocol
	var spaceXLaunchData: [LaunchDomain] = []


	init(launchDataProvider: Kata6LaunchDataProviderProtocol) {
		self.launchDataProvider = launchDataProvider
	}

	func getData() async {
		do {
			self.spaceXLaunchData = try await launchDataProvider.getLaunchData()
		} catch {
			print(error)
		}
	}
}

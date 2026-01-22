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
	private let remoteDateSource: Kata6RemoteDataSourceProtocol
	var spaceXLaunchData: [Launch] = []


	init(remoteDateSource: Kata6RemoteDataSourceProtocol) {
		self.remoteDateSource = remoteDateSource
	}

	func getData() async {
		do {
			async let launchV5 = try await remoteDateSource.getLaunchV5()
			async let launchV4 = try await remoteDateSource.getLaunchV4()
			let data: [Launch] =  try await [launchV5, launchV4]
			self.spaceXLaunchData = data
		} catch {
			print(error)
		}
	}
}

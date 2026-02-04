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
	private let proxy: Kata6NetwokProxyProtocol
	var spaceXLaunchData: [LaunchDomain] = []


	init(proxy: Kata6NetwokProxyProtocol) {
		self.proxy = proxy
	}

	func getData() async {
		do {
			self.spaceXLaunchData = try await proxy.getLaunchData()
		} catch {
			print(error)
		}
	}
}

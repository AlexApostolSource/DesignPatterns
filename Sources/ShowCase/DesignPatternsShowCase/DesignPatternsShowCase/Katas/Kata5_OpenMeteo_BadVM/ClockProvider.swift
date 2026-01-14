//
//  ClockProvider.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 14/1/26.
//
import Foundation

protocol ClockProviderProtocol {
	var timeZone: String { get }
}

struct ClockProvider: ClockProviderProtocol {
	var timeZone: String {
		TimeZone.current.identifier
	}
}

//
//  RemoteDTOKata6.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 22/1/26.
//

import Foundation

// MARK: - Launch Model
struct Launch: Codable, Identifiable {
	// Critical: 'fairings' represents a structural divergence (null vs Object).
	// Must be optional to handle cases like JSON 1.
	let fairings: Fairings?

	let links: Links

	// Critical: 'success' varies between boolean and null.
	// Using a non-optional Bool will cause a decoding failure for JSON 2.
	let success: Bool?
	let upcoming: Bool?

	let rocket: String
	let details: String?

	// Arrays handle empty states naturally, no optionality needed on the container itself.
	let crew: [CrewMember]
	let ships: [String]
	let capsules: [String]
	let payloads: [String]
	let launchpad: String
	let flightNumber: Int
	let name: String
	let dateUtc: String
	let cores: [Core]
	let id: String

	enum CodingKeys: String, CodingKey {
		case fairings, links, rocket, success, details, crew, ships
		case capsules, payloads, launchpad, name, cores, id, upcoming
		case flightNumber = "flight_number"
		case dateUtc = "date_utc"
	}
}

// MARK: - Helper Structures
struct Fairings: Codable {
	let reused: Bool?
	let recoveryAttempt: Bool?
	let recovered: Bool?
	let ships: [String]

	enum CodingKeys: String, CodingKey {
		case reused, recovered, ships
		case recoveryAttempt = "recovery_attempt"
	}
}

struct Links: Codable {
	let patch: Patch
	let webcast: String
	// Other nested link structures...
}

struct Patch: Codable {
	let small: String?
	let large: String?
}

struct CrewMember: Codable {
	let crew: String
	let role: String
}

struct Core: Codable {
	let core: String
	let flight: Int
	let gridfins: Bool
	let legs: Bool
	let reused: Bool
	let landingAttempt: Bool?
	let landingSuccess: Bool?

	enum CodingKeys: String, CodingKey {
		case core, flight, gridfins, legs, reused
		case landingAttempt = "landing_attempt"
		case landingSuccess = "landing_success"
	}
}

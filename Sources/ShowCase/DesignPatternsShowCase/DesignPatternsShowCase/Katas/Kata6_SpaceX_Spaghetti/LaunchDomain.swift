//
//  LaunchDomain.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 26/1/26.
//

import Foundation

// MARK: - Domain Models

/// Represents the consolidated business logic for a Space Launch.
/// It abstracts away the JSON parsing details and provides strict typing.
struct LaunchDomain: Identifiable {
	let id: String
	let name: String
	let flightNumber: Int
	let date: Date

	// Critical: Collapsed 'upcoming' and 'success' DTO fields into a single state machine.
	let status: LaunchStatus

	let details: String?

	// References to other Aggregate Roots (IDs)
	let rocketId: String
	let launchpadId: String

	// Collections
	let crew: [CrewRole]
	let shipIds: [String]
	let capsuleIds: [String]
	let payloadIds: [String]

	// Nested Value Objects
	let links: LaunchLinks
	let fairings: FairingsRecovery?
	let cores: [BoosterCore]
}

/// Represents the mutually exclusive states of a mission.
enum LaunchStatus: Equatable {
	case scheduled
	case success
	case failure
	/// Handles cases where API data is inconsistent (e.g., historical launch with null success flag).
	case unknown
}

struct LaunchLinks {
	let patch: MissionPatch?
	let webcast: URL?
	// You can extend this with article, wikipedia, etc.
}

struct MissionPatch {
	let small: URL?
	let large: URL?
}

struct FairingsRecovery {
	let isReused: Bool
	let recoveryAttempted: Bool
	let recoverySuccessful: Bool
	let recoveryShipIds: [String]
}

struct CrewRole {
	let memberId: String // Mapped from 'crew' string in DTO
	let role: String
}

struct BoosterCore {
	let id: String
	let flightCount: Int
	let hasGridfins: Bool
	let hasLegs: Bool
	let isReused: Bool
	let landing: LandingOutcome
}

/// Encapsulates the complex logic of landing attempts/success from the DTO.
enum LandingOutcome: Equatable {
	case notAttempted
	case success
	case failure
	case unknown
}


protocol LaunchMapperType {
	func map(dto: Launch) -> LaunchDomain
}

// MARK: - Launch Mapper Implementation

struct LaunchMapper: LaunchMapperType {

	// Optimization: DateFormatters are expensive to create. We use a static instance.
	private static let isoFormatter: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return formatter
	}()

	/// transforms the Data Transfer Object (DTO) into a clean Domain Model.
	func map(dto: Launch) -> LaunchDomain {

		// 1. Date Transformation
		// If date parsing fails, we fallback to current date or handle error depending on business rules.
		// Here, we assume a safe fallback to prevent crash, but logging would be ideal.
		let launchDate = Self.isoFormatter.date(from: dto.dateUtc) ?? Date()

		// 2. Status Logic Consolidation
		let status: LaunchStatus
		if let upcoming = dto.upcoming, upcoming == true {
			status = .scheduled
		} else if let success = dto.success {
			status = success ? .success : .failure
		} else {
			status = .unknown
		}

		// 3. Nested Mapping
		return LaunchDomain(
			id: dto.id,
			name: dto.name,
			flightNumber: dto.flightNumber,
			date: launchDate,
			status: status,
			details: dto.details,
			rocketId: dto.rocket,
			launchpadId: dto.launchpad,
			crew: dto.crew.map { mapCrew(dto: $0) },
			shipIds: dto.ships,
			capsuleIds: dto.capsules,
			payloadIds: dto.payloads,
			links: mapLinks(dto: dto.links),
			fairings: mapFairings(dto: dto.fairings),
			cores: dto.cores.map { mapCore(dto: $0) }
		)
	}

	// MARK: - Private Helpers

	private func mapLinks(dto: Links) -> LaunchLinks {
		return LaunchLinks(
			patch: MissionPatch(
				small: URL(string: dto.patch.small ?? ""),
				large: URL(string: dto.patch.large ?? "")
			),
			webcast: URL(string: dto.webcast)
		)
	}

	private func mapFairings(dto: Fairings?) -> FairingsRecovery? {
		guard let dto = dto else { return nil }

		// Logic: If fields are nil, we assume false for booleans in this specific domain context
		return FairingsRecovery(
			isReused: dto.reused ?? false,
			recoveryAttempted: dto.recoveryAttempt ?? false,
			recoverySuccessful: dto.recovered ?? false,
			recoveryShipIds: dto.ships
		)
	}

	private func mapCrew(dto: CrewMember) -> CrewRole {
		return CrewRole(
			memberId: dto.crew,
			role: dto.role
		)
	}

	private func mapCore(dto: Core) -> BoosterCore {
		let landingOutcome: LandingOutcome

		// Logic to determine landing outcome based on attempt and success flags
		if let attempt = dto.landingAttempt, attempt == true {
			if let success = dto.landingSuccess {
				landingOutcome = success ? .success : .failure
			} else {
				landingOutcome = .unknown
			}
		} else {
			landingOutcome = .notAttempted
		}

		return BoosterCore(
			id: dto.core,
			flightCount: dto.flight,
			hasGridfins: dto.gridfins,
			hasLegs: dto.legs,
			isReused: dto.reused,
			landing: landingOutcome
		)
	}
}

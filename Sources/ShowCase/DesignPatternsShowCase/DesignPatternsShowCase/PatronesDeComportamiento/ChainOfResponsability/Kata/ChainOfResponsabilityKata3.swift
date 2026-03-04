//
//  ChainOfResponsabilityKata3.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 25/2/26.
//

// Models
struct AppStoreReceipt {
	let isFormatValid: Bool
	let isSignatureValid: Bool
	let isSubscriptionActive: Bool
	let isRegionSupported: Bool
}

class PurchaseValidator {

	// TODO: Refactor using Chain of Responsibility to decouple the validation steps.
	// Each step should halt the chain and return an error if validation fails.
	func validateReceipt(_ receipt: AppStoreReceipt) -> Bool {
		guard receipt.isFormatValid else {
			print("Validation failed: Invalid receipt format.")
			return false
		}

		guard receipt.isSignatureValid else {
			print("Validation failed: Cryptographic signature mismatch.")
			return false
		}

		guard receipt.isSubscriptionActive else {
			print("Validation failed: Subscription has expired.")
			return false
		}

		guard receipt.isRegionSupported else {
			print("Validation failed: Content not available in this region.")
			return false
		}

		print("Receipt successfully validated. Unlocking premium content.")
		return true
	}
}

import Foundation

protocol Kata4LoggerUseCaseProtocol {
	func logEvent(_ name: Kata4Events, params: [String : Any])
}

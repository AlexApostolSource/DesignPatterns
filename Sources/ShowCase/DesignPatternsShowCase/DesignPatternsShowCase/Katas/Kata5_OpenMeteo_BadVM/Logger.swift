//
//  Logger.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 14/1/26.
//
import OSLog

enum KataLoggerLevel {
	case error
	case info
	case debug
	case none
	case fault
	var description: String {
		switch self {
		case .error:
			return "error"
		case .info:
			return "info"
		case .debug:
			return "debug"
		case .none:
			return "none"
		case .fault:
			return "fault"
		}
	}
}
protocol KataLoggerProtocol {
	func log(level: KataLoggerLevel, message: String)
}

struct KataLogger: KataLoggerProtocol {
	private let subsystem: String
	private let category: String
	private let logger: Logger

	init(subsystem: String, category: String) {
		self.subsystem = subsystem
		self.category = category
		self.logger = Logger(subsystem: subsystem, category: category)
	}

	func log(level: KataLoggerLevel, message: String) {
		switch level {
		case .error:
			logger.log(level: .error,"\(level.description): \(message)")
		case .info:
			logger.log(level: .info,"\(level.description): \(message)")
		case .debug:
			logger.log(level: .debug,"\(level.description): \(message)")
		case .none:
			logger.log(level: .default,"\(level.description): \(message)")
		case .fault:
			logger.log(level: .fault,"\(level.description): \(message)")
		}
	}

}

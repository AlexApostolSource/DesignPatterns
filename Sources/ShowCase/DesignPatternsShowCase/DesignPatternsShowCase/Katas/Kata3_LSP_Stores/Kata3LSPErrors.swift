//
//  Kata3LSPErrors.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 2/10/25.
//

enum BookStoreError: Error {
    case networkError(underlyingError: Error)
    case cannotCreateDirectory(underlyingError: Error)
    case cannotCreateEntryURL
    case cannotWriteEntryToUrl(underlyingError: Error)
	case corruptedCache(underlyingError: Error?)
	case errorRetrievingLocalDataSourceEntry(underlyingError: Error)
	case errorInvalidationCache(underlyingError: Error?)
	case noData
}

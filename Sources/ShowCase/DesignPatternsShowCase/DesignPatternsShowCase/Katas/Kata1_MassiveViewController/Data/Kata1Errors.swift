//
//  Kata1Errors.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//


public enum Kata1Errors: Error {
    case requestFailed(underlyingError: Error)
    case failedFetchingLocalDataSourcePosts(underlyingError: Error)
    case failedFetchingRemoteDataSourcePosts(underlyingError: Error)
    case failedCodingPosts(underlyingError: Error)
    case failedWriteToDisk(underlyingError: Error)
    case failedReadFromDisk(underlyingError: Error)
    case failedDecodingPosts(underlyingError: Error)
}

//
//  Kata1Errors.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//


public enum Kata1Errors: Error {
    case requestFailed(underlyingError: Error)
}

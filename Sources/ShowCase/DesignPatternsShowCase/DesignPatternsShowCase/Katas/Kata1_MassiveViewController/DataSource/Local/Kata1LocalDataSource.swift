//
//  Kata1LocalDataSource.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//

protocol Kata1LocalDataSourceProtocol {
    func getPosts(page: Int) async throws -> [JPPost]
}


public actor Kata1LocalDataSource: Kata1LocalDataSourceProtocol {
    public func getPosts(page: Int) async throws -> [JPPost] {
        fatalError("Not implemented")
    }
}

//
//  PostsEndpoint.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//

import Foundation
import NetworkLayer

public struct PostsEndpoint: NetworkLayerEndpoint {
    public var queryItems: [URLQueryItem] = []

    public var path: String = "/posts"

	public var host: String = "jsonplaceholder.typicode.com"

    public var method: NetworkLayer.URLRequestMethod  = .GET
}

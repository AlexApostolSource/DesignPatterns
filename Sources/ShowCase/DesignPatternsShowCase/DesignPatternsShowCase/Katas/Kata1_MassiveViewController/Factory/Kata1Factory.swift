//
//  Kata1Factory.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//
import NetworkLayer
import UIKit

protocol Kata1FactoryMethodProtocol {
    static func createKata1() -> UIViewController
}

struct Kata1FactoryMethod: Kata1FactoryMethodProtocol {
    static func createKata1() -> UIViewController {
        NetworkLayerConfig.config(host: "jsonplaceholder.typicode.com")
        return MassivePostsViewController()
    }
}

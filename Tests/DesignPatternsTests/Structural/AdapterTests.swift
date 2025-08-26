//
//  AdapterTests.swift
//  DesignPatterns
//
//  Created by Alex.personal on 26/8/25.
//

import XCTest
@testable import DesignPatterns

/// Adapter Design Pattern
///
/// Intent: Convert the interface of a class into the interface clients expect.
/// Adapter lets classes work together that couldn't work otherwise because of
/// incompatible interfaces.

class AdapterRealWorld: XCTestCase {

    /// Example. Let's assume that our app perfectly works with Facebook
    /// authorization. However, users ask you to add sign in via Twitter.
    ///
    /// Unfortunately, Twitter SDK has a different authorization method.
    ///
    /// Firstly, you have to create the new protocol 'AuthService' and insert
    /// the authorization method of Facebook SDK.
    ///
    /// Secondly, write an extension for Twitter SDK and implement methods of
    /// AuthService protocol, just a simple redirect.
    ///
    /// Thirdly, write an extension for Facebook SDK. You should not write any
    /// code at this point as methods already implemented by Facebook SDK.
    ///
    /// It just tells a compiler that both SDKs have the same interface.

    func testAdapterRealWorld() {
        AppConfig(remoteConfig: FirebaseRemoteConfig()).getFeatureFlag(forKey: "new_feature")
        AppConfig(remoteConfig: GrowthBookRemoteConfig()).getFeatureFlag(forKey: "new_feature")
    }
}



//
//  Services.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public final class Services {

    let baseURL = "http://localhost:8000"
    let home: HomeService
    public let auth: AuthService

    public init() {
        home = HomeService(baseURL: baseURL)
        auth = AuthService(baseURL: baseURL)
    }
}

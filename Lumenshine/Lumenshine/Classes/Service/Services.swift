//
//  Services.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public final class Services {
#if DEBUG
    let baseURL = "http://192.168.0.18:8000"
#elseif DEVELOPMENT
    let baseURL = "http://api.stellargate.net"
#endif
    let home: HomeService
    public let auth: AuthService

    public init() {
        home = HomeService(baseURL: baseURL)
        auth = AuthService(baseURL: baseURL)
    }
}

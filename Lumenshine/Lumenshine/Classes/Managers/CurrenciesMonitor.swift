//
//  CurrenciesMonitor.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 15/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class CurrenciesMonitor: NSObject {
    static var updateInterval: Double = 5
    
    private let currenciesService = Services.shared.currenciesService
    
    var isMonitoring = false
    var currentRate: Double = 0
    var updateClosure: ((Double) -> ())?
    
    func startMonitoring() {
        isMonitoring = true
        update()
    }
    
    func stopMonitoring() {
        isMonitoring = false
    }
    
    private func update() {
        currenciesService.getRate(from: .xlm, to: .usd) { (result) -> (Void) in
            switch result {
            case .success(let rate):
                self.currentRate = rate
                self.updateClosure?(rate)
            case .failure(_):
                print("Failed to update rate")
            }
            
            if self.isMonitoring {
                DispatchQueue.main.asyncAfter(deadline: .now() + CurrenciesMonitor.updateInterval) {
                    self.update()
                }
            }
        }
    }
    
}

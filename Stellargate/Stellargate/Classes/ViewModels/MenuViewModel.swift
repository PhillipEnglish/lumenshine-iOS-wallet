//
//  MenuViewModel.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit.UIImage

protocol MenuViewModelType: Transitionable {
    var items: [[String?]] { get }
    var icons: [[UIImage?]] { get }
    func menuItemSelected(at indexPath: IndexPath)
    
}

class MenuViewModel : MenuViewModelType {
    
    var items: [[String?]] = [
        [nil, "name@email.com"],
        ["Home", "Wallets", "Transactions", "Promotions"],
        ["Settings", "Help Center"]
    ]
    
    var icons: [[UIImage?]] = [
        [MaterialIcon.account.size48pt, nil],
        [MaterialIcon.home.size24pt, MaterialIcon.wallets.size24pt, MaterialIcon.transactions.size24pt, MaterialIcon.promotions.size24pt],
        [MaterialIcon.settings.size24pt, MaterialIcon.help.size24pt]
    ]
    
    var navigationCoordinator: CoordinatorType?
    
    init() {
    }
    
    func menuItemSelected(at indexPath:IndexPath) {
        switch indexPath.section {
        case 0:
            navigationCoordinator?.performTransition(transition: .showSettings)
        case 1:
            if indexPath.row == 0 {
                navigationCoordinator?.performTransition(transition: .showHome)
            }
        case 2:
            if indexPath.row == 0 {
                navigationCoordinator?.performTransition(transition: .showSettings)
            }
        default: break
        }
    }
}

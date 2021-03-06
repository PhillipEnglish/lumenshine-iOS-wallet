//
//  HelpCenterViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 9/26/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol HelpCenterViewModelType: Transitionable {
    var itemDistribution: [Int] { get }
    func name(at indexPath: IndexPath) -> String?
    func detail(at indexPath: IndexPath) -> String?
    func iconName(at indexPath: IndexPath) -> String
    func headerTitle(at section: Int) -> String?
    
    func itemSelected(at indexPath: IndexPath)
}

class HelpCenterViewModel : HelpCenterViewModelType {
    
    fileprivate let service: AuthService
    fileprivate let user: User
    fileprivate let entries: [[HelpEntry]]
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
        
        self.entries = [[.inbox],
                        [.FAQ1, .FAQ2, .FAQ3, .FAQ4],
                        [.basics, .security, .wallets, .stellar]]//, .ICO]]
    }
    
    var itemDistribution: [Int] {
        return entries.map { $0.count }
    }
    
    func name(at indexPath: IndexPath) -> String? {
        return entry(at: indexPath).title
    }
    
    func iconName(at indexPath: IndexPath) -> String {
        return entry(at: indexPath).icon.name
    }
    
    func detail(at indexPath: IndexPath) -> String? {
        return entry(at: indexPath).detail
    }
    
    func headerTitle(at section: Int) -> String? {
        switch section {
        case 1:
            return R.string.localizable.faq()
        case 2:
            return R.string.localizable.topics()
        default:
            return nil
        }
    }
    
    func itemSelected(at indexPath:IndexPath) {
        switch entry(at: indexPath) {
        case .inbox:
            break
        case .FAQ1:
            break
        default: break
        }
    }
}

fileprivate extension HelpCenterViewModel {
    func entry(at indexPath: IndexPath) -> HelpEntry {
        return entries[indexPath.section][indexPath.row]
    }
}

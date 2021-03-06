//
//  UserManager.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 05/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

public enum BoolEnum {
    case success(response: Bool)
    case failure(error: ServiceError)
}

public enum CoinEnum {
    case success(response: CoinUnit)
    case failure(error: ServiceError)
}

public enum WalletsEnum {
    case success(response: [Wallet])
    case failure(error: ServiceError)
}

public enum AddressStatusEnum {
    case success(isFunded: Bool, isTrusted: Bool?)
    case failure
}

public typealias BoolClosure = (_ response:BoolEnum) -> (Void)
public typealias CoinClosure = (_ response:CoinEnum) -> (Void)
public typealias WalletsClosure = (_ response:WalletsEnum) -> (Void)
public typealias AddressStatusClosure = (_ response: AddressStatusEnum) -> (Void)
public typealias CoinUnit = Double

public class UserManager: NSObject {
    var totalNativeFunds: CoinUnit?
    
    var walletService: WalletsService {
        get {
            return Services.shared.walletService
        }
    }
    
    var stellarSDK: StellarSDK {
        get {
            return Services.shared.stellarSdk
        }
    }
    
    func totalNativeFounds(completion: @escaping CoinClosure) {
        walletService.getWallets { (result) -> (Void) in
            switch result {
            case .success(let data):
                self.totalBalance(wallets: data, completion: completion)
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func walletsForCurrentUser(completion: @escaping WalletsClosure) {
        walletService.getWallets { (result) -> (Void) in
            switch result {
            case .success(let data):
                self.walletDetailsFor(wallets: data) { (result) -> (Void) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let wallets):
                            completion(.success(response: wallets))
                        case .failure(let error):
                            completion(.failure(error: error))
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func checkAddressStatus(forAccountID accountID: String, asset: AccountBalanceResponse, completion: @escaping AddressStatusClosure) {
        stellarSDK.accounts.getAccountDetails(accountId: accountID) { response in
            switch response {
            case .success(let accountDetails):
                var isFunded = false
                var isTrusted = false
        
                if accountDetails.balances.count > 0 {
                    isFunded = true
                }
                
                if asset.assetIssuer == accountID {
                    isTrusted = true
                } else {
                    for balance in accountDetails.balances {
                        if balance.assetCode == asset.assetCode &&
                            balance.assetIssuer == asset.assetIssuer {
                            isTrusted = true
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion(.success(isFunded: isFunded, isTrusted: isTrusted))
                }
            case .failure(_):
                DispatchQueue.main.async {
                    completion(.failure)
                }
            }
        }
    }
    
    func checkIfAccountExists(forAccountID accountID: String, completion: @escaping ((Bool) -> (Void))) {
        stellarSDK.accounts.getAccountDetails(accountId: accountID) { (accountResponse) -> (Void) in
            DispatchQueue.main.async {
                switch accountResponse {
                case .success(_):
                    completion(true)
                case .failure(_):
                    completion(false)
                }
            }
        }
    }
    
    func createTestAccount(withAccountID accountID: String, completion: @escaping CreateTestAccountClosure) {
        stellarSDK.accounts.createTestAccount(accountId: accountID) { (response) -> (Void) in
            DispatchQueue.main.async {
                switch response {
                case .success(details: let details):
                    completion(.success(details: details))
                case .failure(error: let error):
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    private func totalBalance(wallets: [WalletsResponse], completion: @escaping CoinClosure) {
        guard wallets.count > 0 else {
            completion(.success(response: 0))
            return
        }
        
        var completed = 0
        var callFailed = false
        var xlm: CoinUnit = 0
        for wallet in wallets {
            guard !callFailed else { return }
            
            stellarSDK.accounts.getAccountDetails(accountId: wallet.publicKey) { (result) -> (Void) in
                switch result {
                case .success(let accountDetails):
                    for balance in accountDetails.balances {
                        switch balance.assetType {
                        case AssetTypeAsString.NATIVE:
                            print("balance: \(balance.balance) XLM")
                            if let units = CoinUnit(balance.balance) {
                                xlm += units
                            }
                        default:
                            break
                        }
                    }
                case .failure(let error):
                    switch error {
                    case .notFound(_,_):
                        print(error.localizedDescription)
                    default:
                        guard !callFailed else { return }
                        callFailed = true
                        DispatchQueue.main.sync {
                            completion(.failure(error: .genericError(message: error.localizedDescription)))
                        }
                        return
                    }
                }
                
                completed += 1
                if completed == wallets.count {
                    DispatchQueue.main.async {
                        self.totalNativeFunds = xlm
                        completion(.success(response: xlm))
                    }
                }
            }
        }
    }
    
    private func walletDetailsFor(wallets: [WalletsResponse], completion: @escaping WalletsClosure) {
        guard wallets.count > 0 else {
            completion(.success(response: []))
            return
        }
        
        var completed = 0
        var callFailed = false
        var walletDetails = [Wallet]()
        for wallet in wallets {
            guard !callFailed else { return }
            
            stellarSDK.accounts.getAccountDetails(accountId: wallet.publicKey) { (result) -> (Void) in
                switch result {
                case .success(let accountDetails):
                    let walletDetail = FundedWallet(walletResponse: wallet, accountResponse: accountDetails)
                    walletDetails.append(walletDetail)
                case .failure(let error):
                    switch error {
                    case .notFound(_,_):
                        let unfundedWallet = UnfundedWallet(walletResponse: wallet)
                        walletDetails.append(unfundedWallet)
                    default:
                        guard !callFailed else { return }
                        callFailed = true
                        completion(.failure(error: .genericError(message: error.localizedDescription)))
                        return
                    }
                }
                
                completed += 1
                if completed == wallets.count {
                    completion(.success(response: walletDetails))
                }
            }
        }
    }
}

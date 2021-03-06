//
//  InflationManager.swift
//  Lumenshine
//
//  Created by Soneso on 05/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

public enum GetInflationDestinationEnum {
    case success(inflationDestinationAddress: String)
    case failure(error: HorizonRequestError?)
}

public enum CheckInflationDestinationEnum {
    case success(knownInflationDestination: KnownInflationDestinationResponse)
    case failure(error: ServiceError?)
}

public enum InflationDestinationErrorCodes {
    case accountNotFound
    case transactionFailed
    case invalidTransactionInput
}

public enum SetInflationDestinationEnum {
    case success
    case failure(error: InflationDestinationErrorCodes)
}

public typealias GetInflationDestinationClosure = (_ completion: GetInflationDestinationEnum) -> (Void)
public typealias CheckInflationDestinationClosure = (_ completion: CheckInflationDestinationEnum) -> (Void)
public typealias SetInflationDestinationClosure = (_ completion: SetInflationDestinationEnum) -> (Void)

class InflationManager {
    private var stellarSDK: StellarSDK {
        get {
            return Services.shared.stellarSdk
        }
    }
    
    private var currenciesService: CurrenciesService {
        get {
            return Services.shared.currenciesService
        }
    }
    
    private var userManager = UserManager()
    
    func getKnownInflationDestinations(completion: @escaping GetKnownInflationDestinationsClosure) {
        currenciesService.getKnownInflationDestinations { (response) -> (Void) in
            DispatchQueue.main.async {
                switch response {
                case .success(response: let knownInflationDestinations):
                    completion(.success(response: knownInflationDestinations))
                case .failure(error: let error):
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func getInflationDestination(forAccount accountID: String, completion: @escaping GetInflationDestinationClosure) {
        stellarSDK.accounts.getAccountDetails(accountId: accountID) { (response) -> (Void) in
            DispatchQueue.main.async {
                switch response {
                case .success(details: let accountDetails):
                    if let inflationAddress = accountDetails.inflationDestination {
                        completion(.success(inflationDestinationAddress: inflationAddress))
                    } else {
                        completion(.failure(error: nil))
                    }
                case .failure(error: let error):
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func checkInflationDestination(inflationAddress: String, completion: @escaping CheckInflationDestinationClosure) {
        currenciesService.getKnownInflationDestinations { (response) -> (Void) in
            switch response {
            case .success(response: let knownInflationDestinations):
                for inflationDestination in knownInflationDestinations {
                    if inflationDestination.issuerPublicKey == inflationAddress {
                        DispatchQueue.main.async {
                            completion(.success(knownInflationDestination: inflationDestination))
                        }
                        
                        return
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.failure(error: nil))
                }
            case .failure(error: let error):
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func setInflationDestination(inflationAddress: String, sourceAccountID: String, completion: @escaping SetInflationDestinationClosure) {
        if let sourceAccountKeyPair = PrivateKeyManager.getKeyPair(forAccountID: sourceAccountID) {
            userManager.checkIfAccountExists(forAccountID: inflationAddress) { (accountExists) -> (Void) in
                if accountExists {
                    self.stellarSDK.accounts.getAccountDetails(accountId: sourceAccountKeyPair.accountId) { (response) -> (Void) in
                        switch response {
                        case .success(let accountResponse):
                            self.submitInflationDestination(accountResponse: accountResponse, sourceAccountKeyPair: sourceAccountKeyPair, inflationAddress: inflationAddress,
                                                            completion: { (response) -> (Void) in
                                DispatchQueue.main.async {
                                    completion(response)
                                }
                            })
                        case .failure(let error):
                            StellarSDKLog.printHorizonRequestErrorMessage(tag:"Error:", horizonRequestError: error)
                            DispatchQueue.main.async {
                                completion(.failure(error: InflationDestinationErrorCodes.transactionFailed))
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(error: InflationDestinationErrorCodes.accountNotFound))
                    }
                }
            }
        }
    }
    
    private func submitInflationDestination(accountResponse: AccountResponse, sourceAccountKeyPair: KeyPair, inflationAddress: String, completion: @escaping SetInflationDestinationClosure) {
        do {
            let setInflationOperation = try SetOptionsOperation(inflationDestination: KeyPair(accountId: inflationAddress))
            let transaction = try Transaction(sourceAccount: accountResponse,
                                              operations: [setInflationOperation],
                                              memo: Memo.none,
                                              timeBounds:nil)
            try transaction.sign(keyPair: sourceAccountKeyPair, network: Network.testnet)
            try self.stellarSDK.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                switch response {
                case .success(_):
                    print("Success")
                    completion(.success)
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"Change inflation destination", horizonRequestError:error)
                    completion(.failure(error: InflationDestinationErrorCodes.transactionFailed))
                }
            }
        } catch {
            completion(.failure(error: InflationDestinationErrorCodes.invalidTransactionInput))
        }
    }
}

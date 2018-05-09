//
//  TFARegistrationCoordinator.swift
//  Stellargate
//
//  Created by Istvan Elekes on 4/29/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class TFARegistrationCoordinator: CoordinatorType {
    var baseController: UIViewController
    fileprivate let service: AuthService
    
    init(service: AuthService, email: String, response: RegistrationResponse, mnemonic: String) {
        self.service = service
        let viewModel = TFARegistrationViewModel(service: service, email: email, response: response, mnemonic: mnemonic)
        self.baseController = TFARegistrationViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showGoogle2FA(let url):
            showGoogleAuthenticator(url: url)
        case .showMnemonic(let mnemonic):
            showMnemonicQuiz(mnemonic)
        default: break
        }
    }
}

fileprivate extension TFARegistrationCoordinator {
    func showGoogleAuthenticator(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let urlString = "https://itunes.apple.com/app/google-authenticator/id388497605"
            if let url = URL(string: urlString),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func showMnemonicQuiz(_ mnemonic: String) {
        let mnemonicCoordinator = MnemonicCoordinator(service: service, mnemonic: mnemonic)
        baseController.navigationController?.pushViewController(mnemonicCoordinator.baseController, animated: true)
    }
}


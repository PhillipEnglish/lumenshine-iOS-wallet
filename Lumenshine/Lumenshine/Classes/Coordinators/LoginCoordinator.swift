//
//  LoginCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LoginCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    fileprivate let service: Services
    
    init() {
        self.service = Services()
        let viewModel = LoginViewModel(service: service.auth)
        let navigation = AppNavigationController(rootViewController: LoginViewController(viewModel: viewModel))
        self.baseController = navigation
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showDashboard(let user):
            showDashboard(user: user)
        case .showSignUp:
            showSignUp()
        case .showForgotPassword:
            showForgotPassword()
        case .show2FA(let user, let registrationResponse):
            show2FA(user: user, response: registrationResponse)
        case .showMnemonic(let user):
            showMnemonicQuiz(user: user)
        case .showEmailConfirmation(let user):
            showEmailConfirmation(user: user)
        default:
            break
        }
    }
}

fileprivate extension LoginCoordinator {
    func showDashboard(user: User) {
        let menuCoordinator = MenuCoordinator(user: user)
        
        if let mainNavigation = menuCoordinator.baseController.evo_drawerController,
            let navigation = baseController as? AppNavigationController {
            navigation.popToRootViewController(animated: false)
            navigation.setNavigationBarHidden(true, animated: false)
            navigation.pushViewController(mainNavigation, animated: true)
        }
//        if let window = self.baseController.view.window {
//            window.rootViewController = mainNavigation
//        } else {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.window?.rootViewController = mainNavigation
//        }
//
//        self.baseController.dismiss(animated: true)
    }
    
    func showSignUp() {
        let registrationCoordinator = RegistrationCoordinator(service: service.auth)
        (baseController as! AppNavigationController).pushViewController(registrationCoordinator.baseController, animated: true)
    }
    
    func showForgotPassword() {
        let forgotPasswordCoordinator = ForgotPasswordCoordinator(service: service.auth)
        (baseController as! AppNavigationController).pushViewController(forgotPasswordCoordinator.baseController, animated: true)
    }
    
    func show2FA(user: User, response: RegistrationResponse) {
        let tfaCoordinator = TFARegistrationCoordinator(service: service.auth, user: user, response: response)
        (baseController as! AppNavigationController).pushViewController(tfaCoordinator.baseController, animated: true)
    }
    
    func showMnemonicQuiz(user: User) {
        let mnemonicCoordinator = MnemonicCoordinator(service: service.auth, user: user)
        (baseController as! AppNavigationController).pushViewController(mnemonicCoordinator.baseController, animated: true)
    }
    
    func showEmailConfirmation(user: User) {
        let emailCoordinator = EmailConfirmationCoordinator(service: service.auth, user: user)
        (baseController as! AppNavigationController).pushViewController(emailCoordinator.baseController, animated: true)
    }
}


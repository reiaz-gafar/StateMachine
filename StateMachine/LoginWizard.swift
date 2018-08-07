//
//  LoginWizard.swift
//  StateMachine
//
//  Created by Reiaz Gafar on 8/3/18.
//  Copyright © 2018 Reiaz Gafar. All rights reserved.
//

import UIKit
import Jester

class LoginWizard {

    var stateMachine: LoginStateMachine!

    lazy var promptViewController: PromptViewController = {
        let vc = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "PromptVC") as! PromptViewController
       // vc.onNo =
        return vc
    }()
    lazy var loginViewController: LoginViewController = {
        let vc = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
      //  vc.onLogin =
        return vc
    }()

    init() {
        stateMachine = LoginStateMachine()

    }

}

class LoginStateMachine {

    var stateMachine: StateMachine<State>!

    enum State {
        case initial
        case loggingIn
        case checkingLoginStatus
        case checkingPromptThreshold
        case premiumPrompting
        case home
    }

    struct Input {
        static let launchCountOverThreshold = BaseInput<Void>(description: "there have been 5 launches")
        static let launchCountUnderThreshold = BaseInput<Void>(description: "there have been under 5 launches")

        static let deferPremium = BaseInput<Void>(description: "defer premium")

        static let userLoggedIn = BaseInput<Void>(description: "successful login")
        static let userNotLoggedIn = BaseInput<Void>(description: "unsuccessful login")
    }

    enum Effect {
        case presentLogIn
        case presentHome
        case presentPremiumPrompt
        case checkLoginStatus
        case checkPromptThreshold
    }

    init() {
        let mappings: [MappedStateTransition<State>] = { [weak self] in

            let noEffect = wrap(effect: { self?.noEffect($0) })
            let numberOfLogins = wrap(effect: { self?.numberOfLogins($0, $1) })
            let presentLogin = wrap(effect: { self?.presentLogin($0) })
            let presentHome = wrap(effect: { self?.presentHome($0) })
            let presentPrompt = wrap(effect: { self?.presentPrompt($0) })
            let checkLoginStatus = wrap(effect: { self?.checkLoginStatus($0) })


            return [
                Input.launchCountOverThreshold   | .initial => .premiumPrompting                | presentPrompt,
                Input.launchCountUnderThreshold  | .initial => .checkingLoginStatus             | checkLoginStatus,

                Input.deferPremium               | .premiumPrompting => .checkingLoginStatus    | checkLoginStatus,

                Input.userNotLoggedIn            | .checkingLoginStatus => .loggingIn           | presentLogin,// noEffect?
                Input.userLoggedIn               | .checkingLoginStatus => .home                | presentHome,

                Input.userNotLoggedIn            | .loggingIn => .loggingIn                     | presentLogin,
                Input.userLoggedIn               | .loggingIn => .home                          | presentHome,
                ]
        }()

        stateMachine = StateMachine<State>(initialState: .initial, mappings: mappings)
    }

    func processLogin(didLogIn: Bool, stateMachine: StateMachine<State>) {
        if didLogIn {
            // send present ..
        } else {

            //
        }
    }

    func noEffect(_ machine: StateMachine<State>) {}

    func noEffect(_ bool: Bool, _ machine: StateMachine<State>) {}

    func checkLoginStatus(_ machine: StateMachine<State>) {

    }

    func numberOfLogins(_ count: Int, _ machine: StateMachine<State>) {

    }

    func presentLogin(_ machine: StateMachine<State>) {

    }

    func presentHome(_ machine: StateMachine<State>) {

    }

    func presentPrompt(_ machine: StateMachine<State>) {

    }

}

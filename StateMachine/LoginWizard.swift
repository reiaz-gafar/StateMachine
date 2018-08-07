//
//  LoginWizard.swift
//  StateMachine
//
//  Created by Reiaz Gafar on 8/3/18.
//  Copyright © 2018 Reiaz Gafar. All rights reserved.
//

import UIKit
import Jester
import RxSwift

class LoginWizard {

    private var stateMachine: LoginStateMachine!
    let disposeBag = DisposeBag()

    private var viewControllerSubject = PublishSubject<UIViewController>()

    var viewController: Observable<UIViewController> {
        return viewControllerSubject.asObservable()
    }

    lazy var promptViewController: PromptViewController = {
        let vc = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "PromptVC") as! PromptViewController
        vc.onNo = { self.stateMachine.stateMachine.send(LoginStateMachine.Input.deferPremium) }
        return vc
    }()

    lazy var loginViewController: LoginViewController = {
        let vc = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        vc.onLogin = { $0 ? self.stateMachine.stateMachine.send(LoginStateMachine.Input.userLoggedIn) : self.stateMachine.stateMachine.send(LoginStateMachine.Input.userNotLoggedIn) }
        return vc
    }()

    lazy var homeViewControler: HomeViewController = {
        let vc = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
        vc.onLogOut = { self.stateMachine.stateMachine.send(LoginStateMachine.Input.userNotLoggedIn) }
        return vc
    }()

    init() {
        stateMachine = LoginStateMachine()
        watchStateMachine()
        let launchCount = UserDefaults.standard.integer(forKey: "numberOfLaunches")
        if launchCount == 0 {
            stateMachine.stateMachine.send(LoginStateMachine.Input.launchCountOverThreshold)
        } else {
            stateMachine.stateMachine.send(LoginStateMachine.Input.launchCountUnderThreshold)
        }
    }

    func watchStateMachine() {
        stateMachine.effect
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (effect) in
            switch effect {
            case .presentLogIn:
                self?.viewControllerSubject.onNext((self?.loginViewController)!)
            case .presentHome:
                self?.viewControllerSubject.onNext((self?.homeViewControler)!)
            case .presentPremiumPrompt:
                self?.viewControllerSubject.onNext((self?.promptViewController)!)
            case .checkLoginStatus:
                let loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
                if loggedIn {
                    self?.viewControllerSubject.onNext((self?.homeViewControler)!)
                } else {
                    self?.viewControllerSubject.onNext((self?.loginViewController)!)
                }
            }
        }).disposed(by: disposeBag)
    }

}

class LoginStateMachine {

    var stateMachine: StateMachine<State>!

    private var effectSubject = PublishSubject<Effect>()

    var effect: Observable<Effect> {
        return effectSubject.asObservable()
    }

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
    }

    init() {
        let mappings: [MappedStateTransition<State>] = { [weak self] in

            let noEffect = wrap(effect: { self?.noEffect($0) })
            let presentLogin = wrap(effect: { self?.presentLogin($0) })
            let presentHome = wrap(effect: { self?.presentHome($0) })
            let presentPrompt = wrap(effect: { self?.presentPrompt($0) })
            let checkLoginStatus = wrap(effect: { self?.checkLoginStatus($0) })

            return [
                Input.launchCountOverThreshold   | .initial => .premiumPrompting                | presentPrompt,
                Input.launchCountUnderThreshold  | .initial => .checkingLoginStatus             | checkLoginStatus,

                Input.deferPremium               | .premiumPrompting => .checkingLoginStatus    | checkLoginStatus,

                Input.userNotLoggedIn            | .checkingLoginStatus => .loggingIn           | presentLogin,
                Input.userLoggedIn               | .checkingLoginStatus => .home                | presentHome,

                Input.userNotLoggedIn            | .loggingIn => .loggingIn                     | noEffect,
                Input.userLoggedIn               | .loggingIn => .home                          | presentHome,

                Input.userNotLoggedIn            | .home => .loggingIn                          | presentLogin
                ]
        }()

        stateMachine = StateMachine<State>(initialState: .initial, mappings: mappings)
    }

    func noEffect(_ machine: StateMachine<State>) {}

    func checkLoginStatus(_ machine: StateMachine<State>) {
        effectSubject.onNext(.checkLoginStatus)
    }

    func presentLogin(_ machine: StateMachine<State>) {
        effectSubject.onNext(.presentLogIn)
    }

    func presentHome(_ machine: StateMachine<State>) {
        effectSubject.onNext(.presentHome)
    }

    func presentPrompt(_ machine: StateMachine<State>) {
        effectSubject.onNext(.presentPremiumPrompt)
    }

}


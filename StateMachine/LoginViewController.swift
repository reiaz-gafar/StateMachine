//
//  LoginViewController.swift
//  StateMachine
//
//  Created by Reiaz Gafar on 8/3/18.
//  Copyright © 2018 Reiaz Gafar. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var onLogin: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func loginButtonTapped(_ sender: UIButton) {
        var logInSuccessful = true
        let random = Int(arc4random_uniform(2))

        if random == 1 {
            logInSuccessful = false
            print("bad password")
        } else {
            UserDefaults.standard.set(true, forKey: "loggedIn")
        }

        onLogin?(logInSuccessful)
    }

}

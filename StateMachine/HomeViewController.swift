//
//  ViewController.swift
//  StateMachine
//
//  Created by Reiaz Gafar on 8/3/18.
//  Copyright © 2018 Reiaz Gafar. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    var onLogOut: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        onLogOut?()
        UserDefaults.standard.set(false, forKey: "loggedIn")
    }
    
}


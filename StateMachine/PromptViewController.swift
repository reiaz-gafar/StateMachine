//
//  PromptViewController.swift
//  StateMachine
//
//  Created by Reiaz Gafar on 8/3/18.
//  Copyright © 2018 Reiaz Gafar. All rights reserved.
//

import UIKit

class PromptViewController: UIViewController {

    var onNo: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func noButtonTapped(_ sender: UIButton) {
        onNo?()
    }

}

//
//  RootViewController.swift
//  StateMachine
//
//  Created by Reiaz Gafar on 8/3/18.
//  Copyright © 2018 Reiaz Gafar. All rights reserved.
//

import UIKit
import RxSwift

class RootViewController: UIViewController {

    let loginWizard = LoginWizard()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        watchWizard()
    }

    func watchWizard() {
        loginWizard.viewController.subscribe(onNext: { [unowned self] (viewController) in

            if let currentVC = self.presentedViewController {
                currentVC.dismiss(animated: true) {
                    self.present(viewController, animated: true, completion: nil)
                }
            } else {
                self.present(viewController, animated: true, completion: nil)
            }

        }).disposed(by: disposeBag)
    }

}

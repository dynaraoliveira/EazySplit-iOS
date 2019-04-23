//
//  ViewController.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 21/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginFacebookButton: UIButton!
    @IBOutlet weak var loginGoogleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.loadCornerRadius()
        loginFacebookButton.loadCornerRadius()
        loginGoogleButton.loadCornerRadius()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func loginClick(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyBoard
            .instantiateViewController(withIdentifier:"HomeTabBar") as? UITabBarController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


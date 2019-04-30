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
        setButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setButtons() {
        loginButton.loadCornerRadius()
        loginFacebookButton.loadCornerRadius()
        loginGoogleButton.loadCornerRadius()
    }
    
    @IBAction func loginClick(_ sender: Any) {
        Loader.shared.showOverlay(view: self.view)
        
        let firebaseService = FirebaseService()
        firebaseService.loginFirebase(email: userTextField.text ?? "",
                                      password: passwordTextField.text ?? "",
                                      completion: { (result) in
            switch result {
            case .success:
                Loader.shared.hideOverlayView()
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                guard let vc = storyBoard
                    .instantiateViewController(withIdentifier:"HomeTabBar") as? UITabBarController else { return }
                self.navigationController?.pushViewController(vc, animated: true)
                
                break
                
            case .error(let err):
                print(err.localizedDescription)
                break
            }
        })
       
    }
    
}


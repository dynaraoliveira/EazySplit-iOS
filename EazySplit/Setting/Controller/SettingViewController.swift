//
//  SettingViewController.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 30/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var nameProfile: UILabel!
    @IBOutlet weak var meansOfPayment: UIButton!
    @IBOutlet weak var language: UIButton!
    @IBOutlet weak var about: UIButton!
    @IBOutlet weak var logout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        
        if let urlImage = FirebaseService.shared.authUser?.photoURL {
            imageProfile.loadImage(withURL: urlImage)
        }
        
        if let name = FirebaseService.shared.authUser?.displayName {
            nameProfile.text = name
        }
        
        imageProfile.layer.cornerRadius = imageProfile.frame.height / 2.0
        imageProfile.layer.masksToBounds = true
    }
    
    @IBAction func editProfile(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterViewController")
        tabBarController?.tabBar.isHidden = true
        pushViewController(vc)
    }
    
    @IBAction func clickMeansOfPayment(_ sender: Any) {
    }
    
    @IBAction func clickLanguage(_ sender: Any) {
    }
    
    @IBAction func clickAbout(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AboutViewController")
        tabBarController?.tabBar.isHidden = true
        pushViewController(vc)
    }
    
    
    @IBAction func clickLogout(_ sender: Any) {
        do {
            try FirebaseService.shared.authFirebase.signOut()
            FirebaseService.shared.authUser = nil
            FirebaseService.shared.restaurantList = []
            FirebaseService.shared.user = nil
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        } catch(let error) {
            print(error)
        }
        
    }
    
    private func pushViewController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

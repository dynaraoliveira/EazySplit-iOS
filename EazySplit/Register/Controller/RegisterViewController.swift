//
//  RegisterViewController.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 23/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var registerImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneErrorLabel: UILabel!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var birthdayErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var passwordConfirmErrorLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var firebaseService: FirebaseService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cleanErrors()
        setDelegate()
        setRegisterImageView()
        setRegisterButton()
        addObserverKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func changePhotoClick(_ sender: Any) {
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func registerClick(_ sender: Any) {
        validate()
    }
    
    private func setRegisterImageView() {
        registerImageView.layer.cornerRadius = registerImageView.frame.height / 2.0
        registerImageView.layer.masksToBounds = true
        registerImageView.image = UIImage(named: "foto")
    }
    
    private func setRegisterButton() {
        registerButton.loadCornerRadius()
    }
    
    private func addObserverKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func validate() {
        do {
            let name = try nameTextField.validatedText(validationType: .requiredField(field: "Name", label: nameErrorLabel))
            let email = try emailTextField.validatedText(validationType: ValidatorType.email(label: emailErrorLabel))
            let phone = try phoneTextField.validatedText(validationType: ValidatorType.phone(label: phoneErrorLabel))
            let birthday = try birthdayTextField.validatedText(validationType: ValidatorType.date(label: birthdayErrorLabel))
            let password = try passwordTextField.validatedText(validationType: ValidatorType.password(label: passwordErrorLabel, compare: nil))
            let _ = try passwordConfirmTextField.validatedText(validationType: ValidatorType.password(label: passwordConfirmErrorLabel, compare: password))
            
            let user = User(name: name, email: email, phone: phone, birthday: birthday, password: password, photoURL: "")
            
            saveFirebase(user)
            
        } catch(let error) {
            let errorLabel = (error as! ValidationError).label
            errorLabel.text = (error as! ValidationError).message
        }
    }
    
    private func saveFirebase(_ user: User) {
        Loader.shared.showOverlay(view: self.view)
        
        firebaseService = FirebaseService()
        firebaseService?.saveFirebase(user, photoData: registerImageView.image!.pngData(), completion: { (result) in
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
    
    private func cleanErrors() {
        nameErrorLabel.text = ""
        emailErrorLabel.text = ""
        phoneErrorLabel.text = ""
        birthdayErrorLabel.text = ""
        passwordErrorLabel.text = ""
        passwordConfirmErrorLabel.text = ""
    }
    
    private func setDelegate() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        birthdayTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            
            var contentInset:UIEdgeInsets = self.scrollView.contentInset
            contentInset.bottom = keyboardFrame.size.height
            scrollView.contentInset = contentInset
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        cleanErrors()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return false }
        
        switch textField.tag {
        case 3:
            if textField.text?.count ?? 0 < 15 {
                textField.text = text.applyPatternOnNumbers(pattern: "+(##) ####-####", replacmentCharacter: "#")
            } else {
                textField.text = text.applyPatternOnNumbers(pattern: "+(##) #####-####", replacmentCharacter: "#")
            }
        case 4:
            if textField.text?.count ?? 0 >= 10 { return false }
            textField.text = text.applyPatternOnNumbers(pattern: "##/##/####", replacmentCharacter: "#")
            
        default:
            return true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            registerImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }

}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

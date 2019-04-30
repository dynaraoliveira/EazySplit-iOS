//
//  FirebaseService.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 25/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

enum Result {
    case success
    case error(Error)
}

class FirebaseService {
    private let authFirebase: Auth
    private var authUser: FirebaseAuth.User?
    private var user: User?
    private var error: Error?
    
    init() {
        authFirebase = Auth.auth()
    }
    
    func loginFirebase(email: String, password: String, completion: @escaping((Result) -> Void)) {
        authFirebase.signIn(withEmail: email, password: password) { (authResult, error) in
            guard let error = error else {
                if let authUser = authResult?.user {
                    self.authUser = authUser
                }
                return
            }
            self.error = error
        }
        
        if let error = error {
            completion(.error(error))
        }
        
        completion(.success)
    }
    
    func saveFirebase(_ user: User, photoData: Data? = nil, completion: @escaping((Result) -> Void)) {
        self.user = user
        
        authFirebase.createUser(withEmail: user.email, password: user.password) { (authResult, error) in
            guard let error = error else {
                if let authUser = authResult?.user {
                    self.authUser = authUser
                    self.savePhotoFireStorage(photoData)
                }
                return
            }
            self.error = error
        }
        
        if let error = error {
            completion(.error(error))
        }
        
        completion(.success)
    }
    
    private func savePhotoFireStorage(_ photoData: Data?) {
        if let photoData = photoData {
            let imageName = authUser?.uid.description ?? ""
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            
            storageRef.putData(photoData, metadata: nil, completion: { (_, err) in
                
                if let error = err {
                    print(error)
                    return
                }
                
                storageRef.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    
                    guard let url = url else { return }
                    self.user?.photoURL = url.absoluteString
                    
                    self.performUserChange()
                })
                
            })
        } else {
            self.performUserChange()
        }
        
        
    }
    
    private func performUserChange() {
        let changeResquest = authUser?.createProfileChangeRequest()
        changeResquest?.displayName = user?.name
        changeResquest?.photoURL = URL(string: user?.photoURL ?? "")
        changeResquest?.commitChanges { (error) in
            if error != nil {
                print(error!)
            }
            self.performUserChangeOthersData()
        }
    }
    
    private func performUserChangeOthersData() {
        let db = Firestore.firestore()
        let uid = authUser?.uid ?? ""
        let ref: DocumentReference = db.collection("users").document(uid)
        
        let docData: [String: Any] = [
            "birthday": user?.birthDate ?? "",
            "phone": user?.phoneNumber ?? ""
        ]
        
        ref.setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
    }
    
}

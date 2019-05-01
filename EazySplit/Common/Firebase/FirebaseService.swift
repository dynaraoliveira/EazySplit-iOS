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
    
    static let shared = FirebaseService()
    
    private var user: User?
    
    var restaurantList: [Restaurant] = []
    var authUser: FirebaseAuth.User?
    let authFirebase: Auth
    
    let collectionRestaurants = "restaurants"
    var firestoreListener: ListenerRegistration!
    var firestore: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        var firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()
    
    init() {
        authFirebase = Auth.auth()
    }
    
    func loginFirebase(email: String, password: String, completion: @escaping((Result) -> Void)) {
        authFirebase.signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                completion(.error(error))
            }
            
            if let authUser = authResult?.user {
                self.authUser = authUser
                completion(.success)
            }
        }
    }
    
    func saveFirebase(_ user: User, photoData: Data? = nil, completion: @escaping((Result) -> Void)) {
        self.user = user
        
        authFirebase.createUser(withEmail: user.email, password: user.password) { (authResult, error) in
            
            if let error = error {
                completion(.error(error))
            }
            
            if let authUser = authResult?.user {
                self.authUser = authUser
                self.savePhotoFireStorage(photoData)
                completion(.success)
            }
        }
    }

    func listRestaurants(completion: @escaping((Result) -> Void)) {
        firestoreListener = firestore.collection(collectionRestaurants)
            .order(by: "name", descending: false)
            .addSnapshotListener(includeMetadataChanges: true){ (snapshot, error) in
                if let error = error {
                    completion(.error(error))
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                print("alterações", snapshot.documentChanges.count)
                
                if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                    self.restaurantList.removeAll()
                    
                    for document in snapshot.documents {
                        let data = document.data()
                        
                        if let address = data["address"] as? String,
                            let description = data["description"] as? String,
                            let geolocation = data["geolocation"] as? GeoPoint,
                            let name = data["name"] as? String,
                            let rating = data["rating"] as? Int,
                            let type = data["type"] as? String,
                            let urlImage = data["url_image"] as? String
                        {
                            let restaurant = Restaurant(id: document.documentID, name: name, urlImage: urlImage, type: type, description: description, rating: rating, address: address, geolocation: "\(geolocation.latitude) \(geolocation.longitude)")
                            self.restaurantList.append(restaurant)
                            completion(.success)
                        }
                    }
                }
        }
    }
    
    private func savePhotoFireStorage(_ photoData: Data?) {
        if let photoData = photoData {
            let imageName = authUser?.uid.description ?? ""
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            
            storageRef.putData(photoData, metadata: nil, completion: { (_, error) in
                
                if let error = error {
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

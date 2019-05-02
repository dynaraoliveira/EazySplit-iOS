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
    
    var user: User?
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
                return
            }
            
            guard let authUser = authResult?.user else { return }
            self.authUser = authUser
            
            completion(.success)
        }
    }
    
    func saveFirebase(_ user: User, photoData: Data? = nil, completion: @escaping((Result) -> Void)) {
        self.user = user
        
        if authUser != nil {
            self.savePhotoFireStorage(photoData, {
                completion(.success)
            })
            
        } else {
            authFirebase.createUser(withEmail: user.email, password: user.password) { (authResult, error) in
                if let error = error {
                    completion(.error(error))
                    return
                }
                
                guard let authUser = authResult?.user else { return }
                self.authUser = authUser
                
                self.savePhotoFireStorage(photoData, {
                    completion(.success)
                })
                
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
                            let restaurant = Restaurant(id: document.documentID, name: name, urlImage: urlImage, type: type, description: description, rating: rating, address: address, latitude: geolocation.latitude, longitude: geolocation.longitude)
                            self.restaurantList.append(restaurant)
                        }
                    }
                    
                    completion(.success)
                    return
                }
        }
    }
    
    func getUser(completion: @escaping((Result) -> Void)) {
        self.user = nil
        
        let uid = authUser?.uid ?? ""
        let name = authUser?.displayName ?? ""
        let email = authUser?.email ?? ""
        let photoURL = authUser?.photoURL?.absoluteString ?? ""
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)
        
        ref.getDocument { (document, error) in
            if let error = error {
                completion(.error(error))
                return
            }
            
            guard let data = document?.data() else {
                self.user = User(name: name, email: email, phoneNumber: "", birthDate: Date(), password: "", photoURL: photoURL)
                completion(.success)
                return
            }
            
            if let phoneNumber = data["phoneNumber"] as? String,
                let birthDate = data["birthDate"] as? Timestamp {
                self.user = User(name: name, email: email, phoneNumber: phoneNumber, birthDate: birthDate.dateValue(), password: "", photoURL: photoURL)
                completion(.success)
                return
            }
        }
    }
    
    private func savePhotoFireStorage(_ photoData: Data?, _ completion: @escaping(() -> Void)) {
        if let photoData = photoData {
            let imageName = authUser?.uid.description ?? ""
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            
            storageRef.delete { (_) in
            
                storageRef.putData(photoData, metadata: nil, completion: { (_, error) in
                    if let _ = error { return }
                    
                    storageRef.downloadURL(completion: { (url, error) in
                        if let _ = error { return }
                        guard let url = url else { return }
                        self.user?.photoURL = url.absoluteString
                        
                        self.performUserChange({
                            completion()
                        })
                    })
                })
            }
        } else {
            self.performUserChange({
                completion()
            })
        }
    }
    
    private func performUserChange(_ completion: @escaping(() -> Void)) {
        let changeResquest = authUser?.createProfileChangeRequest()
        changeResquest?.displayName = user?.name
        changeResquest?.photoURL = URL(string: user?.photoURL ?? "")
        changeResquest?.commitChanges { (_) in
            self.performUserChangeOthersData({
                completion()
            })
        }
    }
    
    private func performUserChangeOthersData(_ completion: @escaping(() -> Void)) {
        let db = Firestore.firestore()
        let uid = authUser?.uid ?? ""
        let ref: DocumentReference = db.collection("users").document(uid)
        
        let docData: [String: Any] = [
            "birthDate": user?.birthDate ?? "",
            "phoneNumber": user?.phoneNumber ?? ""
        ]
        
        ref.delete { (_) in
            ref.setData(docData) { _ in
                completion()
            }
        }
    }
}

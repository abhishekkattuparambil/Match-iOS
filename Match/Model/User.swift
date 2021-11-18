//
//  User.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 10/12/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit
import Firebase
import MapKit

let db = Firestore.firestore()

class User {
    let email: String
    var username: String
    let uid: String
    var righty: Bool! = true
    var bowlingPos: String! = "Fast"
    var battingPos: String! = "Tail Ender"
    var isPlayer: Bool! = true
    var website: String! = ""
    var home: String! = ""
    
    init(email: String, username: String, uid: String) {
        self.email = email
        self.username = username
        self.uid = uid
        DispatchQueue.main.async {
            let userRef = db.collection("users").document(uid)
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.righty = document.data()!["righty"] as? Bool
                    self.battingPos = document.data()!["batting position"] as? String
                    self.bowlingPos = document.data()!["bowling position"] as? String
                    self.isPlayer = document.data()!["profile type"] as? Bool
                    self.website = document.data()!["website"] as? String
                    self.home = document.data()!["home"] as? String
                }
            }
        }
    }
    
    func addUser() {
        db.collection("users").document(uid).setData([
            "email": email,
            "username": username,
            "uid": uid,
            "bowling position": "Fast",
            "batting position": "Tail Ender",
            "righty": true,
            "profile type": true,
            "website" : "",
            "home": ""
        ]) { (err) in
            if let err = err{
                print("Error adding document: \(err)")
            } else {
                print("Document added with reference ID: \(self.uid)")
            }
        }
    }
    
    
    func profileType(isPlayer: Bool) {
        self.isPlayer = isPlayer
        db.collection("users").document(AuthenticationController.user!.uid).updateData([
        "profile type": isPlayer
        ])
    }
    
    func updateProfile() {
        db.collection("users").document(AuthenticationController.user!.uid).updateData([
            "website": AuthenticationController.user.website!,
            "righty": AuthenticationController.user.righty!,
            "batting position": AuthenticationController.user.battingPos!,
            "bowling position": AuthenticationController.user.bowlingPos!,
            "username": AuthenticationController.user.username
        ])
    }
    
    func updateHomeGround(placemark: MKPlacemark) {
        db.collection("grounds").document(Utils.cantor(x: placemark.coordinate.latitude, y: placemark.coordinate.longitude)).setData([
            "latitude": placemark.coordinate.latitude,
            "longitude": placemark.coordinate.longitude,
            "title": FieldPopupController.groundName!,
            "team": self.username
        ])
    }
}

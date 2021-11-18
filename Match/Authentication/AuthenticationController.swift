//
//  AuthenticationViewController.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 10/9/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class AuthenticationController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var logIn: UIButton!
    @IBOutlet weak var google: UIButton!
    @IBOutlet weak var facebook: UIButton!
    @IBOutlet weak var signUp: UIButton!
    
    
    let facebookLogin: FBLoginButton = FBLoginButton()
    static var user: User! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.underline()
        password.underline()
        email.attributedPlaceholder = NSAttributedString(string: "Username/Email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        password.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        logIn.layer.cornerRadius = logIn.frame.height/2
        google.layer.cornerRadius = 12
        signUp.layer.cornerRadius = signUp.frame.height/2
        facebook.layer.cornerRadius = 12
        
        email.delegate = self
        password.delegate = self
        
        password.addTarget(self, action: #selector(fieldsFilled), for: .editingChanged)
        email.addTarget(self, action: #selector(fieldsFilled), for: .editingChanged)
        google.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        facebook.addTarget(self, action: #selector(simulateFacebookLogin), for: .touchUpInside)
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        //pull email from fb
        facebookLogin.delegate = self
        facebookLogin.permissions = ["email", "public_profile"]
        
        logIn.disable()
    }
    
    @IBAction func signUp(_ sender: Any) {
        performSegue(withIdentifier: "create", sender: self)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBAction func logIn(_ sender: Any) {
        self.logIn.setTitle("Logging In...", for: .normal)
        self.logIn.disable()
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (result, error) in
            if let error = error {
                self.logIn.setTitle("Log In", for: .normal)
                self.logIn.enable()
                self.presentAlertViewController(title: error.localizedDescription, message: "Please try logging in again", completion:  {})
                return
            }
            
            AuthenticationController.self.user = User(email: self.email.text!, username: (result?.user.displayName)!, uid: (result?.user.uid)!)
            
            self.performSegue(withIdentifier: "logIn", sender: self)
        }
    }
    
    static func logOut() throws -> Void{
    }
    
    @objc func fieldsFilled(_ target:UITextField) {
        if (email.text != nil && email.text != "" && password.text != nil && password.text != "") {
            logIn.enable()
        } else {
            logIn.disable()
        }
    }
    
    @objc func googleSignIn(){
        GIDSignIn.sharedInstance()?.signIn()
    }
}

extension AuthenticationController: UITextFieldDelegate {
    
}

extension AuthenticationController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
         if let error = error {
                   print(error.localizedDescription)
                   return
        }
               
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
               
        Auth.auth().signIn(with: credential) { (result, error) in
            if let error = error {
                self.presentAlertViewController(title: error.localizedDescription, message: "Please fix the issue above", completion: {})
            return
            }
            self.logIn.setTitle("Logging In...", for: .normal)
            self.logIn.disable()
            AuthenticationController.user = User(email: (result?.user.email)!, username: (result?.user.displayName)!, uid: (result?.user.uid)!)
            let docRef = db.collection("users").document((result?.user.uid)!)
            docRef.getDocument { (document, error) in
                if let document = document {
                    if document.exists {
                        self.performSegue(withIdentifier: "logIn", sender: self)
                    } else {
                        AuthenticationController.user.addUser()
                        self.performSegue(withIdentifier: "newAccount", sender: self)
                    }
                }
            }
        }
    }
}

extension AuthenticationController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            self.presentAlertViewController(title: error.localizedDescription, message: "Please try logging in again", completion: {})
            return
        }
        let accessToken = AccessToken.current
        guard let accesTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accesTokenString)
        Auth.auth().signIn(with: credentials) { (result, error) in
            if let error = error {
                self.presentAlertViewController(title: error.localizedDescription, message: "Please try signing in again", completion: {})
            }
           /* GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let user = result {
                    let answer = user as! Dictionary<String, String>
                    data = FirestoreData(email: answer["email"]!, username: answer["name"]!, uid: Auth.auth().currentUser!.uid, origin: self) //current user not initialized and throws error
                }
            }*/
            self.logIn.setTitle("Logging In...", for: .normal)
            self.logIn.disable()
            AuthenticationController.user = User(email: (result?.user.email)!, username: (result?.user.displayName)!, uid: (result?.user.uid)!)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        do {
          try Auth.auth().signOut()
        } catch let signOutError as NSError {
            self.presentAlertViewController(title: signOutError.localizedDescription, message: "Action cannot be completed", completion: {})
        }
    }
    
    @objc func simulateFacebookLogin() {
        facebookLogin.sendActions(for: .touchUpInside)
    }
}


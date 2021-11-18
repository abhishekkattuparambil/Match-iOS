//
//  SignUpController.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 10/9/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var create: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        create.layer.cornerRadius = create.frame.height/2
        navigationItem.backBarButtonItem = UIBarButtonItem(
                   title: "",
                   style: .plain,
                   target: self,
                   action: #selector(popToPrevious)
               )
        
        email.underline()
        username.underline()
        password.underline()
        username.attributedPlaceholder = NSAttributedString(string: "Username",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        password.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        email.attributedPlaceholder = NSAttributedString(string: "Email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        username.delegate = self
        email.delegate = self
        password.delegate = self
        
        password.disableAutoFill()
        
        username.addTarget(self, action: #selector(fieldsFilled), for: .editingChanged)
        email.addTarget(self, action: #selector(fieldsFilled), for: .editingChanged)
        password.addTarget(self, action: #selector(fieldsFilled), for: .editingChanged)
        
        create.disable()
    }
    
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }
    
    /*@IBAction func showPassword(_ sender: Any) {
        password.isSecureTextEntry = !password.isSecureTextEntry;
    }*/
    
    @objc func fieldsFilled(_ target:UITextField) {
        if (username.text != nil && username.text != "" && email.text != nil && email.text != "" && password.text != nil && password.text != "") {
            create.enable()
        } else {
            create.disable()
        }
    }
    
    @IBAction func createUser(_ sender: Any) {
        guard let username = username.text, let email = email.text, let pass = password.text else {return}
        
        create.disable()
        create.setTitle("Loading...", for: .normal)
        
        
        Auth.auth().createUser(withEmail: email, password: pass) { result, error in
            if error == nil && result != nil{
                print("User created!")
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                    } else {
                        self.create.setTitle("Create", for: .normal)
                        self.presentAlertViewController(title: error!.localizedDescription, message: "Please refill the form", completion:  {})
                    }
                }
                
            } else {
                self.create.setTitle("Create", for: .normal)
                self.presentAlertViewController(title: error!.localizedDescription, message: "Please refill the form", completion: {})
            }
            AuthenticationController.user = User(email: email, username: username, uid: (result?.user.uid)!)
            AuthenticationController.user.addUser()
            self.performSegue(withIdentifier: "createAccount", sender: self)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SignUpController: UITextFieldDelegate {
    
}

//
//  SettingsController.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 10/10/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class SettingsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOut(_ sender: Any) {
        let signOutHandler = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            do {
               // try AuthenticationController.handleLogOut()
                //handle local signout
                
                let loginManager = LoginManager()
                loginManager.logOut()
                try Auth.auth().signOut()
                AuthenticationController.user = nil
                self.performSegue(withIdentifier: "signOut", sender: self)
                
            } catch let err {
                self.presentAlertViewController(title: "Failed to Sign Out", message: err.localizedDescription, completion: {})
            }
        }
        let cancelHandler = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(signOutHandler)
        actionSheet.addAction(cancelHandler)
        self.present(actionSheet, animated: true, completion: nil)
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

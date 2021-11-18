//
//  InitializationController.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 10/13/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit
import Firebase

class InitializationController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
                checkUser()
        test(true)
    }
    
    func checkUser(){
        if let user = Auth.auth().currentUser {
            AuthenticationController.user = User(email: user.email ?? "", username: user.displayName!, uid: user.uid)
            self.performSegue(withIdentifier: "userSigned", sender: self)
        } else {
            self.performSegue(withIdentifier: "noUser", sender: self)
        }
    }
    
    func test(_ isNice: Bool){
        
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

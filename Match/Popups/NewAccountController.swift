//
//  NewAccountController.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 10/9/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit

class NewAccountController: UIViewController {
    @IBOutlet weak var player: UIButton!
    @IBOutlet weak var team: UIButton!
    @IBOutlet weak var popup: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.layer.cornerRadius = player.frame.height/3
        team.layer.cornerRadius = team.frame.height/3
        popup.layer.cornerRadius = 15
    }
    
    @IBAction func makePlayer(_ sender: Any) {
        AuthenticationController.user.profileType(isPlayer: true)
        presentAlertViewController(title: "Welcome \(AuthenticationController.user.username)!", message: "Please complete setting up in the profile tab")
        { self.performSegue(withIdentifier: "openApp", sender: self) }
    }
    
    @IBAction func makeTeam(_ sender: Any) {
        AuthenticationController.user.profileType(isPlayer: false)
        presentAlertViewController(title: "Welcome Team \(AuthenticationController.user.username)!", message: "Please complete setting up in the profile tab")
        { self.performSegue(withIdentifier: "openApp", sender: self) }
    }
}

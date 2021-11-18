//
//  ProfileController.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 11/4/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    @IBOutlet weak var edit: UIButton!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var cricclubs: UIButton!
    @IBOutlet weak var field: UILabel!
    @IBOutlet weak var bat: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        edit.layer.cornerRadius = edit.frame.height/2
        cricclubs.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        name.text = AuthenticationController.user.username
        field.text = "\(AuthenticationController.user.righty ?  "Righty" : "Lefty") \(AuthenticationController.user.bowlingPos!)"
        bat.text = "\(AuthenticationController.user.battingPos!) Batsman"
    }
    
    @IBAction func edit(_ sender: Any) {
        performSegue(withIdentifier: "edit", sender: self)
    }
    
    @objc func showProfile() {
        let webpage = AuthenticationController.user.website!
        if webpage != "" &&  webpage.contains("cricclubs") && UIApplication.shared.canOpenURL(URL(string: webpage) ?? URL(string: "no")!){
              UIApplication.shared.open(URL(string: webpage)!)
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

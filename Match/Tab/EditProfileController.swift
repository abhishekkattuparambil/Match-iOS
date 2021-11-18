//
//  ProfileController.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 10/15/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit

class EditProfileController: UIViewController {
    @IBOutlet weak var cricclubs: UIButton!
    @IBOutlet weak var url: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var handed: UISegmentedControl!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var batting: UIPickerView!
    @IBOutlet weak var bowling: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        url.text = "\(AuthenticationController.user.website ?? "")"
        name.text = "\(AuthenticationController.user.username ?? "")"
        
        cricclubs.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        
        
        
        cancel.layer.cornerRadius = cancel.frame.height/2
        
        batting.dataSource = self
        bowling.dataSource = self
        batting.delegate = self
        bowling.delegate = self
        
        if AuthenticationController.user.righty{
            handed.selectedSegmentIndex = 0
        } else {
            handed.selectedSegmentIndex = 1
        }
        
        batting.selectRow(Utils.batting.firstIndex(of: AuthenticationController.user.battingPos)!, inComponent: 0, animated: false)
        bowling.selectRow(Utils.bowling.firstIndex(of: AuthenticationController.user.bowlingPos)!, inComponent: 0, animated: false)
        
        
            
        
    }
    
    @IBAction func save(_ sender: Any) {
        AuthenticationController.user.website = "\(url.text!)"
        AuthenticationController.user.righty = handed.selectedSegmentIndex == 0
        AuthenticationController.user.username = "\(name.text ??  AuthenticationController.user.username)"
        AuthenticationController.user.battingPos = Utils.batting[batting.selectedRow(inComponent: 0)]
        AuthenticationController.user.bowlingPos = Utils.bowling[bowling.selectedRow(inComponent: 0)]
        
        AuthenticationController.user.updateProfile()
        
        cancel(self)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        //performSegue(withIdentifier: "save", sender: self)
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

extension EditProfileController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       if pickerView == batting{
            return Utils.batting.count
        }
        return Utils.bowling.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == batting{
            return Utils.batting[row]
        }
        return Utils.bowling[row]
    }
}

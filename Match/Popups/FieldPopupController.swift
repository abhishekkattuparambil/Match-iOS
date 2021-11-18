//
//  FieldPopupController.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 10/15/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit
import MapKit

class FieldPopupController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var proceed: UIButton!
    @IBOutlet weak var cancel: UIButton!
    public static var groundName: String! = ""
    static var map: LocationController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cancel.backgroundColor = UIColor.red
        cancel.layer.cornerRadius = cancel.frame.height/2
        proceed.layer.cornerRadius = proceed.frame.height/2
        proceed.disable()
        
        name.underline()
        name.addTarget(self, action: #selector(fieldFilled), for: .editingChanged)
    }
    
    @IBAction func `continue`(_ sender: Any) {
        FieldPopupController.groundName = name.text
        AuthenticationController.user.updateHomeGround(placemark: (FieldPopupController.map?.selectedPin!)!)
        FieldPopupController.map?.dropPinZoomIn(placemark: MKPlacemark(coordinate: (FieldPopupController.map?.map.centerCoordinate)!))
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func fieldFilled() {
        if name.text == nil || name.text == "" {
            proceed.disable()
        }
        proceed.enable()
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

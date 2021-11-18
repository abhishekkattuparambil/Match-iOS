//
//  Helper.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 10/9/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit

extension UITextField {
    func underline(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
        
    func disableAutoFill() {
        if #available(iOS 11, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .init(rawValue: "")
        }
    }
}

extension UIViewController {
    public func presentAlertViewController(title: String, message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
            completion()
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}

extension UIButton{
    func disable(){
        self.isEnabled = false;
        self.alpha = 0.4
    }
    func enable(){
        self.isEnabled = true;
        self.alpha = 1
    }
}

//
//  BookingController.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 11/9/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit
import MapKit

class BookingController: UIViewController {

    @IBOutlet weak var header: UILabel!
    var pin :MKPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        header.text = "Book \(pin?.title ?? "this ground")"
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

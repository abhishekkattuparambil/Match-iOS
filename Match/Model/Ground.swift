//
//  Ground.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 1/20/21.
//  Copyright © 2021 Abhishek Kattuparambil. All rights reserved.
//

import UIKit
import Firebase


class Ground{
    let longitude: Double
    let latitude: Double
    var name: String
    var booked: Bool
    let id: String
    var teams: [String]
    
    init(lat: Double, long: Double) {
        self.longitude = long
        self.latitude = lat
        self.name = ""
        booked = false
        id = Utils.cantor(x: lat, y: long)
        self.teams = []
    }
}

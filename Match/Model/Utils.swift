//
//  q.swift
//  Match
//
//  Created by Abhishek Kattuparambil on 11/4/20.
//  Copyright © 2020 Abhishek Kattuparambil. All rights reserved.
//

import UIKit

class Utils {

    static let batting = ["Opening", "Top Order", "Middle Order", "Tail Ender"]
    static let bowling = ["Wicketkeeper", "Fast", "Medium", "Off Spin", "Leg Spin"]

    static func cantor(x: Double, y: Double) -> String{
        return "\(y+0.5*(x+y)*(x+y+1))"
    }
}

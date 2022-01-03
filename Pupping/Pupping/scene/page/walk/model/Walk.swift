//
//  Walk.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/03.
//

import Foundation
import GoogleMaps

class Walk{
    var locations:[CLLocation] = []
    var playTime:Double = 0
    var playDistence:Double = 0
    
    func point()->Double {
        return 10 + floor(playDistence/1000)*10
    }
}

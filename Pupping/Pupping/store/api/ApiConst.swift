//
//  ApiConst.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

import UIKit

struct ApiPrefix {
    static let os =  "ios"
    static let iphone = "iphone"
    static let ipad = "ipad"
    static let service = "btvplus"
    static let device = "I"
    
}

struct ApiConst {
    static let pageSize = 24
}

struct ApiCode {
    static let success = "0000"
}

enum ApiAction:String{
    case password
}

enum ApiValue:String{
    case video
}


      

//
//  colors.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
extension Color {
    init(rgb: Int) {
        let r = Double((rgb >> 16) & 0xFF)/255.0
        let g = Double((rgb >> 8) & 0xFF)/255.0
        let b = Double((rgb ) & 0xFF)/255.0
        self.init(
            red: r,
            green: g,
            blue: b
        )
    }
    
    struct brand {
        public static let primary = Color.init(red: 255/255, green: 152/255, blue: 31/255)
        public static let primaryExtra = Color.init(red: 255/255, green: 241/255, blue: 229/255)
        public static let secondary = Color.init(red: 0/255, green:198/255, blue: 115/255)
        public static let secondaryExtra = Color.init(red: 98/255, green:201/255, blue: 150/255)
        public static let thirdly = Color.init(red: 242/255, green:39/255, blue: 11/255)
        public static let fourth = Color.init(red: 10/255, green:132/255, blue: 255/255)
        public static let fourthExtra = Color.init(red: 136/255, green:161/255, blue: 251/255)
        
        public static let bg = app.whiteDeep
    }
    struct app {
        public static let black =  Color.black
        
        public static let grey = Color.init(red: 112/255, green: 117/255, blue: 126/255)
        public static let greyDeep = Color.init(red: 51/255, green: 51/255, blue: 51/255)
        public static let greyLight = Color.init(red: 216/255, green: 216/255, blue: 225/255)
        public static let greyLightExtra = Color.init(red: 229/255, green: 231/255, blue: 235/255)
        public static let white =  Color.white
        public static let whiteDeep =  Color.init(red: 250/255, green: 250/255, blue: 250/255)
    }
    
    struct transparent {
        public static let clear = Color.black.opacity(0.0)
        public static let clearUi = Color.black.opacity(0.0001)
        public static let black70 = Color.black.opacity(0.7)
        public static let black50 = Color.black.opacity(0.5)
        public static let black45 = Color.black.opacity(0.45)
        public static let black15 = Color.black.opacity(0.15)
        
        public static let white70 = Color.white.opacity(0.7)
        public static let white50 = Color.white.opacity(0.5)
        public static let white45 = Color.white.opacity(0.45)
        public static let white20 = Color.white.opacity(0.20) 
        public static let white15 = Color.white.opacity(0.15)
    }
}



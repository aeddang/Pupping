//
//  font.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/05.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI


extension Font{
    struct customFont {
        public static let light =  Font.custom(Font.family.light, size: Font.size.light)
        public static let regular = Font.custom(Font.family.regular, size: Font.size.regular)
        public static let medium = Font.custom(Font.family.medium, size: Font.size.medium)
        public static let bold = Font.custom(Font.family.bold, size: Font.size.bold)
        public static let black = Font.custom(Font.family.black, size: Font.size.black)
    }
    
    
    struct family {
        public static let thin =  "Roboto-Light"
        public static let light =  "Roboto-Light"
        public static let regular = "Roboto-Medium"
        public static let medium =  "Roboto-Medium"
        public static let bold =  "Roboto-Boldd"
        public static let black =  "Roboto-Bold"
    }
    
    struct kern {
        public static let thin:CGFloat =  -0.7
        public static let regular:CGFloat = 0
        public static let large:CGFloat = 0.7
    }
    
    struct size {
        public static let black:CGFloat = 32//
        public static let bold:CGFloat =  20//
        public static let medium:CGFloat = 18//
        public static let regular:CGFloat = 17//
        public static let light:CGFloat =  16//
        public static let thin:CGFloat = 13//
        public static let tiny:CGFloat = 11 //
        public static let micro:CGFloat = 9
    }

}

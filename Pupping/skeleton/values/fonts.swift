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
        public static let regular = Font.custom(Font.family.regular, size: Font.size.regularExtra)
        public static let medium = Font.custom(Font.family.medium, size: Font.size.regular)
        public static let bold = Font.custom(Font.family.bold, size: Font.size.mediumExtra)
        public static let black = Font.custom(Font.family.black, size: Font.size.black)
    }
   
    
    struct family {
        public static let thin =  "Poppins-Thin"
        public static let light =  "Poppins-Light"
        public static let regular = "Poppins-Regular"
        public static let medium =  "Poppins-Medium"
        public static let bold =  "Poppins-Bold"
        public static let semiBold =  "Poppins-SemiBold"
        public static let black =  "Poppins-Black"
    }
    
    struct kern {
        public static let thin:CGFloat =  -0.7
        public static let regular:CGFloat = 0
        public static let large:CGFloat = 0.7
    }
    
    struct size {
        public static let black:CGFloat = 32//
        public static let bold:CGFloat =  26//
        public static let boldxtra:CGFloat =  24//
        public static let medium:CGFloat =  22//
        public static let mediumExtra:CGFloat =  20//
        public static let regular:CGFloat = 18//
        public static let regularExtra:CGFloat = 17//
        public static let light:CGFloat =  16//
        public static let lightExtra:CGFloat =  15//
        public static let thin:CGFloat = 14//
        public static let thinExtra:CGFloat = 13//
        public static let tiny:CGFloat = 12 //
        public static let tinyExtra:CGFloat = 11 //
        public static let micro:CGFloat = 9
    }

}

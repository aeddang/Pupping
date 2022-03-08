//
//  dimens.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct Dimen{
    struct margin {
        public static let heavy:CGFloat = 75//
        public static let mediumUltra:CGFloat = 46//
        public static let medium:CGFloat = 32//
        public static let mediumExtra:CGFloat = 26//
        public static let regular:CGFloat = 20//
        public static let regularExtra:CGFloat = 24//
        public static let light:CGFloat = 17//
        public static let lightExtra:CGFloat = 15//
        public static let thin:CGFloat = 12//
        public static let thinExtra:CGFloat = 8//
        public static let tiny:CGFloat = 6//
        public static let tinyExtra:CGFloat = 4//
        public static let micro:CGFloat =  2//
    }

    struct icon {
        public static let heavy:CGFloat = 56//
        public static let heavyExtra:CGFloat = 46//
        public static let heavyLight:CGFloat = 40//
        public static let medium:CGFloat = 38//
        public static let mediumLight:CGFloat = 36//
        public static let mediumExtra:CGFloat = 32//
        public static let regular:CGFloat = 28//
        public static let regularExtra:CGFloat = 24//
        public static let light:CGFloat = 22//
        public static let lightExtra:CGFloat = 20//
        public static let thin:CGFloat = 18//
        public static let thinExtra:CGFloat = 16//
        public static let tiny:CGFloat = 14//
        public static let micro:CGFloat = 11//
    }
    
    struct profile {
        public static let heavy:CGFloat = 80 //
        public static let medium:CGFloat = 68//
        public static let regular:CGFloat = 62//
        public static let light:CGFloat = 48//
        public static let lightExtra:CGFloat = 46//
        public static let thin:CGFloat = 34//
       
    }
    
    struct tab {
        public static let heavy:CGFloat = 85//
        public static let medium:CGFloat = 56 //
        public static let regular:CGFloat = 46
        public static let light:CGFloat = 36//
        public static let thin:CGFloat = 24//
    }
    
    struct button {
        public static let heavy:CGFloat = 70//
        public static let medium:CGFloat = 54//
        public static let regular:CGFloat = 44 //
        public static let light:CGFloat = 36 //
        public static let thin:CGFloat = 32 //
        
        public static let regularRect:CGSize = CGSize(width: 211, height: 40)
        public static let lightRect:CGSize = CGSize(width: 150, height: 30)
    }

    struct radius {
        public static let heavy:CGFloat = 32//
        public static let medium:CGFloat = 24//
        public static let regular:CGFloat = 20//
        public static let regularExtra:CGFloat = 18//
        public static let light:CGFloat = 16//
        public static let lightExtra:CGFloat = 14//
        public static let thin:CGFloat = 12//
        public static let tiny:CGFloat = 8//
        public static let micro:CGFloat = 4//
    }
    
    struct circle {
        public static let thin:CGFloat = 3//
    }
    
    struct bar {
        public static let medium:CGFloat = 34 //
        public static let regular:CGFloat = 7
        public static let light:CGFloat = 4 //*
    }
    
    struct line {
        public static let heavy:CGFloat = 10
        public static let medium:CGFloat = 6//
        public static let mediumExtra:CGFloat = 5//
        public static let regular:CGFloat =  2
        public static let light:CGFloat = 1//
    }
    
    
    struct stroke {
        public static let heavy:CGFloat =  16//
        public static let medium:CGFloat =  8 //
        public static let regular:CGFloat = 2//
        public static let light:CGFloat = 1//
    }
    
    struct app {
        public static let bottom:CGFloat = 64
        public static let top:CGFloat = 50
        public static let bottomTab:CGFloat = 100
    }
    
}


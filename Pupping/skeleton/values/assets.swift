//
//  asset.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/15.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
struct Asset {}
extension Asset {
    public static let appIcon = "launcher"
    public static let noImg16_9 = "no_image"
    public static let noImg4_3 = "no_image"
    public static let noImg1_1 = "no_image"
    public static let noImg9_16 = "no_image"
    public static let noImg3_4 = "no_image"
    public static let test = "test"
}
extension Asset{
    
    struct sample {
        public static let img1_1 = "sample1_1"
        public static let img1_2 = "sample1_2"
    }
   
    struct brand {
        public static let logoLauncher =  "launcher"
        public static let logoWhite =  "logo_text"
        public static let logoPupping =  "logo_dog"
    }
    
    struct gnb {
        public static let mission =  "ic_flag"
        public static let walk =  "ic_footPrint"
        public static let explore =  "ic_explore"
        public static let shop =  "ic_shop"
        public static let my =  "ic_my"
    }
    
    struct icon {
        
        public static let sort = "ic_sort"
        public static let filter = "ic_filter"
        public static let down = "icArrowDownG"
        public static let more = "more"
        public static var dropDown = "dropDown"
        public static let setting = "ic_setting"
        public static let add = "ic_add"
        public static let addOn = "ic_addOn"
        public static let modify = "ic_modify"
        public static let trash = "ic_trash"
        public static let close = "ic_close"
        public static let back = "ic_back"
        public static let male = "ic_male"
        public static let female = "ic_female"
        
        public static let flag = "ic_flag"
        public static let footPrint =  "ic_footPrint"
        public static let location = "ic_location"
        public static let coin = "ic_coin"
        public static let point = "ic_point"
         
        public static let delete = "ic_delete"
        public static let hidden = "ic_hidden"
        public static let next = "ic_next"
        public static let photo = "ic_photo"
        public static let fixMap = "ic_fixMap"
        
        public static let stop = "ic_stop"
        public static let pause = "ic_pause"
        public static let resume = "ic_resume"
        public static let calendar = "ic_calendar"
        public static let time = "ic_time"
        public static let speed = "ic_speed"
        public static let distence = "ic_distence"
        
        public static let destinationHeader  = "ic_destinationHeader"
        public static let wayPointHeader  = "ic_wayPointHeader"
        public static let destinationHeaderOn  = "ic_destinationHeaderOn"
        public static let wayPointHeaderOn  = "ic_wayPointHeaderOn"
    }
    
    struct map {
        public static let me = "ic_me"
        public static let destination = "ic_destination"
        public static let destinationOn = "ic_destinationOn"
        public static let wayPoint = "ic_wayPoint"
        public static let wayPointOn = "ic_wayPointOn"
        public static let startPoint = "ic_startPoint"
    }
    
    struct shape {
        public static let radioBtnOn = "sp_checkOn"
        public static let radioBtnOff = "sp_checkOff"
        
        public static let checkBoxOn = "sp_checkOn"
        public static let checkBoxOff = "sp_checkOff"
        public static let spinner = "ic_spinner"
        
        public static let point = "sp_point"
        public static let ellipse = "sp_ellipse"
        
       
    }
    
    struct image {
        public static let dog1 = "dog1"
        public static let dog2 = "dog2"
        public static let dog3 = "dog3"
        public static let dog4 = "dog4"
        public static let manWithDog = "manWithDog"
        public static let womanWithDog = "womanWithDog"
        public static let man = "man"
        public static let woman = "woman"
        public static let present = "present"
        public static let profileEmpty = "profileEmpty"
        public static let profileEmptyContent = "profileEmptyContent"
    }
    
    struct source {
        
    }
    
    struct ani {
        //public static let mic:[String] = (1...27).map{ "imgSearchMic" + $0.description.toFixLength(2) }
    }
    
    
    
    
    struct player {
        public static let resume = "icPlayerPlay"
        public static let pause = "icPlayerPause"
        public static let fullScreen = "icPlayerHalfScalemax"
        public static let fullScreenOff = "icPlayerFullScalemin"
        public static let volumeOn = "icPlayerHalfVolume"
        public static let volumeOff = "icPlayerHalfVolumeMute"
        public static let seekForward = "icPlayerHalfTimeNext"
        public static let seekBackward = "icPlayerHalfTimePrevious"
        
    }
    
}

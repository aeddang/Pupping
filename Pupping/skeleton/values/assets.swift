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
        public static let logoSplash =  "imgSplashLogo"
        public static let logoWhite =  "icHalfLogoBtv"
    }
    
    struct gnb {
        public static let mission =  "ic_mission"
        public static let board =  "ic_board"
        public static let shop =  "ic_shop"
        public static let my =  "ic_my"
    }
    
    struct icon {
        
        public static let sort = "ic_sort"
        public static let down = "icArrowDownG"
        public static let more = "more"
        public static var dropDown = "dropDown"
        public static let setting = "ic_setting"
        public static let add = "ic_add"
        public static let modify = "ic_modify"
        public static let close = "ic_close"
        public static let back = "ic_back"
        public static let mail = "ic_mail"
        public static let femail = "ic_femail"
        
        public static let flag = "ic_flag"
        public static let location = "ic_location"
        public static let pupping = "ic_pupping"
        public static let point = "ic_point"
        
        public static let delete = "ic_delete"
        public static let hidden = "ic_hidden"
        public static let next = "ic_next"
        public static let photo = "ic_photo"
    }
    
    struct shape {
        public static let radioBtnOn = "icRadioSOn"
        public static let radioBtnOff = "icRadioSOff"
        public static let checkBoxOn = "icCheckboxOn"
        public static let checkBoxOn2 = "icCheckboxOn02"
        public static let checkBoxOff = "icCheckboxOff"
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

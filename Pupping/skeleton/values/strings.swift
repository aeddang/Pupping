//
//  strings.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

extension String {
    func loaalized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    struct app {
        public static let appName = "appName".loaalized()
        public static let corfirm = "corfirm".loaalized()
        public static let close = "close".loaalized()
        public static let cancel = "cancel".loaalized()
        public static let retry = "retry".loaalized()
        
        public static let mail = "mail".loaalized()
        public static let femail = "femail".loaalized()
        public static let puppingCoin = "puppingCoin".loaalized()
        public static let point = "point".loaalized()
        public static let completeMission = "completeMission".loaalized()
        public static let year = "year".loaalized()
        public static let month = "month".loaalized()
        public static let day = "day".loaalized()
    }
    
    struct gnb {
        public static let mission = "gnbMission".loaalized()
        public static let board = "gnbBoard".loaalized()
        public static let shop = "gnbShop".loaalized()
        public static let my = "gnbMy".loaalized()
       
    }
    
    struct location {
        public static let notFound = "locationNotFound".loaalized()
    }
    
    
    struct alert {
        public static var apns = "alertApns".loaalized()

        public static var api = "alertApi".loaalized()
        public static var apiErrorServer = "alertApiErrorServer".loaalized()
        public static var apiErrorClient = "alertApiErrorClient".loaalized()
        public static var networkError = "alertNetworkError".loaalized()
        public static var dataError = "alertDataError".loaalized()
        
        public static var location = "alertLocation".loaalized()
        public static var locationSub = "alertLocationSub".loaalized()
        public static var locationBtn = "alertLocationBtn".loaalized()
        
        public static var dragdown = "alertDragdown".loaalized()
        public static var needProfile = "alertNeedProfile".loaalized()
        
    }
    
    struct button {
        public static let view = "btnView".loaalized()
        public static let album = "btnAlbum".loaalized()
        public static let camera = "btnCamera".loaalized()
        public static let delete = "btnDelete".loaalized()
        public static let prev = "btnPrev".loaalized()
        public static let next = "btnNext".loaalized()
        public static let complete = "btnComplete".loaalized()
        public static let swapPupping = "btnSwapPupping".loaalized()
    }
    
    struct pageTitle {
        public static let editProfile = "titleEditProfile".loaalized()
        public static let myRewards = "titleMyRewards".loaalized()
        public static let myPats = "titleMyPats".loaalized()
    }
    
    struct pageText {
        
        public static let profileRegistImage = "profileRegistImage".loaalized()
        public static let profileRegistName = "profileRegistName".loaalized()
        public static let profileRegistSpecies = "profileRegistSpecies".loaalized()
        public static let profileRegistBirth = "profileRegistBirth".loaalized()
        public static let profileRegistGender = "profileRegistGender".loaalized()
        public static let profileRegistNeutralization = "profileRegistNeutralization".loaalized()
        public static let profileRegistMicroFin = "profileRegistMicroFin".loaalized()
        public static let profileRegistPass = "profileRegistPass".loaalized()
        public static let profileRegistPlaceHolder = "profileRegistPlaceHolder".loaalized()
        
        public static let profileEmptyName = "profileEmptyName".loaalized()
        public static let profileEmptySpecies = "profileEmptySpecies".loaalized()

    }
    
}

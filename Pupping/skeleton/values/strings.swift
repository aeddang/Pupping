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
        public static let confirm = "confirm".loaalized()
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
        public static let step = "step".loaalized()
        public static let of = "of".loaalized()
        public static let kmPerH = "kmPerH".loaalized()
        public static let km = "km".loaalized()
        public static let m = "m".loaalized()
        public static let min = "min".loaalized()
        public static let redeem = "redeem".loaalized()
    }
    
    struct gnb {
        public static let mission = "gnbMission".loaalized()
        public static let board = "gnbBoard".loaalized()
        public static let shop = "gnbShop".loaalized()
        public static let my = "gnbMy".loaalized()
        public static let walk = "gnbWalk".loaalized()
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
        public static var deleteProfile = "alertDeleteProfile".loaalized()
        public static var snsLoginError = "alertSnsLoginError".loaalized()
        public static var currentPlayMission = "alertCurrentPlayMission".loaalized()
        public static var currentPlay =  "alertCurrentPlay".loaalized()
        public static var prevPlayWalk = "alertPrevPlayWalk".loaalized()
        public static var prevPlayMission = "alertPrevPlayMission".loaalized()
        public static var closePlayMission = "alertClosePlayMission".loaalized()
        public static var closePlayWalk = "alertClosePlayWalk".loaalized()
        public static var needProfileRegist = "alertNeedProfileRegist".loaalized()
        public static var selectProfile = "alertSelectProfile".loaalized()
        public static var needInput = "alertNeedInput".loaalized()
        public static var coinSwap = "alertCoinSwap".loaalized()
        public static var pointEmpty = "alertPointEmpty".loaalized()
    }
    
    struct button {
        public static let view = "btnView".loaalized()
        public static let album = "btnAlbum".loaalized()
        public static let camera = "btnCamera".loaalized()
        public static let delete = "btnDelete".loaalized()
        public static let modify = "btnModify".loaalized()
        public static let prev = "btnPrev".loaalized()
        public static let next = "btnNext".loaalized()
        public static let complete = "btnComplete".loaalized()
        public static let swapPupping = "btnSwapPupping".loaalized()
        public static let start = "btnStart".loaalized()
        public static let preview = "btnPreview".loaalized()
        public static let stop = "btnStop".loaalized()
        public static let pause = "btnPause".loaalized()
        public static let resume = "btnResume".loaalized()
    }
    
    struct pageTitle {
        public static let my = "titleMy".loaalized()
        public static let editProfile = "titleEditProfile".loaalized()
        public static let myRewards = "titleMyRewards".loaalized()
        public static let myDogs = "titleMyDogs".loaalized()
        public static let commingSoon = "titleCommingSoon".loaalized()
        public static let mission = "titleMission".loaalized()
        public static let missionInfo = "titleMissionInfo".loaalized()
    }
    
    struct pageText {
        
        public static let introText1_1 = "introText1_1".loaalized()
        public static let introText1_2 = "introText1_2".loaalized()
        public static let introText2_1 = "introText2_1".loaalized()
        public static let introText2_2 = "introText2_2".loaalized()
        public static let introText3_1 = "introText3_1".loaalized()
        public static let introText3_2 = "introText3_2".loaalized()
        public static let introComplete = "introComplete".loaalized()
        public static let loginText = "loginText".loaalized()
        public static let loginStart = "loginStart".loaalized()
        public static let profileRegistImage = "profileRegistImage".loaalized()
        public static let profileRegistName = "profileRegistName".loaalized()
        public static let profileRegistNameTip = "profileRegistNameTip".loaalized()
        public static let profileRegistSpecies = "profileRegistSpecies".loaalized()
        public static let profileRegistBirth = "profileRegistBirth".loaalized()
        public static let profileRegistGender = "profileRegistGender".loaalized()
        public static let profileRegistHealth = "profileRegistHealth".loaalized()
        public static let profileRegistMicroFin = "profileRegistMicroFin".loaalized()
        public static let profileRegistMicroFinInfo = "profileRegistMicroFinInfo".loaalized()
       
        public static let profileRegistNeutralized = "profileRegistNeutralized".loaalized()
        public static let profileRegistDistemperVaccinated = "profileRegistDistemperVaccinated".loaalized()
        public static let profileRegistHepatitisVaccinated = "profileRegistHepatitisVaccinated".loaalized()
        public static let profileRegistParovirusVaccinated = "profileRegistParovirusVaccinated".loaalized()
        public static let profileRegistRabiesVaccinated = "profileRegistRabiesVaccinated".loaalized()
        
        public static let profileNamePlaceHolder = "profileNamePlaceHolder".loaalized()
        public static let profileSpeciesPlaceHolder = "profileSpeciesPlaceHolder".loaalized()
        public static let profileMicroFinPlaceHolder = "profileMicroFinPlaceHolder".loaalized()
        
        public static let profileEmptyName = "profileEmptyName".loaalized()
        public static let profileEmptySpecies = "profileEmptySpecies".loaalized()
        public static let profileOption = "profileOption".loaalized()
        public static let profileCheckAll = "profileCheckAll".loaalized()
        public static let profileCancelConfirm = "profileCancelConfirm".loaalized()
        public static let profileWalkHistory = "profileWalkHistory".loaalized()
        public static let profileMissionHistory = "profileMissionHistory".loaalized()
        public static let profileHealthCare = "profileHealthCare".loaalized()
        public static let missionCompleted = "missionCompleted".loaalized()
        public static let missionCompletedText = "missionCompletedText".loaalized()
        
    }
    
}

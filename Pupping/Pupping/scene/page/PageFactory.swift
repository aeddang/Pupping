//
//  PageFactory.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import UIKit
import Foundation
import SwiftUI

extension PageID{
    static let intro:PageID = "intro"
    static let login:PageID = "login"
    static let home:PageID = "home"
    static let walk:PageID = "walk"
    static let mission:PageID = "mission"
    static let explore:PageID = "explore"
    static let missionPreview:PageID = "missionPreview"
    static let missionCompleted:PageID = "missionCompleted"
    static let walkCompleted:PageID = "walkCompleted"
    static let selectProfile:PageID = "selectProfile"
    static let board:PageID = "board"
    static let shop:PageID = "shop"
    static let my:PageID = "my"
    static let history:PageID = "history"
    static let profile:PageID = "profile"
    static let profileRegist:PageID = "profileRegist"
    static let profileModify:PageID = "profileModify"
    static let healthModify:PageID = "healthModify"
    static let user:PageID = "user"
    static let picture:PageID = "picture"
    static let pictureList:PageID = "pictureList"
    static let report:PageID = "report"
}

struct PageProvider {
    
    static func getPageObject(_ pageID:PageID)-> PageObject {
        let pobj = PageObject(pageID: pageID)
        pobj.pageIDX = getPageIdx(pageID)
        pobj.isHome = isHome(pageID)
        pobj.isAnimation = !pobj.isHome
        pobj.isDimed = getDimed(pageID)
        pobj.animationType = getType(pageID)
        pobj.zIndex = isTop(pageID) ? 1 : 0
        return pobj
    }
    
    
    static func isHome(_ pageID:PageID)-> Bool{
        switch pageID {
        case .home, .intro, .my, .board, .shop, .login, .explore: return  true
           default : return  false
        }
    }
    
    static func getType(_ pageID:PageID)-> PageAnimationType{
        switch pageID {
        case  .mission ,.missionPreview, .walk: return .vertical
        case  .missionCompleted,.walkCompleted, .selectProfile, .picture : return .opacity
        default : return  .horizontal
        }
    }
    
    static func isTop(_ pageID:PageID)-> Bool{
        switch pageID{
        case .mission, .selectProfile, .walk, .missionCompleted, .walkCompleted: return true
        default : return  false
        }
    }
    
    static func getPageIdx(_ pageID:PageID)-> Int {
        switch pageID {
            case .intro : return 1
            case .login : return 1
            case .home : return  100
            case .board : return  200
            case .explore : return 300
            case .shop : return  400
            case .my : return  500
            default : return  9999
        }
    }
    
    static func getDimed(_ pageID:PageID)-> Bool {
        switch pageID {
            default : return  false
        }
    }
    
    static func getPageTitle(_ pageID:PageID, deco:String = "")-> String {
        switch pageID {
            default : return  ""
        }
    }
}

extension PageParam {
    static let idx = "idx"
    static let id = "id"
    static let subId = "subId"
    static let link = "link"
    static let data = "data"
    static let datas = "datas"
    static let type = "type"
    static let subType = "subType"
    static let title = "title"
    static let text = "text"
    static let subText = "subText"
    static let viewPagerModel = "viewPagerModel"
    static let infinityScrollModel = "infinityScrollModel"
    
    static let autoStart = "autoStart"
}

extension PageEventType {
    static let pageChange = "pageChange"
    static let completed = "completed"
    static let cancel = "cancel"
}

enum PageStyle{
    case dark, white, normal, primary
    var textColor:Color {
        get{
            switch self {
            case .normal: return Color.app.white
            case .dark: return Color.app.white
            case .primary: return Color.app.white
            case .white: return Color.app.greyDeep
            }
        }
    }
    var bgColor:Color {
        get{
            switch self {
            case .normal: return Color.brand.bg
            case .dark: return Color.app.greyDeep
            case .primary: return Color.brand.primary
            case .white: return Color.app.white
            }
        }
    }
}

struct PageFactory{
    static func getPage(_ pageObject:PageObject) -> PageViewProtocol{
        switch pageObject.pageID {
        case .intro : return PageIntro()
        case .login : return PageLogin()
        case .home : return PageHome()
        case .explore : return PageExplore()
        case .board : return PageBoard()
        case .shop : return PageShop()
        case .my : return PageMy()
        case .history : return PageHistory()
        case .profile : return PageProfile()
        case .profileRegist: return PageProfileRegist()
        case .profileModify: return PageProfileModify()
        case .walk : return PageWalk()
        case .walkCompleted : return PageWalkCompleted()
        case .mission : return PageMission()
        case .missionPreview : return PageMissionPreview()
        case .missionCompleted : return PageMissionCompleted()
        case .selectProfile : return PageSelectProfile()
        case .user : return PageUser()
        case .picture : return PagePicture()
        case .pictureList : return PagePictureList()
        case .healthModify : return PageHealthModify()
        case .report : return PageReport()
        default : return PageTest()
        }
    }
   
}

struct PageSceneModel: PageModel {
    var currentPageObject: PageObject? = nil
    var topPageObject: PageObject? = nil
    
    func getPageOrientation(_ pageObject:PageObject?) -> UIInterfaceOrientationMask? {
        guard let pageObject = pageObject ?? self.topPageObject else { return UIInterfaceOrientationMask.all }
        switch pageObject.pageID {
        case .picture, .pictureList :  return .all
        default :  return .portrait
        }
    }
    func getPageOrientationLock(_ pageObject:PageObject?) -> UIInterfaceOrientationMask? {
        guard let pageObject = pageObject ?? self.topPageObject else { return UIInterfaceOrientationMask.all }
        switch pageObject.pageID {
        case .picture, .pictureList :  return .all
        default : return  .portrait
        }
    }
    func getUIStatusBarStyle(_ pageObject:PageObject?) -> UIStatusBarStyle? {
        guard let page = pageObject else {return .darkContent}
        switch page.pageID {
        case .picture, .profile, .user : return .lightContent
        default : return .darkContent
        }
    }
    func getCloseExceptions() -> [PageID]? {
        return [.mission, .walk]
    }
    
    func isHistoryPage(_ pageObject:PageObject ) -> Bool {
        switch pageObject.pageID {
        default : return true
        }
    }
    
    static func needBottomTab(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        case .home, .board, .shop, .my, .explore: return true
        default : return false
        }
    }
    
    static func needKeyboard(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
       // case .profileRegist , .profileModify: return true
        default : return true
        }
    }
    
}


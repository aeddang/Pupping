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
    static let home:PageID = "home"
    static let mission:PageID = "mission"
    static let my:PageID = "my"
    static let profileRegist:PageID = "profileRegist"
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
        case .home, .intro, .my, .mission : return  true
           default : return  false
        }
    }
    
    static func getType(_ pageID:PageID)-> PageAnimationType{
        switch pageID {
        case .profileRegist : return .vertical
        default : return  .horizontal
        }
    }
    
    static func isTop(_ pageID:PageID)-> Bool{
        switch pageID{
           default : return  false
        }
    }
    
    static func getPageIdx(_ pageID:PageID)-> Int {
        switch pageID {
            case .intro : return 1
            case .home : return  100
            case .mission : return  200
            case .my : return  400
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
}

extension PageEventType {
    static let pageChange = "pageChange"
    static let completed = "completed"
    static let cancel = "cancel"
}

enum PageStyle{
    case dark, white, normal
    var textColor:Color {
        get{
            switch self {
            case .normal: return Color.app.white
            case .dark: return Color.app.white
            case .white: return Color.app.black
            }
        }
    }
    var bgColor:Color {
        get{
            switch self {
            case .normal: return Color.brand.bg
            case .dark: return Color.app.greyDeep
            case .white: return Color.app.white
            }
        }
    }
}

struct PageFactory{
    static func getPage(_ pageObject:PageObject) -> PageViewProtocol{
        switch pageObject.pageID {
        case .intro : return PageIntro()
        case .home : return PageHome()
        case .mission : return PageMission()
        case .my : return PageMy()
        case .profileRegist: return PageProfileRegist()
        default : return PageTest()
        }
    }
   
}

struct PageSceneModel: PageModel {
    var currentPageObject: PageObject? = nil
    var topPageObject: PageObject? = nil
    
    func getPageOrientation(_ pageObject:PageObject?) -> UIInterfaceOrientationMask? {
        guard let pageObject = pageObject ?? self.topPageObject else {
            return UIInterfaceOrientationMask.all
        }
        switch pageObject.pageID {
        default :
            return UIInterfaceOrientationMask.all
        }
    }
    func getPageOrientationLock(_ pageObject:PageObject?) -> UIInterfaceOrientationMask? {
        guard let pageObject = pageObject ?? self.topPageObject else {
            return UIInterfaceOrientationMask.all
        }
        switch pageObject.pageID {
        default :
            return getPageOrientation(pageObject)
        }
    }
    func getCloseExceptions() -> [PageID]? {
        return []
    }
    
    func isHistoryPage(_ pageObject:PageObject ) -> Bool {
        switch pageObject.pageID {
        default : return true
        }
    }
    
    static func needBottomTab(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        case .home, .mission, .my: return true
        default : return false
        }
    }
    
    static func needKeyboard(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        case .profileRegist : return true
        default : return false
        }
    }
    
}


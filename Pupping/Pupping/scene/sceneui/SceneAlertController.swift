//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import Foundation
import SwiftUI
import Combine

enum SceneAlert {
    case confirm(String?, String?,(Bool) -> Void),
         select(String?, String?, [String], (Int) -> Void),
         alert(String?, String?, String? = nil, (() -> Void)? = nil),
         recivedApns, apiError(ApiResultError),
         requestLocation((Bool) -> Void),
         cancel
}

enum SceneAlertResult {
    case complete(SceneAlert), error(SceneAlert) , cancel(SceneAlert?), retry(SceneAlert?)
}


struct SceneAlertController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    
    @State var isShow = false
    @State var title:String? = nil
    @State var image:UIImage? = nil
    @State var text:String? = nil
    @State var subText:String? = nil
    @State var referenceText:String? = nil
    @State var tipText:String? = nil
    @State var imgButtons:[AlertBtnData]? = nil
    @State var buttons:[AlertBtnData] = []
    @State var currentAlert:SceneAlert? = nil
    @State var delayReset:AnyCancellable? = nil
    var body: some View {
        Form{
            Spacer()
        }
        .alert(
            isShowing: self.$isShow,
            title: self.title,
            image: self.image,
            text: self.text,
            subText: self.subText,
            tipText: self.tipText,
            referenceText: self.referenceText,
            imgButtons: self.imgButtons,
            buttons: self.buttons
        ){ idx in
            switch self.currentAlert {
            case .alert(_, _, _, let completionHandler) :
                if let handler = completionHandler { self.selectedAlert(idx, completionHandler:handler) }
            case .select(_, _, _, let completionHandler) : self.selectedSelect(idx, completionHandler:completionHandler)
            case .confirm(_, _, let completionHandler) : self.selectedConfirm(idx, completionHandler:completionHandler)
            case .apiError(let data): self.selectedApi(idx, data:data)
            case .requestLocation(let completionHandler): self.selectedRequestLocation(idx, completionHandler:completionHandler)
            case .recivedApns: self.selectedRecivedApns(idx)
            default: do { return }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reset()
            }
        
        }
        .onReceive(self.appSceneObserver.$alert){ alert in
            self.reset()
            self.currentAlert = alert
            switch alert{
            case .cancel :
                self.isShow = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.reset()
                }
                return
            case .alert(let title,let text, let subText, _) : self.setupAlert(title:title, text:text, subText:subText)
            case .select(let title,let text, let selects, _) : self.setupSelect(title: title, text: text, selects: selects)
            case .confirm(let title,let text, _) : self.setupConfirm(title:title, text:text)
            case .apiError(let data): self.setupApi(data:data)
            case .requestLocation: self.setupRequestLocation()
            case .recivedApns: self.setupRecivedApns()
            default: do { return }
            }
            withAnimation{
                self.isShow = true
            }
        }
    }//body
    
    func reset(){
        if self.isShow { return }
        self.title = nil
        self.image = nil
        self.text = nil
        self.subText = nil
        self.tipText = nil
        self.referenceText = nil
        self.buttons = []
        self.imgButtons = nil
        self.currentAlert = nil
    }

    func setupRecivedApns(){
        guard let apns = self.appObserver.apns else { return  }
        guard let alert = apns["alert"] as? [String:String] else { return }
        self.title = String.alert.apns
        self.text = alert["title"] as String? ?? ""
        self.subText = alert["body"] as String? ?? ""
        if (self.appObserver.page?.page) != nil {
            self.buttons = [
                AlertBtnData(title: String.app.cancel, index: 0),
                AlertBtnData(title: String.app.confirm, index: 1)
            ]
        }else{
            self.buttons = [
                AlertBtnData(title: String.app.confirm, index: 0)
            ]
        }
    }
    
    func selectedRecivedApns(_ idx:Int) {
        if idx == 1 {
            guard let page = self.appObserver.page?.page else { return }
            if page.isPopup {
                self.pagePresenter.openPopup(page)
            }else{
                self.pagePresenter.changePage(page)
            }
        }
        self.appObserver.resetApns()
    }
    
    func setupApi(data:ApiResultError) {
        self.title = String.alert.api
        if let apiError = data.error as? ApiError {
            self.text = ApiError.getViewMessage(response: apiError.response)
            self.buttons = [
                AlertBtnData(title: String.app.confirm, index: 2),
            ]
        }else{
            if self.networkObserver.status == .none {
                self.text = String.alert.apiErrorClient
                self.buttons = [
                    AlertBtnData(title: String.app.cancel, index: 0),
                    AlertBtnData(title: String.app.retry, index: 1),
                ]
                
            }else{
                self.text = String.alert.apiErrorServer
                self.buttons = [
                    AlertBtnData(title: String.app.confirm, index: 2),
                ]
            }
        }
    }
    
    func selectedApi(_ idx:Int, data:ApiResultError) {
        if idx == 1 {
            if data.isProcess {
                self.appSceneObserver.alertResult = .retry(nil)
            }else{
                self.dataProvider.requestData(q:.init(type:data.type))
            }
            
        }else if idx == 0  {
            self.appSceneObserver.alertResult = .cancel(nil)
        }
    }
    
    
    
    func setupRequestLocation() {
        
        self.text = String.alert.location
        self.subText = String.alert.locationSub
        self.buttons = [
            AlertBtnData(title: String.alert.locationBtn, index: 0),
            AlertBtnData(title: String.app.cancel, index: 1)
        ]
    }
    func selectedRequestLocation(_ idx:Int, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(idx == 0)
    }
    
    func setupConfirm(title:String?, text:String?) {
        self.title = title
        self.text = text ?? ""
        self.buttons = [
            AlertBtnData(title: String.app.cancel, index: 0),
            AlertBtnData(title: String.app.confirm, index: 1)
        ]
    }
    func selectedConfirm(_ idx:Int,  completionHandler: @escaping (Bool) -> Void) {
        completionHandler(idx == 1)
    }
    
    func setupAlert(title:String?, text:String?, subText:String? = nil) {
        self.title = title
        self.text = text ?? ""
        self.subText = subText
        self.buttons = [
            AlertBtnData(title: String.app.confirm, index: 0)
        ]
    }
    func selectedAlert(_ idx:Int, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    
    func setupSelect(title:String?, text:String?, selects:[String] ) {
        self.title = title
        self.text = text ?? ""
        self.imgButtons = zip(selects, 0..<selects.count).map{ img, idx in
            AlertBtnData(title: "", img: img, index: idx)
        }
    }
    func selectedSelect(_ idx:Int, completionHandler: @escaping (Int) -> Void) {
        completionHandler(idx)
    }
}



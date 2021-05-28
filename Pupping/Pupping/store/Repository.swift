//
//  Repository.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

enum RepositoryStatus{
    case initate, ready, reset
}

class Repository:ObservableObject, PageProtocol{
    @Published var status:RepositoryStatus = .initate
    
    let appSceneObserver:AppSceneObserver?
    let pagePresenter:PagePresenter?
    let dataProvider:DataProvider
    let networkObserver:NetworkObserver
    let shareManager:ShareManager
    let snsManager:SnsManager
    let apiCoreDataManager = ApiCoreDataManager()
    private let storage = LocalStorage()
    private let apiManager = ApiManager()
   
    
    private var anyCancellable = Set<AnyCancellable>()
    private var dataCancellable = Set<AnyCancellable>()
     
    init(
        dataProvider:DataProvider? = nil,
        networkObserver:NetworkObserver? = nil,
        pagePresenter:PagePresenter? = nil,
        sceneObserver:AppSceneObserver? = nil,
        snsManager:SnsManager? = nil
    ) {
        self.dataProvider = dataProvider ?? DataProvider()
        self.networkObserver = networkObserver ?? NetworkObserver()
        self.appSceneObserver = sceneObserver
        self.pagePresenter = pagePresenter
        self.shareManager = ShareManager(pagePresenter: pagePresenter)
        self.snsManager = snsManager ?? SnsManager()
        
        self.pagePresenter?.$currentPage.sink(receiveValue: { evt in 
            self.apiManager.clear()
            self.appSceneObserver?.isApiLoading = false
            self.pagePresenter?.isLoading = false
            self.retryRegisterPushToken()
        }).store(in: &anyCancellable)
        self.setupSetting()
        self.setupDataProvider()
        self.setupApiManager()

      
    }
    
    deinit {
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
    }
    
    private func setupDataProvider(){
        self.dataProvider.user.setProfiles()
        self.dataProvider.$request.sink(receiveValue: { req in
            guard let apiQ = req else { return }
            if apiQ.isLock {
                self.pagePresenter?.isLoading = true
            }else{
                self.appSceneObserver?.isApiLoading = true
            }
            if let coreDatakey = apiQ.type.coreDataKey(){
                self.requestApi(apiQ, coreDatakey:coreDatakey)
            }else{
                self.apiManager.load(q: apiQ)
            }
        }).store(in: &anyCancellable)
    }
    
    private func setupApiManager(){
        
        self.apiManager.$status.sink(receiveValue: { status in
            switch status {
            case .ready : self.status = .ready
            default: break
            }
        }).store(in: &dataCancellable)
        
        self.apiManager.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            self.respondApi(res)
            self.dataProvider.result = res
            self.appSceneObserver?.isApiLoading = false
            self.pagePresenter?.isLoading = false
        
        }).store(in: &dataCancellable)
        
        self.apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            self.dataProvider.error = err
            if !err.isOptional {
                self.appSceneObserver?.alert = .apiError(err)
            }
            self.appSceneObserver?.isApiLoading = false
            self.pagePresenter?.isLoading = false
            
        }).store(in: &dataCancellable)
    }
    
    private func setupSetting(){
        if !self.storage.initate {
            self.storage.initate = true
            SystemEnvironment.firstLaunch = true
            DataLog.d("initate APP", tag:self.tag)
        }
        self.dataProvider.user.registUser(
            id: self.storage.loginId,
            token: self.storage.loginToken,
            code: self.storage.loginType)
        
        if self.storage.retryPushToken != "" {
            self.registerPushToken(self.storage.retryPushToken)
        }
    }
    
    private func requestApi(_ apiQ:ApiQ, coreDatakey:String){
        DispatchQueue.global(qos: .background).async(){
            var coreData:Codable? = nil
            switch apiQ.type {
                case .getGnb : break
                default: break
            }
            DispatchQueue.main.async {
                if let coreData = coreData {
                    self.dataProvider.result = ApiResultResponds(id: apiQ.id, type: apiQ.type, data: coreData)
                    self.appSceneObserver?.isApiLoading = false
                    self.pagePresenter?.isLoading = false
                }else{
                    self.apiManager.load(q: apiQ)
                }
            }
        }
    }
    private func respondApi(_ res:ApiResultResponds){
        if let coreDatakey = res.type.coreDataKey(){
            self.respondApi(res, coreDatakey: coreDatakey)
        }
    }
    
    private func respondApi(_ res:ApiResultResponds, coreDatakey:String){
        DispatchQueue.global(qos: .background).async(){
            switch res.type {
                case .getGnb :
                    //guard let data = res.data as? GnbBlock  else { return }
                    DataLog.d("save coreData getGnb", tag:self.tag)
                    //self.apiCoreDataManager.setData(key: coreDatakey, data: data)
                default: break
            }
        }
    }
    
    // PushToken
    func retryRegisterPushToken(){
        if self.storage.retryPushToken != "" {
            self.registerPushToken(self.storage.retryPushToken)
        }
    }
    
    func registerPushToken(_ token:String) {
        self.storage.retryPushToken = token
    }
    
    func registerSnsLogin(_ user:SnsUser) {
        self.storage.loginId = user.snsID
        self.storage.loginToken = user.snsToken
        self.storage.loginType = user.snsType.apiCode()
        self.dataProvider.user.registUser(user: user)
    }
    var isLogin: Bool {
        self.dataProvider.user.snsUser != nil
    }
   
}

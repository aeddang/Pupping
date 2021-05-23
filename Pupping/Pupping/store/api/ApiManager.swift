//
//  ApiManager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Combine
enum ApiStatus{
    case initate, ready
}

enum ApiEvents{
    case pairingHostChanged, pairingUpdated(PairingUpdateData)
}

enum UpdateFlag:String{
    case none ,force ,recommend ,emergency ,advance
    static func getFlag(_ value:String?)->UpdateFlag{
        switch value {
            case "0", "none": return .none
            case "1", "force": return .force
            case "2", "recommend": return .recommend
            case "3", "emergency": return .emergency
            case "4", "advance": return .advance
            default : return .none
        }
    }
}

enum PairingUpdateFlag:String{
    case none ,forceUnpairing ,upgrade
    static func getFlag(_ value:String?)->PairingUpdateFlag{
        switch value {
            case "0": return .none
            case "1": return .forceUnpairing
            case "2": return .upgrade
            default : return .none
        }
    }
}

struct PairingUpdateData {
    var updateFlag:PairingUpdateFlag? = nil
    var productName:String? = nil
    var maxCount:Int? = nil
    var count:Int? = nil
    
}


class ApiManager :PageProtocol, ObservableObject{
    @Published var status:ApiStatus = .initate
    @Published var result:ApiResultResponds? = nil {didSet{ if result != nil { result = nil} }}
    @Published var error:ApiResultError? = nil {didSet{ if error != nil { error = nil} }}
    @Published var event:ApiEvents? = nil {didSet{ if event != nil { event = nil} }}
    
    
    private var anyCancellable = Set<AnyCancellable>()
    private var apiQ :[ ApiQ ] = []
   
    private(set) var updateFlag: UpdateFlag = .none
    init() {
        self.initateApi()
    }
    
    func clear(){
        if self.status == .initate {return}
        self.apiQ.removeAll()
    }
    
    private func initateApi()
    {
        self.status = .ready
        self.executeQ()
    }
    
    private func executeQ(){
        self.apiQ.forEach{ q in self.load(q: q)}
        self.apiQ.removeAll()
    }
    

    private var transition = [String : ApiQ]()
    func load(q:ApiQ){
        switch q.type {
        case .getGnb: break
        default : break
        }
        self.load(q.type, action: q.action, resultId: q.id, isOptional: q.isOptional, isProcess: q.isProcess)
    }
    

    @discardableResult
    func load(_ type:ApiType, action:ApiAction? = nil,
              resultId:String = "", isOptional:Bool = false, isLock:Bool = false, isProcess:Bool = false)->String
    {
        let apiID = resultId //+ UUID().uuidString
        if status != .ready{
            self.apiQ.append(ApiQ(id: resultId, type: type, action: action, isOptional: isOptional, isLock: isLock))
            return apiID
        }
        let error = {err in self.onError(id: apiID, type: type, e: err, isOptional: isOptional, isProcess: isProcess)}
        
        switch type {
        case .getGnb : break
            /*
            self.euxp.getGnbBlock(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
            */
        }
        return apiID
    }
    
    private func complated<T:Decodable>(id:String, type:ApiType, res:T){
        let result:ApiResultResponds = .init(id: id, type:type, data: res)
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = .init(id: id, type:type, data: res)
        }
    }
    
    
    private func complated(id:String, type:ApiType, res:Blank){
        let result:ApiResultResponds = .init(id: id, type:type, data: res)
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = .init(id: id, type:type, data: res)
        }
    }
    
    private func onError(id:String, type:ApiType, e:Error,isOptional:Bool = false, isProcess:Bool = false){
        if let trans = transition[id] {
            transition.removeValue(forKey: id)
            self.error = .init(id: id, type:trans.type, error: e, isOptional:isOptional, isProcess:isProcess)
        }else{
            self.error = .init(id: id, type:type, error: e, isOptional:isOptional, isProcess:isProcess)
        }
        
    }

    
}

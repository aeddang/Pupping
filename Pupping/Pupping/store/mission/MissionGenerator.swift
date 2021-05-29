//
//  Missionㅎenerator.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/29.
//

import Foundation
import SwiftUI
import GooglePlaces

enum MissionGeneratorEvent {
    case error(id:String? = nil), create(Mission, id:String? = nil)
}

enum MissionGeneratorRequest {
    case create(type:MissionType? = nil, playType:MissionPlayType? = nil)
}


class MissionGenerator:ObservableObject, PageProtocol{
    @Published private(set) var request:MissionGeneratorRequest? = nil
        {didSet{ if request != nil { request = nil} }}
    @Published private(set) var event:MissionGeneratorEvent? = nil
        {didSet{ if event != nil { event = nil} }}
    
    let placesClient = GMSPlacesClient.shared()
    
    private var requestQ :[ MissionGeneratorRequest ] = []
    private var isBusy:Bool = false
    private var currentId:String? = nil
    func request(q:MissionGeneratorRequest, id:String? = nil){
        if isBusy {
            requestQ.append(q)
            return
        }
        self.currentId = id
        self.request = request
        switch q {
        case .create(let type,let playType) : self.createMission(type: type, playType: playType)
        }
    }
    
    private func createMission(type:MissionType?,playType:MissionPlayType? ){
        self.isBusy = true
        let genType = type ?? MissionType.random()
        let genPlayType = playType ?? MissionPlayType.random()
        
        switch genPlayType {
        case .location :
            self.getCurrentPlace(){ place in
                
            }
        case .duration :
            self.getCurrentPlace(){ place in
                
            }
        case .speed :
            self.getCurrentPlace(){ place in
                
            }
        }
    }
    
    
    
    private func getCurrentPlace(completionHandler: @escaping (GMSPlace) -> Void){
        placesClient.currentPlace{ [weak self] (result, error) -> Void in
            guard let self = self else { return }
            if let error = error {
                DataLog.d("error: \(error.localizedDescription)", tag: self.tag)
                return
            }
            guard let result = result?.likelihoods.first else {
                
                return
            }
        }
    }
    
}




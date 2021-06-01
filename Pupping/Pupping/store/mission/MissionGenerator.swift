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
    case created(Mission, id:String? = nil)
}

enum MissionGeneratorError {
    case apiError(id:String?), notFound(id:String?)
}

enum MissionGeneratorRequest {
    case create(type:MissionType? = nil, playType:MissionPlayType? = nil, lv:MissionLv? = nil, keyword:String? = nil)
}

struct MissionRequestQ :Identifiable{
    var id:String = UUID().uuidString
    let request:MissionGeneratorRequest
}

extension CashedPlace {
    static let resetTime:Double = 10
}

struct CashedPlace {
    let date:Date
    let places:[GMSPlace]
}



class MissionGenerator:ObservableObject, PageProtocol{
    @Published private(set) var request:MissionGeneratorRequest? = nil
        {didSet{ if request != nil { request = nil} }}
    @Published private(set) var event:MissionGeneratorEvent? = nil
        {didSet{ if event != nil { event = nil} }}
    @Published private(set) var error:MissionGeneratorError? = nil
        {didSet{ if error != nil { error = nil} }}
    
    let placesClient = GMSPlacesClient.shared()
    var finalLocation:CLLocation? = nil
    
    private var requestQ :[ MissionRequestQ ] = []
    @Published private(set) var isBusy:Bool = false
    private var currentId:String? = nil
    func request(q:MissionGeneratorRequest, id:String? = nil){
        if isBusy {
            requestQ.append(MissionRequestQ(id: id ?? UUID().uuidString, request: q))
            return
        }
        self.currentId = id
        self.request = request
        switch q {
        case .create(let type,let playType, let lv, let keyword) :
            self.createMission(type: type, playType: playType, lv: lv, keyword:keyword)
        }
    }
    private func executeQ(){
        self.isBusy = false
        guard let next = requestQ.first else { return }
        self.requestQ.removeFirst()
        self.request(q:next.request,id:next.id)
    }
    
    private func createMission(type:MissionType?,playType:MissionPlayType?, lv:MissionLv?, keyword:String? ){
        self.isBusy = true
        let genType = type ?? MissionType.random()
        let genPlayType = playType ?? MissionPlayType.random()
        let genLv = lv ?? MissionLv.random()
        let mission = Mission(type: genType, playType: genPlayType, lv: genLv)
        switch genPlayType {
        case .nearby :
            self.getCurrentPlace(){ place in
                mission.add(start: place)
                self.getNearbyPlace(){ nearbyPlaces in
                    mission.add(destinations: nearbyPlaces)
                    created()
                }
            }
        case .location :
            let genKeyword = keyword ?? MissionKeyword.random().keyword()
            self.getCurrentPlace(){ place in
                mission.add(start: place)
                self.getKeywordPlace(genKeyword){ keywordPlaces in
                    mission.add(recommandPlaces: keywordPlaces)
                    let keyword = keywordPlaces.randomElement()
                    self.lookUp(placeId: keyword?.placeID ?? ""){ place in
                        mission.add(destinations: [place])
                        created()
                    }
                }
            }
        case .endurance :
            self.getCurrentPlace(){ place in
                mission.add(start: place)
                created()
            }
        case .speed :
            self.getCurrentPlace(){ place in
                mission.add(start: place)
                created()
            }
        }
        
        func created (){
            mission.build()
            self.event = .created(mission, id: self.currentId)
            self.executeQ()
        }
        
    }
    
    private func lookUp(placeId:String, completionHandler: @escaping (GMSPlace) -> Void){
        self.isBusy = true
        placesClient.lookUpPlaceID(placeId){[weak self] (result, error) -> Void in
            guard let self = self else { return }
            if let error = error {
                DataLog.e("lookUp error: \(error.localizedDescription)", tag: self.tag)
                self.error = .apiError(id: self.currentId)
                self.executeQ()
                return
            }
            if let result = result {
                DataLog.d("lookUp Place " + (result.name ?? "no data"), tag: self.tag)
                completionHandler(result)
            } else {
                DataLog.d("lookUp Place notfound", tag: self.tag)
                self.error = .notFound(id: self.currentId)
                self.executeQ()
            }
        }
    }
    
    private var cashedCurrentPlace:CashedPlace? = nil
    private func getCurrentPlace(completionHandler: @escaping (GMSPlace) -> Void){
        if let cashed = self.cashedCurrentPlace {
            let diff  = cashed.date.timeIntervalSinceNow
            if diff < CashedPlace.resetTime, let place = cashed.places.first {
                completionHandler(place)
                return
            }
        }
        placesClient.currentPlace{ [weak self] (result, error) -> Void in
            guard let self = self else { return }
            if let error = error {
                DataLog.e("getCurrentPlace error: \(error.localizedDescription)", tag: self.tag)
                self.error = .apiError(id: self.currentId)
                self.executeQ()
                return
            }
            guard let result = result?.likelihoods.first else {
                self.error = .notFound(id: self.currentId)
                self.executeQ()
                return
            }
            DataLog.d("CurrentPlace " + (result.place.name ?? "no data"), tag: self.tag)
            self.cashedCurrentPlace = CashedPlace(date: Date(), places: [result.place])
            completionHandler(result.place)
            
        }
    }
    
    private var cashedNearbyPlaces:CashedPlace? = nil
    private func getNearbyPlace(completionHandler: @escaping ([GMSPlace]) -> Void){
        let placeFields: GMSPlaceField = [.name, .formattedAddress, .coordinate, .placeID]
        if let cashed = self.cashedNearbyPlaces {
            let diff  = cashed.date.timeIntervalSinceNow
            if diff < CashedPlace.resetTime{
                completionHandler(cashed.places)
                return
            }
        }
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
            guard let self = self else { return }
            guard error == nil else {
                DataLog.e("getNearbyPlace error: \(error?.localizedDescription ?? "")", tag: self.tag)
                self.error = .apiError(id: self.currentId)
                self.executeQ()
                return
            }
            guard let placeLikelihoods = placeLikelihoods else {
                self.error = .notFound(id: self.currentId)
                self.executeQ()
                return
            }
            if placeLikelihoods.isEmpty {
                self.error = .notFound(id: self.currentId)
                self.executeQ()
                return
            }
            #if DEBUG
                placeLikelihoods.forEach{ location in
                    DataLog.d("NearbyPlace " + (location.place.name ?? "no data"), tag: self.tag)
                }
            #endif
            let places = placeLikelihoods.map{$0.place}
            self.cashedNearbyPlaces = CashedPlace(date: Date(), places: places)
            completionHandler(places)
        }
    }
    
    private func getKeywordPlace(_ ketword:String, completionHandler: @escaping ([GMSAutocompletePrediction]) -> Void){
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        if let location = self.finalLocation {
            DataLog.d("getKeywordPlace origin: \(location.altitude.debugDescription)", tag: self.tag)
            filter.origin = location
        }
        //filter.locationBias = GMSPlaceLocationBias
        placesClient.findAutocompletePredictions(fromQuery: ketword, filter: filter, sessionToken: nil){[weak self] (results, error) -> Void in
            guard let self = self else { return }
            if let error = error {
                DataLog.d("getKeywordPlace error: \(error.localizedDescription)", tag: self.tag)
                self.error = .apiError(id: self.currentId)
                self.executeQ()
                return
            }
            guard let results = results else {
                self.error = .notFound(id: self.currentId)
                self.executeQ()
                return
            }
            if results.isEmpty {
                self.error = .notFound(id: self.currentId)
                self.executeQ()
                return
            }
            #if DEBUG
                results.forEach{ location in
                    DataLog.d("KeywordPlace " + location.attributedPrimaryText.string , tag: self.tag)
                }
            #endif
            completionHandler(results)
        }
    }
}




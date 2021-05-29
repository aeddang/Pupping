//
//  Profile.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/19.
//

import Foundation
import SwiftUI
import UIKit

import GooglePlaces

enum MissionType:CaseIterable {
    case today, event, always
    
    static func random() -> MissionType{
        return Self.allCases.map{$0}.randomElement()! 
    }
}

enum MissionPlayType:CaseIterable {
    case location, speed, duration
    
    static func random() -> MissionPlayType{
        return Self.allCases.map{$0}.randomElement()!
    }
}

class Mission:ObservableObject, PageProtocol{
    let type:MissionType
    let playType:MissionPlayType
    let placesClient = GMSPlacesClient.shared()
    private (set) var title:String = ""
    private (set) var description:String = ""
    private (set) var destinations:[GMSPlace] = []
    
    init(type:MissionType, playType:MissionPlayType){
        self.type = type
        self.playType = playType
            
        let filter = GMSAutocompleteFilter()
        
        filter.type = .establishment
        
        //filter.locationBias = GMSPlaceLocationBias
        
        
        placesClient.lookUpPlaceID(""){[weak self] (result, error) -> Void in
            guard let self = self else { return }
            if let error = error {
                DataLog.d("error: \(error.localizedDescription)", tag: self.tag)
                return
            }
            if let result = result {
                
            }
        }
        
        placesClient.findAutocompletePredictions(fromQuery: "편의점", filter: filter, sessionToken: nil){[weak self] (results, error) -> Void in
            guard let self = self else { return }
            if let error = error {
                DataLog.d("error: \(error.localizedDescription)", tag: self.tag)
                return
            }
            if let results = results {
                for result in results {
                    //self.primaryAddressArray.append(result.attributedPrimaryText.string)
                    DataLog.d("primary text: \(result.attributedPrimaryText.string)", tag: self.tag)
                    DataLog.d("primary text: \(result.placeID)", tag: self.tag)
                   // self.resultsArray.append(result.attributedFullText.string)
                   // self.primaryAddressArray.append(result.attributedPrimaryText.string)
                    //self.placeIDArray.append(result.placeID!)
                }
            }
        }
        
        let placeFields: GMSPlaceField = [.name, .formattedAddress, .coordinate, .placeID]
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
            guard let self = self else { return }
            guard error == nil else {
                DataLog.d("Current place error: \(error?.localizedDescription ?? "")", tag: self.tag)
                return
            }

            placeLikelihoods?.forEach{ location in
                DataLog.d("place.name " + (location.place.name ?? "no data"), tag: self.tag)
                
            }
              
        }
    }
    
    
    private func getCurrentPlace(){
        placesClient.currentPlace{ [weak self] (result, error) -> Void in
            guard let self = self else { return }
            if let error = error {
                DataLog.d("error: \(error.localizedDescription)", tag: self.tag)
                return
            }
            if let result = result {
                result.likelihoods.forEach{ location in
                    DataLog.d("currentPlace.name " + (location.place.name ?? "no data"), tag: self.tag)
                    
                }
            }
        }
    }
    
}




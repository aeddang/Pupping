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
    func info() -> String{
        switch self {
        case .today: return "Today’s Mission"
        case .event: return "Event!! Mission"
        case .always: return "Any Time Mission"
        }
    }
    static func random() -> MissionType{
        return Self.allCases.map{$0}.randomElement()! 
    }
}

enum MissionPlayType:CaseIterable {
    case nearby, location, speed, endurance
    func info() -> String{
        switch self {
        case .nearby: return "주면 둘러 보기"
        case .location: return "주변 시설 알아보기"
        case .speed : return "스피드 기르기"
        case .endurance : return "지구력 기르기"
        }
    }
    static func random() -> MissionPlayType{
        return Self.allCases.map{$0}.randomElement()!
    }
}

enum MissionLv:CaseIterable {
    case lv1, lv2, lv3, lv4
    func info() -> String{
        switch self {
        case .lv1: return "쉬움"
        case .lv2: return "보통"
        case .lv3: return "어려움"
        case .lv4: return "매우 어려움"
        }
    }
    func speed() -> Double{ // meter per sec
        switch self {
        case .lv1: return 1000 / 3600
        case .lv2: return 1500 / 3600
        case .lv3: return 3000 / 3600
        case .lv4: return 5000 / 3600
        }
    }
    
    func locationCount() -> Int{ // meter
        switch self {
        case .lv1: return 1
        case .lv2: return 2
        case .lv3: return 3
        case .lv4: return 4
        }
    }
    
    func distance() -> Double{ // meter
        switch self {
        case .lv1: return 1000
        case .lv2: return 1500
        case .lv3: return 3000
        case .lv4: return 5000
        }
    }
    
    func duration() -> Double{ // sec
        switch self {
        case .lv1: return 30 * 60
        case .lv2: return 60 * 60
        case .lv3: return 90 * 60
        case .lv4: return 120 * 60
        }
    }
    
    static func random() -> MissionLv{
        return Self.allCases.map{$0}.randomElement()!
    }
}


enum MissionKeyword: CaseIterable {
    case convenience, animalHospital, mart
    
    func keyword() -> String{
        switch self {
        case .convenience: return "편의점"
        case .animalHospital: return "동물병원"
        case .mart : return "마트"
        }
    }
    static func random() -> MissionKeyword{
        return Self.allCases.map{$0}.randomElement()! 
    }
}

class Mission:ObservableObject, PageProtocol, Identifiable{
    let id:String = UUID().uuidString
    let type:MissionType
    let lv:MissionLv
    let playType:MissionPlayType
    let placesClient = GMSPlacesClient.shared()
    
    private (set) var description:String = ""
    private (set) var recommandPlaces:[GMSAutocompletePrediction] = []
    private (set) var start:GMSPlace? = nil
    private (set) var destination:GMSPlace? = nil
    private (set) var waypoints:[GMSPlace] = []
    private (set) var startTime:Double = 0
    private (set) var endTime:Double = 0
    private (set) var totalDistence:Double = 0 //miter
    private (set) var duration:Double = 0 //sec
    private (set) var speed:Double = 0 //meter per hour
    //play
    private (set) var playTime:Double = 0
    private (set) var playDistence:Double = 0
    
    init(type:MissionType, playType:MissionPlayType, lv:MissionLv){
        self.type = type
        self.playType = playType
        self.lv = lv
    }
    
    @discardableResult
    func add(start:GMSPlace) -> Mission {
        self.start = start
        return self
    }
    
    @discardableResult
    func add(destinations:[GMSPlace]) -> Mission {
        var pickList = destinations
        let len = min(destinations.count,self.lv.locationCount())
        (0..<len).forEach{_ in
            if let pick = pickList.randomElement() {
                if let idx =  pickList.firstIndex(where: {$0.placeID == pick.placeID}) {
                    pickList.remove(at: idx)
                }
                if  self.destination == nil {
                    self.destination = pick
                } else {
                    self.waypoints.append(pick)
                }
            }
        }
        return self
    }
    
    @discardableResult
    func add(recommandPlaces:[GMSAutocompletePrediction]) -> Mission {
        self.recommandPlaces = recommandPlaces
        return self
    }
    
    var viewSpeed:String {
        return (self.speed * 3600 / 1000).toTruncateDecimal(n:1) + "km/h"
    }
    var viewDistence:String {
        return (self.totalDistence/1000).toTruncateDecimal(n:1) + "Km"
    }
    var viewDuration:String {
        return (self.duration/60).toTruncateDecimal(n:1) + "분"
    }
    
    @discardableResult
    func build() -> Mission {
        guard let start = self.start else { return self }
        if let destination = self.destination {
            var desc = ""
            var distence:Double = 0
            var prevLoc:CLLocation = CLLocation(latitude: start.coordinate.latitude, longitude: start.coordinate.longitude)
            let way:String = " -> "
            waypoints.filter{$0.name != nil}.forEach{ waypoint in
                let loc = CLLocation(latitude: waypoint.coordinate.latitude, longitude: waypoint.coordinate.longitude)
                let diff = prevLoc.distance(from: loc)
                distence += diff
                desc += waypoint.name! + way 
                prevLoc = loc
            }
            distence += prevLoc.distance(from: CLLocation(latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude))
            self.speed = self.lv.speed()
            self.totalDistence = distence
            self.duration = ceil(distence/self.speed)
            if !desc.isEmpty {
                desc.removeLast(way.count)
                let trailing = self.destination?.name ?? ""
                self.description = desc + "\n를(을) 경유하여 " + viewDuration + " 안에\n" + trailing + "로(으로) 이동"
            } else {
                self.description = viewDuration + " 안에\n" + (destination.name ?? "") + "로(으로) 이동"
            }
        } else {
            switch self.playType {
            case .endurance:
                self.totalDistence = self.lv.distance()
                self.duration = self.lv.duration()
                self.speed = ceil(self.totalDistence/self.duration)
                self.description =
                    viewDuration + " 동안 "
                    + viewDistence + " 이상 이동"
            case .speed:
                self.totalDistence = MissionLv.lv1.distance()
                self.speed = self.lv.speed()
                self.duration = ceil(self.totalDistence/self.speed)
                self.description =
                    viewSpeed + " 이상 속도로 "
                    + viewDistence + " 이동"
            default: break
            }
            
        }
        return self
    }
    
}




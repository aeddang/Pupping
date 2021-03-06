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
    func color() -> Color{
        switch self {
        case .today: return Color.brand.primary
        case .event: return Color.brand.thirdly
        case .always: return Color.brand.secondary
        }
    }
    static func random() -> MissionType{
        return Self.allCases.map{$0}.randomElement()! 
    }
}

enum MissionPlayType:CaseIterable, Equatable {
    case nearby, location, speed, endurance
    func info() -> String{
        switch self {
        case .nearby: return String.play.around
        case .location: return String.play.location
        case .speed : return String.play.speed
        case .endurance : return String.play.endurance
        }
    }
   
    static func random() -> MissionPlayType{
        return Self.allCases.map{$0}.randomElement()!
    }
    static func ==(lhs: MissionPlayType, rhs: MissionPlayType) -> Bool {
        switch (lhs, rhs) {
        case ( .nearby, .nearby): return true
        case ( .location, .location): return true
        case ( .speed, .speed): return true
        case ( .endurance, .endurance): return true
        default : return false
        }
    }
}

enum MissionLv:CaseIterable {
    case lv1, lv2, lv3, lv4
    func apiDataKey() -> String {
        switch self {
        case .lv1 : return "lv1"
        case .lv2 : return "lv2"
        case .lv3 : return "lv3"
        case .lv4 : return "lv4"
        }
    }
    
    static func getMissionLv(_ value:String?) -> MissionLv?{
        switch value{
        case "lv1" : return .lv1
        case "lv2" : return .lv2
        case "lv3" : return .lv3
        case "lv4" : return .lv4
        default : return nil
        }
    }
    func info() -> String{
        switch self {
        case .lv1: return "Easy"
        case .lv2: return "Normal"
        case .lv3: return "Difficult"
        case .lv4: return "Very Difficult"
        }
    }
    func icon() -> String{
        switch self {
        case .lv1: return "ic_easy"
        case .lv2: return "ic_normal"
        case .lv3: return "ic_hard"
        case .lv4: return "ic_hard"
        }
    }
    
    func color() -> Color{
        switch self {
        case .lv1: return Color.brand.secondary
        case .lv2: return Color.brand.primary
        case .lv3: return Color.brand.thirdly
        case .lv4: return Color.brand.thirdly
        }
    }
    
    func point() -> Double{
        switch self {
        case .lv1: return 10
        case .lv2: return 20
        case .lv3: return 30
        case .lv4: return 50
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

extension Mission{
    static func viewSpeed(_ value:Double) -> String {
        return (value * 3600 / 1000).toTruncateDecimal(n:1) + String.app.kmPerH
    }
    static func viewDistence(_ value:Double) -> String {
        return (value / 1000).toTruncateDecimal(n:1) + String.app.km
    }
    static func viewDuration(_ value:Double) -> String {
        return (value / 60).toTruncateDecimal(n:1) + String.app.min
    }
}

class Mission:PageProtocol, Identifiable, Equatable{ 
    let id:String = UUID().uuidString
    let type:MissionType
    let lv:MissionLv
    let playType:MissionPlayType
    let placesClient = GMSPlacesClient.shared()
    
    private (set) var description:String = ""
    private (set) var summary:String = ""
    private (set) var recommandPlaces:[GMSAutocompletePrediction] = []
    private (set) var start:GMSPlace? = nil
    private (set) var destination:GMSPlace? = nil
   
    private (set) var waypoints:[GMSPlace] = []
    private (set) var startTime:Double = 0
    private (set) var totalDistence:Double = 0 //miter
    private (set) var duration:Double = 0 //sec
    private (set) var speed:Double = 0 //meter per hour
    
    private (set) var isCompleted:Bool = false
    private (set) var playTime:Double = 0
    private (set) var playDistence:Double = 0
    
    var pictureUrl:String? = nil
    
    public static func == (l:Mission, r:Mission)-> Bool {
        return l.id == r.id
    }
    
    init(type:MissionType, playType:MissionPlayType, lv:MissionLv){
        self.type = type
        self.playType = playType
        self.lv = lv
    }

   
    func completed(playTime:Double, playDistence:Double) {
        self.playTime = playTime
        self.playDistence = playDistence
        self.isCompleted = true
    }
    
    @discardableResult
    func add(start:GMSPlace) -> Mission {
        self.start = start
        return self
    }
    
    @discardableResult
    func add(destinations:[GMSPlace]) -> Mission {
        var pickList = destinations
        var pickedList:[GMSPlace] = []
        let len = min(destinations.count,self.lv.locationCount())
        (0..<len).forEach{_ in
            if let pick = pickList.randomElement() {
                if let idx =  pickList.firstIndex(where: {$0.placeID == pick.placeID}) {
                    pickList.remove(at: idx)
                }
                pickedList.append(pick)
            }
        }
        pickedList.sort(by: {$0.coordinate.latitude > $1.coordinate.latitude})
        self.destination = pickedList.last
        self.waypoints = pickedList.dropLast()
        return self
    }
    
    @discardableResult
    func add(recommandPlaces:[GMSAutocompletePrediction]) -> Mission {
        self.recommandPlaces = recommandPlaces
        return self
    }
    
    var viewSpeed:String { return Self.viewSpeed(self.speed) }
    var viewDistence:String { return Self.viewDistence(self.totalDistence) }
    var viewDuration:String { return Self.viewDuration(self.duration) }
    
    var allPoint:[GMSPlace] {
        var points:[GMSPlace] = []
        if let value = self.start { points.append(value) }
        points.append(contentsOf: self.waypoints)
        if let value = self.destination { points.append(value) }
        return points
    }
    
    @discardableResult
    func build() -> Mission {
        guard let start = self.start else { return self }
        let locale = NSLocale.current.languageCode
        
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
                if locale == "ko" {
                    self.description = desc + "\n를(을) 경유하여 " + viewDuration + " 안에\n" + trailing + "로(으로) 이동"
                } else {
                    self.description = "Move " + trailing + " in " + viewDuration + " via\n" + desc
                }
                
            } else {
                if locale == "ko" {
                    self.description = viewDuration + " 안에\n" + (destination.name ?? "") + "로(으로) 이동"
                } else {
                    self.description = "Move " + (destination.name ?? "") + "\nwithin " + viewDuration
                }
            }
            if locale == "ko" {
                self.summary = viewDuration + " 안에 " + (destination.name ?? "") + "로(으로) 이동"
            } else {
                self.summary = "Move " + (destination.name ?? "") + " within " + viewDuration
            }
        } else {
            switch self.playType {
            case .endurance:
                self.totalDistence = self.lv.distance()
                self.duration = self.lv.duration()
                self.speed = ceil(self.totalDistence/self.duration)
                if locale == "ko" {
                    self.description = viewDuration + " 동안 " + viewDistence + " 이상 이동"
                } else {
                    self.description = "Move for " + viewDuration + ", over " + viewDistence
                }
            case .speed:
                self.totalDistence = MissionLv.lv1.distance()
                self.speed = self.lv.speed()
                self.duration = ceil(self.totalDistence/self.speed)
                if locale == "ko" {
                    self.description = viewSpeed + " 이상 속도로 " + viewDistence + " 이동"
                } else {
                    self.description = viewDistence  + " moves at a speed of " + viewSpeed
                }
            default: break
            }
            self.summary =  description
        }
        return self
    }
    
}




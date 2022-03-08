//
//  MissionManager.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/30.
//

import Foundation
import Combine
import CoreLocation
import GooglePlaces

enum PlayMissionEvent {
    case accessDenied, start, completeStep(Int), next(Int) ,completed, resume, pause, viewPoint(CLLocation)
}
enum PlayMissionStatus {
    case initate, play, stop, complete
}

enum PlayWalkType {
    case mission, walk
}

struct PlayDestination {
    let place:GMSPlace
    let location:CLLocation
    var isLast:Bool = false
}

class PlayWalkModel:ObservableObject, PageProtocol{
    private var locationObserver:LocationObserver? = nil
    private(set) var mission:Mission? = nil
    private var anyCancellable = Set<AnyCancellable>()
   
    private(set) var startTime:Date = Date()
    
    @Published var event:PlayMissionEvent? = nil
        {didSet{ if event != nil { event = nil} }}
    @Published private(set) var status:PlayMissionStatus = .initate
       
    private(set) var type:PlayWalkType = .walk
    private(set) var playStep:Int = 0
    private(set) var startLocation:CLLocation? = nil
    private(set) var endLocation:CLLocation? = nil
    private(set) var destinations:[PlayDestination] = []
    private(set) var destinationDistence:Double = 0
    private(set) var currentDestination :PlayDestination? = nil
    @Published private(set) var currentDistenceFromDestination :Double? = nil
    @Published private(set) var currentLocation:CLLocation? = nil
    @Published private(set) var playTime:Double = 0
    @Published private(set) var playDistence:Double = 0
    @Published private(set) var currentProgress:Float = 0
    init(type:PlayWalkType = .walk) {
        self.type = type
    }
    
    deinit {
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        self.locationObserver?.requestMe(false, id:self.tag )
        self.mission = nil
        self.locationObserver = nil
    }
    
    
    func startMission(mission:Mission, locationObserver:LocationObserver) {
        self.mission = mission
        if let start = mission.start, let end = mission.destination {
            let startLocation = CLLocation(latitude: start.coordinate.latitude, longitude: start.coordinate.longitude)
            let endLocation = CLLocation(latitude: end.coordinate.latitude, longitude: end.coordinate.longitude)
            let wayPointLocation = mission.waypoints.map{
                PlayDestination(
                    place: $0,
                    location: CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude))
            }
            self.destinations.append(PlayDestination(place: start, location: startLocation))
            self.destinations.append(contentsOf: wayPointLocation)
            self.destinations.append(PlayDestination(place: end, location: endLocation, isLast: true ))
            self.startLocation = startLocation
            self.endLocation = endLocation
            
            DataLog.d("self.destinations " + self.destinations.count.description, tag:self.tag)
        }
        self.locationObserver = locationObserver
        self.currentDistenceFromDestination = nil
        locationObserver.$event.sink(receiveValue: { evt in
            switch evt {
            case .updateAuthorization(let status):
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self.requestLocation()
                } else {
                    self.event = .accessDenied
                }
            case .updateLocation(let loc):
                if let prev = self.currentLocation {
                    let diff = loc.distance(from: prev)
                    self.playDistence += diff
                }
                self.playTime = Date().timeIntervalSince(self.startTime)
                self.currentLocation = loc
                self.currentProgress = self.progress
                
                
            default : break
            }
        }).store(in: &anyCancellable)
        self.requestLocation()
        
    }
    
    func startWalk(locationObserver:LocationObserver) {
        self.locationObserver = locationObserver
        locationObserver.$event.sink(receiveValue: { evt in
            switch evt {
            case .updateAuthorization(let status):
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self.requestLocation()
                } else {
                    self.event = .accessDenied
                }
            case .updateLocation(let loc):
                if let prev = self.currentLocation {
                    let diff = loc.distance(from: prev)
                    self.playDistence += diff
                }
                self.playTime = Date().timeIntervalSince(self.startTime)
                self.currentLocation = loc
            default : break
            }
        }).store(in: &anyCancellable)
        self.requestLocation()
    }
    func resumeWalk() {
        self.event = .resume
        self.status = .play
        self.locationObserver?.requestMe(true, id:self.tag)
    }
    
    func pauseWalk() {
        self.event = .pause
        self.status = .stop
        self.locationObserver?.requestMe(false, id:self.tag )
    }
    
    func toggleWalk() {
        if self.status == .stop {
            resumeWalk()
        } else {
            pauseWalk()
        }
    }
    
    private func start(){
        self.startTime = Date()
        self.playStep = 0
        self.event = .start
        self.event = .resume
        self.status = .play
    }
    
    
    private var progress:Float {
        guard let mission = self.mission else { return 0 }
        
        switch mission.playType {
        case .endurance, .speed:
            let move = Float(self.playDistence/mission.totalDistence)
            if move > 1 {
                self.complete()
            }
            return move
        default:
            guard let destination = self.currentDestination?.location else {return 0}
            guard let location = self.currentLocation else {return 0}
            let move = destination.distance(from: location)
            self.currentDistenceFromDestination = move
            if move < 5 {
                self.next()
            }
            
            return min(Float((self.destinationDistence - move)/self.destinationDistence), 1.0)
        }
    }
    
    func next(){
        if self.destinations.isEmpty {return}
        self.event = .completeStep(self.playStep)
        self.playStep += 1
        self.currentDistenceFromDestination = nil
        DataLog.d("next " + self.playStep.description, tag:self.tag)
        if self.destinations.count <= self.playStep {
            self.complete()
        } else {
            guard let start = self.currentDestination?.location ?? self.startLocation else {return}
            let current = self.destinations[self.playStep]
            self.currentDestination = current
            self.destinationDistence = start.distance(from: current.location)
            self.event = .next(self.playStep)
        }
    }
    
    func complete(){
        self.locationObserver?.requestMe(false, id:self.tag )
        self.status = .complete
        self.event = .completed
    }
    
    private func requestLocation() {
        guard let locationObserver = self.locationObserver else {return}
        let status = locationObserver.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.start()
            locationObserver.requestMe(true, id:self.tag)
            
        } else if status == .denied {
            self.event = .accessDenied
        } else {
            locationObserver.requestWhenInUseAuthorization()
        }
    }
}
    

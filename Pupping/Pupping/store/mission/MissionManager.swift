//
//  MissionManager.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/30.
//

import Foundation
import Combine

class MissionManager:ObservableObject, PageProtocol{
    private(set) var missions:[Mission] = []
    @Published private(set) var isMissionsUpdated:Bool = false
        {didSet{ if isMissionsUpdated == true { isMissionsUpdated = false } }}
    @Published private(set) var currentMission:Mission? = nil
    let generator:MissionGenerator
    private var anyCancellable = Set<AnyCancellable>()
    init(generator:MissionGenerator) {
        self.generator = generator
        self.generator.$event.sink(receiveValue: { evt in
            switch evt {
            case .created(let mission, let id) :
                if id == self.tag {
                    self.missions.append(mission)
                    self.generatedMission()
                }
            default : break
            }
        }).store(in: &anyCancellable)
        
        self.generator.$error.sink(receiveValue: { evt in
            switch evt {
            case .apiError(let id) :
                if id == self.tag {
                    self.generatedMission()
                }
            case .notFound(let id) :
                if id == self.tag {
                    self.generatedMission()
                }
            default : break
            }
        }).store(in: &anyCancellable)
    }
    
    private let generateCount:Int = 3
    private var createCount:Int = 0
    
    var isBusy:Bool {
        return self.generator.isBusy
    }
    
    func generateMission() {
        self.missions.removeAll()
        self.createCount = 0
        self.generator.request(q: .create(type: .today, playType: .nearby, lv: nil, keyword: nil), id: self.tag)
        self.generator.request(q: .create(type: .always, playType: nil, lv: nil, keyword: nil), id: self.tag)
        self.generator.request(q: .create(type: .event, playType: .location, lv: nil, keyword: nil), id: self.tag)
    }
    
    private func generatedMission() {
        self.createCount += 1
        if createCount == self.generateCount {
            self.isMissionsUpdated = true
        }
    }
    
    func addMission(_ mission:Mission) {
        self.missions.append(mission)
    }
    
    func startMission(_ mission:Mission) {
        self.currentMission = mission
    }
    func endMission() {
        self.currentMission = nil
    }

}
    

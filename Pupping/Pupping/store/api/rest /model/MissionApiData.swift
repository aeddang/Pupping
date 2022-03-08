//
//  MissionApiData.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/03.
//

import Foundation
struct MissionData : Decodable {
    private(set) var missionId: Int? = nil
    private(set) var missionCategory: String? = nil
    private(set) var missionType: String? = nil
    private(set) var difficulty: String? = nil
    private(set) var title: String? = nil
    private(set) var description: String? = nil
    private(set) var createdAt: String? = nil
    private(set) var pictureUrl: String? = nil
    private(set) var duration: Double? = nil
    private(set) var distance: Double? = nil
    private(set) var point: Double? = nil
    private(set) var user: UserData? = nil
    private(set) var geos: [GeoData]? = nil
    private(set) var pets: [PetData]? = nil
}

struct GeoData : Decodable {
    private(set) var lat: Double? = nil
    private(set) var lng: Double? = nil
}


struct MissionSummary : Decodable {
    private(set) var totalDuration: Double? = nil
    private(set) var totalDistance: Double? = nil
    private(set) var weeklyReport: MissionReport? = nil
    private(set) var monthlyReport: MissionReport? = nil
}

struct MissionReport : Decodable {
    private(set) var totalMissionCount: Double? = nil
    private(set) var avgMissionCount: Double? = nil
    private(set) var missionTimes: [MissionTime]? = nil
}
    
struct MissionTime : Decodable {
    private(set) var d: String? = nil
    private(set) var v: Double? = nil
}

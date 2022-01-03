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
    
    private(set) var missionTitle: String? = nil
    private(set) var missionDescription: String? = nil
    private(set) var createdAt: String? = nil
   
    private(set) var duration: Double? = nil
    private(set) var speed: Double? = nil
    private(set) var distance: Double? = nil
    private(set) var user: UserData? = nil
    private(set) var geos: [GeoData]? = nil
    private(set) var pets: [PetData]? = nil
}

struct GeoData : Decodable {
    private(set) var lat: Double? = nil
    private(set) var lng: Double? = nil
}

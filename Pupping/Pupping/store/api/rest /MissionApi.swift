//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation

class MissionApi :Rest{
    func get(user:SnsUser, petId:Int, completion: @escaping (ApiContentResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["userId"] = user.snsID
        params["petId"] = petId.description
        fetch(route: MissionApiRoute (method: .get, query: params), completion: completion, error:error)
    }
    
    func post(mission:Mission, pets:[PetProfile] , completion: @escaping (ApiContentResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["missionCategory"] = "Mission"
        params["speed"] = mission.speed
        params["duration"] = mission.playTime
        params["distance"] = mission.playDistence
        let point = mission.lv.point()
        params["point"] = point
        params["experience"] = point
        params["petIds"] = pets.map{$0.petId}
        let geos: [[String: Any]] = mission.allPoint.map{
            var geo = [String: Any]()
            geo["lat"] = $0.coordinate.latitude
            geo["lng"] = $0.coordinate.longitude
            return geo
        }
        params["geos"] = geos
        fetch(route: MissionApiRoute (method: .post, body: params), completion: completion, error:error)
    }
    
    func post(walk:Walk, pets:[PetProfile] , completion: @escaping (ApiContentResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["missionCategory"] = "Walk"
        params["speed"] = 0
        params["duration"] = walk.playTime
        params["distance"] = walk.playDistence
        let point = walk.point()
        params["point"] = point
        params["experience"] = point
        params["petIds"] = pets.map{$0.petId}
        let geos: [[String: Any]] = walk.locations.map{
            var geo = [String: Any]()
            geo["lat"] = $0.coordinate.latitude
            geo["lng"] = $0.coordinate.longitude
            return geo
        }
        params["geos"] = geos
        fetch(route: MissionApiRoute (method: .post, body: params), completion: completion, error:error)
    }
    
}

struct MissionApiRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "missions"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}


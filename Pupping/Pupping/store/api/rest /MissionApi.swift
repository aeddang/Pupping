//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import CoreLocation
extension MissionApi {
    enum Category {
        case walk, mission, all
        func getApiCode() -> String {
            switch self {
            case .walk : return "Walk"
            case .mission : return "Mission"
            case .all : return "All"
            }
        }
        
        func getView() -> String {
            switch self {
            case .walk : return String.app.walk
            case .mission : return String.app.mission
            case .all : return ""
            }
        }
        
        static func getCategory(_ value:String?) -> MissionApi.Category?{
            switch value{
            case "Walk" : return .walk
            case "Mission" : return .mission
            default : return nil
            }
        }
    }
    
    enum SearchType:String {
        case Distance, Time, Random, User
    }
}

class MissionApi :Rest{
    func get(userId:String?, petId:Int?, cate:MissionApi.Category, page:Int?, size:Int?,
             completion: @escaping (ApiItemResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["userId"] = userId ?? ""
        params["petId"] = petId?.description ?? ""
        params["missionCategory"] = cate.getApiCode()
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: MissionApiRoute (method: .get, query: params), completion: completion, error:error)
    }
    
    func get(cate:MissionApi.Category, search:MissionApi.SearchType, location:CLLocation? = nil,distance:Double? = nil, page:Int?, size:Int?,
             completion: @escaping (ApiItemResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["searchType"] = search.rawValue
        params["distance"] = distance?.description ?? ""
        params["lat"] = location?.coordinate.latitude.description ?? ""
        params["lng"] = location?.coordinate.longitude.description ?? ""
        params["missionCategory"] = cate.getApiCode()
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: MissionApiRoute (method: .get, action:.search, query: params), completion: completion, error:error)
    }
    
    func post(mission:Mission, pets:[PetProfile] , completion: @escaping (ApiContentResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["missionCategory"] = Category.mission.getApiCode()
        params["missionType"] = mission.type.info()
        params["title"] = mission.playType.info()
        params["description"] = mission.description
        params["difficulty"] = mission.lv.apiDataKey()
        params["duration"] = mission.playTime
        params["distance"] = mission.playDistence
        params["pictureUrl"] = mission.pictureUrl
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
        params["missionCategory"] = Category.walk.getApiCode()
       
        params["duration"] = walk.playTime
        params["distance"] = walk.playDistence
        params["pictureUrl"] = walk.pictureUrl
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


//
//  ApiConst.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

import UIKit

struct ApiPath {
    static func getRestApiPath() -> String {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                return dict["RestApiPath"] as? String ?? ""
            }
        }
        return ""
    }
}


struct ApiConst {
    static let pageSize = 24
}

struct ApiCode {
    static let error = "E001"
    static let unknownError = "E999"
}

enum ApiAction:String{
    case login
}

enum ApiValue:String{
    case video
}
      
enum ApiType{
    case getUser(SnsUser, isCanelAble:Bool? = true), updateUser(SnsUser, ModifyUserProfileData)
    case joinAuth(SnsUser, SnsUserInfo?), reflashAuth
    case registPet(SnsUser, PetProfile), getPets(SnsUser, isCanelAble:Bool? = true), getPet(petId:Int),
         updatePet(petId:Int, ModifyPetProfileData), updatePetImage(petId:Int, UIImage),
         deletePet(petId:Int)
    case getMission(SnsUser,petId:Int),
         completeMission(Mission, [PetProfile]),completeWalk(Walk, [PetProfile])
    func coreDataKey() -> String? {
        switch self {
        default : return nil
        }
    }
    func transitionKey() -> String {
        switch self {
        default : return ""
        }
    }
}

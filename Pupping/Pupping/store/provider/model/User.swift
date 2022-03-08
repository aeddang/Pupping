//
//  Profile.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/19.
//

import Foundation
import SwiftUI
import UIKit
enum Gender {
    case male, female
    func getIcon() -> String {
        switch self {
        case .male : return Asset.icon.male
        case .female : return Asset.icon.female
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .male : return String.app.male
        case .female : return String.app.female
        }
    }
    
    func getSimpleTitle() -> String {
        switch self {
        case .male : return "Male"
        case .female : return "Female"
        }
    }
    
    func coreDataKey() -> Int {
        switch self {
        case .male : return 1
        case .female : return 2
        }
    }
    func apiDataKey() -> String {
        switch self {
        case .male : return "Male"
        case .female : return "Female"
        }
    }
    
    static func getGender(_ value:Int) -> Gender?{
        switch value{
        case 1 : return .male
        case 2 : return .female
        default : return nil
        }
    }
    static func getGender(_ value:String?) -> Gender?{
        switch value{
        case "Male" : return .male
        case "Female" : return .female
        default : return nil
        }
    }
}

struct ModifyUserData {
    var point:Double?
    var mission:Double?
    var coin:Double?
}

class User:ObservableObject, PageProtocol, Identifiable{
    private(set) var id:String = UUID().uuidString
    @Published private(set) var pets:[PetProfile] = []
    @Published private(set) var point:Double = 0
    @Published private(set) var coin:Double = 0
    @Published private(set) var mission:Double = 0
    private(set) var currentProfile:UserProfile = UserProfile()
    private(set) var currentPet:PetProfile? = nil
    private(set) var snsUser:SnsUser? = nil
    private(set) var recentMission:History? = nil
    private(set) var finalGeo:GeoData? = nil
    
    
    func registUser(user:SnsUser){
        self.snsUser = user
    }
    func clearUser(){
        self.snsUser = nil
    }
    func registUser(id:String?, token:String?, code:String?){
        DataLog.d("id " + (id ?? ""), tag: self.tag)
        DataLog.d("token " + (token ?? ""), tag: self.tag)
        DataLog.d("code " + (code ?? ""), tag: self.tag)
        guard let id = id, let token = token , let type = SnsType.getType(code: code) else {return}
        DataLog.d("user init " + (code ?? ""), tag: self.tag)
        self.snsUser = SnsUser(snsType: type, snsID: id, snsToken: token)
    }
    
    func setData(_ data:MissionData) -> User {
        self.recentMission = History(data: data)
        if let user = data.user {
            self.setData(data:user)
        }
        if let pets = data.pets {
            self.setData(data:pets, isMyPet:false)
        }
        if let type = SnsType.getType(code: data.user?.providerType), let id = data.user?.userId {
            self.snsUser = SnsUser(
                snsType: type,
                snsID: id,
                snsToken: ""
            )
        }
        self.finalGeo = data.geos?.first
        return self
    }
    
    func setData(data:UserData){
        self.point = data.point ?? 0
        self.currentProfile.setData(data: data)
    }
    func setData(data:[PetData], isMyPet:Bool = true){
        self.pets = data.map{ PetProfile(data: $0, isMyPet: isMyPet)}
    }
    
    func deletePet(petId:Int) {
        guard let find = self.pets.firstIndex(where: {$0.petId == petId}) else {
            return
        }
        self.pets.remove(at: find)
    }
    
    func registPetComplete(profile:PetProfile)  {
        self.pets.append(profile)
        if self.currentPet == nil {
            self.currentPet = profile
        }
    }
    
    func getPet(_ id :String) -> PetProfile? {
        return self.pets.first(where: {$0.id == id})
    }
    
    func swapCoin() {
        self.coin += self.point
        self.point = 0
        UserCoreData().update(
            data: ModifyUserData(
                point: self.point,
                coin: self.coin)
        )
    }
    
    func setData(_ data:UserEntity) {
        self.point = data.point
        self.mission = data.mission
        self.coin = data.coin
    }
    
    
     
    func addPet(_ profile:PetProfile) {
        pets.append(profile)
    }
    
    func missionCompleted(_ mission:Mission) {
        let point =  mission.lv.point()
        self.point += point
        self.mission += 1
        self.pets.filter{$0.isWith}.forEach{
            $0.update(exp: point)
        }
        UserCoreData().update(
            data: ModifyUserData(
                point: self.point,
                mission: self.mission)
        )
    }
    
    
    func setDummy() -> User {
        self.currentProfile.setDummy()
        self.pets = [PetProfile().setDummy(),PetProfile().setDummy(),PetProfile().setDummy(),PetProfile().setDummy(),PetProfile().setDummy()]
        return self
    }
}



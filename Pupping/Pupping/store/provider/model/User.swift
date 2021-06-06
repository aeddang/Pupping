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
    case mail, femail
    func getIcon() -> String {
        switch self {
        case .mail : return Asset.icon.mail
        case .femail : return Asset.icon.femail
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .mail : return String.app.mail
        case .femail : return String.app.femail
        }
    }
    
    func coreDataKey() -> Int {
        switch self {
        case .mail : return 1
        case .femail : return 2
        }
    }
    
    static func getGender(_ value:Int) -> Gender?{
        switch value{
        case 1 : return .mail
        case 2 : return .femail
        default : return nil
        }
    }
}

struct ModifyUserData {
    var point:Double?
    var mission:Double?
    var coin:Double?
}

class User:ObservableObject, PageProtocol{
    
    @Published private(set) var profiles:[Profile] = []
    @Published private(set) var point:Double = 0
    @Published private(set) var coin:Double = 0
    @Published private(set) var mission:Double = 0
    private(set) var currentRegistProfile:Profile? = nil
    private(set) var snsUser:SnsUser? = nil
    
    func setProfiles() {
        DispatchQueue.main.async {
            self.profiles = ProfileCoreData().getAllProfiles()
        }
    }
    func registUser(user:SnsUser){
        self.snsUser = user
    }
    func registUser(id:String?, token:String?, code:String?){
        DataLog.d("id " + (id ?? ""), tag: self.tag)
        DataLog.d("token " + (token ?? ""), tag: self.tag)
        DataLog.d("code " + (code ?? ""), tag: self.tag)
        guard let id = id, let token = token , let type = SnsType.getType(code: code) else {return}
        
        DataLog.d("user init " + (code ?? ""), tag: self.tag)
        self.snsUser = SnsUser(snsType: type, snsID: id, snsToken: token)
    }
    
    @discardableResult
    func registProfile() -> Profile {
        let profile = Profile()
        self.currentRegistProfile = profile
        return profile
    }
    func deleteProfile(id:String) {
        guard let find = self.profiles.firstIndex(where: {$0.id == id}) else {
            return
        }
        self.profiles.remove(at: find)
        ProfileCoreData().remove(id: id)
    }
    func registComplete()  {
        guard let profile = self.currentRegistProfile else {return}
        ProfileCoreData().add(profile: profile)
        self.profiles.append(profile)
        self.currentRegistProfile = nil
    }
    
    func getProfile(_ id :String) -> Profile? {
        return self.profiles.first(where: {$0.id == id})
    }
    
    func setData(_ data:UserEntity) {
        self.point = data.point
        self.mission = data.mission
        self.coin = data.coin
    }
     
    func addProfile(_ profile:Profile) {
        profiles.append(profile)
        ProfileCoreData().add(profile: profile)
    }
    
    func missionCompleted(_ mission:Mission) {
        let point =  mission.lv.point()
        self.point += point
        self.mission += 1
        self.profiles.filter{$0.isWith}.forEach{
            $0.update(exp: point)
        }
        UserCoreData().update(
            data: ModifyUserData(
                point: self.point,
                mission: self.mission)
        )
    }
}



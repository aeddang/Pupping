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
}


struct ModifyProfileData {
    var image:UIImage? = nil
    var nickName:String? = nil
    var species:String? = nil
    var gender:Gender? = nil
    var birth:Date? = nil
    var microfin:String? = nil
    var neutralization:Bool? = nil
}

struct ModifyPlayData {
    let lv:Int
    let exp:Double
}

class Profile:ObservableObject, PageProtocol, Identifiable {
    private(set) var id:String = UUID().uuidString
    @Published private(set) var image:UIImage? = nil
    @Published private(set) var nickName:String? = nil
    @Published private(set) var species:String? = nil
    @Published private(set) var gender:Gender? = nil
    @Published private(set) var birth:Date? = nil
    
    @Published private(set) var exp:Double = 0
    @Published private(set) var lv:Int = 1
    private(set) var microfin:String? = nil
    private(set) var neutralization:Bool? = nil
    private(set) var isEmpty:Bool = false
    
    init(){}
    init(nickName:String?,species:String?, gender:Gender?, birth:Date?){
        self.nickName = nickName
        self.species = species
        self.gender = gender
        self.birth = birth
    }
    
    init(data:ProfileEntity){
        self.id = data.id ?? UUID().uuidString
        self.nickName = data.name
        self.species = data.species
        self.gender = Gender.getGender(Int(data.gender))
        self.birth = data.birth
        self.lv = Int(data.lv)
        self.exp = Double(data.exp)
        self.microfin = data.microfin
        if let imgData = data.image { self.image =  UIImage(data: imgData) }
        self.neutralization = data.neutralization
    }
    
    @discardableResult
    func empty() -> Profile{
        self.isEmpty = true
        self.nickName = String.alert.needProfile
        return self
    }
    
    @discardableResult
    func update(data:ModifyProfileData) -> Profile{
        if let value = data.image { self.image = value }
        if let value = data.nickName { self.nickName = value }
        if let value = data.species { self.species = value }
        if let value = data.gender { self.gender = value }
        if let value = data.birth { self.birth = value }
        ProfileCoreData().update(id: self.id, data: data)
        return self
    }
    
    @discardableResult
    func update(image:UIImage?) -> Profile{
        self.image = image
        ProfileCoreData().update(id: self.id, image: image)
        return self
    }
    
    @discardableResult
    func update(exp:Double) -> Profile{
        self.exp += exp
        let willLv = Int(floor(self.exp / 100) + 1)
        if willLv != self.lv {
            self.lv = willLv
        }
        ProfileCoreData().update(id: self.id, data: ModifyPlayData(lv: self.lv, exp: self.exp))
        return self
    }
}

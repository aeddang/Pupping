//
//  Profile.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/06.
//

import Foundation
import SwiftUI
import UIKit

struct ModifyProfileData {
    var image:UIImage? = nil
    var nickName:String? = nil
    var species:String? = nil
    var gender:Gender? = nil
    var birth:Date? = nil
    var microfin:String? = nil
    var neutralization:Bool? = nil
    var distemper:Bool? = nil
    var hepatitis:Bool? = nil
    var parovirus:Bool? = nil
    var rabies:Bool? = nil
}

struct ModifyPlayData {
    let lv:Int
    let exp:Double
}

class Profile:ObservableObject, PageProtocol, Identifiable, Equatable {
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
    private(set) var distemper:Bool? = nil
    private(set) var hepatitis:Bool? = nil
    private(set) var parovirus:Bool? = nil
    private(set) var rabies:Bool? = nil
    private(set) var isEmpty:Bool = false
    var isWith:Bool = true
    
    public static func == (l:Profile, r:Profile)-> Bool {
        return l.id == r.id
    }
    
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
        self.distemper = data.distemper
        self.hepatitis = data.hepatitis
        self.parovirus = data.parovirus
        self.rabies = data.rabies
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
        if let value = data.neutralization { self.neutralization = value }
        if let value = data.distemper { self.distemper = value }
        if let value = data.hepatitis { self.hepatitis = value }
        if let value = data.parovirus { self.parovirus = value }
        if let value = data.rabies { self.rabies = value }
        
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

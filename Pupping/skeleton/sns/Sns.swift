//
//  Sns.swift
//  Valla
//
//  Created by KimJeongCheol on 2020/12/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

protocol Sns {
    func requestLogin()
    func requestLogOut()
    func getAccessTokenInfo()
    func getUserInfo()
    func requestUnlink()
}

enum SnsType{
    case apple
    func apiCode() -> String {
        switch self {
            case .apple: return "apple"
        }
    }
    static func getType(code:String?) -> SnsType? {
        switch code?.lowercased() {
        case "apple": return .apple
        default : return nil
        }
    }
}

enum SnsStatus{
    case login, logout
}

enum SnsEvent{
    case login, logout, getProfile, getToken, invalidToken, reflashToken
}

struct SnsResponds{
    let event:SnsEvent
    let type:SnsType
    var data:Any? = nil
}
struct SnsError{
    let event:SnsEvent
    let type:SnsType
    var error:Error? = nil
}

struct SnsUser{
    var snsType:SnsType
    var snsID:String
    var snsToken:String
}

struct SnsUserInfo{
    var nickName:String? = nil
    var profile:String? = nil
    var email:String? = nil
}

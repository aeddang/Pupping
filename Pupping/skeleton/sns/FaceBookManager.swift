//
//  FaceBookManager.swift
//  Valla
//
//  Created by KimJeongCheol on 2020/12/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class FaceBookManager:ObservableObject, PageProtocol, Sns{
    @Published var respond:SnsResponds? = nil
    @Published var error:SnsError? = nil
    let type = SnsType.fb
 
    func onLogin(token: AccessToken) {
        let user = SnsUser(
            snsType: type, snsID: token.userID, snsToken: token.tokenString
        )
        self.respond = SnsResponds(event: .login, type: type, data:user)
    }
    
    func onLogOut() {
        self.respond = SnsResponds(event: .logout, type: type)
    }
    
    func onLoginError(error: Error?) {
        self.error = SnsError(event: .login, type: type, error: error)
    }
    
    func getAccessTokenInfo(){
        if let token = AccessToken.current, !token.isExpired {
            self.respond = SnsResponds(event: .getToken, type: type, data:token.tokenString)
        }else{
            self.respond = SnsResponds(event: .invalidToken, type: type)
        }
    }
    
    func getUserInfo(){
        GraphRequest.init(graphPath:"me",
                          parameters: ["fields":"name,email, picture.type(large)"])
            .start(completion: {_, result, error in
            if let error = error {
                DataLog.e(error.localizedDescription, tag: self.tag)
                self.error = SnsError(event: .login, type: self.type, error: error)
            }
            else {
                DataLog.d("getUserInfo success. " + result.debugDescription , tag: self.tag)
                guard let  user = result as? [String: Any] else { return }
                var picturePath:String? = nil
                if let picture = user["picture"] as? [String: Any] {
                    if let pictureData = picture["data"] as? [String: Any]{
                        picturePath = pictureData["url"] as? String
                    }
                }
                let userInfo = SnsUserInfo(
                    nickName: user["name"] as? String,
                    profile: picturePath,
                    email: user["email"] as? String
                )
                self.respond = SnsResponds(event: .getProfile, type: self.type, data:userInfo)
            }
            
        })
    }
    
    
    func requestLogin() {
        LoginManager.init().logIn(permissions: ["public_profile", "email"]){result in
            switch result {
            case .success(_, _, let token) :
                guard let token = token else {return}
                self.onLogin(token: token)
            case .cancelled : break
            case .failed(let err) : self.onLoginError(error: err)
            @unknown default: break
            }
        }
    }
    
    func requestLogOut() {
        LoginManager.init().logOut()
        self.onLogOut()
    }
    
    func requestUnlink() {
        DataLog.e("Not supported", tag: self.tag)
    }
}

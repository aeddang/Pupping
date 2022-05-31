//
//  ImageView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Combine
import struct Kingfisher.KFImage
struct UserProfileInfo : PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var profile:UserProfile
    var isModifyAble:Bool = false
    var useProfileImage:Bool = true
    @State var image:UIImage? = nil
    @State var imagePath:String? = nil
    @State var name:String? = nil
   
    var body: some View {
        ZStack{
            VStack(alignment:.leading, spacing:Dimen.margin.thinExtra){
                if self.useProfileImage {
                    UserProfileImage(
                        id : self.profile.id,
                        image: self.image,
                        imagePath: self.imagePath,
                        isModifyAble: self.isModifyAble)
                }
                HStack(spacing:Dimen.margin.tiny){
                    if self.name?.isEmpty == false, let name = self.name {
                        Text(name)
                            .modifier(BoldTextStyle(
                                size: Font.size.mediumExtra,
                                color: Color.app.greyDeep
                            ))
                    } else {
                        Text(String.pageText.profileRegistNickName)
                            .modifier(MediumTextStyle(
                                size: Font.size.mediumExtra,
                                color: Color.app.greyLight
                            ))
                    }
                    if self.isModifyAble {
                        Button(action: {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.profileRegist)
                                    .addParam(key: .type, value: ProfileType.user)
                            )
                
                        }) {
                            Image(Asset.icon.modify)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.app.greyLight)
                                .frame(width: Dimen.icon.thin,
                                       height: Dimen.icon.thin)
                        }
                    }
                }
                
                HStack(spacing:Dimen.margin.tiny){
                    if let type = self.profile.type {
                        Image(uiImage: UIImage(named: type.logo)!)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                    }
                    if let email = self.profile.email {
                        Text(email)
                            .modifier(MediumTextStyle(
                                size: Font.size.tiny,
                                color: Color.app.grey
                            ))
                    }
                }
            }
        }
        .onReceive(self.appSceneObserver.$pickImage) { pick in
            guard let pick = pick else {return}
            if pick.id?.hasSuffix(self.profile.id) != true {return}
            if let img = pick.image {
                self.pagePresenter.isLoading = true
                DispatchQueue.global(qos:.background).async {
                    let uiImage = img.normalized().centerCrop().resize(to: CGSize(width: 240,height: 240))
                    DispatchQueue.main.async {
                        self.pagePresenter.isLoading = false
                        if let user = self.dataProvider.user.snsUser {
                            self.dataProvider.requestData(q: .init(type: .updateUser( user, .init(image: uiImage))))
                        }
                    }
                }
            } else {
                //self.profile.update(image: nil)
            }
        }
        .onReceive(self.profile.$image) { img in
            self.image = img
            self.imagePath = self.profile.imagePath
        }
        .onReceive(self.profile.$nickName) { name in
            self.name = name
        }
        .onAppear(){
           
            self.imagePath = self.profile.imagePath
        }
    }
}

struct UserProfileImage:PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var id:String
    var image:UIImage?
    var imagePath:String?
    var isModifyAble:Bool = false
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            ZStack{
                if let img = self.image {
                    Image(uiImage: img)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                } else if let path = self.imagePath {
                    ImageView(url: path,
                        contentMode: .fill,
                              noImg: Asset.image.emtpyUserProfile)
                        .modifier(MatchParent())
                } else {
                    Image( uiImage: UIImage(named: Asset.image.emtpyUserProfile)! )
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                }
            }
            .frame(width: Dimen.profile.regular, height: Dimen.profile.regular)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                
            if self.isModifyAble {
                Button(action: {
                    self.appSceneObserver.select
                            = .imgPicker(SceneRequest.imagePicker.rawValue + id)
                }) {
                    Image( Asset.icon.add )
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.app.greyLight)
                        .frame(width: Dimen.icon.thin,
                               height: Dimen.icon.thin)
                        .background(Color.app.white)
                        .clipShape(Circle())
                }
            }
        }
       
    }
}


#if DEBUG
struct UserProfileInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            UserProfileInfo(
                profile: UserProfile()
            )
            .environmentObject(PagePresenter())
            .environmentObject(AppSceneObserver())
            .environmentObject(DataProvider())
            .frame(width: 375, height: 640)
        }
    }
}
#endif

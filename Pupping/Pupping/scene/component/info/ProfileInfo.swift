//
//  ImageView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import struct Kingfisher.KFImage
struct ProfileInfo : PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var profile:Profile
    var axio:Axis = .vertical
    var isModifyAble:Bool = false
    var isSelectAble:Bool = false
    @State var image:UIImage? = nil
    @State var name:String? = nil
    @State var age:String? = nil
    @State var species:String? = nil
    @State var gender:Gender? = nil
    @State var lv:String = ""
    @State var exp:String = ""
    var body: some View {
        ZStack{
            if self.axio == .vertical {
                VStack(spacing:Dimen.margin.light){
                    ProfileImage(
                        id : self.profile.id,
                        image: self.image,
                        isEmpty: self.profile.isEmpty)
                    HStack(spacing:Dimen.margin.thin){
                        Text(self.name ?? "")
                            .modifier(BoldTextStyle(
                                size: Font.size.mediumExtra,
                                color: Color.app.greyDeep
                            ))
                        if !self.profile.isEmpty {
                            Text(self.lv)
                                .modifier(BoldTextStyle(
                                    size: Font.size.thinExtra,
                                    color: Color.brand.primary
                                ))
                        }
                    }
                    if !self.profile.isEmpty {
                        ProfileInfoDescription(
                            profile: self.profile,
                            age: self.age,
                            species: self.species,
                            gender: self.gender,
                            isModifyAble: self.isModifyAble)
                    }
                }
                
            } else {
                HStack(spacing:Dimen.margin.light){
                    ProfileImage(
                        id : self.profile.id,
                        image: self.image,
                        isEmpty: self.profile.isEmpty)
                    VStack(alignment: .leading, spacing:Dimen.margin.tiny){
                        HStack(alignment: .bottom, spacing:Dimen.margin.tiny){
                           Text(self.name ?? "")
                                .modifier(BoldTextStyle(
                                    size: Font.size.mediumExtra,
                                    color: self.profile.isEmpty ? Color.app.greyLight : Color.app.greyDeep
                                ))
                            if !self.profile.isEmpty {
                                Text(self.lv)
                                    .modifier(BoldTextStyle(
                                        size: Font.size.thinExtra,
                                        color: Color.brand.primary
                                    ))
                                Text(self.exp)
                                    .modifier(SemiBoldTextStyle(
                                        size: Font.size.thinExtra,
                                        color: Color.app.greyLight
                                    ))
                            }
                            Spacer()
                            if !self.profile.isEmpty && self.isModifyAble {
                                Button(action: {
                                    self.appSceneObserver.alert =
                                        .confirm(nil,  String.alert.deleteProfile){ isOk in
                                            if !isOk {return}
                                            
                                            self.dataProvider.user.deleteProfile(id: self.profile.id)
                                    }
                        
                                }) {
                                    Image(Asset.icon.delete)
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Dimen.icon.tiny,
                                               height: Dimen.icon.tiny)
                                }
                            }
                        }
                        if !self.profile.isEmpty {
                            ProfileInfoDescription(
                                profile: self.profile,
                                age: self.age,
                                species: self.species,
                                gender: self.gender,
                                isModifyAble: self.isModifyAble)
                        }
                    }
                }
            }
            
        }
        .onTapGesture {
            if !self.profile.isEmpty { return }
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.profileRegist)
            )
        }
        
        .onReceive(self.appSceneObserver.$pickImage) { pick in
            guard let pick = pick else {return}
            if pick.id?.hasSuffix(self.profile.id) != true {return}
            if let img = pick.image {
                self.pagePresenter.isLoading = true
                DispatchQueue.global(qos:.background).async {
                    let uiImage = img.normalized().centerCrop().resize(to: CGSize(width: 240,height: 240))
                    DispatchQueue.main.async {
                        self.profile.update(image: uiImage)
                        self.pagePresenter.isLoading = false
                    }
                }
            } else {
                self.profile.update(image: nil)
            }
        }
        
        .onReceive(self.profile.$birth) { birth in
            guard let birth = birth else {
                self.age = nil
                return
            }
            let now = Date()
            let yy = now.toDateFormatter(dateFormat:"yyyy")
            let birthYY = birth.toDateFormatter(dateFormat:"yyyy")
            self.age = (yy.toInt() - birthYY.toInt() + 1).description + "yrs"
        }
        .onReceive(self.profile.$lv) { lv in
            self.lv = "lv" + lv.description
        }
        .onReceive(self.profile.$exp) { exp in
            self.exp = "(exp " + exp.description + ")"
        }
        .onReceive(self.profile.$image) { img in
            self.image = img
        }
        .onReceive(self.profile.$nickName) { name in
            self.name = name?.isEmpty == false ? name : String.pageText.profileEmptyName
        }
        .onReceive(self.profile.$species) { species in
            self.species = species?.isEmpty == false ? species : String.pageText.profileEmptySpecies
        }
        .onReceive(self.profile.$gender) { gender in
            self.gender = gender
        }
    }
}

struct ProfileImage:PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var id:String
    var image:UIImage?
    var isEmpty:Bool = false
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            Image(uiImage: self.image ??
                    UIImage(named: self.isEmpty ? Asset.icon.footPrint : Asset.brand.logoLauncher)!)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .padding(.all, self.isEmpty ? Dimen.margin.tiny : 0)
                .frame(width: Dimen.profile.regular, height: Dimen.profile.regular)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .padding(.horizontal, Dimen.margin.tiny)
            if !self.isEmpty {
                Button(action: {
                    self.appSceneObserver.select
                            = .imgPicker(SceneRequest.imagePicker.rawValue + id)
                }) {
                    Image( Asset.icon.add )
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(self.isEmpty ? Color.brand.primary : Color.app.greyLight)
                        .frame(width: Dimen.icon.thin,
                               height: Dimen.icon.thin)
                        .background(Color.app.white)
                        .clipShape(Circle())
                }
            }
        }
       
    }
}

struct ProfileInfoDescription:PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    var profile:Profile
    var age:String?
    var species:String?
    var gender:Gender?
    var isModifyAble:Bool
    var body: some View {
        HStack(spacing:Dimen.margin.tiny){
            if let gender = self.gender {
                Image(gender.getIcon())
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(gender == .mail ? Color.brand.fourth :  Color.brand.primary)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
            }
            if let age = self.age {
                Circle()
                    .frame(width: Dimen.circle.thin, height: Dimen.circle.thin)
                    .background(Color.app.grey)
                Text(age)
                    .modifier(BoldTextStyle(
                        size: Font.size.thinExtra,
                        color: Color.app.grey
                    ))
            }
            
            if let species = self.species {
                Circle()
                    .frame(width: Dimen.circle.thin, height: Dimen.circle.thin)
                    .background(Color.app.grey)
                Text(species)
                    .modifier(BoldTextStyle(
                        size: Font.size.thinExtra,
                        color: Color.app.grey
                    ))
            }
            if isModifyAble {
                Button(action: {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.profileModify)
                            .addParam(key: .data, value: self.profile)
                    )
                   
                }) {
                    Image(Asset.icon.modify)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.app.greyLight)
                        .frame(width: Dimen.icon.tiny,
                               height: Dimen.icon.tiny)
                }
                .padding(.leading, Dimen.margin.tiny)
            }
        }
        .frame(height:Dimen.icon.thin)
    }
}


#if DEBUG
struct ProfileInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            ProfileInfo(
                profile: Profile(
                    nickName: "dalja",
                    species: "biggle",
                    gender: .femail,
                    birth: Date())
            )
            .environmentObject(DataProvider())
            .frame(width: 375, height: 640)
        }
    }
}
#endif

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
struct PlayProfileInfo : PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var profile:Profile
   
    @State var image:UIImage? = nil
    @State var name:String? = nil
    @State var lv:String = ""
    @State var exp:String = ""
    var body: some View {
        HStack(spacing:Dimen.margin.micro){
            Image(uiImage: self.image ??
                    UIImage(named:Asset.brand.logoLauncher)!)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Dimen.profile.thin, height: Dimen.profile.thin)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .padding(.horizontal, Dimen.margin.tiny)
            
            VStack(alignment: .leading, spacing:0){
                Text(self.name ?? "")
                     .modifier(BoldTextStyle(
                         size: Font.size.tinyExtra,
                         color: Color.app.greyDeep
                     ))
                    .lineLimit(1)
                Text(self.lv)
                    .modifier(BoldTextStyle(
                        size: Font.size.micro,
                        color: Color.brand.primary
                    ))
                    .lineLimit(1)
                
                Text(self.exp)
                    .modifier(LightTextStyle(
                        size: Font.size.micro,
                        color: Color.app.greyLight
                    ))
                    .lineLimit(1)
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
                        self.profile.update(image: uiImage)
                        self.pagePresenter.isLoading = false
                    }
                }
            } else {
                self.profile.update(image: nil)
            }
        }

        .onReceive(self.profile.$lv) { lv in
            self.lv = "Lv." + lv.description
        }
        .onReceive(self.profile.$exp) { exp in
            self.exp = exp.description
        }
        .onReceive(self.profile.$image) { img in
            self.image = img
        }
        .onReceive(self.profile.$nickName) { name in
            self.name = name?.isEmpty == false ? name : String.pageText.profileEmptyName
        }
        
    }
}



#if DEBUG
struct PlayProfileInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PlayProfileInfo(
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
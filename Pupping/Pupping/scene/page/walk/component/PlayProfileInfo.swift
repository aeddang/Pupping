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
    var data:PetProfile
    /*
    @ObservedObject var data:PetProfile
    @State var image:UIImage? = nil
    @State var imagePath:String? = nil
    @State var name:String? = nil
    @State var lv:String = ""
    @State var exp:String = ""
    */
    var body: some View {
        HStack(spacing:Dimen.margin.tiny){
            PetProfileImage(
                id : self.data.id,
                image: self.data.image,
                imagePath: self.data.imagePath,
                size : Dimen.profile.thin
            )
            VStack(alignment: .leading, spacing:0){
                Text(self.data.nickName ?? "")
                     .modifier(BoldTextStyle(
                         size: Font.size.tinyExtra,
                         color: Color.app.greyDeep
                     ))
                    .lineLimit(1)
                Text("Lv." + self.data.lv.description)
                    .modifier(BoldTextStyle(
                        size: Font.size.micro,
                        color: Color.brand.primary
                    ))
                    .lineLimit(1)
                
                Text(self.data.exp.description)
                    .modifier(LightTextStyle(
                        size: Font.size.micro,
                        color: Color.app.greyLight
                    ))
                    .lineLimit(1)
            }
            .frame(width: Dimen.profile.thin)
        }
        .padding(.trailing, Dimen.margin.thin)
        /*
        .onReceive(self.appSceneObserver.$pickImage) { pick in
            guard let pick = pick else {return}
            if pick.id?.hasSuffix(self.profile.id) != true {return}
            if let img = pick.image {
                self.pagePresenter.isLoading = true
                DispatchQueue.global(qos:.background).async {
                    let uiImage = img.normalized().centerCrop().resize(to: CGSize(width: 240,height: 240))
                    DispatchQueue.main.async {
                        self.pagePresenter.isLoading = false
                        self.dataProvider.requestData(q: .init(type: .updatePetImage(petId: self.profile.petId, uiImage)))
                    }
                }
            } else {
                //self.profile.update(image: nil)
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
        */
    }
}



#if DEBUG
struct PlayProfileInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PlayProfileInfo(
                data: PetProfile(
                    nickName: "dalja",
                    species: "biggle",
                    gender: .female,
                    birth: Date())
            )
            .environmentObject(DataProvider())
            .frame(width: 375, height: 640)
        }
    }
}
#endif

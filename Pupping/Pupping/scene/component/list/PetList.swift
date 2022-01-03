//
//  PetList.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/13.
//

import Foundation
import SwiftUI

extension PetList{
    static let width:CGFloat = 294
    static let height:CGFloat = 199
}
struct PetList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[PetProfile]
   
    @State var lv:String = ""
    @State var exp:String = ""
    
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: Dimen.margin.light,
            marginHorizontal: Dimen.margin.light,
            spacing: Dimen.margin.light,
            isRecycle: true,
            useTracking: false
        ){
            if !self.datas.isEmpty {
                ForEach(self.datas) { data in
                    PetListItem(profile: data )
                        .onTapGesture {
                            
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.profile)
                                    .addParam(key: .data, value: data)
                            )
                        }
                }
            } else {
                Image(Asset.image.profileEmpty)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: PetList.width, height: PetList.height)
            }
        }
        
        
    }//body
}

struct PetListItem: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var profile:PetProfile
    @State var imagePath:String? = nil
    @State var image:UIImage? = nil
    @State var name:String? = nil
    @State var age:String? = nil
    @State var species:String? = nil
    @State var gender:Gender? = nil
    @State var lv:String = ""
    @State var exp:String = ""
    @State var prevExp:String = ""
    @State var nextExp:String = ""
    @State var progressExp:Float = 0
   
    var body: some View {
        ZStack(alignment: .topTrailing){
            VStack(spacing: Dimen.margin.regular){
                HStack(spacing:Dimen.margin.light){
                    PetProfileImage(
                        id : self.profile.id,
                        image: self.image,
                        imagePath: self.imagePath,
                        isEmpty: false,
                        isEditable: self.profile.isMypet
                    )
                    VStack(alignment: .leading, spacing:Dimen.margin.tiny){
                        HStack(alignment: .bottom, spacing:Dimen.margin.tiny){
                           Text(self.name ?? "")
                                .modifier(BoldTextStyle(
                                    size: Font.size.mediumExtra,
                                    color: self.profile.isEmpty ? Color.app.greyLight : Color.app.greyDeep
                                ))
                            Spacer()
                           
                        }
                        PetProfileInfoDescription(
                            profile: self.profile,
                            age: self.age,
                            species: self.species,
                            gender: self.gender,
                            isModifyAble: false)
                    }
                }
                VStack(spacing: Dimen.margin.micro){
                    HStack{
                        Text(self.lv)
                            .modifier(BoldTextStyle(
                                size: Font.size.thinExtra,
                                color: Color.brand.primary
                            ))
                        Spacer()
                        Text(self.exp)
                            .modifier(SemiBoldTextStyle(
                                size: Font.size.thinExtra,
                                color: Color.app.grey
                            ))
                    }
                    ProgressSlider(progress: self.progressExp, useGesture: false, progressHeight: Dimen.bar.light, thumbSize: 0)
                        .frame(height: Dimen.bar.light)
                        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.micro))
                    
                }
                .padding(.horizontal, Dimen.margin.thin)
               
            }
            
        }
        .modifier(ContentTab())
        .frame(width: PetList.width)
        
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
        
        .onReceive(self.profile.$image) { img in
            self.image = img
            self.imagePath = self.profile.imagePath
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
        
        .onReceive(self.profile.$lv) { lv in
            self.lv = "Lv." + lv.description
        }
        .onReceive(self.profile.$exp) { exp in
            self.exp = exp.formatted(style: .decimal) + "exp"
        }
        .onReceive(self.profile.$prevExp) { exp in
            self.prevExp = exp.formatted(style: .decimal)
        }
        .onReceive(self.profile.$nextExp) { exp in
            if exp == 0 {return}
            self.nextExp = exp.formatted(style: .decimal)
            let prev = self.profile.prevExp
            withAnimation{
                self.progressExp = Float((self.profile.exp - prev) / (exp - prev))
            }
        }
        .onAppear(){
            self.imagePath = self.profile.imagePath
        }

    }
}

//
//  ProfileDetail.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/14.
//

import Foundation
import SwiftUI

struct PetHealthInfo: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
   
    @ObservedObject var profile:PetProfile
    var userId:String? = nil
    
    @State var weight:String? = nil
    @State var size:String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.thin){
            if profile.isMypet || weight != nil || size != nil {
                TitleTab(
                    title: String.pageText.profileHealthRecord,
                    type: .modify){
                        self.openModify()
                    }
                HStack(spacing: Dimen.margin.thin){
                    if weight == nil && size == nil {
                        FillButton(
                            type: .stroke,
                            text: String.pageText.profileHealthRecordUpdate,
                            icon: Asset.icon.add,
                            isSelected:false){ _ in
                            self.openModify()
                        }
                    }
                    if let value = weight {
                        ValueBox(
                            title: String.app.weight,
                            value: value)
                    }
                    if let value = size {
                        ValueBox(
                            title: String.app.size,
                            value: value)
                    }
                }
            }
        }
        .onReceive(self.profile.$weight) { weight in
            guard let w = weight else {return}
            self.weight = w.description + String.app.kg
        }
        .onReceive(self.profile.$size) { size in
            guard let s = size else {return}
            self.size = s.description + String.app.m
        }
    }
    
    private func openModify(){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.healthModify)
                .addParam(key: .data, value: self.profile)
        )
    }
}


#if DEBUG
struct PetHealthInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PetHealthInfo(
                profile: PetProfile(
                    nickName: "dalja",
                    species: "biggle",
                    gender: .female,
                    birth: Date())
            )
            .environmentObject(Repository())
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            .environmentObject(DataProvider())
            .frame(width: 375, height: 640)
        }
    }
}
#endif

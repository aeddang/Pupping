//
//  ProfileDetail.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/14.
//

import Foundation
import SwiftUI

struct PetHistory: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
   
    var profile:PetProfile
    var userId:String? = nil
    
   
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.regular){
            CategoryButton(
                icon:Asset.icon.footPrint,
                color:Color.brand.primary,
                title:String.pageText.profileWalkHistory,
                subTitle: (self.profile.totalWalkCount != nil)
                    ? String.pageText.profileHistoryTotalWalk.replace(self.profile.totalWalkCount!.description)
                    : nil
            )
            {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.history)
                            .addParam(key: .type, value: MissionApi.Category.walk)
                            //.addParam(key: .id, value: self.userId)
                            .addParam(key: .subId, value: self.profile.petId)
                    )
            }
            CategoryButton(
                icon:Asset.icon.flag,
                color:Color.brand.primary,
                title:String.pageText.profileMissionHistory,
                subTitle:(self.profile.totalWalkCount != nil)
                ? String.pageText.profileHistoryTotalMission.replace(self.profile.totalMissionCount!.description)
                : nil
            ){
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.history)
                            .addParam(key: .type, value: MissionApi.Category.mission)
                            //.addParam(key: .id, value: self.userId)
                            .addParam(key: .subId, value: self.profile.petId)
                    )
            }
            
            CategoryButton(
                icon:Asset.icon.report,
                color:Color.brand.secondary,
                title:String.pageText.profileHealthCare,
                subTitle:(self.profile.recordSummry() != nil)
                ? String.pageText.profileHistoryTotalRecord.replace(self.profile.recordSummry()!)
                : nil
            ){
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.report)
                            .addParam(key: .data, value:self.profile)
                            .addParam(key: .id, value: self.userId)
                    )
            }
        }
    }
}


#if DEBUG
struct PetHistory_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PetHistory(
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

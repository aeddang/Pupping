//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps

struct PageMissionCompleted: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var missionManager:MissionManager
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @State var mission:Mission? = nil
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                ZStack(alignment: .topLeading){
                    if let mission = self.mission {
                        RedeemInfo(
                            title: String.pageText.missionCompleted,
                            text: String.pageText.missionCompletedText.replace(
                                (mission.playTime/60).toTruncateDecimal(n:1)
                            ),
                            point: mission.lv.point()
                        ){
                            self.onClose()
                        }
                    }
                }
                .padding(.all, Dimen.margin.regular)
                .modifier(MatchParent())
                .background(Color.transparent.black70)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            .onAppear{
                self.mission = self.missionManager.currentMission
                
            }
            .onDisappear{
               
            }
        }//geo
    }//body
   
    private func onClose(){
        if let mission = self.mission {
            self.dataProvider.user.missionCompleted(mission)
        }
        self.missionManager.completedMission()
        self.missionManager.endMission()
        self.pagePresenter.closeAllPopup()
    }
}


#if DEBUG
struct PageMissionCompleted_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMissionCompleted().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

 

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
extension PageMissionInfo {
    static let zoomRatio:Float = 15.0
    static let zoomCloseup:Float = 16.0
    static let mapMoveDuration:Double = 1.0
    static let forceMoveDelay:Double = 2.0
}
struct PageMissionInfo: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var missionManager:MissionManager
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var mapModel:PlayMapModel = PlayMapModel()
    
    @State var mission:Mission? = nil
    @State var isUiReady:Bool = false
    @State var isFollowMe:Bool = false
    @State var isForceMove:Bool = false
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                ZStack(alignment: .topLeading){
                    VStack(spacing:0){
                        PageTab(
                            title: String.pageTitle.missionInfo,
                            isClose:true
                        )
                        .padding(.top, self.sceneObserver.safeAreaTop)
                        VStack(spacing:Dimen.margin.thin){
                            if let mission = self.mission {
                                MissionInfo(data: mission)
                            }
                            ZStack{
                                PlayMap(
                                    pageObservable: self.pageObservable,
                                    viewModel: self.mapModel,
                                    isFollowMe: self.$isFollowMe,
                                    isForceMove: self.$isForceMove
                                    )
                            }
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
                            .modifier(Shadow())
                        }
                        .modifier(ContentHorizontalEdges())
                    }
                    .padding(.bottom, Dimen.margin.regular + self.sceneObserver.safeAreaBottom)
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.prevInit()
                }
            }
            .onAppear{
                self.mapModel.zoom = Self.zoomRatio
                self.mapModel.startLocation = self.missionManager.generator.finalLocation ?? CLLocation()
                self.mapModel.uiEvent = .move(self.mapModel.startLocation)
                guard let obj = self.pageObject  else { return }
                self.mission = obj.getParamValue(key: .data) as? Mission
            }
            
        }//geo
    }//body
   
    private func prevInit(){
        guard let mission = self.mission else { return }
        self.mapModel.playEvent = .setupMission(mission)
    }
}


#if DEBUG
struct PageMissionInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMissionInfo().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

 

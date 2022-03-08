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
    
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var missionManager:MissionManager
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var mapModel:PlayMapModel = PlayMapModel()
    
    @State var mission:Mission? = nil
    @State var isUiReady:Bool = false
    @State var isFollowMe:Bool = false
    @State var isForceMove:Bool = false
    
    @State var bottomMargin:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                ZStack(alignment: .topLeading){
                    VStack(spacing:0){
                        PageTab(
                            title: String.pageTitle.missionInfo,
                            isClose:true
                        )
                        .padding(.top, self.appSceneObserver.safeHeaderHeight)
                        VStack(spacing:Dimen.margin.thin){
                            if let mission = self.mission {
                                PlayMissionInfo(data: mission)
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
                        
                        FillButton(
                            text: String.button.start, isSelected:true){ _ in
                            self.startMission()
                            
                        }
                        .modifier(ContentHorizontalEdges())
                    }
                    .padding(.bottom, self.bottomMargin)
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.prevInit()
                }
            }
            .onReceive(self.appSceneObserver.$safeBottomHeight){ height in
                withAnimation{ self.bottomMargin = height }
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
    
    private func startMission(){
        
        guard let mission = self.mission else { return }
        if self.missionManager.currentMission == mission {
            self.appSceneObserver.event = .toast(String.alert.currentPlayMission)
            return
        }
        if self.dataProvider.user.pets.isEmpty {
            self.appSceneObserver.alert = .alert(nil, String.alert.needProfileRegist, nil){
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.profileRegist)
                )
            }
            return
        }
        if self.pagePresenter.hasLayerPopup() {
            if self.missionManager.currentMission != nil {
                self.appSceneObserver.alert = .confirm(nil, String.alert.prevPlayMission){ ac in
                    if ac {
                        self.missionManager.endMission()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.startMission(mission:mission)
                        }
                        
                    }
                }
            } else {
                self.appSceneObserver.alert = .confirm(nil, String.alert.prevPlayWalk){ ac in
                    if ac {
                        self.pagePresenter.closePopup(pageId: .walk)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.startMission(mission:mission)
                        }
                    }
                }
            }
        }else {
            self.startMission(mission:mission)
        }
    }
    
    private func startMission(mission:Mission){
        self.pagePresenter.closePopup(self.pageObject?.id)
        self.missionManager.startMission(mission)
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.mission)
                .addParam(key: UUID().uuidString, value:  "")
                .addParam(key: .autoStart, value:  true)
        )
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

 

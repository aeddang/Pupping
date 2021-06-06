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

extension PageMission {
    static let uiHeight:CGFloat = 160
    static let zoomRatio:Float = 17.0
    static let zoomCloseup:Float = 18.5
    static let mapMoveDuration:Double = 0.5
    static let forceMoveDelay:Double = 1.5
}

struct PageMission: PageView {
    enum UiType{
        case simple, normal
    }
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var missionManager:MissionManager
    @EnvironmentObject var locationObserver:LocationObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var mapModel:PlayMapModel = PlayMapModel()
    @ObservedObject var playMissionModel:PlayMissionModel = PlayMissionModel()
    
    @State var uiType:UiType = .normal
    @State var mission:Mission? = nil
    @State var missionInfoType:MissionInfo.UiType = .normal

    @State var dragOffset:CGFloat = 0
    @State var dragOpacity:Double = 1
    @State var isFollowMe:Bool = true
    @State var isForceMove:Bool = false
   
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical,
                dragingEndAction : { isBottom in
                    self.onDragEndAction(isBottom: isBottom, geometry:geometry)
                }
            ) {
                ZStack(alignment: .bottom){
                    PlayMap(
                        pageObservable: self.pageObservable,
                        viewModel: self.mapModel,
                        isFollowMe: self.$isFollowMe,
                        isForceMove: self.$isForceMove,
                        bottomMargin: (self.isPlay ? Self.uiHeight : Dimen.button.heavy) + self.sceneObserver.safeAreaBottom
                    )
                    .modifier(MatchParent())
                    .opacity(self.dragOpacity)
                    VStack(alignment: .trailing, spacing:Dimen.margin.thin){
                        Button(action: {
                            self.onClose()
                        }) {
                            Image(Asset.icon.close)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.app.greyDeep)
                                .frame(width: Dimen.icon.thin,
                                       height: Dimen.icon.thin)
                                .padding(.leading, Dimen.margin.regular)
                                .background(Color.transparent.clearUi)
                        }
                        .padding(.top,
                                 self.uiType == .normal
                                    ? Dimen.margin.medium + self.sceneObserver.safeAreaTop
                                    : Dimen.margin.regular)
                        .padding(.trailing, Dimen.margin.regular)
                        
                        if self.uiType == .simple {
                            PlaySummary(
                                playMissionModel: self.playMissionModel
                            )
                            .modifier(ContentHorizontalEdges())
                        }
                        VStack(spacing:Dimen.margin.thin){
                            if let mission = self.mission {
                                MissionInfo(
                                    data: mission,
                                    isPlay:true,
                                    uiType:self.missionInfoType
                                )
                                .onTapGesture {
                                    withAnimation{
                                        self.missionInfoType = self.missionInfoType == .normal ? .simple : .normal
                                    }
                                }
                                
                            }
                            Spacer()
                            if !self.isPlay {
                                FillButton(
                                    text: String.button.start, isSelected:true){ _ in
                                    self.playStart()
                                }
                            }
                        }
                        .modifier(ContentEdges())
                        .opacity(self.dragOpacity)
                        .padding(.bottom,  self.sceneObserver.safeAreaBottom)
                    }
                   
                    .padding(.bottom, self.isPlay ? Self.uiHeight : 0)
                    if self.isPlay {
                        PlayInfo(
                            playMissionModel: self.playMissionModel,
                            profiles: self.withProfiles
                        )
                    }
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                .modifier(BottomFunctionTab(
                            isEffect: self.uiType == .simple,
                            margin: 0))
                
                
            }
            .onReceive(self.missionManager.$currentMission) { mission in
                if !self.isInit { return }
                if self.mission != mission {
                    self.pagePresenter.closePopup(self.pageObject?.id)
                }
            }
            .onReceive(self.appSceneObserver.$useBottom) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateBottomPos()
                }
            }
            .onReceive(self.pageDragingModel.$event) { evt in
                guard let evt = evt  else { return }
                guard let page  = self.pageObject  else { return }
                switch evt {
                case .dragInit :
                    if self.isBottom {
                        PageLog.d("on dragInit setLayerPopup " + isBottom.description, tag: self.tag)
                        self.isBottom = false
                        self.pagePresenter.setLayerPopup(pageObject: page, isLayer: false)
                        withAnimation{
                            self.dragOffset = 0
                        }
                    }
                case .drag(_, let dragOpacity) :
                    self.dragOpacity = dragOpacity
                    PageLog.d("self.dragOffset " + self.dragOffset.description, tag: self.tag)
               
                default : break
                }
            }
            .onReceive(self.playMissionModel.$event) { evt in
                guard let evt = evt  else { return }
                switch evt {
                case .accessDenied :
                    self.appSceneObserver.alert = .requestLocation{ retry in
                        if retry { AppUtil.goLocationSettings() }
                    }
                case .start :
                    withAnimation{
                        self.isPlay = true
                    }
                default : break 
                }
            }
            .onReceive(self.playMissionModel.$currentLocation){ loc in
                guard let me = loc else {return}
                self.moveMe(loc: me)
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.playInit()
                }
            }
            .onReceive(self.dataProvider.user.$profiles){ profiles in
                if !self.isInit { return }
                if profiles.isEmpty {return}
                if self.isPlay {return}
                self.checkWithProfile()
            }
            .onReceive(self.pagePresenter.$event){ evt in
                guard let evt = evt else {return}
                switch evt.type {
                case .datas :
                    guard let selected = evt.data as? [Profile] else { return }
                    self.withProfiles = selected
                    self.playStart()
                default : break
                }
            }
            .onReceive(self.playMissionModel.$event) { evt in
                guard let evt = evt  else { return }
                switch evt {
                case .next(_):
                    self.playNext()
                case .completed:
                    self.playCompleted()
                default : break
                }
            }
            .onAppear{
                self.mapModel.zoom = Self.zoomRatio
                self.mapModel.startLocation = self.missionManager.generator.finalLocation ?? CLLocation()
                self.mapModel.uiEvent = .move(self.mapModel.startLocation)
                self.mission = self.missionManager.currentMission
            }
            .onDisappear{
                if self.missionManager.currentMission == self.mission {
                    self.missionManager.endMission()
                }
            }
        }//geo
    }//body
    @State var isInit:Bool = false
    @State var isPlay:Bool = false
    @State var withProfiles:[Profile] = []
    private func playInit(){
        guard let mission = self.mission else { return }
        self.mapModel.playEvent = .setupMission(mission)
        self.isInit = true
    }
    private func moveMe(loc:CLLocation){
        self.mapModel.playEvent = .me(loc)
    }
    
    private func playStart(){
        if self.withProfiles.isEmpty {
            self.checkWithProfile()
            return
        }
        guard let mission = self.mission else { return }
        self.playMissionModel.startMission(mission: mission, locationObserver: self.locationObserver)
        withAnimation{
            self.missionInfoType = .simple
        }
        
        if let start = self.playMissionModel.startLocation {
            self.mapModel.uiEvent = .move(start, zoom: Self.zoomCloseup, duration: Self.mapMoveDuration)
            self.forceMoveLock()
        }
    }
    private func playNext(){
        if let location = self.playMissionModel.currentDestination?.location {
            self.mapModel.uiEvent = .move(location, zoom: Self.zoomCloseup, duration: Self.mapMoveDuration)
            self.forceMoveLock()
        }
    }
    
    private func playCompleted(){
        guard let mission = self.mission else { return }
        mission.playTime = self.playMissionModel.playTime
        mission.playDistence = self.playMissionModel.playDistence
        self.pagePresenter.closePopup(self.pageObject?.id)
        self.pagePresenter.openPopup(PageProvider.getPageObject(.missionCompleted))
    }
    
    private func forceMoveLock(){
        self.isForceMove = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.forceMoveDelay) {
            self.isForceMove = false
        }
    }
    
    private func checkWithProfile(){
        if self.dataProvider.user.profiles.isEmpty {
            self.appSceneObserver.alert = .alert(nil, String.alert.closePlayMission, nil){
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.profileRegist)
                )
            }
            
        } else if self.dataProvider.user.profiles.count == 1{
            if let profile = self.dataProvider.user.profiles.first {
                self.withProfiles.append(profile)
                self.playStart()
            }
        } else {
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.selectProfile)
            )
        }
        
    }
    
    
   
    
    @State var isBottom:Bool = false
    func onDragEndAction(isBottom: Bool, geometry:GeometryProxy) {
        self.isBottom = isBottom
        if let page  = self.pageObject {
            PageLog.d("onDragEndAction setLayerPopup " + isBottom.description, tag: self.tag)
            self.pagePresenter.setLayerPopup(pageObject: page, isLayer: isBottom)
        }
        if isBottom {
            updateBottomPos()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation{
                self.uiType = isBottom ? .simple : .normal
                self.dragOffset = isBottom ? self.sceneObserver.screenSize.height - (Dimen.app.bottomTab - 50) : 0
                self.dragOpacity = isBottom ? 0 : 1
            }
        }
    }
    
    @State private var currentPos:CGFloat = -1
    private func updateBottomPos(){
        if !self.isBottom {return}
        let hei = Dimen.app.bottomTab + (self.appSceneObserver.useBottom ? Dimen.app.bottom : 0 )
        if hei == self.currentPos {return}
        self.currentPos = hei
        let offset = self.sceneObserver.screenSize.height - hei + self.sceneObserver.safeAreaBottom
        self.pageDragingModel.uiEvent = .setBodyOffset( offset )
        
    }
    
    private func onClose(){
        self.appSceneObserver.alert = .confirm(nil, String.alert.closePlayMission){ ac in
            if ac {
                self.pagePresenter.closePopup(self.pageObject?.id)
            }
        }
    }
    
}


#if DEBUG
struct PageMission_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMission().contentBody
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

 

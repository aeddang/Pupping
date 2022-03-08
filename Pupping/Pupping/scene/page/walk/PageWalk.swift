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

extension PageWalk {
    static let uiHeight:CGFloat = 160
    static let zoomRatio:Float = 17.0
    static let zoomCloseup:Float = 18.5
    static let mapMoveDuration:Double = 0.5
    static let forceMoveDelay:Double = 1.5
    
    static let limitedDistence:Double = 1
}

struct PageWalk: PageView {
    enum UiType{
        case simple, normal
    }
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var locationObserver:LocationObserver
    @EnvironmentObject var missionManager:MissionManager
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var mapModel:PlayMapModel = PlayMapModel()
    @ObservedObject var viewModel:PlayWalkModel = PlayWalkModel(type: .walk)
    
    @State var uiType:UiType = .normal
    
    @State var dragOffset:CGFloat = 0
    @State var dragOpacity:Double = 1
    @State var isFollowMe:Bool = true
    @State var isForceMove:Bool = false
    @State var walk:Walk = Walk()
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
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
                        HStack(spacing:Dimen.margin.thin){
                            DragOnOffButton(
                                isOn: self.uiType == .normal
                            ){
                                self.pageDragingModel.uiEvent = .dragEnd(!self.isBottom)
                            }
                            Spacer()
                            CloseButton(){
                                self.onClose()
                            }
                        }
                        .padding(.horizontal, Dimen.margin.regular)
                        
                        if self.uiType == .simple {
                            PlaySummary(
                                viewModel: self.viewModel
                            )
                            .modifier(ContentHorizontalEdges())
                            .onTapGesture {
                                self.pageDragingModel.uiEvent = .dragEnd(false)
                            }
                        }
                        VStack(spacing:Dimen.margin.thin){
                            Spacer().modifier(MatchParent())
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
                    .padding(.top, self.isBottom ? Dimen.margin.thin : self.appSceneObserver.safeHeaderHeight)
                    .padding(.bottom, self.isPlay ? Self.uiHeight : 0)
                    if self.isPlay {
                        PlayInfo(
                            viewModel: self.viewModel,
                            profiles: self.withProfiles
                        )
                    }
                }
                .modifier(PageFull(style:.white))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                .modifier(BottomFunctionTab(
                            isEffect: self.uiType == .simple,
                            margin: 0))
                
                
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
            .onReceive(self.viewModel.$event) { evt in
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
                case .completed:
                    self.playCompleted()
                default : break
                }
            }
            .onReceive(self.viewModel.$currentLocation){ loc in
                guard let me = loc else {return}
                self.moveMe(loc: me)
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isInit = true
                }
            }
            .onReceive(self.dataProvider.user.$pets){ profiles in
                if !self.isInit { return }
                if profiles.isEmpty {return}
                if self.isPlay {return}
                self.checkWithProfile()
            }
            .onReceive(self.pagePresenter.$event){ evt in
                guard let evt = evt else {return}
                switch evt.type {
                case .datas :
                    guard let selected = evt.data as? [PetProfile] else { return }
                    self.withProfiles = selected
                    self.playStart()
                default : break
                }
            }
            
            .onAppear{
                self.mapModel.zoom = Self.zoomRatio
                self.mapModel.startLocation = self.missionManager.generator.finalLocation ?? CLLocation()
                self.mapModel.uiEvent = .move(self.mapModel.startLocation)
               
            }
            .onDisappear{
                self.viewModel.pauseWalk()
            }
        }//geo
    }//body
   
    @State var isInit:Bool = false
    @State var isPlay:Bool = false
    @State var withProfiles:[PetProfile] = []
   
    private func moveMe(loc:CLLocation){
        self.mapModel.playEvent = .me(loc)
        if self.walk.locations.isEmpty {
            self.walk.locations.append(loc)
        }
    }
    
    private func playStart(){
        if self.withProfiles.isEmpty {
            self.checkWithProfile()
            return
        }
        self.viewModel.startWalk(locationObserver: self.locationObserver)
    }
    
    
    private func playCompleted(){
        self.onClose()
        
    }
    
    
    private func checkWithProfile(){
        if self.dataProvider.user.pets.count == 1{
            if let profile = self.dataProvider.user.pets.first {
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
        //if hei == self.currentPos {return}
        self.currentPos = hei
        let offset = self.sceneObserver.screenSize.height - hei + self.sceneObserver.safeAreaBottom
        self.pageDragingModel.uiEvent = .setBodyOffset( offset )
        
    }
    
    private func onClose(){
        self.appSceneObserver.alert = .confirm(nil, String.alert.closePlayWalk.replace(Self.limitedDistence.description)){ ac in
            if ac {
                if self.viewModel.playDistence > Self.limitedDistence {
                    self.walk.playDistence = self.viewModel.playDistence
                    self.walk.playTime = self.viewModel.playTime
                    if let loc = self.viewModel.currentLocation { self.walk.locations.append(loc) }
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.walkCompleted)
                            .addParam(key: .data, value: self.walk)
                            .addParam(key: .datas, value: self.withProfiles)
                    )
                } else {
                    self.pagePresenter.closePopup(self.pageObject?.id)
                }
                
            }
        }
    }
    
}


#if DEBUG
struct PageWalk_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageWalk().contentBody
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

 

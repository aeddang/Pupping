//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine


struct PageMission: PageView {
    enum UiType{
        case simple, normal
    }
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var missionManager:MissionManager
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var mapModel:MapModel = MapModel()
    
    @State var uiType:UiType = .normal
    @State var mission:Mission? = nil
    @State var missionInfoType:MissionInfo.UiType = .normal
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical,
                dragingEndAction : { isBottom in
                    self.onDragEndAction(isBottom: isBottom, geometry:geometry)
                }
            ) {
                ZStack(alignment: .topLeading){
                    VStack(spacing:0){
                        PageTab(
                            title: self.uiType == .normal ? nil : self.mission?.type.info(),
                            isClose:true
                        ){
                            self.onClose()
                        }
                       
                        .padding(.top,  self.uiType == .normal ? self.sceneObserver.safeAreaBottom : 0)
                        
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
                            ZStack{
                                CPGoogleMap(viewModel: self.mapModel, pageObservable: self.pageObservable)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
                            .modifier(Shadow())
                        }
                        .modifier(ContentHorizontalEdges())
                        .padding(.bottom, Dimen.margin.thin)
                        
                    }
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }
            .modifier(ShadowTop(opacity: self.uiType == .normal ? 0 : 0.12) )
            .onReceive(self.missionManager.$currentMission) { mission in
                self.mission = mission
                
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
                    }
                default : break
                }
            }
            .onAppear{
              
            }
            .onDisappear{
                self.missionManager.endMission()
            }
        }//geo
    }//body
   
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation{ self.uiType = isBottom ? .simple : .normal }
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
        PageLog.d("updateBottomPos " + offset.description, tag: self.tag)
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

 

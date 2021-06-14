//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PageHome: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var missionManager:MissionManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewPagerModel:ViewPagerModel = ViewPagerModel()
    
    @State var reloadDegree:Double = 0
    @State var reloadDegreeMax:Double = Double(InfinityScrollModel.PULL_COMPLETED_RANGE)
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading){
                ReflashSpinner(
                    progress: self.$reloadDegree)
                    .padding(.top, Dimen.margin.regular)
                InfinityScrollView(
                    viewModel: self.infinityScrollModel,
                    scrollType : .reload(isDragEnd: false),
                    isRecycle:false,
                    useTracking:true)
                {
                    VStack(spacing:Dimen.margin.regular){
                        CPImageViewPager(
                            viewModel : self.viewPagerModel,
                            pages: self.profilePages
                        )
                        .modifier(MatchHorizontal(height: 150))
                        LocationInfo()
                        if self.isUiReady, let missions = self.missions  {
                            ForEach(missions){ mission in
                                MissionInfo(data:mission)
                                .onTapGesture {
                                    self.selectMission(mission)
                                }
                            }
                        }
                    }
                    .modifier(ContentHorizontalEdges())
                    .padding(.top, self.appSceneObserver.safeHeaderHeight + Dimen.margin.regular)
                    .padding(.bottom, self.bottomMargin + Dimen.app.bottomTab)
                }
            }
            .onReceive(self.appSceneObserver.$safeBottomHeight){ height in
                withAnimation{ self.bottomMargin = height }
            }
            .onReceive(self.infinityScrollModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCompleted :
                    if !self.missionManager.isBusy {
                        self.missionManager.generateMission()
                    }
                    withAnimation{ self.reloadDegree = 0 }
                case .pullCancel :
                    withAnimation{ self.reloadDegree = 0 }
                default : do{}
                }
                
            }
            .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                if pos < InfinityScrollModel.PULL_RANGE { return }
                self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
            }
            .onReceive(self.dataProvider.user.$profiles){ profiles in
                if profiles.isEmpty {
                    self.profiles = [Profile().empty()]
                } else {
                    self.profiles = profiles
                }
                if let pages = self.profiles {
                    self.profilePages = pages.map{
                        ProfileItem(profile: $0)
                    }
                    self.viewPagerModel.request = .jump(0)
                }
            }
            .onReceive(self.missionManager.generator.$isBusy){ isBusy in
                self.appSceneObserver.isApiLoading = isBusy
            }
            .onReceive(self.missionManager.$isMissionsUpdated) { isUpdated in
                if isUpdated {
                    self.onMissionUpdated()
                    if !self.isUiReady {
                        withAnimation{
                            self.isUiReady = true
                        }
                    }
                }
            }
        }//geo
        .modifier(PageFull())
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                if self.missionManager.missions.isEmpty {
                    
                    self.missionManager.generateMission()
                } else {
                    self.onMissionUpdated()
                    withAnimation{
                        self.isUiReady = true
                    }
                }
            }
        }
        .onAppear{
            
        }
    }//body
    @State var missions:[Mission]? = nil
    @State var profiles:[Profile]? = nil
    @State var profilePages: [PageViewProtocol] = []
    
    private func onMissionUpdated(){
        self.pagePresenter.isLoading = false
        self.missions = self.missionManager.missions
        self.missions?.forEach{ mission in
            PageLog.d("mission " + mission.type.info() , tag: self.tag)
            PageLog.d("mission " + mission.playType.info() , tag: self.tag)
            PageLog.d("mission " + mission.description , tag: self.tag)
        }
    }
    
    private func selectMission(_ mission:Mission){
        
        if self.missionManager.currentMission == mission {
            self.appSceneObserver.event = .toast(String.alert.currentPlayMission)
            return
        }
        self.appSceneObserver.select = .select((self.tag , [String.button.preview, String.button.start]), 1){ idx in
            if idx == 0 {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.missionInfo)
                        .addParam(key: .data, value: mission)
                )
            }else {
                startMission(mission)
            }
            
        }
    }
    
    private func startMission(_ mission:Mission){
        
        if self.missionManager.currentMission == mission {
            self.appSceneObserver.event = .toast(String.alert.currentPlayMission)
            return
        }
        if self.pagePresenter.hasLayerPopup() {
            if self.missionManager.currentMission == nil {
                self.appSceneObserver.alert = .confirm(nil, String.alert.prevPlayWalk){ ac in
                    if ac {
                        self.pagePresenter.closePopup(pageId: .walk)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.startMission(mission)
                        }
                    }
                }
                return
            }
        }
        if self.dataProvider.user.profiles.isEmpty {
            self.appSceneObserver.alert = .alert(nil, String.alert.needProfileRegist, nil){
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.profileRegist)
                )
            }
            return
        }
        if self.missionManager.currentMission != nil {
            self.appSceneObserver.alert = .confirm(nil, String.alert.prevPlayMission){ ac in
                if ac {
                    self.missionManager.endMission()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.missionManager.startMission(mission)
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.mission)
                                .addParam(key: UUID().uuidString, value:  "")
                        )
                    }
                    
                }
            }
        } else {
            self.missionManager.startMission(mission)
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.mission)
                    .addParam(key: UUID().uuidString, value:  "")
            )
        }
    }
}


#if DEBUG
struct PageHome_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageHome().contentBody
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


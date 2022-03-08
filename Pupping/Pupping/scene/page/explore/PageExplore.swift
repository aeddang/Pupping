//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
import CoreLocation
extension PageExplore{
    static let filters = [
        "none",
        "500m",
        "1Km",
        "5km",
        "10Km"
    ]
    
    static let values:[Double] = [
        0, 500, 1000, 5000, 10000
    ]
    static let zooms:[Float] = [
        8, 14, 13, 12, 10
    ]
    static private var filter:Int = 0
}

struct PageExplore: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var locationObserver:LocationObserver
 
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var userMapModel: UserMapModel = UserMapModel()
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
    @State var isMap:Bool = true
    
    @State var currentFilterIdx = Self.filter
    @State var currentFilter = ""
    @State var reloadDegree:Double = 0
    @State var reloadDegreeMax:Double = Double(InfinityScrollModel.PULL_COMPLETED_RANGE)
    @State var isFollowMe:Bool = false
    @State var isForceMove:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            HStack(spacing:Dimen.margin.thin){
                PageTab(
                    title: String.gnb.explore,
                    isBack: false,
                    isClose: false,
                    isSetting: false)
                ImageButton(
                    isSelected: self.isMap,  defaultImage: Asset.icon.map,
                    size: .init(width: Dimen.icon.regular, height: Dimen.icon.regular),
                    defaultColor: Color.app.greyLight, activeColor: Color.app.black){_ in
                        self.isMap = true
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.05){
                            self.updateLocation()
                        }
                    }
                
                Spacer().modifier(LineVertical(width: Dimen.line.light))
                    .frame( height: Dimen.tab.thin )
                
                ImageButton(
                    isSelected: !self.isMap,  defaultImage: Asset.icon.list,
                    size: .init(width: Dimen.icon.regular, height: Dimen.icon.regular),
                    defaultColor: Color.app.greyLight, activeColor: Color.app.black){_ in
                        self.isMap = false
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.05){
                            self.updateLocation()
                        }
                    }
            }
            .padding(.top, self.sceneObserver.safeAreaTop)
            .padding(.trailing, Dimen.margin.light)
            ZStack(alignment: .top){
                
                ReflashSpinner(
                    progress: self.$reloadDegree)
                    .padding(.top, Dimen.margin.regular + Dimen.margin.regular)
                if self.isMap {
                    UserMap(
                        pageObservable: self.pageObservable,
                        viewModel: self.userMapModel,
                        isFollowMe: self.$isFollowMe,
                        isForceMove: self.$isForceMove)
                
                } else {
                    if let dataSets = self.dataSets {
                        if dataSets.isEmpty {
                            EmptyInfo()
                                .padding(.top, Dimen.margin.medium + Dimen.margin.thin)
                        } else {
                            UserListSet(
                                viewModel: self.infinityScrollModel,
                                datas: dataSets){
                                    self.load()
                                }
                                .padding(.top, Dimen.margin.medium + Dimen.margin.thin)
                                .modifier(MatchParent())
                        }
                    } else {
                        Spacer().modifier(MatchParent())
                    }
                }
                
                HStack{
                    Spacer()
                    SortButton(
                        text: self.currentFilterIdx == 0
                        ? String.app.filter
                        : String.app.near + self.currentFilter,
                        isSelected: self.currentFilterIdx != 0,
                        icon: Asset.icon.filter
                    ){
                        self.appSceneObserver.select = .select((self.tag , Self.filters), Self.filter){ idx in
                            self.currentFilterIdx = idx
                            Self.filter = idx
                            self.setupFilter()
                            self.reload()
                        }
                    }
                }
                .modifier(ContentHorizontalEdges())
                .padding(.top, Dimen.margin.thin)
            }
            .padding(.top, Dimen.margin.medium)
        }
        .padding(.bottom, self.bottomMargin)
        .onReceive(self.infinityScrollModel.$event){evt in
            guard let evt = evt else {return}
            switch evt {
            case .pullCompleted :
                if !self.infinityScrollModel.isLoading {
                    self.reload()
                }
                withAnimation{ self.reloadDegree = 0 }
            case .pullCancel :
                withAnimation{ self.reloadDegree = 0 }
            default : break
            }
            
        }
        .onReceive(self.userMapModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .selectedMarker(let marker):
                guard let markerUser = marker.userData as? User else{ return }
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.user)
                        .addParam(key: .data, value: markerUser)
                )
            default : break
            }
        }
        .onReceive(self.infinityScrollModel.$pullPosition){ pos in
            if pos < InfinityScrollModel.PULL_RANGE { return }
            self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
        }
        .onReceive(self.locationObserver.$event) { evt in
            guard let evt = evt else {return}
            switch evt {
            case .updateAuthorization(let status):
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self.requestLocation()
                }
            case .updateLocation(let loc):
                if self.location != nil {return}
                self.location = loc
                self.clearWaitingRequestLocation()
                self.reload()
            }
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .searchMission : self.loaded(res)
            default : break
            }
        }
        .onReceive(self.appSceneObserver.$safeBottomHeight){ height in
            withAnimation{ self.bottomMargin = height }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                self.isUiReady = true
                self.load()
            }
        }
        .modifier(PageFull())
        .onAppear{
            self.setupFilter()
            self.requestLocation()
        }
        .onDisappear{
            self.clearWaitingRequestLocation()
        }
    }//body
    @State var datas:[User] = []
    @State var dataSets:[UserDataSet]? = nil
    @State var isError:Bool? = nil
    @State var location:CLLocation? = nil
   
    
    @State var requestLocationTimer:AnyCancellable?
    func waitingRequestLocation(){
        self.location = nil
        self.locationObserver.requestMe(true, id:nil)
        
        var count = 0
        self.requestLocationTimer?.cancel()
        self.requestLocationTimer = Timer.publish(
            every: 1, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                if count == 0 {
                    self.appSceneObserver.loadingInfo = [
                        String.alert.locationFind
                    ]
                } else if count == 2 {
                    self.clearWaitingRequestLocation()
                    DispatchQueue.main.async {
                        if self.location != nil {return}
                        self.undefinedLocation()
                    }
                }
                count += 1
            }
    }
    func clearWaitingRequestLocation() {
        self.locationObserver.requestMe(false, id:self.tag)
        self.appSceneObserver.loadingInfo = nil
        self.requestLocationTimer?.cancel()
        self.requestLocationTimer = nil
    }
    func requestLocation() {
        let status = self.locationObserver.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.waitingRequestLocation()
           
            
        } else if status == .denied {
            self.appSceneObserver.alert = .requestLocation{ retry in
                if retry { AppUtil.goLocationSettings() }
            }
        } else {
            self.locationObserver.requestWhenInUseAuthorization()
        }
    }
    
    func undefinedLocation(){
        self.appSceneObserver.alert = .confirm(nil, String.alert.locationDisable){ isOk in
            if isOk {
                self.requestLocation()
            }
        }
    }
    
    func setupFilter(){
        if self.currentFilterIdx == 0 {
            self.currentFilter = ""
        } else {
            self.currentFilter = Self.filters[self.currentFilterIdx]
        }
    }
   
    func reload(){
        self.isError = nil
        self.datas = []
        self.dataSets = nil
        self.infinityScrollModel.reload()
        self.load()
    }

    func load(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        if self.currentFilterIdx == 0 {
            self.dataProvider.requestData(
                q: .init(
                    id: self.tag,
                    type: .searchMission(
                        .all, .Random,
                        page: self.infinityScrollModel.page) ))
        } else  if let loc = self.location {
            self.dataProvider.requestData(
                q: .init(
                    id: self.tag,
                    type: .searchMission(
                        .all, .User,
                        location: loc,
                        distance: Self.values[self.currentFilterIdx],
                        page: self.infinityScrollModel.page) ))
        } else {
            self.undefinedLocation()
            self.dataSets = []
        }
        
    }
    
    private func loaded(_ res:ApiResultResponds){
       
        guard let datas = res.data as? [MissionData] else { return }
        var added:[User] = []
        if !datas.isEmpty {
            let start = self.datas.count
            let end = start + datas.count
            added = zip(start...end, datas).map { idx, d in
                return User().setData(d)
            }
        }
        self.datas.append(contentsOf: added)
        self.onDataSet()
        self.infinityScrollModel.onComplete(itemCount: added.count)
        
    }
    
    private func onDataSet(){
        let count:Int = 2
        var rows:[UserDataSet] = []
        var cells:[User] = []
        var total = self.datas.count
        self.datas.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    UserDataSet( count: count, datas: cells, isFull: true, index:total)
                )
                total += 1
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(
                UserDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        self.dataSets = rows
        self.updateLocation()
        
    }
    
    @State var isInitMove:Bool = true
    private func updateLocation(){
        self.userMapModel.userEvent = .setupMap(self.datas)
        if let loc = self.location {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05){
                self.userMapModel.userEvent = .me(loc)
                let zoom = PageExplore.zooms[self.currentFilterIdx]
                self.userMapModel.uiEvent = .move(
                    loc, zoom:  zoom,
                    duration: self.isInitMove ? 0 :  0.5)
                self.isInitMove = false
            }
        }
    }
}


#if DEBUG
struct PageExplore_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageExplore().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 340, height: 640, alignment: .center)
        }
    }
}
#endif


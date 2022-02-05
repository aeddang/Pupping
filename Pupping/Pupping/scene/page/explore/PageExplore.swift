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
   
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
    
    
    @State var currentFilterIdx = Self.filter
    @State var currentFilter = ""
    @State var reloadDegree:Double = 0
    @State var reloadDegreeMax:Double = Double(InfinityScrollModel.PULL_COMPLETED_RANGE)
    
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            PageTab(
                title: String.gnb.explore,
                isBack: false,
                isClose: false,
                isSetting: false)
                .padding(.top, self.sceneObserver.safeAreaTop)
            
            HStack{
                Text(String.app.near + self.currentFilter)
                    .modifier(ContentTitle())
                Spacer()
                SortButton(
                    text: String.app.filter,
                    isSelected: false,
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
            .padding(.top, Dimen.margin.mediumUltra)
            ZStack(alignment: .top){
                ReflashSpinner(
                    progress: self.$reloadDegree)
                    .padding(.top, Dimen.margin.regular)
                if let dataSets = self.dataSets {
                    if dataSets.isEmpty {
                        EmptyInfo()
                    } else {
                        UserListSet(
                            viewModel: self.infinityScrollModel,
                            datas: dataSets){
                                self.load()
                            }
                            .modifier(MatchParent())
                    }
                } else {
                    Spacer().modifier(MatchParent())
                }
            }
            
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
                self.location = loc
                self.locationObserver.requestMe(false, id:self.tag)
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
    }//body
    @State var datas:[User] = []
    @State var dataSets:[UserDataSet]? = nil
    @State var isError:Bool? = nil
    @State var location:CLLocation? = nil
    
    func requestLocation() {
        let status = self.locationObserver.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.locationObserver.requestMe(true, id:self.tag)
            
        } else if status == .denied {
            self.appSceneObserver.alert = .requestLocation{ retry in
                if retry { AppUtil.goLocationSettings() }
            }
        } else {
            self.locationObserver.requestWhenInUseAuthorization()
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
            self.appSceneObserver.event = .toast(String.alert.locationDisable)
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


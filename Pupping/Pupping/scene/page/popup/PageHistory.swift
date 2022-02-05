//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PageHistory: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
   
    
    @State var reloadDegree:Double = 0
    @State var reloadDegreeMax:Double = Double(InfinityScrollModel.PULL_COMPLETED_RANGE)
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(alignment: .leading, spacing:0){
                    PageTab(
                        title:  self.title ?? String.pageTitle.history,
                        isBack: true,
                        isClose: false,
                        isSetting: false)
                        .padding(.top, self.sceneObserver.safeAreaTop)
                    
                    ZStack(alignment: .top){
                        ReflashSpinner(
                            progress: self.$reloadDegree)
                            .padding(.top, Dimen.margin.regular)
                        if let datas = self.datas {
                            if datas.isEmpty {
                                EmptyInfo()
                            } else {
                                HistoryList(
                                    viewModel: self.infinityScrollModel,
                                    datas: datas){ _ in
                                        self.load()
                                    }
                            }
                        } else {
                            Spacer().modifier(MatchParent())
                        }
                    }
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
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
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isUiReady = true
                    self.load()
                }
            }
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .getMission: self.loaded(res)
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                let userId = obj.getParamValue(key: .id) as? String
                let petId = obj.getParamValue(key: .subId) as? Int
                let type = obj.getParamValue(key: .type) as? MissionApi.Category
                if let typeStr = type?.getView(){
                    self.title = typeStr + " " + String.pageTitle.history
                }
                if let nick = obj.getParamValue(key: .text) as? String {
                    self.title = nick + String.app.owner + " " + (self.title ?? String.pageTitle.history)
                }
                self.userId = userId
                self.petId = petId
                self.type = type ?? .mission
            }
        }
    }//body
    @State var datas:[History]? = nil
    @State var isError:Bool? = nil
    @State var userId:String? = nil
    @State var petId:Int? = nil
    @State var title:String? = nil
    @State var type:MissionApi.Category = .mission
    func reload(){
        self.isError = nil
        self.datas = nil
        self.infinityScrollModel.reload()
        self.load()
    }

    func load(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        self.dataProvider.requestData(
            q: .init(
                id: self.tag, type: .getMission(
                    userId:self.userId,
                    petId: self.petId,
                    self.type,
                    page: self.infinityScrollModel.page 
                )
            )
        )
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [MissionData] else { return }
        var added:[History] = []
        if !datas.isEmpty {
            let start = self.datas?.count ?? 0
            let end = start + datas.count
            added = zip(start...end, datas).map { idx, d in
                return History(data: d, idx: idx)
            }
        }
        if self.datas != nil {
            self.datas!.append(contentsOf: added)
        } else {
            self.datas = added
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }
    
}


#if DEBUG
struct PageHistory_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageHistory().contentBody
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


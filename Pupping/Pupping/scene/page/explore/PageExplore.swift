//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

extension PageExplore{
    static let filters = [
        "500m",
        "1Km",
        "5km",
        "10Km"
    ]
    
    static private var filter:Int = 0
}

struct PageExplore: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var userScrollModel:InfinityScrollModel = InfinityScrollModel()
   
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
    
    
    @State var currentFilterIdx = Self.filter
    @State var currentFilter = Self.filters[ Self.filter ]
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
                        self.currentFilter = Self.filters[idx]
                        Self.filter = idx
                    }
                }
            }
            .modifier(ContentHorizontalEdges())
            .padding(.top, Dimen.margin.mediumUltra)
            if !self.users.isEmpty {
                UserListSet( viewModel: self.userScrollModel, datas: self.users)
                    .modifier(MatchParent())
            } else {
                Spacer().modifier(MatchParent())
            }
        }
        .padding(.bottom, self.bottomMargin)
        .onReceive(self.appSceneObserver.$safeBottomHeight){ height in
            withAnimation{ self.bottomMargin = height }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                self.isUiReady = true
            }
        }
        .modifier(PageFull())
        .onAppear{
            self.users = [
                UserDataSet( datas: [User().setDummy(), User().setDummy()], isFull:true),
                UserDataSet( datas: [User().setDummy(), User().setDummy()], isFull:true),
                UserDataSet( datas: [User().setDummy(), User().setDummy()], isFull:true),
                UserDataSet( datas: [User().setDummy(), User().setDummy()], isFull:true),
                UserDataSet( datas: [User().setDummy()], isFull:false)
            ]
        }
    }//body
    @State var users:[UserDataSet] = []
   
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


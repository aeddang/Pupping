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
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewPagerModel:ViewPagerModel = ViewPagerModel()
    
    @State var reloadDegree:Double = 0
    @State var reloadDegreeMax:Double = Double(InfinityScrollModel.PULL_COMPLETED_RANGE)
    
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
                    }
                    .modifier(ContentHorizontalEdges())
                    .padding(.top, self.sceneObserver.safeAreaTop + Dimen.margin.regular)
                }
                .padding(.bottom, self.sceneObserver.safeAreaBottom + Dimen.app.bottom)
            }
            .onReceive(self.infinityScrollModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCompleted :
                    if !self.infinityScrollModel.isLoading {  }
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
        }//geo
        .modifier(PageFull())
        .onAppear{
           
        }
    }//body
    @State var profiles:[Profile]? = nil
    @State var profilePages: [PageViewProtocol] = []
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


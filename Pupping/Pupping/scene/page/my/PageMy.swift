//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PageMy: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    
    var body: some View {
        VStack(spacing: 0){
            MyRewardsInfo()
                .modifier(ContentEdges())
                .padding(.top, self.sceneObserver.safeAreaTop)
                
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                isRecycle:false,
                useTracking:true)
            {
                VStack(alignment: .leading, spacing:0){
                    Text(String.pageTitle.myPats)
                        .modifier(ContentTitle())
                        .modifier(ListRowInset(
                                    marginHorizontal:Dimen.margin.light,
                                    spacing: Dimen.margin.regular))
                    
                    ForEach(self.profiles) { profile in
                        ProfileInfo(profile: profile, axio:.horizontal, isModifyAble:true )
                            .modifier(ListRowInset(
                                        marginHorizontal:Dimen.margin.light,
                                        spacing: Dimen.margin.regular))
                    }
                }
                .padding(.bottom, Dimen.app.bottomTab)
            }
            .padding(.bottom, self.sceneObserver.safeAreaBottom + Dimen.app.bottom)
        }
        .onReceive(self.dataProvider.user.$profiles){ profiles in
            if profiles.isEmpty {
                self.profiles = []
            } else {
                self.profiles = profiles
            }
            self.profiles.append(Profile().empty())
            
        }
        
        .modifier(PageFull())
        .onAppear{
           
        }
    }//body
    @State var profiles:[Profile] = []
   
}


#if DEBUG
struct PageMy_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMy().contentBody
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


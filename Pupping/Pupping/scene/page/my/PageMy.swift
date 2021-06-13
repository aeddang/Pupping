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
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var profileScrollModel:InfinityScrollModel = InfinityScrollModel()
   
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            MyRewardsInfo()
                .modifier(ContentHorizontalEdges())
                .padding(.top, self.appSceneObserver.safeHeaderHeight)
            HStack{
                Text(String.pageTitle.myPats)
                    .modifier(ContentTitle())
                Spacer()
                Button(action: {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.profileRegist)
                    )
        
                }) {
                    Image(Asset.icon.addOn)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regular,
                               height: Dimen.icon.regular)
                }
            }
            .modifier(ContentHorizontalEdges())
            .padding(.top, Dimen.margin.mediumUltra)
            ProfileList(
                viewModel:self.profileScrollModel,
                datas: self.profiles)
                
            Spacer().modifier(MatchParent())
        }
        .padding(.top, self.appSceneObserver.safeHeaderHeight + Dimen.margin.regular)
        //.padding(.bottom, self.bottomMargin)
        .onReceive(self.appSceneObserver.$safeBottomHeight){ height in
            withAnimation{ self.bottomMargin = height }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                self.isUiReady = true
            }
        }
        .onReceive(self.dataProvider.user.$profiles){ profiles in
            if profiles.isEmpty {
                self.profiles = []
            } else {
                self.profiles = profiles
            }
            
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


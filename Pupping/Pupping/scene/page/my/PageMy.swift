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
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var profileScrollModel:InfinityScrollModel = InfinityScrollModel()
   
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            PageTab(
                title: String.pageTitle.my,
                isBack: false,
                isClose: false,
                isSetting: true)
                .padding(.top, self.sceneObserver.safeAreaTop)
            MyRewardsInfo()
                .modifier(ContentHorizontalEdges())
                .padding(.top, Dimen.margin.mediumExtra)
            HStack{
                Text(String.pageTitle.myDogs)
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
                        .frame(width: Dimen.icon.mediumLight,
                               height: Dimen.icon.mediumLight)
                }
            }
            .modifier(ContentHorizontalEdges())
            .padding(.top, Dimen.margin.mediumUltra)
            if !self.profiles.isEmpty {
                ProfileList(
                    viewModel:self.profileScrollModel,
                    datas: self.profiles)
            } else {
                ZStack{
                    Image(Asset.image.profileEmptyContent)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 274, height: 170)
                }
                .modifier(MatchHorizontal(height: 199))
                .background(Color.app.whiteDeepExtra)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
                .modifier(ContentHorizontalEdges())
                
                .padding(.top, Dimen.margin.light)
                
            }
           
                
            Spacer().modifier(MatchParent())
        }
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


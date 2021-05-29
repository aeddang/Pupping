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
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var mapModel:MapModel = MapModel()
    
    var body: some View {
        ZStack(alignment: .topLeading){
            VStack(spacing:0){
                PageTab(
                    isBack:true
                )
                .padding(.top, self.sceneObserver.safeAreaTop)
                CPGoogleMap(viewModel: self.mapModel, pageObservable: self.pageObservable)
            }
            
        }
        .modifier(PageFull())
        .onAppear{
            
        }
    }//body
   
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


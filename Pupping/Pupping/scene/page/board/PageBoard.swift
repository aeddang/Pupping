//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PageBoard: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    var body: some View {
        ZStack(alignment: .topLeading){
            VStack(spacing:0){
                PageTab(
                    isBack:true
                )
                .padding(.top, self.sceneObserver.safeAreaTop)
                ZStack{
                    Text(String.pageTitle.commingSoon)
                        .modifier(ContentTitle())
                }
                .modifier(MatchParent())
            }
            
        }
        .modifier(PageFull())
        .onAppear{
           
        }
    }//body
   
}


#if DEBUG
struct PageBoard_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageBoard().contentBody
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


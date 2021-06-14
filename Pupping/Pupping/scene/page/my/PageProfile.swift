//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PageProfile: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
    @State var profile:Profile? = nil
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack{
                    if let profile = self.profile {
                        ProfileDetail(profile: profile)
                    } else {
                        Spacer()
                    }
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isUiReady = true
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                guard let profile = obj.getParamValue(key: .data) as? Profile else { return }
                self.profile = profile
            }
        }
    }//body
   
}


#if DEBUG
struct PageProfile_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageProfile().contentBody
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


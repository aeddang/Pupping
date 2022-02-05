//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PageUser: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var profileScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var pictureScrollModel:InfinityScrollModel = InfinityScrollModel()
   
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
    @State var user:User? = nil
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack{
                    if let user = self.user {
                        UserDetail(
                            pageObservable: self.pageObservable,
                            pageDragingModel: self.pageDragingModel,
                            infinityScrollModel: self.infinityScrollModel,
                            profileScrollModel: self.profileScrollModel,
                            pictureScrollModel: self.pictureScrollModel,
                            user:user)
                    } else {
                        Spacer()
                    }
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                .onReceive(self.pageDragingModel.$nestedScrollEvent){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCompleted :
                        self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                    case .pullCancel :
                        self.pageDragingModel.uiEvent = .pullCancel(geometry)
                    case .pull(let pos) :
                        self.pageDragingModel.uiEvent = .pull(geometry, pos)
                    default: break
                    }
                }
            }//draging
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isUiReady = true
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                guard let user = obj.getParamValue(key: .data) as? User else { return }
                self.user  = user
            }
        }
    }//body
   
}


#if DEBUG
struct PageUser_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageUser().contentBody
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


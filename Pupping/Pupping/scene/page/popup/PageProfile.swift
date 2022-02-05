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
    
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var pictureScrollModel:InfinityScrollModel = InfinityScrollModel()
   
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
    @State var profile:PetProfile? = nil
    @State var userId:String? = nil
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack{
                    if let profile = self.profile {
                        PetProfileDetail(
                            pageObservable: self.pageObservable,
                            pageDragingModel : self.pageDragingModel,
                            infinityScrollModel: self.infinityScrollModel,
                            pictureScrollModel: self.pictureScrollModel,
                            navigationModel:self.navigationModel,
                            profile: profile,
                            userId: self.userId)
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
                guard let profile = obj.getParamValue(key: .data) as? PetProfile else { return }
                if let userId = obj.getParamValue(key: .id) as? String {
                    self.userId = userId
                }
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


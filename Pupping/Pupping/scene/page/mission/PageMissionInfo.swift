//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PageMissionInfo: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var missionManager:MissionManager
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var mapModel:MapModel = MapModel()
    
    @State var mission:Mission? = nil
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                ZStack(alignment: .topLeading){
                    VStack(spacing:0){
                        PageTab(
                            title: String.pageTitle.missionInfo,
                            isClose:true
                        )
                        .padding(.top, self.sceneObserver.safeAreaTop)
                        VStack(spacing:Dimen.margin.thin){
                            if let mission = self.mission {
                                MissionInfo(data: mission)
                            }
                            ZStack{
                                CPGoogleMap(viewModel: self.mapModel, pageObservable: self.pageObservable)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
                            .modifier(Shadow())
                        }
                        .modifier(ContentHorizontalEdges())
                    }
                    
                    
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
    
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.mission = obj.getParamValue(key: .data) as? Mission
                
            }
        }//geo
    }//body
   
}


#if DEBUG
struct PageMissionInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMissionInfo().contentBody
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

 

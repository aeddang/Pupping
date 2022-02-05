//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps

struct PageMissionCompleted: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var missionManager:MissionManager
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @State var mission:Mission? = nil
    @State var withProfiles:[PetProfile] = []
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                ZStack(alignment: .topLeading){
                    if let mission = self.mission {
                        RedeemInfo(
                            title: String.pageText.missionCompleted,
                            text: String.pageText.missionCompletedText.replace(
                                (mission.playTime/60).toTruncateDecimal(n:1)
                            ),
                            point: mission.lv.point(),
                            action : {
                                self.appSceneObserver.alert = .alert(nil, String.alert.completedNeedPicture){
                                    self.appSceneObserver.event = .openCamera(self.tag)
                                }
                            },
                            close: {
                                self.appSceneObserver.alert = .confirm(nil, String.alert.completedExitConfirm){ isOk in
                                    if isOk {
                                        self.closeMission()
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.all, Dimen.margin.regular)
                .modifier(MatchParent())
                .background(Color.transparent.black70)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            .onAppear{
                self.mission = self.missionManager.currentMission
                guard let obj = self.pageObject  else { return }
                guard let datas = obj.getParamValue(key: .datas) as? [PetProfile] else { return }
                self.withProfiles = datas
                
            }
            .onDisappear{
               
            }
            .onReceive(self.appSceneObserver.$pickImage) { pick in
                guard let pick = pick else {return}
                if pick.id?.hasSuffix(self.tag) != true {return}
                if let img = pick.image {
                    self.pagePresenter.isLoading = true
                    DispatchQueue.global(qos:.background).async {
                        let uiImage = img.normalized().centerCrop().resize(to: CGSize(width: 240,height: 240))
                        DispatchQueue.main.async {
                            self.pagePresenter.isLoading = false
                            self.checkResult(img: uiImage)
                        }
                    }
                } 
            }
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .completeMission : self.onClose()
                case .checkHumanWithDog :
                    guard let data = res.data as? DetectData else {
                        self.appSceneObserver.event = .toast(String.alert.completedNeedPictureError)
                        return
                    }
                    if data.isDetected != true {
                        self.appSceneObserver.event = .toast(String.alert.completedNeedPictureError)
                        return
                    }
                    self.sendResult(imgPath: data.pictureUrl)
                default : break
                }
            }
        }//geo
    }//body
   
    private func checkResult(img:UIImage){
        self.dataProvider.requestData(q: .init(id:self.tag, type: .checkHumanWithDog(img), isLock: true))
        
    }
    private func sendResult(imgPath:String?){
        guard let mission = self.mission else { return }
        mission.pictureUrl = imgPath
        self.dataProvider.requestData(q: .init(id:self.tag, type: .completeMission(mission, self.withProfiles), isLock: true))
        
    }
    private func onClose(){
        if let mission = self.mission {
            self.dataProvider.user.missionCompleted(mission)
        }
        self.closeMission()
        self.appSceneObserver.event = .toast(String.pageText.missionCompletedSaved)
    }
    private func closeMission(){
        
        self.missionManager.completedMission()
        self.missionManager.endMission()
        self.pagePresenter.closeAllPopup()
    }

}


#if DEBUG
struct PageMissionCompleted_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMissionCompleted().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

 

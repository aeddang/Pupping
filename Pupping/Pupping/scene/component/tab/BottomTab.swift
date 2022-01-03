//
//  BottomTab.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/19.
//

import Foundation
import SwiftUI
import Combine

struct PageSelecterble : SelecterbleProtocol{
    let key = UUID().uuidString
    var id:PageID = PageID.home
    var idx:Int = -1
    var on:String = ""
    var off:String = ""
    var text:String = ""
    var isPopup:Bool = false
}

struct BottomTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @State var pages:[PageSelecterble] = []
   
    @State var currentPageIdx:Int? = nil
    var body: some View {
        VStack{
            Spacer().modifier(LineHorizontal()) 
            HStack( alignment: .center, spacing:0 ){
                ForEach(self.pages, id: \.key) { gnb in
                    ImageButton(
                        isSelected:self.checkCategory(pageIdx: gnb.idx),
                        defaultImage: gnb.off,
                        activeImage:gnb.on,
                        text: gnb.text
                    ){ _ in
                        if gnb.isPopup {
                            if self.pagePresenter.hasLayerPopup() {
                                self.appSceneObserver.event = .toast(String.alert.currentPlay)
                                return
                            }
                            if self.dataProvider.user.pets.isEmpty {
                                self.appSceneObserver.alert = .alert(nil, String.alert.needProfileRegist, nil){
                                    self.pagePresenter.openPopup(
                                        PageProvider.getPageObject(.profileRegist)
                                    )
                                }
                                return
                            }
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(gnb.id)
                            )
                        } else {
                            self.pagePresenter.changePage(
                                PageProvider.getPageObject(gnb.id)
                            )
                        }
                    }
                    .modifier(MatchParent())
                }
            }
            .padding(.bottom, self.sceneObserver.safeAreaBottom)
        }
        .modifier(MatchHorizontal(height: self.sceneObserver.safeAreaBottom + Dimen.app.bottom))
        .background(Color.brand.bg)
        .onReceive (self.pagePresenter.$currentTopPage) { page in
            
            self.currentPageIdx = page?.pageIDX
        }
        .onAppear(){
            pages = [
                PageSelecterble(
                    id: .walk,
                    idx: PageProvider.getPageIdx(.walk),
                    on: Asset.gnb.walk, off: Asset.gnb.walk, text: String.gnb.walk,
                    isPopup : true),
                
                PageSelecterble(
                    id: .home,
                    idx: PageProvider.getPageIdx(.home),
                    on: Asset.gnb.mission, off: Asset.gnb.mission, text: String.gnb.mission),
                
                PageSelecterble(
                    id: .explore,
                    idx: PageProvider.getPageIdx(.explore),
                    on: Asset.gnb.explore, off: Asset.gnb.explore, text: String.gnb.explore),
               
                PageSelecterble(
                    id: .my,
                    idx: PageProvider.getPageIdx(.my),
                    on: Asset.gnb.my, off: Asset.gnb.my, text: String.gnb.my)
            ]
        }
    }
    
    func checkCategory(pageIdx:Int) -> Bool {
        guard let currentIdx = self.currentPageIdx else { return false }
        let idx = floor( Double(pageIdx) / 100.0 )
        let cidx = floor( Double(currentIdx) / 100.0 )
        return idx == cidx
    }
}

#if DEBUG
struct ComponentBottomTab_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            BottomTab()
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width:370,height:200)
        }
    }
}
#endif

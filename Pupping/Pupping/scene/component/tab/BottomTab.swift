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
}

struct BottomTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @State var pages:[PageSelecterble] = []
   
    @State var currentPageIdx:Int? = nil
    var body: some View {
        ZStack{
            HStack( alignment: .center, spacing:0 ){
                ForEach(self.pages, id: \.key) { gnb in
                    ImageButton(
                        isSelected:self.checkCategory(pageIdx: gnb.idx),
                        defaultImage: gnb.off,
                        activeImage:gnb.on,
                        text: gnb.text
                    ){ _ in
                        self.pagePresenter.changePage(
                            PageProvider
                                .getPageObject(gnb.id)
                        )
                    }
                    .modifier(MatchParent())
                }
            }
            .padding(.bottom, self.sceneObserver.safeAreaBottom)
        }
        .modifier(MatchHorizontal(height: self.sceneObserver.safeAreaBottom + Dimen.app.bottom))
        .background(Color.brand.bg)
        .onReceive (self.pagePresenter.$currentPage) { page in
            self.currentPageIdx = page?.pageIDX
        }
        .onAppear(){
            pages = [
                PageSelecterble(
                    id: .home,
                    idx: PageProvider.getPageIdx(.home),
                    on: Asset.gnb.mission, off: Asset.gnb.mission, text: String.gnb.mission),
                PageSelecterble(
                    id: .board,
                    idx: PageProvider.getPageIdx(.board),
                    on: Asset.gnb.board, off: Asset.gnb.board, text: String.gnb.board),
                PageSelecterble(
                    id: .shop,
                    idx: PageProvider.getPageIdx(.shop),
                    on: Asset.gnb.shop, off: Asset.gnb.shop, text: String.gnb.shop),
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

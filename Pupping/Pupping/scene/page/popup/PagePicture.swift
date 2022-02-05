//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PagePicture: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var viewPagerModel:PictureViewPagerModel = PictureViewPagerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(){
                    PictureViewPager(
                        viewModel: self.viewPagerModel
                    ){idx in
                        withAnimation{
                            self.isShowUi.toggle()
                        }
                    }
                    VStack(spacing:0){
                        HStack{
                            Button(action: {
                                self.pagePresenter.closePopup(self.pageObject?.id)
                    
                            }) {
                                Image(Asset.icon.back)
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Dimen.icon.regularExtra,
                                           height: Dimen.icon.regularExtra)
                            }
                            Spacer()
                            FavoriteButton(
                                isFavorite:self.isLike ?? false,
                                value: self.likeValue
                            )
                            {
                                guard let data = self.currentData else {return}
                                self.dataProvider.requestData(
                                    q: .init( type: .updateAlbumPictures(pictureId: data.pictureId, isLike: !data.isLike)))
                            }
                            if self.isMine {
                                Button(action: {
                                    self.appSceneObserver.alert =
                                        .confirm(nil,  String.alert.deleteProfile){ isOk in
                                            if !isOk {return}
                                            guard let data = self.currentData else {return}
                                            self.dataProvider.requestData(
                                                q: .init(type: .deleteAlbumPictures(ids: data.pictureId.description), isLock: true))
                                    }
                        
                                }) {
                                    Image(Asset.icon.trash)
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Dimen.icon.regularExtra,
                                               height: Dimen.icon.regularExtra)
                                }
                            }
                        }
                        .padding(.all, Dimen.margin.thin)
                        .padding(.top, self.sceneObserver.safeAreaTop)
                        .background(Color.transparent.black70)
                        Spacer()
                    }
                    .opacity(self.isShowUi ? 1 : 0)
                }
                .modifier(MatchParent())
                .background(Color.app.black)
                .clipped()
                .modifier(PageDragingSecondPriority(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            
            .onTapGesture {
                withAnimation{
                    self.isShowUi.toggle()
                }
            }
            .onReceive(self.viewPagerModel.$index){idx in
                if idx >= self.viewPagerModel.datas.count {
                    self.currentData = nil
                    self.likeValue =  nil
                    self.isLike = nil
                } else {
                    self.currentData = self.viewPagerModel.datas[idx]
                    self.likeValue = self.currentData?.likeValue.description.toThousandUnit(f: 0)
                    self.isLike = self.currentData?.isLike
                }
            }
            /*
            .onReceive(self.viewPagerModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCompleted:
                    self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                case .pullCancel :
                    self.pageDragingModel.uiEvent = .pullCancel(geometry)
                case .pull(let pos) :
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                }
            }*/
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    guard let obj = self.pageObject  else { return }
                    if let idx = obj.getParamValue(key: .idx) as? Int {
                        self.viewPagerModel.request = .jump(idx)
                    }
                }
            }
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                switch res.type {
                case .deleteAlbumPictures(let ids) :
                    if ids == self.currentData?.pictureId.description {
                        self.onDeleted()
                    }
                case .updateAlbumPictures(let pictureId, let isLike): self.updated(pictureId, isLike: isLike)
                default : break
                }
            }
            
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let datas = obj.getParamValue(key: .datas) as? [Picture] {
                    self.viewPagerModel.addPictures(datas)
                }
                if let datas = obj.getParamValue(key: .datas) as? [PictureDataSet] {
                    var pictures:[Picture] = []
                    datas.forEach{
                        pictures.append(contentsOf: $0.datas)
                    }
                    self.viewPagerModel.addPictures(pictures)
                }
                if let id = obj.getParamValue(key: .id) as? String {
                    self.userId = id
                }
                if let id = obj.getParamValue(key: .subId) as? String {
                    self.petId = id
                }
                self.isMine = self.userId == self.dataProvider.user.snsUser?.snsID
            }
            
            .onDisappear{
               
            }
        }//geo
    }//body
    @State var isShowUi:Bool = true
    @State var userId:String? = nil
    @State var petId:String? = nil
    @State var isMine:Bool = false
    @State var currentData:Picture? = nil
    @State var isLike:Bool? = nil
    @State var likeValue:String? = nil
    
    private func onDeleted(){
        guard let data = self.currentData else {return}
        let num = self.viewPagerModel.deletePicture(data)
        if num == 0 {
            self.pagePresenter.closePopup(self.pageObject?.id)
            return
        }
        if num <= self.viewPagerModel.index {
            self.viewPagerModel.request = .move(num-1)
        }
    }
    private func updated(_ id:Int, isLike:Bool){
        guard let data = self.currentData else { return }
        if data.pictureId == id {
            data.updata(isLike: isLike)
            self.likeValue = data.likeValue.description.toThousandUnit(f: 0)
            self.isLike = data.isLike
        }
    }
}

#if DEBUG
struct PageMyPurchase_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePicture().contentBody
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                
                .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif

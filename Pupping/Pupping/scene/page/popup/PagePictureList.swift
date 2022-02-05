//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PagePictureList: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
   
    
    @State var reloadDegree:Double = 0
    @State var reloadDegreeMax:Double = Double(InfinityScrollModel.PULL_COMPLETED_RANGE)
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(alignment: .leading, spacing:0){
                    PageTab(
                        title: self.title ?? String.pageTitle.album,
                        isBack: true,
                        isClose: false,
                        isSetting: false)
                        .padding(.top, self.sceneObserver.safeAreaTop)
                    
                    ZStack(alignment: .top){
                        ReflashSpinner(
                            progress: self.$reloadDegree)
                            .padding(.top, Dimen.margin.regular)
                        if let dataSets = self.dataSets {
                            if dataSets.isEmpty {
                                EmptyInfo()
                            } else {
                                PictureListItemSet(
                                    viewModel: self.infinityScrollModel,
                                    datas: dataSets,
                                    action: { data in
                                        self.selectPicture(data)
                                    }, onBottom: {
                                        self.load()
                                    })
                            }
                        } else {
                            Spacer().modifier(MatchParent())
                        }
                    }
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.infinityScrollModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCompleted :
                    if !self.infinityScrollModel.isLoading {
                        self.reload()
                    }
                    withAnimation{ self.reloadDegree = 0 }
                case .pullCancel :
                    withAnimation{ self.reloadDegree = 0 }
                default : break
                }
                
            }
            .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                if pos < InfinityScrollModel.PULL_RANGE { return }
                self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isUiReady = true
                    
                    self.load()
                }
            }
            .onReceive(self.appSceneObserver.$pickImage) { pick in
                guard let pick = pick else {return}
                if pick.id?.hasSuffix(self.key) != true {return}
                if let img = pick.image {
                    self.pagePresenter.isLoading = true
                    DispatchQueue.global(qos:.background).async {
                        let scale:CGFloat = 1//UIScreen.main.scale
                        let size = CGSize(
                            width: PictureList.pictureWidth * scale,
                            height: PictureList.pictureHeight * scale)
                        let image = img.normalized().crop(to: size).resize(to: size)
                        
                        let sizeList = CGSize(
                            width: PictureList.width * scale,
                            height: PictureList.height * scale)
                        let thumbImage = img.normalized().crop(to: sizeList).resize(to: size)
                        DispatchQueue.main.async {
                            self.pagePresenter.isLoading = false
                            self.dataProvider.requestData(
                                q: .init(type: .registAlbumPicture(img: image, thumbImg: thumbImage, id: self.ownerId, self.type)))
                        }
                    }
                } else {
                    //self.profile.update(image: nil)
                }
            }
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                
                switch res.type {
                case .getAlbumPictures: self.loaded(res)
                case .registAlbumPicture(_, _, _, let type) : if type == .user {self.addedPicture(res)}
                case .deleteAlbumPictures(let ids) : self.deletedPicture(res, ids: ids)
                default : break
                }
            }
            .onReceive(self.sceneObserver.$screenSize){ size in
                if !self.isUiReady {return}
                if self.screenWidth != size.width {
                    self.screenWidth = size.width
                    self.onDataSet()
                }
            }
            .onAppear{
                self.screenWidth = self.sceneObserver.screenSize.width
                guard let obj = self.pageObject  else { return }
                let id = obj.getParamValue(key: .id) as? String
                let subId = obj.getParamValue(key: .subId) as? String
                let type = obj.getParamValue(key: .type) as? AlbumApi.Category
                if let nick = obj.getParamValue(key: .text) as? String {
                    self.title = nick + String.app.owner + " " + String.pageTitle.album
                }
                self.ownerId = id ?? ""
                self.isMine = type == .user
                    ? self.dataProvider.user.snsUser?.snsID == self.ownerId
                    : self.dataProvider.user.snsUser?.snsID == subId
                self.type = type ?? .user
                if isMine {self.datas.append(Picture().setEmpty())}
            }
        }
    }//body
    @State var key = UUID().uuidString
    @State var datas:[Picture] = []
    @State var dataSets:[PictureDataSet]? = nil
    @State var isError:Bool? = nil
    @State var ownerId:String = ""
    @State var title:String? = nil
    @State var isMine:Bool = false
    @State var type:AlbumApi.Category = .user
    @State var screenWidth:CGFloat = 0
    func reload(){
        self.isError = nil
        self.datas = []
        self.dataSets = nil
        if isMine {self.datas.append(Picture().setEmpty())}
        self.infinityScrollModel.reload()
        self.load()
    }

    func load(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        self.dataProvider.requestData(
            q: .init(
                id: self.key,
                type: .getAlbumPictures(id: self.ownerId, self.type, page: self.infinityScrollModel.page)))
    }
    
    private func loaded(_ res:ApiResultResponds){
        if !res.id.hasPrefix(self.key) {return}
        guard let datas = res.data as? [PictureData] else { return }
        var added:[Picture] = []
        if !datas.isEmpty {
            let start = self.datas.count
            let end = start + datas.count
            added = zip(start...end, datas).map { idx, d in
                return Picture().setData(d, index:idx)
            }
        }
        self.datas.append(contentsOf: added)
        self.onDataSet()
        self.infinityScrollModel.onComplete(itemCount: added.count)
        
    }
    private func selectPicture(_ data:Picture){
        if data.isEmpty {
            self.appSceneObserver.select = .imgPicker(SceneRequest.imagePicker.rawValue + self.key)
        } else {
            var idx = self.datas.firstIndex(of:data) ?? 0
            if self.isMine {idx = max(idx-1, 0)}
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.picture)
                    .addParam(key: .datas, value: self.datas.filter{!$0.isEmpty})
                    .addParam(key: .id, value: self.ownerId)
                    .addParam(key: .idx, value: idx )
            )
        }
    }
    private func addedPicture(_ res:ApiResultResponds){
        guard let data = res.data as? PictureData else { return }
        if data.ownerId != self.ownerId { return }
        self.datas.insert(Picture().setData(data), at: self.isMine ? 1 : 0)
        self.onDataSet()
    }
    private func deletedPicture(_ res:ApiResultResponds, ids:String){
        let idA = ids.split(separator: ",")
        let newDatas = self.datas.filter{ pic in
            return idA.first(where: {$0 == pic.pictureId.description }) == nil
        }
        if newDatas.count == self.datas.count {return}
        self.datas = newDatas
        self.onDataSet()
    }
    
    private func onDataSet(){
        let count:Int = Int(floor(self.screenWidth / PictureList.width))
        var rows:[PictureDataSet] = []
        var cells:[Picture] = []
        var total = self.datas.count
        self.datas.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    PictureDataSet( count: count, datas: cells, isFull: true, index:total)
                )
                total += 1
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(
                PictureDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        self.dataSets = rows
    }
}


#if DEBUG
struct PagePictureList_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePictureList().contentBody
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


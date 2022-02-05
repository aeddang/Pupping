//
//  PetList.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/13.
//

import Foundation
import SwiftUI

class Picture : InfinityData, ObservableObject {
    private(set) var imagePath:String? = nil
    private(set) var originImagePath:String? = nil
    private(set) var pictureId:Int = 0
    private(set) var ownerId:String = ""
    @Published fileprivate(set) var image:UIImage? = nil
    @Published private(set) var isLike:Bool = false
    @Published private(set) var likeValue:Double = 0
    
    private(set) var isEmpty:Bool = false
    
    @discardableResult
    func setEmpty(index:Int = 0) -> Picture{
        self.isEmpty = true
        return self
    }
    
    @discardableResult
    func setDummy(index:Int = 0) -> Picture{
        self.index = index
        return self
    }
    
    @discardableResult
    func setData(_ data:PictureData, index:Int = 0) -> Picture{
        self.index = index
        self.imagePath = data.smallPictureUrl
        self.originImagePath = data.pictureUrl
        self.pictureId = data.pictureId ?? 0
        self.ownerId = data.ownerId ?? ""
        self.likeValue = data.thumbsupCount ?? 0
        self.isLike = data.isChecked ?? false
        return self
    }
    
    @discardableResult
    func updata(isLike:Bool) -> Picture{
        if isLike != self.isLike {
            self.likeValue = isLike ? self.likeValue+1 : self.likeValue-1
            self.isLike = isLike
        }
        return self
    }
}

extension PictureList{
    static let width:CGFloat = 162
    static let height:CGFloat = 198
    
    static let pictureWidth:CGFloat = Self.width * 2
    static let pictureHeight:CGFloat = Self.height * 2
    
}
struct PictureList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[Picture]
    var action: ((_ data:Picture) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginHorizontal: Dimen.margin.light,
            spacing: Dimen.margin.light,
            isRecycle: true,
            useTracking: true
        ){
            ForEach(self.datas) { data in
                PictureListItem(data: data )
                    .frame(width: Self.width, height: Self.height)
                    .onTapGesture {
                        action?(data)
                    }
                    
            }
        }
        .modifier(
            ContentScrollPull(
                infinityScrollModel: self.viewModel,
                pageDragingModel: self.pageDragingModel)
        )
    }//body
}

struct PictureListItemSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[PictureDataSet]
    var action: ((_ data:Picture) -> Void)? = nil
    var onBottom: (() -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginVertical: Dimen.margin.light,
            spacing: Dimen.margin.light,
            isRecycle: true,
            useTracking: true
        ){
            ForEach(self.datas) { data in
                PictureSet(data: data ){ pic in
                    action?(pic)
                }
                .onAppear{
                    if data.index == self.datas.last?.index {
                        self.onBottom?() 
                    }
                }
            }
        }
    }//body
}

struct PictureDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 2
    var datas:[Picture] = []
    var isFull = false
    var index:Int = -1
}

struct PictureSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    
    var data:PictureDataSet
    var horizontalMargin:CGFloat = Dimen.margin.light
    var action: ((_ data:Picture) -> Void)? = nil
    @State var height:CGFloat = PictureList.height
    var body: some View {
        HStack( spacing: Dimen.margin.thin){
            ForEach(self.data.datas) { data in
                PictureListItem( data:data )
                    .modifier(MatchHorizontal(height: self.height))
                    .onTapGesture {
                        self.action?(data)
                    }
            }
            if !self.data.isFull && self.data.count > 1 {
                ForEach(0..<(self.data.count - self.data.datas.count)) { _ in
                    Spacer()
                        .modifier(MatchHorizontal(height: self.height))
                }
            }
        }
        .padding(.horizontal, self.horizontalMargin)
        .onAppear {
            let num = CGFloat(self.data.count)
            let lineWidth = self.sceneObserver.screenSize.width
            - (horizontalMargin * 2)
            - (Dimen.margin.thin * (num-1))
            let ratio = PictureList.height/PictureList.width
            self.height = round( lineWidth / num * ratio)
        }
    }//body
}


struct PictureListItem: PageView {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var data:Picture
    
    @State var imagePath:String? = nil
    @State var image:UIImage? = nil
    @State var isLike:Bool? = nil
    @State var likeValue:String? = nil
    
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            if self.data.isEmpty {
                Image( uiImage: UIImage( named: Asset.image.pictureEmpty)! )
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .modifier(MatchParent())
            } else {
                if let img = self.image {
                    Image(uiImage: img)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                } else if let path = self.imagePath {
                    ImageView(url: path,
                        contentMode: .fill,
                        noImg: Asset.brand.logoLauncher)
                        .modifier(MatchParent())
                } else {
                    Image( uiImage: UIImage( named: Asset.brand.logoLauncher)! )
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                }
                FavoriteButton(
                    isFavorite:self.isLike ?? false,
                    value: self.likeValue
                )
                {
                    self.dataProvider.requestData(
                        q: .init( type: .updateAlbumPictures(pictureId: self.data.pictureId, isLike: !self.data.isLike)))
                }
                .padding(.all, Dimen.margin.thin)
            }
            
        }
        .modifier(MatchParent())
        .background(Color.app.white)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
        
       
        .onReceive(self.data.$image) { img in
            self.image = img
            self.imagePath = self.data.imagePath
        }
        .onReceive(self.data.$isLike) { isLike in
            self.isLike = isLike
        }
        .onReceive(self.data.$likeValue) { value in
            self.likeValue = value.description.toThousandUnit(f: 0)
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .updateAlbumPictures(let pictureId, let isLike): self.updated(pictureId, isLike: isLike)
            default : break
            }
        }
        .onAppear(){
            self.imagePath = self.data.imagePath
        }
    }
    
    private func updated(_ id:Int, isLike:Bool){
        if self.data.pictureId == id {
            self.data.updata(isLike: isLike)
        }
    }
    
}


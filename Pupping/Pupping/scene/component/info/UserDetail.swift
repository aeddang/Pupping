//
//  ProfileDetail.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/14.
//

import Foundation
import SwiftUI

struct UserDetail: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var profileScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var pictureScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    var user:User
    
    @State var image:UIImage? = nil
    @State var imagePath:String? = nil
    
    @State var isUiReady:Bool = false
    @State var profileHeight:CGFloat = 0
    @State var profileScale:CGFloat = 1.0
    @State var bottomMargin:CGFloat = 0
    @State var scrollTop:CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top){
            ZStack{
                ZStack{
                    if let img = self.image {
                        Image(uiImage: img)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .modifier(MatchParent())
                    } else if let path = self.imagePath {
                        ImageView(
                            imageLoader: self.imageLoader,
                            url: path,
                            contentMode: .fill,
                            noImg: Asset.brand.logoLauncher)
                            .modifier(MatchParent())
                    } else {
                        Image( uiImage: UIImage(named: Asset.brand.logoLauncher)! )
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .modifier(MatchParent())
                    }
                }
                .modifier(MatchHorizontal(height: self.profileHeight * self.profileScale))
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCancel :
                        withAnimation{ self.profileScale = 1 }
                    case .down :
                        withAnimation(.easeOut(duration: 0.2)){
                            self.scrollTop = self.profileHeight - Dimen.margin.heavy - self.sceneObserver.safeAreaTop
                        }
                    default : break
                    }
                    
                }
                .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                    if self.scrollTop != 0 {
                        withAnimation(.easeOut(duration: 0.2)){ self.scrollTop = 0 }
                    }
                    self.profileScale = 1.0 + (pos*0.01)
                }
            }
            .modifier(MatchHorizontal(height: self.profileHeight))
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                scrollType : .reload(isDragEnd: false),
                showIndicators: false,
                isRecycle:false,
                useTracking:true)
            {
                VStack(alignment: .leading, spacing: Dimen.margin.regular){
                    VStack(alignment: .leading, spacing: Dimen.margin.tiny){
                        Text(self.user.currentProfile.nickName ?? "")
                             .modifier(BoldTextStyle(
                                 size: Font.size.boldExtra,
                                 color: Color.app.greyDeep
                             ))
                             .padding(.top ,Dimen.margin.regular)
                        HStack(spacing:Dimen.margin.tiny){
                            if let type = self.user.currentProfile.type {
                                Image(uiImage: UIImage(named: type.logo)!)
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                            }
                            if let email = self.user.currentProfile.email {
                                Text(email)
                                    .modifier(MediumTextStyle(
                                        size: Font.size.thin,
                                        color: Color.app.grey
                                    ))
                            }
                        }
                    }
                    .padding(.horizontal ,Dimen.margin.regular)
                    if !self.user.pets.isEmpty {
                        PetList(
                            pageDragingModel: self.pageDragingModel,
                            viewModel:self.profileScrollModel,
                            datas: self.user.pets,
                            userId: self.user.snsUser?.snsID
                        )
                        .modifier(MatchHorizontal(height: PetList.height))
                    }
                    if !self.pictures.isEmpty {
                        TitleTab(
                            title: String.pageTitle.album,
                            type: .more){
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.pictureList)
                                        .addParam(key: .id, value: self.user.snsUser?.snsID)
                                        .addParam(key: .text, value: self.user.currentProfile.nickName)
                                        .addParam(key: .type, value: AlbumApi.Category.user)
                                )
                            }
                            .modifier(ContentHorizontalEdges())
                        PictureList(
                            pageDragingModel: self.pageDragingModel,
                            viewModel: self.pictureScrollModel,
                            datas: self.pictures){ data in
                                self.selectPicture(data)
                            }
                            .modifier(MatchHorizontal(height: PictureList.height))
                    } else {
                        Spacer().modifier(MatchParent())
                    }
                }
                .padding(.bottom,self.bottomMargin)
            }
            .modifier(BottomFunctionTab(margin:0))
            .padding(.top, self.profileHeight - Dimen.margin.mediumExtra)
            .modifier(MatchParent())
            LinearGradient(
                gradient:Gradient(colors: [Color.app.black.opacity(0.7), Color.app.black.opacity(0)]),
                startPoint: .top, endPoint: .bottom)
            .modifier(MatchHorizontal(height:  70 + self.sceneObserver.safeAreaTop ))
            HStack{
                Button(action: {
                    self.pagePresenter.goBack()
        
                }) {
                    Image(Asset.icon.back)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regularExtra,
                               height: Dimen.icon.regularExtra)
                }
                Spacer()
               
            }
            .modifier(ContentHorizontalEdges())
            .padding(.top, self.sceneObserver.safeAreaTop + Dimen.margin.regular)
        }
        .modifier(MatchParent())
        .onReceive(self.appSceneObserver.$safeBottomHeight){ height in
            withAnimation{ self.bottomMargin = height }
        }
        .onReceive(self.user.currentProfile.$image) { img in
            self.setupImage(img)
        }
        .onReceive(self.imageLoader.$event){ evt in
            switch evt {
            case .complete(let img): self.setupImage(img)
            default: break
            }
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .getAlbumPictures: self.loaded(res)
            default : break
            }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                self.isUiReady = true
                if let snsUserID = self.user.snsUser?.snsID {
                     self.dataProvider.requestData(q: .init(id:self.key, type: .getAlbumPictures(id: snsUserID, .user), isOptional: true))
                }
            }
        }
        .onAppear(){
            
            if let img = self.user.currentProfile.image {
                self.setupImage(img)
            } else {
                self.imagePath = self.user.currentProfile.imagePath
            }
        }
        
    }
    @State var key = UUID().uuidString
    @State var pictures:[Picture] = []
    private func loaded(_ res:ApiResultResponds){
        if !res.id.hasPrefix(self.key) {return}
        guard let datas = res.data as? [PictureData] else { return }
        var added:[Picture] = []
        if !datas.isEmpty {
            let start = self.pictures.count
            let end = start + datas.count
            added = zip(start...end, datas).map { idx, d in
                return Picture().setData(d, index:idx)
            }
        }
        self.pictures.append(contentsOf: added)
        self.pictureScrollModel.onComplete(itemCount: added.count)
    }
    
    private func selectPicture(_ data:Picture){
        let idx = self.pictures.firstIndex(of:data) ?? 0
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.picture)
                .addParam(key: .datas, value: self.pictures)
                .addParam(key: .id, value: self.user.snsUser?.snsID)
                .addParam(key: .idx, value: idx )
        )
    }
    
    private func setupImage(_ img:UIImage?){
        self.image = img
        guard let imageSize = img?.size else {
            self.profileHeight = 300
            return
        }
        self.profileHeight = min(300, floor(self.sceneObserver.screenSize.width * imageSize.height / imageSize.width))
    }
    
}


#if DEBUG
struct UserDetail_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            UserDetail(
                user: User().setDummy()
            )
            .environmentObject(Repository())
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            .environmentObject(DataProvider())
            .frame(width: 375, height: 640)
        }
    }
}
#endif

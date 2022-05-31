//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PageMy: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var profileScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var pictureScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            PageTab(
                title: String.pageTitle.my,
                isBack: false,
                isClose: false,
                isSetting: false)
                .padding(.top, self.sceneObserver.safeAreaTop)
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                scrollType : .vertical(isDragEnd: false),
                isRecycle:false,
                useTracking:false)
            {
                UserProfileInfo(
                    profile: self.dataProvider.user.currentProfile,
                    isModifyAble: true
                )
                .modifier(ContentHorizontalEdges())
                .padding(.top, Dimen.margin.medium)
                TitleTab(
                    title: String.pageTitle.myDogs,
                    type: .add){
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.profileRegist)
                        )
                    }
                    .modifier(ContentHorizontalEdges())
                    .padding(.top, Dimen.margin.medium)
                if !self.profiles.isEmpty {
                    PetList(
                        viewModel:self.profileScrollModel,
                        datas: self.profiles,
                        userId: self.dataProvider.user.snsUser?.snsID
                    )
                    .modifier(MatchHorizontal(height: PetList.height))
                    .padding(.top, Dimen.margin.thin)
                } else {
                    VStack(spacing:0){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        HStack(alignment: .center, spacing: Dimen.margin.thin){
                            Image(Asset.image.emtpyDogProfileCard)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120)
                            Text(String.pageText.profileRegistGuide)
                                 .modifier(MediumTextStyle(
                                     size: Font.size.thin,
                                     color: Color.app.grey
                                 ))
                        }
                    }
                    .frame(height: PetList.height)
                    .padding(Dimen.margin.thin)
                    .background(Color.app.whiteDeepExtra)
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
                    .modifier(ContentHorizontalEdges())
                    .padding(.top, Dimen.margin.light)
                    
                }
                TitleTab(
                    title: String.pageTitle.album,
                    type: self.pictures.count > 1  ? .more : .none){
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.pictureList)
                                .addParam(key: .id, value: self.userId)
                                .addParam(key: .type, value: AlbumApi.Category.user)
                        )
                    }
                    .modifier(ContentHorizontalEdges())
                    .padding(.top, Dimen.margin.medium)
                if !self.pictures.isEmpty {
                    PictureList(
                        viewModel: self.pictureScrollModel,
                        datas: self.pictures){ data in
                            self.selectPicture(data)
                        }
                        .modifier(MatchHorizontal(height: PictureList.height))
                        .padding(.top, Dimen.margin.light)
                        .padding(.bottom, Dimen.margin.regular)
                } else {
                    Spacer().modifier(MatchParent())
                }
            }
        }
        .padding(.bottom, self.bottomMargin)
        .modifier(PageFull())
        .onReceive(self.appSceneObserver.$safeBottomHeight){ height in
            if !self.isUiReady {return}
            withAnimation{ self.bottomMargin = height }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                self.isUiReady = true
                if let snsUser = self.dataProvider.user.snsUser {
                    self.userId = snsUser.snsID
                    self.dataProvider.requestData(q: .init(type: .getUser(snsUser)))
                    self.dataProvider.requestData(q: .init(type: .getPets(snsUser), isOptional: true))
                    self.dataProvider.requestData(q: .init(id:self.tag, type: .getAlbumPictures(id: self.userId, .user), isOptional: true))
                    
                    self.pictures.append(Picture().setEmpty())
                }
            }
        }
        .onReceive(self.appSceneObserver.$pickImage) { pick in
            guard let pick = pick else {return}
            if pick.id?.hasSuffix(self.tag) != true {return}
            if let img = pick.image {
                self.pagePresenter.isLoading = true
                DispatchQueue.global(qos:.background).async {
                    let scale:CGFloat = 1 //UIScreen.main.scale
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
                            q: .init(type: .registAlbumPicture(img:image, thumbImg:thumbImage, id: self.userId, .user)))
                    }
                }
            } else {
                //self.profile.update(image: nil)
            }
        }
        .onReceive(self.dataProvider.user.$pets){ profiles in
            if !self.isUiReady {return}
            if profiles.isEmpty {
                self.profiles = []
            } else {
                self.profiles = profiles
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
        .onAppear{
            self.bottomMargin = self.appSceneObserver.safeBottomHeight
            
        }
    }//body
    
    @State var userId:String = ""
    @State var profiles:[PetProfile] = []
    @State var pictures:[Picture] = []
    
    private func loaded(_ res:ApiResultResponds){
        if !res.id.hasPrefix(self.tag) {return}
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
        if data.isEmpty {
            self.appSceneObserver.select = .imgPicker(SceneRequest.imagePicker.rawValue + self.tag)
        } else {
            let idx = self.pictures.firstIndex(of:data) ?? 0
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.picture)
                    .addParam(key: .datas, value: self.pictures.filter{!$0.isEmpty})
                    .addParam(key: .id, value: self.userId)
                    .addParam(key: .idx, value: max(idx-1, 0) )
            )
        }
    }
    
    private func addedPicture(_ res:ApiResultResponds){
        guard let data = res.data as? PictureData else { return }
        if data.ownerId != self.userId { return }
        self.pictures.insert(Picture().setData(data), at: 1)
    }
    private func deletedPicture(_ res:ApiResultResponds, ids:String){
        let idA = ids.split(separator: ",")
        self.pictures = self.pictures.filter{ pic in
            return idA.first(where: {$0 == pic.pictureId.description }) == nil
        }
    }
}


#if DEBUG
struct PageMy_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMy().contentBody
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


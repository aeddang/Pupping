//
//  ProfileDetail.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/14.
//

import Foundation
import SwiftUI

struct PetProfileDetail: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var pictureScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @ObservedObject var profile:PetProfile
    var userId:String? = nil
    
    @State var image:UIImage? = nil
    @State var imagePath:String? = nil 
    @State var name:String? = nil
    @State var age:String? = nil
    @State var species:String? = nil
    @State var microfin:String? = nil
    @State var gender:Gender? = nil
    
    
   
    @State var profileHeight:CGFloat = 300
    @State var profileScale:CGFloat = 1.0
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
    @State var selectedMenu:Int = 0
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
                VStack(alignment: .leading, spacing: Dimen.margin.medium){
                    VStack(alignment: .leading, spacing: Dimen.margin.tiny){
                        HStack{
                            VStack(alignment: .leading, spacing: 0){
                                Spacer().modifier(MatchHorizontal(height: 0))
                                Text(self.name ?? "")
                                     .modifier(BoldTextStyle(
                                         size: Font.size.boldExtra,
                                         color: Color.app.greyDeep
                                     ))
                                
                                PetProfileInfoDescription(
                                    profile: self.profile,
                                    age: self.age,
                                    species: self.species,
                                    gender: self.gender,
                                    isModifyAble: false)
                                    .padding(.top, Dimen.margin.tiny)
                                
                            }
                            LvInfo(profile: self.profile)
                                .frame(width: 120)
                        }
                        
                        if self.profile.isMypet, let microfin = self.microfin{
                            Text(microfin)
                                 .modifier(BoldTextStyle(
                                     size: Font.size.tinyExtra,
                                     color:Color.app.greyLight
                                 ))
                                .padding(.all, Dimen.margin.tiny)
                                .background(Color.app.whiteDeep)
                                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
                        }
                        
                            
                    }
                    .modifier(ContentHorizontalEdges())
                    Spacer().modifier(LineHorizontal())
                        .modifier(ContentHorizontalEdges())
                    MenuTab(
                        pageObservable:self.pageObservable,
                        viewModel:self.navigationModel,
                        buttons: [
                            String.pageText.profileAbout, String.pageText.profileHistory
                        ],
                        selectedIdx: self.selectedMenu
                    )
                    .padding(.horizontal,Dimen.margin.thin)
                    .modifier(ContentHorizontalEdges())
                    .onReceive(self.navigationModel.$index){ idx in
                        withAnimation{ self.selectedMenu = idx }
                    }
                    if self.selectedMenu == 0 {
                        PetAbout(
                            profile: self.profile,
                            userId: self.userId
                        )
                        .modifier(ContentHorizontalEdges())
                        VStack(spacing: Dimen.margin.thin){
                            if !self.pictures.isEmpty {
                                TitleTab(
                                    title: String.pageTitle.album,
                                    type: .more){
                                        self.pagePresenter.openPopup(
                                            PageProvider.getPageObject(.pictureList)
                                                .addParam(key: .id, value: self.profile.petId.description)
                                                .addParam(key: .subId, value: self.userId)
                                                .addParam(key: .text, value: self.profile.nickName)
                                                .addParam(key: .type, value: AlbumApi.Category.pet)
                                        )
                                    }
                                    .modifier(ContentHorizontalEdges())
                                PictureList(
                                    pageDragingModel: self.pageDragingModel,
                                    viewModel: self.pictureScrollModel,
                                    datas: self.pictures){ data in
                                        self.selectPicture(data)
                                    }
                            }
                        }
                        
                    } else if self.selectedMenu == 1 {
                        PetHistory(
                            profile: self.profile,
                            userId: self.userId
                        )
                        .modifier(ContentHorizontalEdges())
                    } else {
                        PetAlbum(
                            profile: self.profile,
                            userId: self.userId
                        )
                        .modifier(ContentHorizontalEdges())
                    }
                    
                }
                .padding(.top, Dimen.margin.regular)
                .padding(.bottom,self.bottomMargin)
            }
            .modifier(BottomFunctionTab(margin:0))
            .padding(.top, self.profileHeight - self.scrollTop)
            .modifier(MatchParent())
            
            LinearGradient(
                gradient:Gradient(colors: [Color.app.black.opacity(0.7), Color.app.black.opacity(0)]),
                startPoint: .top, endPoint: .bottom)
            .modifier(MatchHorizontal(height:  70 + self.sceneObserver.safeAreaTop ))
            
            HStack(spacing:Dimen.margin.tiny){
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
                if self.profile.isMypet {
                    Button(action: {
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.profileModify)
                                .addParam(key: .data, value: self.profile)
                        )
            
                    }) {
                        Image(Asset.icon.modify)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.regularExtra,
                                   height: Dimen.icon.regularExtra)
                    }
                    Button(action: {
                        self.appSceneObserver.alert =
                            .confirm(nil,  String.alert.deleteProfile){ isOk in
                                if !isOk {return}
                                self.dataProvider.requestData(
                                    q: .init(type: .deletePet(petId: self.profile.petId)))
                                self.pagePresenter.goBack()
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
            .modifier(ContentHorizontalEdges())
            .padding(.top, self.sceneObserver.safeAreaTop + Dimen.margin.regular) 
        }
        .modifier(MatchParent())
        .onReceive(self.appSceneObserver.$safeBottomHeight){ height in
            withAnimation{ self.bottomMargin = height }
        }
        
        .onReceive(self.profile.$birth) { birth in
            guard let birth = birth else {
                self.age = nil
                return
            }
            let now = Date()
            let yy = now.toDateFormatter(dateFormat:"yyyy")
            let birthYY = birth.toDateFormatter(dateFormat:"yyyy")
            self.age = (yy.toInt() - birthYY.toInt() + 1).description + "yrs"
        }
        
        .onReceive(self.profile.$image) { img in
            self.setupImage(img)
        }
        .onReceive(self.profile.$nickName) { name in
            self.name = name?.isEmpty == false ? name : String.pageText.profileEmptyName
        }
        .onReceive(self.profile.$species) { species in
            self.species = species?.isEmpty == false ? species : String.pageText.profileEmptySpecies
        }
        .onReceive(self.profile.$gender) { gender in
            self.gender = gender
        }
        .onReceive(self.profile.$microfin) { fin in
            if fin?.isEmpty == false {
                self.microfin = fin
            } else {
                self.microfin = nil
            }
        }
        
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .getAlbumPictures: self.loaded(res)
            case .registAlbumPicture(_, _, _, let type) : if type == .pet {self.addedPicture(res)}
            case .deleteAlbumPictures(let ids) : self.deletedPicture(res, ids: ids)
            default : break
            }
        }
        .onReceive(self.appSceneObserver.$pickImage) { pick in
            guard let pick = pick else {return}
            if pick.id?.hasSuffix(self.key) != true {return}
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
                            q: .init(type: .registAlbumPicture(img:image, thumbImg:thumbImage, id: self.profile.petId.description, .pet)))
                    }
                }
            } else {
                //self.profile.update(image: nil)
            }
        }
        .onReceive(self.imageLoader.$event){ evt in
            switch evt {
            case .complete(let img): self.setupImage(img)
            default: break
            }
        }
        
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                self.isUiReady = true
                self.isMine = self.dataProvider.user.snsUser?.snsID == self.userId
                if isMine {self.pictures.append(Picture().setEmpty())}
                self.dataProvider.requestData(
                    q: .init(id:self.key,
                             type: .getAlbumPictures(id: self.profile.petId.description, .pet), isOptional: true))
                
            }
        }
        .onAppear(){
            if let img = self.profile.image {
                self.setupImage(img)
            } else {
                self.imagePath = self.profile.imagePath
            }
        }
    }
    
    private func setupImage(_ img:UIImage?){
        self.image = img
        guard let imageSize = img?.size else {
            self.profileHeight = 300
            return
        }
        self.profileHeight = min(300, floor(self.sceneObserver.screenSize.width * imageSize.height / imageSize.width))
    }
    
    @State var key = UUID().uuidString
    @State var pictures:[Picture] = []
    @State var isMine:Bool = false
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
        self.infinityScrollModel.onComplete(itemCount: added.count)
        
    }
    private func selectPicture(_ data:Picture){
        if data.isEmpty {
            self.appSceneObserver.select = .imgPicker(SceneRequest.imagePicker.rawValue + self.key)
        } else {
            var idx = self.pictures.firstIndex(of:data) ?? 0
            if self.isMine {idx = max(idx-1, 0)}
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.picture)
                    .addParam(key: .datas, value: self.pictures.filter{!$0.isEmpty})
                    .addParam(key: .id, value: self.profile.petId.description)
                    .addParam(key: .idx, value: idx )
            )
        }
    }
    private func addedPicture(_ res:ApiResultResponds){
        guard let data = res.data as? PictureData else { return }
        if data.ownerId != self.profile.petId.description { return }
        self.pictures.insert(Picture().setData(data), at: self.isMine ? 1 : 0)
    }
    private func deletedPicture(_ res:ApiResultResponds, ids:String){
        let idA = ids.split(separator: ",")
        let newDatas = self.pictures.filter{ pic in
            return idA.first(where: {$0 == pic.pictureId.description }) == nil
        }
        if newDatas.count == self.pictures.count {return}
        self.pictures = newDatas
    }
}


#if DEBUG
struct PetProfileDetail_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PetProfileDetail(
                profile: PetProfile(
                    nickName: "dalja",
                    species: "biggle",
                    gender: .female,
                    birth: Date())
            )
            .environmentObject(Repository())
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            .environmentObject(DataProvider())
            .frame(width: 325, height: 640)
        }
    }
}
#endif

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
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @ObservedObject var profile:PetProfile
    
    
    @State var image:UIImage? = nil
    @State var imagePath:String? = nil 
    @State var name:String? = nil
    @State var age:String? = nil
    @State var species:String? = nil
    @State var microfin:String? = nil
    @State var gender:Gender? = nil
    @State var lv:String = ""
    @State var exp:String = ""
    @State var prevExp:String = ""
    @State var nextExp:String = ""
    @State var progressExp:Float = 0
    
    @State var neutralization:Bool = false
    @State var distemper:Bool = false
    @State var hepatitis:Bool = false
    @State var parovirus:Bool = false
    @State var rabies:Bool = false
   
    @State var profileHeight:CGFloat = 0
    @State var profileScale:CGFloat = 1.0
    @State var bottomMargin:CGFloat = 0
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
                    case .pullCompleted :
                        //withAnimation{ self.profileScale = 1 }
                        break
                    case .pullCancel :
                        withAnimation{ self.profileScale = 1 }
                    default : do{}
                    }
                    
                }
                .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                    PageLog.d("pos " +  pos.description, tag:self.tag)
                    self.profileScale = 1.0 + (pos*0.01)
                }
                    
            }
            .modifier(MatchHorizontal(height: self.profileHeight))
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                scrollType : .reload(isDragEnd: false),
                isRecycle:false,
                useTracking:true)
            {
                VStack(alignment: .leading, spacing: Dimen.margin.regular){
                    VStack(alignment: .leading, spacing: Dimen.margin.tiny){
                        HStack(spacing:Dimen.margin.tiny){
                            Text(self.name ?? "")
                                 .modifier(BoldTextStyle(
                                     size: Font.size.boldxtra,
                                     color: Color.app.greyDeep
                                 ))
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
                        PetProfileInfoDescription(
                            profile: self.profile,
                            age: self.age,
                            species: self.species,
                            gender: self.gender,
                            isModifyAble: false)
                    }
                    
                    VStack(alignment: .leading, spacing: Dimen.margin.micro){
                        if self.neutralization {
                            PetVaccinated(text: String.pageText.profileRegistNeutralized, isVaccination: true)
                        }
                        if self.distemper {
                            PetVaccinated(text: String.pageText.profileRegistDistemperVaccinated, isVaccination: true)
                        }
                        if self.hepatitis {
                            PetVaccinated(text: String.pageText.profileRegistHepatitisVaccinated, isVaccination: true)
                        }
                        if self.parovirus {
                            PetVaccinated(text: String.pageText.profileRegistParovirusVaccinated, isVaccination: true)
                        }
                        if self.rabies {
                            PetVaccinated(text: String.pageText.profileRegistRabiesVaccinated, isVaccination: true)
                        }
                    }
                    VStack(spacing: Dimen.margin.regular){
                        VStack(spacing: Dimen.margin.micro){
                            HStack{
                                Text(self.lv)
                                    .modifier(BoldTextStyle(
                                        size: Font.size.thinExtra,
                                        color: Color.brand.primary
                                    ))
                                Spacer()
                                Text(self.exp)
                                    .modifier(SemiBoldTextStyle(
                                        size: Font.size.thinExtra,
                                        color: Color.app.grey
                                    ))
                            }
                            ProgressSlider(progress: self.progressExp, useGesture: false, progressHeight: Dimen.bar.light, thumbSize: 0)
                                .frame(height: Dimen.bar.light)
                                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.micro))
                            
                        }
                    }
                    
                    HStack{
                        Text(String.pageText.profileWalkHistory)
                            .modifier(ContentTitle())
                        Spacer()
                        Button(action: {
                           
                
                        }) {
                            Image(Asset.icon.calendar)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.brand.fourth)
                                .frame(width: Dimen.icon.regularExtra,
                                       height: Dimen.icon.regularExtra)
                        }
                    }
                    
                    HStack{
                        Text(String.pageText.profileMissionHistory)
                            .modifier(ContentTitle())
                        Spacer()
                        Button(action: {
                           
                
                        }) {
                            Image(Asset.icon.flag)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.brand.primary)
                                .frame(width: Dimen.icon.regularExtra,
                                       height: Dimen.icon.regularExtra)
                        }
                    }
                    
                    HStack{
                        Text(String.pageText.profileHealthCare)
                            .modifier(ContentTitle())
                        Spacer()
                        Button(action: {
                           
                
                        }) {
                            Image(Asset.icon.speed)
                                .renderingMode(.template)
                                .resizable()
                                .foregroundColor(Color.brand.secondary)
                                .scaledToFit()
                                .frame(width: Dimen.icon.regularExtra,
                                       height: Dimen.icon.regularExtra)
                        }
                    }
                    
                }
                .padding(.bottom,self.bottomMargin)
            }
            .modifier(BottomFunctionTab())
            .padding(.top, self.profileHeight - Dimen.margin.mediumExtra)
            .modifier(MatchParent())
            
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
        .onReceive(self.profile.$neutralization) { isVaccination in
            self.neutralization = isVaccination ?? false
        }
        .onReceive(self.profile.$hepatitis) { isVaccination in
            self.hepatitis = isVaccination ?? false
        }
        .onReceive(self.profile.$distemper) { isVaccination in
            self.distemper = isVaccination ?? false
        }
        .onReceive(self.profile.$parovirus) { isVaccination in
            self.parovirus = isVaccination ?? false
        }
        .onReceive(self.profile.$rabies) { isVaccination in
            self.rabies = isVaccination ?? false
        }
        .onReceive(self.profile.$lv) { lv in
            self.lv = "Lv." + lv.description
        }
        .onReceive(self.profile.$exp) { exp in
            self.exp = exp.formatted(style: .decimal) + "exp"
        }
        .onReceive(self.profile.$prevExp) { exp in
            self.prevExp = exp.formatted(style: .decimal)
        }
        .onReceive(self.profile.$nextExp) { exp in
            if exp == 0 {return}
            self.nextExp = exp.formatted(style: .decimal)
            let prev = self.profile.prevExp
            withAnimation{
                self.progressExp = Float((self.profile.exp - prev) / (exp - prev))
            }
        }
        .onReceive(self.imageLoader.$event){ evt in
            switch evt {
            case .complete(let img): self.setupImage(img)
            default: break
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
}

struct PetVaccinated:PageView{
    var text:String
    var isVaccination:Bool = false
    var body: some View {
        HStack(alignment: .center, spacing: Dimen.margin.thin){
            Image(self.isVaccination
                    ? Asset.shape.radioBtnOn
                    : Asset.shape.radioBtnOff)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
            Text(self.text)
                .modifier(SemiBoldTextStyle(
                    size: Font.size.thinExtra,
                    color: self.isVaccination ? Color.brand.secondary: Color.app.grey
                ))
            
        }
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
            .frame(width: 375, height: 640)
        }
    }
}
#endif

//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

enum ProfileType:String{
    case user, pet
}
enum InputDataType:String{
    case text, select, date, image, radio
}

class InputData:Identifiable{
    let id:String = UUID().uuidString
    
    let type:InputDataType
    let title: String
    let tip: String?
    let info: String?
    let placeHolder:String
    let keyboardType:UIKeyboardType
    let tabs:[SelectData]
    let checks:[RadioData]
    var selectedIdx:Int = -1
    var selectedDate:Date? = nil
    var selectedImage:UIImage? = nil
    var inputValue:String = ""
    var inputMax:Int = 15
    var isOption:Bool = false
    init(
        type:InputDataType = .text,
        title: String,
        tip:String? = nil,
        info:String? = nil,
        placeHolder:String = "",
        keyboardType:UIKeyboardType = .default,
        tabs:[SelectData] = [],
        checks:[RadioData] = [],
        isOption:Bool = false
        ) {
        
        self.type = type
        self.title = title
        self.tip = tip
        self.info = info
        self.placeHolder = placeHolder
        self.keyboardType = keyboardType
        self.tabs = tabs
        self.checks = checks
        self.isOption = isOption
    }
}

struct PageProfileRegist: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
   
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @State var bottomMargin:CGFloat = 0
    @State var type:ProfileType = .pet
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack( spacing: 0 ){
                    PageTab(
                        isBack: true
                    ){
                        self.isFocus = false
                        self.appSceneObserver.alert = .confirm(
                            nil, String.pageText.profileCancelConfirm)
                        { isOk in
                            if isOk {
                                self.pagePresenter.goBack()
                            }
                        }
                    }
                    .padding(.top, self.appSceneObserver.safeHeaderHeight)
                    .padding(.bottom, Dimen.margin.thin)
                    VStack( spacing: 0 ){
                        
                        VStack(spacing: 0) {
                            if self.step != 1 {
                                if let img = self.selectedProfileImage {
                                    Image(uiImage: img)
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(
                                        width: Dimen.profile.lightExtra,
                                        height: Dimen.profile.lightExtra)
                                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                }
                            }
                            HStack(spacing: Dimen.margin.tinyExtra) {
                                Text(String.app.step + " " + (self.step+1).description)
                                    .modifier(SemiBoldTextStyle(size: Font.size.lightExtra, color: Color.brand.primary))
                                Text( String.app.of + " " + self.steps.count.description )
                                    .modifier(SemiBoldTextStyle(size: Font.size.lightExtra, color: Color.app.greyLight))
                            }
                            .padding(.top, Dimen.margin.light)
                            
                            HStack(spacing: 0) {
                                Spacer()
                                    .modifier(MatchVertical(width:self.leading))
                                    .background(Color.brand.primary)
                                    .fixedSize(horizontal: true, vertical: false)
                                Spacer()
                                    .modifier(MatchVertical(width:self.trailing))
                                    .background(Color.app.greyLight)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .frame( height: Dimen.line.mediumExtra)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                            .padding(.top, Dimen.margin.tiny)
                        }
                        .padding(.bottom, Dimen.margin.mediumExtra)
                        
                        if let inputData = self.inputData {
                            if inputData.type == .select{
                                SelectTab(
                                    name:self.currentName,
                                    data: inputData )
                                { idx in
                                    self.selectedIdx = idx
                                }
                            } else if inputData.type == .radio{
                                SelectRadio(
                                    name:self.currentName,
                                    data: inputData )
                                
                            } else if inputData.type == .date{
                                SelectDatePicker(
                                    name:self.currentName,
                                    data: inputData )
                                { date in
                                    self.selectedDate = date
                                }
                            } else if inputData.type == .image{
                                SelectImagePicker(
                                    name:self.currentName,
                                    id:self.profile?.id ?? "", data: inputData )
                                { image in
                                    self.selectedImage = image
                                }
                            }else {
                                InputCell(
                                    title: self.currentName + inputData.title,
                                    input: self.$input,
                                    inputLimited: inputData.inputMax,
                                    isFocus: self.isFocus,
                                    placeHolder: inputData.placeHolder,
                                    keyboardType: inputData.keyboardType,
                                    tip: inputData.tip,
                                    info: inputData.info
                                )
                            }
                        }
                        Spacer()
                        if self.inputData?.isOption == true {
                            TextButton(
                                defaultText: String.pageText.profileOption,
                                isSelected: true
                            ){ _ in
                                self.update()
                                self.next()
                            }
                            .padding(.bottom, Dimen.margin.mediumExtra)
                        }
                        HStack(spacing: Dimen.margin.tiny) {
                            if self.step > 0 {
                                FillButton(
                                    text: String.button.prev,
                                    isSelected: false
                                ){_ in
                                    self.update()
                                    self.prev()
                                }
                            }
                            FillButton(
                                text: self.step == self.steps.count-1
                                    ? String.button.complete
                                    :String.button.next,
                                isSelected: self.isComplete
                            ){_ in
                                if !self.update() {
                                    self.appSceneObserver.event = .toast(String.alert.needInput)
                                } else {
                                    self.next()
                                }
                            }
                        }
                        .padding(.bottom, self.bottomMargin + Dimen.margin.light)
                    }
                    .modifier(ContentHorizontalEdges())
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.appSceneObserver.$safeBottomHeight){ height in
                withAnimation{ self.bottomMargin = height }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.setupInput()
                }
                
            }
            .onReceive(self.keyboardObserver.$isOn){ isOn in
                if isOn != isFocus {
                    self.isFocus = isOn
                }
                
            }
            .onAppear{
                if let obj = self.pageObject {
                    if let type = obj.getParamValue(key: .type) as? ProfileType {
                        self.type = type
                    }
                }
                switch self.type {
                case .user :
                    self.userProfile = UserProfile()
                    self.steps = [
                        InputData(
                            type:.text,
                            title: String.pageText.profileRegistNickName,
                            tip:String.pageText.profileRegistNameTip,
                            placeHolder: String.pageText.profileNickNamePlaceHolder)
                    ]
                case .pet :
                    if let profile = self.dataProvider.user.currentPet {
                        self.profile = profile
                    } else {
                        self.profile = PetProfile(isMyPet: true)
                    }
                    self.steps = [
                        InputData(
                            type:.text,
                            title: String.pageText.profileRegistName,
                            tip:String.pageText.profileRegistNameTip,
                            placeHolder: String.pageText.profileNamePlaceHolder),
                        InputData(
                            type:.image,
                            title: String.pageText.profileRegistImage),
                        InputData(
                            type:.text,
                            title: String.pageText.profileRegistSpecies,
                            tip:String.pageText.profileRegistNameTip,
                            placeHolder: String.pageText.profileSpeciesPlaceHolder),
                        InputData(
                            type:.date,
                            title: String.pageText.profileRegistBirth),
                        InputData(
                            type:.select,
                            title: String.pageText.profileRegistGender,
                            tabs: [
                                .init(
                                    idx: 0,
                                    image: Asset.icon.male,
                                    text: String.app.male, color: Color.brand.fourthExtra),
                                .init(
                                    idx: 1,
                                    image: Asset.icon.female,
                                    text: String.app.female, color: Color.brand.fiveth)
                            ]),
                        InputData(
                            type:.text,
                            title: String.pageText.profileRegistMicroFin,
                            info:String.pageText.profileRegistMicroFinInfo,
                            placeHolder: String.pageText.profileMicroFinPlaceHolder,
                            keyboardType: .numberPad,
                            isOption: true
                            ),
                        InputData(
                            type:.radio,
                            title: String.pageText.profileRegistHealth,
                            checks:[
                                .init(text: String.pageText.profileRegistNeutralized),
                                .init(text: String.pageText.profileRegistDistemperVaccinated),
                                .init(text: String.pageText.profileRegistHepatitisVaccinated),
                                .init(text: String.pageText.profileRegistParovirusVaccinated),
                                .init(text: String.pageText.profileRegistRabiesVaccinated)
                            ])
                    ]
                }
                
                
            }
            .onDisappear{
               
            }
            /*
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .updateUser, .registPet:
                    self.pagePresenter.closePopup(self.pageObject?.id)
                default : break
                }
            }
             */
            
        }//geo

    }//body
    
    @State var currentName:String = ""
    @State var isFocus:Bool = false
    @State var input:String = ""
    @State var inputData:InputData? = nil
    @State var selectedIdx:Int = -1
    @State var selectedDate:Date? = nil
    @State var selectedImage:UIImage? = nil
    @State var selectedProfileImage:UIImage? = nil
    @State var step:Int  = 0
    
    @State var profile:PetProfile? = nil
    @State var userProfile:UserProfile? = nil
    @State var leading:CGFloat = 0
    @State var trailing:CGFloat = 0
    
    @State var steps: [InputData] = []
     
    @discardableResult
    private func update() -> Bool {
        if self.step >= self.steps.count { return false }
        switch self.step {
        case  0 :
            if self.input.isEmpty  { return false }
            self.currentName = self.input + String.app.owner + " "
            self.profile?.update(data: ModifyPetProfileData(nickName: self.input))
            self.userProfile?.update(data: ModifyUserProfileData( nickName: self.input))
        case  1 :
            guard let image = self.selectedImage else { return false }
            self.selectedProfileImage = image
            self.profile?.update(image:image)
        case  2 :
            if self.input.isEmpty  { return false }
            self.profile?.update(data: ModifyPetProfileData(species: self.input))
        case  3 :
            guard let date = self.selectedDate else { return false }
            self.profile?.update(data: ModifyPetProfileData(birth: date))
        case  4 :
            let gender:Gender = self.selectedIdx == 0 ? .male : .female
            self.profile?.update(data: ModifyPetProfileData(gender: gender))
        case  5 :
            self.profile?.update(data: ModifyPetProfileData(microfin: self.input))
        case  6 :
            guard let inputData = self.inputData else {return false}
            self.profile?.update(data:
                            ModifyPetProfileData(
                                neutralization: inputData.checks[0].isCheck,
                                distemper: inputData.checks[1].isCheck,
                                hepatitis: inputData.checks[2].isCheck,
                                parovirus: inputData.checks[3].isCheck,
                                rabies: inputData.checks[4].isCheck))
            
        default : break
        }
        return true
    }
    
    var isComplete:Bool {
        switch self.inputData?.type {
        case .text:
            return !self.input.isEmpty
        case .image:
            return self.selectedImage != nil
        case .select:
            return self.selectedIdx != -1
        case .date:
            return self.selectedDate != nil
        case .radio:
            return true
        default  : return false
        }
    }
    
    private func saveInput(){
        if let data = self.inputData {
            switch data.type {
            case .date :
                data.selectedDate = self.selectedDate
                PageLog.d("saveInput " + self.selectedDate.debugDescription, tag: self.tag)
            case .image :
                data.selectedImage = self.selectedImage
            case .select :
                data.selectedIdx = self.selectedIdx
                PageLog.d("saveInput " + self.selectedIdx.description, tag: self.tag)
            case .text :
                data.inputValue = self.input
            case .radio : break
            }
        }
        self.inputData = nil
        self.selectedIdx = -1
        self.selectedImage = nil
        self.input = ""
        self.isFocus = false
        self.selectedDate = Date()
        PageLog.d("saveInput reset", tag: self.tag)
    }
    
    private func prev(){
        self.saveInput()
        let willStep = self.step - 1
        if willStep < 0 { return }
       
        self.step = willStep
        self.setupInput()
    }
    
    private func next(){
        self.saveInput()
        let willStep = self.step + 1
        if willStep >= self.steps.count {
            self.setupCompleted()
        } else {
            self.step = willStep
            self.setupInput()
        }
    }
    
    private func setBar(){
        if self.steps.count <= 1 {return}
        let count = self.steps.count
        let size =  Dimen.bar.medium
        let cidx = self.step + 1
        withAnimation{
            self.leading = size * CGFloat(cidx)
            self.trailing = size * CGFloat(count - cidx)
        }
    }
    private func setupInput(){
        let cdata = self.steps[self.step]
        if self.step == 0 {
            self.currentName = ""
        }
        
        self.selectedIdx = cdata.selectedIdx
        self.input = cdata.inputValue
        self.selectedDate = cdata.selectedDate
        self.selectedImage = cdata.selectedImage
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2){
            withAnimation{
                self.inputData = cdata
            }
            PageLog.d("setupInput " + cdata.type.rawValue, tag: self.tag)
            PageLog.d("setupInput " + cdata.selectedDate.debugDescription, tag: self.tag)
            PageLog.d("setupInput " + cdata.selectedIdx.description, tag: self.tag)
        }
        
        if cdata.type == .text && !cdata.isOption {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3){
                self.isFocus = true
            }
        }
        self.setBar()
    }
    private func setupCompleted(){
        guard let user = self.dataProvider.user.snsUser else { return }
        switch self.type {
        case .user :
            self.dataProvider.requestData(q: .init(id:self.tag, type: .updateUser( user, .init( nickName: self.userProfile?.nickName))))
            
        case .pet :
            guard let profile = self.profile else { return }
            self.dataProvider.requestData(q: .init(id:self.tag, type: .registPet(user, profile)))
        }
        self.pagePresenter.closePopup(self.pageObject?.id)
        
        
    }
}


#if DEBUG
struct PageProfileRegist_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageProfileRegist().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif


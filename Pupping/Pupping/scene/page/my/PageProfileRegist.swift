//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

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
        placeHolder:String = String.pageText.profileRegistPlaceHolder,
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
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @State var safeAreaBottom:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
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
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    .padding(.bottom, Dimen.margin.thin)
                    VStack( spacing: 0 ){
                        
                        VStack(spacing: 0) {
                            if self.step != 0 {
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
                            .frame( height: Dimen.line.medium)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                            .padding(.top, Dimen.margin.tiny)
                        }
                        .padding(.bottom, Dimen.margin.mediumExtra)
                        
                        if let inputData = self.inputData {
                            if inputData.type == .select{
                                SelectTab(data: inputData )
                                { idx in
                                    self.selectedIdx = idx
                                }
                            } else if inputData.type == .radio{
                                SelectRadio( data: inputData )
                                
                            } else if inputData.type == .date{
                                SelectDatePicker( data: inputData )
                                { date in
                                    self.selectedDate = date
                                }
                            } else if inputData.type == .image{
                                SelectImagePicker( id:self.profile?.id ?? "", data: inputData )
                                { image in
                                    self.selectedImage = image
                                }
                            }else {
                                InputCell(
                                    title: inputData.title,
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
                                self.update()
                                self.next()
                            }
                        }
                        .padding(.bottom, self.safeAreaBottom + Dimen.margin.light)
                    }
                    .modifier(ContentHorizontalEdges())
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
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
            .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
                withAnimation{
                    self.safeAreaBottom = pos
                }
            }
            .onAppear{
                if let profile = self.dataProvider.user.currentRegistProfile {
                    self.profile = profile
                } else {
                    self.profile = self.dataProvider.user.registProfile()
                }
            }
            .onDisappear{
               
            }
            
        }//geo

    }//body
    
   
    @State var isFocus:Bool = false
    @State var input:String = ""
    @State var inputData:InputData? = nil
    @State var selectedIdx:Int = -1
    @State var selectedDate:Date? = nil
    @State var selectedImage:UIImage? = nil
    @State var selectedProfileImage:UIImage? = nil
    @State var step:Int  = 0
    @State var profile:Profile? = nil
    
    @State var leading:CGFloat = 0
    @State var trailing:CGFloat = 0
    
    let steps: [InputData] = [
        InputData(
            type:.image,
            title: String.pageText.profileRegistImage),
        InputData(
            type:.text,
            title: String.pageText.profileRegistName,
            tip:String.pageText.profileRegistNameTip),
        InputData(
            type:.text,
            title: String.pageText.profileRegistSpecies,
            tip:String.pageText.profileRegistNameTip),
        InputData(
            type:.date,
            title: String.pageText.profileRegistBirth),
        InputData(
            type:.select,
            title: String.pageText.profileRegistGender,
            tabs: [
                .init(
                    idx: 0,
                    image: Asset.icon.mail,
                    text: String.app.mail, color: Color.brand.fourthExtra),
                .init(
                    idx: 1,
                    image: Asset.icon.femail,
                    text: String.app.femail, color: Color.brand.primary)
            ]),
        InputData(
            type:.text,
            title: String.pageText.profileRegistMicroFin,
            info:String.pageText.profileRegistMicroFinInfo,
            placeHolder: String.pageText.profileRegistMicroFinPlaceHolder,
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
    
    private func update(){
        if self.step >= self.steps.count { return }
        switch self.step {
        case  0 :
            self.selectedProfileImage = self.selectedImage
            self.profile?.update(image:self.selectedImage)
        case  1 : self.profile?.update(data: ModifyProfileData(nickName: self.input))
        case  2 : self.profile?.update(data: ModifyProfileData(species: self.input))
        case  3 : self.profile?.update(data: ModifyProfileData(birth: self.selectedDate))
        case  4 :
            let gender:Gender = self.selectedIdx == 0 ? .mail : .femail
            self.profile?.update(data: ModifyProfileData(gender: gender))
        case  5 : self.profile?.update(data: ModifyProfileData(microfin: self.input))
        case  6 :
            guard let inputData = self.inputData else {return}
            self.profile?.update(data:
                            ModifyProfileData(
                                neutralization: inputData.checks[0].isCheck,
                                distemper: inputData.checks[1].isCheck,
                                hepatitis: inputData.checks[2].isCheck,
                                parovirus: inputData.checks[3].isCheck,
                                rabies: inputData.checks[4].isCheck))
            
        default : break
        }
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
        self.setBar()
        self.setupInput()
    }
    
    private func next(){
        self.saveInput()
        let willStep = self.step + 1
        if willStep >= self.steps.count {
            self.setupCompleted()
        } else {
            self.step = willStep
            self.setBar()
            self.setupInput()
        }
    }
    
    private func setBar(){
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
    }
    private func setupCompleted(){
        self.dataProvider.user.registComplete()
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


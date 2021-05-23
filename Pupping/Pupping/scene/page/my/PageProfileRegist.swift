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
    case text, select, date, image
}

class InputData:Identifiable{
    let id:String = UUID().uuidString
    
    let type:InputDataType
    let title: String
    let tip: String?
    let placeHolder:String
    let keyboardType:UIKeyboardType
    let tabs:[String]
    
    var selectedIdx:Int = 0
    var selectedDate:Date = Date()
    var selectedImage:UIImage? = nil
    
    var inputValue:String = ""
    init(
        type:InputDataType = .text,
        title: String,
        tip:String? = nil,
        placeHolder:String = String.pageText.profileRegistPlaceHolder,
        keyboardType:UIKeyboardType = .default,
        tabs:[String] = []) {
        
        self.type = type
        self.title = title
        self.tip = tip
        self.placeHolder = placeHolder
        self.keyboardType = keyboardType
        self.tabs = tabs
    }
}

struct PageProfileRegist: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @State var safeAreaBottom:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack( spacing: 0 ){
                    PageTab(
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    .padding(.bottom, Dimen.margin.heavy)
                    if let inputData = self.inputData {
                        if inputData.type == .select{
                            SelectTab(data: inputData )
                            { idx in
                                self.selectedIdx = idx
                            }
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
                                isFocus: self.isFocus,
                                placeHolder: inputData.placeHolder,
                                keyboardType: inputData.keyboardType,
                                tip: inputData.tip
                            )
                        }
                    }
                    Spacer()
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
                            isSelected: self.step == self.steps.count-1
                        ){_ in
                            self.update()
                            self.next()
                        }
                    }
                    .padding(.bottom, self.safeAreaBottom + Dimen.margin.light)
                }
                
                .modifier(ContentHorizontalEdges())
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
    @State var selectedIdx:Int = -1
    @State var inputData:InputData? = nil
    @State var selectedDate:Date = Date()
    @State var selectedImage:UIImage? = nil
    @State var step:Int  = 0
    @State var profile:Profile? = nil
    
    let steps: [InputData] = [
        InputData(type:.image, title: String.pageText.profileRegistImage),
        InputData(type:.text, title: String.pageText.profileRegistName, tip:String.pageText.profileModifyAble),
        InputData(type:.text, title: String.pageText.profileRegistSpecies, tip:String.pageText.profileModifyAble),
        InputData(type:.date, title: String.pageText.profileRegistBirth),
        InputData(type:.select, title: String.pageText.profileRegistGender,
                  tabs: [Gender.mail.getTitle(), Gender.femail.getTitle()] ),
        InputData(type:.text, title: String.pageText.profileRegistMicroFin, tip:String.pageText.profileOption)
    ]
    
    private func update(){
        if self.step >= self.steps.count-1 { return }
        switch self.step {
        case  0 : self.profile?.update(image:self.selectedImage)
        case  1 : self.profile?.update(data: ModifyProfileData(nickName: self.input))
        case  2 : self.profile?.update(data: ModifyProfileData(species: self.input))
        case  3 : self.profile?.update(data: ModifyProfileData(birth: self.selectedDate))
        case  4 :
            let gender:Gender = self.selectedIdx == 0 ? .mail : .femail
            self.profile?.update(data: ModifyProfileData(gender: gender))
        case  5 : self.profile?.update(data: ModifyProfileData(microfin: self.input))
        default : break
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
            }
        }
        self.inputData = nil
        self.selectedIdx = 0
        self.input = ""
        self.selectedDate = Date()
        self.selectedImage = nil
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
        
        if cdata.type == .text {
            self.isFocus = true
        } else {
            self.isFocus = false
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


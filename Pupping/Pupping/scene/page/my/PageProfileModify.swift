//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine



struct PageProfileModify: PageView {
    enum ModifyType {
        case none, name, species
    }

    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    
    @State var bottomMargin:CGFloat = 0
    @State var isUiReady:Bool = false
   
   
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
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        isRecycle:false,
                        useTracking:false)
                    {
                        VStack( spacing: Dimen.margin.medium ){
                            if self.isReady {
                                InputCell(
                                    title: String.pageText.profileRegistName,
                                    input: self.$inputName,
                                    isFocus: self.currentModifyType == .name,
                                    placeHolder: String.pageText.profileNamePlaceHolder,
                                    keyboardType: .default
                                )
                                InputCell(
                                    title:self.inputName + String.pageText.profileRegistSpecies,
                                    input: self.$inputSpecies,
                                    isFocus: self.currentModifyType == .species,
                                    placeHolder: String.pageText.profileSpeciesPlaceHolder,
                                    keyboardType: .default
                                )
                                InputCell(
                                    title:self.inputName + String.pageText.profileRegistMicroFin,
                                    input: self.$inputMicrofin,
                                    isFocus: self.currentModifyType == .species,
                                    placeHolder: String.pageText.profileMicroFinPlaceHolder,
                                    keyboardType: .numberPad
                                )
                                SelectRadio(
                                    data: self.healthData,
                                    margin: Dimen.margin.regular
                                )
                                .padding(.bottom, Dimen.margin.medium)
                            }
                        }
                        .modifier(ContentHorizontalEdges())
                    }
                    HStack(spacing: Dimen.margin.tiny) {
                        FillButton(
                            text: String.app.cancel,
                            isSelected: false
                        ){_ in
                            self.pagePresenter.goBack()
                        }
                        FillButton(
                            text:  String.button.modify,
                            isSelected: self.isComplete
                        ){_ in
                            if !self.isComplete {
                                self.appSceneObserver.event = .toast(String.alert.needInput)
                                return 
                            }
                            guard let profile = self.profile else {return}
                            let data = ModifyPetProfileData(
                                nickName:self.inputName,
                                species: self.inputSpecies,
                                microfin: self.inputMicrofin,
                                neutralization: self.healthData.checks[0].isCheck,
                                distemper: self.healthData.checks[1].isCheck,
                                hepatitis: self.healthData.checks[2].isCheck,
                                parovirus: self.healthData.checks[3].isCheck,
                                rabies: self.healthData.checks[4].isCheck)
                            
                            self.dataProvider.requestData(q: .init(type: .updatePet(petId: profile.petId, data)))
                            self.pagePresenter.goBack()
                        }
                    }
                    .modifier(ContentHorizontalEdges())
                    .padding(.bottom, self.bottomMargin + Dimen.margin.light)
                    
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.appSceneObserver.$safeBottomHeight){ height in
                withAnimation{ self.bottomMargin = height }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isUiReady = true
                    
                }
            }
            
            .onAppear{
                guard let obj = self.pageObject  else { return }
                guard let profile = obj.getParamValue(key: .data) as? PetProfile else { return }
                self.profile = profile
                self.inputName = profile.nickName ?? ""
                self.inputSpecies = profile.species ?? ""
                self.inputMicrofin = profile.microfin ?? ""
                self.isReady = true
                
                self.healthData.checks[0].isCheck = profile.neutralization ?? false
                self.healthData.checks[1].isCheck = profile.distemper ?? false
                self.healthData.checks[2].isCheck = profile.hepatitis ?? false
                self.healthData.checks[3].isCheck = profile.parovirus ?? false
                self.healthData.checks[4].isCheck =  profile.rabies ?? false
                
            }
            .onDisappear{
               
            }
            
        }//geo

    }//body
    @State var isReady:Bool = false
    @State var currentModifyType:ModifyType = .none
    @State var inputName:String = ""
    @State var inputSpecies:String = ""
    @State var inputMicrofin:String = ""
    @State var healthData:InputData = InputData(
        type:.radio,
        title: String.pageText.profileRegistHealth,
        checks:[
            .init(text: String.pageText.profileRegistNeutralized),
            .init(text: String.pageText.profileRegistDistemperVaccinated),
            .init(text: String.pageText.profileRegistHepatitisVaccinated),
            .init(text: String.pageText.profileRegistParovirusVaccinated),
            .init(text: String.pageText.profileRegistRabiesVaccinated)
        ])
    @State var profile:PetProfile? = nil
    
    var isComplete:Bool {
        if self.inputName.isEmpty {return false}
        if self.inputSpecies.isEmpty {return false}
        
        return true
    }
   
}


#if DEBUG
struct PageProfileModify_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageProfileModify().contentBody
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


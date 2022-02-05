//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine



struct PageHealthModify: PageView {
    enum ModifyType {
        case none, weight, size
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
                                    title: self.name + String.pageText.profileRegistWeight,
                                    input: self.$inputWeight,
                                    isFocus: self.currentModifyType == .weight,
                                    placeHolder: String.app.kg,
                                    keyboardType: .decimalPad
                                )
                                InputCell(
                                    title: self.name + String.pageText.profileRegistSize,
                                    input: self.$inputSize,
                                    isFocus: self.currentModifyType == .size,
                                    placeHolder: String.app.m,
                                    keyboardType: .decimalPad
                                )
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
                                weight:self.inputWeight.toDouble(),
                                size: self.inputSize.toDouble())
                            
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
                self.inputWeight = profile.weight?.description ?? ""
                self.inputSize = profile.size?.description ?? ""
                self.name = profile.nickName ?? String.pageText.profileRegistName
                self.isReady = true
                
            }
            .onDisappear{
               
            }
            
        }//geo

    }//body
    @State var isReady:Bool = false
    @State var currentModifyType:ModifyType = .none
    @State var name:String = String.pageText.profileRegistName
    @State var inputWeight:String = ""
    @State var inputSize:String = ""
   
    @State var profile:PetProfile? = nil
    
    var isComplete:Bool {
        if self.inputSize.isEmpty {return false}
        if self.inputWeight.isEmpty {return false}
        return true
    }
   
}


#if DEBUG
struct PageHealthModify_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageHealthModify().contentBody
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


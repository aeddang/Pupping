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
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    
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
                        self.appSceneObserver.alert = .confirm(
                            nil, String.pageText.profileCancelConfirm)
                        { isOk in
                            if isOk {
                                self.pagePresenter.goBack()
                            }
                        }
                    }
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    .padding(.bottom, Dimen.margin.heavy)
                    
                    VStack( spacing: 0 ){
                        if self.isReady {
                            InputCell(
                                title: String.pageText.profileRegistName,
                                input: self.$inputName,
                                isFocus: self.currentModifyType == .name,
                                placeHolder: String.pageText.profileEmptyName,
                                keyboardType: .default
                            )
                            .padding(.bottom, Dimen.margin.medium)
                            InputCell(
                                title:String.pageText.profileRegistSpecies,
                                input: self.$inputSpecies,
                                isFocus: self.currentModifyType == .species,
                                placeHolder: String.pageText.profileEmptySpecies,
                                keyboardType: .default
                            )
                       
                            Spacer()
                            HStack(spacing: Dimen.margin.tiny) {
                                FillButton(
                                    text: String.app.cancel,
                                    isSelected: false
                                ){_ in
                                    self.pagePresenter.goBack()
                                }
                                FillButton(
                                    text:  String.button.modify,
                                    isSelected: true
                                ){_ in
                                    self.profile?.update(data: ModifyProfileData(nickName:self.inputName, species: self.inputSpecies))
                                    self.pagePresenter.goBack()
                                }
                            }
                            .padding(.bottom, self.safeAreaBottom + Dimen.margin.light)
                        }
                    }
                    .modifier(ContentHorizontalEdges())
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    
                }
            }
            .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
                withAnimation{
                    self.safeAreaBottom = pos
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                guard let profile = obj.getParamValue(key: .data) as? Profile else { return }
                self.profile = profile
                self.inputName = profile.nickName ?? ""
                self.inputSpecies = profile.species ?? ""
                self.isReady = true
            }
            .onDisappear{
               
            }
            
        }//geo

    }//body
    @State var isReady:Bool = false
    @State var currentModifyType:ModifyType = .none
    @State var inputName:String = ""
    @State var inputSpecies:String = ""
    @State var profile:Profile? = nil
    
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


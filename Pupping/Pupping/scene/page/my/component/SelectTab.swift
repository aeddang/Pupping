//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI
struct SelectTab: PageComponent{
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    var data:InputData
    
    @State var tabs:[NavigationButton] = []
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0){
            if let title = self.data.title {
                Text(title)
                    .modifier(RegularTextStyle(size: Font.size.light, color: Color.brand.primary))
                    .multilineTextAlignment(.leading)
            }
            DivisionTab(
                viewModel: self.viewModel,
                buttons: self.tabs,
                height: Dimen.tab.heavy)
            .modifier(MatchParent())
        }
        .onReceive(self.viewModel.$index) { idx in
            self.updateButtons(idx: idx)
            self.action(idx)
        }
        .onAppear(){
            self.viewModel.index = self.data.selectedIdx
        }
    }//body
    
    private func updateButtons(idx:Int){
        
        self.tabs = NavigationBuilder(
            index:idx,
            textModifier: TextModifier(
                family:Font.family.medium,
                size:  Font.size.black,
                color: Color.app.grey,
                activeColor: Color.app.white
                )
            )
        .getNavigationButtons(texts:self.data.tabs)
       
    }
}


#if DEBUG
struct SelectTab_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SelectTab(
                data:InputData(title: "Test", tabs:["Test0", "Test1"])
            ){ _ in
                
            }
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .frame(width:320,height:600)
        }
    }
}
#endif

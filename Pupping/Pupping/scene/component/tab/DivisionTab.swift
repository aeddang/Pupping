//
//  ComponentTabNavigation.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine


struct DivisionTab : PageComponent {
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    var buttons:[NavigationButton]
    var strokeWidth:CGFloat = Dimen.line.light
    var divisionMargin:CGFloat = 0
    var height:CGFloat = Dimen.tab.regular
    var bgColor:Color = Color.transparent.clear
    var useSelectedEffect:Bool = true
    var body: some View {
        HStack(spacing:0){
            ForEach(self.buttons) { btn in
                self.createButton(btn)
                if btn.idx != (self.buttons.count - 1) {
                    Spacer().modifier(MatchVertical(width: 1))
                        .background(Color.app.greyLight)
                        .padding(.vertical , self.divisionMargin)
                }
            }
        }
        .modifier(MatchHorizontal(height: self.height))
        .background(self.bgColor)
    }//body
    
    func createButton(_ btn:NavigationButton) -> some View {
        return Button<AnyView?>(
            action: { self.performAction(btn.id, index: btn.idx)}
        ){ btn.body }
        .modifier(MatchParent())
        .background( btn.idx == self.viewModel.index
                        ? Color.brand.primary
                        : Color.transparent.clearUi)
       
        .buttonStyle(BorderlessButtonStyle())
        
    }
    
    func performAction(_ btnID:String, index:Int){
        if self.useSelectedEffect { self.viewModel.selected = btnID }
        self.viewModel.index = index
    }
    
}


#if DEBUG
struct DivisionTab_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            DivisionTab(
                viewModel:NavigationModel(),
                buttons: [
                    NavigationButton(
                        id: "test1sdsd",
                        body: AnyView(
                            Text("testqsq").background(Color.yellow)

                        ),
                        idx:0
                    ),
                    NavigationButton(
                        id: "test2",
                        body: AnyView(
                            Image(Asset.test).renderingMode(.original).resizable()
                        ),
                        idx:1
                    ),
                    NavigationButton(
                        id: "test3",
                        body: AnyView(
                            Text("tesdcdcdvt")
                        
                        ),
                        idx:2
                    ),
                    NavigationButton(
                        id: "test4",
                        body: AnyView(
                            Text("te")
                            
                        ),
                        idx:3
                    )

                ]
            )
            .frame( alignment: .center)
        }
        .background(Color.brand.bg)
    }
}
#endif

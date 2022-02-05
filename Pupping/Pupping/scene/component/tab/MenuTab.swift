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

struct MenuTab : PageComponent {
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    var scrollReader:ScrollViewProxy? = nil
    let buttons:[String]
    var selectedIdx:Int = 0
    var height:CGFloat = Dimen.button.regular
    var bgColor:Color = Color.app.whiteDeepExtra
    var isDivision:Bool = true
    @State var menus:[MenuBtn] = []
   
    var body: some View {
        HStack(spacing:0){
            ForEach(self.menus) { menu in
                let uuid = UUID().hashValue
                Button(
                    action: {
                        if let scrollReader = self.scrollReader {
                            if menu.idx < self.menus.count-2 {
                                withAnimation{scrollReader.scrollTo(uuid, anchor: .center)}
                            }
                        }
                        self.performAction(menu)
                        
                    }
                ){
                    if self.isDivision {
                        self.createButton(menu)
                            .modifier(MatchParent())
                    } else {
                        self.createButton(menu)
                            .frame(height: self.height)
                    }
                }
                .id(uuid)
                .background( menu.idx == self.selectedIdx
                             ? Color.app.white
                            : Color.transparent.clearUi)
                .clipShape( RoundedRectangle(cornerRadius: Dimen.radius.medium))
                .overlay(
                    RoundedRectangle(
                        cornerRadius: Dimen.radius.medium, style: .circular)
                        .strokeBorder(
                            Color.brand.primary  ,
                            lineWidth: menu.idx == self.selectedIdx ? Dimen.stroke.light : 0 )
                )
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .frame(height: self.height)
        .background(self.bgColor)
        .clipShape( RoundedRectangle(cornerRadius: Dimen.radius.medium))
        .onAppear(){
            self.menus = zip(0..<self.buttons.count, self.buttons).map{ idx, btn in
                MenuBtn(idx: idx, text: btn)
            }
        }
        
    }//body
    
    func createButton(_ menu:MenuBtn) -> some View {
        return Text(menu.text)
            .kerning(Font.kern.thin)
            .modifier(BoldTextStyle(
                size: Font.size.lightExtra,
                color: menu.idx == self.selectedIdx ? Color.brand.primary : Color.app.greyExtra
            ))
            .padding(.horizontal, Dimen.margin.regular)
            .fixedSize(horizontal: true, vertical: false)
    }
    
    
    func performAction(_ menu:MenuBtn){
        self.viewModel.selected = menu.text
        self.viewModel.index = menu.idx
        
    }
    
    struct MenuBtn : SelecterbleProtocol, Identifiable {
        let id = UUID().uuidString
        var idx:Int = 0
        var text:String = ""
    }
    
}


#if DEBUG
struct MenuTab_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            MenuTab(
                viewModel:NavigationModel(),
                buttons: [
                    "TEST0", "TEST11", "TEST222","TEST333" ,"TEST444"
                ]
            )
            .frame( alignment: .center)
        }
        .background(Color.app.white)
    }
}
#endif

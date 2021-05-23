//
//  Toast.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI


extension View {
    func select(isShowing: Binding<Bool>,
               index: Binding<Int>,
               buttons:[SelectBtnData],
               action: @escaping (_ idx:Int) -> Void) -> some View {
        
        return Select(
            isShowing: isShowing,
            index: index,
            presenting: { self },
            buttons: buttons,
            action:action)
    }
    
}
struct SelectBtnData:Identifiable, Equatable{
    let id = UUID.init()
    let title:String
    let index:Int
    var tip:String? = nil
}

struct Select<Presenting>: View where Presenting: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    @Binding var index: Int
    let presenting: () -> Presenting
    var buttons: [SelectBtnData]
    let action: (_ idx:Int) -> Void
    
    @State var safeAreaBottom:CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Button(action: {
                withAnimation{
                    self.isShowing = false
                }
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            VStack{
                Spacer()
                VStack (alignment: .leading, spacing:0){
                    VStack(alignment: .leading, spacing:0){
                        ForEach(self.buttons) { btn in
                            SelectButton(
                                text: btn.title ,
                                tip: btn.tip,
                                index: btn.index,
                                isSelected: btn.index == self.index){idx in
                            
                                self.index = idx
                                self.action(idx)
                            }
                        }
                    }
                }
                .padding(.bottom, self.safeAreaBottom)
                .background(Color.app.white)
                .mask(
                    ZStack(alignment: .bottom){
                        RoundedRectangle(cornerRadius: Dimen.radius.regular)
                        Rectangle().modifier(MatchHorizontal(height: Dimen.radius.regular))
                    }
                )
                .modifier(ShadowTop())
                .offset(y:self.isShowing ? 0 : 200)
            }
        }
        //.transition(.slide)
        .opacity(self.isShowing ? 1 : 0)
        
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            //if self.editType == .nickName {return}
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
    }
}
#if DEBUG
struct Select_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .select(
            isShowing: .constant(true),
            index: .constant(0),
            buttons: [
                SelectBtnData(title:"test" , index:0, tip:"T") ,
                SelectBtnData(title:"test1" , index:1)
            ]
        ){ idx in
        
        }
        .environmentObject(PageSceneObserver())
    }
}
#endif

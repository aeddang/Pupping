//
//  FillButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct FillButton: View, SelecterbleProtocol{
    let text:String
    var index: Int = 0
    var isSelected: Bool = false
    var textModifier:TextModifier = TextModifier(
        family: Font.family.bold,
        size: Font.size.regular,
        color: Color.app.greyDeep,
        activeColor: Color.app.white
    )
    var size:CGFloat = Dimen.button.medium
    var bgColor:Color = Color.app.white
    var bgActiveColor:Color = Color.app.greyDeep
    var icon:String? = nil
    var iconSize:CGFloat = Dimen.icon.thin
    let action: (_ idx:Int) -> Void
    
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                HStack(spacing:Dimen.margin.tiny){
                    if let icon = self.icon {
                        Image(icon)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                            .frame(height: self.iconSize)
                    }
                    Text(self.text)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    
            
                }
            }
            .modifier( MatchHorizontal(height: self.size) )
            .background(self.isSelected ? self.bgActiveColor : self.bgColor )
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
            .overlay(
                RoundedRectangle(cornerRadius: Dimen.radius.light, style: .circular).stroke( self.bgActiveColor ,lineWidth: Dimen.stroke.light )
            )
        }
        
        
    }
}
#if DEBUG
struct FillButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            FillButton(
                text: "test",
                isSelected: true,
                icon: Asset.noImg1_1
            ){_ in
                
            }
            .frame( alignment: .center)
            .background(Color.app.white)
        }
    }
}
#endif


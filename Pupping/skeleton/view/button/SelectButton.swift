//
//  FillButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct SelectButton: View, SelecterbleProtocol{
    let text:String
    var tip:String? = nil
    var index: Int = 0
    var isSelected: Bool
    var textModifier:TextModifier = TextModifier(
        family: Font.family.bold,
        size: Font.size.regular,
        color: Color.app.greyDeep,
        activeColor: Color.brand.primary
    )
    var size:CGFloat = Dimen.button.medium
    let action: (_ idx:Int) -> Void

    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                HStack(spacing:0){
                    Text(self.text)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                    Spacer().modifier(MatchParent())
                    if let tip = self.tip {
                        Text(tip)
                            .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.white))
                            .padding(.horizontal, Dimen.margin.thin)
                            .frame(height:Dimen.button.thin)
                            .background(Color.brand.primary)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
                    }
                    
                }
                .padding(.horizontal, Dimen.margin.medium)
            }
            .modifier( MatchHorizontal(height: self.size) )
            .background(self.isSelected ? Color.app.greyLight : Color.app.white )
        }
        
        
    }
}
#if DEBUG
struct SelectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SelectButton(
                text: "test",
                tip: "A",
                index: 0,
                isSelected: false
            ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif


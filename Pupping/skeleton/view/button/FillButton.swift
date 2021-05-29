//
//  FillButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

enum FillButtonType{
    case normal, stroke, small
}


struct FillButton: View, SelecterbleProtocol{
    let text:String
    var index: Int = 0
    var isSelected: Bool = false
    var textModifier:TextModifier = TextModifier(
        family: Font.family.semiBold,
        size: Font.size.regularExtra,
        color: Color.app.white,
        activeColor: Color.app.white
    )
    var size:CGFloat = Dimen.button.medium
    var bgColor:Color = Color.app.greyLight
    var bgActiveColor:Color = Color.brand.primary
    var icon:String? = nil
    var iconSize:CGFloat = Dimen.icon.thin
    var isStroke:Bool = false
    let action: (_ idx:Int) -> Void
    
    
    init(
        type:FillButtonType = .normal,
        text:String,
        icon:String? = nil,
        index: Int = 0,
        isSelected: Bool = true,
        size:CGFloat? = nil,
        action:@escaping (_ idx:Int) -> Void )
    {
        self.text = text
        self.icon = icon
        self.index = index
        self.isSelected = isSelected
        self.action = action
        if let value = size {self.size = value}
        switch type {
        case .stroke :
            textModifier = TextModifier(
                family: Font.family.semiBold,
                size: Font.size.regularExtra,
                color: Color.app.greyDeep,
                activeColor: Color.app.white
            )
            bgColor = Color.app.white
            bgActiveColor = Color.app.greyDeep
            isStroke = true
        case .small :
            textModifier = TextModifier(
                family: Font.family.semiBold,
                size: Font.size.thin,
                color: Color.app.white,
                activeColor: Color.app.white
            )
            if size == nil { self.size = Dimen.button.regular }
        default : break
        }
    }
    
    
    
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
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.lightExtra))
            .overlay(
                RoundedRectangle(
                    cornerRadius: Dimen.radius.lightExtra, style: .circular)
                    .stroke( self.bgActiveColor ,lineWidth: self.isStroke ? Dimen.stroke.light : 0 )
            )
            .modifier(Shadow(
                color: self.isSelected ? self.bgActiveColor : self.bgColor,
                opacity: self.isStroke ? 0 : 0.12
            ))
        }
        
        
    }
}
#if DEBUG
struct FillButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            FillButton(
                text: "test",
                icon: Asset.noImg1_1,
                isSelected: true
                
            ){_ in
                
            }
            .frame( alignment: .center)
            .background(Color.app.white)
        }
    }
}
#endif


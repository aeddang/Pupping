//
//  CheckBox.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/20.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct CheckBox: View, SelecterbleProtocol {
    var isChecked: Bool
    var text:String? = nil
    var subText:String? = nil
    var isStrong:Bool = false
    var isSimple:Bool = false
    var more: (() -> Void)? = nil
    var action: ((_ check:Bool) -> Void)? = nil
    
    
    var body: some View {
        HStack(alignment: .top, spacing: Dimen.margin.thin){
           ImageButton(
            isSelected: self.isChecked, defaultImage: Asset.shape.checkBoxOff,
            activeImage: self.isStrong
                ? Asset.shape.checkBoxOn : Asset.shape.checkBoxOn2,
                size: CGSize(width: Dimen.icon.thin, height: Dimen.icon.thin)
                ){_ in
                    if self.action != nil {
                        self.action!(!self.isChecked)
                    }
            }
            if !self.isSimple {
                VStack(alignment: .leading, spacing: Dimen.margin.tiny){
                    if self.text != nil {
                        if self.isStrong {
                            Text(self.text!)
                                .modifier( BoldTextStyle(
                                        size: Font.size.light,
                                        color: Color.app.white)
                                )
                        }else{
                            Text(self.text!)
                                .modifier( MediumTextStyle(
                                        size: Font.size.thinExtra,
                                        color: Color.app.white)
                                )
                        }

                    }
                    if self.subText != nil {
                        Text(self.subText!)
                            .modifier(MediumTextStyle(
                                size: Font.size.thinExtra,
                                color: Color.app.greyLight))
                    }
                }.offset(y:3)
                Spacer()
                if more != nil {
                    TextButton(
                        defaultText: String.button.view,
                        textModifier:TextModifier(
                            family:Font.family.medium,
                            size:Font.size.thinExtra,
                            color: Color.app.white),
                        isUnderLine: true)
                    {_ in
                        self.more!()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct CheckBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CheckBox(
                isChecked: true,
                text:"asdafafsd",
                more:{
                    
                },
                action:{ ck in
                
                }
            )
            .frame( alignment: .center)
            .background(Color.brand.bg)
        }
        
    }
}
#endif


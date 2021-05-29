//
//  CheckBox.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/20.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct RadioButton: View, SelecterbleProtocol {
    var isChecked: Bool
    var size:CGSize = CGSize(width: Dimen.icon.mediumExtra, height: Dimen.icon.mediumExtra)
    var text:String? = nil
    var textSize:CGFloat = Font.size.thin
    
    var action: ((_ check:Bool) -> Void)? = nil
    var body: some View {
        HStack(alignment: .center, spacing: Dimen.margin.thin){
            if self.text != nil {
                Button(action: {
                    if self.action != nil {
                        self.action!(!self.isChecked)
                    }
                    
                }) {
                    Text(self.text!)
                        .modifier(SemiBoldTextStyle(
                            size: self.textSize,
                            color: self.isChecked ? Color.app.greyDeep : Color.app.grey
                        ))
                    
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            Spacer()
            Button(action: {
                if self.action != nil {
                    self.action!(!self.isChecked)
                }
                
            }) {
                Image(self.isChecked
                        ? Asset.shape.radioBtnOn
                        : Asset.shape.radioBtnOff)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
                
            }
            .buttonStyle(BorderlessButtonStyle())
            
        }
    }
}

#if DEBUG
struct RadioButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            RadioButton(
                isChecked: true,
                text:"asdafafsd"
            )
            .frame( alignment: .center)
            .background(Color.brand.bg)
        }
        
    }
}
#endif


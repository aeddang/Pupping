//
//  MoreButton.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/18.
//
import Foundation
import SwiftUI
struct MoreButton: View{
    var text:String? = String.button.more
    let action: () -> Void
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HStack(alignment: .center, spacing: Dimen.margin.thin){
                if let text = self.text {
                    Text(text).modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.greyExtra))
                }
                Image(Asset.icon.go)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regularExtra,
                           height: Dimen.icon.regularExtra)
            }
        }
    }
}
#if DEBUG
struct MoreButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            MoreButton()
            {
                
            }
            .frame( width:300, alignment: .center)
            
        }
    }
}
#endif


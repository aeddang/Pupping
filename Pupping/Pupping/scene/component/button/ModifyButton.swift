//
//  ModifyButton.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/20.
//

//
//  MoreButton.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/18.
//
import Foundation
import SwiftUI
struct ModifyButton: View{
    
    let action: () -> Void
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(Asset.icon.modify)
                .resizable()
                .scaledToFit()
                .frame(width: Dimen.icon.regularExtra,
                       height: Dimen.icon.regularExtra)
        }
    }
}
#if DEBUG
struct ModifyButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ModifyButton()
            {
                
            }
            .frame( width:300, alignment: .center)
            
        }
    }
}
#endif

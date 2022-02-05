//
//  TitleTab.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/20.
//

//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI



struct EmptyInfo: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var text:String? = String.alert.dataError
    var action: (() -> Void)? = nil
   
    var body: some View {
        VStack(spacing:Dimen.margin.thin){
            Image(Asset.icon.warning)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.app.greyExtra)
                .frame(width: Dimen.icon.heavy,
                       height: Dimen.icon.heavy)
            if let text = self.text {
                Text(text).modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.greyExtra))
            }
        }
        .modifier(MatchParent())
    }
}

#if DEBUG
struct EmptyInfo_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            EmptyInfo()
                .environmentObject(PagePresenter()).frame(width:320,height:100)
                
        }
    }
}
#endif


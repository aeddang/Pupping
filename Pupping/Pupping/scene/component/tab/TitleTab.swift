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

extension TitleTab{
    enum ButtonType {
        case none, more, add, modify
    }
}


struct TitleTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var title:String
    var type:ButtonType = .none
    var action: (() -> Void)? = nil
   
    var body: some View {
        HStack(alignment: .center, spacing: 0){
            Text(self.title)
                .modifier(ContentTitle())
                .fixedSize(horizontal: true, vertical: false)
            Spacer()
            switch self.type {
            case .more :
                MoreButton(){action?()}
            case .add :
                AddedButton(){action?()}
            case .modify :
                ModifyButton(){action?()}
            case .none :
                Spacer()
            }
        }
    }
}

#if DEBUG
struct TitleTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            TitleTab(title: "title")
                .environmentObject(PagePresenter()).frame(width:320,height:100)
                
        }
    }
}
#endif


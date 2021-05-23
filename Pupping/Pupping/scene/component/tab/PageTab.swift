//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI



struct PageTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var title:String? = nil
    var isBack:Bool = false
    var isClose:Bool = false
    var isSetting:Bool = false
     
    var body: some View {
        ZStack(alignment: .leading){
            if self.title != nil {
                Text(self.title!)
                    .modifier(PageTitle())
                    .lineLimit(1)
                    .modifier(ContentHorizontalEdges())
                    .frame(maxWidth: .infinity)
                    .padding(.top, 1)
                    .padding(.horizontal, Dimen.icon.regular)
            }
            HStack{
                if self.isBack {
                    Button(action: {
                        self.pagePresenter.goBack()
                    }) {
                        Image(Asset.icon.back)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.app.greyDeep)
                            .frame(width: Dimen.icon.thin,
                                   height: Dimen.icon.thin)
                    }
                }
                Spacer()
                if self.isClose {
                    Button(action: {
                        self.pagePresenter.goBack()
                    }) {
                        Image(Asset.icon.close)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.app.greyDeep)
                            .frame(width: Dimen.icon.thin,
                                   height: Dimen.icon.thin)
                    }
                }
                if self.isSetting {
                    Button(action: {
                        
                    }) {
                        Image(Asset.icon.setting)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.app.greyDeep)
                            .frame(width: Dimen.icon.light,
                                   height: Dimen.icon.light)
                    }
                }
            }
            .modifier(ContentHorizontalEdges())
            
        }
        .modifier(MatchHorizontal(height: Dimen.app.top))
        .background(Color.brand.bg)
    }
}

#if DEBUG
struct PageTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            PageTab(title: "title")
                .environmentObject(PagePresenter()).frame(width:320,height:100)
                
        }
    }
}
#endif

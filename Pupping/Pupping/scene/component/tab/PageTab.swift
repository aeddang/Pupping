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
    var profile:String? = nil
    var isBack:Bool = false
    var isClose:Bool = false
    var isSetting:Bool = false
    var confirm: (() -> Void)? = nil
   
    var body: some View {
        ZStack(alignment: .leading){
            HStack(spacing:Dimen.margin.thin){
                if self.isBack {
                    Button(action: {
                        if let confirm = self.confirm {
                            confirm()
                        } else {
                            self.pagePresenter.goBack()
                        }
                        
                    }) {
                        Image(Asset.icon.back)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.app.greyDeep)
                            .frame(width: Dimen.icon.regularExtra,
                                   height: Dimen.icon.regularExtra)
                    }
                }
                if self.title != nil {
                    Text(self.title!)
                        .modifier(PageTitle())
                        .lineLimit(1)
            
                }
                Spacer()
                if self.isClose {
                    Button(action: {
                        if let confirm = self.confirm {
                            confirm()
                        } else {
                            self.pagePresenter.goBack()
                        }
                        
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
                if let profile = self.profile{
                    Image(profile)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regular,
                               height: Dimen.icon.regular)
                        .clipShape(Circle())
                }
                if self.isSetting {
                    Button(action: {
                        
                    }) {
                        Image(Asset.icon.setting)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.app.grey)
                            .frame(width: Dimen.icon.regular,
                                   height: Dimen.icon.regular)
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
            PageTab(title: "title", isBack: true, isClose: true, isSetting: true)
                .environmentObject(PagePresenter()).frame(width:320,height:100)
                
        }
    }
}
#endif

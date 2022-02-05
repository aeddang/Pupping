//
//  ImageView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct ValueBox : PageComponent {
    var title:String? = nil
    var icon:String? = nil
    var iconColor:Color? = nil
    var value:String
    var color:Color? = Color.app.whiteDeep
    var alignment:HorizontalAlignment = .center
    var body: some View {
        HStack(spacing:0){
            VStack(alignment:self.alignment,spacing:Dimen.margin.thinExtra){
                if let icon = self.icon {
                    if let col = self.iconColor {
                        Image(icon)
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(col)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimen.icon.regularExtra, height: Dimen.icon.regularExtra)
                    } else {
                        Image(icon)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimen.icon.regularExtra, height: Dimen.icon.regularExtra)
                    }
                    
                }
                if let title = self.title {
                    Text(title)
                        .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.app.grey))
                        .multilineTextAlignment(.center)
                }
                    
                Text(self.value)
                    .modifier(BoldTextStyle(size: Font.size.light, color: Color.app.greyDeep))
                    .multilineTextAlignment(.center)
                
            }
            .padding(.all, self.color == nil ? Dimen.margin.thin : 0)
            if self.alignment == .leading {
                Spacer()
            }
        }
        .modifier(MatchHorizontal(height:80))
        .background(self.color ?? Color.transparent.clear)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
    }
}

#if DEBUG
struct ValueBox_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            ValueBox(
                title: "test", 
                value: "10")
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter())
            .frame(width: 375, height: 640)
        }
    }
}
#endif

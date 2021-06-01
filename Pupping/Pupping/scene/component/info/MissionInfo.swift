//
//  ImageView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps
import struct Kingfisher.KFImage
struct MissionInfo : PageComponent {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
   
    let data:Mission
     
    var body: some View {
        VStack(alignment: .leading, spacing:Dimen.margin.thin){
            HStack(spacing:Dimen.margin.thin){
                Image(Asset.icon.flag)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(data.type == .today ? Color.brand.primary : Color.app.greyDeep)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                Text(data.type.info())
                    .modifier(BoldTextStyle(
                        size: Font.size.light,
                        color: Color.brand.primary
                    ))
            }
            VStack(alignment: .leading, spacing:Dimen.margin.tinyExtra){
                Text(data.description)
                    .modifier(RegularTextStyle(
                        size: Font.size.thin,
                        color: Color.app.grey
                    ))
                HStack(spacing:Dimen.margin.tiny){
                    Text(data.lv.info())
                        .modifier(LightTextStyle(
                            size: Font.size.tiny,
                            color: data.lv == .lv3 || data.lv == .lv4
                                ? Color.brand.thirdly : Color.brand.fourth
                        ))
                    Circle()
                        .frame(width: Dimen.circle.thin, height: Dimen.circle.thin)
                        .background(Color.app.grey)
                    Text(data.viewDuration)
                        .modifier(LightTextStyle(
                            size: Font.size.tiny,
                            color: Color.app.grey
                        ))
                    Circle()
                        .frame(width: Dimen.circle.thin, height: Dimen.circle.thin)
                        .background(Color.app.grey)
                    
                    Text(data.viewSpeed)
                        .modifier(LightTextStyle(
                            size: Font.size.tiny,
                            color: Color.app.grey
                        ))
                    Circle()
                        .frame(width: Dimen.circle.thin, height: Dimen.circle.thin)
                        .background(Color.app.grey)
                    
                    Text(data.viewDistence)
                        .modifier(LightTextStyle(
                            size: Font.size.tiny,
                            color: Color.app.greyDeep
                        ))
                    
                }
            }
            Spacer().modifier(MatchHorizontal(height: 0))
        }
        .modifier(ContentTab())
        .onAppear(){
            
        }
    }
}



#if DEBUG
struct MissionInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            MissionInfo(
                data: Mission(type: .always, playType: .speed, lv: .lv1).build()
            )
            .environmentObject(AppSceneObserver())
            .environmentObject(DataProvider())
            .environmentObject(LocationObserver())
            .frame(width: 375, height: 640)
        }
    }
}
#endif

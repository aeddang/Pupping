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
extension MissionInfo {
    static let pointBoxSize:CGFloat = 60
}

struct MissionInfo : PageComponent {
    enum UiType{
        case simple, normal
    }
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    let data:Mission
    var isPlay:Bool = false
    var uiType:UiType = .normal
    var body: some View {
        ZStack(alignment: .topTrailing){
            if isPlay {
                VStack(spacing:Dimen.margin.micro) {
                    Image(Asset.icon.point)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    Text("20")
                        .modifier(MediumTextStyle(
                            size: Font.size.tinyExtra,
                            color: Color.app.grey
                        ))
                }
                .frame(width: Self.pointBoxSize, height: Self.pointBoxSize)
                .background(Color.app.greyLightExtra)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
        
            }
            VStack(alignment: .leading, spacing:0){
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
                .padding(.trailing, self.isPlay ? Self.pointBoxSize : 0)
                if self.uiType == .normal {
                    VStack(alignment: .leading, spacing:Dimen.margin.tinyExtra){
                        Text(data.description)
                            .modifier(RegularTextStyle(
                                size: Font.size.thin,
                                color: Color.app.grey
                            ))
                            .padding(.trailing, self.isPlay ? Self.pointBoxSize : 0)
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
                    .padding(.top, Dimen.margin.tiny)
                } else {
                    Text(data.summary)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin,
                            color: Color.app.grey
                        ))
                        .padding(.trailing, self.isPlay ? Self.pointBoxSize : 0)
                        .padding(.top, Dimen.margin.tiny)
                }
                Spacer().modifier(MatchHorizontal(height: 0))
            }
            .padding(.all, self.uiType == .normal ? Dimen.margin.thin : 0)
        }
        .modifier(ContentTab(margin: Dimen.margin.thin))
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

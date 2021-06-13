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
    static let pointBoxSize:CGFloat = 82
}
struct UnitInfo : View{
    let icon:String
    let text:String
    var color:Color? = Color.app.grey
    var body: some View {
        HStack(spacing:Dimen.margin.micro){
            if let color = self.color {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(color)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.micro, height: Dimen.icon.micro)
            } else {
                Image(icon)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.micro, height: Dimen.icon.micro)
            }
            Text(text)
                .modifier(LightTextStyle(
                    size: Font.size.tinyExtra,
                    color: self.color ?? Color.app.white
                ))
        }
    }
}

struct WayPointInfo : View{
    let icon:String
    let text:String
    var color:Color = Color.app.grey
    var body: some View {
        HStack(spacing:Dimen.margin.thinExtra){
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .foregroundColor(color)
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
            Text(text)
                .modifier(RegularTextStyle(
                    size: Font.size.thinExtra,
                    color: self.color
                ))
        }
    }
}


struct MissionInfo : PageComponent {
    enum UiType{
        case simple, normal
    }
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    let data:Mission
    
    var uiType:UiType = .normal
    var body: some View {
        ZStack(alignment: .topTrailing){
            HStack(spacing:Dimen.margin.thinExtra) {
                Image(Asset.icon.point)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.mediumExtra, height: Dimen.icon.mediumExtra)
                Text(self.data.lv.point().toInt().description)
                    .modifier(MediumTextStyle(
                        size: Font.size.tinyExtra,
                        color: Color.app.grey
                    ))
            }
            .padding(.all, Dimen.margin.tiny)
            .frame(width: Self.pointBoxSize)
            .background(Color.app.white)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: Dimen.radius.regularExtra)
                    .stroke(Color.app.greyLight, lineWidth: Dimen.stroke.light)
            )
            
            VStack(alignment: .leading, spacing:0){
                HStack(spacing:Dimen.margin.thin){
                    Image(Asset.icon.flag)
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(Color.app.greyDeep)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                    Text(data.type.info())
                        .modifier(BoldTextStyle(
                            size: Font.size.light,
                            color: Color.app.greyDeep
                        ))
                }
                .padding(.trailing, Self.pointBoxSize )
                UnitInfo(icon: data.lv.icon(), text: data.lv.info(), color: data.lv.color())
                    .padding(.top, Dimen.margin.micro)
                
                if self.uiType == .normal {
                    VStack(alignment: .leading, spacing:Dimen.margin.light){
                        if let destination = data.destination {
                            VStack(alignment: .leading, spacing:0){
                                ForEach( Array(data.waypoints.enumerated()), id: \.offset){idx,  point in
                                    WayPointInfo(icon: Asset.icon.wayPointHeader, text: point.name ?? "", color: Color.app.grey)
                                    ZStack{
                                        Spacer()
                                            .frame(width: 1 , height: 14)
                                            .background(
                                                idx == data.waypoints.count-1 ? Color.brand.primary : Color.app.grey)
                                            
                                    }
                                    .frame(width: 1 , height: 10)
                                    .padding(.leading, floor(Dimen.icon.tiny/2)-1)
                                }
                                WayPointInfo(icon: Asset.icon.destinationHeader, text: destination.name ?? "", color: Color.brand.primary)
                                
                                
                            }
                        }
                        HStack(spacing:Dimen.margin.tiny){
                            UnitInfo(icon: Asset.icon.time, text: data.viewDuration)
                            UnitInfo(icon: Asset.icon.speed, text: data.viewSpeed)
                            UnitInfo(icon: Asset.icon.distence, text: data.viewDistence)
                        }
                    }
                    .padding(.top, Dimen.margin.light)
                } else {
                    Text(data.summary)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin,
                            color: Color.app.grey
                        ))
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

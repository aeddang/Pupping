//
//  PlayMissionInfo.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/11.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps



extension PlayMissionInfo {
    static let pointBoxSize:CGFloat = 82
}
struct PlayMissionInfo : PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var viewModel:PlayWalkModel = PlayWalkModel()
    let data:Mission
    var uiType:MissionInfo.UiType = .normal
    @State var currentCompletedStep:Int = -1
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
            
            
            VStack(alignment: .leading, spacing:0){
                HStack(spacing:Dimen.margin.micro){
                    Image(Asset.icon.flag)
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(Color.app.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                    Text(data.type.info())
                        .modifier(BoldTextStyle(
                            size: Font.size.light,
                            color: Color.app.white
                        ))
                }
                .padding(.trailing, Self.pointBoxSize )
                UnitInfo(icon: data.lv.icon(), text: data.lv.info(), color: nil)
                    .padding(.top, Dimen.margin.micro)
                
                if self.uiType == .normal {
                    VStack(alignment: .leading, spacing:Dimen.margin.light){
                        if let destination = data.destination {
                            VStack(alignment: .leading, spacing:0){
                                ForEach( Array(data.waypoints.enumerated()), id: \.offset){idx,  point in
                                    WayPointInfo(
                                        icon: self.currentCompletedStep > idx ? Asset.icon.wayPointHeaderOn : Asset.icon.wayPointHeader,
                                        text: point.name ?? "",
                                        color: self.currentCompletedStep > idx ? Color.brand.secondary : Color.app.white)
                                    ZStack{
                                        Spacer()
                                            .frame(width: 1 , height: 14)
                                            .background(
                                                self.currentCompletedStep > (idx+1) ? Color.brand.secondary : Color.app.white)
                                    }
                                    .frame(width: 1 , height: 10)
                                    .padding(.leading, floor(Dimen.icon.tiny/2)-1)
                                }
                                WayPointInfo(
                                    icon: self.currentCompletedStep > data.waypoints.count ? Asset.icon.destinationHeaderOn : Asset.icon.destinationHeader,
                                    text: destination.name ?? "",
                                    color: self.currentCompletedStep > data.waypoints.count ? Color.brand.secondary : Color.app.white)
                                   
                                
                            }
                        }
                        HStack(spacing:Dimen.margin.tiny){
                            PlayUnitInfo(icon: Asset.icon.time, text: data.viewDuration)
                                .modifier(MatchHorizontal(height: 60))
                            PlayUnitInfo(icon: Asset.icon.speed, text: data.viewSpeed)
                                .modifier(MatchHorizontal(height: 60))
                            PlayUnitInfo(icon: Asset.icon.distence, text: data.viewDistence)
                                .modifier(MatchHorizontal(height: 60))
                        }
                        .padding(.all, Dimen.margin.thin)
                        .background(Color.app.white)
                        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                    }
                    .padding(.top, Dimen.margin.light)
                } else {
                    Text(data.summary)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin,
                            color: Color.app.white
                        ))
                        .padding(.top, Dimen.margin.tiny)
                }
                Spacer().modifier(MatchHorizontal(height: 0))
            }
           
        }
        .modifier(ContentTab( bgColor: Color.brand.primary))
        .onReceive(self.viewModel.$event) { evt in
            guard let evt = evt  else { return }
            switch evt {
            case .completeStep(let step):
                self.currentCompletedStep = step
                break
            default : break
            }
        }
        .onAppear(){
            
        }
        
    }
}

struct PlayUnitInfo : View{
    let icon:String
    let text:String
    var color:Color? = Color.app.grey
    var body: some View {
        VStack(spacing:Dimen.margin.micro){
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color.app.grey)
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
            Text(text)
                .modifier(RegularTextStyle(
                    size: Font.size.thin,
                    color:  Color.app.grey
                ))
        }
    }
}

#if DEBUG
struct PlayMissionInfo_Previews: PreviewProvider {
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

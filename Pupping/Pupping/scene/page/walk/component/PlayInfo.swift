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


struct PlayInfo : PageComponent {
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var locationObserver:LocationObserver
    
    @ObservedObject var playMissionModel:PlayMissionModel = PlayMissionModel()
    
    
    var profiles:[Profile] = []
    @State var playTime:String = ""
    @State var playDistence:String = ""
    @State var progress:Float = 0
    @State var currentDistence:String? = nil
    @State var currentLocation:String = ""
    var body: some View {
        VStack(spacing:Dimen.margin.thin){
            HStack{
                Text(self.playDistence)
                    .modifier(BoldTextStyle(
                        size: Font.size.bold,
                        color: Color.app.greyDeep
                    ))
                
                Spacer()
                Text(self.playTime)
                    .modifier(SemiBoldTextStyle(
                        size: Font.size.mediumExtra,
                        color: Color.app.greyDeep
                    ))
            }
            HStack(spacing:Dimen.margin.thin){
                ForEach(profiles) { profile in
                    Image(uiImage: profile.image ?? UIImage(named: Asset.brand.logoLauncher)!)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: Dimen.profile.thin, height: Dimen.profile.thin)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        
                }
                Spacer()
                if let currentLocation = self.currentLocation {
                    ZStack{
                        Image(Asset.icon.flag)
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(Color.app.greyDeep)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                    }
                    .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    .background(Color.app.greyLight)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(currentLocation)
                            .modifier(RegularTextStyle(size: Font.size.tiny, color: Color.brand.primary))
                        Text(self.currentDistence ?? "...")
                            .modifier(SemiBoldTextStyle(size: Font.size.tiny, color: Color.app.grey))
                    }
                }
            }
            ProgressSlider(
                progress: self.progress,
                useGesture: false,
                progressHeight: Dimen.line.medium)
                .frame(height:Dimen.line.medium)
            HStack(spacing:Dimen.margin.thin){
                FillButton(
                    text: String.button.next, isSelected:false){ _ in
                    self.playMissionModel.next()
                }
                FillButton(
                    text: String.button.complete, isSelected:true){ _ in
                    self.playMissionModel.complete()
                }
            }
            
        }
        .modifier(BottomFunctionTab())
        .onReceive(self.playMissionModel.$playTime) { time in
            self.playTime = time.secToMinString()
        }
        .onReceive(self.playMissionModel.$playDistence) { distence in
            self.playDistence = distence.toTruncateDecimal(n:1) + String.app.m
        }
        .onReceive(self.playMissionModel.$currentDistenceFromDestination) { distence in
            if let distence = distence {
                self.currentDistence = distence.toTruncateDecimal(n:1) + String.app.m
            } else {
                self.currentDistence = nil
            }
            
        }
        .onReceive(self.playMissionModel.$currentProgress) { progress in
            self.progress = min(progress, 1.0)
        }
        .onReceive(self.playMissionModel.$event) { evt in
            guard let evt = evt  else { return }
            switch evt {
            case .next(_):
                self.currentLocation = self.playMissionModel.currentDestination?.place.name ?? ""
            default : break
            }
        }
        .onAppear(){
           
        }
    }
    
    
    
}



#if DEBUG
struct PlayInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PlayInfo(
                
            )
            .environmentObject(AppSceneObserver())
            .environmentObject(DataProvider())
            .environmentObject(LocationObserver())
            .frame(width: 375, height: 640)
        }
    }
}
#endif

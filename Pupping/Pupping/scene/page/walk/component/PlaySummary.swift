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


struct PlaySummary : PageComponent {
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var locationObserver:LocationObserver
    
    @ObservedObject var playMissionModel:PlayMissionModel = PlayMissionModel()
   
    @State var playTime:String = ""
    @State var playDistence:String = ""
    @State var progress:Float = 0
    
   
    var body: some View {
        VStack(spacing:Dimen.margin.thin) {
            
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
            ProgressSlider(
                progress: self.progress,
                useGesture: false,
                progressHeight: Dimen.line.medium)
                .frame(height:Dimen.line.medium)
            Spacer().modifier(MatchHorizontal(height: 0))
            
        }
        .onReceive(self.playMissionModel.$playTime) { time in
            self.playTime = time.secToMinString()
        }
        .onReceive(self.playMissionModel.$playDistence) { distence in
            self.playDistence = distence.toTruncateDecimal(n:1) + String.app.m
        }
        .onReceive(self.playMissionModel.$currentProgress) { progress in
            self.progress = progress
        }
        .onAppear(){
           
        }
    }
    
    
    
}



#if DEBUG
struct Summary_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PlaySummary(
                
            )
            .environmentObject(AppSceneObserver())
            .environmentObject(DataProvider())
            .environmentObject(LocationObserver())
            .frame(width: 375, height: 640)
        }
    }
}
#endif

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
    
    @ObservedObject var viewModel:PlayWalkModel = PlayWalkModel()
    @State var playTime:String = ""
    @State var playDistence:String = ""
    @State var progress:Float = 0
    @State var currentStatus:PlayMissionStatus = .stop
   
    var body: some View {
        VStack(spacing:Dimen.margin.thin) {
            HStack(spacing:Dimen.margin.thin){
                if self.viewModel.type == .walk && self.currentStatus != .initate {
                    ImageButton(
                        isSelected:self.currentStatus == .play,
                        defaultImage :Asset.icon.pause,
                        activeImage: Asset.icon.resume,
                        defaultColor: Color.app.grey
                        ){ _ in
                        self.viewModel.toggleWalk()
                    }
                }
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
            if self.viewModel.type == .mission {
                ProgressSlider(
                    progress: self.progress,
                    useGesture: false,
                    progressHeight: Dimen.line.medium)
                    .frame(height:Dimen.line.medium)
            }
            Spacer().modifier(MatchHorizontal(height: 0))
            
            
        }
        .onReceive(self.viewModel.$playTime) { time in
            self.playTime = time.secToMinString()
        }
        .onReceive(self.viewModel.$playDistence) { distence in
            self.playDistence = distence.toTruncateDecimal(n:1) + String.app.m
        }
        .onReceive(self.viewModel.$currentProgress) { progress in
            self.progress = progress
        }
        .onReceive(self.viewModel.$status) { status in
            self.currentStatus = status
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

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
    
    @ObservedObject var viewModel:PlayWalkModel = PlayWalkModel()
    
    
    var profiles:[PetProfile] = []
    @State var playTime:String = ""
    @State var playDistence:String = ""
    @State var progress:Float = 0
    @State var currentDistence:String? = nil
    @State var currentLocationName:String? = nil
    @State var currentStatus:PlayMissionStatus = .stop
    @State var currentLocation:CLLocation? = nil
    
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
            .padding(.horizontal,Dimen.margin.regular )
            HStack(spacing:Dimen.margin.tiny){
                ZStack(alignment: .trailing){
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing:Dimen.margin.tiny){
                            ForEach(profiles) { profile in
                                PlayProfileInfo(
                                    data: profile
                                )
                            }
                        }
                        .padding(.horizontal,Dimen.margin.regular)
                    }
                    LinearGradient(
                        gradient:Gradient(colors: [Color.app.white.opacity(0), Color.app.white]),
                        startPoint: .leading, endPoint: .trailing)
                        .frame(width: Dimen.margin.regular, height: Dimen.profile.thin)
                }
                if self.viewModel.type == .mission {
                    ZStack{
                        Image(Asset.icon.flag)
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(Color.app.greyDeep)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                            .onTapGesture {
                                guard let loc = self.currentLocation else {return}
                                self.viewModel.event = .viewPoint(loc)
                            }
                    }
                    .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    .background(Color.app.greyLight)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    VStack(alignment: .leading, spacing: 0) {
                        if let currentLocation = self.currentLocationName {
                            Text(currentLocation)
                                .modifier(RegularTextStyle(size: Font.size.tiny, color: Color.brand.primary))
                        }
                        if let dis = self.currentDistence {
                            Text(dis)
                                .modifier(SemiBoldTextStyle(size: Font.size.tiny, color: Color.app.grey))
                        }
                    }
                }
            }
            .padding(.trailing, Dimen.margin.regular)
            
            if self.viewModel.type == .mission {
                ProgressSlider(
                    progress: self.progress,
                    useGesture: false,
                    progressHeight: Dimen.line.medium)
                    .frame(height:Dimen.line.medium)
                    .padding(.horizontal,Dimen.margin.regular )
                HStack(spacing:Dimen.margin.thin){
                    FillButton(
                        type: .stroke,
                        text:  String.button.next,
                        isSelected:false){ _ in
                        self.viewModel.next()
                    }
                    FillButton(
                        type: .stroke,
                        text: String.button.complete , isSelected:true){ _ in
                        self.viewModel.complete()
                    }
                    .frame(width: 211)
                }
                .padding(.horizontal,Dimen.margin.regular )
            } else {
                HStack(spacing:Dimen.margin.thin){
                    FillButton(
                        type: .stroke,
                        text: self.currentStatus == .play
                            ? String.button.pause : String.button.resume,
                        icon:self.currentStatus == .play
                            ? Asset.icon.resume: Asset.icon.pause,
                        isSelected:false){ _ in
                        self.viewModel.toggleWalk()
                    }
                    FillButton(
                        type: .stroke,
                        text: String.button.stop , isSelected:true){ _ in
                        self.viewModel.complete()
                    }
                    .frame(width: 211)
                }
                .padding(.horizontal,Dimen.margin.regular )
                
            }
            
        }
        .padding(.vertical, Dimen.margin.regular)
        .modifier(BottomFunctionTab(margin:0))
        .onReceive(self.viewModel.$playTime) { time in
            self.playTime = time.secToMinString()
        }
        .onReceive(self.viewModel.$playDistence) { distence in
            self.playDistence = distence.toTruncateDecimal(n:1) + String.app.m
        }
        .onReceive(self.viewModel.$currentDistenceFromDestination) { distence in
            if let distence = distence {
                self.currentDistence = distence.toTruncateDecimal(n:1) + String.app.m
            } else {
                self.currentDistence = nil
            }
            
        }
        .onReceive(self.viewModel.$currentProgress) { progress in
            self.progress = min(progress, 1.0)
        }
        .onReceive(self.viewModel.$status) { status in
            self.currentStatus = status
        }
        .onReceive(self.viewModel.$event) { evt in
            guard let evt = evt  else { return }
            switch evt {
            case .next(_):
                self.currentLocationName = self.viewModel.currentDestination?.place.name
                self.currentLocation = self.viewModel.currentDestination?.location
            default : break
            }
        }
        .onAppear(){
            if self.viewModel.mission?.playType == .location {
                self.currentLocationName = self.viewModel.destinations.first?.place.name
                self.currentLocation = self.viewModel.destinations.first?.location
            } else {
                if let distence = self.viewModel.mission?.totalDistence {
                    self.currentDistence = Mission.viewDistence(distence)
                } else {
                    self.currentDistence = nil
                }
            }
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

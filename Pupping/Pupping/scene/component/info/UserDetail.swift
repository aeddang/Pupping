//
//  ProfileDetail.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/14.
//

import Foundation
import SwiftUI

struct UserDetail: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var profileScrollModel:InfinityScrollModel = InfinityScrollModel()
   
    var user:User
    
    @State var profileHeight:CGFloat = 0
    @State var profileScale:CGFloat = 1.0
    @State var bottomMargin:CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top){
            ZStack{
                Image(uiImage: self.user.currentProfile.image
                      ?? UIImage(named: Asset.brand.logoLauncher)!)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .modifier(MatchHorizontal(height: self.profileHeight * self.profileScale))
                    .onReceive(self.infinityScrollModel.$event){evt in
                        guard let evt = evt else {return}
                        switch evt {
                        case .pullCompleted :break
                        case .pullCancel :
                            withAnimation{ self.profileScale = 1 }
                        default : break
                        }
                        
                    }
                    .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                        self.profileScale = 1.0 + (pos*0.01)
                    }
            }
            .modifier(MatchHorizontal(height: self.profileHeight))
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                scrollType : .reload(isDragEnd: false),
                isRecycle:false,
                useTracking:true)
            {
                VStack(alignment: .leading, spacing: Dimen.margin.regular){
                    VStack(alignment: .leading, spacing: Dimen.margin.tiny){
                        Text(self.user.currentProfile.nickName ?? "")
                             .modifier(BoldTextStyle(
                                 size: Font.size.boldxtra,
                                 color: Color.app.greyDeep
                             ))
                             .padding(.top ,Dimen.margin.regular)
                        HStack(spacing:Dimen.margin.tiny){
                            if let type = self.user.currentProfile.type {
                                Image(uiImage: UIImage(named: type.logo)!)
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                            }
                            if let email = self.user.currentProfile.email {
                                Text(email)
                                    .modifier(MediumTextStyle(
                                        size: Font.size.thin,
                                        color: Color.app.grey
                                    ))
                            }
                        }
                    }
                    .padding(.horizontal ,Dimen.margin.regular)
                    if !self.user.pets.isEmpty {
                        PetList(
                            viewModel:self.profileScrollModel,
                            datas: self.user.pets)
                    }
                
                    HStack{
                        Text(String.pageText.profileWalkHistory)
                            .modifier(ContentTitle())
                        Spacer()
                        Button(action: {
                           
                
                        }) {
                            Image(Asset.icon.calendar)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.brand.fourth)
                                .frame(width: Dimen.icon.regularExtra,
                                       height: Dimen.icon.regularExtra)
                        }
                    }
                    .padding(.horizontal ,Dimen.margin.regular)
                    
                    HStack{
                        Text(String.pageText.profileMissionHistory)
                            .modifier(ContentTitle())
                        Spacer()
                        Button(action: {
                           
                
                        }) {
                            Image(Asset.icon.flag)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.brand.primary)
                                .frame(width: Dimen.icon.regularExtra,
                                       height: Dimen.icon.regularExtra)
                        }
                    }
                    .padding(.horizontal ,Dimen.margin.regular)
                    .padding(.bottom ,Dimen.margin.regular)
                }
                .padding(.bottom,self.bottomMargin)
            }
            .modifier(BottomFunctionTab(margin:0))
            .padding(.top, self.profileHeight - Dimen.margin.mediumExtra)
            .modifier(MatchParent())
            
            HStack{
                Button(action: {
                    self.pagePresenter.goBack()
        
                }) {
                    Image(Asset.icon.back)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regularExtra,
                               height: Dimen.icon.regularExtra)
                }
                Spacer()
               
            }
            .modifier(ContentHorizontalEdges())
            .padding(.top, self.sceneObserver.safeAreaTop + Dimen.margin.regular)
        }
        .modifier(MatchParent())
        .onReceive(self.appSceneObserver.$safeBottomHeight){ height in
            withAnimation{ self.bottomMargin = height }
        }
        .onAppear(){
            guard let imageSize = self.user.currentProfile.image?.size else {return}
            self.profileHeight = min(300, floor(self.sceneObserver.screenSize.width * imageSize.height / imageSize.width))
        }
        
    }
}


#if DEBUG
struct UserDetail_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            UserDetail(
                user: User().setDummy()
            )
            .environmentObject(Repository())
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            .environmentObject(DataProvider())
            .frame(width: 375, height: 640)
        }
    }
}
#endif

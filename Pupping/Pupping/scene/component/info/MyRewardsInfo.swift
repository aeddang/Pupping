//
//  ImageView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct MyRewardsInfo : PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @State var point:Double = 0
    @State var coin:Double = 0
    
   
    var body: some View {
        VStack(alignment:.leading, spacing:Dimen.margin.light){
            Text(String.pageTitle.myRewards)
                .modifier(ContentTitle())
            HStack(spacing:Dimen.margin.lightExtra){
                RewardsItem (
                    title: String.app.point,
                    icon: Asset.icon.point,
                    point: self.point,
                    color: Color.brand.primaryLight)
                
                Image(Asset.shape.spinner)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(self.isSwap ? Color.brand.primary : Color.app.greyDeep)
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    .rotationEffect(.degrees(self.degrees) )
                    .onTapGesture {
                        self.swap()
                    }
                    
                RewardsItem (
                    title: String.app.puppingCoin,
                    icon: Asset.icon.coin,
                    point: self.coin,
                    color: Color.brand.secondaryExtra)
            }
        }
        
        .onReceive(self.dataProvider.user.$coin){ coin in
            self.coin = coin
        }
        .onReceive(self.dataProvider.user.$point){ point in
            self.point = point
        }
    }
    
    @State var degrees:Double = 0
    @State var isSwap:Bool = false
    func swap(){
        if self.point == 0 {
            self.appSceneObserver.event = .toast(String.alert.pointEmpty)
            return
        }
        
        self.dataProvider.user.swapCoin()
        withAnimation{
            self.isSwap = true
            self.degrees = self.degrees == 0 ? 360 : 0
        }
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
            DispatchQueue.main.async {
                withAnimation {self.isSwap = false}
                self.appSceneObserver.event = .toast(String.alert.coinSwap)
            }
        }
        
    }
}


struct RewardsItem : PageComponent {
    var title:String
    var icon:String
    var point:Double
    var color:Color
    
    var body: some View {
        VStack(alignment:.leading,spacing:Dimen.margin.thinExtra){
            HStack(alignment:.top, spacing:Dimen.margin.thinExtra){
                Image(self.icon)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.mediumExtra, height: Dimen.icon.mediumExtra)
                Text(self.point.formatted(style: .decimal))
                    .modifier(BoldTextStyle(size: Font.size.mediumExtra, color: Color.app.white))
                Spacer()
            }
            Text(self.title)
                .modifier(RegularTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                .padding(.leading, Dimen.margin.thinExtra)
            
        }
        .padding(.all, Dimen.margin.thin)
        .modifier(MatchHorizontal(height:86))
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
    }
}

#if DEBUG
struct MyRewardsInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            MyRewardsInfo()
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter())
            .frame(width: 375, height: 640)
        }
    }
}
#endif

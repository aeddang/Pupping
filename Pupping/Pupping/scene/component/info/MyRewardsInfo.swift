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
    @State var point:Double = 0
    @State var coin:Double = 0
    @State var mission:Double = 0
   
    var body: some View {
        
        VStack(alignment:.leading, spacing:Dimen.margin.regular){
            Text(String.pageTitle.myRewards)
                .modifier(ContentTitle())
            HStack(spacing:Dimen.margin.thin){
                RewardsItem (
                    title: String.app.point,
                    icon: Asset.icon.point,
                    point: self.point,
                    color: Color.brand.primary)
                RewardsItem (
                    title: String.app.puppingCoin,
                    icon: Asset.icon.pupping,
                    point: self.coin,
                    color: Color.brand.secondary)
                RewardsItem (
                    title: String.app.completeMission,
                    icon: Asset.gnb.mission,
                    point: self.mission,
                    color: Color.app.grey)
            }
        }
        
        .onReceive(self.dataProvider.user.$coin){ coin in
            self.coin = coin
        }
        .onReceive(self.dataProvider.user.$point){ point in
            self.point = point
        }
        .onReceive(self.dataProvider.user.$mission){ mission in
            self.mission = mission
        }
    }
}


struct RewardsItem : PageComponent {
    var title:String
    var icon:String
    var point:Double
    var color:Color
    
    var body: some View {
        VStack(alignment:.leading,spacing:Dimen.margin.light){
            HStack(alignment:.top, spacing:Dimen.margin.tiny){
                Image(self.icon)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                Text(self.title)
                    .modifier(RegularTextStyle(size: Font.size.thinExtra, color: Color.app.grey))
            }
            .frame( height: 50 )
            ZStack{
                Text(self.point.formatted(style: .decimal))
                    .modifier(RegularTextStyle(size: Font.size.mediumExtra, color: self.color))
            }
            .modifier(MatchHorizontal(height: Dimen.tab.light))
            .background(self.color.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.lightExtra))
        }
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

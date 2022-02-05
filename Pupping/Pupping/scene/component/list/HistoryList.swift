//
//  PetList.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/13.
//

import Foundation
import SwiftUI

class History:InfinityData {
   
    private(set) var missionId: Int? = nil
    private(set) var category: String? = nil
    private(set) var title: String? = nil
    private(set) var imagePath: String? = nil
    private(set) var description: String? = nil
    private(set) var date: String? = nil
    private(set) var duration: Double? = nil
    private(set) var distance: Double? = nil
    private(set) var point: Double? = nil
    private(set) var lv:MissionLv? = nil
    private(set) var missionCategory:MissionApi.Category? = nil
    init(data:MissionData, idx:Int = 0){
        super.init()
        self.missionCategory = MissionApi.Category.getCategory(data.missionCategory)
        self.missionId = data.missionId
        self.title = data.title
        self.imagePath = data.pictureUrl
        self.description = data.description
        self.lv = MissionLv.getMissionLv(data.difficulty)
        self.duration = data.duration
        self.distance = data.distance
        self.point = data.point ?? 0.0
        self.date = data.createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")?.toDateFormatter(dateFormat: "yy-MM-dd HH:mm")
        self.index = idx
    }
}

extension HistoryList{
    static let height:CGFloat = 224
}

struct HistoryList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[History]
    var onBottom: ((_ data:History) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            scrollType : .reload(isDragEnd: false),
            marginVertical: Dimen.margin.light,
            marginHorizontal: 0,
            spacing: 0,
            isRecycle: true,
            useTracking: true
        ){
            ForEach(self.datas) { data in
                HistoryListItem(data: data )
                    .modifier(ListRowInset(marginHorizontal: Dimen.margin.thin ,spacing: Dimen.margin.thin))
                    .onTapGesture {
                        /*
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.profile)
                                .addParam(key: .data, value: data)
                        )*/
                    }
                    .onAppear{
                        if data.index == self.datas.last?.index {
                            self.onBottom?(data)
                        }
                    }
            }
        }
    }//body
}


struct HistoryListItem: PageView {
    var data:History
    @State var isExpanded:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.thin){
            HStack( alignment: .top, spacing: Dimen.margin.light){
                ZStack{
                    if let path = self.data.imagePath {
                        ImageView(url: path,
                            contentMode: .fill,
                            noImg: Asset.brand.logoLauncher)
                            .modifier(MatchParent())
                    } else {
                        Image( uiImage: UIImage( named: Asset.brand.logoLauncher)! )
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .modifier(MatchParent())
                    }
                }
                .frame(
                    width: self.isExpanded ? Dimen.profile.heavy : Dimen.profile.regular,
                    height: self.isExpanded ? Dimen.profile.heavy : Dimen.profile.regular)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                
                VStack(alignment: .leading, spacing: 0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    if let title = self.data.title {
                        HStack(alignment: .center){
                            Text(title)
                                .modifier(BoldTextStyle( size: Font.size.light,color: Color.app.black))
                                .multilineTextAlignment(.leading)
                            if let lv = self.data.lv {
                                Image(lv.icon())
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: Dimen.icon.micro, height: Dimen.icon.micro)
                            }
                        }
                    }
                    
                    if let desc = self.data.description {
                        Text(desc)
                            .modifier(LightTextStyle( size: Font.size.thin,color: Color.app.grey))
                            .multilineTextAlignment(.leading)
                            .lineLimit(self.isExpanded ? 999 : 1)
                            .padding(.top, Dimen.margin.tiny)
                    }
                    
                    if let date = self.data.date {
                        Text(date)
                            .modifier(LightTextStyle( size: Font.size.tiny,color: Color.app.grey))
                    }
                    
                }
            }
            if self.isExpanded {
                HStack(spacing:Dimen.margin.tiny){
                    if let value = self.data.duration {
                        PlayUnitInfo(icon: Asset.icon.time, text: Mission.viewDuration(value))
                            .modifier(MatchHorizontal(height: 60))
                    }
                    if let value = self.data.distance {
                        PlayUnitInfo(icon: Asset.icon.distence, text: Mission.viewDuration(value))
                            .modifier(MatchHorizontal(height: 60))
                    }
                    if let value = self.data.point {
                        PlayUnitInfo(icon: Asset.icon.point, isOrigin: true, text: value.description)
                            .modifier(MatchHorizontal(height: 60))
                    }
                   
                }
                .padding(.all, Dimen.margin.thin)
                .background(Color.app.whiteDeep)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
            }
        }
        .modifier(MatchParent())
        .modifier(ContentTab(margin: Dimen.margin.tiny))
        .onTapGesture {
            withAnimation{
                self.isExpanded.toggle()
            }
        }
        .onAppear{
            self.isExpanded = false
        }
        
    }
}

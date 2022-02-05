//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

class ReportData {
    private(set) var daysWalkData:ArcGraphData = ArcGraphData()
    private(set) var daysWalkReport:String = ""
    private(set) var daysWalkCompareData:[CompareGraphData]
    = [
        CompareGraphData(value:1, color:Color.brand.primary, title:String.pageText.reportWalkDayCompareMe),
        CompareGraphData(value:2, color:Color.app.grey, title:String.pageText.reportWalkDayCompareOthers)
    ]
    private(set) var daysWalkCompareReport:String = ""
    private(set) var daysWalkTimeData:LineGraphData = LineGraphData()
    private(set) var currentDaysWalkTimeIdx:Int = 0
    private(set) var daysWalkTimeReport:String = ""
    
    
    func seupData(){
        self.daysWalkReport = Int(daysWalkData.value).description + " " + String.pageText.reportWalkDayUnit
        if daysWalkCompareData.count >= 2 {
            let me = daysWalkCompareData.first!.value
            let other = daysWalkCompareData.last!.value
            let diff = me - other
            if diff > 0 {
                self.daysWalkCompareReport = diff.description + String.pageText.reportWalkDayUnit + " " + String.pageText.reportWalkDayCompareMore
            } else if diff < 0 {
                self.daysWalkCompareReport = abs(diff).description + String.pageText.reportWalkDayUnit + " " + String.pageText.reportWalkDayCompareLess
            } else {
                self.daysWalkCompareReport = String.pageText.reportWalkDayCompareSame
            }
        }
        let avg = self.daysWalkTimeData.values.reduce(Float(0), {$0 + $1}) / Float(self.daysWalkTimeData.values.count) * 50.0
        self.daysWalkTimeReport = Double(avg).toTruncateDecimal(n:2) + " " + String.pageText.reportWalkRecentlyUnit
    }
    
    func setDummyWeekly() -> ReportData{
        self.daysWalkData = ArcGraphData()
        self.daysWalkCompareData
        = [
            CompareGraphData(value:1, color:Color.brand.primary, title:String.pageText.reportWalkDayCompareMe),
            CompareGraphData(value:2, color:Color.app.grey, title:String.pageText.reportWalkDayCompareOthers)
        ]
        self.daysWalkTimeData = LineGraphData()
        self.currentDaysWalkTimeIdx = 2
        self.seupData()
        return self
    }
    func setDummyMonthly() -> ReportData{
        self.daysWalkData = ArcGraphData(value: 10, max: 31)
        self.daysWalkCompareData
        = [
            CompareGraphData(value:1, max:31,color:Color.brand.primary, title:String.pageText.reportWalkDayCompareMe),
            CompareGraphData(value:2, max:31, color:Color.app.grey, title:String.pageText.reportWalkDayCompareOthers)
        ]
        let values:[Float] = (0...31).map{ _ in
            return Float(arc4random() % 100) / 100
        }
        self.daysWalkTimeData = LineGraphData(values: values, lines: values.map{$0.description})
        self.currentDaysWalkTimeIdx = 5
        self.seupData()
        return self
    }
}

extension PageReport{
    enum ReportType{
        case weekly, monthly
    }
}

struct PageReport: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
   
    @State var profile:PetProfile? = PetProfile().setDummy()
    @State var userId:String? = nil
    @State var selectedMenu:Int = 0
    @State var isUiReady:Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(alignment: .topLeading){
                    VStack(spacing:0){
                        PageTab(
                            isBack:true
                        )
                        .padding(.top, self.sceneObserver.safeAreaTop)
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            scrollType : .vertical(isDragEnd: false),
                            isRecycle:false,
                            useTracking:false)
                        {
                            HStack(spacing: Dimen.margin.thin){
                                Image(Asset.icon.report)
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Dimen.icon.heavyLight,
                                           height: Dimen.icon.heavyLight)
                                VStack(alignment: .leading, spacing: 0){
                                    Spacer().modifier(MatchHorizontal(height: 0))
                                    if let nickName = self.profile?.nickName {
                                        Text(nickName + String.app.owner )
                                            .modifier(RegularTextStyle(size: Font.size.thin, color: Color.app.grey))
                                    }
                                    Text(String.pageTitle.walkReport)
                                        .modifier(BoldTextStyle(size: Font.size.medium, color: Color.app.greyDeep))
                                }
                            }
                            .modifier(ContentHorizontalEdges())
                            .padding(.top, Dimen.margin.medium)
                            
                            
                            VStack(alignment: .leading, spacing: Dimen.margin.medium){
                                HStack(spacing: Dimen.margin.thin){
                                    if let value = self.profile?.totalExerciseDuration {
                                        ValueBox(
                                            title: String.pageText.reportWalkSummaryDuration,
                                            icon: Asset.icon.time,
                                            iconColor: Color.brand.primary,
                                            value: Mission.viewDuration(value),
                                            alignment: .leading)
                                    }
                                    if let value = self.profile?.totalExerciseDistance {
                                        ValueBox(
                                            title: String.pageText.reportWalkSummaryDistance,
                                            icon: Asset.icon.walk,
                                            iconColor: Color.brand.primary,
                                            value: Mission.viewDistence(value),
                                            alignment: .leading)
                                    }
                                }
                                
                                Spacer().modifier(LineHorizontal())
                                    
                                Text(String.pageTitle.walkReport)
                                    .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.grey))
                                MenuTab(
                                    pageObservable:self.pageObservable,
                                    viewModel:self.navigationModel,
                                    buttons: [
                                        String.pageText.reportWalkSummaryWeekly, String.pageText.reportWalkSummaryMonthly
                                    ],
                                    selectedIdx: self.selectedMenu
                                )
                                .onReceive(self.navigationModel.$index){ idx in
                                    self.selectedMenu = idx
                                    self.load()
                                }
                                if let data = self.reportData {
                                    VStack(alignment: .leading, spacing: Dimen.margin.mediumUltra){
                                        VStack(alignment: .center, spacing: Dimen.margin.regular){
                                            ReportText(
                                                leading: String.pageText.reportWalkDayText,
                                                value: data.daysWalkReport,
                                                trailing: self.reportType == .weekly ? String.pageText.reportWalkDayWeek : String.pageText.reportWalkDayMonth)
                                            ArcGraph(data: data.daysWalkData,
                                                     innerCircleColor:Color.app.whiteDeep)
                                        }
                                        Spacer().modifier(LineHorizontal())
                                        VStack(alignment: .leading, spacing: Dimen.margin.regular){
                                            ReportText(
                                                leading: String.pageText.reportWalkDayCompareText1,
                                                value: data.daysWalkCompareReport,
                                                trailing: String.pageText.reportWalkDayCompareText2)
                                            CompareGraph(datas: data.daysWalkCompareData)
                                        }
                                        Spacer().modifier(LineHorizontal())
                                        VStack(alignment: .leading, spacing: Dimen.margin.regular){
                                            ReportText(
                                                leading: String.pageText.reportWalkRecentlyText1,
                                                value: data.daysWalkTimeReport,
                                                trailing: String.pageText.reportWalkRecentlyText2)
                                            LineGraph(selectIdx: data.currentDaysWalkTimeIdx, data: data.daysWalkTimeData)
                                            Text(String.pageText.reportWalkRecentlyTip)
                                                .modifier(BoldTextStyle(size: Font.size.thin, color: Color.app.grey))
                                        }
                                    }
                                } else {
                                    Spacer()
                                }
                                
                            }
                            .modifier(ContentHorizontalEdges())
                            .padding(.vertical, Dimen.margin.regular + self.sceneObserver.safeAreaBottom)
                        }
                    }
                    
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                .onReceive(self.pageDragingModel.$nestedScrollEvent){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCompleted :
                        self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                    case .pullCancel :
                        self.pageDragingModel.uiEvent = .pullCancel(geometry)
                    case .pull(let pos) :
                        self.pageDragingModel.uiEvent = .pull(geometry, pos)
                    default: break
                    }
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isUiReady = true
                    self.load()
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                guard let profile = obj.getParamValue(key: .data) as? PetProfile else { return }
                if let userId = obj.getParamValue(key: .id) as? String {
                    self.userId = userId
                }
                self.profile = profile
            }
        }//geo
    }//body
   
    @State var reportType:ReportType = .weekly
    @State var reportData:ReportData? = nil
    
    func load(){
        if !self.isUiReady {return}
        self.reportData = nil
        if self.selectedMenu == 0 {
            self.reportType = .weekly
            withAnimation{
                self.reportData = ReportData().setDummyWeekly()
            }
        } else {
            self.reportType = .monthly
            withAnimation{
                self.reportData = ReportData().setDummyMonthly()
            }
        }
    }
    
}


#if DEBUG
struct PageReport_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageReport().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

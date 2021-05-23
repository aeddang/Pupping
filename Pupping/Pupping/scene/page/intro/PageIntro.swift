//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//
import Foundation
import SwiftUI



struct PageIntro: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @State var index: Int = 0
   
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing:0){
                Text("intro")
            }
        }//geo
        .modifier(PageFull())
        .onAppear{
            
        }
    }//body
}


#if DEBUG
struct PageIntro_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageIntro().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(Repository())
                .frame(width: 325, height: 640, alignment: .center)
        }
    }
}
#endif


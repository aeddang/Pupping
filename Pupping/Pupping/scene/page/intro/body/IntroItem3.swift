//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//
import Foundation
import SwiftUI

struct IntroItem3: PageComponent, Identifiable {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    let id = UUID().uuidString
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack{
                Image(Asset.image.womanWithDog)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 211, height: 229)
                    .padding(.leading, -15)
                    .padding(.top, Dimen.margin.medium)
                Spacer()
            }
            ZStack(alignment: .bottomTrailing){
                Image(Asset.image.manWithDog)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, Dimen.margin.medium)
                    .frame(width: 371, height: 302)
                    .padding(.trailing, -60)
                    .padding(.bottom, 55)
                VStack(alignment: .leading, spacing: Dimen.margin.regular){
                    Text(String.pageText.introText3_1)
                        .modifier(RegularTextStyle(size: Font.size.medium, color: Color.app.greyDeep))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(String.pageText.introText3_2)
                        .modifier(RegularTextStyle(size: Font.size.lightExtra, color: Color.app.greyDeep))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer().modifier(MatchParent())
                }
                .padding(.leading, Dimen.margin.regular)
            }
            Spacer().frame(height: Dimen.margin.heavy)
        }
        .modifier(MatchParent())
        .background(Color.brand.secondaryExtra)
    }
}




#if DEBUG
struct IntroItem3_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            IntroItem3().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .frame(width: 325, height: 640, alignment: .center)
        }
    }
}
#endif


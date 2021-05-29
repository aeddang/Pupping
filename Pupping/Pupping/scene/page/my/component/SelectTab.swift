//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI

struct SelectData: Identifiable {
    var id:String = UUID().uuidString
    var idx = -1
    var image:String? = nil
    var text:String? = nil
    var color:Color = Color.app.white
}

struct SelectTab: PageComponent{

    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    var data:InputData
    @State var selectedIdx:Int = -1
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        VStack (alignment: .center, spacing: 0){
            if let title = self.data.title {
                Text(title)
                    .modifier(SemiBoldTextStyle(size: Font.size.medium, color: Color.app.greyDeep))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            HStack(spacing:Dimen.margin.lightExtra){
                ForEach(self.data.tabs) { tab in
                    Button(action: {
                        self.selectedIdx = tab.idx
                        self.action(tab.idx)
                    }) {
                        ZStack{
                            VStack(spacing:Dimen.margin.light){
                                if let image = tab.image {
                                    Image(image)
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundColor(
                                            self.selectedIdx != tab.idx
                                                ? tab.color : Color.app.white)
                                        
                                        .scaledToFit()
                                        .frame(width:50, height:Dimen.icon.heavy )
                                }
                                if let text = tab.text {
                                    Text(text)
                                        .modifier(
                                            SemiBoldTextStyle(
                                                size: Font.size.regularExtra,
                                                color: self.selectedIdx == tab.idx
                                                    ? Color.app.white : Color.app.greyDeep))
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        .modifier( MatchParent() )
                        .background(self.selectedIdx == tab.idx ? tab.color : Color.app.white )
                        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.lightExtra))
                        .modifier(Shadow())
                    }
                }
            }
            .frame(height:182)
            Spacer()
        }
        .onAppear(){
            self.selectedIdx = self.data.selectedIdx
        }
    }//body
    
    
}


#if DEBUG
struct SelectTab_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SelectTab(
                data:InputData(
                    title: "Test",
                    tabs:[
                        .init(
                            idx: 0,
                            image: Asset.icon.mail,
                            text: String.app.mail, color: Color.brand.fourthExtra),
                        .init(
                            idx: 0,
                            image: Asset.icon.femail,
                            text: String.app.femail, color: Color.brand.primary)
                    ])
            ){ _ in
                
            }
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .frame(width:320,height:600)
        }
    }
}
#endif

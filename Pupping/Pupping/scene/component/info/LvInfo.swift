//
//  TitleTab.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/20.
//

//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI
extension LvInfo{
    enum GraphType{
        case circle, progress
    }
}


struct LvInfo: PageComponent{
    @ObservedObject var profile:PetProfile
    let type:GraphType = .circle
    var size:CGFloat = 80
    @State var lv:String = ""
    @State var exp:String = ""
    @State var prevExp:String = ""
    @State var nextExp:String = ""
    @State var progressExp:Float = 0
    var body: some View {
        ZStack{
            if self.type == .progress {
                VStack(spacing: Dimen.margin.micro){
                    HStack{
                        Text(self.lv)
                            .modifier(BoldTextStyle(
                                size: Font.size.thinExtra,
                                color: Color.brand.primary
                            ))
                        Spacer()
                        Text(self.exp)
                            .modifier(MediumTextStyle(
                                size: Font.size.tiny,
                                color: Color.app.greyLight
                            ))
                    }
                    ProgressSlider(progress: self.progressExp, useGesture: false, progressHeight: Dimen.bar.light, thumbSize: 0)
                        .frame(height: Dimen.bar.light)
                        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.micro))
                    
                }
            } else {
                ZStack(alignment: .top){
                    ZStack(alignment: .bottom){
                        GraphArc(progress: self.progressExp, stroke: Dimen.stroke.medium)
                            .frame(width: self.size, height: self.size)
                            .frame(height: self.size/2, alignment: .top)
                            .clipped()
                        HStack{
                            Spacer()
                            Text(self.exp)
                                .modifier(MediumTextStyle(
                                    size: Font.size.micro,
                                    color: Color.app.greyExtra
                                ))
                        }
                        Text(self.lv)
                            .modifier(BoldTextStyle(
                                size: Font.size.light,
                                color: Color.brand.primary
                            ))
                    }
                }
                
            }
        }
        
        .onReceive(self.profile.$lv) { lv in
            self.lv = "Lv." + lv.description
        }
        .onReceive(self.profile.$exp) { exp in
            self.exp = exp.formatted(style: .decimal) + "exp"
        }
        .onReceive(self.profile.$prevExp) { exp in
            self.prevExp = exp.formatted(style: .decimal)
        }
        .onReceive(self.profile.$nextExp) { exp in
            if exp == 0 {return}
            self.nextExp = exp.formatted(style: .decimal)
            let prev = self.profile.prevExp
            withAnimation{
                self.progressExp = Float((self.profile.exp - prev) / (exp - prev))
            }
        }
    }
}

#if DEBUG
struct LvInfo_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            LvInfo(profile: PetProfile().setDummy())
                .environmentObject(PagePresenter()).frame(width:220,height:500)
                
        }
    }
}
#endif


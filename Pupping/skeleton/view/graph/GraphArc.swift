//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct GraphArc: PageView {
    var progress: Float // or some value binded
    var progressColor:Gradient = Gradient(colors: [Color.brand.primary, Color.brand.primaryLight])
    var bgColor:Color = Color.app.greyLight
    var innerCircleColor:Color = Color.app.white
    var stroke:CGFloat = Dimen.stroke.heavy
    var start:CGFloat = 180
    var end:CGFloat = 360
    var body: some View {
        ZStack {
            Spacer()
                .modifier(MatchParent())
                .background(self.bgColor)
                .drawSector(start:self.start, end: self.end)
            ZStack{
                LinearGradient(
                    gradient:self.progressColor,
                    startPoint: .leading, endPoint: .trailing)
                    .modifier(MatchParent())
            }
            .drawSector(
                start: self.start,
                end: self.start + ((self.end - self.start)*CGFloat(self.progress)))
            
            Circle().foregroundColor(self.innerCircleColor).padding(.all, self.stroke)
        }
        .modifier(MatchParent())
    }
}
#if DEBUG
struct GraphArc_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GraphArc(
                progress:  0.8
            )
            .frame(width: 156, height:156)
        }
    }
}
#endif

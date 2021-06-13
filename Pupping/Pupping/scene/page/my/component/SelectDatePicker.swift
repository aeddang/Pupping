//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI
import UIKit


struct SelectDatePicker: PageComponent{
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    var data:InputData
    
    var dateClosedRange: ClosedRange<Date> {
        let startDay = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let now = Date()
        return startDay...now
    }
    
    @State var selectedDate = Date()
    let action: (_ date:Date) -> Void
    
    var body: some View {
        VStack (alignment: .center, spacing: 0){
            if let title = self.data.title {
                Text(title)
                    .modifier(SemiBoldTextStyle(size: Font.size.medium, color: Color.app.greyDeep))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            DatePicker(
                "",
                selection: self.$selectedDate,
                in:dateClosedRange,
                displayedComponents: [.date]
            )
            .labelsHidden()
            .exChangeTextColor(Color.brand.primary)
            .datePickerStyle(WheelDatePickerStyle())
            
            .modifier(MatchParent())
            
        }
        .onReceive( [self.selectedDate].publisher ) { value in
            self.action(value)
        }
        .onAppear(){
            self.selectedDate = data.selectedDate ?? Date()
        }
    }//body

}


#if DEBUG
struct SelectDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SelectDatePicker(
                data:InputData(title: "Test")
            ){ _ in
                
            }
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .frame(width:320,height:600)
        }
    }
}
#endif

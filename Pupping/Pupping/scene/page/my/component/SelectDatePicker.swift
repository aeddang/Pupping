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
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    @State var selectedDate = Date()
    let action: (_ date:Date) -> Void
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0){
            if let title = self.data.title {
                Text(title)
                    .modifier(RegularTextStyle(size: Font.size.light, color: Color.brand.primary))
                    .multilineTextAlignment(.leading)
            }
            DatePicker(
                "",
                selection: self.$selectedDate,
                
                displayedComponents: [.date]
            )
            .datePickerStyle(WheelDatePickerStyle())
            .modifier(MatchParent())
        }
        .onReceive( [self.selectedDate].publisher ) { value in
            if data.selectedDate.timeIntervalSince1970 == value.timeIntervalSince1970 { return }
            self.action(value)
        }
        .onAppear(){
            self.selectedDate = data.selectedDate
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

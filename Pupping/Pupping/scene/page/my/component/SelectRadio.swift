//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI

class RadioData: Identifiable {
    var id:String = UUID().uuidString
    var isCheck:Bool = false
    var text:String? = nil
    init(
        isCheck:Bool = false,
        text:String? = nil
        ) {
        
        self.isCheck = isCheck
        self.text = text
    }
}

struct SelectRadio: PageComponent{

    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var name:String = ""
    var data:InputData
    var margin:CGFloat? = nil
    @State var selected:[RadioData] = []
      
    var body: some View {
        VStack (alignment: .center, spacing: self.margin ?? 0){
            if let title = self.data.title {
                Text(self.name + title)
                    .modifier(SemiBoldTextStyle(size: Font.size.medium, color: Color.app.greyDeep))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if self.margin == nil {
                Spacer()
            }
            TextButton(
                defaultText: String.pageText.profileCheckAll,
                isSelected: false
            ){ _ in
                self.data.checks.forEach{$0.isCheck = true}
                self.selected = self.data.checks
            }
            .padding(.bottom, self.margin == nil ? Dimen.margin.regular : 0)
            
            VStack(spacing:Dimen.margin.lightExtra){
                ForEach(self.data.checks) { check in
                    RadioButton(
                        isChecked: self.selected.first(where:{$0.id == check.id}) != nil ,
                        text:check.text
                    ){ isCheck in
                        if isCheck {
                            self.selected.append(check)
                        } else {
                            guard let fIdx = self.selected.firstIndex(where:{$0.id == check.id}) else {return}
                            self.selected.remove(at: fIdx)
                        }
                        check.isCheck = isCheck
                    }
                    .padding(.horizontal, Dimen.margin.regular)
                    .modifier( MatchHorizontal(height:Dimen.button.medium ) )
                    .background(Color.app.white )
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.lightExtra))
                    .modifier(Shadow())
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            if self.margin == nil {
                Spacer()
            }
        }
        .onAppear(){
            self.selected = self.data.checks.filter{$0.isCheck}.map{$0}
        }
    }//body
    
    
}


#if DEBUG
struct SelectRadio_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SelectRadio(
                data:InputData(
                    title: "Test",
                    checks:[
                        .init(
                            isCheck: true,
                            text: String.app.mail),
                        .init(
                            isCheck: true,
                            text: String.app.femail)
                    ])
            )
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .frame(width:320,height:600)
        }
    }
}
#endif

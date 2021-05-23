import Foundation
import SwiftUI

extension InputCell{
    static var inputFontSize = Font.size.black
    static var inputHeight:CGFloat = inputFontSize
   
}
struct InputCell: PageView {
    var title:String? = nil
    var lineLimited:Int = -1
    @Binding var input:String
    var isFocus:Bool = false
    var placeHolder:String = ""
    var keyboardType:UIKeyboardType = .default
    var tip:String? = nil
    var isEditable:Bool = true
    var isSecure:Bool = false
    @State private var inputHeight:CGFloat = Self.inputHeight
    var actionTitle:String? = nil
    var action:(() -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            if let title = self.title {
                Text(title)
                    .modifier(RegularTextStyle(size: Font.size.light, color: Color.brand.primary))
                    .multilineTextAlignment(.leading)
            }
            HStack(alignment: .top, spacing:0){
                if self.isEditable {
                    if self.lineLimited == -1 {
                        if self.isSecure{
                            SecureField(self.placeHolder, text: self.$input)
                                .keyboardType(self.keyboardType)
                                .modifier(MediumTextStyle(
                                            size: Self.inputFontSize))
                        }else{
                            TextField(self.placeHolder, text: self.$input)
                                .keyboardType(self.keyboardType)
                                .modifier(MediumTextStyle(
                                    size: Self.inputFontSize))
                        }
                        
                    } else {
                        FocusableTextView(
                            placeholder: "",
                            text:self.$input,
                            isfocus: true,
                            textModifier:BoldTextStyle(size: Self.inputFontSize).textModifier,
                            usefocusAble: true,
                            inputChanged: {text , size in
                                //self.input = text
                                //self.inputHeight = min(size.height, (Self.inputHeight * CGFloat(self.lineLimited)))
                            }
                        ).frame(height : Self.inputHeight * CGFloat(self.lineLimited))
                    }
                }else{
                    Text(self.input)
                    .modifier(MediumTextStyle(
                                size: Self.inputFontSize,
                        color: Color.app.greyLight)
                    )
                }
                if self.actionTitle != nil{
                    TextButton(
                        defaultText: self.actionTitle!,
                        textModifier:TextModifier(
                            family:Font.family.medium,
                            size:Font.size.thin,
                            color: Color.brand.primary),
                        isUnderLine: true)
                    {_ in
                        guard let action = self.action else { return }
                        action()
                    }
                }
            }
            .modifier(MatchHorizontal(height: Dimen.tab.regular))
            Spacer().modifier(LineHorizontal(color: self.isFocus ? Color.app.greyDeep : Color.app.grey))
            if self.tip != nil{
                Spacer().frame(height:Dimen.margin.thin)
                Text(self.tip!)
                    .modifier(MediumTextStyle(
                        size: Font.size.thin,
                        color: Color.app.grey))
            }
        }
    }
    
}

#if DEBUG
struct InputCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            InputCell(
                title: "title",
                input: .constant("test"),
                //isFocus: .constant(true),
                tip: "sdsdsdd",
                actionTitle: "btn"
            )
            .environmentObject(PagePresenter()).frame(width:320,height:600)
            .background(Color.brand.bg)
        }
    }
}
#endif


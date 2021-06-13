import Foundation
import SwiftUI

extension InputCell{
    static var inputFontSize = Font.size.regular
    static var inputHeight:CGFloat = inputFontSize
   
}
struct InputCell: PageView {
    var title:String? = nil
    @Binding var input:String
    var lineLimited:Int = -1
    var inputLimited:Int = -1
    var usefocusAble:Bool = true
    var isFocus:Bool = false
    var placeHolder:String = ""
    var keyboardType:UIKeyboardType = .default
    var tip:String? = nil
    var info:String? = nil
    var isEditable:Bool = true
    var isSecure:Bool = false
   
    var actionTitle:String? = nil
    var action:(() -> Void)? = nil
    
    @State private var inputHeight:CGFloat = Self.inputHeight
    @State private var isInputLimited:Bool = false
    var body: some View {
        VStack(alignment: .center, spacing:Dimen.margin.mediumExtra){
            if let title = self.title {
                Text(title)
                    .modifier(SemiBoldTextStyle(size: Font.size.medium, color: Color.app.greyDeep))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if self.isInputLimited ,let tip = self.tip{
                Text(tip)
                    .modifier(MediumTextStyle(
                        size: Font.size.thinExtra,
                                color: Color.brand.thirdly))
                    .padding(.vertical, Dimen.margin.thinExtra)
                    .padding(.horizontal, Dimen.margin.regular)
                    .background(Color.brand.thirdly.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
            }
            HStack(alignment: .center, spacing:Dimen.margin.thin){
                ZStack(alignment: .trailing){
                    if self.isEditable {
                        if !self.usefocusAble {
                            if self.isSecure{
                                SecureField(self.placeHolder, text: self.$input)
                                    .keyboardType(self.keyboardType)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.app.greyDeep)
                                    .modifier(MediumTextStyle(
                                                size: Self.inputFontSize))
                                    .padding(.trailing, Dimen.icon.tiny)
                            }else{
                                TextField(self.placeHolder, text: self.$input)
                                    .keyboardType(self.keyboardType)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.app.greyDeep)
                                    .modifier(MediumTextStyle(
                                        size: Self.inputFontSize))
                                    .padding(.trailing, Dimen.icon.tiny)
                            }
                            
                        } else {
                            if self.lineLimited == -1 {
                                FocusableTextField(
                                    text: self.$input,
                                    keyboardType: self.keyboardType,
                                    placeholder: self.placeHolder,
                                    maxLength: self.inputLimited,
                                    textModifier: MediumTextStyle(size: Self.inputFontSize).textModifier,
                                    isfocus: self.isFocus,
                                    inputLimited: {
                                        if !self.isInputLimited {
                                            withAnimation{ self.isInputLimited = true }
                                        }
                                    },
                                    inputChanged: { text in
                                        if self.isInputLimited {
                                            withAnimation{ self.isInputLimited = false }
                                        }
                                    },
                                    inputCopmpleted: { text in
                                        
                                    }
                                )
                                .padding(.trailing, Dimen.icon.tiny)
                            } else {
                                FocusableTextView(
                                    placeholder: "",
                                    text:self.$input,
                                    isfocus: self.isFocus,
                                    textModifier:MediumTextStyle(size: Self.inputFontSize).textModifier,
                                    usefocusAble: true,
                                    textAlignment: .center,
                                    inputLimited: {
                                        if !self.isInputLimited {
                                            withAnimation{ self.isInputLimited = true }
                                        }
                                    },
                                    inputChanged: {text , size in
                                        if self.isInputLimited {
                                            withAnimation{ self.isInputLimited = false }
                                        }
                                        self.inputHeight = min(size.height, (Self.inputHeight * CGFloat(self.lineLimited)))
                                    }
                                )
                                .frame(height : Self.inputHeight * CGFloat(self.lineLimited))
                                .padding(.trailing, Dimen.icon.tiny)
                            }
                        }
                    }else{
                        Text(self.input)
                        .modifier(MediumTextStyle(
                                    size: Self.inputFontSize,
                            color: Color.app.greyLight)
                        )
                        .multilineTextAlignment(.center)
                        .padding(.trailing, Dimen.icon.tiny)
                    }
                    if !self.input.isEmpty {
                        Button(action: {
                            self.input = ""
                            
                        }) {
                            Image(Asset.icon.delete)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Dimen.icon.tiny,
                                       height: Dimen.icon.tiny)
                                .opacity(0.5)
                        }
                    }
                }
                .padding(.all, Dimen.margin.thin)
                .modifier(MatchHorizontal(height: Dimen.tab.regular))
                .background(Color.app.white)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.lightExtra))
                .overlay(
                    RoundedRectangle(
                        cornerRadius: Dimen.radius.lightExtra, style: .circular)
                        .stroke( self.isFocus
                                    ? ( self.isInputLimited ? Color.brand.thirdly : Color.brand.primary )
                                    : Color.app.greyLight ,
                                 lineWidth: 1 )
                )
                .modifier(Shadow())
                if self.actionTitle != nil{
                    TextButton(
                        defaultText: self.actionTitle!,
                        textModifier:TextModifier(
                            family:Font.family.medium,
                            size:Font.size.thinExtra,
                            color: Color.brand.thirdly),
                        isUnderLine: true)
                    {_ in
                        guard let action = self.action else { return }
                        action()
                    }
                }
            }
            
            if let info = self.info {
                Text(info)
                    .modifier(MediumTextStyle(size: Font.size.thin,color: Color.app.grey))
                    .multilineTextAlignment(.center)
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
                isFocus: true,
                tip: "sdsdsdd",
                actionTitle: "btn"
            )
            .environmentObject(PagePresenter()).frame(width:320,height:600)
            .background(Color.brand.bg)
        }
    }
}
#endif


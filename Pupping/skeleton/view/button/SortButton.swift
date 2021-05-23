
import Foundation
import SwiftUI
struct SortButton: View{
    var text:String
    var isFocus:Bool = false
    var isFill:Bool = false
    var textModifier:TextModifier = TextModifier(
        family: Font.family.regular,
        size: Font.size.light,
        color: Color.app.white
    )
    var icon:String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            ZStack{
                HStack(spacing:Dimen.margin.thin){
                    if let icon = self.icon {
                        Image(icon)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                    }
                    
                    Text(self.text)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .foregroundColor(textModifier.color)
                    if self.isFill {
                        Spacer().modifier(MatchParent())
                    }
                    Image(Asset.icon.sort)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.micro, height: Dimen.icon.micro)
                }
                .padding(.horizontal, Dimen.margin.thin)
            }
            .frame(height:Dimen.button.light)
            .background(self.isFocus ? Color.brand.primary : Color.app.grey)
            .clipShape(
                RoundedRectangle(cornerRadius: Dimen.radius.light))
            
        }
    }
}
#if DEBUG
struct SortButtonButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SortButton(
                text: "test",
                isFocus: true,
                icon: Asset.icon.flag
            )
            {
                
            }
            .frame( width:300, alignment: .center)
            
        }
    }
}
#endif

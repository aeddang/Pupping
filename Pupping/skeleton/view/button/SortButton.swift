
import Foundation
import SwiftUI
struct SortButton: View{
    var text:String
    var isSelected:Bool = false
    var isFill:Bool = false
    var textModifier:TextModifier = TextModifier(
        family: Font.family.regular,
        size: Font.size.tiny,
        color: Color.app.grey
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
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(self.isSelected ? Color.brand.primary : Color.app.greyLight)
                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                    }
                    
                    Text(self.text)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(textModifier.color)
                    if self.isFill {
                        Spacer().modifier(MatchParent())
                    }
                    Image(Asset.icon.sort)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(self.isSelected ? Color.brand.primary : Color.app.greyLight)
                            .rotationEffect(.degrees(180))
                            .frame(width: Dimen.icon.micro, height: Dimen.icon.micro)
                }
                .padding(.horizontal, Dimen.margin.thin)
            }
            .frame(height:Dimen.button.thin)
            .background(Color.transparent.clearUi)
            .overlay(
                RoundedRectangle(cornerRadius: Dimen.radius.light)
                    .stroke(self.isSelected ? Color.brand.primary : Color.app.greyLight  ,
                            lineWidth: Dimen.stroke.light )
            )
            
        }
    }
}
#if DEBUG
struct SortButtonButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SortButton(
                text: "testsdsds",
                isSelected: true,
                icon: Asset.icon.filter
            )
            {
                
            }
            .frame( width:300, alignment: .center)
            
        }
    }
}
#endif

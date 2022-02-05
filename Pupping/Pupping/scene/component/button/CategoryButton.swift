
import Foundation
import SwiftUI
struct CategoryButton: View{
    var icon:String? = nil
    var color:Color? = nil
    var title:String? = nil
    var subTitle:String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HStack(spacing:Dimen.margin.thin){
                if let icon = self.icon {
                    ZStack{
                        if let color = self.color {
                            Image(icon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(color)
                                .modifier(MatchParent())
                        } else {
                            Image(icon)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .modifier(MatchParent())
                        }
                        
                    }
                    .padding(.all, Dimen.margin.tiny)
                    .frame(width: Dimen.icon.heavyLight,
                           height: Dimen.icon.heavyLight)
                    .overlay(
                        Circle()
                            .stroke( Color.app.greyLight ,lineWidth: Dimen.stroke.light )
                    )
                }
                VStack(alignment:.leading){
                    if let title = self.title {
                        Text(title).modifier(BoldTextStyle(size: Font.size.light, color: Color.app.greyDeep))
                            .multilineTextAlignment(.leading)
                    }
                    if let title = self.subTitle {
                        Text(title).modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.grey))
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer()
                Image(Asset.icon.go)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regularExtra,
                           height: Dimen.icon.regularExtra)
            }
        }
    }
}
#if DEBUG
struct CategoryButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CategoryButton(
                icon:Asset.icon.footPrint,
                title:"Title",
                subTitle:"subTitle"){
            
            }
            .frame( width:300, alignment: .center)
            
        }
    }
}
#endif


import Foundation
import SwiftUI
struct FlagButton: View{
    var isSelected:Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            ZStack{
                Image(Asset.icon.flag)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.app.black)
                    .frame(width: Dimen.icon.micro,
                           height: Dimen.icon.micro)
            }
            .frame(width: Dimen.icon.mediumExtra,height: Dimen.icon.mediumExtra)
            .background(isSelected ? Color.brand.primary : Color.app.greyLight)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.lightExtra))
        }
    }
}
#if DEBUG
struct FlagButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            FlagButton()
            {
                
            }
            .frame( width:300, alignment: .center)
            
        }
    }
}
#endif

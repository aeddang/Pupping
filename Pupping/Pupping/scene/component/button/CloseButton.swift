
import Foundation
import SwiftUI
struct CloseButton: View{
    
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            ZStack{
                Image(Asset.icon.close)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.app.white)
                    .frame(width: Dimen.icon.micro,
                           height: Dimen.icon.micro)
            }
            .frame(width: Dimen.icon.mediumExtra,height: Dimen.icon.mediumExtra)
            .background(Color.app.greyDeep)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
        }
    }
}
#if DEBUG
struct CloseButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CloseButton()
            {
                
            }
            .frame( width:300, alignment: .center)
            
        }
    }
}
#endif

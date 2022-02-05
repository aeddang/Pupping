
import Foundation
import SwiftUI
struct AddedButton: View{
    let action: () -> Void
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(Asset.icon.addOn)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: Dimen.icon.regularExtra,
                       height: Dimen.icon.regularExtra)
        }
    }
}
#if DEBUG
struct AddedButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            AddedButton()
            {
                
            }
            .frame( width:300, alignment: .center)
            
        }
    }
}
#endif

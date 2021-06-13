
import Foundation
import SwiftUI
struct DragOnOffButton: View{
    var isOn:Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            ZStack{
                Image(Asset.icon.back)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.app.greyDeep)
                    .frame(width: Dimen.icon.thinExtra,
                           height: Dimen.icon.thinExtra)
                    .rotationEffect(.degrees(self.isOn ? 270 : 90))
            }
            .frame(width: Dimen.icon.mediumExtra,height: Dimen.icon.mediumExtra)
            .background(Color.app.whiteDeep)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
        }
    }
}
#if DEBUG
struct DragOnOffButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            DragOnOffButton()
            {
                
            }
            .frame( width:300, alignment: .center)
            
        }
    }
}
#endif

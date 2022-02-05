
import Foundation
import SwiftUI
struct FavoriteButton: View{
    var isFavorite:Bool
    var value:String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HStack(spacing:Dimen.margin.tinyExtra){
                Image(isFavorite ? Asset.icon.favoriteOn : Asset.icon.favorite)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.thinExtra,
                           height: Dimen.icon.thinExtra)
                
                if let v = self.value {
                    Text(v)
                        .modifier(BoldTextStyle(
                            size: Font.size.thin,
                            color: isFavorite ? Color.brand.primary : Color.app.grey
                        ))
                }
            }
            .padding(.all, Dimen.margin.tiny)
            .background(Color.app.white)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.medium))
        }
    }
}
#if DEBUG
struct FavoriteButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            FavoriteButton(
                isFavorite: true
            )
            {
                
            }
            
        }
    }
}
#endif

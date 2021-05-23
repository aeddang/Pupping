//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI
import UIKit

struct SelectImagePicker: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
   
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    var id:String
    var data:InputData
    @State var selectedImage:UIImage? = nil
    let action: (_ image:UIImage?) -> Void
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0){
            if let title = self.data.title {
                Text(title)
                    .modifier(RegularTextStyle(size: Font.size.light, color: Color.brand.primary))
                    .multilineTextAlignment(.leading)
            }
            ZStack(alignment: .topTrailing){
                Image(uiImage: self.selectedImage ??
                        UIImage(named: Asset.brand.logoLauncher)!)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 280, height: 280)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    .opacity(self.selectedImage == nil ? 0.5 : 1.0)
                if self.selectedImage == nil {
                    Image( Asset.icon.add )
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor( Color.brand.primary )
                        .frame(width: Dimen.icon.regular,
                               height: Dimen.icon.regular)
                }
            }.onTapGesture {
                self.appSceneObserver.select
                    = .imgPicker(SceneRequest.imagePicker.rawValue + self.id)
            }
            .modifier(MatchParent())
        }
        .onReceive(self.appSceneObserver.$pickImage) { pick in
            guard let pick = pick else {return}
            if pick.id?.hasSuffix(self.id) != true {return}
            if let img = pick.image {
                self.pagePresenter.isLoading = true
                DispatchQueue.global(qos:.background).async {
                    let uiImage = img.normalized().centerCrop().resize(to: CGSize(width: 180,height: 180))
                    DispatchQueue.main.async {
                        self.selectedImage = uiImage
                        self.pagePresenter.isLoading = false
                        self.action(uiImage)
                    }
                }
            } else {
                self.selectedImage = nil
                self.action(nil)
            }
        }
        .onAppear(){
            self.selectedImage = data.selectedImage
            if self.selectedImage == nil {
                self.appSceneObserver.select
                    = .imgPicker(SceneRequest.imagePicker.rawValue + self.id)
            }
            
        }
    }//body

}


#if DEBUG
struct SelectImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SelectImagePicker(
                id: "ttt",
                data:InputData(title: "Test")
            ){ _ in
                
            }
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .frame(width:320,height:600)
        }
    }
}
#endif

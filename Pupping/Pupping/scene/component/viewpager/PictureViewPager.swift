//
//  ImageViewPager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
class PictureViewPagerModel:ViewPagerModel{
    @Published var datas:[Picture] = []
    func addPictures(_ datas:[Picture]){
        self.datas.append(contentsOf: datas)
    }
    func deletePicture(_ data:Picture)->Int{
        guard let idx = self.datas.firstIndex(of: data) else {return self.datas.count}
        self.datas.remove(at: idx)
        return self.datas.count
    }
}

struct PictureViewPager: PageComponent {
    @ObservedObject var viewModel:PictureViewPagerModel = PictureViewPagerModel()
   
    @State var index: Int = 0
    @State var pages: [PageViewProtocol] = []
    var action:((_ idx:Int) -> Void)? = nil
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SwipperView(
                viewModel:self.viewModel,
                pages: self.pages,
                coordinateSpace: .global,
                usePull: nil
            ) {
                guard let action = self.action else {return}
                action(self.index)
            }
        }
        .onReceive( self.viewModel.$index ){ idx in
            self.index = idx
        }
        .onReceive( self.viewModel.$datas){ datas in
            self.pages = datas.map{
                if let img = $0.image {
                    return UIImageItem(image: img)
                } else if let img = $0.originImagePath {
                    return ImageItem(imagePath: img)
                } else {
                    return ResourceItem(asset: Asset.brand.logoLauncher)
                }
            }
        }
        
    }
}

#if DEBUG
struct PictureViewPager_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PictureViewPager(
                
            )
            .frame(width:375, height: 170, alignment: .center)
        }
    }
}
#endif

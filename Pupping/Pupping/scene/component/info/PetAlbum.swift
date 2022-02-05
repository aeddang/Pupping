//
//  ProfileDetail.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/14.
//

import Foundation
import SwiftUI

struct PetAlbum: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
   
    @ObservedObject var profile:PetProfile
    var userId:String? = nil
    
   
    @State var pictures:[PictureDataSet] = []
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.regular){
            HStack{
                Text(String.pageTitle.album)
                    .modifier(ContentTitle())
                Spacer()
                if self.profile.isMypet {
                    AddedButton(){
                        guard let id = self.dataProvider.user.snsUser?.snsID else {return}
                        self.appSceneObserver.select
                                = .imgPicker(SceneRequest.imagePicker.rawValue + id)
                    }
                }
            }
            
            if !self.pictures.isEmpty {
                ForEach(self.pictures) { data in
                    PictureSet(
                        data: data,
                        horizontalMargin: 0
                    )
                    .modifier(ListRowInset(spacing: Dimen.margin.thin))
                }

            } else {
                Spacer().modifier(MatchParent())
            }
            
        }
        .onAppear(){
            self.pictures = [
                PictureDataSet( datas: [Picture().setDummy(), Picture().setDummy()],  isFull: true),
                PictureDataSet( datas: [Picture().setDummy(), Picture().setDummy()],  isFull: true),
                PictureDataSet( datas: [Picture().setDummy(), Picture().setDummy()],  isFull: true),
                PictureDataSet( datas: [Picture().setDummy(), Picture().setDummy()],  isFull: true),
                PictureDataSet( datas: [Picture().setDummy()],  isFull: false)
            ]
        }
        
    }
}


#if DEBUG
struct PetAlbum_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PetAlbum(
                profile: PetProfile(
                    nickName: "dalja",
                    species: "biggle",
                    gender: .female,
                    birth: Date())
            )
            .environmentObject(Repository())
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            .environmentObject(DataProvider())
            .frame(width: 375, height: 640)
        }
    }
}
#endif

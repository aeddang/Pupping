//
//  PetList.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/13.
//

import Foundation
import SwiftUI

extension UserList{
    static let width:CGFloat = 160
    static let height:CGFloat = 224
}

struct UserList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[User]
   
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: Dimen.margin.light,
            marginHorizontal: Dimen.margin.light,
            spacing: Dimen.margin.light,
            isRecycle: true,
            useTracking: false
        ){
            ForEach(self.datas) { data in
                UserListItem(data: data )
                    .frame(width: UserList.width, height: UserList.height)
                    .onTapGesture {
                        /*
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.profile)
                                .addParam(key: .data, value: data)
                        )*/
                    }
            }
        }
    }//body
}

struct UserListSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[UserDataSet]
    var onBottom: (() -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginVertical: Dimen.margin.light,
            spacing: Dimen.margin.light,
            isRecycle: true,
            useTracking: true
        ){
            ForEach(self.datas) { data in
                UserSet(data: data )
                .onAppear{
                    if data.index == self.datas.last?.index {
                        self.onBottom?()
                    }
                }
            }
        }
    }//body
}

struct UserDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 2
    var datas:[User] = []
    var isFull = false
    var index:Int = -1
}


struct UserSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    
    var data:UserDataSet
    var body: some View {
        HStack( spacing: Dimen.margin.thin){
            ForEach(self.data.datas) { data in
                UserListItem( data:data )
                .modifier(MatchParent())
                .onTapGesture {
                    
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.user)
                            .addParam(key: .data, value: data)
                    )
                }
            }
            if !self.data.isFull && self.data.count > 1 {
                Spacer().modifier(MatchParent())
            }
        }
        .modifier(MatchHorizontal(height: UserList.height))
        .modifier(ContentHorizontalEdges())
        .onAppear {
        }
    }//body
}



struct UserListItem: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var data:User

   
    var body: some View {
        VStack(alignment:.leading, spacing: Dimen.margin.regular){
            UserProfileInfo(
                profile: self.data.currentProfile,
                isModifyAble: false
            )
            .padding(.horizontal, Dimen.margin.regular)
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing:Dimen.margin.tinyExtra){
                    ForEach(self.data.pets) { pet in
                        PetProfileImage(
                            id : pet.id,
                            image: pet.image,
                            imagePath: pet.imagePath,
                            size: Dimen.profile.thin
                        )
                    }
                }
                .padding(.horizontal, Dimen.margin.regular)
            }
        }
        .modifier(MatchParent())
        .padding(.vertical, Dimen.margin.regular)
        .modifier(ContentTab(margin: 0))
        
        
    }
}

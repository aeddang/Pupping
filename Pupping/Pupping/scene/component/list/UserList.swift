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
   
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginVertical: Dimen.margin.light,
            spacing: Dimen.margin.light,
            isRecycle: true,
            useTracking: false
        ){
            ForEach(self.datas) { data in
                UserSet(data: data )
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
    
    @State var image:UIImage? = nil
    @State var name:String? = nil
    @State var age:String? = nil
    @State var species:String? = nil
    @State var gender:Gender? = nil
    @State var lv:String = ""
    @State var exp:String = ""
    @State var prevExp:String = ""
    @State var nextExp:String = ""
    @State var progressExp:Float = 0
   
    var body: some View {
        VStack(alignment:.leading, spacing: Dimen.margin.regular){
            UserProfileInfo(
                profile: self.data.currentProfile,
                isModifyAble: false
            )
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing:Dimen.margin.micro){
                    ForEach(self.data.pets) { pet in
                        Image(uiImage: pet.image ??
                                UIImage(named:Asset.brand.logoLauncher)!)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: Dimen.profile.thin, height: Dimen.profile.thin)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .padding(.horizontal, Dimen.margin.tiny)
                    }
                }
            }
        }
        .modifier(MatchParent())
        .modifier(ContentTab())
        
        
    }
}

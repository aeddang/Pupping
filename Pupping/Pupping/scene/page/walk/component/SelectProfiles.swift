//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct ProfileDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 3
    var datas:[Profile] = []
}

struct SelectProfiles: PageComponent {
   
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    
    let action: (_ selectedProfiles:[Profile]) -> Void
    
    var body: some View {
        VStack(spacing: Dimen.margin.medium){
            Text(String.alert.selectProfile)
                .modifier(RegularTextStyle(
                    size: Font.size.thin,
                    color: Color.app.grey
                ))
            
            VStack(spacing: Dimen.margin.thin) {
                ForEach(self.profileSets) { profileSet in
                    HStack(spacing: Dimen.margin.thin) {
                        ForEach(profileSet.datas) { profile in
                            SelectProfileItem(
                                data: profile,
                                isSelected: self.selectedProfiles.first(where: {$0.id == profile.id}) != nil
                            )
                            .onTapGesture {
                                profile.isWith.toggle()
                                if profile.isWith {
                                    self.selectedProfiles.append(profile)
                                } else {
                                    if let find = self.selectedProfiles.firstIndex(of: profile) {
                                        self.selectedProfiles.remove(at: find)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            FillButton(
                text: String.app.corfirm,
                isSelected:!self.selectedProfiles.isEmpty
                ){ _ in
                if self.selectedProfiles.isEmpty {return}
                self.action(self.selectedProfiles)
            }
            .frame(width: Dimen.button.lightRect.width)
        }
        .modifier(ContentTab())
        .onReceive(self.dataProvider.user.$profiles){ profiles in
            if profiles.isEmpty {
                self.profileSets = []
            } else {
                let count:Int = 3
                var rows:[ProfileDataSet] = []
                var cells:[Profile] = []
                profiles.forEach{ d in
                    if cells.count < count {
                        cells.append(d)
                    }else{
                        rows.append(
                            ProfileDataSet( count: count, datas: cells)
                        )
                        cells = [d]
                    }
                }
                if !cells.isEmpty {
                    rows.append(
                        ProfileDataSet( count: count, datas: cells)
                    )
                }
                self.profileSets.append(contentsOf: rows)
            }
            self.selectedProfiles = profiles.filter{$0.isWith}.map{$0}
            
        }
        .onAppear{
           
        }
    }//body
    @State var profileSets:[ProfileDataSet] = []
    @State var selectedProfiles:[Profile] = []
}

struct SelectProfileItem: PageComponent {
   
    var data:Profile
    var isSelected:Bool
    var body: some View {
        VStack(spacing: Dimen.margin.tinyExtra){
            Image(uiImage: self.data.image ??
                    UIImage(named: Asset.brand.logoLauncher)!)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Dimen.profile.regular, height: Dimen.profile.regular)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .overlay(
                   Circle()
                    .stroke(
                        self.isSelected
                            ? Color.brand.primary
                            : Color.transparent.clearUi ,
                        lineWidth: Dimen.stroke.regular)
                )
            HStack(spacing:Dimen.margin.micro ){
                Text(self.data.nickName ?? "")
                     .modifier(BoldTextStyle(
                         size: Font.size.thinExtra,
                         color: Color.app.greyDeep
                     ))
             
                Text("lv" + self.data.lv.description)
                     .modifier(BoldTextStyle(
                         size: Font.size.thinExtra,
                         color: Color.brand.primary
                     ))
             }
        }
        .onAppear{
           
        }
    }//body
}


#if DEBUG
struct SelectProfiles_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SelectProfiles(){ _ in
                
            }
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(Repository())
            .environmentObject(DataProvider())
            .environmentObject(AppSceneObserver())
            .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif


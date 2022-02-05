//
//  ProfileDetail.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/14.
//

import Foundation
import SwiftUI

struct PetAbout: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
   
    @ObservedObject var profile:PetProfile
    var userId:String? = nil
    
    
    
    @State var neutralization:Bool = false
    @State var distemper:Bool = false
    @State var hepatitis:Bool = false
    @State var parovirus:Bool = false
    @State var rabies:Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.regular){
            VStack(alignment: .leading, spacing: Dimen.margin.micro){
                if self.neutralization {
                    PetVaccinated(text: String.pageText.profileRegistNeutralized, isVaccination: true)
                }
                if self.distemper {
                    PetVaccinated(text: String.pageText.profileRegistDistemperVaccinated, isVaccination: true)
                }
                if self.hepatitis {
                    PetVaccinated(text: String.pageText.profileRegistHepatitisVaccinated, isVaccination: true)
                }
                if self.parovirus {
                    PetVaccinated(text: String.pageText.profileRegistParovirusVaccinated, isVaccination: true)
                }
                if self.rabies {
                    PetVaccinated(text: String.pageText.profileRegistRabiesVaccinated, isVaccination: true)
                }
            }
            PetHealthInfo(
                profile: self.profile,
                userId: self.userId)
        }
        .onReceive(self.profile.$neutralization) { isVaccination in
            self.neutralization = isVaccination ?? false
        }
        .onReceive(self.profile.$hepatitis) { isVaccination in
            self.hepatitis = isVaccination ?? false
        }
        .onReceive(self.profile.$distemper) { isVaccination in
            self.distemper = isVaccination ?? false
        }
        .onReceive(self.profile.$parovirus) { isVaccination in
            self.parovirus = isVaccination ?? false
        }
        .onReceive(self.profile.$rabies) { isVaccination in
            self.rabies = isVaccination ?? false
        }
        
        .onAppear(){
            
        }
        
    }
}

struct PetVaccinated:PageView{
    var text:String
    var isVaccination:Bool = false
    var body: some View {
        HStack(alignment: .center, spacing: Dimen.margin.thin){
            Image(self.isVaccination
                    ? Asset.shape.radioBtnOn
                    : Asset.shape.radioBtnOff)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
            Text(self.text)
                .modifier(SemiBoldTextStyle(
                    size: Font.size.thinExtra,
                    color: self.isVaccination ? Color.brand.secondary: Color.app.grey
                ))
            
        }
    }
}
#if DEBUG
struct PetAbout_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PetAbout(
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

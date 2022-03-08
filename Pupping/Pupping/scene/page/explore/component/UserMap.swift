//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps
import GooglePlaces

enum UserMapUiEvent {
    case setupMap([User]), me(CLLocation), selectUser(User)
}
class UserMapModel:MapModel{
    @Published var  userEvent:UserMapUiEvent? = nil{
        didSet{
            if userEvent != nil { self.userEvent = nil }
        }
    }
}


struct UserMap: PageView {
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:UserMapModel = UserMapModel()
    @Binding var isFollowMe:Bool
    @Binding var isForceMove:Bool
    
    var bottomMargin:CGFloat = 0
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            CPGoogleMap(
                viewModel: self.viewModel,
                pageObservable: self.pageObservable,
                useRotationEffect: true
                
            )
            /*
            Button(action: {
                self.isFollowMe.toggle()
                
            }) {
                Image( Asset.icon.fixMap )
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.isFollowMe ? Color.brand.fourth : Color.app.greyLight)
                    .frame(width: Dimen.icon.thin,
                           height: Dimen.icon.thin)
                    .padding(.all, Dimen.margin.tiny)
                    .background(Color.app.white)
                    .clipShape(Circle())
            }
            .padding(.trailing, Dimen.margin.regular)
            .padding(.bottom, Dimen.margin.regular + self.bottomMargin)
             */
        }
        .onReceive(self.viewModel.$userEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .me(let loc):
                self.moveMe(loc: loc)
            case .setupMap(let users) :
                self.userSetup(users: users)
            default : break
            }
            
        }
    }//body

    
    @State var anyCancellable = Set<AnyCancellable>()
    private func getUserMarker(_ data:User) -> GMSMarker{
        let marker = GMSMarker()
        if let pos = data.finalGeo {
            marker.position = CLLocationCoordinate2D(
                latitude: pos.lat ?? 0,
                longitude: pos.lng ?? 0)
        }
        marker.userData = data
        marker.title = data.currentProfile.nickName
        var leading = data.pets.filter{$0.nickName != nil}.reduce("", {$0 + $1.nickName! + ", "})
        //let trailing = String.app.owner + " " + (data.currentProfile.nickName ?? "")
        leading.removeLast()
        leading.removeLast()
        marker.snippet = leading
        
        if let path = data.currentProfile.imagePath {
            let loader = ImageLoader()
            loader.$event.sink(receiveValue: { evt in
                guard let  evt = evt else { return }
                switch evt {
                case .reset :break
                case .complete(let img) :
                    DispatchQueue.global(qos:.background).async {
                        let scale:CGFloat = UIScreen.main.scale
                        let size = Dimen.profile.light
                        let uiImage = img.normalized().centerCrop()
                            .resize(to: CGSize(
                                width: size/scale ,
                                height: size/scale ))
                            
                        
                        DispatchQueue.main.async {
                            marker.icon = uiImage.maskRoundedImage(
                                radius: size/2,
                                borderColor:Color.brand.primary,
                                borderWidth:Dimen.stroke.regular)
            
                        }
                    }
                    
                case .error :break
                }
            }).store(in: &anyCancellable)
            loader.load(url: path)
        
        }
        
        return marker
    }
    
    private func userSetup(users:[User]){
        let markers:[MapMarker] = users.map{ user in
            MapMarker(id:user.snsUser?.snsID ?? user.id , marker:self.getUserMarker(user))
        }
        self.viewModel.uiEvent = .addMarkers(markers)
    }
    

    private func moveMe(loc:CLLocation){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude)
        marker.title = "Me"
        marker.icon = UIImage(named: Asset.map.me)
        self.viewModel.uiEvent = .me( MapMarker(id: "me", marker:  marker)  , follow:self.isFollowMe ? loc : nil )
        
    }
   
}



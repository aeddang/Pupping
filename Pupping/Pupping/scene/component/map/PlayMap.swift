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

enum PlayMapUiEvent {
    case setupMission(Mission), me(CLLocation)
}
class PlayMapModel:MapModel{
    @Published var playEvent:PlayMapUiEvent? = nil{
        didSet{
            if playEvent != nil { self.playEvent = nil }
        }
    }
}

extension PlayMap {
    static let uiHeight:CGFloat = 130
    static let zoomRatio:Float = 15.0
    static let zoomCloseup:Float = 16.0
    static let mapMoveDuration:Double = 1.0
}

struct PlayMap: PageView {
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
    @Binding var isFollowMe:Bool
    @Binding var isForceMove:Bool 
    var bottomMargin:CGFloat = 0
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            CPGoogleMap(
                viewModel: self.viewModel,
                pageObservable: self.pageObservable)
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
        }
        .onReceive(self.viewModel.$playEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .setupMission(let mission) :
                self.playSetup(mission: mission)
            case .me(let loc):
                self.moveMe(loc: loc)
            }
        }
    }//body
   
    
  
    private func getStartMarker(_ start:GMSPlace) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: start.coordinate.latitude,
            longitude: start.coordinate.longitude)
        marker.title = "start"
        marker.icon = UIImage(named: Asset.icon.destination)
        marker.snippet = start.name
        return marker
    }
    
    private func getWaypointMarker(_ point:GMSPlace, idx:Int) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: point.coordinate.latitude,
            longitude: point.coordinate.longitude)
        marker.title = "point "+(idx+1).description
        marker.icon = UIImage(named: Asset.icon.flag)
        marker.snippet = point.name
        return marker
    }
    
    private func getDestinationMarker(_ destination:GMSPlace) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: destination.coordinate.latitude,
            longitude: destination.coordinate.longitude)
        marker.title = "destination"
        marker.icon = UIImage(named: Asset.icon.destination)
        marker.snippet = destination.name
        return marker
    }
    
    private func playSetup(mission:Mission){
        var markers:[GMSMarker] = []
        if let start = mission.start {
            markers.append(self.getStartMarker(start))
        }
        zip(mission.waypoints, 0..<mission.waypoints.count).forEach{ point, idx in
            markers.append(self.getWaypointMarker(point, idx: idx))
        }
        
        if let destination = mission.destination {
            markers.append(self.getDestinationMarker(destination))
            
        }
        self.viewModel.uiEvent = .addMarkers(markers)
    }
    
    
    
    private func moveMe(loc:CLLocation){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude)
        marker.title = "me"
        marker.icon = UIImage(named: Asset.icon.point)
        self.viewModel.uiEvent = .me(marker, follow:self.isFollowMe ? loc : nil )
        
    }
}



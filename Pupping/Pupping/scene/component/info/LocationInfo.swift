//
//  ImageView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps
import struct Kingfisher.KFImage
struct LocationInfo : PageComponent {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var locationObserver:LocationObserver
 
    @State var location:String? = nil
    @State var temperature:String? = "24"
    @State var weather:String? = "흐림"
     
    var body: some View {
        HStack(spacing:Dimen.margin.light){
            Image(Asset.icon.location)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                
            VStack(alignment: .leading, spacing:Dimen.margin.tiny){
                Text(self.location ?? String.location.notFound)
                    .modifier(BoldTextStyle(
                        size: Font.size.thinExtra,
                        color: Color.app.grey
                    ))
                HStack(spacing:Dimen.margin.tiny){
                    if let temperature = self.temperature {
                        Text(temperature)
                            .modifier(BoldTextStyle(
                                size: Font.size.mediumExtra,
                                color: Color.brand.primary
                            ))
                    }
                    if self.temperature != nil && self.weather != nil {
                        Circle()
                            .frame(width: Dimen.circle.thin, height: Dimen.circle.thin)
                            .background(Color.app.grey)
                    }
                    if let weather = self.weather {
                        Text(weather)
                            .modifier(BoldTextStyle(
                                size: Font.size.mediumExtra,
                                color: Color.app.greyDeep
                            ))
                    }
                }
            }
            Spacer()
        }
        .modifier(ContentTab())
        .onReceive(self.locationObserver.$event) { evt in
            guard let evt = evt else {return}
            switch evt {
            case .updateAuthorization(let status):
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self.requestLocation()
                }
            case .updateLocation(let loc):
                self.locationObserver.convertLocationToAddress(location: loc){ address in
                    guard let state = address.state else {return}
                    if let city = address.city {
                        if let street = address.street {
                            self.location = state + " " + city  + " " + street
                        } else {
                            self.location = state + " " + city
                        }
                    } else {
                        self.location = state
                    }
                    self.locationObserver.requestMe(false, id:self.tag)
                }
            }
        }
        .onAppear(){
            if !self.locationObserver.isSearch {
                self.requestLocation()
            }
        }
    }
    
    func requestLocation() {
        let status = self.locationObserver.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.locationObserver.requestMe(true, id:self.tag)
            
        } else if status == .denied {
            self.appSceneObserver.alert = .requestLocation{ retry in
                if retry { AppUtil.goLocationSettings() }
            }
        } else {
            self.locationObserver.requestWhenInUseAuthorization()
        }
    }
    
    
}



#if DEBUG
struct LocationInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            LocationInfo()
                .environmentObject(AppSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(LocationObserver())
                .frame(width: 375, height: 640)
        }
    }
}
#endif

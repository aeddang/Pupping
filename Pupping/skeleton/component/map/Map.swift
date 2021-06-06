//
//  Map.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/19.
//

import Foundation
import GoogleMaps
import CoreLocation


enum MapUiEvent {
    case addMarker(GMSMarker), addMarkers([GMSMarker]), me(GMSMarker, follow:CLLocation? = nil) ,
         move(CLLocation, zoom:Float? = nil, duration:Double? = nil)
}

open class MapModel: ComponentObservable {
    var startLocation:CLLocation = CLLocation()
    var zoom:Float = 6.0
    @Published var uiEvent:MapUiEvent? = nil{
        willSet{
            self.status = .update
            ComponentLog.d("willSet event " + self.status.rawValue, tag: self.tag)
        }
        didSet{
            if uiEvent == nil { self.status = .ready }
        }
    }
    
}

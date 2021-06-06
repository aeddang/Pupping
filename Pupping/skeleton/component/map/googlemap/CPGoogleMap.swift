//
//  CustomCamera.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/22.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps
struct CPGoogleMap {
    @ObservedObject var viewModel:MapModel
    @ObservedObject var pageObservable:PageObservable
    func makeCoordinator() -> Coordinator { return Coordinator() }
    class Coordinator:NSObject, PageProtocol {
    
    }
}


extension CPGoogleMap: UIViewControllerRepresentable, PageProtocol {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CPGoogleMap>) -> UIViewController {
        let mapController = CustomGoogleMapController(viewModel: self.viewModel)
        //mapController.delegate = context.coordinator
        return mapController
        
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CPGoogleMap>) {
       if viewModel.status != .update { return }
        guard let evt = viewModel.uiEvent else { return }
        guard let map = uiViewController as? CustomGoogleMapController else { return }
       
        ComponentLog.d("evt " , tag: self.tag)
        switch evt {
        case .addMarker(let marker):
            map.addMarker(marker)
        case .addMarkers(let markers):
            map.addMarker(markers)
        case .me(let marker, let loc):
            map.me(marker)
            if let loc = loc {
                map.move(loc)
            }
        case .move(let loc, let zoom, let duration):
            map.move(loc, zoom:zoom, duration:duration)
        }
    }
}



open class CustomGoogleMapController: UIViewController {
    @ObservedObject var viewModel:MapModel
    init(viewModel:MapModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var mapView: GMSMapView? = nil
    private var camera: GMSCameraPosition? = nil
    open override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(
            withLatitude: self.viewModel.startLocation.coordinate.latitude,
            longitude: self.viewModel.startLocation.coordinate.longitude,
            zoom: self.viewModel.zoom)
        
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)
        self.mapView = mapView
        self.camera = camera
        // Creates a marker in the center of the map.
    }
    
    fileprivate func me(_ marker:GMSMarker){
        marker.map = mapView
        //ComponentLog.d("me " + loc.debugDescription , tag: "CPGoogleMap")
    }
    fileprivate func move(_ loc:CLLocation, zoom:Float? = nil, duration:Double? = nil){
        if let duration = duration {
            CATransaction.begin()
            CATransaction.setValue(duration, forKey: kCATransactionAnimationDuration)
            let camera = GMSCameraPosition(
                target: loc.coordinate,
                zoom: zoom ?? self.viewModel.zoom)
            self.mapView?.animate(to: camera)
            CATransaction.commit()
        }else{
            mapView?.camera = GMSCameraPosition(
                target: loc.coordinate,
                zoom: zoom ?? self.viewModel.zoom)
        }
       
    }
    
    fileprivate func addMarker(_ marker:GMSMarker){
        marker.map = mapView
        //ComponentLog.d("addMarker " + (marker.title ?? "") , tag: "CPGoogleMap")
    }
    fileprivate func addMarker(_ markers:[GMSMarker]){
        markers.forEach{
            $0.map = mapView
        }
       // ComponentLog.d("addMarkers " + markers.count.description , tag: "CPGoogleMap")
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

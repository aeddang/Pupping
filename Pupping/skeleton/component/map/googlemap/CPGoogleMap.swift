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
        ComponentLog.d("updateUIView status " + viewModel.status.rawValue , tag: self.tag)
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
    open override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

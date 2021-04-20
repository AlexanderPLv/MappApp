//
//  MapController.swift
//  MappApp
//
//  Created by Alexander Pelevinov on 05.04.2021.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController {
    
    private var steps: [CLLocationCoordinate2D] = []
    private var route: [CLLocationCoordinate2D] = []
    private var navigationStarted = false
    private let locationDistance: Double = 500
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let coreDataManager = CoreDataManager.shared
    
    var onLogout: (() -> Void)?
    
    private var startTrackButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "play.fill",
                            withConfiguration: imageConfig)
        let iv = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        let button = UIButton(type: .system)
        button.setImage(iv.image, for: .normal)
        button.addTarget(self,
                         action: #selector(handleStartTrack),
                         for: .touchUpInside)
        return button
    }()
    
    private var stopTrackButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "stop.fill",
                            withConfiguration: imageConfig)
        let iv = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        let button = UIButton(type: .system)
        button.setImage(iv.image, for: .normal)
        button.addTarget(self,
                         action: #selector(handleStopTrack),
                         for: .touchUpInside)
        return button
    }()
    
    private var showTrackButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "arrowshape.turn.up.left.circle.fill",
                            withConfiguration: imageConfig)
        let iv = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        let button = UIButton(type: .system)
        button.setImage(iv.image, for: .normal)
        button.addTarget(self,
                         action: #selector(handleShowTrack),
                         for: .touchUpInside)
        return button
    }()
    
    @objc private func handleStopTrack() {
        guard navigationStarted else { return }
        locationManager.stopUpdatingLocation()
        let context = coreDataManager.persistentContainer.viewContext
        for (index, step) in steps.enumerated() {
            let coordinate = Coordinate(context: context)
            coordinate.step = Int32(index)
            coordinate.latitude = step.latitude
            coordinate.longitude = step.longitude
            do {
              try context.save()
            } catch let saveErr {
                print("Failed to save coordinate:", saveErr)
                // Alert
            }
        }
        navigationStarted = false
        mapView.removeOverlays(mapView.overlays)
        steps.removeAll()
    }
    
    @objc private func handleShowTrack() {
        guard !navigationStarted else { return }
        let coordinates = coreDataManager.fetchCoordinates()
        coordinates.forEach {
            let step = CLLocationCoordinate2D(latitude: $0.latitude,
                                              longitude: $0.longitude)
            self.route.append(step)
        }
        let polyline = MKPolyline(coordinates: &route, count: route.count)
        mapView.addOverlay(polyline)
        mapView.setVisibleMapRect(polyline.boundingMapRect,
                                  edgePadding: UIEdgeInsets(top: 20, left: 20,
                                                            bottom: 20, right: 20),
                                  animated: true)
        
    }
    
    @objc private func handleStartTrack() {
        guard !navigationStarted else { return }
        clearRoute()
        locationManager.startUpdatingLocation()
        navigationStarted = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupMapView()
        setupStartButton()
        setupLogoutButton()
    }
    
    private func setupLogoutButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:
                                                            "Logout",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(handleLogout))
    }
    
    @objc private func handleLogout() {
        UserDefaults.standard.setValue(false, forKey: "isLogin")
        onLogout?()
    }
    
    private func clearRoute() {
        route.removeAll()
        coreDataManager.removeAllCoordinates()
        mapView.removeOverlays(mapView.overlays)
    }
    
    private func setupStartButton() {
        view.addSubview(showTrackButton)
        view.addSubview(stopTrackButton)
        view.addSubview(startTrackButton)
        let buttonWidthHeight: CGFloat = 50
        showTrackButton.anchor(top: nil, left: nil,
                               bottom: view.bottomAnchor, right: view.rightAnchor,
                               paddingTop: 0, paddingLeft: 0,
                               paddingBottom: 30, paddingRight: 20,
                               width: buttonWidthHeight, height: buttonWidthHeight)
        stopTrackButton.anchor(top: nil, left: nil,
                               bottom: showTrackButton.topAnchor, right: view.rightAnchor,
                               paddingTop: 0, paddingLeft: 0,
                               paddingBottom: 0, paddingRight: 20,
                               width: buttonWidthHeight, height: buttonWidthHeight)
        startTrackButton.anchor(top: nil, left: nil,
                                bottom: stopTrackButton.topAnchor, right: view.rightAnchor,
                                paddingTop: 0, paddingLeft: 0,
                                paddingBottom: 0, paddingRight: 20,
                                width: buttonWidthHeight, height: buttonWidthHeight)
    }
    
    private func setupLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 20
            locationManager.allowsBackgroundLocationUpdates = true
            handleAuthorizationStatus(locationManager: locationManager)
        } else {
            print("Alert Location services are not enabled")
            //Alert Location services are not enabled
        }
    }
    
    private func setupMapView() {
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.fillSuperview()
    }
    
    fileprivate func centerViewToUserLocation() {
        if let center = locationManager.location?.coordinate {
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: locationDistance,
                                        longitudinalMeters: locationDistance)
        mapView.setRegion(region, animated: true)
        }
    }
    
    fileprivate func handleAuthorizationStatus(locationManager: CLLocationManager) {
        switch locationManager.authorizationStatus {
        
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //alert
            break
        case .denied:
            //go to settings ale
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewToUserLocation()
        @unknown default:
            // show err alert
            break
        }
    }
}

extension MapViewController :  MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            steps.append(location)
        }
        let polyline = MKPolyline(coordinates: &steps, count: steps.count)
        mapView.addOverlay(polyline)
        centerViewToUserLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
       handleAuthorizationStatus(locationManager: manager)
}
    
    private func showAlert(with message: String) {
        let alertController = UIAlertController(title: "Network Error",
                                                message: (message + " No data is currently available. Please pull down to refresh."),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok",
                                                style: .cancel))
        present(alertController, animated: true)
    }
    

}

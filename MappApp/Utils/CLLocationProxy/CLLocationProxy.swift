//
//  CLLocationManager.swift
//  MappApp
//
//  Created by Alexander Pelevinov on 21.04.2021.
//

import Foundation
import CoreLocation
import Combine

final class LocationProxy: NSObject, CLLocationManagerDelegate {

    let manager: CLLocationManager
    private let locationSubject: PassthroughSubject<CLLocationCoordinate2D, Never>
    private let authorizationSubject: PassthroughSubject<Bool, Never>
    var locationPublisher: AnyPublisher<CLLocationCoordinate2D, Never>
    var authorizationPublisher: AnyPublisher<Bool, Never>
    
    override init() {
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 15
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = true
        
        locationSubject = PassthroughSubject<CLLocationCoordinate2D, Never>()
        locationPublisher = locationSubject.eraseToAnyPublisher()
        authorizationSubject = PassthroughSubject<Bool, Never>()
        authorizationPublisher = authorizationSubject.eraseToAnyPublisher()
        
        super.init()
        manager.delegate = self
    }
    
    var locationServiceAutorized: Bool {
        guard manager.authorizationStatus == .authorizedAlways ||
                manager.authorizationStatus == .authorizedWhenInUse else {
            return false
        }
            return true
    }
    
    func enable() {
        if locationServiceAutorized {
            manager.startUpdatingLocation()
        }
    }

    func disable() {
        manager.stopUpdatingLocation()
    }
    
    func permissionRequest() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            locationSubject.send(location)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            break
        case .restricted:
            //Alert
        break
        case .denied:
            //Alert
            break
        case .authorizedAlways:
            authorizationSubject.send(true)
        case .authorizedWhenInUse:
            authorizationSubject.send(true)
        @unknown default:
            print("Location auth error.")
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

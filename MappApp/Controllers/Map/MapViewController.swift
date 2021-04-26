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
import Combine

class MapViewController: UIViewController {
    
    private var steps: [CLLocationCoordinate2D] = []
    private var route: [CLLocationCoordinate2D] = []
    private var profileImage: UIImage? {
        didSet {
            print("image setup")
        }
    }
    private var navigationStarted = false
    private let locationDistance: Double = 500
    private let mapView = MKMapView()
    private let coreDataManager = CoreDataManager.shared
    
    private let locationProxy = LocationProxy()
    private var cancellables = [AnyCancellable]()
    
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
        locationProxy.disable()
        do {
           try coreDataManager.saveCurrentRoute(with: steps)
        } catch let saveErr {
            present(UIAlertController.showAlert(with: saveErr.localizedDescription),
                    animated: true)
        }
        navigationStarted = false
        mapView.removeOverlays(mapView.overlays)
        steps.removeAll()
    }
    
    @objc private func handleShowTrack() {
        if !navigationStarted {
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
        } else {
            present(UIAlertController.stopTracking(onConfirm: { self.handleStopTrack() }),
                    animated:  true)
        }
        
    }
    
    @objc private func handleStartTrack() {
        guard !navigationStarted else { return }
        clearRoute()
        locationProxy.enable()
        navigationStarted = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationProxy.permissionRequest()
        setupMapView()
        setupStartButton()
        setupLogoutButton()
        setupImagePickerButton()
        
        locationProxy
            .authorizationPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] authorized in
                guard let self = self else { return }
                if authorized {
                    self.mapView.showsUserLocation = true
                }
            }.store(in: &cancellables)
        
        locationProxy
            .locationPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] coordinate in
                guard let self = self else { return }
                self.centerViewToUserLocation(with: coordinate)
                self.steps.append(coordinate)
                let polyline = MKPolyline(coordinates: &self.steps, count: self.steps.count)
                self.mapView.addOverlay(polyline)
            }.store(in: &cancellables)
        
    }
    
    private func setupLogoutButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:
                                                            "Logout",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(handleLogout))
    }
    
    private func setupImagePickerButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Photo",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(imagePIckTapped))
    }
    
    @objc private func imagePIckTapped() {
        showChooseSourceTypeAlertController()
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
    
    private func setupMapView() {
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.fillSuperview()
    }
    
    fileprivate func centerViewToUserLocation(with coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: locationDistance,
                                        longitudinalMeters: locationDistance)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController :  MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        return renderer
    }
}

extension MapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showChooseSourceTypeAlertController() {
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Choose a Photo",
                                               style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take a New Photo",
                                         style: .default) { (action) in
            self.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel, handler: nil)
        [photoLibraryAction, cameraAction, cancelAction] .forEach{
            alert.addAction($0)
        }
        present(alert, animated: true)
    }
    
    private func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                   self.profileImage = editedImage.withRenderingMode(.alwaysOriginal)
               } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                   self.profileImage = originalImage.withRenderingMode(.alwaysOriginal)
               }
               dismiss(animated: true, completion: nil)
    }
    
}

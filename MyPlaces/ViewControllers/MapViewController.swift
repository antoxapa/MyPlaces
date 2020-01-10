//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Антон Потапчик on 1/7/20.
//  Copyright © 2020 TonyPo Production. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressPin: UIImageView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var getDirectionButton: UIButton!
    
    var segueIdentifier = ""
    var place = Place()
    var annotationIdentifier = "annotationIdentifier"
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var mapManager = MapManager()
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLoation(for: mapView, location: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        mapView.delegate = self
    }
    
    private func setupMapView() {
        getDirectionButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: segueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if segueIdentifier == "showPlace" {
            getDirectionButton.isHidden = false
            mapManager.setupLocation(place: place, mapView: mapView)
            addressPin.isHidden = true
            doneButton.isHidden = true
            currentLocationLabel.isHidden = true
        }
    }
    
    @IBAction func pressCancel() {
        dismiss(animated: true)
    }
    
    @IBAction func showUserLocationAction(_ sender: UIButton) {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func getDirectionAction(_ sender: UIButton) {
        mapManager.getDirection(mapView: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        mapViewControllerDelegate?.getAddress(currentLocationLabel.text)
        dismiss(animated: true)
    }
}

//MARK: - MAPDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterCoordinates(for: mapView)
        let geocoder = CLGeocoder()
        
        // focuse on user if center changed
        if segueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            let streetName = placemark.thoroughfare
            let buildingName = placemark.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildingName != nil {
                    self.currentLocationLabel.text = "\(streetName! + "," + buildingName!)"
                } else if streetName != nil {
                    self.currentLocationLabel.text = "\(streetName!)"
                } else {
                    self.currentLocationLabel.text = ""
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
    }
}

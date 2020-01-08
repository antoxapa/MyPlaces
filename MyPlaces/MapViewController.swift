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
    
    var locationManager = CLLocationManager()
    var segueIdentifier = ""
    var place = Place()
    var annotationIdentifier = "annotationIdentifier"
    var mapViewControllerDelegate: MapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        mapView.delegate = self
        checkLocationServices()
    }
    
    @IBAction func pressCancel() {
        dismiss(animated: true)
    }
    
    private func setupLocation() {
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location is not available",
                    message: "To give permission: Settings -> Privacy -> Location services")
            }
        }
    }
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "chooseAddress" {
                showUserLocation()
            }
            
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location is not available",
                    message: "To give permission: Settings -> MyPlaces -> Location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
            
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    @IBAction func showUserLocationAction(_ sender: UIButton) {
        showUserLocation()
    }
    private func setupMapView() {
        setupLocation()
        if segueIdentifier == "showPlace" {
            addressPin.isHidden = true
            doneButton.isHidden = true
            currentLocationLabel.isHidden = true
        }
    }
    
    private func getCenterCoordinates(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterCoordinates(for: mapView)
        let geocoder = CLGeocoder()
        
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
    
    
    
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 250, longitudinalMeters: 250)
            mapView.setRegion(region, animated: true)
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
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

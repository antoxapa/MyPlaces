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
    
    var locationManager = CLLocationManager()
    var segueIdentifier = ""
    var place = Place()
    var annotationIdentifier = "annotationIdentifier"
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var placeCoordinates: CLLocationCoordinate2D?
    var previousLocation: CLLocation? {
        didSet {
            startTrackingUserLoation()
        }
    }
    var directionsArray: [MKDirections] = []
    
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
            self.placeCoordinates = placemarkLocation.coordinate
            
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
            getDirectionButton.isHidden = false
            if segueIdentifier == "chooseAddress" {
                showUserLocation()
                getDirectionButton.isHidden = true
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
    private func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        
        let _ = directionsArray.map{ $0.cancel() }
        directionsArray.removeAll()
        
    }
    
    private func getCenterCoordinates(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
 
    
    
    @IBAction func getDirectionAction(_ sender: UIButton) {
        getDirection()
    }
    
    private func getDirection() {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = getDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request)
        // удаляет все прошлые маршруты, если они были построены и отменены
        resetMapView(withNew: directions)
        
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime / 60
                
                print("Distance is \(distance), time interval \(timeInterval)")
            }
        }
    }
    
    private func getDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinates else { return nil}
        
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }

    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 250, longitudinalMeters: 250)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func startTrackingUserLoation() {
        guard let previousLocation = previousLocation else { return }
        let center = getCenterCoordinates(for: mapView)
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
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
         let center = getCenterCoordinates(for: mapView)
         let geocoder = CLGeocoder()
        
        // focuse on user if center changed
        if segueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
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
        checkLocationAuthorization()
    }
}

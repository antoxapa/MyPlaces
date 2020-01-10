//
//  MapManager.swift
//  MyPlaces
//
//  Created by Антон Потапчик on 1/10/20.
//  Copyright © 2020 TonyPo Production. All rights reserved.
//

import UIKit
import MapKit

class MapManager {
    var locationManager = CLLocationManager()
    private var placeCoordinates: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    
    
    // проверка адреса и создание маркера заведения
    func setupLocation(place: Place, mapView: MKMapView) {
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinates = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // Проверка сервисов геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location is not available",
                    message: "To give permission: Settings -> Privacy -> Location services")
            }
        }
    }
    
    // Проверка авториции приложения для использования сервисов геолокации
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "chooseAddress" {
                showUserLocation(mapView: mapView)
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
    
    // Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 250, longitudinalMeters: 250)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Строим маршрут от местоположения пользователя до заведения
    func getDirection(mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = getDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request)
        // удаляет все прошлые маршруты, если они были построены и отменены
        resetMapView(withNew: directions,mapView: mapView)
        
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
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime / 60
                
                print("Distance is \(distance), time interval \(timeInterval)")
            }
        }
    }
    
    // Настройка запроса для расчета маршрута
    func getDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
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
    
    // Меняем отображаемую зону области в соответствии с перемещением пользователя
    func startTrackingUserLoation(for mapView: MKMapView, location: CLLocation?, closure: (_ currentLocation: CLLocation?) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterCoordinates(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        closure(center)
    }
    
    // Сброс всех ранее построенных маршрутов перед построением новых
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        
        let _ = directionsArray.map{ $0.cancel() }
        directionsArray.removeAll()
    }
    
    // Определение центра обображаемой области
    func getCenterCoordinates(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        let alerWindow = UIWindow(frame: UIScreen.main.bounds)
        alerWindow.rootViewController = UIViewController()
        alerWindow.windowLevel = UIWindow.Level.alert + 1
        alerWindow.makeKeyAndVisible()
        alerWindow.rootViewController?.present(alertController, animated: true)
    }
}

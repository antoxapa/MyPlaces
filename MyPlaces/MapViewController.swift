//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Антон Потапчик on 1/7/20.
//  Copyright © 2020 TonyPo Production. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var place: Place!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
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
}

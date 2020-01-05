//
//  PlacesModel.swift
//  MyPlaces
//
//  Created by Антон Потапчик on 1/5/20.
//  Copyright © 2020 TonyPo Production. All rights reserved.
//

import UIKit

struct Place {
    var name: String
    var location: String?
    var type: String?
    var restaurantImage: String?
    var image: UIImage?
    
    
    static let namesArray = ["Shaurma", "GrillFood", "Rublevskiy", "Kafe Garage", "Gippo", "Green", "BurgerKing"]
    
   
    static func getPlaces () -> [Place] {
        var places = [Place]()
        for name in namesArray {
            places.append(Place(name: name, location: "Minsk", type: "Restaurant", restaurantImage: name, image: nil))
        }
        return places
    }
}

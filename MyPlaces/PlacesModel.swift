//
//  PlacesModel.swift
//  MyPlaces
//
//  Created by Антон Потапчик on 1/5/20.
//  Copyright © 2020 TonyPo Production. All rights reserved.
//

import RealmSwift

class Place: Object {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    

    let placesArray = ["Shaurma", "GrillFood", "Rublevskiy", "Kafe Garage", "Gippo", "Green", "BurgerKing"]
    
   
    func savePlacesToDB() {
        for place in placesArray {
            guard let image = UIImage(named: place)?.pngData() else { return }
            let newPlace = Place()
            newPlace.name = place
            newPlace.location = "Minsk"
            newPlace.type = "Restaurant"
            newPlace.imageData = image
            StorageManager.saveObject(newPlace)
        }
    }
}



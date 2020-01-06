//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Антон Потапчик on 1/6/20.
//  Copyright © 2020 TonyPo Production. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
}

//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Антон Потапчик on 1/5/20.
//  Copyright © 2020 TonyPo Production. All rights reserved.
//

import UIKit
import RealmSwift

class TableViewController: UITableViewController {

    let cellID = "Cell"
     
    //  Same as Array in Realm
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! CustomCell

        let place = places[indexPath.row]

        cell.placeName.text = place.name
        cell.placeType.text = place.type
        cell.placeLocation.text = place.location
        cell.placeImage.image = UIImage(data: place.imageData!)

        cell.placeImage.layer.cornerRadius = cell.placeImage.frame.height / 2

        return cell
    }
//
//    // MARK: - Navigation
//
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let svc = segue.source as? AddPlaceTableViewController else { return }
        svc.saveNewPlace()
        tableView.reloadData()
    }
}

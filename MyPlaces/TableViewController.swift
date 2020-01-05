//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Антон Потапчик on 1/5/20.
//  Copyright © 2020 TonyPo Production. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    let cellID = "Cell"
    
    var places = Place.getPlaces()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! CustomCell
        
        let place = places[indexPath.row]

        cell.placeName.text = place.name
        cell.placeType.text = place.type
        cell.placeLocation.text = place.location
        
        if place.image == nil {
            cell.placeImage?.image = UIImage(named: places[indexPath.row].restaurantImage!)
        } else {
            cell.placeImage.image = place.image
        }
        
        cell.placeImage.layer.cornerRadius = cell.placeImage.frame.height / 2

        return cell
    }
    
    // MARK: - Navigation

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let svc = segue.source as? AddPlaceTableViewController else { return }
        svc.saveNewPlace()
        places.append(svc.newPlace!)
        tableView.reloadData()
    }
}

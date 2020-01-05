//
//  CustomCell.swift
//  MyPlaces
//
//  Created by Антон Потапчик on 1/5/20.
//  Copyright © 2020 TonyPo Production. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeLocation: UILabel!
    @IBOutlet weak var placeType: UILabel!
    
    override func awakeFromNib() {
          super.awakeFromNib()
          // Initialization code
      }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

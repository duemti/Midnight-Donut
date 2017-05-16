//
//  PlaceTableViewCell.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/15/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    //MARK: Properties.
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLabelCell: UILabel!
    @IBOutlet weak var addressLabelCell: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

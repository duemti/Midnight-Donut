//
//  MoreViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 6/15/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {
    
    // MARK: - Properties.
    @IBOutlet weak var tagsButton: menuButton!
    @IBOutlet weak var shopButton: menuButton!
    @IBOutlet weak var aboutButton: menuButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        designCells()
    }

}

// MARK: - Layout.
extension MoreViewController {
    func designCells() {
        // Corner Radius for buttons
        self.tagsButton.layer.cornerRadius = 10
        self.shopButton.layer.cornerRadius = 10
        self.aboutButton.layer.cornerRadius = 10
        
        // Shadows of buttons.
        self.tagsButton.layer.shadowColor = UIColor(red:0.09, green:0.11, blue:0.13, alpha:1.0).cgColor
        self.tagsButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.tagsButton.layer.shadowOpacity = 1.0
        self.tagsButton.layer.shadowRadius = 0
        self.tagsButton.layer.masksToBounds = false
        
        self.shopButton.layer.shadowColor = UIColor(red:0.09, green:0.11, blue:0.13, alpha:1.0).cgColor
        self.shopButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.shopButton.layer.shadowOpacity = 1.0
        self.shopButton.layer.shadowRadius = 0
        self.shopButton.layer.masksToBounds = false
        
        self.aboutButton.layer.shadowColor = UIColor(red:0.09, green:0.11, blue:0.13, alpha:1.0).cgColor
        self.aboutButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.aboutButton.layer.shadowOpacity = 1.0
        self.aboutButton.layer.shadowRadius = 0
        self.aboutButton.layer.masksToBounds = false
    }
}

class menuButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = UIColor(red:0.14, green:0.17, blue:0.18, alpha:1.0)
                layer.shadowOffset = CGSize(width: 0, height: 2)
            } else {
                backgroundColor = UIColor(red:0.18, green:0.22, blue:0.24, alpha:1.0)
                layer.shadowOffset = CGSize(width: 0, height: 8)
            }
        }
    }
}

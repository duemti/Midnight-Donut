//
//  PlacesCollectionViewCell.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/22/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

class PlacesCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties.
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeAddress: UILabel!
    @IBOutlet weak var placeRating: UILabel!
    @IBOutlet weak var placeStatus: UILabel!
    
    //MARK: - Rating Control.
    @IBOutlet weak var star_1: UIImageView!
    @IBOutlet weak var star_2: UIImageView!
    @IBOutlet weak var star_3: UIImageView!
    @IBOutlet weak var star_4: UIImageView!
    @IBOutlet weak var star_5: UIImageView!
    
    @IBOutlet weak var fullStar_1: UIImageView!
    @IBOutlet weak var fullStar_2: UIImageView!
    @IBOutlet weak var fullStar_3: UIImageView!
    @IBOutlet weak var fullStar_4: UIImageView!
    @IBOutlet weak var fullStar_5: UIImageView!
    
    // Sets the Rating View.
    func setRatingValue(_ value: Float) {
        
        let fullStars = [fullStar_1, fullStar_2, fullStar_3, fullStar_4, fullStar_5]
        let emtyStars = [star_1, star_2, star_3, star_4, star_5]
        for i in 0..<5 {
            let fullStar = fullStars[i]!
            let emtyStar = emtyStars[i]!
            
            if value > Float(i + 1) {
                // Removing empty star image.
                emtyStar.isHidden = true
                // Making visible full star image.
                fullStar.isHidden = false
            } else {
                let maskLayer = CALayer()
                let maskWidth: CGFloat = CGFloat(value - Float(i)) * fullStar.frame.size.width
                let maskHeight: CGFloat = fullStar_5.frame.size.height
                maskLayer.frame = CGRect(x: 0.0, y: 0.0, width: maskWidth, height: maskHeight)
                maskLayer.backgroundColor = UIColor.black.cgColor
                fullStar_5.layer.mask = maskLayer
                fullStar_5.isHidden = false
                break
            }
        }
    }
}

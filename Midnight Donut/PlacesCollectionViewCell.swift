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
    @IBOutlet weak var directionImage: UIImageView!
    @IBOutlet weak var placeHours: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
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
    
    var rating: Float = 0.0 {
        didSet {
            setRatingValue(rating)
        }
    }
    
    // Sets the Rating View.
    private func setRatingValue(_ value: Float) {
//        fullStar_1.isHidden = true
//        fullStar_2.isHidden = true
//        fullStar_3.isHidden = true
//        fullStar_4.isHidden = true
//        fullStar_5.isHidden = true
        let fullStars = [fullStar_1, fullStar_2, fullStar_3, fullStar_4, fullStar_5]
//        star_1.isHidden = false
//        star_2.isHidden = false
//        star_3.isHidden = false
//        star_4.isHidden = false
//        star_5.isHidden = false
//        let emptyStars = [star_1, star_2, star_3, star_4, star_5]
        if value == 0.0 {
            return
        }
        for i in 0..<fullStars.count {
            let full_Star = fullStars[i]!
            
            if value >= Float(i + 1) {
                // Making visible full star image.
                full_Star.layer.mask = nil
                full_Star.isHidden = false
            } else if value > Float(i) && value < Float(i + 1) {
                let maskLayer = CALayer()
                let maskWidth: CGFloat = CGFloat(value - Float(i)) * full_Star.frame.size.width
                let maskHeight: CGFloat = full_Star.frame.size.height
                maskLayer.frame = CGRect(x: 0.0, y: 0.0, width: maskWidth, height: maskHeight)
                maskLayer.backgroundColor = UIColor.black.cgColor
                full_Star.layer.mask = maskLayer
                full_Star.isHidden = false
            } else {
                full_Star.layer.mask = nil
                full_Star.isHidden = true
            }
        }
    }
}

//
//  PlacesViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/22/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

private let firstReuseIdentifier = "Cell"
private let secondReuseIdentifier = "NoDataCell"

class PlacesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: Properties.
    let themeColor: [UIColor] = [UIColor(red:0.61, green:0.69, blue:0.49, alpha:1.0), UIColor(red:0.49, green:0.61, blue:0.69, alpha:1.0), UIColor(red:0.69, green:0.58, blue:0.49, alpha:1.0), UIColor(red:0.65, green:0.65, blue:0.00, alpha:1.0)]
    var places = [Place]()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = places.count
        return count == 0 ? 1 : count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if places.count != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: firstReuseIdentifier, for: indexPath) as! PlacesCollectionViewCell
            
            // Configure the cell...
            
            let place = places[indexPath.row]
            let address = place.formattedAddress.components(separatedBy: ",")
            
            /*                  Setting theme Color             */
            let theme = themeColor[0]
            
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 5
            cell.directionImage.layer.cornerRadius = 5
            
            mainTitleLabel.textColor = theme
            cell.layer.borderColor = theme.cgColor
            cell.placeName.textColor = theme
            cell.placeAddress.textColor = theme
            cell.placeStatus.textColor = theme
            cell.directionImage.backgroundColor = theme
            cell.placeRating.textColor = theme
            cell.placeHours.textColor = theme
            /*                   THEME SETTED                   */
            
            cell.placeName.text = place.name
            cell.placeAddress.text = address[0]
            cell.placeRating.text = String(format: "%.1f", place.rating)
            cell.rating = place.rating
            cell.placeStatus.text = place.openNow ? "Open Now" : "Closed Now"
            cell.placeHours.text = place.weekdays?[4]
            return cell
        } else {
            // Display Cell with "No Places" message if [places] is empty ...
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: secondReuseIdentifier, for: indexPath) as! EmptyCollectionViewCell
            print("No Places.")
            return cell
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}

extension PlacesViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let cv = collectionView.bounds.size.width
//        let size = CGSize(width: cv, height: 160)
//        return size
//    }
}

extension PlacesViewController {
    func finishPassing(places: [Place]) {
        self.places = places
//        collectionView?.reloadData()
        print("Received the Places.")
    }
}


// MARK: - Sorting Functions.
extension PlacesViewController {
    @IBAction func sortTopRated(_ sender: UIButton) {
        let count = places.count
        
        if count != 0 {
            var index = 1
            while index < count {
                
                if places[index - 1].rating < places[index].rating {
                    swap(&places[index - 1], &places[index])
                    index = 0
                }
                index += 1
            }
            collectionView.reloadData()
        }
    }
    
    @IBAction func sortNearest(_ sender: UIButton) {
        print("sort 2")
    }
}

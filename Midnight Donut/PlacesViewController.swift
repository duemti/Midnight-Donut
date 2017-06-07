//
//  PlacesViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/22/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import CoreLocation

private let firstReuseIdentifier = "Cell"
private let secondReuseIdentifier = "NoDataCell"

class PlacesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: Properties.
    let themeColor: [UIColor] = [UIColor(red:0.61, green:0.69, blue:0.49, alpha:1.0), UIColor(red:0.49, green:0.61, blue:0.69, alpha:1.0), UIColor(red:0.69, green:0.58, blue:0.49, alpha:1.0), UIColor(red:0.65, green:0.65, blue:0.00, alpha:1.0)]
    var places = [Place]()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var topRatedButton: UIButton!
    @IBOutlet weak var nearestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        topRatedButton.setTitleColor(UIColor(red:0.18, green:0.22, blue:0.24, alpha:1.0), for: .disabled)
        topRatedButton.setTitleColor(UIColor(red:0.18, green:0.22, blue:0.24, alpha:1.0), for: .selected)
        nearestButton.setTitleColor(UIColor(red:0.18, green:0.22, blue:0.24, alpha:1.0), for: .disabled)
        nearestButton.setTitleColor(UIColor(red:0.18, green:0.22, blue:0.24, alpha:1.0), for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if places.count > 0 {
            topRatedButton.isEnabled = true
            nearestButton.isEnabled = true
        } else {
            topRatedButton.isEnabled = false
            nearestButton.isEnabled = false
        }
        
        animateTextAppearence()
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
            let dayOfTheWeek = Calendar.current.component(.weekdayOrdinal, from: Date())
            
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
            cell.distanceLabel.textColor = theme
            /*                   THEME SETTED                   */
            
            cell.placeName.text = place.name
            cell.placeAddress.text = address[0]
            cell.placeRating.text = String(format: "%.1f", place.rating)
            cell.rating = place.rating
            cell.placeStatus.text = place.openNow
            cell.placeHours.text = place.weekdays?[dayOfTheWeek]
            cell.distanceLabel.text = place.distanceText
            return cell
        } else {
            // Display Cell with "No Places" message if [places] is empty ...
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: secondReuseIdentifier, for: indexPath) as! EmptyCollectionViewCell
            print("No Places.")
            return cell
        }
    }
    
    // MARK: - Animation Section.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0.0
        cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1.0
            cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    /****************************************************************************************************************************************************************/
}

// MARK: - Actions When Tapped a Cell.
extension PlacesViewController: CLLocationManagerDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let maps = tabBarController?.viewControllers?[2] as! MapViewController
        let location = CLLocationManager().location?.coordinate
        let destination = places[indexPath.item]
        
        maps.s = location
        maps.d = destination.place_id
        print("Tap")
    }
}
/*********************************************************************************************************************************************************************/

extension PlacesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Size of collection View minus(-) 20 pixels because of MainScreen.
        let cellWidth = UIScreen.main.bounds.width - 32
        let size = CGSize(width: cellWidth, height: 160)
        return size
    }
}


// MARK: - Sorting Functions.
extension PlacesViewController {
    @IBAction func sortTopRated(_ sender: UIButton) {
        let count = places.count
        self.nearestButton.isEnabled = true
        self.topRatedButton.isEnabled = false
        
        if count != 0 {
            var index = 1
            while index < count {
                if places[index - 1].rating < places[index].rating {
                    swap(&places[index - 1], &places[index])
                    UIView.animate(withDuration: 1, animations: {
                        self.collectionView.moveItem(at: IndexPath(item: index - 1, section: 0), to: IndexPath(item: index, section: 0))
                    })
                    index = 0
                }
                index += 1
            }
        }
    }

    @IBAction func sortNearest(_ sender: UIButton) {
        let count = places.count
        self.nearestButton.isEnabled = false
        self.topRatedButton.isEnabled = true
        
        if count != 0 {
            var index = 1
            while index < count {
                if places[index - 1].distanceValue > places[index].distanceValue {
                    swap(&places[index - 1], &places[index])
                    UIView.animate(withDuration: 1, animations: {
                        self.collectionView.moveItem(at: IndexPath(item: index - 1, section: 0), to: IndexPath(item: index, section: 0))
                    })
                    index = 0
                }
                index += 1
            }
        }
    }
}

extension PlacesViewController {
    func finishPassing(places: [Place]) {
        self.places = places
        collectionView?.reloadData()
        print("Received the Places.")
    }
    
    func animateTextAppearence() {
        topRatedButton.transform = CGAffineTransform(translationX: -90, y: 0)
        nearestButton.transform = CGAffineTransform(translationX: 90, y: 0)
        mainTitleLabel.transform = CGAffineTransform(translationX: 0, y: -60)
        
        UIView.animate(withDuration: 0.5) {
            self.topRatedButton.transform = .identity
            self.nearestButton.transform = .identity
            self.mainTitleLabel.transform = .identity
        }
    }
}

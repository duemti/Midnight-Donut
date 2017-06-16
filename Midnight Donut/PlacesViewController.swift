//
//  PlacesViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/22/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import AVFoundation

private let firstReuseIdentifier = "Cell"
private let secondReuseIdentifier = "NoDataCell"

class PlacesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: Properties.
    let themeColor: [UIColor] = [UIColor(red:0.61, green:0.69, blue:0.49, alpha:1.0), UIColor(red:0.49, green:0.61, blue:0.69, alpha:1.0), UIColor(red:0.69, green:0.58, blue:0.49, alpha:1.0), UIColor(red:0.65, green:0.65, blue:0.00, alpha:1.0)]
    var allPlaces = [Place]()
    var favoritePlaces = [Place]()
    var places = [Place]() // is a variable that hold all places displayed in collection view in Comparing to allPlaces
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var topRatedButton: UIButton!
    @IBOutlet weak var nearestButton: UIButton!
    @IBOutlet weak var openNowButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var player: AVAudioPlayer? // Sound Variable
    
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
            let dayOfTheWeek = findDayOfTheWeek(Calendar.current.component(.weekday, from: Date()))
            
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
            cell.placeStatus.text = place.openNowText
            if let day = place.weekdays {
                cell.placeHours.text = day[dayOfTheWeek]
            } else {
                cell.placeHours.text = ""
            }
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
        
        if indexPath.row == places.count - 1 {
            print("loadding more ..")
            loadMorePlaces()
        }
    }
    /****************************************************************************************************************************************************************/
    
    // Load more Places.
    func loadMorePlaces() {
        // Network indicator.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Accessing first tab VC.
        let placesTab = self.tabBarController?.viewControllers?[0] as! FirstViewController
        
        if let next = placesTab.nextTokenResult {
            placesTab.getThePlaces(from: next) { (morePlaces, success) in
                if let morePlaces = morePlaces {
                    self.allPlaces += morePlaces
                    let startIndex = self.places.count
                    
                    // Filter result if user requested ONLY opened places.
                    if self.openNowButton.titleLabel?.text == "OPENED" {
                        var counter = 0
                        for place in morePlaces {
                            if place.openNowBool == true {
                                self.places.append(place)
                                counter += 1
                            } else {
                                print(place.openNowBool)
                            }
                        }
                        print("-\(counter)")
                        DispatchQueue.main.async {
                            self.reloadItemsFrom(index: startIndex, totalOf: counter)
                        }
                    }
                        // If user choose to be listed all places Even closed.
                    else {
                        self.places = self.allPlaces
                        DispatchQueue.main.async {
                            self.reloadItemsFrom(index: startIndex, totalOf: morePlaces.count)
                        }
                    }
                } else {
                    print("Returned Zero Results.")
                }
            }
        } else {
            print("No more Results.")
        }
        // Network indicator.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // Reload the item from collection view from specified position up.
    func reloadItemsFrom(index: Int, totalOf: Int) {
        var items = [IndexPath]()
        var counter: Int = index
        let until = index + totalOf
        
        while counter < until {
            items.append(IndexPath(item: counter, section: 0))
            counter += 1
        }
        
        if totalOf > 0 {
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: items)
            })
        }
    }
}

// MARK: - Action: Provide Directions on the Map.
extension PlacesViewController: CLLocationManagerDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PlacesCollectionViewCell {
            UIView.animate(withDuration: 0.25, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            }, completion: { (finished) in
                let maps = self.tabBarController?.viewControllers?[2] as! MapViewController
                maps.destinationPlace = self.places[indexPath.item]
                maps.findDirectionsToThePlace()
                
                UIView.animate(withDuration: 0.5, animations: { 
                    cell.transform = .identity
                }, completion: { (nil) in
                    self.tabBarController?.selectedIndex = 2
                })
            })
        }
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
    // Sorting the cells TOP RATED FIRST.
    @IBAction func sortTopRated(_ sender: UIButton) {
        self.nearestButton.isEnabled = true
        self.topRatedButton.isEnabled = false
        
        sortBy(top: true, nearest: false, the: self.places) { (finished) in
            if let finished = finished {
                self.places = finished
                
                // Refresh So that the user whould see cells swapping.
                self.refreshCells()
            }
        }
    }

    // Sorting the cells TO NEAREST.
    @IBAction func sortNearest(_ sender: UIButton) {
        self.nearestButton.isEnabled = false
        self.topRatedButton.isEnabled = true
        
        sortBy(top: false, nearest: true, the: self.places) { (finished) in
            if let finished = finished {
                self.places = finished
                
                // Refresh So that the user whould see cells swapping.
                self.refreshCells()
            }
        }
    }
    
    // The sorting function.
    func sortBy(top: Bool, nearest: Bool, the unsortedPlaces: [Place], completion: @escaping ([Place]?) -> ()) {
        var sorted = unsortedPlaces
        let count = sorted.count
        
        if count != 0 {
            var index = 1
            
            if nearest {
                while index < count {
                    if sorted[index - 1].distanceValue > sorted[index].distanceValue {
                        swap(&sorted[index - 1], &sorted[index])
                        index = 0
                    }
                    index += 1
                }
            } else if top {
                while index < count {
                    if sorted[index - 1].rating < sorted[index].rating {
                        swap(&sorted[index - 1], &sorted[index])
                        index = 0
                    }
                    index += 1
                }
            }
            completion( sorted )
        }
        completion( nil )
    }
    
    // Refresheshing So that the user whould see cells swapping.
    func refreshCells() {
        let count = places.count
        var index = 0
        
        while index != count {
            var cellIndex = 0
            let place = places[index].name!
            
            while cellIndex < count {
                guard let cell = collectionView.cellForItem(at: IndexPath(item: cellIndex, section: 0)) as? PlacesCollectionViewCell else {
                    cellIndex += 1
                    continue
                }
                if cell.placeName.text == place && index != cellIndex {
                    UIView.animate(withDuration: 1.5, animations: {
                        self.collectionView.performBatchUpdates({
                            self.collectionView.moveItem(at: IndexPath(item: cellIndex, section: 0), to: IndexPath(item: index, section: 0))
                            self.collectionView.moveItem(at: IndexPath(item: index, section: 0), to: IndexPath(item: cellIndex, section: 0))
                        })
                    })
                    break
                }
                cellIndex += 1
            }
            index += 1
        }
    }
    
    @IBAction func openNowAction(_ sender: UIButton) {
        if openNowButton.titleLabel?.text == "ALL" {
            places.removeAll()
            for place in allPlaces {
                if place.openNowBool == true {
                    places.append(place)
                }
            }
            openNowButton.setTitle("OPENED", for: .normal)
            collectionView.reloadData()
        } else {
            openNowButton.setTitle("ALL", for: .normal)
            self.places = self.allPlaces
            collectionView.reloadData()
        }
    }
    
    @IBAction func favoriteAction(_ sender: UIButton) {
        // kidding
        
        let path = Bundle.main.path(forResource: "glass-breaking.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            print("play")
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("couldn load")
        }
        
        self.favoriteButton.setImage(#imageLiteral(resourceName: "brokenHeart"), for: .disabled)
        self.favoriteButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.favoriteButton.isEnabled = true
        }
        
        // TODO: - Implement me.
        print("Implement favoriteAction()")
        if places.count == 0 {
            if let places = loadFavoritePlaces() {
                self.favoritePlaces = places
                self.collectionView.reloadData()
            }
        } else {
            saveToFavorite()
        }
    }
    
    private func saveToFavorite() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject( favoritePlaces, toFile: Place.ArchiveURL.path )
        
        if isSuccessfulSave {
            print("Saved with success")
        } else {
            print("Failed to save.")
        }
    }
    
    private func loadFavoritePlaces() -> [Place]? {
        print("Load ffavorite places ...")
        return NSKeyedUnarchiver.unarchiveObject(withFile: Place.ArchiveURL.path) as? [Place]
    }
}

extension PlacesViewController {
    // MARK: - Receiving Requested places from firstviewcontroller
    func finishPassing(places: [Place]) {
        self.places = places
        self.allPlaces = places
        
        if self.collectionView != nil {
            if openNowButton.titleLabel?.text == "OPENED" {
                self.places.removeAll()
                for place in allPlaces {
                    if place.openNowBool == true {
                        self.places.append(place)
                    }
                }
                collectionView.reloadData()
            } else {
                collectionView.reloadData()
            }
        }
        print("Received the \(places.count) Places.")
    }
    
    // MARK: - Some cool animation when VC is presented.
    func animateTextAppearence() {
        topRatedButton.transform = CGAffineTransform(translationX: -90, y: 0)
        nearestButton.transform = CGAffineTransform(translationX: 90, y: 0)
        mainTitleLabel.transform = CGAffineTransform(translationX: 0, y: -60)
        openNowButton.transform = CGAffineTransform(translationX: 0, y: -40)
        openNowButton.alpha = 0.0
        favoriteButton.alpha = 0.0
        
        UIView.animate(withDuration: 0.5) {
            self.topRatedButton.transform = .identity
            self.nearestButton.transform = .identity
            self.mainTitleLabel.transform = .identity
            self.openNowButton.transform = .identity
            self.openNowButton.alpha = 1.0
            self.favoriteButton.alpha = 1.0
        }
    }
    
    // MARK: - Return right day of the week.
    func findDayOfTheWeek(_ today: Int) -> Int {
        switch today {
        case 1:
            return 6
        case 2:
            return 0
        case 3:
            return 1
        case 4:
            return 2
        case 5:
            return 3
        case 6:
            return 4
        case 7:
            return 5
        default:
            return 0
        }
    }
}

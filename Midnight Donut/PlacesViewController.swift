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
    var nowShowingFavoritePlaces: Bool = false
    
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
            // Setting tag to know which button was pressed in order to add cell to favorite.
            cell.addToFavoriteButton.tag = indexPath.item
            if place.isFavorite {
                cell.addToFavoriteButton.setImage(#imageLiteral(resourceName: "fullHeart"), for: .normal)
            } else {
                cell.addToFavoriteButton.setImage(#imageLiteral(resourceName: "emptyHeart"), for: .normal)
            }

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
            if LIMIT_SEARCH_RETURN > 0 && nowShowingFavoritePlaces == false {
                print("loadding more ..")
                loadMorePlaces()
                LIMIT_SEARCH_RETURN -= 1
            }
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
                    // Check if it is favorite.
                    self.checkFavorite(forPlaces: morePlaces)
                    
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
        print("\(UIScreen.main.bounds.width - collectionView.bounds.width)")
        let size = CGSize(width: cellWidth, height: 160)
        return size
    }
}


// MARK: - Sorting Functions.
extension PlacesViewController {
    // Sorting the cells TOP RATED FIRST.
    @IBAction func sortTopRated(_ sender: UIButton) {
        // Beacause nearest sort is unavalable.
        if nowShowingFavoritePlaces == false {
            self.nearestButton.isEnabled = true
            self.topRatedButton.isEnabled = false
        }
        
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
        // Choosing which array of places to display based on user selection (favorite or all)
        let current = nowShowingFavoritePlaces ? favoritePlaces : allPlaces
        
        if openNowButton.titleLabel?.text == "ALL" {
            places.removeAll()
            for place in current {
                if place.openNowBool == true {
                    places.append(place)
                }
            }
            openNowButton.setTitle("OPENED", for: .normal)
            collectionView.reloadData()
        } else {
            openNowButton.setTitle("ALL", for: .normal)
            self.places = current
            collectionView.reloadData()
        }
    }
}

extension PlacesViewController {
    // MARK: - Receiving Requested places from firstviewcontroller
    func finishPassing(places: [Place]) {
        // Check if it is favorite.
        checkFavorite(forPlaces: places)
        
        self.allPlaces = places
        
        if nowShowingFavoritePlaces == false {
            self.places = places
            
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
        }
        print("Received the \(places.count) Places.")
    }
    
    func checkFavorite(forPlaces: [Place]) {
        // Check if it is favorite.
        for place in forPlaces {
            for fav in favoritePlaces {
                if fav.place_id == place.place_id {
                    place.isFavorite = true
                }
            }
        }
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

// MARK: - Favorite Implementation.
extension PlacesViewController {
    @IBAction func favoriteAction(_ sender: UIButton) { // up top button
        if nowShowingFavoritePlaces == false {
            // if user want to access favorite places.
            if favoritePlaces.isEmpty {
                self.favoritePlaces = loadFavoritePlaces() ?? [Place]()
            }
            self.places = favoritePlaces
            self.nearestButton.isEnabled = false
            self.favoriteButton.setImage(#imageLiteral(resourceName: "fullHeart"), for: .normal)
            nowShowingFavoritePlaces = true
        }
        else {
            // if user switched from favorite cell's.
            nowShowingFavoritePlaces = false
            self.favoriteButton.setImage(#imageLiteral(resourceName: "emptyHeart"), for: .normal)
            
            finishPassing(places: allPlaces)
        }
        self.collectionView.reloadData()
    }
    
    @IBAction func heartButton(_ sender: UIButton) { // cell button
        let place = places[sender.tag]
        
        // Check for duplicates - if duplicate then remove
        var index = 0
        let count = favoritePlaces.count
        
        while index < count {
            let favPlace = favoritePlaces[index]
            
            if favPlace.place_id == place.place_id {
                self.favoritePlaces.remove(at: index)
                places[sender.tag].isFavorite = false
                
                for place in allPlaces {
                    if place.place_id == favPlace.place_id {
                        place.isFavorite = false
                        
                        break
                    }
                }
                saveToFavorite()
                return
            }
            index += 1
        }
        
        
        place.isFavorite = true
        self.favoritePlaces.append(place)
        
        saveToFavorite()
    }
    
    private func saveToFavorite() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject( favoritePlaces, toFile: Place.ArchiveURL.path )
        
        if isSuccessfulSave {
            
            UIView.animate(withDuration: 0.25, animations: { 
                self.favoriteButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: { (nil) in
                UIView.animate(withDuration: 0.25, animations: { 
                    self.favoriteButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }, completion: { (nil) in
                    UIView.animate(withDuration: 0.25, animations: { 
                        self.favoriteButton.transform = .identity
                    })
                })
            })
            
            print("Saved with success")
        } else {
            print("Failed to save.")
        }
    }
    
    private func loadFavoritePlaces() -> [Place]? {
        print("load places")
        return NSKeyedUnarchiver.unarchiveObject(withFile: Place.ArchiveURL.path) as? [Place]
    }
}

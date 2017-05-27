//
//  PlacesCollectionViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/22/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

private let firstReuseIdentifier = "Cell"
private let secondReuseIdentifier = "NoDataCell"

class PlacesCollectionViewController: UICollectionViewController {
    
    //MARK: Properties.
    var places = [Place]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(PlacesCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }
    
    // Update tableview everytime it is entered.
    override func viewWillAppear(_ animated: Bool) {
        collectionView?.reloadData()
    }
    
    // changing navigation bar height.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = places.count
        return count == 0 ? 1 : count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if places.count != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: firstReuseIdentifier, for: indexPath) as! PlacesCollectionViewCell
            // Configure the cell...
            
            let place = places[indexPath.row]
            let address = place.formattedAddress.components(separatedBy: ",")
            
            cell.placeName.text = place.name
            cell.placeAddress.text = address[0]
            cell.placeRating.text = place.rating
            cell.placeStatus.text = place.openNow
            print("Places exists!")
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

extension PlacesCollectionViewController {
    func finishPassing(places: [Place]) {
        self.places = places
        print("Received the Places.")
    }
}

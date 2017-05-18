//
//  FirstViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/12/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation
import GooglePlacePicker

protocol SendDataThroughVCDelegate {
    func finishPassing(places: GMSPlaceLikelihoodList)
}

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: Properties.
    var placesClient: GMSPlacesClient!
    var locationManager = CLLocationManager()
    var delegate: SendDataThroughVCDelegate?

    // Labels to display info.
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
    }

    // Google Place
    @IBAction func getCurrentPlace(_ sender: UIButton) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Request permission to locate.
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global(qos: .default).async {
            self.placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
                if let error = error {
                    print("Pick Place error: \(error.localizedDescription)")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    return
                }
                
                if let placeLikelihoodList = placeLikelihoodList {
                    let placesTab = self.tabBarController?.viewControllers?[1] as! PlacesTableViewController
                    placesTab.finishPassing(places: placeLikelihoodList)
                    print("Sending the Places...")
                    
                    let place = placeLikelihoodList.likelihoods.first?.place
                    if let place = place {
                        DispatchQueue.main.async {
//                            self.nameLabel.text = place.name
//                            self.addressLabel.text = place.formattedAddress!
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    } else {
                        print("Can't get the address.")
                    }
                }
            })
        }
    }
    
    @IBOutlet weak var pickNameLabel: UILabel!
    @IBOutlet weak var pickAddressLabel: UILabel!
    // Google Place Picker
    @IBAction func pickThePlace(_ sender: UIButton) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePicker(config: config)
        
        placePicker.pickPlace(callback: { (place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place selected")
                return
            }
            
            self.pickNameLabel.text = place.name
            self.pickAddressLabel.text = place.formattedAddress!
            print("Place name \(place.name)")
            print("Place address \(place.formattedAddress)")
            print("Place attributions \(place.attributions)")
        })
    }
    
}


/*
 
 TODO:
 
 18. Midnight Donut.
 Sometimes you just have to have donuts – or whatever food you crave – in the
	middle of the night.
 Your app would tell a user what restaurants were still open around them at any time of the night.
 
 Is there any way to use Places API to suggest two people in one city place to meeting optimal for both of them with approximately the same ride duration from their locations?﻿

 API key for google Places: 
    AIzaSyBH9l0IodrxU3HS-l7tQlx8RR26H84ItwY
 
 */

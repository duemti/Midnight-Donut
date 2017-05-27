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

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: Properties.
    
    let KEY = "AIzaSyABjELFCIbnytefGjThre9r_A0DhTk9AVg"
    var allTags: [String] = ["bakery", "bar", "convenience_store", "grocery_or_supermarket", "meal_delivery", "meal_takeaway", "store", "gas_station"]
    var selectedTags: [String] = ["food", "cafe", "restaurant"]
    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    var places = [Place]()

    // Labels to display info.
    @IBOutlet weak var findAPlace: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customizing the button
        findAPlace.layer.cornerRadius = 5
        getPlaceInfo("ChIJd2HNqEt8yUARGqhGQCgGSKQ")
        placesClient = GMSPlacesClient.shared()
    }
    
    // Search for a place.
    @IBAction func getCurrentPlace(_ sender: UIButton) {
        // Request permission to locate.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        var showAlert = false
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted:
                print("No Location Access.")
            case .authorizedWhenInUse, .authorizedAlways:
                print("Location Access Granted.")
                getThePlaces()
            case .denied:
                showAlert = true
                print("Location Access Denied.")
            }
        } else {
            print("Location services are not enabled")
        }
        
        if showAlert {
            let alert = UIAlertController(title: "Please enable location from Settings->Midnight Donut", message: "Used to detect places near you.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Search place for detailed info.
extension FirstViewController {
    func getPlaceInfo(_ id: String) {
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(id)&key=\(KEY)")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print("Error while retrieving place info: \(error)")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any?]
                print(json)
            }catch let error {
                print("Error while parsing json: \(error)")//////////////////////////////////////
            }
        }
    }
}

// MARK: - Search for places.
extension FirstViewController {
    func getThePlaces() {
        //MARK: - Variables
        guard let location = locationManager.location?.coordinate else {
            print("Err: location is nil. \(locationManager.location)")
            return
        }
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?location=\(location.latitude),\(location.longitude)&type=\(selectedTags.joined(separator: "|"))&key=\(KEY)")
        URLSession.shared.dataTask(with: url!) { (data, respoonse, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any?]
                
                let results = json["results"] as! [[String: Any?]]
                for place in results {
                    var hours = [String]()
                    var status: Bool = false
                    var rating = "0"
                    // Initializing a new place.
                    let geometry = place["geometry"] as! [String: Any?]
                    // Check Open Status and if Exist Hours.
                    let openNow = place["opening_hours"] as? [String: Any?]
                    if openNow != nil {
                        status = openNow!["open_now"] as! Bool
                        hours = openNow!["weekday_text"] as! [String]
                        print("==>\(openNow?["weekday_text"])<==")
                    }
                    if place["rating"] != nil{//let val = place["rating"] as? String {
                        print("exists")
                        rating = String(format: "%.1f", place["rating"] as! Float)
                    }
                    let newPlace = Place(place["name"] as! String, rating, place["formatted_address"] as! String, place["place_id"] as! String, place["types"] as! [String], status ? "open" : "closed", hours, geometry["location"] as! [String: Double], geometry["viewport"] as! [String: [String: Double]])
                    
                    // Adding an place to places list.
                    self.places.append(newPlace)
                }
            }catch let error {
                print("Error while parsing json: \(error)")
            }
            
            let placesTab = self.tabBarController?.viewControllers?[1] as! PlacesCollectionViewController
            placesTab.finishPassing(places: self.places)
            print("==>Sending \(self.places.count) ...")
            }.resume()
    }
}

extension FirstViewController {
    func getCurrentTags() -> [Int: [String]] {
        return [0: allTags, 1: selectedTags]
    }
    
    func update(tags: [Int: [String]]) {
        allTags = tags[0]!
        selectedTags = tags[1]!
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

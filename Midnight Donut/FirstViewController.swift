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
    var allTags: [String] = ["food", "bakery", "bar", "convenience_store", "grocery_or_supermarket", "meal_delivery", "meal_takeaway", "store", "gas_station"]
    var selectedTags: [String] = ["cafe", "restaurant"]
    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    var places = [Place]()

    // Labels to display info.
    @IBOutlet weak var findAPlace: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customizing the Main BUTTON.
        findAPlace.layer.cornerRadius = 70
        findAPlace.layer.shadowColor = UIColor.white.cgColor
        findAPlace.layer.shadowOffset = CGSize(width: 5, height: 5)
        findAPlace.layer.shadowOpacity = 1.0
        
        let shadowPath = UIBezierPath(ovalIn: findAPlace.bounds)
        findAPlace.layer.shadowPath = shadowPath.cgPath
        
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
        let types = selectedTags.joined(separator: "|")
        print(types)
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?location=\(location.latitude),\(location.longitude)&types=cafe&key=\(KEY)") else {
            print("URL is nil.")
            return
        }
        print(url)
        URLSession.shared.dataTask(with: url) { (data, respoonse, error) in
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
                    if place["rating"] != nil{
                        rating = String(format: "%.1f", place["rating"] as! Float)
                    }
                    let newPlace = Place(place["name"] as! String, rating, place["formatted_address"] as! String, place["place_id"] as! String, place["types"] as! [String], status ? "open" : "closed", hours, geometry["location"] as! [String: Double], geometry["viewport"] as! [String: [String: Double]])
                    
                    // Adding an place to places list.
                    self.places.append(newPlace)
                }
            }catch let error {
                print("Error while parsing json: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                let placesTab = self.tabBarController?.viewControllers?[1] as! PlacesCollectionViewController
                placesTab.finishPassing(places: self.places)
                print("==>Sending \(self.places.count) ...")
                self.displayError(message: "Success", err: false)
            }
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

// Pop UP.
extension FirstViewController {
    func displayError(message: String, err: Bool) {
        let popup = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let label = UILabel()
        popup.backgroundColor = err ? UIColor(red:0.33, green:0.00, blue:0.00, alpha:1.0) : UIColor(red:0.00, green:0.27, blue:0.00, alpha:1.0)
        label.text = message
        label.textAlignment = .center
        label.textColor = .white
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        popup.addSubview(label)
        popup.addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: popup, attribute: .leading, multiplier: 1, constant: 0))
        popup.addConstraint(NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: popup, attribute: .trailing, multiplier: 1, constant: 0))
        popup.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: popup, attribute: .centerY, multiplier: 1, constant: 0))
        
        popup.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(popup)
        self.view.addConstraint(NSLayoutConstraint(item: popup, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
        self.view.addConstraint(NSLayoutConstraint(item: popup, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 8))
        self.view.addConstraint(NSLayoutConstraint(item: popup, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -8))
        self.view.addConstraint(NSLayoutConstraint(item: popup, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 20))
        
        // the alert view
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            popup.removeFromSuperview()
        }
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

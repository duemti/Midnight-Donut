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
    var allTags: [String] = ["food", "restaurant", "bakery", "bar", "convenience_store", "grocery_or_supermarket", "meal_delivery", "meal_takeaway", "store", "gas_station"]
    var selectedTags: [String] = ["cafe"]
    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    var places = [Place]()

    // Labels to display info.
    @IBOutlet weak var findAPlace: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* ========================        Customizing the Main BUTTON.   ========================= */
        applyDesignForMainButton()
        /* ========================================================================================= */
        
        let shadowPath = UIBezierPath(ovalIn: findAPlace.bounds)
        findAPlace.layer.shadowPath = shadowPath.cgPath

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
    func getInfoFor(place: Place) {
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place.place_id!)&key=\(KEY)") else {
            print("url is nil \(place.place_id!)")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error while retrieving place info: \(error)")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any?]
                
                let result = json["result"] as! [String: Any?]
                let status = json["status"] as! String
                if status == "OK" {
                    // Filling my place with VITAL DATA
                    if let workTime = result["opening_hours"] as? [String: Any?] {
                        if let openNow = workTime["open_now"] as? Bool {
                            place.setFor(openNow: openNow)
                        }
                        if let periods = workTime["periods"] as? [[String: [String: Any]]] {
                            place.setFor(periods: periods)
                        }
                        if let weekdayText = workTime["weekday_text"] as? [String] {
                            place.setFor(weekdays: weekdayText)
                        }
                    }
                    if let rating = result["rating"] as? Float {
                        place.setFor(rating: String(format: "%.1f", rating))
                    }
                } else if status == "OVER_QUERY_LIMIT" {
                    self.displayMessage(message: "Limit Reached for today 😭", err: true)
                }
                print("GOT: status->\(status)")
            }catch let error {
                print("Error while parsing json: \(error)")
            }
        }.resume()
    }
}

// Main Button Design.
extension FirstViewController {
    func applyDesignForMainButton() {
//        let textAttributes = [
//            NSStrokeColorAttributeName: UIColor(red:0.07, green:0.07, blue:0.07, alpha:1.0),
//            NSStrokeWidthAttributeName: -6.0,
//        ] as [String : Any]
//        let attributedTitle = NSAttributedString(string: "find a place", attributes: textAttributes)
//        findAPlace.setAttributedTitle(attributedTitle, for: .normal)
        
        findAPlace.layer.cornerRadius = 70
        findAPlace.backgroundColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:1.0)
        findAPlace.setTitleColor(UIColor(red:1.00, green:0.91, blue:0.64, alpha:1.0), for: .normal)
        findAPlace.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        findAPlace.titleLabel?.textAlignment = .center
        
        findAPlace.titleLabel?.layer.shadowOffset = CGSize(width: -2, height: 2)
        findAPlace.titleLabel?.layer.shouldRasterize = true
        findAPlace.titleLabel?.layer.shadowRadius = 1
        findAPlace.titleLabel?.layer.shadowOpacity = 1
        findAPlace.titleLabel?.layer.shadowColor = UIColor(red:0.07, green:0.07, blue:0.07, alpha:1.0).cgColor
        
        findAPlace.layer.shadowColor = UIColor(red:0.07, green:0.07, blue:0.07, alpha:1.0).cgColor
        findAPlace.layer.shadowOffset = CGSize(width: -5, height: 8)
        findAPlace.layer.shadowOpacity = 1.0
        // On Click.
        findAPlace.setTitleColor(UIColor(red:0.90, green:0.81, blue:0.54, alpha:1.0), for: .highlighted)
    }
}

// MARK: - Search for places.
extension FirstViewController {
    func getThePlaces() {
        // Clear previous Searches.
        if !self.places.isEmpty {
            self.places.removeAll()
        }
        //MARK: - Variables
        guard let location = locationManager.location?.coordinate else {
            print("Err: location is nil.")
            self.displayMessage(message: "Cannot Locate You 😥", err: true)
            return
        }
        let types = selectedTags.joined(separator: "|")
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?location=\(location.latitude),\(location.longitude)&types=\(types)&key=\(KEY)") else {
            print("URL is nil.")
            self.displayMessage(message: "Error, While searching... 🙁", err: true)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, respoonse, error) in
            if let error = error {
                print("Error: \(error)")
                self.displayMessage(message: "Error, Try Again, 🙁", err: true)
                return
            }
             
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any?]
                
                let results = json["results"] as! [[String: Any?]]
                for place in results {
                    // Initializing a new place.
                    let geometry = place["geometry"] as! [String: Any?]
                    // Instantiate a New Place.
                    let newPlace = Place(place["name"] as! String, place["formatted_address"] as! String, place["place_id"] as! String, place["types"] as! [String], geometry["location"] as! [String: Double], geometry["viewport"] as! [String: [String: Double]])
                    
                    // Adding an place to places list.
                    self.getInfoFor(place: newPlace)
                    self.places.append(newPlace)
                }
            }catch let error {
                print("Error while parsing json: \(error)")
                self.displayMessage(message: "An Error occured 😡", err: true)
                return
            }
            
            DispatchQueue.main.async {
                let placesTab = self.tabBarController?.viewControllers?[1] as! PlacesCollectionViewController
                placesTab.finishPassing(places: self.places)
                self.displayMessage(message: "You got Your Places! 😎", err: false)
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

// Custom Pop UP UIView.
extension FirstViewController {
    func displayMessage(message: String, err: Bool) {
        let popup = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let label = UILabel()
        popup.backgroundColor = err ? UIColor(red:0.33, green:0.00, blue:0.00, alpha:1.0) : UIColor(red:0.00, green:0.27, blue:0.00, alpha:1.0)
        popup.layer.cornerRadius = 6
        label.text = message
        label.textAlignment = .center
        label.textColor = .white
        label.alpha = 0.0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        popup.addSubview(label)
        popup.addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: popup, attribute: .leading, multiplier: 1, constant: 0))
        popup.addConstraint(NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: popup, attribute: .trailing, multiplier: 1, constant: 0))
        popup.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: popup, attribute: .centerY, multiplier: 1, constant: 0))
        
        popup.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(popup)
        self.view.addConstraint(NSLayoutConstraint(item: popup, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 8))
        self.view.addConstraint(NSLayoutConstraint(item: popup, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -8))
        self.view.addConstraint(NSLayoutConstraint(item: popup, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 20))
        // Animate Height.
        let height = NSLayoutConstraint(item: popup, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        animatePopup(item: popup, label: label, constraint: height, remove: false)
        
        
        // change to desired number of seconds (in this case 5 seconds)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.animatePopup(item: popup, label: label, constraint: height, remove: true)
        }
    }
    
    func animatePopup(item: UIView, label: UILabel, constraint: NSLayoutConstraint, remove: Bool) {
        self.view.layoutIfNeeded()
        if remove {
            constraint.constant = 0
        }
        UIView.animate(withDuration: 0.4, animations: { 
            self.view.addConstraint(constraint)
            if remove {
                label.alpha = 0.0
            } else {
                label.alpha = 1.0
            }
            self.view.layoutIfNeeded()
        }) { (finished) in
            if remove {
                item.removeFromSuperview()
            }
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

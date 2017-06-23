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

private let validSearchColor: UIColor = UIColor(red:0.52, green:0.55, blue:0.42, alpha:1.0)
private let invalidSearchColor: UIColor = UIColor(red:0.61, green:0.29, blue:0.30, alpha:1.0)
private let highlightSearchColor: UIColor = UIColor(red:1.00, green:0.91, blue:0.64, alpha:1.0)

var USER_LOCATION: CLLocationCoordinate2D?

// Custom button.
class mainButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.isHighlighted {
                    self.backgroundColor = highlightSearchColor
                    self.layer.shadowOffset = CGSize(width: 0, height: 3)
                    self.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 0)
                    self.titleLabel?.layer.shadowRadius = 0
                } else {
                    self.backgroundColor = LIMIT_SEARCH > 0 ? validSearchColor : invalidSearchColor
                    self.layer.shadowOffset = CGSize(width: 0, height: 8)
                    self.titleLabel?.layer.shadowOffset = CGSize(width: -1, height: 1)
                    self.titleLabel?.layer.shadowRadius = 1
                }
            }
        }
    }
}

class FirstViewController: UIViewController {
    
    //MARK: - Properties.
    
    let KEY = "AIzaSyABjELFCIbnytefGjThre9r_A0DhTk9AVg" // Google Places API Key.
    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    var nextTokenResult: String? = nil
    var READY_TO_SEND: Int = 0

    // Labels to display info.
    @IBOutlet weak var findAPlace: mainButton!
    @IBOutlet weak var moonDonutImage: UIImageView!
    @IBOutlet weak var nameOfAppImage: UIImageView!
    @IBOutlet weak var leftHillImage: UIImageView!
    @IBOutlet weak var rightHillImage: UIImageView!
    @IBOutlet weak var centerHillImage: UIImageView!
    @IBOutlet weak var remainSearchesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* ========================        Customizing the Main BUTTON.   ========================= */
        applyDesignForMainButton()
        /* ========================================================================================= */
        
        // Request permission to locate.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        placesClient = GMSPlacesClient.shared()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        animateAppearing()
        // debug
        print(TAGS)
        remainSearchesLabel.text = "Remain searches: \(LIMIT_SEARCH!)"
    }
    
    // Search for a place.
    @IBAction func getCurrentPlace(_ sender: UIButton) {
        var showAlert = false
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted:
                print("No Location Access.")
            case .authorizedWhenInUse, .authorizedAlways:
                print("loacation access gran`ted.")
                
                // Making query to search places.
                if LIMIT_SEARCH > 0, let location = USER_LOCATION {
                    getThePlaces(from: "location=\(location.latitude),\(location.longitude)&radius=1000&types=\(TAGS.joined(separator: "|"))&key=\(KEY)", completion: { (newPlaces, success) in
                        if let places = newPlaces, success {
                            print("Good \(success) -> \(places.count)")
                            
                            self.getInfoFor(places: places, completion: { () in
                                DispatchQueue.main.async {
                                    self.sendPlacesToPlacesVC(places: places)
                                    self.displayMessage(message: "You got Your Places! 😎", err: false)
                                    /****/
                                    LIMIT_SEARCH = LIMIT_SEARCH - 1
                                    UserDefaults.standard.set(String(LIMIT_SEARCH), forKey: "limitSearch") // updation limit on user defaults.
                                    LIMIT_SEARCH_RETURN = 1
                                    self.remainSearchesLabel.text = "Remain searches: \(LIMIT_SEARCH!)"
                                    /****/
                                    self.tabBarController?.selectedIndex = 1
                                }
                            })
                        }
                    })
                } else {
                    self.displayMessage(message: "You Reached Today's Limit 😐", err: false, yellow: true)
                }
                // END.
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

// MARK: - Update tags.
extension FirstViewController: TypesTableViewControllerDelegate {
    func updateTags(_ types: [String]) {
        TAGS = types
        UserDefaults.standard.set(TAGS, forKey: "types")
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - CLLocationManagerDelegate
extension FirstViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("=> \(location)")
            USER_LOCATION = location.coordinate
            locationManager.stopUpdatingLocation()
        }
    }
}

// MARK: - Search place for detailed info. // Request #->R2
extension FirstViewController {
    func getInfoFor(places: [Place], completion: @escaping () -> ()) {
        for place in places {
            guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place.place_id!)&key=\(KEY)") else {
                print("url is nil #->R2")
                return
            }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error while retrieving place info: \(error)")
                    return
                }
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any?]
                        
                        let status = json["status"] as! String
                        if status == "OK" {
                            let result = json["result"] as! [String: Any?]
                            
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
                                place.setFor(rating: rating)
                            }
                        } else {
                            self.googleError(status: status, requestNumber: "#->R2")
                        }
                    }catch let error {
                        print("Error while parsing json: \(error)")
                    }
                }
                
                if places.last?.place_id == place.place_id {
                    completion()
                }
            }.resume()
        }
    }
    
    func googleError(status: String, requestNumber: String) {
        switch status {
        case "ZERO_RESULTS":
            print("Error: \(status) in \(requestNumber)")
        case "OVER_QUERY_LIMIT":
            print("Error: \(status) in \(requestNumber)")
        default:
            print("Error: \(status) in \(requestNumber)")
        }
    }
}

// MARK: - Search for places. // Request #R1
extension FirstViewController {
    func getThePlaces(from query: String, completion: @escaping ([Place]?, Bool) -> Void) {
        var newPlaces = [Place]()
        
        //MARK: - Variables
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?\(query)") else {
            print("URL is nil.")
            self.displayMessage(message: "Error, While searching... 🙁", err: true)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, respoonse, error) in
            if let error = error {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.displayMessage(message: "Error, Try Again, 🙁", err: true)
                }
                return
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any?]
                    
                    let results = json["results"] as! [[String: Any?]]
                    let status = json["status"] as! String
                    
                    print(status)
                    if status == "OK" {
                        if let nextToken = json["next_page_token"] as? String {
                            self.nextTokenResult = "pagetoken=\(nextToken)&key=\(self.KEY)"
                        } else {
                            self.nextTokenResult = nil
                        }
                        
                        for place in results {
                            // Initializing a new place.
                            guard let geometry = place["geometry"] as? [String: Any?] else {
                                print("1")
                                return
                            }
                            guard let address = place["formatted_address"] as? String else {
                                print("2")
                                return
                            }
                            guard let name = place["name"] as? String else {
                                print("3")
                                return
                            }
                            guard let placeId = place["place_id"] as? String else {
                                print("4")
                                return
                            }
                            guard let types = place["types"] as? [String] else {
                                print("5")
                                return
                            }
                            guard let location = geometry["location"] as? [String: Double] else {
                                print("6")
                                return
                            }
                            guard let viewport = geometry["viewport"] as? [String: [String: Double]] else {
                                print("7")
                                return
                            }
                            
                            // Instantiate a New Place.
                            let newPlace = Place(name, address, placeId, types, viewport)
                            
                            if let openNow = place["opening_hours"] as? [String: Any?], let on = openNow["open_now"] as? Bool {
                                newPlace.setFor(openNow: on)
                            }
                            newPlace.setFor(location: CLLocationCoordinate2D(latitude: location["lat"]!, longitude: location["lng"]!))
                            
                            // Adding an place to places list.
                            newPlaces.append(newPlace)
                        }
                        completion(newPlaces, true)
                    } else if status == "ZERO_RESULTS" {
                        DispatchQueue.main.async {
                            self.displayMessage(message: "Zero Results.", err: false, yellow: true)
                        }
                        completion(newPlaces, false)
                    } else if status == "OVER_QUERY_LIMIT" {
                        self.displayMessageAsync("Limit Reached for today 😭", true)
                        completion(newPlaces, false)
                    } else {
                        self.displayMessageAsync("An Error occured 😡", true)
                        completion(newPlaces, false)
                    }
                }catch let error {
                    self.displayMessageAsync("An Error occured 😡", true)
                    print("Error while parsing json: \(error)")
                    completion(newPlaces, false)
                }
            }
        }.resume()
    }
}

// MARK: - Comunication with other Tab Bar Controller.
extension FirstViewController {
    func sendPlacesToPlacesVC(places: [Place]) {
        let placesTab = self.tabBarController?.viewControllers?[1] as! PlacesViewController
        placesTab.finishPassing(places: places)
    }
}

// Custom Pop UP UIView.
extension FirstViewController {
    func displayMessageAsync(_ msg: String, _ err: Bool) {
        DispatchQueue.main.async {
            self.displayMessage(message: msg, err: err)
        }
    }
    
    func displayMessage(message: String, err: Bool, yellow: Bool? = false) {
        let popup = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let label = UILabel()
        if yellow == true {
            popup.backgroundColor = UIColor(red:0.85, green:0.90, blue:0.40, alpha:1.0)
        } else {
            popup.backgroundColor = err ? UIColor(red:0.33, green:0.00, blue:0.00, alpha:1.0) : UIColor(red:0.00, green:0.27, blue:0.00, alpha:1.0)
        }
        popup.layer.cornerRadius = 6
        
        label.textColor = yellow! ? UIColor(red:0.07, green:0.10, blue:0.11, alpha:1.0) : UIColor(red:1.00, green:0.91, blue:0.64, alpha:1.0)
        
        label.text = message
        label.font = UIFont(name: "Sniglet-Regular", size: 16)
        label.textAlignment = .center
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

// Main Button Design.
extension FirstViewController {
    func applyDesignForMainButton() {
        findAPlace.layer.cornerRadius = 70
        findAPlace.backgroundColor = LIMIT_SEARCH > 0 ? validSearchColor : invalidSearchColor
        findAPlace.setTitleColor(UIColor(red:1.00, green:0.91, blue:0.64, alpha:1.0), for: .normal)
        
        findAPlace.titleLabel?.textAlignment = .center
        findAPlace.titleLabel?.layer.shadowOffset = CGSize(width: -1, height: 1)
        findAPlace.titleLabel?.layer.shouldRasterize = true
        findAPlace.titleLabel?.layer.shadowRadius = 1
        findAPlace.titleLabel?.layer.shadowOpacity = 2
        findAPlace.titleLabel?.layer.shadowColor = UIColor(red:0.07, green:0.07, blue:0.07, alpha:1.0).cgColor
        
        findAPlace.layer.shadowColor = UIColor(red:0.07, green:0.07, blue:0.07, alpha:1.0).cgColor
        findAPlace.layer.shadowOffset = CGSize(width: -5, height: 8)
        findAPlace.layer.shadowOpacity = 1.0
        
        // On Click.
        findAPlace.setTitleColor(UIColor(red:0.07, green:0.10, blue:0.11, alpha:1.0), for: .highlighted)
    }
}

extension FirstViewController {
    func animateAppearing() {
        self.leftHillImage.transform = CGAffineTransform(translationX: 0, y: 50)
        self.rightHillImage.transform = CGAffineTransform(translationX: 0, y: 50)
        self.centerHillImage.transform = CGAffineTransform(translationX: 0, y: 20)
        
        self.moonDonutImage.transform = CGAffineTransform(translationX: 90, y: -90).rotated(by: 90)
        self.nameOfAppImage.alpha = 0.0
        
        self.findAPlace.transform = CGAffineTransform(translationX: 0, y: 100).rotated(by: 90)
        self.findAPlace.alpha = 0.0
        
        remainSearchesLabel.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.7, animations: {
            self.centerHillImage.transform = .identity
            self.moonDonutImage.transform = CGAffineTransform(translationX: -15, y: 15).rotated(by: -45)
            self.nameOfAppImage.alpha = 0.9
        }) { (success) in
            UIView.animate(withDuration: 2.0, animations: {
                self.leftHillImage.transform = .identity
                self.rightHillImage.transform = .identity
                self.remainSearchesLabel.transform = .identity
            })
            
            UIView.animate(withDuration: 0.5, animations: {
                self.findAPlace.transform = .identity
                self.findAPlace.alpha = 1.0
                self.moonDonutImage.transform = .identity
            })
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

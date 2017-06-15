//
//  MapViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 6/1/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    // MARK: - Properties.
    var mapView: GMSMapView?
    var source = CLLocationCoordinate2D(latitude: 47.039902113355559, longitude: 28.824365403191109)
    var destinationPlace: Place? = nil
    
    var distanceText: String?
    var durationText: String?
    
    // MARK: - Outlets.
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var clockImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: 47.039867, longitude: 28.824547, zoom: 16)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView!.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
        
        view = mapView
        let tap = UITapGestureRecognizer(target: self, action: #selector (self.goToPlacesTab(_:)))
        infoView.addGestureRecognizer( tap )
        infoView.isUserInteractionEnabled = true
        
        infoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoView)
        view.addConstraints( [NSLayoutConstraint(item: infoView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0), NSLayoutConstraint(item: infoView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 50)] )
    }
    
    // Container display.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if destinationPlace == nil {
            print("No place selected for directions.")
            distanceLabel.text = "Select a Place"
            timeLabel.isHidden = true
            clockImageView.isHidden = true
        } else {
            timeLabel.isHidden = false
            clockImageView.isHidden = false
            self.distanceLabel.text = self.distanceText
            self.timeLabel.text = self.durationText
        }
    }
    
    // Throw user to another tap.
    func goToPlacesTab(_ sender: UITapGestureRecognizer) {
        print("tap segue.")
        self.tabBarController?.selectedIndex = 1
    }
    
    func seValue(for place: Place) {
        self.destinationPlace = place
    }
}

extension MapViewController {
    func findDirectionsToThePlace() {
        let origin: CLLocationCoordinate2D = source
        let place_id: String = (destinationPlace?.place_id)!
        let key = "AIzaSyCPBu09mUuPcNZSZg9qfT-PV3xjKVf4Fw4" // Google Directions API Key.
        let stringURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=place_id:\(place_id)&key=\(key)"
        guard let url = URL(string: stringURL) else {
            print("Error: Direction URL is nul.")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any?]
                let status = json["status"] as! String
                
                print(status)
                if status == "OK" {
                    let routes = json["routes"] as! [[String: Any?]]
                    
                    let route = routes[0]["overview_polyline"] as! [String: String]
                    let polyline = route["points"]!
                    
                    let legs = routes[0]["legs"] as! [[String: Any?]]
                    
                    if let distance = legs[0]["distance"] as? [String: Any], let distanceText = distance["text"] as? String {
                        self.distanceText = distanceText
                    } else {
                        self.distanceText = "n/a"
                    }
                    
                    if let duration = legs[0]["duration"] as? [String: Any], let durationText = duration["text"] as? String {
                        self.durationText = durationText
                    } else {
                        self.durationText = "n/a"
                    }
                    
                    DispatchQueue.main.async {
                        self.drawRoute(with: polyline)
                    }
                } else {
                    print("Error: Direction API - Status: \(status)")
                }
            } catch let error {
                print("Error: Map - while parsing json - \(error).")
            }
        }.resume()
    }
    
    func drawRoute(with polyline: String) {
        // add Markers
        let marker1 = GMSMarker()
        let marker2 = GMSMarker()
        
        marker1.position = source
        marker1.title = "Start"
        marker1.map = self.mapView
        
        marker2.position = destinationPlace!.location
        marker2.title = "Finish"
        marker2.map = self.mapView
        // Draw route
        let path: GMSPath = GMSPath(fromEncodedPath: polyline)!
        let routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 10
        routePolyline.strokeColor = UIColor(red:1.00, green:0.91, blue:0.64, alpha:1.0)
        routePolyline.map = self.mapView
    }
}

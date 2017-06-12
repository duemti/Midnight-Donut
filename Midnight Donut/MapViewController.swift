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
        if let destination = destinationPlace {
            findDirectionsToThePlace()
        }
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
                
                if status == "OK" {
                    let routes = json["routes"] as! [[String: Any?]]
                    let route = routes[0]["overview_polyline"] as! [String: String]
                    let polyline = route["points"]!
                    
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
        
        routePolyline.map = self.mapView
    }
}

//
//  MapViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 6/1/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class MapViewController: UIViewController {

    // MARK: - Properties.
    var destinationPlace: Place? = nil
    
    var Route = ( polyline: GMSPolyline(), bounds: ( northeast: CLLocationCoordinate2D(), southwest: CLLocationCoordinate2D() ) )
    var markers = (start: GMSMarker(), end: GMSMarker())
    
    var distanceText: String?
    var durationText: String?
    
    // MARK: - Outlets.
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var clockImageView: UIImageView!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.isMyLocationEnabled = true
        
        // Setting camera view.
        if let origin = USER_LOCATION {
            print("=>origin: \(origin)<=")
            let camera = GMSCameraPosition.camera(withLatitude: origin.latitude, longitude: origin.longitude, zoom: 16)
            mapView.camera = camera
        } else {
            mapView = GMSMapView(frame: self.view.bounds)
        }
        
        
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
        
        // first time opened tabBar.
        if let origin = USER_LOCATION, destinationPlace != nil {
            self.drawRoute(polyline: Route.polyline, userOrigin: origin, completion: {
                self.updateCamera(north: self.Route.bounds.northeast, south: self.Route.bounds.southwest)
            })
        }
    }
    
    // Container display.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // See if user actually choosed a place or not.
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
    
    func seValue(for place: Place) {
        self.destinationPlace = place
    }
}

extension MapViewController {
    func findDirectionsToThePlace() {
        if let origin = USER_LOCATION {
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
                        
                        // Getting coordinates to set mapView to see full path.
                        let bounds = routes[0]["bounds"] as! [String: Any]
                        let northBounds = bounds["northeast"] as! [String: CLLocationDegrees]
                        let northeast = CLLocationCoordinate2D(latitude: northBounds["lat"]!, longitude: northBounds["lng"]!)
                        let southBounds = bounds["southwest"] as! [String: CLLocationDegrees]
                        let southwest = CLLocationCoordinate2D(latitude: southBounds["lat"]!, longitude: southBounds["lng"]!)
                        
                        
                        // Draw route
                        let path: GMSPath = GMSPath(fromEncodedPath: polyline)!
                        let routePolyline = GMSPolyline(path: path)
                        routePolyline.strokeWidth = 10
                        routePolyline.strokeColor = UIColor(red:0.69, green:0.58, blue:0.49, alpha:1.0)
                        
                        // Adding polyline to array.
                        self.Route.polyline.map = nil
                        self.Route.polyline = routePolyline
                        self.Route.bounds.northeast = northeast
                        self.Route.bounds.southwest = southwest
                        
                        DispatchQueue.main.async {
                            self.drawRoute(polyline: routePolyline, userOrigin: origin, completion: {
                                self.updateCamera(north: northeast, south: southwest)
                            })
                        }
                    } else {
                        print("Error: Direction API - Status: \(status)")
                    }
                } catch let error {
                    print("Error: Map - while parsing json - \(error).")
                }
            }.resume()
        } else {
            addMarkerToPlace()
        }
    }
    
    func drawRoute(polyline: GMSPolyline, userOrigin: CLLocationCoordinate2D, completion: @escaping () -> ()) {
        
        // Clearing markers.
        markers.start.map = nil
        markers.end.map = nil
        
        // add Markers
        let marker1 = GMSMarker()
        let marker2 = GMSMarker()
        
        marker1.position = userOrigin
        marker1.title = "Start"
        marker1.icon = #imageLiteral(resourceName: "startPin")
        marker1.map = self.mapView
        
        marker2.position = destinationPlace!.location
        marker2.title = "Finish"
        marker2.icon = #imageLiteral(resourceName: "destinationPin")
        marker2.map = self.mapView

        markers.start = marker1
        markers.end = marker2
        
        // Drawing the route on the map.
        polyline.map = self.mapView
        
        completion()
    }
    
    func addMarkerToPlace() {
        let marker = GMSMarker()
        
        marker.title = "destination"
        marker.icon = #imageLiteral(resourceName: "destinationPin")
        marker.map = self.mapView
        
        markers.end = marker
    }
}

extension MapViewController {
    // Update view on map.
    func updateCamera(north: CLLocationCoordinate2D, south: CLLocationCoordinate2D) {
        let bounds = GMSCoordinateBounds(coordinate: north, coordinate: south)
        let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 60)
        self.mapView?.animate(with: cameraUpdate)
    }
}

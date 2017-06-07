//
//  MapViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 6/1/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Properties.
    @IBOutlet weak var mapView: MKMapView!
    var s: CLLocationCoordinate2D?
    var d: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        drawDirectionOnTheMAp()
    }
    
    func drawDirectionOnTheMAp() {
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.7127, longitude: -74.0059), addressDictionary: nil))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.783333, longitude: -122.416667), addressDictionary: nil))
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
            print("=>\(route.polyline)<=")
            self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
            
            // Set map Region To see the direction.
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .green
        return renderer
    }
}

extension MapViewController {
//    func findDirectionsToThePlace(origin: CLLocationCoordinate2D, destination place_id: String) {
//        let key = "AIzaSyCPBu09mUuPcNZSZg9qfT-PV3xjKVf4Fw4" // Google Directions API Key.
//        let stringURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=place_id:\(place_id)&key=\(key)"
//        guard let url = URL(string: stringURL) else {
//            print("Error: Direction URL is nul.")
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//            
//            do {
//                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any?]
//                print(json)
//            } catch let error {
//                print("Error: Map - while parsing json - \(error).")
//            }
//        }
//        
//    }
}

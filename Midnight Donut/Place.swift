//
//  Place.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/23/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import CoreLocation

class Place: NSObject {
    let name: String!
    let formattedAddress: String!
    let place_id: String!
    let tags: [String]!
    let viewport: [String: [String: Double]]
    var location = CLLocationCoordinate2D()
    
    var distanceText: String = "n/a"
    var distanceValue: Int = 0
    
    // Optionals.
    var rating: Float = 0.0
    var openNow: String = "n/a"
    var weekdays: [String]? = nil
    var periods: [[String: [String: Any]]]? = nil
    
    init(_ name: String, _ address: String, _ place_id: String, _ tags: [String], _ location: [String: Double], _ viewport: [String: [String: Double]]) {
        self.name = name
        self.formattedAddress = address
        self.place_id = place_id
        self.tags = tags
        self.location.latitude = location["lat"]!
        self.location.longitude = location["lng"]!
        self.viewport = viewport
    }
    
    override var description: String {
        return "{name: \(self.name!), rating: \(self.rating), address: \(self.formattedAddress!)}"
    }
}

// MARK: - Constructors.
extension Place {
    func setFor(openNow: String) {
        self.openNow = openNow
    }
    
    func setFor(weekdays: [String]) {
        self.weekdays = weekdays
    }
    
    func setFor(rating: Float) {
        self.rating = rating
    }
    
    func setFor(periods: [[String: [String: Any]]]) {
        self.periods = periods
    }
    
    func setFor(distanceText: String, distanceValue: Int) {
        self.distanceText = distanceText
        self.distanceValue = distanceValue
    }
}

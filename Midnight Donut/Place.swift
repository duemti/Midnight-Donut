//
//  Place.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/23/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

class Place: NSObject {
    let name: String!
    let formattedAddress: String!
    let place_id: String!
    let tags: [String]!
    let location: [String: Double]
    let viewport: [String: [String: Double]]
    
    // Optionals.
    var rating: String? = nil
    var openNow: Bool = false
    var weekdays: [String]? = nil
    var periods: [[String: [String: Any]]]? = nil
    
    init(_ name: String, _ address: String, _ place_id: String, _ tags: [String], _ location: [String: Double], _ viewport: [String: [String: Double]]) {
        self.name = name
        self.formattedAddress = address
        self.place_id = place_id
        self.tags = tags
        self.location = location
        self.viewport = viewport
    }
    
    override var description: String {
        return "{name: \(self.name!), rating: \(self.rating!), address: \(self.formattedAddress!)}"
    }
}

// MARK: - Constructors.
extension Place {
    func setFor(openNow: Bool) {
        self.openNow = openNow
    }
    
    func setFor(weekdays: [String]) {
        self.weekdays = weekdays
    }
    
    func setFor(rating: String) {
        self.rating = rating
    }
    
    func setFor(periods: [[String: [String: Any]]]) {
        self.periods = periods
    }
}

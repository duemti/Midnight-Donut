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
    let rating: String!
    let formattedAddress: String!
    let place_id: String!
    let tags: [String]!
    let openNow: String!
    let hours: [String]?
    
    let location: [String: Double]
    let viewport: [String: [String: Double]]
    
    init(_ name: String, _ rating: String, _ address: String, _ place_id: String, _ tags: [String], _ openNow: String, _ hours: [String]?, _ location: [String: Double], _ viewport: [String: [String: Double]]) {
        self.name = name
        self.rating = rating
        self.formattedAddress = address
        self.place_id = place_id
        self.tags = tags
        self.openNow = openNow
        self.hours = hours
        self.location = location
        self.viewport = viewport
    }
    
    override var description: String {
        return "{name: \(self.name!), rating: \(self.rating!), address: \(self.formattedAddress!)}"
    }
}

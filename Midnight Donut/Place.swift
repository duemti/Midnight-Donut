//
//  Place.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/23/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import CoreLocation

class Place: NSObject, NSCoding {
    // MARKS: - Properties.
    let name: String!
    let formattedAddress: String!
    let place_id: String!
    let tags: [String]!
    let viewport: [String: [String: Double]]
    var location = CLLocationCoordinate2D()
    
    var distanceText: String = "n/a"
    var distanceValue: Int = 0
    
    var isFavorite: Bool = false
    
    // Optionals.
    var rating: Float = 0.0
    var openNowText: String = "n/a"
    var openNowBool: Bool = false
    var weekdays: [String]? = nil
    var periods: [[String: [String: Any]]]? = nil
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("places")
    
    //MARK: - Types
    struct PropertyKey {
        static let name = "name"
        static let address = "address"
        static let placeId = "placeID"
        static let lat = "lat"
        static let lng = "lng"
        static let rating = "rating"
        static let workDays = "workDays"
        static let periods = "periods"
    }
    
    init(_ name: String, _ address: String, _ place_id: String, _ tags: [String], _ viewport: [String: [String: Double]]) {
        self.name = name
        self.formattedAddress = address
        self.place_id = place_id
        self.tags = tags
        self.viewport = viewport
    }
    
    override var description: String {
        return "{name: \(self.name!), rating: \(self.rating), address: \(self.formattedAddress!)}"
    }
    
    //MARK: - NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(formattedAddress, forKey: PropertyKey.address)
        aCoder.encode(place_id, forKey: PropertyKey.placeId)
        aCoder.encode(location.latitude, forKey: PropertyKey.lat)
        aCoder.encode(location.longitude, forKey: PropertyKey.lng)
        aCoder.encode(rating, forKey: PropertyKey.rating)
        aCoder.encode(weekdays, forKey: PropertyKey.workDays)
        aCoder.encode(periods, forKey: PropertyKey.periods)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String, let address = aDecoder.decodeObject(forKey: PropertyKey.address) as? String, let placeId = aDecoder.decodeObject(forKey: PropertyKey.placeId) as? String else {
            print("ERROR: Unable some elements")
            return nil
        }
        let lat = aDecoder.decodeDouble(forKey: PropertyKey.lat)
        let lng = aDecoder.decodeDouble(forKey: PropertyKey.lng)
        let rating = aDecoder.decodeFloat(forKey: PropertyKey.rating)
        
        // Conditional cast.
        let workDays = aDecoder.decodeObject(forKey: PropertyKey.workDays) as? [String]
        let periods = aDecoder.decodeObject(forKey: PropertyKey.periods) as? [[String: [String: Any]]]
        
        // Must call designated initializer.
        self.init(name, address, placeId, ["cafe"], ["text":["text":0.0]])
        
        self.setFor(rating: rating)
        self.setFor(weekdays: workDays)
        self.setFor(location: CLLocationCoordinate2D(latitude: lat, longitude: lng))
        if let periods = periods {
            self.setFor(periods: periods)
        }
        self.isFavorite = true
    }
}

// MARK: - Constructors.
extension Place {
    func setFor(openNow: Bool) {
        self.openNowText = openNow ? "OPEN Now" : "Closed Now"
        self.openNowBool = openNow
    }
    
    func setFor(weekdays: [String]?) {
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
    func setFor(location: CLLocationCoordinate2D) {
        self.location = location
    }
}

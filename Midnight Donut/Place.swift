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
        static let location = "location"
        static let rating = "rating"
        static let workDays = "workDays"
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
//        aCoder.encode(location, forKey: PropertyKey.location)
        aCoder.encode(rating, forKey: PropertyKey.rating)
        aCoder.encode(weekdays, forKey: PropertyKey.workDays)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String, let address = aDecoder.decodeObject(forKey: PropertyKey.address) as? String, let placeId = aDecoder.decodeObject(forKey: PropertyKey.placeId) as? String/*, let location = aDecoder.decodeObject(forKey: "location") as? CLLocationCoordinate2D*/ else {
            print("Unable to decode the name")
            return nil
        }
        
        // Because other are optional property of Place, just use conditional cast.
        let workDays = aDecoder.decodeObject(forKey: PropertyKey.address) as? [String]
        let rating = aDecoder.decodeObject(forKey: "rating") as? Float ?? 0.0
        
        // Must call designated initializer.
        self.init(name, address, placeId, ["cafe"], ["text":["text":0.0]])
        
        self.setFor(rating: rating)
        self.setFor(weekdays: workDays)
//        self.setFor(location: location)
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

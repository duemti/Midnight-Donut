//
//  AppDelegate.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/12/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

var LIMIT_SEARCH: Int! // Limited to search places per day.
var LIMIT_SEARCH_RETURN: Int = 1 // Limited to get more result from 1 search.
var LIMIT_DIRECTION: Int! // Limited for using google directions.
var TAGS: [String] = ["restaurant"]
var nonConsumablePurchaseMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseMade") // TravelMode state, if unlockked.

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Google Places API Key.
        GMSPlacesClient.provideAPIKey("AIzaSyBH9l0IodrxU3HS-l7tQlx8RR26H84ItwY")
        GMSServices.provideAPIKey("AIzaSyBH9l0IodrxU3HS-l7tQlx8RR26H84ItwY")
        
        // Customizing Tab Bar Controller my Way.
        UITabBar.appearance().tintColor = UIColor(red:1.00, green:0.91, blue:0.64, alpha:1.0)
        UITabBar.appearance().barTintColor = UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.0)
        UITabBarItem.appearance().setTitleTextAttributes( [NSFontAttributeName: UIFont(name: "Sniglet-Regular", size: 10)!] , for: .normal)
        
        
        // Taking care of restoring or not the limit of search.
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM"
        
        let todaysDate = formatter.string(from: Date()) // Current date.
        let defaults = UserDefaults.standard
        var storedDate = defaults.string(forKey: "date") // date retrieved from user defaults
        let limitSearch = defaults.string(forKey: "limitSearch") // Current status of how many more searches can perform user.
        let limitDirection = defaults.string(forKey: "limitDirection") // How many direction requests can perform user.
        let types = defaults.array(forKey: "types") as? [String] // Places types saved.
        
        if storedDate == nil {
            defaults.set(todaysDate, forKey: "date")
            storedDate = todaysDate
        }
        
        if types == nil { // Only first time app is opened.
            defaults.set(TAGS, forKey: "types")
        } else {
            TAGS = types!
        }
        
        if limitDirection == nil { // Only first time app is opened.
            LIMIT_DIRECTION = 10
            defaults.set(String(LIMIT_DIRECTION), forKey: "limitDirection")
        } else {
            LIMIT_DIRECTION = Int(limitDirection!) // setting returned remaining searches.
        }
        
        if limitSearch == nil { // Only first time app is opened.
            LIMIT_SEARCH = 5
            defaults.set(String(LIMIT_SEARCH), forKey: "limitSearch")
        } else {
            LIMIT_SEARCH = Int(limitSearch!) // setting returned remaining searches.
        }
        
        if todaysDate != storedDate { // Restoring everyday!
            print("Reseting limit")
            defaults.set(todaysDate, forKey: "date")
            
            // updating value ony if neccesary.
            LIMIT_SEARCH = LIMIT_SEARCH < 5 ? 5 : LIMIT_SEARCH
            LIMIT_DIRECTION = LIMIT_DIRECTION < 10 ? 10 : LIMIT_DIRECTION
        }
        // end.
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}


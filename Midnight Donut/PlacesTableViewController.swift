//
//  PlacesTableViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/15/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import GooglePlaces

class PlacesTableViewController: UITableViewController, SendDataThroughVCDelegate {
    
    //MAEK: Properties.
    var places = [GMSPlace]()
    
    func finishPassing(places: GMSPlaceLikelihoodList) {
        for place in places.likelihoods {
            self.places.append(place.place)
        }
        print("Received the Places.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // Update tableview everytime it is entered.
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // changing navigation bar height.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let height: CGFloat = 50
        let bounds = self.navigationController?.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds!.width, height: bounds!.height + height)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.00
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if places.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath) as! PlaceTableViewCell
            // Configure the cell...
            
            let place = places[indexPath.row]

            cell.nameLabelCell.text = place.name
            cell.addressLabelCell.text = place.formattedAddress
            print("Yep!")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            
            cell.textLabel?.text = "No Data."
            cell.textLabel?.textAlignment = .center
            
            return cell
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    */
}

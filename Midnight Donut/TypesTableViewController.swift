//
//  TypesTableViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 6/20/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

protocol TypesTableViewControllerDelegate: class {
    func updateTags(_ types: [String])
}

class TypesTableViewController: UITableViewController {
    
    // MARK: - Properties.
    let possibleTypesDictionary = ["bakery":"Bakery", "bar":"Bar", "cafe":"Cafe", "grocery_or_supermarket":"Supermarket", "restaurant":"Restaurant"]
    var selectedTypes = [String]()
    var sortedKeys: [String] {
        return possibleTypesDictionary.keys.sorted()
    }
    weak var delegate: TypesTableViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling Top navigation bar.
        navigationController?.navigationBar.barTintColor = UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:1.00, green:0.91, blue:0.64, alpha:1.0)]
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        delegate.updateTags(selectedTypes)
        print("Reselected types )")
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return possibleTypesDictionary.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)

        let key = sortedKeys[indexPath.row]
        let type = possibleTypesDictionary[key]!
        
        cell.textLabel?.text = type
        cell.imageView?.image = UIImage(named: key)
        
        cell.accessoryType = selectedTypes.contains(key) ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let key = sortedKeys[indexPath.row]
        if selectedTypes.contains(key) {
            selectedTypes = selectedTypes.filter({$0 != key})
        } else {
            selectedTypes.append(key)
        }
        
        tableView.reloadData()
    }

}

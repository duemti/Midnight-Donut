//
//  AboutViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 6/15/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions.
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

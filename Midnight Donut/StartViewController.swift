//
//  StartViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 6/9/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    // MARK: - Properties.
    @IBOutlet weak var logoOfTheAppImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logoOfTheAppImageView.alpha = 0.0
        
        // Show logo of the App for 1 sec.
        UIView.animate(withDuration: 1, animations: { 
            self.logoOfTheAppImageView.alpha = 1.0
        }) { (finished) in
            self.performSegue(withIdentifier: "startTheApp", sender: self)
        }
    }
}

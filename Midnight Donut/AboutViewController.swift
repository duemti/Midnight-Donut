//
//  AboutViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 6/15/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    // MARK: - Properties.
    let appStoreID = "id1222517805"
    @IBOutlet weak var rateMeButton: menuButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var subInfoLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let shadowColor: UIColor = .black
        
        rateMeButton.layer.cornerRadius = 18
        rateMeButton.layer.shadowColor = shadowColor.cgColor
        rateMeButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        rateMeButton.layer.shadowOpacity = 1.0
        rateMeButton.layer.shadowRadius = 0.2
        rateMeButton.layer.masksToBounds = false
        rateMeButton.setTitleColor(UIColor(red:0.07, green:0.10, blue:0.11, alpha:1.0), for: .highlighted)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        exitButton.alpha = 0.0
        exitButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        logoImageView.transform = CGAffineTransform(translationX: 0, y: -100)
        infoLabel.transform = CGAffineTransform(translationX: 0, y: -100)
        subInfoLabel.transform = CGAffineTransform(translationX: 0, y: -100)
        rateMeButton.transform = CGAffineTransform(translationX: 0, y: -100)
        
        // Animate appearence of content.
        UIView.animate(withDuration: 0.5, animations: { 
            self.logoImageView.transform = .identity
            self.infoLabel.transform = .identity
            self.rateMeButton.transform = .identity
            self.subInfoLabel.transform = .identity
        }) { (nil) in
            UIView.animate(withDuration: 1.0, animations: {
                self.exitButton.alpha = 1.0
                self.exitButton.transform = .identity
            })
        }
    }
    
    // MARK: - Actions.
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rateMeAction(_ sender: UIButton) {
        rateApp(appId: appStoreID) { success in
            print("RateApp \(success)")
        }
    }
    
    // MARK: - Functions.
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }

}

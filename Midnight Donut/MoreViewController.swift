//
//  MoreViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 6/15/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {
    
    // MARK: - Properties.
    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var rightLineView: UIView!
    @IBOutlet weak var leftLineView: UIView!
    @IBOutlet weak var tagsButton: menuButton!
    @IBOutlet weak var shopButton: menuButton!
    @IBOutlet weak var aboutButton: menuButton!
    @IBOutlet weak var selectRadiusOutlet: UISlider!
    
    var animateController: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        designCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if animateController {
            animateAppear()
        }
        animateController = true
    }
    
    @IBAction func selectRadius(_ sender: UISlider) {
        let tab = tabBarController?.viewControllers![0] as! FirstViewController
        
        tab.RADIUS = Int(sender.value)
    }
}

// MARK: - Actions.
extension MoreViewController {
    @IBAction func selectTagsAction(_ sender: menuButton) {
        self.animateController = false
    }
    
    @IBAction func shopAction(_ sender: menuButton) {
        self.animateController = false
    }
    
    @IBAction func aboutAction(_ sender: menuButton) {
        self.animateController = false
    }
}

// MARK: - Layout.
extension MoreViewController {
    func designCells() {
        // MARK: - Colors.
        let shadowColor: UIColor = .black
        let highlightedBackgroundButtonColor: UIColor = UIColor(red:0.07, green:0.10, blue:0.11, alpha:1.0)
        
        // Corner Radius for buttons
        self.tagsButton.layer.cornerRadius = 10
        self.shopButton.layer.cornerRadius = 10
        self.aboutButton.layer.cornerRadius = 10
        
        // Shadows of buttons.
        self.tagsButton.layer.shadowColor = shadowColor.cgColor
        self.tagsButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.tagsButton.layer.shadowOpacity = 1.0
        self.tagsButton.layer.shadowRadius = 0.2
        self.tagsButton.layer.masksToBounds = false
        
        self.shopButton.layer.shadowColor = shadowColor.cgColor
        self.shopButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.shopButton.layer.shadowOpacity = 1.0
        self.shopButton.layer.shadowRadius = 0.2
        self.shopButton.layer.masksToBounds = false
        
        self.aboutButton.layer.shadowColor = shadowColor.cgColor
        self.aboutButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.aboutButton.layer.shadowOpacity = 1.0
        self.aboutButton.layer.shadowRadius = 0.2
        self.aboutButton.layer.masksToBounds = false
        
        self.tagsButton.setTitleColor(highlightedBackgroundButtonColor, for: .highlighted)
        self.shopButton.setTitleColor(highlightedBackgroundButtonColor, for: .highlighted)
        self.aboutButton.setTitleColor(highlightedBackgroundButtonColor, for: .highlighted)
    }
}

// MARK: - Animate appearing of content of View Controller when presented.
extension MoreViewController {
    func animateAppear() {
        let buttons = [tagsButton, shopButton, aboutButton]
        
        moreLabel.transform = CGAffineTransform(translationX: 0, y: -40)
        moreLabel.alpha = 0.0
        tagsButton.alpha = 0.0
        shopButton.alpha = 0.0
        aboutButton.alpha = 0.0
        selectRadiusOutlet.alpha = 0.0
        
        rightLineView.transform = CGAffineTransform(translationX: -100, y: 0)
        leftLineView.transform = CGAffineTransform(translationX: 100, y: 0)
        
        
        UIView.animate(withDuration: 0.6, animations: {
            self.moreLabel.transform = .identity
            self.moreLabel.alpha = 1.0
            
            self.rightLineView.transform = .identity
            self.leftLineView.transform = .identity
            
            var time = DispatchTime.now()
            for button in buttons {
                time = time + 0.05
                
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    UIView.animate(withDuration: 0.55, animations: {
                        button?.alpha = 1.0
                        self.selectRadiusOutlet.alpha = 1.0
                    })
                })
            }
        })
    }
}

// MARK: - Segue handler.
extension MoreViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Types Segue" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! TypesTableViewController
            let tab = tabBarController?.viewControllers?[0] as! FirstViewController
            
            controller.selectedTypes = TAGS
            controller.delegate = tab
        }
    }
}

// Custom button.
class menuButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.isHighlighted {
                    self.backgroundColor = UIColor(red:1.00, green:0.91, blue:0.64, alpha:1.0)
                    self.layer.shadowOffset = CGSize(width: 0, height: 3)
                } else {
                    self.backgroundColor = UIColor(red: 0.263643, green: 0.318744, blue: 0.336634, alpha:1.0)
                    self.layer.shadowOffset = CGSize(width: 0, height: 8)
                }
            }
        }
    }
}

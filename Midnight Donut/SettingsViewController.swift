//
//  SettingsViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/25/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Properties
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    let colors: [(bgColor: UIColor, txtColor: UIColor)] = [(UIColor(red:0.79, green:0.00, blue:0.02, alpha:1.0), UIColor(red:0.69, green:0.00, blue:0.00, alpha:1.0)),
                                                           (UIColor(red:1.00, green:0.43, blue:0.00, alpha:1.0), UIColor(red:0.90, green:0.33, blue:0.00, alpha:1.0)),
                                                           (UIColor(red:1.00, green:0.78, blue:0.00, alpha:1.0), UIColor(red:0.90, green:0.68, blue:0.00, alpha:1.0)),
                                                           (UIColor(red:0.00, green:0.80, blue:0.26, alpha:1.0), UIColor(red:0.00, green:0.70, blue:0.16, alpha:1.0)),
                                                           (UIColor(red:0.00, green:0.75, blue:0.98, alpha:1.0), UIColor(red:0.00, green:0.65, blue:0.89, alpha:1.0)),
                                                           (UIColor(red:0.75, green:0.07, blue:0.55, alpha:1.0), UIColor(red:0.65, green:0.00, blue:0.45, alpha:1.0))]
    
    var tags: [Int: [String]]! = [0: ["bakery", "bar", "cafe", "convenience_store", "grocery_or_supermarket", "meal_delivery", "meal_takeaway", "restaurant", "store", "gas_station"], 1: ["food"]]
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Entered.")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
        addSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
    }
    
    func getCurrentTag(for indexPath: IndexPath) -> String {
        return tags[indexPath.section]![indexPath.row]
    }
}

extension SettingsViewController {
    
    func addSubviews() {
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognizerAction))
        longPressGestureRecognizer.isEnabled = true
        self.collectionView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func longPressGestureRecognizerAction(sender: UILongPressGestureRecognizer) {
        let state = sender.state
        var locationInView = sender.location(in: collectionView)
        var indexPath = collectionView.indexPathForItem(at: locationInView)
        print("=> \(locationInView) \(indexPath) \(state)")
        
        struct My {
            static var cellSnapshot: UIView? = nil
        }
        
        struct Path {
            static var initialIndexPath: NSIndexPath? = nil
        }
        
        switch state {
        case .began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath as NSIndexPath?
                let cell = collectionView.cellForItem(at: indexPath!) as! TagsCollectionViewCell
                My.cellSnapshot = snapshopOfCell(inputView: cell)
                var center = cell.center
                My.cellSnapshot?.center = center
                My.cellSnapshot?.alpha = 0.0
                collectionView.addSubview(My.cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center.y = locationInView.y
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell.alpha = 0.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        cell.isHidden = true
                }
                })
            }
        case .changed:
            var center = My.cellSnapshot!.center
            center.y = locationInView.y
            My.cellSnapshot!.center = center
            if ((indexPath != nil) && (indexPath != Path.initialIndexPath as!  IndexPath)) {
                swap(&tags[0]![indexPath!.row], &tags[0]![Path.initialIndexPath!.row])
                collectionView.moveItem(at: Path.initialIndexPath! as IndexPath, to: indexPath!)
                Path.initialIndexPath = indexPath as NSIndexPath?
            }
        default:
            let cell = collectionView.cellForItem(at: indexPath!) as! TagsCollectionViewCell
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                My.cellSnapshot!.center = cell.center
                My.cellSnapshot!.transform = .identity
                My.cellSnapshot!.alpha = 0.0
                cell.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    Path.initialIndexPath = nil
                    My.cellSnapshot!.removeFromSuperview()
                    My.cellSnapshot = nil
                }
            })
        }
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5, height: 0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}

// MARK: - UICollectionViewDataSource
extension SettingsViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags[section]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tag", for: indexPath) as! TagsCollectionViewCell
        
        let tag = getCurrentTag(for: indexPath)
        let color = colors[Int(arc4random_uniform(6))]
        
        cell.layer.cornerRadius = 8
        cell.backgroundColor = color.bgColor
        cell.tagNameLabel.textColor = .white
        cell.tagNameLabel.shadowColor = color.txtColor
        cell.tagNameLabel.text = tag
        cell.tagNameLabel.sizeToFit()
        
        return cell
    }
}

// MARK: - Layout
extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = getCurrentTag(for: indexPath) as NSString
        var size: CGSize = tag.size(attributes: [NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 19) as Any])
        size.height = 32
        size.width += 6
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionInsets = UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0)
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! HeaderCollectionReusableView
        
        switch indexPath.section {
        case 0:
            header.titleForSectionLabel.text = "In"
            header.titleForSectionLabel.textColor = .green
            header.lineView.backgroundColor = .green
        case 1:
            header.titleForSectionLabel.text = "Out"
            header.titleForSectionLabel.textColor = .red
            header.lineView.backgroundColor = .red
        default:
            header.titleForSectionLabel.text = ""
        }
        return header
    }
}

//
//  SettingsViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 5/25/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit

extension UIView {
    var snapshot : UIView? {
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        let snapshot: UIView = UIImageView(image: image)
        
        return snapshot
    }
}

class SettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Properties
    var placeTab: FirstViewController!
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    let colors: [(bgColor: UIColor, txtColor: UIColor)] = [(UIColor(red:0.79, green:0.00, blue:0.02, alpha:1.0), UIColor(red:0.69, green:0.00, blue:0.00, alpha:1.0)),
                                                           (UIColor(red:1.00, green:0.43, blue:0.00, alpha:1.0), UIColor(red:0.90, green:0.33, blue:0.00, alpha:1.0)),
                                                           (UIColor(red:1.00, green:0.78, blue:0.00, alpha:1.0), UIColor(red:0.90, green:0.68, blue:0.00, alpha:1.0)),
                                                           (UIColor(red:0.00, green:0.80, blue:0.26, alpha:1.0), UIColor(red:0.00, green:0.70, blue:0.16, alpha:1.0)),
                                                           (UIColor(red:0.00, green:0.75, blue:0.98, alpha:1.0), UIColor(red:0.00, green:0.65, blue:0.89, alpha:1.0)),
                                                           (UIColor(red:0.75, green:0.07, blue:0.55, alpha:1.0), UIColor(red:0.65, green:0.00, blue:0.45, alpha:1.0))]
    
    var tags: [Int: [String]]!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Entered.")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        placeTab = self.tabBarController?.viewControllers?[0] as! FirstViewController
        tags = self.placeTab.getCurrentTags()
        addSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tags = self.placeTab.getCurrentTags()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        placeTab.update(tags: tags)
    }
    
    func getCurrentTag(for indexPath: IndexPath) -> String {
        return tags[indexPath.section]![indexPath.row]
    }
}

// MARK: - Reselect tags.
extension SettingsViewController {
    
    func addSubviews() {
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognizerAction))
        longPressGestureRecognizer.isEnabled = true
        self.collectionView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func longPressGestureRecognizerAction(sender: UILongPressGestureRecognizer) {
        let state = sender.state
        let locationInView = sender.location(in: collectionView)
        var indexPath = collectionView.indexPathForItem(at: locationInView)
        
        // Structs for saving cell info.
        struct My {
            static var cellSnapshot : UIView? = nil
        }
        struct First {
            static var index : IndexPath? = nil
        }
        struct Last {
            static var index: IndexPath? = nil
        }
        switch state {
        case .began:
            if indexPath != nil {
                First.index = indexPath
                Last.index = indexPath
                let cell = collectionView.cellForItem(at: indexPath!) as! TagsCollectionViewCell
                My.cellSnapshot = cell.snapshot
                My.cellSnapshot?.center = cell.center
                My.cellSnapshot?.alpha = 0.0
                collectionView.addSubview(My.cellSnapshot!)
                
                UIView.animate(withDuration: 0.1, animations: {
                    My.cellSnapshot?.alpha = 0.97
                    My.cellSnapshot?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: { (finished) in
                    if finished {
                        cell.isHidden = true
                    }
                })
            }
            print("=====>Gesture began.")
        case .changed:
            My.cellSnapshot?.center = locationInView
            if indexPath != nil && First.index != nil {
                let newRow = indexPath!.row
                let newSection = indexPath!.section
                let row = First.index!.row
                let section = First.index!.section
                
                // Swap tags that are in same section of collectionView.
                if newRow != row {
                    if newSection == section {
                        // Swapping Tags using tuples.
                        (tags[section]![newRow], tags[section]![row]) = (tags[section]![row], tags[section]![newRow])
                        collectionView.moveItem(at: First.index!, to: indexPath!)
                    } else {
                        // Swap tags that are in Different same sections of CollectionView.
                        tags[newSection]?.append(tags[section]![row])
                        tags[section]?.remove(at: row)
                        collectionView.moveItem(at: First.index!, to: indexPath!)
                        print(tags)
                    }
                    First.index = indexPath
                }
                
                if indexPath != Last.index {
                    Last.index = indexPath
                }
            }
        case .ended:
            if First.index != nil {
                let cell = collectionView.cellForItem(at: First.index!)!
                cell.isHidden = false
                cell.alpha = 0.0
                UIView.animate(withDuration: 0.25, animations: {
                    My.cellSnapshot?.center = cell.center
                    My.cellSnapshot?.transform = CGAffineTransform.identity
                    My.cellSnapshot?.alpha = 0.0
                    cell.alpha = 1.0
                }, completion: { (finished) in
                    if finished {
                        First.index = nil
                        Last.index = nil
                        My.cellSnapshot?.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
                print("Gesture ended.")
            }
        default:
            print("Gesture default.")
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SettingsViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags[section]?.count ?? 0
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

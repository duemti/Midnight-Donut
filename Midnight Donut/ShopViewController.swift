//
//  ShopViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 6/16/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import StoreKit

private var viewLoadedContent: Bool = false

class ShopViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    // MARK: - Properties.
    let SEARCHES_PRODUCT_ID = "com.midnightDonut.requests"
    let DIRECTIONS_PRODUCTS_ID = "com.midnightDonut.directions"
    let NC_TRAVELMODES_PRODUCT_ID = "com.midnightDonut.travelModes"
    
    var product_ID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var searches = UserDefaults.standard.integer(forKey: "searches")
    
    @IBOutlet weak var leftLineView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightLineView: UIView!
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var buySearchesLabel: UILabel!
    @IBOutlet weak var buySearchesButton: buyButton!
    @IBOutlet weak var currentAmountOfSearchesLabel: UILabel!
    
    @IBOutlet weak var buyDirectionsLabel: UILabel!
    @IBOutlet weak var buyDirectionsButton: buyButton!
    @IBOutlet weak var currentAmountOfDirectionsLabel: UILabel!
    
    @IBOutlet weak var buyTravelModesLabel: UILabel!
    @IBOutlet weak var buyTravelModesButton: buyButton!
    @IBOutlet weak var bonusLabel: UILabel!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check your In-App Purchases
        print("Non consumable purchases MADE: \(nonConsumablePurchaseMade)")
        print("Searches: \(LIMIT_SEARCH!), Directions: \(LIMIT_DIRECTION!)")
        
        
        if nonConsumablePurchaseMade {
            self.buyTravelModesButton.isEnabled = false
            self.buyTravelModesLabel.text = "Travel Modes Unlocked! 👍"
            self.bonusLabel.isHidden = true
            self.buyTravelModesButton.isHidden = true
        }
        
        // Fetch IAP Products available
        fetchAvailableProducts()

        buttonLayout()
        
        // Fetching current amount of searches and directions
        currentAmountOfSearchesLabel.text = "current: \(LIMIT_SEARCH!)"
        currentAmountOfDirectionsLabel.text = "current: \(LIMIT_DIRECTION!)"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        buySearchesButton.isEnabled = false
        buyDirectionsButton.isEnabled = false
        buyTravelModesButton.isEnabled = false
        
        animateVC()
    }
    
    // MARK: - Actions.
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: -  BUY 100 SEARCHES BUTTON
    @IBAction func buySearches(_ sender: buyButton) {
        purchaseMyProduct(product: iapProducts[1])
    }
    
    // MARK: -  BUY 100 DIRECTIONS BUTTON
    @IBAction func buyDirections(_ sender: buyButton) {
        purchaseMyProduct(product: iapProducts[0])
    }

    // MARK: -  UNLOCK TRAVEL MODES
    @IBAction func buyTravelModes(_ sender: buyButton) {
        purchaseMyProduct(product: iapProducts[2])
    }
    
    // MARK: - RESTORE NON-CONSUMABLE PURCHASE BUTTON
    @IBAction func restorePurchases(_ sender: UIButton) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        nonConsumablePurchaseMade = true
        UserDefaults.standard.set(nonConsumablePurchaseMade, forKey: "nonConsumablePurchaseMade")
        
        UIAlertView(title: "Purchases Restored", message: "You've successfully restored your purchase!", delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts() {
        
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects: SEARCHES_PRODUCT_ID, DIRECTIONS_PRODUCTS_ID, NC_TRAVELMODES_PRODUCT_ID)
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            iapProducts = response.products
            
            // 1st IAP Product (Consumable Searches) ------------------------------------
            let firstProduct = response.products[1] as SKProduct
            
            // Get its price from iTunes Connect
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = firstProduct.priceLocale
            let price1Str = numberFormatter.string(from: firstProduct.price)
            
            // Show its description
            print(firstProduct.localizedDescription + "\nfor just \(price1Str!)")
            UIView.animate(withDuration: 0.5, animations: {
                self.buySearchesButton.isEnabled = true
                self.buySearchesButton.backgroundColor = UIColor(red:0.00, green:0.80, blue:0.26, alpha:1.0)
            })
            // ------------------------------------------------
            
            // 2nd IAP Product (Consumable Directions) ------------------------------
            let secondProduct = response.products[0] as SKProduct
            numberFormatter.locale = secondProduct.priceLocale
            let price2Str = numberFormatter.string(from: secondProduct.price)
            
            // Show its description
            print(secondProduct.localizedDescription + "\nfor just \(price2Str!)")
            UIView.animate(withDuration: 0.5, animations: {
                self.buyDirectionsButton.isEnabled = true
                self.buyDirectionsButton.backgroundColor = UIColor(red:0.00, green:0.80, blue:0.26, alpha:1.0)
            })
            // ------------------------------------------------
            
            // 3rd IAP Product (Non-Consumable) ------------------------------
            let thirdProduct = response.products[2] as SKProduct
            
            // Get its price from iTunes Connect
            numberFormatter.locale = thirdProduct.priceLocale
            let price3Str = numberFormatter.string(from: thirdProduct.price)
            
            // Show its description
            print(thirdProduct.localizedDescription + "\nfor just \(price3Str!)")
            UIView.animate(withDuration: 0.5, animations: {
                self.buyTravelModesButton.isEnabled = true
                self.buyTravelModesButton.backgroundColor = UIColor(red:0.00, green:0.80, blue:0.26, alpha:1.0)
            })
            // ------------------------------------------------
            viewLoadedContent = true
        }
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            product_ID = product.productIdentifier
        }// IAP Purchases dsabled on the Device
        else {
            UIAlertView(title: "Failed", message: "Purchases are disabled in your device!", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction: AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    // The Consumable product (100 searches) has been purchased -> gain 100 extra searches!
                    if product_ID == SEARCHES_PRODUCT_ID {
                        
                        // Add 100 searches and save their total amount
                        LIMIT_SEARCH = LIMIT_SEARCH + 100
                        UserDefaults.standard.set(LIMIT_SEARCH, forKey: "limitSearch")
                        
                        // update label animated
                        animateLabelChange(currentAmountOfSearchesLabel)
                        UIAlertView(title: "Success", message: "You've successfully bought 100 extra searches!", delegate: nil, cancelButtonTitle: "OK").show()
                    
                    // The Consumable product (100 searches) has been purchased -> gain 100 extra searches!
                    } else if product_ID == DIRECTIONS_PRODUCTS_ID {
                        
                        // Add 100 directions and save their total amount
                        LIMIT_DIRECTION = LIMIT_DIRECTION + 100
                        UserDefaults.standard.set(LIMIT_DIRECTION, forKey: "limitDirection")
                        
                        // update label animated
                        animateLabelChange(currentAmountOfDirectionsLabel)
                        UIAlertView(title: "Success", message: "You've successfully bought 100 extra directions!", delegate: nil, cancelButtonTitle: "OK").show()
                        
                    // The Non-Consumable product (Travel Modes) has been purchased!
                    } else if product_ID == NC_TRAVELMODES_PRODUCT_ID {
                        
                        // Save your purchase locally (needed only for Non-Consumable IAP)
                        nonConsumablePurchaseMade = true
                        UserDefaults.standard.set(nonConsumablePurchaseMade, forKey: "nonConsumablePurchaseMade")
                        
                        self.buyTravelModesButton.isEnabled = false
                        self.buyTravelModesLabel.text = "Travel Modes Unlocked! 👍"
                        self.bonusLabel.isHidden = true
                        self.buyTravelModesButton.isHidden = true
                        
                        // Adding BONUS.
                        LIMIT_DIRECTION = LIMIT_DIRECTION + 25
                        UserDefaults.standard.set(LIMIT_DIRECTION, forKey: "limitDirection")
                        LIMIT_SEARCH = LIMIT_SEARCH + 25
                        UserDefaults.standard.set(LIMIT_SEARCH, forKey: "limitSearch")
                        
                        UIAlertView(title: "Success", message: "You've successfully unlocked travel modes!", delegate: nil, cancelButtonTitle: "OK").show()
                    }
                    break
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    self.buyTravelModesButton.isEnabled = false
                    self.buyTravelModesLabel.text = "Travel Modes Unlocked! 👍"
                    self.bonusLabel.isHidden = true
                    self.buyTravelModesButton.isHidden = true
                    
                    break
                    
                default:
                    break
                }
            }
        }
    }
    
    func animateLabelChange(_ label: UILabel) {
        UIView.animate(withDuration: 0.5, animations: { 
            label.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }) { (nil) in
            label.text = "current: \(LIMIT_DIRECTION!)"
            UIView.animate(withDuration: 1, animations: {
                label.transform = .identity
            })
        }
    }
    
}

// MARK: - Load Layout of buttons.
extension ShopViewController {
    func buttonLayout() {
        buySearchesButton.layer.shadowColor = UIColor.black.cgColor
        buySearchesButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        buySearchesButton.layer.shadowOpacity = 1.0
        buySearchesButton.layer.shadowRadius = 0.2
        buySearchesButton.layer.masksToBounds = false
        buySearchesButton.layer.cornerRadius = 15
        
        buyDirectionsButton.layer.shadowColor = UIColor.black.cgColor
        buyDirectionsButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        buyDirectionsButton.layer.shadowOpacity = 1.0
        buyDirectionsButton.layer.shadowRadius = 0.2
        buyDirectionsButton.layer.masksToBounds = false
        buyDirectionsButton.layer.cornerRadius = 15
        
        buyTravelModesButton.layer.shadowColor = UIColor.black.cgColor
        buyTravelModesButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        buyTravelModesButton.layer.shadowOpacity = 1.0
        buyTravelModesButton.layer.shadowRadius = 0.2
        buyTravelModesButton.layer.masksToBounds = false
        buyTravelModesButton.layer.cornerRadius = 15
    }
}

// MARK: - Animate appearing of content of View Controller when presented.
extension ShopViewController {
    func animateVC() {
        exitButton.alpha = 0.0
        exitButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        leftLineView.transform = CGAffineTransform(translationX: -100, y: 0)
        rightLineView.transform = CGAffineTransform(translationX: 100, y: 0)
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -100)
        titleLabel.alpha = 0.0
        
        buySearchesLabel.alpha = 0.0
        buySearchesButton.alpha = 0.0
        currentAmountOfSearchesLabel.alpha = 0.0
        
        buyDirectionsLabel.alpha = 0.0
        buyDirectionsButton.alpha = 0.0
        currentAmountOfDirectionsLabel.alpha = 0.0
        
        buyTravelModesLabel.alpha = 0.0
        buyTravelModesButton.alpha = 0.0
        bonusLabel.alpha = 0.0
        
        // Animate appearence of content.
        UIView.animate(withDuration: 0.5, animations: {
            self.rightLineView.transform = .identity
            self.leftLineView.transform = .identity
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1.0
            
            self.buySearchesLabel.alpha = 1
            self.buySearchesButton.alpha = 1
            self.currentAmountOfSearchesLabel.alpha = 1
            
            self.buyDirectionsLabel.alpha = 1
            self.buyDirectionsButton.alpha = 1
            self.currentAmountOfDirectionsLabel.alpha = 1
            
            self.buyTravelModesLabel.alpha = 1
            self.buyTravelModesButton.alpha = 1
            self.bonusLabel.alpha = 1
        }) { (nil) in
            UIView.animate(withDuration: 1.0, animations: {
                self.exitButton.alpha = 1.0
                self.exitButton.transform = .identity
            })
        }
    }
}

// Custom button.
class buyButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.isHighlighted {
                    self.backgroundColor = UIColor(red:0.00, green:0.80, blue:0.26, alpha:1.0)
                    self.layer.shadowOffset = CGSize(width: 0, height: 3)
                } else {
                    self.backgroundColor = viewLoadedContent ? UIColor(red:0.00, green:0.80, blue:0.26, alpha:1.0) : UIColor(red: 0.263643, green: 0.318744, blue: 0.336634, alpha:1.0)
                    self.layer.shadowOffset = CGSize(width: 0, height: 8)
                }
            }
        }
    }
}

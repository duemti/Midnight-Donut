//
//  ShopViewController.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 6/16/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import StoreKit

class ShopViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    // MARK: - Properties.
    let REQUESTS_PRODUCT_ID = "com.midnightDonut.requests"
    let DIRECTIONS_PRODUCTS_ID = "com.midnightDonut.directions"
    let NC_TRAVELMODES_PRODUCT_ID = "com.midnightDonut.travelModes"
    
    var product_ID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var nonConsumablePurchaseMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseMade")
    var searches = UserDefaults.standard.integer(forKey: "searches")
    
    @IBOutlet weak var leftLineView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightLineView: UIView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var buySearchesButton: buyButton!
    @IBOutlet weak var buyDirectionsButton: buyButton!
    
    @IBOutlet weak var buyTravelModesButton: buyButton!
    @IBOutlet weak var buyTravelModesLabel: UILabel!
    @IBOutlet weak var bonusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check your In-App Purchases
        print("Non consumable purchases MADE: \(nonConsumablePurchaseMade)")
        print("Searches: \(LIMIT_SEARCH), Directions: \(LIMIT_DIRECTION)")
        
        if nonConsumablePurchaseMade {
            self.buyTravelModesButton.isEnabled = false
            self.buyTravelModesLabel.text = "Travel Modes Unlocked! 👍"
            self.bonusLabel.isHidden = true
        }
        
        // Fetch IAP Products available
        //fetchAvailableProducts()

        buttonLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        animateVC()
    }
    
    // MARK: - Actions.
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: -  BUY 100 SEARCHES BUTTON
    @IBAction func buySearches(_ sender: buyButton) {
        purchaseMyProduct(product: iapProducts[0])
    }
    
    // MARK: -  BUY 100 DIRECTIONS BUTTON
    @IBAction func buyDirections(_ sender: buyButton) {
        purchaseMyProduct(product: iapProducts[1])
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
        let productIdentifiers = NSSet(objects: REQUESTS_PRODUCT_ID, DIRECTIONS_PRODUCTS_ID, NC_TRAVELMODES_PRODUCT_ID)
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            iapProducts = response.products
            
            // 1st IAP Product (Consumable) ------------------------------------
            let firstProduct = response.products[0] as SKProduct
            
            // Get its price from iTunes Connect
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = firstProduct.priceLocale
            let price1Str = numberFormatter.string(from: firstProduct.price)
            
            // Show its description
            print(firstProduct.localizedDescription + "\nfor just \(price1Str!)")
            // ------------------------------------------------
            
            // 2nd IAP Product (Non-Consumable) ------------------------------
            let secondProduct = response.products[1] as SKProduct
            numberFormatter.locale = secondProduct.priceLocale
            let price2Str = numberFormatter.string(from: secondProduct.price)
            
            // Show its description
            print(firstProduct.localizedDescription + "\nfor just \(price2Str!)")
            // ------------------------------------------------
            
            // 3rd IAP Product (Non-Consumable) ------------------------------
            let thirdProduct = response.products[2] as SKProduct
            
            // Get its price from iTunes Connect
            numberFormatter.locale = thirdProduct.priceLocale
            let price3Str = numberFormatter.string(from: thirdProduct.price)
            
            // Show its description
            print(firstProduct.localizedDescription + "\nfor just \(price3Str!)")
            // ------------------------------------------------
        }
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
        
        // Animate appearence of content.
        UIView.animate(withDuration: 0.5, animations: {
            self.rightLineView.transform = .identity
            self.leftLineView.transform = .identity
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1.0
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
                    self.backgroundColor = UIColor(red: 0.263643, green: 0.318744, blue: 0.336634, alpha:1.0)
                    self.layer.shadowOffset = CGSize(width: 0, height: 8)
                }
            }
        }
    }
}

//
//  MyActivityIndicator.swift
//  Midnight Donut
//
//  Created by Petrov Dumitru on 6/17/17.
//  Copyright © 2017 Dumitru PETROV. All rights reserved.
//

import UIKit
import QuartzCore

class MyActivityIndicator: UIView {
    
    // MARK: - Properties.
    lazy private var animationLayer : CALayer = {
        return CALayer()
    }()
    
    var isAnimating: Bool = false
    var hidesWhenStopped : Bool = true
    
    // MARK: - Init.
    init(image: UIImage) {
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        super.init(frame: frame)
        
        animationLayer.frame = frame
        animationLayer.contents = image
        animationLayer.masksToBounds = true
        
        self.layer.addSublayer(animationLayer)
        pause()
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions.
    func addRotation(forLayer layer: CALayer) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        
        rotation.duration = 1.0
        rotation.isRemovedOnCompletion = false
        rotation.repeatCount = HUGE
        rotation.fillMode = kCAFillModeForwards
        rotation.fromValue = NSNumber(value: 0.0)
        rotation.toValue = NSNumber(value: 3.14 * 2.0)
        
        layer.add(rotation, forKey: "rotate")
    }

    func resume(layer : CALayer) {
        let pausedTime : CFTimeInterval = layer.timeOffset
        
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
        
        isAnimating = true
    }
    
    func startAnimating () {
        
        if isAnimating {
            return
        }
        
        if hidesWhenStopped {
            self.isHidden = false
        }
        resume(layer: animationLayer)
    }
    
    func stopAnimating () {
        if hidesWhenStopped {
            self.isHidden = true
        }
        pause()
    }

}

//
//  AIRAnimationView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 16.09.2024.
//

import UIKit

final class AIRAnimationView: UIView {
    private lazy var animationLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            Appearance.main500.withAlphaComponent(0.2).cgColor,
            Appearance.main500.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 0] as [NSNumber]
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        animationLayer.frame = bounds
    }
}

// MARK: Public
extension AIRAnimationView {
    func animate() {
        isHidden = false
        
        layer.addSublayer(animationLayer)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0]
        animation.toValue = [1, 2]
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.autoreverses = true
        
        animationLayer.add(animation, forKey: "loc")
        animationLayer.locations = [1, 2]
    }
    
    func cancel() {
        isHidden = true
        
        animationLayer.removeAllAnimations()
        animationLayer.removeFromSuperlayer()
    }
}

// MARK: Private
private extension AIRAnimationView {
    func initialize() {
        backgroundColor = UIColor.clear
        isHidden = true
    }
}

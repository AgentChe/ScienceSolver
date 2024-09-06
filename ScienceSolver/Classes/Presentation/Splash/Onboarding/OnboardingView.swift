//
//  OnboardingView.swift
//  Soccer
//
//  Created by Андрей Чернышев on 23.08.2022.
//

import UIKit

final class OnboardingView: UIView {
    enum Step: Int {
        case welcome1, welcome2, welcome3
    }
    
    var didFinish: (() -> Void)?
    
    lazy var contentViews: [OSlideView] = {
        [
            OSlideView(step: .welcome1)
        ]
    }()
    
    private var step = Step.welcome1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: OSlideViewDelegate
extension OnboardingView: OSlideViewDelegate {
    func slideViewDidNext(from step: Step) {
        let nextRawValue = step.rawValue + 1
        
        guard let nextStep = Step(rawValue: nextRawValue) else {
            didFinish?()
            
            return
        }
        
        scroll(to: nextStep)
    }
    
    func slideViewDidBack(from step: OnboardingView.Step) {
        let previousRawValue = step.rawValue - 1
        
        guard let previousStep = Step(rawValue: previousRawValue) else {
            return
        }
        
        scroll(to: previousStep)
    }
    
    func slideViewDidSkip() {
        didFinish?()
    }
}

// MARK: Private
private extension OnboardingView {
    func initialize() {
        contentViews
            .enumerated()
            .forEach { [weak self] index, view in
                view.frame.size = CGSize(width: UIScreen.main.bounds.width,
                                         height: UIScreen.main.bounds.height)
                
                view.clipsToBounds = true
                view.delegate = self
                
                if index == 0 {
                    view.frame.origin = CGPoint(x: 0, y: 0)
                    self?.addSubview(view)
                    
                    view.moveToThis()
                }
            }
    }
    
    func scroll(to newStep: Step) {
        let currentIndex = step.rawValue
        let scrollToIndex = newStep.rawValue
        
        let direction = scrollToIndex > currentIndex ? 1 : -1
        
        let indices = contentViews.indices
        
        guard indices.contains(currentIndex), indices.contains(scrollToIndex) else {
            return
        }

        let currentView = contentViews[currentIndex]
        let scrollToView = contentViews[scrollToIndex]
        
        scrollToView.frame.origin = CGPoint(x: 393.scale * CGFloat(direction), y: 0)
        
        addSubview(scrollToView)
        
        UIView.animate(withDuration: 0.3, animations: {
            currentView.frame.origin = CGPoint(x: 393.scale * CGFloat(-direction), y: 0)
            scrollToView.frame.origin = CGPoint(x: 0, y: 0)
        }, completion: { [weak self] result in
            guard let self = self else {
                return
            }
            
            currentView.removeFromSuperview()
            
            scrollToView.moveToThis()
            
            self.step = newStep
        })
    }
}

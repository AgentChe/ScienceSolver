//
//  OnboardingWelcome1View.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 06.09.2024.
//

import UIKit
import Lottie

final class OnboardingWelcome1View: OnboardingSlideView {
    lazy var container = makeContainer()
    lazy var animationView = makeAnimationView()
    lazy var button = makeButton()
    
    init() {
        super.init(slide: .welcome1)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func moveToThis() {
        super.moveToThis()
        
        animationView.play()
    }
}

// MARK: Private
private extension OnboardingWelcome1View {
    func initialize() {
        backgroundColor = Appearance.main100
    }
}

// MARK: Make constraints
private extension OnboardingWelcome1View {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32.scale),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32.scale),
            animationView.topAnchor.constraint(equalTo: container.topAnchor, constant: 64.scale),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -32.scale)
        ])
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 92.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension OnboardingWelcome1View {
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 40.scale
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.backgroundColor = Appearance.main400
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeAnimationView() -> LottieAnimationView {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor.clear
        view.animation = LottieAnimation.named("Onboarding.Welcome1.Animation")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Onboarding.Welcome1.Button".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main400
        view.layer.cornerRadius = 32.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        addSubview(view)
        return view
    }
}

//
//  AssistantResultBottomView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 04.03.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class AssistantResultBottomView: UIView {
    enum Action {
        case generateEssay
    }
    
    enum Mode {
        case generateEssay
    }
    
    private lazy var actionTrigger = PublishRelay<Action>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AssistantResultBottomView {
    func setup(mode: Mode?) {
        subviews.forEach { $0.removeFromSuperview() }
        
        guard let mode else { return }
        
        switch mode {
        case .generateEssay:
            makeGenerateEssayUI()
        }
        
        layoutIfNeeded()
    }
    
    var action: Signal<Action> {
        actionTrigger.asSignal()
    }
}

// MARK: Private
private extension AssistantResultBottomView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
    
    func makeGenerateEssayUI() {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 16.scale))
        
        let button = UIButton()
        button.setAttributedTitle("AssistantResult.GenerateEssay".localized.attributed(with: attrs), for: .normal)
        button.backgroundColor = Appearance.main300
        button.layer.cornerRadius = 16.scale
        button.addTarget(self, action: #selector(generateEssayTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc
    func generateEssayTapped() {
        actionTrigger.accept(.generateEssay)
    }
}

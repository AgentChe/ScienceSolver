//
//  AssistantCameraPermissionProblemView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit

final class AssistantCameraPermissionProblemView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var allowAccessButton = makeAllowAccessButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConsraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension AssistantCameraPermissionProblemView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension AssistantCameraPermissionProblemView {
    func makeConsraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 56.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -56.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 56.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -56.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            allowAccessButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.scale),
            allowAccessButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            allowAccessButton.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 40.scale),
            allowAccessButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            allowAccessButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AssistantCameraPermissionProblemView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.semiBold(size: 20.scale))
            .lineHeight(28.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "AssistantCamera.PermissionProblem.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.regular(size: 16.scale))
            .lineHeight(22.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "AssistantCamera.PermissionProblem.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeAllowAccessButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("AssistantCamera.PermissionProblem.Button".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main300
        view.layer.cornerRadius = 16.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

//
//  AssistantImageResizeView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 13.09.2024.
//

import UIKit
import Mantis

final class AssistantImageResizeView: UIView {
    lazy var cancelButton = makeTextTapAreaButton(title: "Cancel".localized)
    lazy var doneButton = makeTextTapAreaButton(title: "AssistantImageResize.Done".localized)
    lazy var imageContainer = makeImageContainerView()
    lazy var animateView = makeAnimateView()
    lazy var selectEntityButton = makeSelectEntityButton()
    
    private lazy var animateViewWidthConstraint = NSLayoutConstraint()
    private lazy var animateViewHeightConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AssistantImageResizeView {
    func update(cropInfo: CropInfo) {
        NSLayoutConstraint.deactivate([
            animateViewWidthConstraint,
            animateViewHeightConstraint
        ])
        
        animateViewWidthConstraint.constant = cropInfo.cropSize.width
        animateViewHeightConstraint.constant = cropInfo.cropSize.height
        
        layoutIfNeeded()
        
        NSLayoutConstraint.activate([
            animateViewWidthConstraint,
            animateViewHeightConstraint
        ])
    }
}

// MARK: Private
private extension AssistantImageResizeView {
    func initialize() {
        backgroundColor = Appearance.mono200
    }
}

// MARK: Make constraints
private extension AssistantImageResizeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            cancelButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 14.scale)
        ])
        
        NSLayoutConstraint.activate([
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            doneButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 14.scale)
        ])
        
        NSLayoutConstraint.activate([
            imageContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 35.scale),
            imageContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -35.scale),
            imageContainer.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 42.scale),
            imageContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -137.scale)
        ])
        
        animateViewWidthConstraint = animateView.widthAnchor.constraint(equalToConstant: 0)
        animateViewHeightConstraint = animateView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            animateView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            animateView.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),
            animateViewWidthConstraint,
            animateViewHeightConstraint,
        ])
        
        NSLayoutConstraint.activate([
            selectEntityButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectEntityButton.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 28.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AssistantImageResizeView {
    func makeTextTapAreaButton(title: String) -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.semiBold(size: 16.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle(title.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageContainerView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeAnimateView() -> AIRAnimationView {
        let view = AIRAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSelectEntityButton() -> AIRSelectEntityButton {
        let view = AIRSelectEntityButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

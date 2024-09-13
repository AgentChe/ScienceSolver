//
//  AssistantImageResizeView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 13.09.2024.
//

import UIKit

final class AssistantImageResizeView: UIView {
    lazy var cancelButton = makeTextTapAreaButton(title: "Cancel".localized)
    lazy var doneButton = makeTextTapAreaButton(title: "AssistantImageResize.Done".localized)
    lazy var imageView = makeImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 35.scale),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -35.scale),
            imageView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 42.scale),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -137.scale)
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
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

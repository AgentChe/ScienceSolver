//
//  HelpfulActionsView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 22.02.2025.
//

import UIKit

final class HelpfulActionsView: UIView {
    var didTapLike: (() -> Void)?
    var didTapDislike: (() -> Void)?
    
    lazy var likeButton = makeActionButton(iconName: "AssistantResult.Like")
    lazy var dislikeButton = makeActionButton(iconName: "AssistantResult.Dislike")
    
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
private extension HelpfulActionsView {
    func initialize() {
        backgroundColor = UIColor.clear
        
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        dislikeButton.addTarget(self, action: #selector(dislikeTapped), for: .touchUpInside)
    }
    
    @objc
    func likeTapped() {
        didTapLike?()
    }
    
    @objc
    func dislikeTapped() {
        didTapDislike?()
    }
}

// MARK: Make constraints
private extension HelpfulActionsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            likeButton.widthAnchor.constraint(equalToConstant: 40.scale),
            likeButton.heightAnchor.constraint(equalToConstant: 40.scale),
            likeButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -4.scale),
            likeButton.topAnchor.constraint(equalTo: topAnchor),
            likeButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            dislikeButton.widthAnchor.constraint(equalToConstant: 40.scale),
            dislikeButton.heightAnchor.constraint(equalToConstant: 40.scale),
            dislikeButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 4.scale),
            dislikeButton.topAnchor.constraint(equalTo: topAnchor),
            dislikeButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HelpfulActionsView {
    func makeActionButton(iconName: String) -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: iconName), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

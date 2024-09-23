//
//  ARTHelpfulCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit

final class ARTHelpfulCell: UITableViewCell {
    var didTapLike: (() -> Void)?
    var didTapDislike: (() -> Void)?
    
    lazy var container = makeContainer()
    lazy var titleLabel = makeTitleLabel()
    lazy var likeButton = makeActionButton(iconName: "AssistantResult.Like")
    lazy var dislikeButton = makeActionButton(iconName: "AssistantResult.Dislike")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ARTHelpfulCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
        
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
private extension ARTHelpfulCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 110.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            likeButton.widthAnchor.constraint(equalToConstant: 40.scale),
            likeButton.heightAnchor.constraint(equalToConstant: 40.scale),
            likeButton.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -4.scale),
            likeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            dislikeButton.widthAnchor.constraint(equalToConstant: 40.scale),
            dislikeButton.heightAnchor.constraint(equalToConstant: 40.scale),
            dislikeButton.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: 4.scale),
            dislikeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ARTHelpfulCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono100
        view.layer.cornerRadius = 16.scale
        view.layer.borderColor = Appearance.main200.cgColor
        view.layer.borderWidth = 1.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.regular(size: 16.scale))
            .lineHeight(22.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "AssistantResult.Helpful".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeActionButton(iconName: String) -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: iconName), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}

//
//  ARTQuestionImageCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit

final class ARTQuestionImageCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var pictureView = makeImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ARTQuestionImageCell {
    func setup(image: UIImage) {
        pictureView.image = image
    }
}

// MARK: Private
private extension ARTQuestionImageCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ARTQuestionImageCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 40.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            pictureView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            pictureView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            pictureView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            pictureView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ARTQuestionImageCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono100
        view.layer.cornerRadius = 16.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.borderColor = Appearance.main200.cgColor
        view.layer.borderWidth = 1.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}

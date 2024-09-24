//
//  ARTQuestionTextCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit

final class ARTQuestionTextCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var label = makeLabel()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.Inter.regular(size: 16.scale))
        .lineHeight(22.scale)
        .textAlignment(.left)
    
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
extension ARTQuestionTextCell {
    func setup(question: String) {
        label.attributedText = question.attributed(with: attrs)
    }
}

// MARK: Private
private extension ARTQuestionTextCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ARTQuestionTextCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 40.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ARTQuestionTextCell {
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
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}

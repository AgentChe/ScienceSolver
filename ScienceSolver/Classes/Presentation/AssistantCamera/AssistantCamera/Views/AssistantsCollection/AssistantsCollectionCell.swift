//
//  AssistantsCollectionCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit

final class AssistantsCollectionCell: UICollectionViewCell {
    lazy var label = makeLabel()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.medium(size: 16.scale))
        .lineHeight(19.scale)
        .textAlignment(.center)
    
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
extension AssistantsCollectionCell {
    func setup(element: AssistantsCollectionElement) {
        label.attributedText = element.assistant.title.attributed(with: attrs)
        
        contentView.backgroundColor = element.marked ? Appearance.main300 : Appearance.mono200.withAlphaComponent(0.2)
    }
}

// MARK: Private
private extension AssistantsCollectionCell {
    func initialize() {
        backgroundColor = UIColor.clear
        
        contentView.layer.cornerRadius = 12.scale
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView = selectedView
    }
}

// MARK: Make constraints
private extension AssistantsCollectionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AssistantsCollectionCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}

// MARK: Additional
private extension AssistantsCollectionElement.Assistant {
    var title: String {
        switch self {
        case .math:
            return "Assistant.Math".localized
        case .physics:
            return "Assistant.Physics".localized
        case .biology:
            return "Assistant.Biology".localized
        case .chemistry:
            return "Assistant.Chemistry".localized
        case .writing:
            return "Assistant.Writing".localized
        case .language:
            return "Assistant.Language".localized
        }
    }
}

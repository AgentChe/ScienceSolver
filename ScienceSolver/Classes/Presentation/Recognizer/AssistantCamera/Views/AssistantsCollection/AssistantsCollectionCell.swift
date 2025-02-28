//
//  AssistantsCollectionCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit

final class AssistantsCollectionCell: UICollectionViewCell {
    lazy var blurView = makeBlurView()
    lazy var label = makeLabel()
    
    private lazy var mono100Attrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.medium(size: 16.scale))
        .lineHeight(19.scale)
        .textAlignment(.center)
    private lazy var mono200Attrs = TextAttributes()
        .textColor(Appearance.mono200)
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
        switch element.style {
        case .withBlur:
            label.attributedText = element.assistant.title.attributed(with: mono100Attrs)
            
            contentView.backgroundColor = element.marked ? Appearance.main300 : UIColor.clear
            blurView.isHidden = element.marked
        case .whiteBlack:
            let attrs = element.marked ? mono100Attrs : mono200Attrs
            label.attributedText = element.assistant.title.attributed(with: attrs)
            
            contentView.backgroundColor = element.marked ? Appearance.main300 : Appearance.main200
            blurView.isHidden = true
        }
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
            blurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: contentView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AssistantsCollectionCell {
    func makeBlurView() -> UIVisualEffectView {
        let effect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: effect)
        view.isUserInteractionEnabled = false
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.cornerRadius = 12.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
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

//
//  PickerCollectionCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 03.03.2025.
//

import UIKit

final class PickerCollectionCell: UICollectionViewCell {
    lazy var label = makeLabel()
    
    private lazy var normalAttrs = TextAttributes()
        .textColor(Appearance.mono200.withAlphaComponent(0.3))
        .font(Fonts.Inter.regular(size: 16.scale))
        .lineHeight(22.scale)
        .textAlignment(.center)
    private lazy var selectedAttrs = TextAttributes()
        .textColor(Appearance.main400)
        .font(Fonts.Inter.medium(size: 18.scale))
        .lineHeight(22.scale)
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
extension PickerCollectionCell {
    func setup(element: PickerCollectionElement) {
        let attrs = element.selected ? selectedAttrs : normalAttrs
        label.attributedText = element.title.attributed(with: attrs)
    }
}

// MARK: Private
private extension PickerCollectionCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView = selectedView
    }
}

// MARK: Make constraints
private extension PickerCollectionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PickerCollectionCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}

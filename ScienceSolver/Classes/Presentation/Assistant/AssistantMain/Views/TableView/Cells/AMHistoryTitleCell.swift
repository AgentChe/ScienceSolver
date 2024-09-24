//
//  AMHistoryTitleCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import UIKit

final class AMHistoryTitleCell: UITableViewCell {
    lazy var label = makeLabel()
    lazy var arrowView = makeArrowView()
    
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
private extension AMHistoryTitleCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension AMHistoryTitleCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -48.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 24.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 24.scale),
            arrowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            arrowView.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AMHistoryTitleCell {
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 20.scale))
            .lineHeight(28.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "AssistantMain.History".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "AssistantMain.Arrow")
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}

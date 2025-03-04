//
//  HistoryTextCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit

final class HistoryTextCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var assistantNameLabel = makeLabel()
    lazy var contentLabel = makeLabel()
    lazy var createdLabel = makeLabel()
    
    private lazy var contentAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.Inter.medium(size: 16.scale))
        .lineHeight(19.scale)
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var createdAttrs = TextAttributes()
        .textColor(Appearance.mono200.withAlphaComponent(0.4))
        .font(Fonts.Inter.semiBold(size: 12.scale))
        .lineHeight(17.scale)
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
extension HistoryTextCell {
    func setup(assistantName: String, content: String, created: String) {
        assistantNameLabel.attributedText = assistantName.attributed(with: createdAttrs)
        
        let contentHTML: NSAttributedString = {
            let font = Fonts.Inter.medium(size: 16.scale)
            let htmlWithStyle = "<span style=\"font-family: \(font.fontName); font-style: regular; font-size: \(font.pointSize); line-height: \(19.scale)px;\">\(content)</span>"
            
            guard let data = htmlWithStyle.data(using: .utf8) else { return content.attributed(with: contentAttrs) }
            
            let attributedString = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            guard let attributedString else { return content.attributed(with: contentAttrs) }
            
            return attributedString
        }()
        contentLabel.attributedText = contentHTML
        
        createdLabel.attributedText = created.attributed(with: createdAttrs)
    }
}

// MARK: Private
private extension HistoryTextCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension HistoryTextCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            assistantNameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            assistantNameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            assistantNameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            contentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            contentLabel.topAnchor.constraint(equalTo: assistantNameLabel.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            createdLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            createdLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            createdLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale),
            createdLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HistoryTextCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono100
        view.layer.cornerRadius = 16.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.main200.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}

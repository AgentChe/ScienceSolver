//
//  HistoryImageCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit
import Kingfisher

final class HistoryImageCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var pictureView = makeImageView()
    lazy var createdLabel = makeLabel()
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pictureView.kf.cancelDownloadTask()
        pictureView.image = nil
    }
}

// MARK: Public
extension HistoryImageCell {
    func setup(imageUrl: URL, created: String) {
        pictureView.kf.setImage(with: imageUrl)
        createdLabel.attributedText = created.attributed(with: createdAttrs)
    }
}

// MARK: Private
private extension HistoryImageCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension HistoryImageCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            pictureView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            pictureView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            pictureView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            pictureView.heightAnchor.constraint(equalToConstant: 131.scale)
        ])
        
        NSLayoutConstraint.activate([
            createdLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            createdLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            createdLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale),
            createdLabel.topAnchor.constraint(equalTo: pictureView.bottomAnchor, constant: 8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HistoryImageCell {
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
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 16.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
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

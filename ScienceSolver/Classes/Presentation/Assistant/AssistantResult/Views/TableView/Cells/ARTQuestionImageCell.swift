//
//  ARTQuestionImageCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 23.09.2024.
//

import UIKit
import Kingfisher

final class ARTQuestionImageCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var pictureView = makeImageView()
    
    private lazy var pictureHeightConstraint = NSLayoutConstraint()
    
    private var imageSize: CGSize?
    
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
        
        imageSize = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if pictureHeightConstraint.constant == 0, imageSize != nil {
            updateLayout()
        }
    }
}

// MARK: Public
extension ARTQuestionImageCell {
    func setup(url: URL) {
        pictureView.kf.setImage(with: url) { [weak self] result in
            guard let self, case let .success(result) = result else { return }
            
            self.imageSize = result.image.size
            self.setNeedsLayout()
            
            updateLayout()
        }
    }
    
    func setup(image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            pictureView.image = image
            
            imageSize = image.size
            setNeedsLayout()
        }
    }
}

// MARK: Private
private extension ARTQuestionImageCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
    }
    
    func updateLayout() {
        guard let imageSize else { return }
        
        let aspectHeight = imageSize.height / imageSize.width * frame.width
        pictureHeightConstraint.constant = aspectHeight
        
        layoutIfNeeded()
    
        guard let tableView = superview as? UITableView else { return }
    
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}

// MARK: Make constraits
private extension ARTQuestionImageCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 40.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        pictureHeightConstraint = pictureView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            pictureView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            pictureView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            pictureView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            pictureView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale),
            pictureHeightConstraint
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

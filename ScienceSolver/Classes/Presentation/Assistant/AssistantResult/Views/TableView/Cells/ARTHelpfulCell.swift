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
    
    private var actionsView: UIView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
        makeActionsButtonsUI()
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
    }
    
    func makeActionsButtonsUI() {
        let view = HelpfulActionsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.scale),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
        
        self.actionsView = view
        
        view.didTapLike = { [weak self] in
            self?.makeReasonsUI(relatively: .like)
        }
        
        view.didTapDislike = { [weak self] in
            self?.makeReasonsUI(relatively: .dislike)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func makeReasonsUI(relatively: HelpfulReasonsView.Relatively) {
        actionsView?.removeFromSuperview()
        actionsView = nil
        
        let view = HelpfulReasonsView(relatively: relatively) { [weak self] in
            guard let self else { return }
            
            switch relatively {
            case .like:
                didTapLike?()
            case .dislike:
                didTapDislike?()
            }
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.scale),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
        
        self.actionsView = view
        
        if let tableView = self.superview as? UITableView {
            tableView.beginUpdates()
            
            setNeedsLayout()
            layoutIfNeeded()
            
            tableView.endUpdates()
       }
    }
}

// MARK: Make constraints
private extension ARTHelpfulCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
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
}

//
//  AccountHistoryCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 11.09.2024.
//

import UIKit

final class AccountHistoryCell: UITableViewCell {
    var didTap: (() -> Void)?
    
    lazy var actionView = makeActionView()
    
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
private extension AccountHistoryCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension AccountHistoryCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            actionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            actionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            actionView.heightAnchor.constraint(equalToConstant: 56.scale),
            actionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            actionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AccountHistoryCell {
    func makeActionView() -> AccountActionView {
        let view = AccountActionView(title: "Account.History".localized, separatorHidden: true) { [weak self] in
            self?.didTap?()
        }
        view.layer.cornerRadius = 16.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}

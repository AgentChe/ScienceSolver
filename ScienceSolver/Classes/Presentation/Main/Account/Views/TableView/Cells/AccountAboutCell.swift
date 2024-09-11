//
//  AccountAboutCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 11.09.2024.
//

import UIKit

final class AccountAboutCell: UITableViewCell {
    var didTapPrivacyPolicy: (() -> Void)?
    var didTapTermsOfUse: (() -> Void)?
    var didTapContactUs: (() -> Void)?
    
    lazy var titleLabel = makeTitleLabel()
    lazy var container = makeContainer()
    lazy var privacyPolicyView = makePrivacyPolicyView()
    lazy var termsOfUseView = makeTermsOfUseView()
    lazy var contactUsView = makeContactUsView()
    
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
private extension AccountAboutCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension AccountAboutCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            privacyPolicyView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            privacyPolicyView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            privacyPolicyView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            termsOfUseView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            termsOfUseView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            termsOfUseView.topAnchor.constraint(equalTo: privacyPolicyView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contactUsView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            contactUsView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            contactUsView.topAnchor.constraint(equalTo: termsOfUseView.bottomAnchor),
            contactUsView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AccountAboutCell {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.medium(size: 18.scale))
            .lineHeight(22.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Account.About".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 16.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.main200.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makePrivacyPolicyView() -> AccountActionView {
        let view = AccountActionView(title: "Account.PrivacyPolicy".localized, separatorHidden: true) { [weak self] in
            self?.didTapPrivacyPolicy?()
        }
        view.layer.cornerRadius = 16.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeTermsOfUseView() -> AccountActionView {
        let view = AccountActionView(title: "Account.TermsOfUse".localized, separatorHidden: true) { [weak self] in
            self?.didTapTermsOfUse?()
        }
        view.layer.cornerRadius = 16.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeContactUsView() -> AccountActionView {
        let view = AccountActionView(title: "Account.ContactUs".localized, separatorHidden: true) { [weak self] in
            self?.didTapContactUs?()
        }
        view.layer.cornerRadius = 16.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}

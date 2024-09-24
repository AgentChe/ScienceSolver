//
//  HistoryView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit

final class HistoryView: UIView {
    lazy var backButton = makeBackButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var tableView = makeTableView()
    lazy var emptyView = makeEmptyView()
    lazy var centerPreloader = makePreloader()
    lazy var tablePreloader = makePreloader()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension HistoryView {
    func initialize() {
        backgroundColor = Appearance.main100
    }
}

// MARK: Make constraints
private extension HistoryView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 24.scale),
            backButton.heightAnchor.constraint(equalToConstant: 24.scale),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            emptyView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale),
            emptyView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            centerPreloader.widthAnchor.constraint(equalToConstant: 45.scale),
            centerPreloader.heightAnchor.constraint(equalToConstant: 45.scale),
            centerPreloader.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            centerPreloader.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tablePreloader.widthAnchor.constraint(equalToConstant: 32.scale),
            tablePreloader.heightAnchor.constraint(equalToConstant: 32.scale),
            tablePreloader.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            tablePreloader.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HistoryView {
    func makeBackButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "History.Back"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.medium(size: 18.scale))
            .lineHeight(22.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "History.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> HistoryTableView {
        let view = HistoryTableView()
        view.backgroundColor = UIColor.clear
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.contentInset = UIEdgeInsets(vertical: 16.scale)
        view.setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEmptyView() -> HistoryEmptyView {
        let view = HistoryEmptyView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.color = Appearance.main300
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}


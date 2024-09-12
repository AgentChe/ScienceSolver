//
//  HistoryView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit

final class HistoryView: UIView {
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
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
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


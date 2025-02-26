//
//  AssistantResultView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit

final class AssistantResultView: UIView {
    lazy var tableView = makeTableView()
    
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
private extension AssistantResultView {
    func initialize() {
        backgroundColor = Appearance.main100
    }
}

// MARK: Make constraints
private extension AssistantResultView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AssistantResultView {
    func makeTableView() -> AssistantResultTableView {
        let view = AssistantResultTableView()
        view.backgroundColor = UIColor.clear
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.contentInset = UIEdgeInsets(vertical: 19.scale)
        view.setContentOffset(CGPoint(x: 0, y: -19.scale), animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

//
//  AssistantResultView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit

final class AssistantResultView: UIView {
    lazy var tableView = makeTableView()
    lazy var bottomView = makeBottomView()
    
    private lazy var tableViewBottomConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AssistantResultView {
    func setup(bottomViewMode: AssistantResultBottomView.Mode?) {
        let bottomViewHidden = bottomViewMode == nil
        
        bottomView.isHidden = bottomViewHidden
        bottomView.setup(mode: bottomViewMode)
        
        tableViewBottomConstraint.isActive = false
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(
            equalTo: bottomViewHidden ? safeAreaLayoutGuide.bottomAnchor : bottomView.topAnchor,
            constant: bottomViewHidden ? 0 : -12.scale
        )
        tableViewBottomConstraint.isActive = true
        
        layoutIfNeeded()
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
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableViewBottomConstraint
        ])
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 50.scale)
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
        view.contentInset = UIEdgeInsets()
        view.setContentOffset(CGPoint.zero, animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeBottomView() -> AssistantResultBottomView {
        let view = AssistantResultBottomView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

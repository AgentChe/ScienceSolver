//
//  AssistantMainView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import UIKit

final class AssistantMainView: UIView {
    lazy var assistantsCollectionView = makeAssistantsCollectionView()
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
private extension AssistantMainView {
    func initialize() {
        backgroundColor = Appearance.main100
    }
}

// MARK: Make constraints
private extension AssistantMainView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            assistantsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            assistantsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            assistantsCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 36.scale),
            assistantsCollectionView.heightAnchor.constraint(equalToConstant: 31.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: assistantsCollectionView.bottomAnchor, constant: 8.scale),
            tableView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AssistantMainView {
    func makeAssistantsCollectionView() -> AssistantsCollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12.scale
        layout.minimumInteritemSpacing = 0
        
        let view = AssistantsCollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.clear
        view.showsHorizontalScrollIndicator = false
        view.contentInset = UIEdgeInsets(horizontal: 100.scale)
        view.setContentOffset(CGPoint(x: -100.scale, y: 0), animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> AssistantMainTableView {
        let view = AssistantMainTableView()
        view.backgroundColor = UIColor.clear
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.contentInset = UIEdgeInsets(vertical: 16.scale)
        view.setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

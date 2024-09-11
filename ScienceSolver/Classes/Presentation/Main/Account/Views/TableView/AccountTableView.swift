//
//  AccountTableView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 11.09.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountTableView: UITableView {
    lazy var elements = [AccountTableElement]()
    
    private lazy var didTapHistoryTrigger = PublishRelay<Void>()
    private lazy var didTapPrivacyPolicyTrigger = PublishRelay<Void>()
    private lazy var didTapTermsOfUseTrigger = PublishRelay<Void>()
    private lazy var didTapContactUsTrigger = PublishRelay<Void>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AccountTableView {
    func setup(elements: [AccountTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapHistory: Signal<Void> {
        didTapHistoryTrigger.asSignal()
    }
    
    var didTapPrivacyPolicy: Signal<Void> {
        didTapPrivacyPolicyTrigger.asSignal()
    }
    
    var didTapTermsOfUse: Signal<Void> {
        didTapTermsOfUseTrigger.asSignal()
    }
    
    var didTapContactUs: Signal<Void> {
        didTapContactUsTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension AccountTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .title:
            return dequeueReusableCell(withIdentifier: String(describing: AccountTitleCell.self), for: indexPath)
        case .history:
            let cell = dequeueReusableCell(withIdentifier: String(describing: AccountHistoryCell.self), for: indexPath) as! AccountHistoryCell
            cell.didTap = { [weak self] in
                self?.didTapHistoryTrigger.accept(Void())
            }
            return cell
        case .about:
            let cell = dequeueReusableCell(withIdentifier: String(describing: AccountAboutCell.self), for: indexPath) as! AccountAboutCell
            cell.didTapPrivacyPolicy = { [weak self] in
                self?.didTapPrivacyPolicyTrigger.accept(Void())
            }
            cell.didTapTermsOfUse = { [weak self] in
                self?.didTapTermsOfUseTrigger.accept(Void())
            }
            cell.didTapContactUs = { [weak self] in
                self?.didTapContactUsTrigger.accept(Void())
            }
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension AccountTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension AccountTableView {
    func initialize() {
        register(AccountTitleCell.self, forCellReuseIdentifier: String(describing: AccountTitleCell.self))
        register(AccountHistoryCell.self, forCellReuseIdentifier: String(describing: AccountHistoryCell.self))
        register(AccountAboutCell.self, forCellReuseIdentifier: String(describing: AccountAboutCell.self))
        
        dataSource = self
        delegate = self
    }
}

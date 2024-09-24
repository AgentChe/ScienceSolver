//
//  AccountViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 11.09.2024.
//

import UIKit
import RxSwift

final class AccountViewController: UIViewController {
    private lazy var mainView = AccountView()
    
    private lazy var viewModel = AccountViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: AccountViewModel.Input(
            didTapHistory: mainView.tableView.didTapHistory,
            didTapPrivacyPolicy: mainView.tableView.didTapPrivacyPolicy,
            didTapTermsOfUse: mainView.tableView.didTapTermsOfUse,
            didTapContactUs: mainView.tableView.didTapContactUs
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension AccountViewController {
    static func make() -> AccountViewController {
        let vc = AccountViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension AccountViewController {
    func route(_ route: AccountViewModel.Route) {
        switch route {
        case .history:
            let vc = HistoryViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        case .url(let url):
            UIApplication.shared.open(url)
        }
    }
}

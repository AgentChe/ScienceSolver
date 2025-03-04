//
//  HistoryViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit
import RxSwift

final class HistoryViewController: UIViewController {
    private lazy var mainView = HistoryView()
    
    private lazy var viewModel = HistoryViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: HistoryViewModel.Input(
            didSelect: mainView.tableView.didSelect,
            didScrollToBottom: mainView.tableView.didScrollToBottom
        ))
        
        output.elements
            .drive(Binder(mainView) { base, elements in
                base.tableView.add(elements: elements)
                base.emptyView.isHidden = !base.tableView.elements.isEmpty
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.firstPageActivity
            .drive(Binder(self) { base, activity in
                base.firstPage(activity: activity)
            })
            .disposed(by: disposeBag)
        
        output.paginationActivity
            .drive(Binder(self) { base, activity in
                base.pagination(activity: activity)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension HistoryViewController {
    static func make() -> HistoryViewController {
        let vc = HistoryViewController()
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "History.Title".localized
        return vc
    }
}

// MARK: Private
private extension HistoryViewController {
    func route(_ route: HistoryViewModel.Route) {
        switch route {
        case .select(let item):
            guard let nc = navigationController else { return }
            
            AssistantAssembly().history(item: item, from: nc)
        case .paygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
    
    func firstPage(activity: Bool) {
        activity ? mainView.centerPreloader.startAnimating() : mainView.centerPreloader.stopAnimating()
    }
    
    func pagination(activity: Bool) {
        mainView.tableView.contentInset.bottom = activity ? 48.scale : 16.scale
        activity ? mainView.tablePreloader.startAnimating() : mainView.tablePreloader.stopAnimating()
    }
}

//
//  AssistantResultViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit
import RxSwift
import Toast_Swift

final class AssistantResultViewController: UIViewController {
    private lazy var mainView = AssistantResultView()
    
    private let viewModel: AssistantResultViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private let didTapClose: () -> Void
    
    private init(recognized: AssistantRecognizerController.Result, didTapClose: @escaping () -> Void) {
        self.viewModel = AssistantResultViewModel(recognized: recognized)
        self.didTapClose = didTapClose
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: AssistantResultViewModel.Input(
            didTapClose: mainView.closeButton.rx.tap.asSignal(),
            didTapRefresh: mainView.tableView.didTapRefresh,
            didTapCopy: mainView.tableView.didTapCopy
        ))
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension AssistantResultViewController {
    static func make(recognized: AssistantRecognizerController.Result, didTapClose: @escaping () -> Void) -> AssistantResultViewController {
        let vc = AssistantResultViewController(recognized: recognized, didTapClose: didTapClose)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension AssistantResultViewController {
    func route(_ route: AssistantResultViewModel.Route) {
        switch route {
        case .close:
            didTapClose()
        }
    }
    
    func action(_ action: AssistantResultViewModel.Action) {
        switch action {
        case .copy(let string):
            UIPasteboard.general.string = string
            
            mainView.makeToast("AssistantResult.Copied".localized, position: .top)
        }
    }
}

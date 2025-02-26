//
//  AssistantResultViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit
import RxSwift
import RxCocoa
import Toast_Swift

final class AssistantResultViewController: UIViewController {
    private lazy var mainView = AssistantResultView()
    
    private let viewModel: AssistantResultViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private let didTapClose: () -> Void
    
    private lazy var didRefreshTrigger = PublishRelay<AssistantResultViewModel.AssistantResult>()
    private lazy var didLikeTrigger = PublishRelay<AssistantResultViewModel.AssistantResult>()
    private lazy var didDislikeTrigger = PublishRelay<AssistantResultViewModel.AssistantResult>()
    
    private var navigationClosedButtonTapped: (() -> Void)?
    
    private init(historyItem: AssistantHistoryItem, didTapClose: @escaping () -> Void) {
        self.viewModel = AssistantResultViewModel(historyItem: historyItem)
        self.didTapClose = didTapClose
        
        super.init(nibName: nil, bundle: nil)
    }
    
    private init(recognized: AssistantRecognizerController.Result, didTapClose: @escaping () -> Void) {
        self.viewModel = AssistantResultViewModel(recognized: recognized)
        self.didTapClose = didTapClose
        
        super.init(nibName: nil, bundle: nil)
    }
    
    private init(manual: AssistantMainViewController.DataForManualAnalyze, didTapClose: @escaping () -> Void) {
        self.viewModel = AssistantResultViewModel(manual: manual)
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
            didTapRefresh: didRefreshTrigger.asSignal(),
            didTapCopy: mainView.tableView.didTapCopy,
            didTapLike: didLikeTrigger.asSignal(),
            didTapDislike: didDislikeTrigger.asSignal()
        ))
        
        let currentAssistantResult = output.currentResult
        
        mainView.tableView.didTapRefresh
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(currentAssistantResult)
            .drive(Binder(self) { base, currentAssistantResult in
                base.didRefreshTrigger.accept(currentAssistantResult)
            })
            .disposed(by: disposeBag)
        
        mainView.tableView.didTapLike
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(currentAssistantResult)
            .drive(Binder(self) { base, currentAssistantResult in
                base.didLikeTrigger.accept(currentAssistantResult)
            })
            .disposed(by: disposeBag)
        
        mainView.tableView.didTapDislike
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(currentAssistantResult)
            .drive(Binder(self) { base, currentAssistantResult in
                base.didDislikeTrigger.accept(currentAssistantResult)
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
    
    static func make(historyItem: AssistantHistoryItem, didTapClose: @escaping () -> Void) -> AssistantResultViewController {
        let vc = AssistantResultViewController(historyItem: historyItem, didTapClose: didTapClose)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
    
    static func make(manual: AssistantMainViewController.DataForManualAnalyze, didTapClose: @escaping () -> Void) -> AssistantResultViewController {
        let vc = AssistantResultViewController(manual: manual, didTapClose: didTapClose)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
    
    func addCloseButtonInNavigationBar(closed: @escaping () -> Void) {
        let closeButton = TapAreaButton()
        closeButton.backgroundColor = UIColor.clear
        closeButton.setImage(UIImage(named: "AssistantResult.Close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        let item = UIBarButtonItem(customView: closeButton)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 44.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 44.scale).isActive = true
        
        navigationItem.leftBarButtonItem = item
        
        navigationClosedButtonTapped = closed
    }
}

// MARK: Private
private extension AssistantResultViewController {
    func action(_ action: AssistantResultViewModel.Action) {
        switch action {
        case .copy(let string):
            UIPasteboard.general.string = string
            
            mainView.makeToast("AssistantResult.Copied".localized, position: .top)
        }
    }
    
    @objc
    func closeButtonTapped() {
        navigationClosedButtonTapped?()
    }
}

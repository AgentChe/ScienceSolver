//
//  AssistantMainViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class AssistantMainViewController: UIViewController {
    enum DataForManualAnalyze {
        case math(String)
        case physics(String)
        case biology(String)
        case chemistry(String)
        case writing(String, WritingMode, WritingStyle)
        case language(String, Language)
    }
    
    private lazy var mainView = AssistantMainView()
    
    private lazy var viewModel = AssistantMainViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didSelectWritingStyleTrigger = PublishRelay<WritingStyle>()
    private lazy var didSelectLanguageTrigger = PublishRelay<Language>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: AssistantMainViewModel.Input(
            didSelectAssistant: mainView.assistantsCollectionView.didSelect,
            didTapHistory: mainView.tableView.didTapHistory,
            didSelectHistoryItem: mainView.tableView.didSelectHistoryItem,
            didSelectWritingStyle: didSelectWritingStyleTrigger.asSignal(),
            didSelectLanguage: didSelectLanguageTrigger.asSignal(),
            didTapSelectAdditionalData: mainView.tableView.didTapSelectAdditionalData,
            didChangeWritingMode: mainView.tableView.didChangeWritingMode,
            didTapCamera: mainView.tableView.didTapCamera,
            didTapCalculator: mainView.tableView.didTapCalculator,
            didTapDone: mainView.tableView.didTapDone
        ))
        
        output.assistantsElements
            .drive(Binder(mainView.assistantsCollectionView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
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
        
        output.currentAssistant
            .drive(Binder(mainView.tableView) { base, currentAssistant in
                base.setup(assistant: currentAssistant)
            })
            .disposed(by: disposeBag)
        
        output.writingMode
            .drive(Binder(mainView.tableView) { base, writingMode in
                base.setup(writingMode: writingMode)
            })
            .disposed(by: disposeBag)
        
        output.additionalDataEntity
            .drive(Binder(mainView.tableView) { base, additionalDataEntity in
                base.setup(additionalDataEntity: additionalDataEntity)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension AssistantMainViewController {
    static func make() -> AssistantMainViewController {
        let vc = AssistantMainViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension AssistantMainViewController {
    func route(_ route: AssistantMainViewModel.Route) {
        switch route {
        case .history:
            let vc = HistoryViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        case .historyItem(let assistantHistoryItem):
            guard let nc = navigationController else { return }
            
            AssistantAssembly().history(item: assistantHistoryItem, from: nc)
        case .selectWritingStyle(let mode, let style):
            let vc = SWMViewController.make(mode: mode, style: style) { [weak self] result in
                self?.didSelectWritingStyleTrigger.accept(result)
            }
            present(vc, animated: false)
        case .selectLanguage(let language):
            let vc = SLViewController.make(language: language) { [weak self] language in
                self?.didSelectLanguageTrigger.accept(language)
            }
            present(vc, animated: false)
        case .assistantRecognize(let assistant):
            AssistantAssembly().recognize(assistant: assistant, from: self)
        case .calculator:
            break // TODO
        case .analyze(let data):
            AssistantAssembly().manualAnalyze(data: data, from: self)
        }
    }
}

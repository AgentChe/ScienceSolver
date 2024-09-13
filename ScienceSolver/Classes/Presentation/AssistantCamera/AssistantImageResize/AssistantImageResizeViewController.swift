//
//  AssistantImageResizeViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 13.09.2024.
//

import UIKit
import RxSwift

final class AssistantImageResizeViewController: UIViewController {
    var didCancel: (() -> Void)?
    
    private lazy var mainView = AssistantImageResizeView()
    
    private let viewModel: AssistantImageResizeViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private init(fromCamera: AssistantCameraViewController.Result) {
        viewModel = AssistantImageResizeViewModel(fromCamera: fromCamera)
        
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
        
        let output = viewModel.configure(input: AssistantImageResizeViewModel.Input(
            didTapCancel: mainView.cancelButton.rx.tap.asSignal(),
            didTapDone: mainView.doneButton.rx.tap.asSignal()
        ))
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.originalImage
            .drive(Binder(mainView.imageView) { base, image in
                base.image = image
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension AssistantImageResizeViewController {
    static func make(fromCamera: AssistantCameraViewController.Result) -> AssistantImageResizeViewController {
        AssistantImageResizeViewController(fromCamera: fromCamera)
    }
}

// MARK: Private
private extension AssistantImageResizeViewController {
    func route(_ route: AssistantImageResizeViewModel.Route) {
        switch route {
        case .cancel:
            didCancel?()
        case .done:
            break // TODO
        }
    }
}

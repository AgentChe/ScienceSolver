//
//  AssistantRecognizerController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 13.09.2024.
//

import UIKit
import RxSwift

final class AssistantRecognizerController: UIViewController {
    struct Result {
        let fromCamera: AssistantCameraViewController.Result
        let recognized: AssistantImageResizeViewController.Result
    }
    
    private lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.mono200
        return view
    }()
    
    private let cameraVC: AssistantCameraViewController
    
    private var previousVC: UIViewController?
    
    private lazy var disposeBag = DisposeBag()
    
    private let close: () -> Void
    private let result: (Result) -> Void
    
    private init(
        assistant: AssistantsCollectionElement.Assistant?, 
        close: @escaping () -> Void,
        result: @escaping (Result) -> Void
    ) {
        self.cameraVC = AssistantCameraViewController.make(assistant: assistant)
        self.close = close
        self.result = result
        
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
        
        cameraVC.didResult = { [weak self] fromCamera in
            guard let self else { return }
            
            let vc = AssistantImageResizeViewController.make(fromCamera: fromCamera)
            
            vc.didResult = { [weak self] recognized in
                let finally = Result(fromCamera: fromCamera, recognized: recognized)
                
                self?.result(finally)
            }
            
            vc.didCancel = { [weak self] in
                guard let self else { return }
                
                changeVC(on: cameraVC)
            }
            
            changeVC(on: vc)
        }
        
        cameraVC.didClose = { [weak self] in
            self?.close()
        }
        
        rx.methodInvoked(#selector(UIViewController.viewDidLayoutSubviews))
            .take(1)
            .bind(to: Binder(self) { base, _ in
                base.changeVC(on: base.cameraVC)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension AssistantRecognizerController {
    static func make(
        assistant: AssistantsCollectionElement.Assistant? = nil,
        close: @escaping () -> Void,
        result: @escaping (AssistantRecognizerController.Result) -> Void
    ) -> AssistantRecognizerController {
        let vc = AssistantRecognizerController(assistant: assistant, close: close, result: result)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private
private extension AssistantRecognizerController {
    func changeVC(on vc: UIViewController) {
        if let previousVC = self.previousVC {
            previousVC.willMove(toParent: nil)
            previousVC.view.removeFromSuperview()
            previousVC.removeFromParent()
        }
    
        self.previousVC = vc
    
        addChild(vc)
        vc.view.frame = mainView.bounds
        mainView.addSubview(vc.view)
        vc.willMove(toParent: self)
    }
}

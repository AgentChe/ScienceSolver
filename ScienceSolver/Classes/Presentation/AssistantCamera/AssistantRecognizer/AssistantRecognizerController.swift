//
//  AssistantRecognizerController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 13.09.2024.
//

import UIKit
import RxSwift

final class AssistantRecognizerController: UIViewController {
    private lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.mono200
        return view
    }()
    
    private let cameraVC: AssistantCameraViewController
    
    private var previousVC: UIViewController?
    
    private lazy var disposeBag = DisposeBag()
    
    private init(assistant: AssistantsCollectionElement.Assistant?) {
        cameraVC = AssistantCameraViewController.make(assistant: assistant)
        
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
        
        cameraVC.didResult = { [weak self] result in
            guard let self else { return }
            
            let vc = AssistantImageResizeViewController.make(fromCamera: result)
            
            vc.didCancel = { [weak self] in
                guard let self else { return }
                
                changeVC(on: cameraVC)
            }
            
            changeVC(on: vc)
        }
        
        cameraVC.didClose = { [weak self] in
            self?.dismiss(animated: true)
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
    static func make(assistant: AssistantsCollectionElement.Assistant? = nil) -> AssistantRecognizerController {
        let vc = AssistantRecognizerController(assistant: assistant)
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

//
//  ACEViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 17.09.2024.
//

import UIKit
import RxSwift

final class ACEViewController: UIViewController {
    private lazy var mainView = ACEView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let tryAgain: () -> Void
    
    private init(tryAgain: @escaping () -> Void) {
        self.tryAgain = tryAgain
        
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
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss()
            })
            .disposed(by: disposeBag)
        
        mainView.tryAgainButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss {
                    base.tryAgain()
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        dismiss()
    }
}

// MARK: Public
extension ACEViewController {
    static func make(tryAgain: @escaping () -> Void) -> ACEViewController {
        let vc = ACEViewController(tryAgain: tryAgain)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension ACEViewController {
    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}

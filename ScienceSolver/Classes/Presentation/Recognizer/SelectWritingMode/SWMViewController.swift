//
//  SWMViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 17.09.2024.
//

import UIKit
import RxSwift

final class SWMViewController: UIViewController {
    private lazy var mainView = SWMView(mode: mode)
    
    private lazy var disposeBag = DisposeBag()
    
    private let mode: WritingMode
    private let style: WritingStyle?
    private let select: (WritingStyle) -> Void
    
    private init(mode: WritingMode, style: WritingStyle?, select: @escaping (WritingStyle) -> Void) {
        self.mode = mode
        self.style = style
        self.select = select
        
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
        
        mainView.saveButton.rx.tap
            .compactMap { [weak self] void -> WritingStyle? in
                self?.mainView.pickerView.selectedStyle
            }
            .bind(to: Binder(self) { base, style in
                base.dismiss {
                    base.select(style)
                }
            })
            .disposed(by: disposeBag)
        
        if let style {
            mainView.pickerView.select(style: style)
        }
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
extension SWMViewController {
    static func make(mode: WritingMode, style: WritingStyle? = nil, select: @escaping (WritingStyle) -> Void) -> SWMViewController {
        let vc = SWMViewController(mode: mode, style: style, select: select)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension SWMViewController {
    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}

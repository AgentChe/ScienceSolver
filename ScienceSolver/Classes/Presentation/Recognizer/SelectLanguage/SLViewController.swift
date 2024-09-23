//
//  SLViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 17.09.2024.
//

import UIKit
import RxSwift

final class SLViewController: UIViewController {
    private lazy var mainView = SLView()
    
    private lazy var viewModel = SLViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private let initialLanguage: Language?
    private let select: (Language) -> Void
    
    private init(language: Language? = nil, select: @escaping (Language) -> Void) {
        self.initialLanguage = language
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
        
        let output = viewModel.configure(input: SLViewModel.Input())
        
        output.languages
            .drive(Binder(self) { base, languages in
                base.mainView.pickerView.setup(languages: languages, scrollTo: base.initialLanguage)
            })
            .disposed(by: disposeBag)
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss()
            })
            .disposed(by: disposeBag)
        
        mainView.saveButton.rx.tap
            .compactMap { [weak self] void -> Language? in
                self?.mainView.pickerView.selectedLanguage
            }
            .bind(to: Binder(self) { base, style in
                base.dismiss {
                    base.select(style)
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
extension SLViewController {
    static func make(language: Language? = nil, select: @escaping (Language) -> Void) -> SLViewController {
        let vc = SLViewController(language: language, select: select)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension SLViewController {
    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}

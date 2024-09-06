//
//  SplashViewController.swift
//  Soccer
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import UIKit
import RxSwift
import RxCocoa

final class SplashViewController: UIViewController {
    private lazy var mainView = SplashView()
    
    private lazy var viewModel = SplashViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var sdkInitialize = SplashReceiptValidationObserver()
    
    private lazy var didSDKConfiguredTrigger = PublishRelay<Void>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: SplashViewModel.Input())
        
        sdkInitialize.observe { [weak self] in
            self?.didSDKConfiguredTrigger.accept(Void())
        }
    }
}

// MARK: Make
extension SplashViewController {
    static func make() -> SplashViewController {
        SplashViewController()
    }
}

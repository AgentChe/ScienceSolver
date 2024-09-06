//
//  OnboardingViewController.swift
//  Soccer
//
//  Created by Андрей Чернышев on 23.08.2022.
//

import UIKit
import RxSwift
import RxCocoa

final class OnboardingViewController: UIViewController {
    struct Constants {
        static let wasViewedKey = "onboarding_view_controller_was_viewed_key"
    }
    
    private lazy var mainView = OnboardingView()
    
    private lazy var viewModel = OnboardingViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didCompleteOnboardingTrigger = PublishRelay<Void>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: OnboardingViewModel.Input( ))
        
        mainView.didFinish = { [weak self] in
            self?.markAsViewed()
            self?.didCompleteOnboardingTrigger.accept(Void())
        }
    }
}

// MARK: Public
extension OnboardingViewController {
    static func make() -> OnboardingViewController {
        OnboardingViewController()
    }
    
    static func wasViewed() -> Bool {
        UserDefaults.standard.bool(forKey: OnboardingViewController.Constants.wasViewedKey)
    }
}

// MARK: Private
private extension OnboardingViewController {
    func markAsViewed() {
        UserDefaults.standard.setValue(true, forKey: Constants.wasViewedKey)
    }
}

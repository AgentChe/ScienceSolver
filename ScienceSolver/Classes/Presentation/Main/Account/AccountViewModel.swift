//
//  AccountViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 11.09.2024.
//

import RxSwift
import RxCocoa

final class AccountViewModel {
    enum Route {
        case history
        case url(URL)
    }
}

// MARK: Public
extension AccountViewModel {
    struct Input {
        let didTapHistory: Signal<Void>
        let didTapPrivacyPolicy: Signal<Void>
        let didTapTermsOfUse: Signal<Void>
        let didTapContactUs: Signal<Void>
    }
    
    struct Output {
        let elements: Driver<[AccountTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        Output(
            elements: makeElements(),
            route: makeRoute(
                didTapHistory: input.didTapHistory,
                didTapPrivacyPolicy: input.didTapPrivacyPolicy,
                didTapTermsOfUse: input.didTapTermsOfUse,
                didTapContactUs: input.didTapContactUs
            )
        )
    }
}

// MARK: Private
private extension AccountViewModel {
    func makeElements() -> Driver<[AccountTableElement]> {
        Single
            .create { single in
                let elements: [AccountTableElement] = [
                    .title,
                    .history,
                    .about
                ]
                single(.success(elements))
                
                return Disposables.create()
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(
        didTapHistory: Signal<Void>,
        didTapPrivacyPolicy: Signal<Void>,
        didTapTermsOfUse: Signal<Void>,
        didTapContactUs: Signal<Void>
    ) -> Driver<Route> {
        let history = didTapHistory
            .map { Route.history }
            .asDriver(onErrorDriveWith: .never())
        
        let url = Signal
            .merge(
                didTapPrivacyPolicy
                    .map { GlobalDefinitions.privacyPolicyUrl }
                    .map { Route.url($0) },
                
                didTapTermsOfUse
                    .map { GlobalDefinitions.termsOfServiceUrl }
                    .map { Route.url($0) },
                
                didTapContactUs
                    .map { GlobalDefinitions.contactUsUrl }
                    .map { Route.url($0) }
            )
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge([history, url])
    }
}

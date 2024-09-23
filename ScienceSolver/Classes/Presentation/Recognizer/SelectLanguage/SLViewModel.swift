//
//  SLViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 17.09.2024.
//

import RxSwift
import RxCocoa

final class SLViewModel {
    private lazy var assistantManager = AssistantManager()
}

// MARK: Public
extension SLViewModel {
    struct Input {}
    
    struct Output {
        let languages: Driver<[Language]>
    }
    
    func configure(input: Input) -> Output {
        Output(
            languages: makeLanguages()
        )
    }
}

// MARK: Private
private extension SLViewModel {
    func makeLanguages() -> Driver<[Language]> {
        assistantManager
            .obtainLanaguages(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
}

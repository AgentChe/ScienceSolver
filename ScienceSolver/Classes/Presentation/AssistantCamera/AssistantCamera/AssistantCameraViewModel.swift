//
//  AssistantCameraViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import RxSwift
import RxCocoa

final class AssistantCameraViewModel {
    enum Route {
        case dismiss, selectImageFromLibrary
    }
    
    private let initialAssistant: Driver<AssistantsCollectionElement.Assistant?>
    
    init(assistant: AssistantsCollectionElement.Assistant?) {
        initialAssistant = BehaviorRelay(value: assistant).asDriver()
    }
}

// MARK: Public
extension AssistantCameraViewModel {
    struct Input {
        let didTapDismiss: Signal<Void>
        let didTapSelectImageFromLibrary: Signal<Void>
    }
    
    struct Output {
        let route: Driver<Route>
        let elements: Driver<[AssistantsCollectionElement]>
    }
    
    func configure(input: Input) -> Output {
        Output(
            route: makeRoute(
                didTapDismiss: input.didTapDismiss,
                didTapSelectImageFromLibrary: input.didTapSelectImageFromLibrary
            ),
            elements: makeElements()
        )
    }
}

// MARK: Private
private extension AssistantCameraViewModel {
    func makeRoute(
        didTapDismiss: Signal<Void>,
        didTapSelectImageFromLibrary: Signal<Void>
    ) -> Driver<Route> {
        let dismiss = didTapDismiss
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
        
        let selectImageFromLibrary = didTapSelectImageFromLibrary
            .map { Route.selectImageFromLibrary }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(dismiss, selectImageFromLibrary)
    }
    
    func makeElements() -> Driver<[AssistantsCollectionElement]> {
        initialAssistant
            .map { initialAssistant -> [AssistantsCollectionElement] in
                [
                    .init(assistant: .math, marked: (initialAssistant == .math) || initialAssistant == nil),
                    .init(assistant: .physics, marked: initialAssistant == .physics),
                    .init(assistant: .biology, marked: initialAssistant == .biology),
                    .init(assistant: .chemistry, marked: initialAssistant == .chemistry),
                    .init(assistant: .writing, marked: initialAssistant == .writing),
                    .init(assistant: .language, marked: initialAssistant == .language)
                ]
            }
    }
}
